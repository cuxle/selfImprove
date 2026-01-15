from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date


class ChallengeBase(BaseModel):
    """挑战基础Schema"""

    challenge_title: str = Field(..., min_length=1, max_length=200, description="挑战标题")
    old_response: str = Field(..., min_length=1, description="旧的自动反应")
    new_response: str = Field(..., min_length=1, description="新的有意识回应")
    difficulty_level: int = Field(..., ge=1, le=5, description="难度等级 (1-5)")


class ChallengeCreate(ChallengeBase):
    """创建挑战Schema"""

    diary_id: Optional[int] = Field(None, description="关联的日记ID")


class ChallengeUpdate(BaseModel):
    """更新挑战Schema"""

    challenge_title: Optional[str] = None
    old_response: Optional[str] = None
    new_response: Optional[str] = None
    difficulty_level: Optional[int] = Field(None, ge=1, le=5)
    status: Optional[str] = Field(None, pattern="^(planned|in_progress|completed)$")
    actual_result: Optional[str] = None
    reflection: Optional[str] = None
    success_rate: Optional[int] = Field(None, ge=0, le=100)


class AttemptCreate(BaseModel):
    """创建尝试记录Schema"""

    attempt_date: date = Field(..., description="尝试日期")
    success: bool = Field(..., description="是否成功")
    notes: Optional[str] = Field(None, description="笔记")
    emotion_before: Optional[str] = Field(None, max_length=100, description="尝试前情绪")
    emotion_after: Optional[str] = Field(None, max_length=100, description="尝试后情绪")


class AttemptResponse(AttemptCreate):
    """尝试记录响应Schema"""

    id: int
    challenge_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class ChallengeResponse(ChallengeBase):
    """挑战响应Schema"""

    id: int
    user_id: int
    diary_id: Optional[int]
    status: str
    actual_result: Optional[str]
    reflection: Optional[str]
    success_rate: Optional[int]
    created_at: datetime
    updated_at: datetime
    completed_at: Optional[datetime]
    attempts: List[AttemptResponse] = []

    class Config:
        from_attributes = True


class ChallengeListResponse(BaseModel):
    """挑战列表响应Schema"""

    total: int
    challenges: List[ChallengeResponse]
