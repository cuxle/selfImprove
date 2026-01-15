from sqlalchemy import Column, BigInteger, Boolean, Date, Text, DateTime, ForeignKey, String
from sqlalchemy.orm import relationship
from datetime import datetime
from app.config.database import Base


class ChallengeAttempt(Base):
    """挑战执行记录模型"""

    __tablename__ = "challenge_attempts"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    challenge_id = Column(
        BigInteger, ForeignKey("response_challenges.id", ondelete="CASCADE"), nullable=False, index=True
    )

    attempt_date = Column(Date, nullable=False, index=True)  # 尝试日期
    success = Column(Boolean, nullable=False)  # 是否成功
    notes = Column(Text, nullable=True)  # 笔记
    emotion_before = Column(String(100), nullable=True)  # 尝试前情绪
    emotion_after = Column(String(100), nullable=True)  # 尝试后情绪

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    # 关系
    challenge = relationship("ResponseChallenge", back_populates="attempts")

    def __repr__(self):
        return f"<ChallengeAttempt(id={self.id}, challenge_id={self.challenge_id}, success={self.success})>"
