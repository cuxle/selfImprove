# AWS Lightsail 部署指南

本指南将帮助你将 Emotion Legacy (情绪遗产) 后端项目部署到 AWS Lightsail 服务器。

## 1. 准备工作

### 1.1 修改 Docker 配置 (可选)
为了在海外服务器获得更好的构建速度，建议修改 `backend/Dockerfile`。
如果不修改也能运行，但可能下载依赖较慢。

**文件:** `backend/Dockerfile`
找到:
```dockerfile
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```
改为 (移除 `-i` 参数使用官方源):
```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

### 1.2 准备代码
确保你的代码已经提交到 GitHub/GitLab，或者准备好打包上传。

---

## 2. 创建 Lightsail 实例

1. 登录 [AWS Lightsail 控制台](https://lightsail.aws.amazon.com/)。
2. 点击 **"Create instance"**。
3. **Platform**: 选择 `Linux/Unix`。
4. **Blueprint**: 选择 **OS Only** -> **Ubuntu 22.04 LTS** (或 24.04)。
   * *注意: 虽然有 Docker 预装镜像，但使用纯 Ubuntu 手动安装灵活性更好。*
5. **Instance plan**: 选择 `$5 USD` (1 GB RAM, 1 vCPU, 40 GB SSD) 或更高。
   * *对于本项目，Docker + MySQL 至少建议 1GB 内存配置。*
6. **Instance name**: 输入 `emotion-backend`。
7. 点击 **"Create instance"**。

---

## 3. 配置网络 (防火墙)

1. 点击刚创建的实例进入详情页。
2. 点击 **"Networking"** 标签页。
3. 在 **"IPv4 Firewall"** 区域，添加规则:
   - 默认已有 SSH (TCP 22) 和 HTTP (TCP 80)。
   - 添加 **HTTPS** (TCP 443)。
   - (可选) 添加 **Custom TCP 8000** (如果你想直接访问 API 而不经过 Nginx)。
4. 建议点击 **"Attach static IP"** 创建并绑定一个静态 IP，这样重启服务器 IP 不变。

---

## 4. 连接服务器并安装环境

点击页面上的 **"Connect using SSH"** (橙色按钮) 或使用本地终端 SSH 连接。

在终端中执行以下命令安装 Docker:

```bash
# 1. 更新系统
sudo apt-get update && sudo apt-get upgrade -y

# 2. 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. 将当前用户加入 docker 组 (避免每次输 sudo)
sudo usermod -aG docker $USER

# 4. 安装 Docker Compose (新版 Docker 已集成，验证一下)
docker compose version
# 如果显示 version 说明安装成功
```

*执行完第3步后，建议关闭 SSH 窗口重新连接，以使权限生效。*

---

## 5. 部署应用

### 5.1 获取代码
(假设你使用 Git)
```bash
# 安装 git
sudo apt-get install git -y

# 克隆代码 (替换为你的仓库地址)
git clone https://github.com/yourusername/selfimprove.git
cd selfimprove/backend
```
*如果没有 Git，可以使用 SFTP 工具 (如 FileZilla) 将本地 `selfimprove/backend` 目录上传到服务器 `/home/ubuntu/backend`。*

### 5.2 配置环境变量
在服务器端创建 `.env` 文件。

```bash
# 进入 backend 目录
cd ~/selfimprove/backend

# 复制示例配置 (如果有) 或者新建
nano .env
```

**粘贴以下内容 (根据实际情况修改):**
```ini
DATABASE_URL=mysql+aiomysql://root:MySuperSecurePass123@db/emotion_legacy_db
MYSQL_ROOT_PASSWORD=MySuperSecurePass123
SECRET_KEY=your_production_secret_key_change_this
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALLOWED_ORIGINS=*
```
*按 `Ctrl+O` -> `Enter` 保存，`Ctrl+X` 退出。*

### 5.3 修改 docker-compose.yml 端口 (重要)
默认配置将 Nginx 映射到 8080 端口，生产环境我们需要它是 80。

```bash
nano docker-compose.yml
```

找到 `nginx` 部分:
```yaml
  nginx:
    # ...
    ports:
      - "8080:80"   # <--- 修改这行
      - "8443:443"
```
改为:
```yaml
    ports:
      - "80:80"     # <--- 改为 80
      - "443:443"
```

---

## 6. 启动服务

```bash
# 启动所有服务 (-d 后台运行)
docker compose up -d --build
```

**查看状态:**
```bash
docker compose ps
docker compose logs -f api  # 查看 API 日志
```

如果一切正常，你可以通过浏览器访问 `http://<你的静态IP>/docs` 查看 Swagger 文档。

---

## 7. 后续维护

- **更新代码**:
  ```bash
  cd ~/selfimprove/backend
  git pull
  docker compose up -d --build
  ```
- **备份数据库**:
  ```bash
  docker exec emotion_db mysqldump -u root -pMySuperSecurePass123 emotion_legacy_db > backup.sql
  ```
