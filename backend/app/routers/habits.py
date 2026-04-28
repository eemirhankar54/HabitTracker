from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, cast, Date
from datetime import datetime, date, timedelta
from typing import List
from ..core.database import get_db
from ..core.security import get_current_user
from ..models.user import User
from ..models.habit import Habit, HabitLog
from ..schemas.habit import (
    HabitCreate, HabitUpdate, HabitOut,
    HabitLogCreate, HabitLogOut, StatsOut,
)

router = APIRouter(prefix="/habits", tags=["Habits"])


def _calculate_streak(db: Session, habit_id: int) -> int:
    """Bugünden geriye kaç ardışık gün tamamlandı."""
    streak = 0
    current = date.today()
    while True:
        exists = db.query(HabitLog).filter(
            HabitLog.habit_id == habit_id,
            cast(HabitLog.completed_at, Date) == current,
        ).first()
        if exists:
            streak += 1
            current -= timedelta(days=1)
        else:
            break
    return streak


# ── Habit CRUD ────────────────────────────────────────────────────────────────

@router.get("/", response_model=List[HabitOut])
def get_habits(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habits = (
        db.query(Habit)
        .filter(Habit.user_id == current_user.id, Habit.is_active == True)
        .order_by(Habit.created_at)
        .all()
    )
    result = []
    for h in habits:
        out = HabitOut.model_validate(h)
        out.streak = _calculate_streak(db, h.id)
        result.append(out)
    return result


@router.post("/", response_model=HabitOut, status_code=201)
def create_habit(
    payload: HabitCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = Habit(**payload.model_dump(), user_id=current_user.id)
    db.add(habit)
    db.commit()
    db.refresh(habit)
    out = HabitOut.model_validate(habit)
    out.streak = 0
    return out


@router.patch("/{habit_id}", response_model=HabitOut)
def update_habit(
    habit_id: int,
    payload: HabitUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = db.query(Habit).filter(
        Habit.id == habit_id, Habit.user_id == current_user.id
    ).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit bulunamadı")

    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(habit, field, value)
    db.commit()
    db.refresh(habit)
    out = HabitOut.model_validate(habit)
    out.streak = _calculate_streak(db, habit.id)
    return out


@router.delete("/{habit_id}", status_code=204)
def delete_habit(
    habit_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = db.query(Habit).filter(
        Habit.id == habit_id, Habit.user_id == current_user.id
    ).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit bulunamadı")
    db.delete(habit)
    db.commit()


# ── Habit Log (Tamamlama) ─────────────────────────────────────────────────────

@router.post("/log", response_model=HabitLogOut, status_code=201)
def log_habit(
    payload: HabitLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Habit bu kullanıcıya ait mi?
    habit = db.query(Habit).filter(
        Habit.id == payload.habit_id, Habit.user_id == current_user.id
    ).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit bulunamadı")

    # Bugün zaten tamamlandı mı?
    today = date.today()
    already = db.query(HabitLog).filter(
        HabitLog.habit_id == payload.habit_id,
        cast(HabitLog.completed_at, Date) == today,
    ).first()
    if already:
        raise HTTPException(status_code=409, detail="Bugün zaten tamamlandı")

    log = HabitLog(habit_id=payload.habit_id, note=payload.note)
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


@router.delete("/log/{log_id}", status_code=204)
def unlog_habit(
    log_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    log = (
        db.query(HabitLog)
        .join(Habit)
        .filter(HabitLog.id == log_id, Habit.user_id == current_user.id)
        .first()
    )
    if not log:
        raise HTTPException(status_code=404, detail="Log bulunamadı")
    db.delete(log)
    db.commit()


# ── İstatistikler ─────────────────────────────────────────────────────────────

@router.get("/stats", response_model=StatsOut)
def get_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habits = db.query(Habit).filter(
        Habit.user_id == current_user.id, Habit.is_active == True
    ).all()
    habit_ids = [h.id for h in habits]
    today = date.today()

    # Bugün tamamlananlar
    today_completed = db.query(HabitLog).filter(
        HabitLog.habit_id.in_(habit_ids),
        cast(HabitLog.completed_at, Date) == today,
    ).count()

    # Son 7 günlük tamamlanma
    weekly = []
    for i in range(6, -1, -1):
        day = today - timedelta(days=i)
        count = db.query(HabitLog).filter(
            HabitLog.habit_id.in_(habit_ids),
            cast(HabitLog.completed_at, Date) == day,
        ).count()
        weekly.append({"date": day.isoformat(), "count": count})

    # En uzun streak
    longest = max(
        (_calculate_streak(db, h.id) for h in habits), default=0
    )

    total = len(habits)
    return StatsOut(
        total_habits=total,
        today_completed=today_completed,
        today_total=total,
        today_progress=today_completed / total if total else 0.0,
        weekly_completion=weekly,
        longest_streak=longest,
    )
