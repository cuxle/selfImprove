from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class DiaryBase(BaseModel):
    """日记基础Schema"""

    trigger_event: str = Field(..., min_length=1, description="触发事件描述")
    immediate_emotion: str = Field(..., min_length=1, max_length=100, description="即时情绪")
    emotion_intensity: int = Field(..., ge=1, le=10, description="情绪强度 (1-10)")
    physical_reaction: Optional[str] = Field(None, description="身体反应")
    auto_thought: Optional[str] = Field(None, description="自动化思维")
    childhood_memory: Optional[str] = Field(None, description="童年记忆联结")
    pattern_recognition: Optional[str] = Field(None, description="模式识别")


class DiaryCreate(DiaryBase):
    """创建日记Schema"""

    tag_ids: Optional[List[int]] = Field(default=[], description="标签ID列表")


class DiaryUpdate(BaseModel):
    """更新日记Schema"""

    trigger_event: Optional[str] = None
    immediate_emotion: Optional[str] = None
    emotion_intensity: Optional[int] = Field(None, ge=1, le=10)
    physical_reaction: Optional[str] = None
    auto_thought: Optional[str] = None
    childhood_memory: Optional[str] = None
    pattern_recognition: Optional[str] = None
    tag_ids: Optional[List[int]] = None


class TagResponse(BaseModel):
    """标签响应Schema"""

    id: int
    tag_name: str
    tag_type: str

    class Config:
        from_attributes = True


class DiaryResponse(DiaryBase):
    """日记响应Schema"""

    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    tags: List[TagResponse] = []

    class Config:
        from_attributes = True


class DiaryListResponse(BaseModel):
    """日记列表响应Schema"""

    total: int
    diaries: List[DiaryResponse]
