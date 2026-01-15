"""
数据库迁移脚本 - 添加手机号字段
执行方式: python migrate_add_phone.py
"""
import sys
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

# 获取数据库连接URL
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("错误: 未找到DATABASE_URL环境变量")
    sys.exit(1)

# 创建数据库引擎
engine = create_engine(DATABASE_URL, echo=False)

def migrate_add_phone_field():
    """添加phone字段到users表"""
    
    print("=" * 60)
    print("数据库迁移：添加phone字段到users表")
    print("=" * 60)
    
    try:
        # 检查表是否存在
        with engine.connect() as conn:
            # 检查phone字段是否已经存在
            check_column_sql = text("""
                SELECT COUNT(*) as count
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'users'
                AND COLUMN_NAME = 'phone'
            """)
            
            result = conn.execute(check_column_sql)
            row = result.fetchone()
            
            if row[0] > 0:
                print("✓ phone字段已经存在，无需迁移")
                return True
            
            print("→ 开始添加phone字段...")
            
            # 添加phone字段
            alter_table_sql = text("""
                ALTER TABLE users 
                ADD COLUMN phone VARCHAR(20) NULL AFTER nickname,
                ADD UNIQUE INDEX idx_phone (phone)
            """)
            
            conn.execute(alter_table_sql)
            conn.commit()
            
            print("✓ phone字段添加成功")
            
            # 验证字段是否添加成功
            verify_sql = text("""
                SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'users'
                AND COLUMN_NAME = 'phone'
            """)
            
            result = conn.execute(verify_sql)
            row = result.fetchone()
            
            if row:
                print(f"\n字段信息:")
                print(f"  名称: {row[0]}")
                print(f"  类型: {row[1]}")
                print(f"  可为空: {row[2]}")
                print(f"  索引: {row[3]}")
                print("\n✓ 迁移成功完成！")
                return True
            else:
                print("✗ 验证失败：无法找到新添加的字段")
                return False
                
    except SQLAlchemyError as e:
        print(f"\n✗ 迁移失败: {str(e)}")
        return False
    except Exception as e:
        print(f"\n✗ 发生错误: {str(e)}")
        return False

def show_table_structure():
    """显示users表结构"""
    try:
        with engine.connect() as conn:
            desc_sql = text("DESC users")
            result = conn.execute(desc_sql)
            
            print("\n" + "=" * 80)
            print("users表当前结构:")
            print("=" * 80)
            print(f"{'Field':<20} {'Type':<20} {'Null':<8} {'Key':<8} {'Default':<12}")
            print("-" * 80)
            
            for row in result:
                print(f"{row[0]:<20} {row[1]:<20} {row[2]:<8} {row[3]:<8} {str(row[4]):<12}")
            
            print("=" * 80)
            
    except Exception as e:
        print(f"显示表结构失败: {str(e)}")

if __name__ == "__main__":
    print("\n开始执行数据库迁移...\n")
    
    # 执行迁移
    success = migrate_add_phone_field()
    
    # 显示表结构
    if success:
        show_table_structure()
    
    print("\n迁移脚本执行完毕\n")
    sys.exit(0 if success else 1)
