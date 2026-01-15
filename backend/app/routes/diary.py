from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime
from app.config.database import get_db
from app.models.user import User
from app.models.emotion_diary import EmotionDiary
from app.models.emotion_tag import EmotionTag
from app.schemas.diary_schema import DiaryCreate, DiaryUpdate, DiaryResponse, DiaryListResponse
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/diaries", tags=["情绪日记"])


@router.post("", response_model=DiaryResponse, status_code=status.HTTP_201_CREATED)
async def create_diary(
    diary_data: DiaryCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """创建情绪遗产日记"""

    # 创建新日记
    new_diary = EmotionDiary(
        user_id=current_user.id,
        trigger_event=diary_data.trigger_event,
        immediate_emotion=diary_data.immediate_emotion,
        emotion_intensity=diary_data.emotion_intensity,
        physical_reaction=diary_data.physical_reaction,
        auto_thought=diary_data.auto_thought,
        childhood_memory=diary_data.childhood_memory,
        pattern_recognition=diary_data.pattern_recognition,
    )

    # 添加标签
    if diary_data.tag_ids:
        tags = db.query(EmotionTag).filter(EmotionTag.id.in_(diary_data.tag_ids)).all()
        new_diary.tags = tags

    db.add(new_diary)
    db.commit()
    db.refresh(new_diary)

    return new_diary


@router.get("", response_model=DiaryListResponse)
async def get_diaries(
    skip: int = Query(0, ge=0, description="跳过记录数"),
    limit: int = Query(10, ge=1, le=100, description="返回记录数"),
    emotion: Optional[str] = Query(None, description="按情绪筛选"),
    tag_id: Optional[int] = Query(None, description="按标签ID筛选"),
    start_date: Optional[datetime] = Query(None, description="开始日期"),
    end_date: Optional[datetime] = Query(None, description="结束日期"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取当前用户的日记列表"""

    query = db.query(EmotionDiary).filter(EmotionDiary.user_id == current_user.id)

    # 应用筛选条件
    if emotion:
        query = query.filter(EmotionDiary.immediate_emotion.contains(emotion))

    if tag_id:
        # 按标签筛选：只返回包含该标签的日记
        query = query.filter(EmotionDiary.tags.any(EmotionTag.id == tag_id))

    if start_date:
        query = query.filter(EmotionDiary.created_at >= start_date)

    if end_date:
        query = query.filter(EmotionDiary.created_at <= end_date)

    # 获取总数
    total = query.count()

    # 分页查询
    diaries = query.order_by(EmotionDiary.created_at.desc()).offset(skip).limit(limit).all()

    return {"total": total, "diaries": diaries}


@router.get("/{diary_id}", response_model=DiaryResponse)
async def get_diary(
    diary_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """获取单个日记详情"""

    diary = db.query(EmotionDiary).filter(EmotionDiary.id == diary_id, EmotionDiary.user_id == current_user.id).first()

    if not diary:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="日记不存在")

    return diary


@router.put("/{diary_id}", response_model=DiaryResponse)
async def update_diary(
    diary_id: int,
    diary_data: DiaryUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """更新日记"""

    diary = db.query(EmotionDiary).filter(EmotionDiary.id == diary_id, EmotionDiary.user_id == current_user.id).first()

    if not diary:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="日记不存在")

    # 更新字段
    update_data = diary_data.model_dump(exclude_unset=True)

    # 处理标签
    if "tag_ids" in update_data:
        tag_ids = update_data.pop("tag_ids")
        tags = db.query(EmotionTag).filter(EmotionTag.id.in_(tag_ids)).all()
        diary.tags = tags

    for key, value in update_data.items():
        setattr(diary, key, value)

    db.commit()
    db.refresh(diary)

    return diary


@router.delete("/{diary_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_diary(
    diary_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """删除日记"""

    diary = db.query(EmotionDiary).filter(EmotionDiary.id == diary_id, EmotionDiary.user_id == current_user.id).first()

    if not diary:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="日记不存在")

    db.delete(diary)
    db.commit()

    return None
