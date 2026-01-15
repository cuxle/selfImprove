from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import IntegrityError
from app.config.config import settings
from app.config.database import Base, engine
from app.routes import auth, diary, challenge, tag, stats, reminder, export, backup
from app.middleware.error_handler import validation_exception_handler, integrity_exception_handler

# 创建数据库表
Base.metadata.create_all(bind=engine)

# 创建FastAPI应用
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.API_VERSION,
    description="情绪遗产 - 心理健康自我觉察应用API",
    docs_url="/docs",  # Swagger UI
    redoc_url="/redoc",  # ReDoc
)

# CORS中间件配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 开发环境临时允许所有来源
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册异常处理器
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(IntegrityError, integrity_exception_handler)

# 注册路由
app.include_router(auth.router, prefix="/api/v1")
app.include_router(diary.router, prefix="/api/v1")
app.include_router(challenge.router, prefix="/api/v1")
app.include_router(tag.router, prefix="/api/v1")
app.include_router(stats.router, prefix="/api/v1")
app.include_router(reminder.router, prefix="/api/v1")
app.include_router(export.router, prefix="/api/v1")
app.include_router(backup.router, prefix="/api/v1")


@app.get("/")
async def root():
    """根路径"""
    return {
        "message": "欢迎使用情绪遗产API",
        "version": settings.API_VERSION,
        "docs": "/docs",
    }


@app.get("/health")
async def health_check():
    """健康检查"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
    )
