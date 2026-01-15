from sqlalchemy import Column, BigInteger, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.config.database import Base
from app.models.emotion_tag import diary_tags


class EmotionDiary(Base):
    """情绪遗产日记模型"""

    __tablename__ = "emotion_diaries"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)

    # 核心字段
    trigger_event = Column(Text, nullable=False)  # 触发事件
    immediate_emotion = Column(String(100), nullable=False)  # 即时情绪
    emotion_intensity = Column(Integer, nullable=False)  # 情绪强度 1-10

    # 可选字段
    physical_reaction = Column(Text, nullable=True)  # 身体反应
    auto_thought = Column(Text, nullable=True)  # 自动化思维
    childhood_memory = Column(Text, nullable=True)  # 童年记忆联结
    pattern_recognition = Column(Text, nullable=True)  # 模式识别

    # 时间戳
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 关系
    user = relationship("User", back_populates="diaries")
    tags = relationship("EmotionTag", secondary=diary_tags, backref="diaries")
    challenges = relationship("ResponseChallenge", back_populates="diary", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<EmotionDiary(id={self.id}, user_id={self.user_id}, emotion='{self.immediate_emotion}')>"
