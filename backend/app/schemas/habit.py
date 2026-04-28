from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List


class HabitCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=100)
    description: str = ""
    icon_emoji: str = "⭐"
    color_hex: str = "#6C63FF"
    target_days_per_week: int = Field(ge=1, le=365)
    reminder_hour: int = Field(-1, ge=-1, le=23)
    reminder_minute: int = Field(0, ge=0, le=59)


class HabitUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    icon_emoji: Optional[str] = None
    color_hex: Optional[str] = None
    target_days_per_week: Optional[int] = Field(None, ge=1, le=365)
    reminder_hour: Optional[int] = Field(None, ge=-1, le=23)
    reminder_minute: Optional[int] = Field(None, ge=0, le=59)
    is_active: Optional[bool] = None


class HabitOut(BaseModel):
    id: int
    title: str
    description: str
    icon_emoji: str
    color_hex: str
    target_days_per_week: int
    reminder_hour: int
    reminder_minute: int
    is_active: bool
    created_at: datetime
    streak: int = 0
    today_log_id: Optional[int] = None  

    model_config = {"from_attributes": True}


class HabitLogCreate(BaseModel):
    habit_id: int
    note: str = ""


class HabitLogOut(BaseModel):
    id: int
    habit_id: int
    completed_at: datetime
    note: str

    model_config = {"from_attributes": True}


class StatsOut(BaseModel):
    total_habits: int
    today_completed: int
    today_total: int
    today_progress: float
    weekly_completion: List[dict]   # [{"date": "2024-01-01", "count": 3}, ...]
    longest_streak: int
