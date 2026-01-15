@echo off
echo ========================================
echo 情绪遗产 - 后端启动脚本
echo ========================================
echo.

echo [1/4] 检查Python环境...
python --version
if errorlevel 1 (
    echo 错误：未找到Python，请先安装Python 3.11+
    pause
    exit /b 1
)
echo.

echo [2/4] 检查依赖...
pip show fastapi >nul 2>&1
if errorlevel 1 (
    echo 正在安装依赖...
    pip install -r requirements.txt
) else (
    echo 依赖已安装
)
echo.

echo [3/4] 检查环境变量...
if not exist .env (
    echo 警告：未找到.env文件，请确保已创建
    pause
)
echo.

echo [4/4] 启动后端服务...
echo 服务将在 http://localhost:8000 启动
echo API文档: http://localhost:8000/docs
echo.
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
