from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


class TagBase(BaseModel):
    """标签基础模型"""

    tag_name: str = Field(..., min_length=1, max_length=50, description="标签名称")
    tag_type: str = Field(..., description="标签类型: emotion/pattern/trigger")


class TagCreate(TagBase):
    """创建标签请求"""

    pass


class TagUpdate(BaseModel):
    """更新标签请求"""

    tag_name: Optional[str] = Field(None, min_length=1, max_length=50)
    tag_type: Optional[str] = None


class TagResponse(TagBase):
    """标签响应"""

    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class TagListResponse(BaseModel):
    """标签列表响应"""

    total: int
    items: list[TagResponse]
