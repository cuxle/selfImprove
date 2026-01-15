from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.config.database import get_db
from app.models.user import User
from app.models.reminder import Reminder
from app.schemas.reminder_schema import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
    ReminderListResponse,
)
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/reminders", tags=["提醒管理"])


@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(
    reminder_data: ReminderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """创建新提醒"""
    # 验证reminder_type
    if reminder_data.reminder_type not in ["diary", "challenge"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="提醒类型必须是 'diary' 或 'challenge'",
        )

    # 验证frequency
    if reminder_data.frequency not in ["daily", "weekly", "custom"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="频率必须是 'daily', 'weekly' 或 'custom'",
        )

    # 如果是weekly，必须提供days_of_week
    if reminder_data.frequency == "weekly" and not reminder_data.days_of_week:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="weekly频率必须指定days_of_week",
        )

    # 创建新提醒
    new_reminder = Reminder(
        user_id=current_user.id,
        reminder_type=reminder_data.reminder_type,
        is_enabled=reminder_data.is_enabled,
        reminder_time=reminder_data.reminder_time,
        frequency=reminder_data.frequency,
        days_of_week=reminder_data.days_of_week,
        message=reminder_data.message,
    )

    db.add(new_reminder)
    db.commit()
    db.refresh(new_reminder)

    return new_reminder


@router.get("", response_model=ReminderListResponse)
async def get_reminders(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    reminder_type: Optional[str] = Query(None, description="按类型筛选"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取提醒列表"""
    query = db.query(Reminder).filter(Reminder.user_id == current_user.id)

    # 类型筛选
    if reminder_type:
        query = query.filter(Reminder.reminder_type == reminder_type)

    # 总数
    total = query.count()

    # 分页
    reminders = query.offset(skip).limit(limit).all()

    return {"total": total, "items": reminders}


@router.get("/{reminder_id}", response_model=ReminderResponse)
async def get_reminder(
    reminder_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取单个提醒详情"""
    reminder = (
        db.query(Reminder)
        .filter(Reminder.id == reminder_id, Reminder.user_id == current_user.id)
        .first()
    )

    if not reminder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="提醒不存在"
        )

    return reminder


@router.put("/{reminder_id}", response_model=ReminderResponse)
async def update_reminder(
    reminder_id: int,
    reminder_data: ReminderUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """更新提醒"""
    reminder = (
        db.query(Reminder)
        .filter(Reminder.id == reminder_id, Reminder.user_id == current_user.id)
        .first()
    )

    if not reminder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="提醒不存在"
        )

    # 更新字段
    update_data = reminder_data.model_dump(exclude_unset=True)

    # 验证frequency（如果提供）
    if "frequency" in update_data:
        if update_data["frequency"] not in ["daily", "weekly", "custom"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="频率必须是 'daily', 'weekly' 或 'custom'",
            )

    for key, value in update_data.items():
        setattr(reminder, key, value)

    db.commit()
    db.refresh(reminder)

    return reminder


@router.delete("/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_reminder(
    reminder_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """删除提醒"""
    reminder = (
        db.query(Reminder)
        .filter(Reminder.id == reminder_id, Reminder.user_id == current_user.id)
        .first()
    )

    if not reminder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="提醒不存在"
        )

    db.delete(reminder)
    db.commit()

    return None
