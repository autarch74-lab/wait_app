# alembic/env.py
import os
import sys
import traceback
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool
from alembic import context

# 프로젝트 루트를 import 경로에 추가 (alembic 디렉터리의 부모)
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# 환경변수로 DATABASE_URL 덮어쓰기 (있으면 alembic.ini의 url을 덮음)
db_url = os.getenv("DATABASE_URL")
if db_url:
    config.set_main_option("sqlalchemy.url", db_url)

# target_metadata 준비: 여러 후보 경로를 시도하여 Base.metadata를 찾음
target_metadata = None

# 필요하면 여기에 프로젝트의 실제 경로 후보를 추가하세요
candidates = [
    "app.models.models:Base",
    "app.models:Base",
    "models:Base",
    "src.app.models.models:Base",
    "backend.app.models.models:Base",
]

for cand in candidates:
    try:
        mod, attr = cand.split(":", 1)
        module = __import__(mod, fromlist=[attr])
        obj = getattr(module, attr)
        # obj가 declarative base 클래스인 경우 metadata 속성 사용
        if hasattr(obj, "metadata"):
            target_metadata = obj.metadata
        # 혹시 metadata 객체 자체를 직접 노출한 경우
        elif getattr(obj, "__class__", None) and getattr(obj, "tables", None) is not None:
            target_metadata = obj
        if target_metadata is not None:
            print(f"Imported Base/metadata from {cand}")
            break
    except Exception:
        # 실패하면 스택트레이스 출력하고 다음 후보 시도
        traceback.print_exc()

if target_metadata is None:
    raise RuntimeError(
        "Could not import Base for target_metadata. "
        "Check import path, package structure (presence of __init__.py), and that model modules do not execute side effects on import."
    )

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
        compare_server_default=True,
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
            compare_server_default=True,
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
