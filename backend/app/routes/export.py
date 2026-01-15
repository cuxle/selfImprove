from fastapi import APIRouter, Depends, Query, Response
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime, timedelta
from io import StringIO
import csv
import json
from app.config.database import get_db
from app.models.user import User
from app.models.emotion_diary import EmotionDiary
from app.models.response_challenge import ResponseChallenge
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/export", tags=["数据导出"])


@router.get("/diaries/json")
async def export_diaries_json(
    start_date: Optional[str] = Query(None, description="开始日期 YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="结束日期 YYYY-MM-DD"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """导出日记为JSON格式"""
    query = db.query(EmotionDiary).filter(EmotionDiary.user_id == current_user.id)

    # 日期筛选
    if start_date:
        start = datetime.fromisoformat(start_date)
        query = query.filter(EmotionDiary.created_at >= start)
    if end_date:
        end = datetime.fromisoformat(end_date)
        query = query.filter(EmotionDiary.created_at <= end)

    diaries = query.order_by(EmotionDiary.created_at.desc()).all()

    # 转换为JSON格式
    data = []
    for diary in diaries:
        data.append({
            "id": diary.id,
            "trigger_event": diary.trigger_event,
            "immediate_emotion": diary.immediate_emotion,
            "emotion_intensity": diary.emotion_intensity,
            "physical_reaction": diary.physical_reaction,
            "auto_thought": diary.auto_thought,
            "childhood_memory": diary.childhood_memory,
            "pattern_recognition": diary.pattern_recognition,
            "tags": [{"id": tag.id, "name": tag.tag_name, "type": tag.tag_type} for tag in diary.tags],
            "created_at": diary.created_at.isoformat() if hasattr(diary.created_at, 'isoformat') else str(diary.created_at),
        })

    json_str = json.dumps(data, ensure_ascii=False, indent=2)

    return Response(
        content=json_str,
        media_type="application/json",
        headers={
            "Content-Disposition": f"attachment; filename=emotion_diaries_{datetime.now().strftime('%Y%m%d')}.json"
        },
    )


@router.get("/diaries/csv")
async def export_diaries_csv(
    start_date: Optional[str] = Query(None, description="开始日期 YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="结束日期 YYYY-MM-DD"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """导出日记为CSV格式"""
    query = db.query(EmotionDiary).filter(EmotionDiary.user_id == current_user.id)

    # 日期筛选
    if start_date:
        start = datetime.fromisoformat(start_date)
        query = query.filter(EmotionDiary.created_at >= start)
    if end_date:
        end = datetime.fromisoformat(end_date)
        query = query.filter(EmotionDiary.created_at <= end)

    diaries = query.order_by(EmotionDiary.created_at.desc()).all()

    # 生成CSV
    output = StringIO()
    writer = csv.writer(output)

    # 写入表头
    writer.writerow([
        "ID", "创建时间", "触发事件", "即时情绪", "情绪强度",
        "身体反应", "自动化思维", "童年记忆", "模式识别", "标签"
    ])

    # 写入数据
    for diary in diaries:
        tags_str = ", ".join([tag.tag_name for tag in diary.tags])
        writer.writerow([
            diary.id,
            diary.created_at.isoformat() if hasattr(diary.created_at, 'isoformat') else str(diary.created_at),
            diary.trigger_event,
            diary.immediate_emotion,
            diary.emotion_intensity,
            diary.physical_reaction or "",
            diary.auto_thought or "",
            diary.childhood_memory or "",
            diary.pattern_recognition or "",
            tags_str,
        ])

    csv_content = output.getvalue()
    output.close()

    # 添加BOM以支持Excel正确显示中文
    csv_content = '\ufeff' + csv_content

    return Response(
        content=csv_content.encode('utf-8'),
        media_type="text/csv",
        headers={
            "Content-Disposition": f"attachment; filename=emotion_diaries_{datetime.now().strftime('%Y%m%d')}.csv"
        },
    )


@router.get("/report/weekly")
async def generate_weekly_report(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """生成周报告（最近7天）"""
    end_date = datetime.now()
    start_date = end_date - timedelta(days=7)

    # 获取日记
    diaries = (
        db.query(EmotionDiary)
        .filter(
            EmotionDiary.user_id == current_user.id,
            EmotionDiary.created_at >= start_date,
            EmotionDiary.created_at <= end_date,
        )
        .all()
    )

    # 获取挑战
    challenges = (
        db.query(ResponseChallenge)
        .filter(
            ResponseChallenge.user_id == current_user.id,
            ResponseChallenge.created_at >= start_date,
        )
        .all()
    )

    # 统计数据
    total_diaries = len(diaries)
    avg_intensity = (
        sum(d.emotion_intensity for d in diaries) / total_diaries
        if total_diaries > 0
        else 0
    )

    # 最常见情绪
    emotions = {}
    for diary in diaries:
        emotions[diary.immediate_emotion] = emotions.get(diary.immediate_emotion, 0) + 1
    top_emotions = sorted(emotions.items(), key=lambda x: x[1], reverse=True)[:3]

    # 标签统计
    tag_counts = {}
    for diary in diaries:
        for tag in diary.tags:
            tag_counts[tag.tag_name] = tag_counts.get(tag.tag_name, 0) + 1
    top_tags = sorted(tag_counts.items(), key=lambda x: x[1], reverse=True)[:5]

    report = {
        "period": "weekly",
        "start_date": start_date.date().isoformat(),
        "end_date": end_date.date().isoformat(),
        "summary": {
            "total_diaries": total_diaries,
            "avg_emotion_intensity": round(avg_intensity, 2),
            "total_challenges": len(challenges),
            "completed_challenges": len([c for c in challenges if c.status == "completed"]),
        },
        "top_emotions": [{"emotion": e[0], "count": e[1]} for e in top_emotions],
        "top_tags": [{"tag": t[0], "count": t[1]} for t in top_tags],
        "insights": _generate_insights(diaries, challenges),
    }

    return report


@router.get("/report/monthly")
async def generate_monthly_report(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """生成月报告（最近30天）"""
    end_date = datetime.now()
    start_date = end_date - timedelta(days=30)

    # 获取日记
    diaries = (
        db.query(EmotionDiary)
        .filter(
            EmotionDiary.user_id == current_user.id,
            EmotionDiary.created_at >= start_date,
            EmotionDiary.created_at <= end_date,
        )
        .all()
    )

    # 获取挑战
    challenges = (
        db.query(ResponseChallenge)
        .filter(
            ResponseChallenge.user_id == current_user.id,
            ResponseChallenge.created_at >= start_date,
        )
        .all()
    )

    # 统计数据
    total_diaries = len(diaries)
    avg_intensity = (
        sum(d.emotion_intensity for d in diaries) / total_diaries
        if total_diaries > 0
        else 0
    )

    # 最常见情绪
    emotions = {}
    for diary in diaries:
        emotions[diary.immediate_emotion] = emotions.get(diary.immediate_emotion, 0) + 1
    top_emotions = sorted(emotions.items(), key=lambda x: x[1], reverse=True)[:5]

    # 标签统计
    tag_counts = {}
    for diary in diaries:
        for tag in diary.tags:
            tag_counts[tag.tag_name] = tag_counts.get(tag.tag_name, 0) + 1
    top_tags = sorted(tag_counts.items(), key=lambda x: x[1], reverse=True)[:10]

    # 按周统计趋势
    weekly_trend = []
    for week in range(4):
        week_start = start_date + timedelta(days=week * 7)
        week_end = week_start + timedelta(days=7)
        week_diaries = [
            d for d in diaries
            if week_start <= d.created_at < week_end
        ]
        week_avg = (
            sum(d.emotion_intensity for d in week_diaries) / len(week_diaries)
            if week_diaries
            else 0
        )
        weekly_trend.append({
            "week": week + 1,
            "diary_count": len(week_diaries),
            "avg_intensity": round(week_avg, 2),
        })

    report = {
        "period": "monthly",
        "start_date": start_date.date().isoformat(),
        "end_date": end_date.date().isoformat(),
        "summary": {
            "total_diaries": total_diaries,
            "avg_emotion_intensity": round(avg_intensity, 2),
            "total_challenges": len(challenges),
            "completed_challenges": len([c for c in challenges if c.status == "completed"]),
        },
        "top_emotions": [{"emotion": e[0], "count": e[1]} for e in top_emotions],
        "top_tags": [{"tag": t[0], "count": t[1]} for t in top_tags],
        "weekly_trend": weekly_trend,
        "insights": _generate_insights(diaries, challenges),
    }

    return report


def _generate_insights(diaries, challenges):
    """生成洞察建议"""
    insights = []

    if len(diaries) == 0:
        insights.append("本期还没有日记记录，建议开始记录情绪日记")
        return insights

    # 平均强度分析
    avg_intensity = sum(d.emotion_intensity for d in diaries) / len(diaries)
    if avg_intensity > 7:
        insights.append("本期情绪强度偏高，建议增加放松和自我关怀活动")
    elif avg_intensity < 4:
        insights.append("本期情绪相对平稳，保持良好状态")

    # 记录频率分析
    if len(diaries) < 3:
        insights.append("本期记录次数较少，建议保持规律的情绪记录习惯")
    elif len(diaries) > 20:
        insights.append("本期记录非常积极，继续保持这个好习惯")

    # 挑战完成情况
    completed = len([c for c in challenges if c.status == "completed"])
    if len(challenges) > 0:
        completion_rate = (completed / len(challenges)) * 100
        if completion_rate > 60:
            insights.append(f"挑战完成率{completion_rate:.1f}%，继续加油！")
        else:
            insights.append("可以尝试设置更容易实现的小目标，逐步建立信心")

    return insights
