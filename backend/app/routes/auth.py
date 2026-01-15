from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.models.user import User
from app.schemas.user_schema import UserCreate, UserLogin, UserResponse, Token, WeChatLogin, PhoneSendCode, PhoneLogin, PasswordResetRequest, PasswordResetConfirm
from app.utils.jwt_helper import verify_password, get_password_hash, create_access_token
from app.middleware.auth_middleware import get_current_user
from app.utils.wechat_helper import wechat_service
from app.utils.sms_helper import sms_service

router = APIRouter(prefix="/auth", tags=["认证"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """用户注册"""

    # 检查邮箱是否已存在
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="邮箱已被注册")

    # 检查用户名是否已存在
    existing_username = db.query(User).filter(User.username == user_data.username).first()
    if existing_username:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="用户名已存在")

    # 创建新用户
    new_user = User(
        username=user_data.username,
        email=user_data.email,
        password_hash=get_password_hash(user_data.password),
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


@router.post("/login", response_model=Token)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    """用户登录（支持用户名或邮箱）"""

    # 查找用户（支持用户名或邮箱）
    user = db.query(User).filter(
        (User.email == user_data.account) | (User.username == user_data.account)
    ).first()

    if not user or not verify_password(user_data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="用户名/邮箱或密码错误")

    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="账户已被禁用")

    # 创建访问令牌
    access_token = create_access_token(data={"user_id": user.id, "email": user.email})

    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """获取当前用户信息"""
    return current_user


@router.post("/wechat/login", response_model=Token)
async def wechat_login(wechat_data: WeChatLogin, db: Session = Depends(get_db)):
    """
    微信登录
    
    前端通过微信SDK获取code后，将code发送到此接口
    后端验证code并获取用户信息，自动注册或登录
    """
    try:
        # 1. 验证微信授权码并获取用户信息
        wechat_info = await wechat_service.verify_and_get_user_info(wechat_data.code)
        
        openid = wechat_info.get("openid")
        unionid = wechat_info.get("unionid")
        
        if not openid:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="无法获取微信用户标识"
            )
        
        # 2. 查找用户（优先使用unionid，其次使用openid）
        user = None
        if unionid:
            user = db.query(User).filter(User.wechat_unionid == unionid).first()
        if not user and openid:
            user = db.query(User).filter(User.wechat_openid == openid).first()
        
        # 3. 如果用户不存在，自动注册
        if not user:
            # 生成唯一的用户名
            base_username = wechat_info.get("nickname", "wx_user")
            username = base_username
            counter = 1
            while db.query(User).filter(User.username == username).first():
                username = f"{base_username}_{counter}"
                counter += 1
            
            # 创建新用户
            user = User(
                username=username,
                email=None,  # 微信登录不需要邮箱
                password_hash=None,  # 微信登录不需要密码
                wechat_openid=openid,
                wechat_unionid=unionid,
                nickname=wechat_info.get("nickname"),
                avatar_url=wechat_info.get("avatar_url"),
                is_active=True
            )
            
            db.add(user)
            db.commit()
            db.refresh(user)
        else:
            # 4. 用户已存在，更新微信信息
            user.wechat_openid = openid
            if unionid:
                user.wechat_unionid = unionid
            user.nickname = wechat_info.get("nickname")
            user.avatar_url = wechat_info.get("avatar_url")
            db.commit()
        
        # 5. 检查用户状态
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="账户已被禁用"
            )
        
        # 6. 创建JWT token
        access_token = create_access_token(
            data={
                "user_id": user.id,
                "email": user.email or f"wechat_{user.id}@temp.com"
            }
        )
        
        return {"access_token": access_token, "token_type": "bearer"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"微信登录失败: {str(e)}"
        )


@router.post("/phone/send-code")
async def send_phone_code(phone_data: PhoneSendCode, db: Session = Depends(get_db)):
    """
    发送手机验证码
    
    用于手机号登录/注册时获取验证码
    """
    try:
        # 发送验证码
        result = await sms_service.send_code(phone_data.phone)
        
        if not result["success"]:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=result["message"]
            )
        
        # 开发模式会返回验证码，生产环境不返回
        response = {"message": result["message"]}
        if "code" in result:
            response["code"] = result["code"]
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"发送验证码失败: {str(e)}"
        )


@router.post("/phone/login", response_model=Token)
async def phone_login(phone_data: PhoneLogin, db: Session = Depends(get_db)):
    """
    手机号验证码登录
    
    如果手机号未注册，会自动创建新用户
    """
    try:
        # 调试日志
        print(f"[登录] 手机号: {phone_data.phone}, 验证码: {phone_data.code}")
        print(f"[登录] 验证码存储: {sms_service._code_storage}")
        
        # 1. 验证验证码
        if not sms_service.verify_code(phone_data.phone, phone_data.code):
            print(f"[登录] 验证码验证失败")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="验证码错误或已过期"
            )
        
        # 2. 查找用户
        user = db.query(User).filter(User.phone == phone_data.phone).first()
        
        # 3. 如果用户不存在，自动注册
        if not user:
            # 生成唯一的用户名
            base_username = f"user_{phone_data.phone[-4:]}"
            username = base_username
            counter = 1
            while db.query(User).filter(User.username == username).first():
                username = f"{base_username}_{counter}"
                counter += 1
            
            # 创建新用户
            user = User(
                username=username,
                email=None,  # 手机号登录不需要邮箱
                password_hash=None,  # 手机号登录不需要密码
                phone=phone_data.phone,
                is_active=True
            )
            
            db.add(user)
            db.commit()
            db.refresh(user)
        
        # 4. 检查用户状态
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="账户已被禁用"
            )
        
        # 5. 创建JWT token
        access_token = create_access_token(
            data={
                "user_id": user.id,
                "email": user.email or f"phone_{user.id}@temp.com"
            }
        )
        
        return {"access_token": access_token, "token_type": "bearer"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"手机号登录失败: {str(e)}"
        )


@router.post("/password/reset-request")
async def request_password_reset(reset_data: PasswordResetRequest, db: Session = Depends(get_db)):
    """
    请求密码重置（发送验证码）
    
    用于忘记密码时，通过手机号获取验证码
    """
    try:
        # 1. 检查手机号是否已注册
        user = db.query(User).filter(User.phone == reset_data.phone).first()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="该手机号未注册"
            )
        
        # 2. 发送验证码
        result = await sms_service.send_code(reset_data.phone)
        
        if not result["success"]:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=result["message"]
            )
        
        # 开发模式会返回验证码，生产环境不返回
        response = {"message": result["message"]}
        if "code" in result:
            response["code"] = result["code"]
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"发送验证码失败: {str(e)}"
        )


@router.post("/password/reset-confirm")
async def confirm_password_reset(reset_data: PasswordResetConfirm, db: Session = Depends(get_db)):
    """
    确认密码重置（验证码+新密码）
    
    验证验证码后设置新密码
    """
    try:
        # 1. 验证验证码
        if not sms_service.verify_code(reset_data.phone, reset_data.code):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="验证码错误或已过期"
            )
        
        # 2. 查找用户
        user = db.query(User).filter(User.phone == reset_data.phone).first()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="用户不存在"
            )
        
        # 3. 更新密码
        user.password_hash = get_password_hash(reset_data.new_password)
        db.commit()
        
        return {"message": "密码重置成功"}
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"密码重置失败: {str(e)}"
        )
