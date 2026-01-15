from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import IntegrityError


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """处理验证错误"""
    return JSONResponse(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, content={"detail": exc.errors()})


async def integrity_exception_handler(request: Request, exc: IntegrityError):
    """处理数据库完整性错误"""
    error_msg = str(exc.orig)

    if "Duplicate entry" in error_msg:
        if "username" in error_msg:
            detail = "用户名已存在"
        elif "email" in error_msg:
            detail = "邮箱已被注册"
        else:
            detail = "数据重复"
    else:
        detail = "数据库错误"

    return JSONResponse(status_code=status.HTTP_400_BAD_REQUEST, content={"detail": detail})
