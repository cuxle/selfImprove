from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    """用户基础Schema"""

    username: str = Field(..., min_length=3, max_length=50, description="用户名")
    email: EmailStr = Field(..., description="邮箱地址")


class UserCreate(UserBase):
    """用户注册Schema"""

    password: str = Field(..., min_length=6, max_length=100, description="密码")


class UserLogin(BaseModel):
    """用户登录Schema"""

    account: str = Field(..., min_length=3, max_length=100, description="用户名或邮箱")
    password: str = Field(..., min_length=6, max_length=100, description="密码")


class WeChatLogin(BaseModel):
    """微信登录Schema"""
    
    code: str = Field(..., description="微信授权码（由前端微信SDK获取）")


class PhoneSendCode(BaseModel):
    """发送手机验证码Schema"""
    
    phone: str = Field(..., min_length=10, max_length=20, description="手机号（含区号，如+8613912345678）", pattern=r"^\+?[1-9]\d{1,14}$")


class PhoneLogin(BaseModel):
    """手机号验证码登录Schema"""
    
    phone: str = Field(..., min_length=10, max_length=20, description="手机号（含区号，如+8613912345678）", pattern=r"^\+?[1-9]\d{1,14}$")
    code: str = Field(..., min_length=6, max_length=6, description="验证码")


class PasswordResetRequest(BaseModel):
    """密码重置请求Schema（发送验证码）"""
    
    phone: str = Field(..., min_length=10, max_length=20, description="手机号（含区号，如+8613912345678）", pattern=r"^\+?[1-9]\d{1,14}$")


class PasswordResetConfirm(BaseModel):
    """密码重置确认Schema（验证码+新密码）"""
    
    phone: str = Field(..., min_length=10, max_length=20, description="手机号（含区号，如+8613912345678）", pattern=r"^\+?[1-9]\d{1,14}$")
    code: str = Field(..., min_length=6, max_length=6, description="验证码")
    new_password: str = Field(..., min_length=6, max_length=100, description="新密码")


class UserResponse(UserBase):
    """用户响应Schema"""

    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    """JWT令牌Schema"""

    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """JWT令牌数据Schema"""

    user_id: Optional[int] = None
    email: Optional[str] = None
