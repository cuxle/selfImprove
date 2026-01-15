from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime
from app.config.database import get_db
from app.models.user import User
from app.models.response_challenge import ResponseChallenge
from app.models.challenge_attempt import ChallengeAttempt
from app.schemas.challenge_schema import (
    ChallengeCreate,
    ChallengeUpdate,
    ChallengeResponse,
    ChallengeListResponse,
    AttemptCreate,
    AttemptResponse,
)
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/challenges", tags=["新回应挑战"])


@router.post("", response_model=ChallengeResponse, status_code=status.HTTP_201_CREATED)
async def create_challenge(
    challenge_data: ChallengeCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """创建新回应挑战"""

    # 创建新挑战
    new_challenge = ResponseChallenge(
        user_id=current_user.id,
        diary_id=challenge_data.diary_id,
        challenge_title=challenge_data.challenge_title,
        old_response=challenge_data.old_response,
        new_response=challenge_data.new_response,
        difficulty_level=challenge_data.difficulty_level,
        status="planned",
    )

    db.add(new_challenge)
    db.commit()
    db.refresh(new_challenge)

    return new_challenge


@router.get("", response_model=ChallengeListResponse)
async def get_challenges(
    skip: int = Query(0, ge=0, description="跳过记录数"),
    limit: int = Query(10, ge=1, le=100, description="返回记录数"),
    status_filter: Optional[str] = Query(None, description="按状态筛选"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取当前用户的挑战列表"""

    query = db.query(ResponseChallenge).filter(ResponseChallenge.user_id == current_user.id)

    # 应用筛选条件
    if status_filter:
        query = query.filter(ResponseChallenge.status == status_filter)

    # 获取总数
    total = query.count()

    # 分页查询
    challenges = query.order_by(ResponseChallenge.created_at.desc()).offset(skip).limit(limit).all()

    return {"total": total, "challenges": challenges}


@router.get("/{challenge_id}", response_model=ChallengeResponse)
async def get_challenge(
    challenge_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """获取单个挑战详情"""

    challenge = (
        db.query(ResponseChallenge)
        .filter(ResponseChallenge.id == challenge_id, ResponseChallenge.user_id == current_user.id)
        .first()
    )

    if not challenge:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="挑战不存在")

    return challenge


@router.put("/{challenge_id}", response_model=ChallengeResponse)
async def update_challenge(
    challenge_id: int,
    challenge_data: ChallengeUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """更新挑战"""

    challenge = (
        db.query(ResponseChallenge)
        .filter(ResponseChallenge.id == challenge_id, ResponseChallenge.user_id == current_user.id)
        .first()
    )

    if not challenge:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="挑战不存在")

    # 更新字段
    update_data = challenge_data.model_dump(exclude_unset=True)

    # 如果状态变为completed，设置完成时间
    if update_data.get("status") == "completed" and challenge.status != "completed":
        update_data["completed_at"] = datetime.utcnow()

    for key, value in update_data.items():
        setattr(challenge, key, value)

    db.commit()
    db.refresh(challenge)

    return challenge


@router.delete("/{challenge_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_challenge(
    challenge_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """删除挑战"""

    challenge = (
        db.query(ResponseChallenge)
        .filter(ResponseChallenge.id == challenge_id, ResponseChallenge.user_id == current_user.id)
        .first()
    )

    if not challenge:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="挑战不存在")

    db.delete(challenge)
    db.commit()

    return None


@router.post("/{challenge_id}/attempts", response_model=AttemptResponse, status_code=status.HTTP_201_CREATED)
async def create_attempt(
    challenge_id: int,
    attempt_data: AttemptCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """为挑战添加尝试记录"""

    # 检查挑战是否存在且属于当前用户
    challenge = (
        db.query(ResponseChallenge)
        .filter(ResponseChallenge.id == challenge_id, ResponseChallenge.user_id == current_user.id)
        .first()
    )

    if not challenge:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="挑战不存在")

    # 创建尝试记录
    new_attempt = ChallengeAttempt(
        challenge_id=challenge_id,
        attempt_date=attempt_data.attempt_date,
        success=attempt_data.success,
        notes=attempt_data.notes,
        emotion_before=attempt_data.emotion_before,
        emotion_after=attempt_data.emotion_after,
    )

    db.add(new_attempt)
    db.commit()
    db.refresh(new_attempt)

    return new_attempt
