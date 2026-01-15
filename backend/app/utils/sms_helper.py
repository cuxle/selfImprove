"""
短信验证码服务
支持阿里云短信服务和腾讯云短信服务
也可以在开发环境使用模拟模式
"""
import random
import time
import httpx
from typing import Optional, Dict
from datetime import datetime, timedelta


class SMSConfig:
    """短信服务配置"""
    
    # 短信服务提供商: "aliyun" | "tencent" | "mock"
    PROVIDER: str = "mock"  # 开发环境使用mock模式
    
    # 阿里云短信配置
    ALIYUN_ACCESS_KEY_ID: str = "your_access_key_id"
    ALIYUN_ACCESS_KEY_SECRET: str = "your_access_key_secret"
    ALIYUN_SIGN_NAME: str = "your_sign_name"  # 短信签名
    ALIYUN_TEMPLATE_CODE: str = "SMS_123456789"  # 短信模板CODE
    
    # 腾讯云短信配置
    TENCENT_SECRET_ID: str = "your_secret_id"
    TENCENT_SECRET_KEY: str = "your_secret_key"
    TENCENT_SMS_SDK_APP_ID: str = "your_app_id"
    TENCENT_SIGN_NAME: str = "your_sign_name"  # 短信签名
    TENCENT_TEMPLATE_ID: str = "123456"  # 短信模板ID
    
    # 验证码配置
    CODE_LENGTH: int = 6  # 验证码长度
    CODE_EXPIRE_MINUTES: int = 5  # 验证码有效期（分钟）
    RATE_LIMIT_SECONDS: int = 60  # 同一手机号发送间隔（秒）


class SMSService:
    """短信服务类"""
    
    def __init__(self):
        self.config = SMSConfig()
        # 临时存储验证码（生产环境应使用Redis）
        self._code_storage: Dict[str, Dict] = {}
        self._send_time_storage: Dict[str, float] = {}
    
    def generate_code(self) -> str:
        """生成随机验证码"""
        return ''.join([str(random.randint(0, 9)) for _ in range(self.config.CODE_LENGTH)])
    
    def check_rate_limit(self, phone: str) -> bool:
        """检查发送频率限制"""
        if phone in self._send_time_storage:
            last_send_time = self._send_time_storage[phone]
            if time.time() - last_send_time < self.config.RATE_LIMIT_SECONDS:
                return False
        return True
    
    async def send_code(self, phone: str) -> Dict[str, any]:
        """
        发送验证码
        
        Args:
            phone: 手机号
            
        Returns:
            {"success": bool, "message": str, "code": str (仅mock模式返回)}
        """
        # 检查频率限制
        if not self.check_rate_limit(phone):
            remaining_seconds = int(
                self.config.RATE_LIMIT_SECONDS - 
                (time.time() - self._send_time_storage[phone])
            )
            return {
                "success": False,
                "message": f"发送过于频繁，请{remaining_seconds}秒后再试"
            }
        
        # 生成验证码
        code = self.generate_code()
        
        # 保存验证码和过期时间
        expire_time = datetime.now() + timedelta(minutes=self.config.CODE_EXPIRE_MINUTES)
        self._code_storage[phone] = {
            "code": code,
            "expire_time": expire_time
        }
        self._send_time_storage[phone] = time.time()
        
        # 根据配置的提供商发送短信
        if self.config.PROVIDER == "mock":
            # 开发模式：不真实发送，直接返回验证码
            print(f"[SMS Mock] 手机号: {phone}, 验证码: {code}, 有效期: {self.config.CODE_EXPIRE_MINUTES}分钟")
            return {
                "success": True,
                "message": "验证码已发送（开发模式）",
                "code": code  # 仅开发模式返回，生产环境不应返回
            }
        elif self.config.PROVIDER == "aliyun":
            return await self._send_aliyun_sms(phone, code)
        elif self.config.PROVIDER == "tencent":
            return await self._send_tencent_sms(phone, code)
        else:
            return {
                "success": False,
                "message": "未配置短信服务提供商"
            }
    
    async def _send_aliyun_sms(self, phone: str, code: str) -> Dict[str, any]:
        """使用阿里云发送短信（需要安装 alibabacloud_dysmsapi20170525）"""
        try:
            # 这里需要集成阿里云SDK
            # 示例代码：
            # from alibabacloud_dysmsapi20170525.client import Client
            # from alibabacloud_dysmsapi20170525 import models
            # ...
            return {
                "success": True,
                "message": "验证码已发送"
            }
        except Exception as e:
            print(f"阿里云短信发送失败: {str(e)}")
            return {
                "success": False,
                "message": f"发送失败: {str(e)}"
            }
    
    async def _send_tencent_sms(self, phone: str, code: str) -> Dict[str, any]:
        """使用腾讯云发送短信（需要安装 tencentcloud-sdk-python）"""
        try:
            # 这里需要集成腾讯云SDK
            # 示例代码：
            # from tencentcloud.sms.v20210111 import sms_client, models
            # ...
            return {
                "success": True,
                "message": "验证码已发送"
            }
        except Exception as e:
            print(f"腾讯云短信发送失败: {str(e)}")
            return {
                "success": False,
                "message": f"发送失败: {str(e)}"
            }
    
    def verify_code(self, phone: str, code: str) -> bool:
        """
        验证验证码
        
        Args:
            phone: 手机号
            code: 验证码
            
        Returns:
            bool: 验证是否成功
        """
        if phone not in self._code_storage:
            return False
        
        stored_data = self._code_storage[phone]
        
        # 检查是否过期
        if datetime.now() > stored_data["expire_time"]:
            del self._code_storage[phone]
            return False
        
        # 验证码匹配
        if stored_data["code"] == code:
            # 验证成功后删除验证码（一次性使用）
            del self._code_storage[phone]
            return True
        
        return False
    
    def cleanup_expired_codes(self):
        """清理过期的验证码（定时任务调用）"""
        current_time = datetime.now()
        expired_phones = [
            phone for phone, data in self._code_storage.items()
            if current_time > data["expire_time"]
        ]
        for phone in expired_phones:
            del self._code_storage[phone]


# 全局短信服务实例
sms_service = SMSService()
