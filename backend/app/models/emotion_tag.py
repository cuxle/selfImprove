from sqlalchemy import Column, BigInteger, String, DateTime, Table, ForeignKey
from datetime import datetime
from app.config.database import Base


class EmotionTag(Base):
    """情绪标签模型"""

    __tablename__ = "emotion_tags"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    tag_name = Column(String(50), unique=True, nullable=False, index=True)
    tag_type = Column(String(20), nullable=False)  # emotion/pattern/trigger
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    def __repr__(self):
        return f"<EmotionTag(id={self.id}, tag_name='{self.tag_name}', type='{self.tag_type}')>"


# 日记-标签关联表（多对多）
diary_tags = Table(
    "diary_tags",
    Base.metadata,
    Column("id", BigInteger, primary_key=True, autoincrement=True),
    Column("diary_id", BigInteger, ForeignKey("emotion_diaries.id", ondelete="CASCADE"), nullable=False),
    Column("tag_id", BigInteger, ForeignKey("emotion_tags.id", ondelete="CASCADE"), nullable=False),
    Column("created_at", DateTime, default=datetime.utcnow, nullable=False),
)
