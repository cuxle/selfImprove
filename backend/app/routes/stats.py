from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Optional
from datetime import datetime, timedelta
from app.config.database import get_db
from app.models.user import User
from app.models.emotion_diary import EmotionDiary
from app.models.response_challenge import ResponseChallenge
from app.models.challenge_attempt import ChallengeAttempt
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/stats", tags=["数据统计"])


@router.get("/emotion-trend")
async def get_emotion_trend(
    days: int = Query(30, ge=1, le=365, description="统计天数"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取情绪趋势数据（按天）"""
    # 计算起始日期
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)

    # 获取时间范围内的所有日记
    diaries = (
        db.query(EmotionDiary)
        .filter(
            EmotionDiary.user_id == current_user.id,
            EmotionDiary.created_at >= start_date,
            EmotionDiary.created_at <= end_date,
        )
        .order_by(EmotionDiary.created_at.asc())
        .all()
    )

    # 按日期分组统计平均情绪强度
    daily_data = {}
    for diary in diaries:
        date_key = diary.created_at.date().isoformat()
        if date_key not in daily_data:
            daily_data[date_key] = {"intensities": [], "count": 0}
        daily_data[date_key]["intensities"].append(diary.emotion_intensity)
        daily_data[date_key]["count"] += 1

    # 计算每天的平均强度
    trend_data = []
    for date_str, data in sorted(daily_data.items()):
        avg_intensity = sum(data["intensities"]) / len(data["intensities"])
        trend_data.append(
            {
                "date": date_str,
                "avg_intensity": round(avg_intensity, 2),
                "diary_count": data["count"],
            }
        )

    return {
        "start_date": start_date.date().isoformat(),
        "end_date": end_date.date().isoformat(),
        "data": trend_data,
    }


@router.get("/emotion-intensity-distribution")
async def get_emotion_intensity_distribution(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取情绪强度分布"""
    # 统计每个强度级别的日记数量
    distribution = (
        db.query(
            EmotionDiary.emotion_intensity, func.count(EmotionDiary.id).label("count")
        )
        .filter(EmotionDiary.user_id == current_user.id)
        .group_by(EmotionDiary.emotion_intensity)
        .order_by(EmotionDiary.emotion_intensity)
        .all()
    )

    # 确保1-10都有数据（没有的补0）
    distribution_dict = {i: 0 for i in range(1, 11)}
    for intensity, count in distribution:
        distribution_dict[intensity] = count

    result = [
        {"intensity": intensity, "count": count}
        for intensity, count in sorted(distribution_dict.items())
    ]

    # 计算总数和平均值
    total_count = sum(item["count"] for item in result)
    if total_count > 0:
        total_intensity = sum(
            item["intensity"] * item["count"] for item in result
        )
        avg_intensity = total_intensity / total_count
    else:
        avg_intensity = 0

    return {
        "distribution": result,
        "total_count": total_count,
        "avg_intensity": round(avg_intensity, 2),
    }


@router.get("/challenge-completion")
async def get_challenge_completion_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取挑战完成率统计"""
    # 获取所有挑战
    challenges = (
        db.query(ResponseChallenge)
        .filter(ResponseChallenge.user_id == current_user.id)
        .all()
    )

    # 按状态统计
    status_stats = {"planned": 0, "in_progress": 0, "completed": 0}
    for challenge in challenges:
        status_stats[challenge.status] = status_stats.get(challenge.status, 0) + 1

    # 统计所有尝试记录
    attempts = (
        db.query(ChallengeAttempt)
        .join(ResponseChallenge)
        .filter(ResponseChallenge.user_id == current_user.id)
        .all()
    )

    success_count = sum(1 for attempt in attempts if attempt.is_successful)
    total_attempts = len(attempts)
    success_rate = (
        round((success_count / total_attempts) * 100, 2) if total_attempts > 0 else 0
    )

    # 按难度统计挑战数量
    difficulty_stats = {}
    for challenge in challenges:
        difficulty_stats[challenge.difficulty_level] = (
            difficulty_stats.get(challenge.difficulty_level, 0) + 1
        )

    return {
        "total_challenges": len(challenges),
        "status_distribution": status_stats,
        "total_attempts": total_attempts,
        "successful_attempts": success_count,
        "success_rate": success_rate,
        "difficulty_distribution": difficulty_stats,
    }


@router.get("/overview")
async def get_stats_overview(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取统计概览"""
    # 日记总数
    total_diaries = (
        db.query(func.count(EmotionDiary.id))
        .filter(EmotionDiary.user_id == current_user.id)
        .scalar()
    )

    # 最近7天的日记数
    seven_days_ago = datetime.now() - timedelta(days=7)
    recent_diaries = (
        db.query(func.count(EmotionDiary.id))
        .filter(
            EmotionDiary.user_id == current_user.id,
            EmotionDiary.created_at >= seven_days_ago,
        )
        .scalar()
    )

    # 平均情绪强度
    avg_intensity = (
        db.query(func.avg(EmotionDiary.emotion_intensity))
        .filter(EmotionDiary.user_id == current_user.id)
        .scalar()
    )

    # 挑战总数
    total_challenges = (
        db.query(func.count(ResponseChallenge.id))
        .filter(ResponseChallenge.user_id == current_user.id)
        .scalar()
    )

    # 已完成的挑战数
    completed_challenges = (
        db.query(func.count(ResponseChallenge.id))
        .filter(
            ResponseChallenge.user_id == current_user.id,
            ResponseChallenge.status == "completed",
        )
        .scalar()
    )

    return {
        "total_diaries": total_diaries or 0,
        "recent_diaries": recent_diaries or 0,
        "avg_emotion_intensity": round(avg_intensity, 2) if avg_intensity else 0,
        "total_challenges": total_challenges or 0,
        "completed_challenges": completed_challenges or 0,
    }
