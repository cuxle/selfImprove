from sqlalchemy import Column, Integer, BigInteger, String, Boolean, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.config.database import Base
from datetime import datetime


class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    reminder_type = Column(String(20), nullable=False)  # 'diary' or 'challenge'
    is_enabled = Column(Boolean, default=True, nullable=False)
    reminder_time = Column(String(5), nullable=False)  # HH:MM format
    frequency = Column(String(20), default="daily", nullable=False)  # daily, weekly, custom
    days_of_week = Column(String(100), nullable=True)  # JSON string for days
    message = Column(String(200), nullable=True)
    created_at = Column(String(50), default=lambda: datetime.now().isoformat())
    updated_at = Column(String(50), default=lambda: datetime.now().isoformat(), onupdate=lambda: datetime.now().isoformat())

    # 关系
    user = relationship("User", back_populates="reminders")
