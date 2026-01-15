"""
数据备份和恢复路由
"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Dict, Any
import json

from ..config.database import get_db
from ..middleware.auth_middleware import get_current_user
from ..models.user import User
from ..models.emotion_diary import EmotionDiary
from ..models.response_challenge import ResponseChallenge
from ..models.challenge_attempt import ChallengeAttempt
from ..models.emotion_tag import EmotionTag
from ..models.reminder import Reminder

router = APIRouter(prefix="/api/v1/backup", tags=["backup"])


@router.get("/full")
async def create_full_backup(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """创建完整数据备份（JSON格式）"""
    try:
        # 获取所有日记及其标签
        diaries = db.query(EmotionDiary).filter(EmotionDiary.user_id == current_user.id).all()
        diaries_data = []
        for diary in diaries:
            diary_dict = {
                "id": diary.id,
                "emotional_trigger": diary.emotional_trigger,
                "emotional_reaction": diary.emotional_reaction,
                "physical_sensations": diary.physical_sensations,
                "automatic_thoughts": diary.automatic_thoughts,
                "behavior_urges": diary.behavior_urges,
                "actual_behavior": diary.actual_behavior,
                "emotional_intensity": diary.emotional_intensity,
                "reflection": diary.reflection,
                "created_at": diary.created_at,
                "updated_at": diary.updated_at,
                "tags": [{"id": tag.id, "tag_name": tag.tag_name, "tag_type": tag.tag_type} for tag in diary.tags]
            }
            diaries_data.append(diary_dict)

        # 获取所有挑战及其尝试记录
        challenges = db.query(ResponseChallenge).filter(ResponseChallenge.user_id == current_user.id).all()
        challenges_data = []
        for challenge in challenges:
            challenge_dict = {
                "id": challenge.id,
                "trigger_situation": challenge.trigger_situation,
                "old_response": challenge.old_response,
                "new_response": challenge.new_response,
                "success_criteria": challenge.success_criteria,
                "start_date": challenge.start_date,
                "end_date": challenge.end_date,
                "status": challenge.status,
                "created_at": challenge.created_at,
                "updated_at": challenge.updated_at,
                "attempts": [
                    {
                        "id": attempt.id,
                        "attempt_date": attempt.attempt_date,
                        "success_level": attempt.success_level,
                        "notes": attempt.notes,
                        "created_at": attempt.created_at,
                    }
                    for attempt in challenge.attempts
                ]
            }
            challenges_data.append(challenge_dict)

        # 获取所有标签
        tags = db.query(EmotionTag).filter(EmotionTag.user_id == current_user.id).all()
        tags_data = [
            {
                "id": tag.id,
                "tag_name": tag.tag_name,
                "tag_type": tag.tag_type,
                "description": tag.description,
                "created_at": tag.created_at,
            }
            for tag in tags
        ]

        # 获取所有提醒
        reminders = db.query(Reminder).filter(Reminder.user_id == current_user.id).all()
        reminders_data = [
            {
                "id": reminder.id,
                "reminder_type": reminder.reminder_type,
                "is_enabled": reminder.is_enabled,
                "reminder_time": reminder.reminder_time,
                "frequency": reminder.frequency,
                "days_of_week": reminder.days_of_week,
                "message": reminder.message,
                "created_at": reminder.created_at,
                "updated_at": reminder.updated_at,
            }
            for reminder in reminders
        ]

        # 构建完整备份数据
        backup_data = {
            "backup_version": "1.0",
            "backup_date": datetime.now().isoformat(),
            "user": {
                "id": current_user.id,
                "username": current_user.username,
                "email": current_user.email,
            },
            "diaries": diaries_data,
            "challenges": challenges_data,
            "tags": tags_data,
            "reminders": reminders_data,
            "statistics": {
                "total_diaries": len(diaries_data),
                "total_challenges": len(challenges_data),
                "total_tags": len(tags_data),
                "total_reminders": len(reminders_data),
            }
        }

        return backup_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"创建备份失败: {str(e)}")


@router.post("/restore")
async def restore_from_backup(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """从备份文件恢复数据"""
    try:
        # 读取上传的文件
        content = await file.read()
        backup_data = json.loads(content.decode('utf-8'))

        # 验证备份数据格式
        if "backup_version" not in backup_data:
            raise HTTPException(status_code=400, detail="无效的备份文件格式")

        # 统计信息
        restored_counts = {
            "diaries": 0,
            "challenges": 0,
            "tags": 0,
            "reminders": 0,
        }

        # 恢复标签（先恢复，因为日记依赖标签）
        tag_id_mapping = {}  # 旧ID -> 新ID的映射
        if "tags" in backup_data:
            for tag_data in backup_data["tags"]:
                # 检查是否已存在同名标签
                existing_tag = db.query(EmotionTag).filter(
                    EmotionTag.user_id == current_user.id,
                    EmotionTag.tag_name == tag_data["tag_name"],
                    EmotionTag.tag_type == tag_data["tag_type"],
                ).first()

                if existing_tag:
                    tag_id_mapping[tag_data["id"]] = existing_tag.id
                else:
                    new_tag = EmotionTag(
                        user_id=current_user.id,
                        tag_name=tag_data["tag_name"],
                        tag_type=tag_data["tag_type"],
                        description=tag_data.get("description"),
                    )
                    db.add(new_tag)
                    db.flush()
                    tag_id_mapping[tag_data["id"]] = new_tag.id
                    restored_counts["tags"] += 1

        # 恢复日记
        if "diaries" in backup_data:
            for diary_data in backup_data["diaries"]:
                new_diary = EmotionDiary(
                    user_id=current_user.id,
                    emotional_trigger=diary_data["emotional_trigger"],
                    emotional_reaction=diary_data["emotional_reaction"],
                    physical_sensations=diary_data.get("physical_sensations"),
                    automatic_thoughts=diary_data.get("automatic_thoughts"),
                    behavior_urges=diary_data.get("behavior_urges"),
                    actual_behavior=diary_data.get("actual_behavior"),
                    emotional_intensity=diary_data["emotional_intensity"],
                    reflection=diary_data.get("reflection"),
                )
                db.add(new_diary)
                db.flush()

                # 关联标签
                if "tags" in diary_data:
                    for tag_data in diary_data["tags"]:
                        old_tag_id = tag_data["id"]
                        if old_tag_id in tag_id_mapping:
                            new_tag_id = tag_id_mapping[old_tag_id]
                            tag = db.query(EmotionTag).filter(EmotionTag.id == new_tag_id).first()
                            if tag:
                                new_diary.tags.append(tag)

                restored_counts["diaries"] += 1

        # 恢复挑战
        if "challenges" in backup_data:
            for challenge_data in backup_data["challenges"]:
                new_challenge = ResponseChallenge(
                    user_id=current_user.id,
                    trigger_situation=challenge_data["trigger_situation"],
                    old_response=challenge_data["old_response"],
                    new_response=challenge_data["new_response"],
                    success_criteria=challenge_data.get("success_criteria"),
                    start_date=challenge_data["start_date"],
                    end_date=challenge_data.get("end_date"),
                    status=challenge_data.get("status", "active"),
                )
                db.add(new_challenge)
                db.flush()

                # 恢复尝试记录
                if "attempts" in challenge_data:
                    for attempt_data in challenge_data["attempts"]:
                        new_attempt = ChallengeAttempt(
                            challenge_id=new_challenge.id,
                            attempt_date=attempt_data["attempt_date"],
                            success_level=attempt_data["success_level"],
                            notes=attempt_data.get("notes"),
                        )
                        db.add(new_attempt)

                restored_counts["challenges"] += 1

        # 恢复提醒
        if "reminders" in backup_data:
            for reminder_data in backup_data["reminders"]:
                new_reminder = Reminder(
                    user_id=current_user.id,
                    reminder_type=reminder_data["reminder_type"],
                    is_enabled=reminder_data.get("is_enabled", True),
                    reminder_time=reminder_data["reminder_time"],
                    frequency=reminder_data.get("frequency", "daily"),
                    days_of_week=reminder_data.get("days_of_week"),
                    message=reminder_data.get("message"),
                )
                db.add(new_reminder)
                restored_counts["reminders"] += 1

        # 提交所有更改
        db.commit()

        return {
            "message": "数据恢复成功",
            "restored": restored_counts,
            "backup_date": backup_data.get("backup_date"),
        }

    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="无效的JSON文件")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"恢复数据失败: {str(e)}")


@router.get("/info")
async def get_backup_info(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取当前数据统计信息"""
    try:
        diaries_count = db.query(EmotionDiary).filter(EmotionDiary.user_id == current_user.id).count()
        challenges_count = db.query(ResponseChallenge).filter(ResponseChallenge.user_id == current_user.id).count()
        tags_count = db.query(EmotionTag).filter(EmotionTag.user_id == current_user.id).count()
        reminders_count = db.query(Reminder).filter(Reminder.user_id == current_user.id).count()

        return {
            "total_diaries": diaries_count,
            "total_challenges": challenges_count,
            "total_tags": tags_count,
            "total_reminders": reminders_count,
            "username": current_user.username,
            "email": current_user.email,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取备份信息失败: {str(e)}")
