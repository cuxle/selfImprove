from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import time


class ReminderBase(BaseModel):
    reminder_type: str = Field(..., description="提醒类型: diary 或 challenge")
    is_enabled: bool = Field(default=True, description="是否启用")
    reminder_time: str = Field(..., pattern=r"^([0-1][0-9]|2[0-3]):[0-5][0-9]$", description="提醒时间 HH:MM")
    frequency: str = Field(default="daily", description="频率: daily, weekly, custom")
    days_of_week: Optional[List[int]] = Field(None, description="星期几 0-6, 0=周一")
    message: Optional[str] = Field(None, max_length=200, description="自定义提醒消息")


class ReminderCreate(ReminderBase):
    pass


class ReminderUpdate(BaseModel):
    is_enabled: Optional[bool] = None
    reminder_time: Optional[str] = Field(None, pattern=r"^([0-1][0-9]|2[0-3]):[0-5][0-9]$")
    frequency: Optional[str] = None
    days_of_week: Optional[List[int]] = None
    message: Optional[str] = Field(None, max_length=200)


class ReminderResponse(ReminderBase):
    id: int
    user_id: int
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class ReminderListResponse(BaseModel):
    total: int
    items: List[ReminderResponse]
