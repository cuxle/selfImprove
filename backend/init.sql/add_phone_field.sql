-- ============================================================
-- 数据库迁移脚本：添加手机号字段
-- 版本：1.1
-- 日期：2026-01-11
-- 说明：为users表添加phone字段，支持手机号验证码登录
-- ============================================================

USE emotion_legacy_db;

-- 1. 检查phone字段是否已存在
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '字段已存在，跳过迁移'
        ELSE '开始添加字段'
    END AS status
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'users'
AND COLUMN_NAME = 'phone';

-- 2. 添加phone字段（如果不存在）
-- 注意：如果字段已存在，此语句会报错，可以忽略
ALTER TABLE users 
ADD COLUMN phone VARCHAR(20) NULL COMMENT '手机号' AFTER nickname;

-- 3. 添加唯一索引
-- 注意：如果索引已存在，此语句会报错，可以忽略
ALTER TABLE users 
ADD UNIQUE INDEX idx_phone (phone);

-- 4. 验证字段是否添加成功
SELECT 
    COLUMN_NAME as '字段名',
    COLUMN_TYPE as '类型',
    IS_NULLABLE as '可为空',
    COLUMN_KEY as '索引',
    COLUMN_COMMENT as '备注'
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'users'
AND COLUMN_NAME = 'phone';

-- 5. 查看完整的users表结构
DESC users;

-- ============================================================
-- 迁移完成提示
-- ============================================================
SELECT '✓ phone字段迁移完成！' AS '迁移状态';
SELECT '现在支持三种登录方式：邮箱密码、微信登录、手机号验证码' AS '功能说明';

