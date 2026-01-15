# 情绪遗产 App - 数据库设计

## 1. 用户表 (users)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 用户ID | 主键, 自增 |
| username | VARCHAR(50) | 用户名 | 唯一, 非空 |
| email | VARCHAR(100) | 邮箱 | 唯一, 非空 |
| password_hash | VARCHAR(255) | 密码哈希 | 非空 |
| created_at | TIMESTAMP | 创建时间 | 默认当前时间 |
| updated_at | TIMESTAMP | 更新时间 | 默认当前时间 |
| is_active | BOOLEAN | 账户是否激活 | 默认true |

## 2. 情绪遗产日记表 (emotion_diaries)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 日记ID | 主键, 自增 |
| user_id | BIGINT | 用户ID | 外键, 非空 |
| trigger_event | TEXT | 触发事件描述 | 非空 |
| immediate_emotion | VARCHAR(100) | 即时情绪 | 非空 |
| emotion_intensity | INT | 情绪强度(1-10) | 1-10 |
| physical_reaction | TEXT | 身体反应 | 可为空 |
| auto_thought | TEXT | 自动化思维 | 可为空 |
| childhood_memory | TEXT | 童年记忆联结 | 可为空 |
| pattern_recognition | TEXT | 模式识别 | 可为空 |
| created_at | TIMESTAMP | 记录时间 | 默认当前时间 |
| updated_at | TIMESTAMP | 更新时间 | 默认当前时间 |

## 3. 情绪标签表 (emotion_tags)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 标签ID | 主键, 自增 |
| tag_name | VARCHAR(50) | 标签名称 | 唯一, 非空 |
| tag_type | VARCHAR(20) | 标签类型 (emotion/pattern/trigger) | 非空 |
| created_at | TIMESTAMP | 创建时间 | 默认当前时间 |

## 4. 日记-标签关联表 (diary_tags)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 关联ID | 主键, 自增 |
| diary_id | BIGINT | 日记ID | 外键, 非空 |
| tag_id | BIGINT | 标签ID | 外键, 非空 |
| created_at | TIMESTAMP | 创建时间 | 默认当前时间 |

唯一约束: (diary_id, tag_id)

## 5. 新回应挑战表 (response_challenges)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 挑战ID | 主键, 自增 |
| user_id | BIGINT | 用户ID | 外键, 非空 |
| diary_id | BIGINT | 关联日记ID | 外键, 可为空 |
| challenge_title | VARCHAR(200) | 挑战标题 | 非空 |
| old_response | TEXT | 旧的自动反应 | 非空 |
| new_response | TEXT | 新的有意识回应 | 非空 |
| difficulty_level | INT | 难度等级(1-5) | 1-5 |
| status | VARCHAR(20) | 状态(planned/in_progress/completed) | 非空 |
| actual_result | TEXT | 实际执行结果 | 可为空 |
| reflection | TEXT | 反思记录 | 可为空 |
| success_rate | INT | 成功率(0-100) | 0-100, 可为空 |
| created_at | TIMESTAMP | 创建时间 | 默认当前时间 |
| updated_at | TIMESTAMP | 更新时间 | 默认当前时间 |
| completed_at | TIMESTAMP | 完成时间 | 可为空 |

## 6. 挑战执行记录表 (challenge_attempts)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 记录ID | 主键, 自增 |
| challenge_id | BIGINT | 挑战ID | 外键, 非空 |
| attempt_date | DATE | 尝试日期 | 非空 |
| success | BOOLEAN | 是否成功 | 非空 |
| notes | TEXT | 笔记 | 可为空 |
| emotion_before | VARCHAR(100) | 尝试前情绪 | 可为空 |
| emotion_after | VARCHAR(100) | 尝试后情绪 | 可为空 |
| created_at | TIMESTAMP | 创建时间 | 默认当前时间 |

## 7. 内容库文章表 (content_articles)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 文章ID | 主键, 自增 |
| title | VARCHAR(200) | 文章标题 | 非空 |
| category | VARCHAR(50) | 分类(trauma/attachment/neuroscience) | 非空 |
| content | TEXT | 文章内容 | 非空 |
| audio_url | VARCHAR(255) | 音频链接 | 可为空 |
| reading_time | INT | 阅读时长(分钟) | 可为空 |
| created_at | TIMESTAMP | 创建时间 | 默认当前时间 |
| updated_at | TIMESTAMP | 更新时间 | 默认当前时间 |

## 8. 用户阅读记录表 (user_reading_history)

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | BIGINT | 记录ID | 主键, 自增 |
| user_id | BIGINT | 用户ID | 外键, 非空 |
| article_id | BIGINT | 文章ID | 外键, 非空 |
| progress | INT | 阅读进度(0-100) | 0-100 |
| completed | BOOLEAN | 是否完成 | 默认false |
| last_read_at | TIMESTAMP | 最后阅读时间 | 默认当前时间 |

## 关系说明

1. **用户 ↔ 日记**: 一对多 (一个用户可以有多条日记)
2. **日记 ↔ 标签**: 多对多 (通过diary_tags关联表)
3. **用户 ↔ 挑战**: 一对多 (一个用户可以有多个挑战)
4. **日记 ↔ 挑战**: 一对多 (一条日记可以衍生多个挑战)
5. **挑战 ↔ 执行记录**: 一对多 (一个挑战可以有多次尝试)
6. **用户 ↔ 阅读记录**: 一对多 (一个用户可以阅读多篇文章)

## 数据隐私与安全考虑

1. **敏感数据加密**:
   - `trigger_event`, `auto_thought`, `childhood_memory` 等敏感字段考虑应用层加密

2. **数据备份**:
   - 定期自动备份用户数据
   - 提供用户导出个人数据功能

3. **匿名化处理**:
   - 如果未来添加社区功能，确保分享内容完全匿名

4. **访问控制**:
   - 严格的用户身份验证
   - 用户只能访问自己的数据
