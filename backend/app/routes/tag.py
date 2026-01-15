from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Optional
from app.config.database import get_db
from app.models.user import User
from app.models.emotion_tag import EmotionTag
from app.models.emotion_diary import EmotionDiary
from app.schemas.tag_schema import TagCreate, TagUpdate, TagResponse, TagListResponse
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/tags", tags=["标签管理"])


@router.post("", response_model=TagResponse, status_code=status.HTTP_201_CREATED)
async def create_tag(
    tag_data: TagCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """创建新标签"""
    # 检查标签名称是否已存在
    existing_tag = db.query(EmotionTag).filter(EmotionTag.tag_name == tag_data.tag_name).first()
    if existing_tag:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="标签名称已存在"
        )

    # 创建新标签
    new_tag = EmotionTag(tag_name=tag_data.tag_name, tag_type=tag_data.tag_type)

    db.add(new_tag)
    db.commit()
    db.refresh(new_tag)

    return new_tag


@router.get("", response_model=TagListResponse)
async def get_tags(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    tag_type: Optional[str] = Query(None, description="标签类型筛选"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取标签列表"""
    query = db.query(EmotionTag)

    # 类型筛选
    if tag_type:
        query = query.filter(EmotionTag.tag_type == tag_type)

    # 总数
    total = query.count()

    # 分页
    tags = query.order_by(EmotionTag.created_at.desc()).offset(skip).limit(limit).all()

    return {"total": total, "items": tags}


@router.get("/{tag_id}", response_model=TagResponse)
async def get_tag(
    tag_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取单个标签详情"""
    tag = db.query(EmotionTag).filter(EmotionTag.id == tag_id).first()

    if not tag:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="标签不存在"
        )

    return tag


@router.put("/{tag_id}", response_model=TagResponse)
async def update_tag(
    tag_id: int,
    tag_data: TagUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """更新标签"""
    tag = db.query(EmotionTag).filter(EmotionTag.id == tag_id).first()

    if not tag:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="标签不存在"
        )

    # 检查新标签名是否已被使用
    if tag_data.tag_name and tag_data.tag_name != tag.tag_name:
        existing = (
            db.query(EmotionTag).filter(EmotionTag.tag_name == tag_data.tag_name).first()
        )
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail="标签名称已存在"
            )

    # 更新字段
    update_data = tag_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(tag, key, value)

    db.commit()
    db.refresh(tag)

    return tag


@router.delete("/{tag_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_tag(
    tag_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """删除标签"""
    tag = db.query(EmotionTag).filter(EmotionTag.id == tag_id).first()

    if not tag:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="标签不存在"
        )

    db.delete(tag)
    db.commit()

    return None


@router.get("/stats/usage", response_model=list)
async def get_tag_usage_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取标签使用统计"""
    # 获取所有标签
    all_tags = db.query(EmotionTag).all()

    stats = []
    for tag in all_tags:
        # 统计每个标签被多少篇日记使用
        usage_count = (
            db.query(func.count(EmotionDiary.id))
            .join(EmotionDiary.tags)
            .filter(EmotionTag.id == tag.id)
            .filter(EmotionDiary.user_id == current_user.id)
            .scalar()
        )

        stats.append({
            "id": tag.id,
            "tag_name": tag.tag_name,
            "tag_type": tag.tag_type,
            "usage_count": usage_count or 0,
        })

    # 按使用次数降序排序
    stats.sort(key=lambda x: x["usage_count"], reverse=True)

    return stats
