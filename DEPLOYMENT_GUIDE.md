# 后端云服务器部署指南

## 📋 目录

1. [服务器选择建议](#服务器选择建议)
2. [部署方式对比](#部署方式对比)
3. [Docker部署（推荐）](#docker部署推荐)
4. [传统部署](#传统部署)
5. [数据库配置](#数据库配置)
6. [域名和HTTPS配置](#域名和https配置)
7. [监控和维护](#监控和维护)

---

## 🌐 服务器选择建议

### 国内云服务商推荐

| 云服务商 | 优势 | 适合场景 | 价格参考 |
|---------|------|---------|---------|
| **阿里云ECS** | 稳定性好、网络质量高 | 企业应用、大流量 | ¥99-300/月 |
| **腾讯云CVM** | 性价比高、微信生态好 | 微信小程序、个人项目 | ¥88-280/月 |
| **华为云ECS** | 企业级稳定 | 政企应用 | ¥99-320/月 |
| **百度云BCC** | 价格实惠 | 个人学习、测试 | ¥68-200/月 |

### 推荐配置（起步）

**轻量级应用（个人/小团队）：**
- CPU: 2核
- 内存: 2GB
- 带宽: 1-3Mbps
- 硬盘: 40GB SSD
- 系统: Ubuntu 22.04 / CentOS 8

**估计费用：** ¥80-150/月

### 学生优惠
- 阿里云学生机：¥9.5/月
- 腾讯云学生机：¥10/月
- 华为云学生优惠：¥9/月

---

## 🎯 部署方式对比

| 方式 | 优点 | 缺点 | 推荐度 |
|-----|------|------|--------|
| **Docker部署** | 环境一致、部署快速、易于迁移 | 需要学习Docker | ⭐⭐⭐⭐⭐ |
| **传统部署** | 直接、易理解 | 环境配置复杂、依赖管理麻烦 | ⭐⭐⭐ |
| **Serverless** | 按量付费、自动扩缩容 | 冷启动问题、调试复杂 | ⭐⭐⭐⭐ |

**本指南重点介绍：Docker部署（推荐）+ 传统部署（备选）**

---

## 🐳 Docker部署（推荐）

### 优势
- ✅ 环境隔离，避免依赖冲突
- ✅ 一键部署，快速回滚
- ✅ 便于扩展和迁移
- ✅ 与本地开发环境一致

### 步骤一：准备Docker配置文件

创建以下文件到后端项目根目录：

#### 1. Dockerfile
```dockerfile
# 使用官方Python运行时作为基础镜像
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Shanghai

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制项目文件
COPY . .

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### 2. docker-compose.yml
```yaml
version: '3.8'

services:
  # FastAPI应用
  api:
    build: .
    container_name: emotion_api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=mysql+pymysql://root:${MYSQL_ROOT_PASSWORD}@db:3306/emotion_legacy_db
      - SECRET_KEY=${SECRET_KEY}
      - ALLOWED_ORIGINS=*
    depends_on:
      - db
    volumes:
      - ./app:/app/app
    restart: unless-stopped
    networks:
      - emotion_network

  # MySQL数据库
  db:
    image: mysql:8.0
    container_name: emotion_db
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=emotion_legacy_db
      - TZ=Asia/Shanghai
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped
    networks:
      - emotion_network

  # Nginx反向代理（可选）
  nginx:
    image: nginx:alpine
    container_name: emotion_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - api
    restart: unless-stopped
    networks:
      - emotion_network

volumes:
  mysql_data:

networks:
  emotion_network:
    driver: bridge
```

#### 3. .env.production（生产环境配置）
```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=your_strong_password_here_123456
DATABASE_URL=mysql+pymysql://root:your_strong_password_here_123456@db:3306/emotion_legacy_db

# JWT配置（务必修改为随机字符串）
SECRET_KEY=your-very-strong-secret-key-change-this-in-production-32chars-min
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# 应用配置
APP_NAME=Emotion Legacy API
DEBUG=False
API_VERSION=v1

# CORS配置
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# 微信配置（如果使用微信登录）
WECHAT_APP_ID=your_wechat_app_id
WECHAT_APP_SECRET=your_wechat_app_secret
```

#### 4. .dockerignore
```
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.env
.env.local
*.log
.git
.gitignore
README.md
.vscode
.idea
```

#### 5. nginx.conf（Nginx配置）
```nginx
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
        server api:8000;
    }

    server {
        listen 80;
        server_name yourdomain.com www.yourdomain.com;

        # 重定向到HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name yourdomain.com www.yourdomain.com;

        # SSL证书配置
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        # 安全配置
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # 日志
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        # 限制上传大小
        client_max_body_size 50M;

        # API代理
        location / {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket支持（如果需要）
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # API文档（可选择关闭）
        location /docs {
            proxy_pass http://api_backend;
            # 生产环境可注释以下行来禁用文档
            # deny all;
        }

        location /redoc {
            proxy_pass http://api_backend;
        }
    }
}
```

### 步骤二：上传代码到服务器

```bash
# 在本地打包项目
cd c:\Users\cxl\Desktop\selfimprove\backend
tar -czf backend.tar.gz --exclude=__pycache__ --exclude=.env .

# 上传到服务器（使用SCP）
scp backend.tar.gz root@your_server_ip:/root/

# 或使用Git（推荐）
git init
git add .
git commit -m "Initial commit"
git push origin main
```

### 步骤三：服务器安装Docker

```bash
# 连接到服务器
ssh root@your_server_ip

# 安装Docker（Ubuntu/Debian）
curl -fsSL https://get.docker.com | bash -s docker

# 安装Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version

# 启动Docker服务
systemctl start docker
systemctl enable docker
```

### 步骤四：部署应用

```bash
# 进入项目目录
cd /root/backend

# 解压代码（如果使用tar.gz）
tar -xzf backend.tar.gz

# 配置环境变量
cp .env.production .env
nano .env  # 修改密码等敏感信息

# 构建并启动服务
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 查看运行状态
docker-compose ps
```

### 步骤五：数据库初始化

```bash
# 进入API容器
docker exec -it emotion_api bash

# 运行数据库迁移（如果使用Alembic）
alembic upgrade head

# 或手动创建表
python -c "from app.config.database import Base, engine; Base.metadata.create_all(bind=engine)"

# 退出容器
exit
```

### 常用Docker命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f api

# 查看状态
docker-compose ps

# 重新构建
docker-compose up -d --build

# 进入容器
docker exec -it emotion_api bash

# 清理无用镜像
docker system prune -a
```

---

## 🔧 传统部署

### 适用场景
- 不使用Docker
- 服务器资源有限
- 需要直接控制环境

### 步骤一：服务器环境准备

```bash
# 连接服务器
ssh root@your_server_ip

# 更新系统
apt update && apt upgrade -y  # Ubuntu/Debian
# 或
yum update -y  # CentOS

# 安装Python 3.11
apt install python3.11 python3.11-venv python3-pip -y

# 安装MySQL
apt install mysql-server -y
systemctl start mysql
systemctl enable mysql

# 安全配置MySQL
mysql_secure_installation

# 安装Nginx
apt install nginx -y
systemctl start nginx
systemctl enable nginx

# 安装其他依赖
apt install git supervisor -y
```

### 步骤二：配置MySQL

```bash
# 登录MySQL
mysql -u root -p

# 创建数据库和用户
CREATE DATABASE emotion_legacy_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'emotion_user'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON emotion_legacy_db.* TO 'emotion_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 步骤三：部署应用

```bash
# 创建项目目录
mkdir -p /var/www/emotion-api
cd /var/www/emotion-api

# 克隆代码（或上传）
git clone https://github.com/yourusername/emotion-api.git .
# 或使用scp上传

# 创建虚拟环境
python3.11 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 配置环境变量
cp .env.example .env
nano .env
```

### 步骤四：配置Supervisor（进程管理）

创建 `/etc/supervisor/conf.d/emotion-api.conf`：

```ini
[program:emotion-api]
command=/var/www/emotion-api/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
directory=/var/www/emotion-api
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/emotion-api.log
environment=PATH="/var/www/emotion-api/venv/bin"
```

启动服务：

```bash
# 更新Supervisor配置
supervisorctl reread
supervisorctl update

# 启动应用
supervisorctl start emotion-api

# 查看状态
supervisorctl status

# 查看日志
tail -f /var/log/emotion-api.log
```

### 步骤五：配置Nginx

创建 `/etc/nginx/sites-available/emotion-api`：

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    client_max_body_size 50M;
}
```

启用配置：

```bash
# 创建软链接
ln -s /etc/nginx/sites-available/emotion-api /etc/nginx/sites-enabled/

# 测试配置
nginx -t

# 重启Nginx
systemctl restart nginx
```

---

## 🗄️ 数据库配置

### MySQL优化配置

编辑 `/etc/mysql/mysql.conf.d/mysqld.cnf`：

```ini
[mysqld]
# 字符集
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

# 性能优化
max_connections=200
innodb_buffer_pool_size=256M
innodb_log_file_size=64M
innodb_flush_method=O_DIRECT

# 慢查询日志
slow_query_log=1
slow_query_log_file=/var/log/mysql/slow.log
long_query_time=2

# 时区
default-time-zone='+08:00'
```

重启MySQL：
```bash
systemctl restart mysql
```

### 数据库备份

```bash
# 创建备份脚本 /root/backup_db.sh
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

mysqldump -u root -p'your_password' emotion_legacy_db > $BACKUP_DIR/emotion_db_$DATE.sql
gzip $BACKUP_DIR/emotion_db_$DATE.sql

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

# 添加到定时任务
chmod +x /root/backup_db.sh
crontab -e
# 添加：0 2 * * * /root/backup_db.sh  # 每天凌晨2点备份
```

---

## 🔒 域名和HTTPS配置

### 1. 域名解析

在域名服务商处添加A记录：
```
类型: A
主机记录: @
记录值: 你的服务器IP
TTL: 600
```

```
类型: A
主机记录: www
记录值: 你的服务器IP
TTL: 600
```

### 2. 申请SSL证书

#### 方式一：Let's Encrypt免费证书（推荐）

```bash
# 安装certbot
apt install certbot python3-certbot-nginx -y

# 申请证书
certbot --nginx -d yourdomain.com -d www.yourdomain.com

# 自动续期
certbot renew --dry-run
```

#### 方式二：阿里云/腾讯云免费证书

1. 在云服务商控制台申请免费SSL证书
2. 下载Nginx版本证书
3. 上传到服务器 `/etc/nginx/ssl/`

### 3. Nginx HTTPS配置

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # 其他配置...
}
```

---

## 📊 监控和维护

### 1. 服务器监控

```bash
# 安装htop（进程监控）
apt install htop -y

# 查看资源使用
htop

# 磁盘使用
df -h

# 内存使用
free -h

# 网络连接
netstat -tunlp
```

### 2. 应用日志

```bash
# Docker日志
docker-compose logs -f --tail=100 api

# 传统部署日志
tail -f /var/log/emotion-api.log

# Nginx日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 3. 性能监控工具

推荐安装：
- **Prometheus + Grafana**: 全面监控
- **阿里云云监控**: 云服务商自带
- **宝塔面板**: 可视化管理（适合新手）

### 4. 安全加固

```bash
# 配置防火墙
ufw allow 22/tcp     # SSH
ufw allow 80/tcp     # HTTP
ufw allow 443/tcp    # HTTPS
ufw enable

# 修改SSH端口（可选）
nano /etc/ssh/sshd_config
# Port 22 改为 Port 2222
systemctl restart sshd

# 禁用root远程登录
PermitRootLogin no

# 安装fail2ban防暴力破解
apt install fail2ban -y
systemctl enable fail2ban
```

---

## 🚀 部署检查清单

### 部署前
- [ ] 代码已测试通过
- [ ] 环境变量已配置
- [ ] 数据库密码已修改为强密码
- [ ] SECRET_KEY已生成随机值
- [ ] API域名已解析
- [ ] SSL证书已准备

### 部署后
- [ ] API可以访问（测试 https://yourdomain.com/）
- [ ] 数据库连接正常
- [ ] 日志输出正常
- [ ] 注册登录功能正常
- [ ] 微信登录配置正确（如需要）
- [ ] HTTPS正常工作
- [ ] 定时任务配置完成
- [ ] 备份脚本测试成功

### Flutter应用配置
- [ ] 修改 `lib/config/api_config.dart` 中的baseUrl为服务器域名
- [ ] 重新构建并发布应用

---

## 💰 成本估算

### 方案一：基础配置（个人项目）
- 云服务器（2核2G）：¥100/月
- 域名：¥50/年
- SSL证书：免费（Let's Encrypt）
- **总计：约¥105/月**

### 方案二：标准配置（小团队）
- 云服务器（2核4G）：¥150/月
- RDS数据库：¥80/月
- CDN流量：¥20/月
- 域名：¥50/年
- **总计：约¥254/月**

### 学生优惠方案
- 学生云服务器：¥10/月
- 免费域名（.tech等）：¥0
- Let's Encrypt证书：¥0
- **总计：约¥10/月**

---

## 📞 需要帮助？

**常见问题：**
1. 如何生成SECRET_KEY？
   ```python
   import secrets
   print(secrets.token_urlsafe(32))
   ```

2. 如何查看服务状态？
   ```bash
   # Docker方式
   docker-compose ps
   
   # 传统方式
   supervisorctl status
   ```

3. 如何更新代码？
   ```bash
   git pull
   docker-compose up -d --build  # Docker
   # 或
   supervisorctl restart emotion-api  # 传统
   ```

4. 性能不够怎么办？
   - 升级服务器配置
   - 添加Redis缓存
   - 使用CDN加速
   - 数据库读写分离

**推荐学习资源：**
- [Docker官方文档](https://docs.docker.com/)
- [FastAPI部署文档](https://fastapi.tiangolo.com/deployment/)
- [Nginx配置指南](https://nginx.org/en/docs/)
