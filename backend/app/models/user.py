from sqlalchemy import Column, BigInteger, String, Boolean, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.config.database import Base


class User(Base):
    """用户模型"""

    __tablename__ = "users"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=True, index=True)  # 微信登录时可能为空
    password_hash = Column(String(255), nullable=True)  # 微信登录时可能为空
    
    # 微信登录相关字段
    wechat_openid = Column(String(100), unique=True, nullable=True, index=True)  # 微信openid
    wechat_unionid = Column(String(100), unique=True, nullable=True, index=True)  # 微信unionid
    avatar_url = Column(String(500), nullable=True)  # 用户头像URL
    nickname = Column(String(100), nullable=True)  # 微信昵称
    
    # 手机号登录相关字段
    phone = Column(String(20), unique=True, nullable=True, index=True)  # 手机号
    
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

    # 关系
    diaries = relationship("EmotionDiary", back_populates="user", cascade="all, delete-orphan")
    challenges = relationship("ResponseChallenge", back_populates="user", cascade="all, delete-orphan")
    reminders = relationship("Reminder", back_populates="user", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User(id={self.id}, username='{self.username}', email='{self.email}')>"
