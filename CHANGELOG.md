# 更新日志 (Changelog)

所有重要更改都记录在此文件中。

---

## [未发布] - 2026-01-24

### 新增
- `LIGHTSAIL_DEPLOY.md`：新增 AWS Lightsail 部署指南，详细说明如何将后端服务部署到海外云服务器，包括：
  - Lightsail 实例创建与配置
  - 网络防火墙规则设置
  - Docker 环境安装
  - 应用部署与环境变量配置
  - 日常维护操作（更新代码、备份数据库）

### 修改
- `backend/Dockerfile`：移除 pip 安装时的清华大学镜像源参数 (`-i https://pypi.tuna.tsinghua.edu.cn/simple`)，改为使用 PyPI 官方源，以适配部署在海外服务器（如 AWS Lightsail）时的网络环境。

---

## [初始版本] - 2026-01-15

### 新增
- 项目初始化：后端 (FastAPI) + 前端 (Flutter) 完整项目结构
- 用户认证系统（注册、登录、JWT Token）
- 情绪遗产日记 CRUD API
- 新回应挑战 CRUD API 及尝试记录功能
- 数据库设计文档 (`database-design.md`)
- 项目结构文档 (`project-structure.md`)
- 主要文档：`README.md`、`backend/README.md`、`flutter_app/README.md`
