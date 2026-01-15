from sqlalchemy import Column, BigInteger, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.config.database import Base


class ResponseChallenge(Base):
    """新回应挑战模型"""

    __tablename__ = "response_challenges"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    diary_id = Column(BigInteger, ForeignKey("emotion_diaries.id", ondelete="SET NULL"), nullable=True)

    challenge_title = Column(String(200), nullable=False)  # 挑战标题
    old_response = Column(Text, nullable=False)  # 旧的自动反应
    new_response = Column(Text, nullable=False)  # 新的有意识回应

    difficulty_level = Column(Integer, nullable=False)  # 难度等级 1-5
    status = Column(String(20), nullable=False, default="planned")  # planned/in_progress/completed

    # 完成后填写
    actual_result = Column(Text, nullable=True)  # 实际执行结果
    reflection = Column(Text, nullable=True)  # 反思记录
    success_rate = Column(Integer, nullable=True)  # 成功率 0-100

    # 时间戳
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    completed_at = Column(DateTime, nullable=True)  # 完成时间

    # 关系
    user = relationship("User", back_populates="challenges")
    diary = relationship("EmotionDiary", back_populates="challenges")
    attempts = relationship("ChallengeAttempt", back_populates="challenge", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<ResponseChallenge(id={self.id}, title='{self.challenge_title}', status='{self.status}')>"
