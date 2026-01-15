"""微信登录相关工具函数"""
import httpx
from typing import Optional, Dict, Any
from fastapi import HTTPException, status


class WeChatConfig:
    """微信配置"""
    # 移动应用（App）微信登录配置
    APP_ID: str = ""  # 在微信开放平台申请的AppID
    APP_SECRET: str = ""  # 在微信开放平台申请的AppSecret
    
    # 网页应用微信登录配置（可选）
    WEB_APP_ID: str = ""
    WEB_APP_SECRET: str = ""


class WeChatService:
    """微信登录服务"""
    
    def __init__(self):
        self.app_id = WeChatConfig.APP_ID
        self.app_secret = WeChatConfig.APP_SECRET
        
    async def get_access_token(self, code: str) -> Dict[str, Any]:
        """
        通过code获取access_token
        
        Args:
            code: 微信授权code（由前端获取后传递给后端）
            
        Returns:
            包含access_token, openid, unionid等信息的字典
        """
        url = "https://api.weixin.qq.com/sns/oauth2/access_token"
        params = {
            "appid": self.app_id,
            "secret": self.app_secret,
            "code": code,
            "grant_type": "authorization_code"
        }
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(url, params=params, timeout=10.0)
                data = response.json()
                
                if "errcode" in data:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"微信认证失败: {data.get('errmsg', 'Unknown error')}"
                    )
                
                return data
            except httpx.RequestError as e:
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail=f"无法连接到微信服务器: {str(e)}"
                )
    
    async def get_user_info(self, access_token: str, openid: str) -> Dict[str, Any]:
        """
        获取微信用户信息
        
        Args:
            access_token: 微信access_token
            openid: 用户的openid
            
        Returns:
            包含用户信息的字典（昵称、头像等）
        """
        url = "https://api.weixin.qq.com/sns/userinfo"
        params = {
            "access_token": access_token,
            "openid": openid,
            "lang": "zh_CN"
        }
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(url, params=params, timeout=10.0)
                data = response.json()
                
                if "errcode" in data:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"获取用户信息失败: {data.get('errmsg', 'Unknown error')}"
                    )
                
                return data
            except httpx.RequestError as e:
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail=f"无法连接到微信服务器: {str(e)}"
                )
    
    async def verify_and_get_user_info(self, code: str) -> Dict[str, Any]:
        """
        验证微信授权码并获取用户信息（组合接口）
        
        Args:
            code: 微信授权code
            
        Returns:
            包含openid、unionid、用户信息的字典
        """
        # 1. 获取access_token
        token_data = await self.get_access_token(code)
        
        access_token = token_data.get("access_token")
        openid = token_data.get("openid")
        unionid = token_data.get("unionid")  # 可能为None，取决于是否绑定开放平台
        
        # 2. 获取用户信息
        user_info = await self.get_user_info(access_token, openid)
        
        # 3. 整合返回数据
        return {
            "openid": openid,
            "unionid": unionid,
            "nickname": user_info.get("nickname"),
            "avatar_url": user_info.get("headimgurl"),
            "sex": user_info.get("sex"),  # 1为男性，2为女性，0为未知
            "province": user_info.get("province"),
            "city": user_info.get("city"),
            "country": user_info.get("country")
        }


# 创建全局服务实例
wechat_service = WeChatService()
