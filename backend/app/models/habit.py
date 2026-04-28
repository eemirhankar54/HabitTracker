from typing import Optional

from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..core.database import Base
from datetime import date


class Habit(Base):
    __tablename__ = "habits"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(100), nullable=False)
    description = Column(Text, default="")
    icon_emoji = Column(String(10), default="⭐")
    color_hex = Column(String(7), default="#6C63FF")
    target_days_per_week = Column(Integer, default=7)
    reminder_hour = Column(Integer, default=-1)   # -1 = bildirim yok
    reminder_minute = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="habits")
    logs = relationship("HabitLog", back_populates="habit", cascade="all, delete-orphan")
    
    @property
    def today_log_id(self) -> Optional[int]:
        """Bugün için bir log kaydı varsa ID'sini döner, yoksa None döner."""
        today = date.today()
        # logs ilişkisi üzerinden bugünkü kaydı ara
        for log in self.logs:
            if log.completed_at.date() == today:
                return log.id
        return None


class HabitLog(Base):
    __tablename__ = "habit_logs"

    id = Column(Integer, primary_key=True, index=True)
    habit_id = Column(Integer, ForeignKey("habits.id"), nullable=False)
    completed_at = Column(DateTime(timezone=True), server_default=func.now())
    note = Column(Text, default="")

    habit = relationship("Habit", back_populates="logs")
