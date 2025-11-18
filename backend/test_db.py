# test_db.py
import os, traceback
from sqlalchemy import create_engine, text

url = os.getenv("DATABASE_URL")
print("DATABASE_URL:", url)
try:
    engine = create_engine(url, echo=False)
    with engine.connect() as conn:
        print("connected, version:", conn.execute(text("select version()")).scalar())
except Exception:
    traceback.print_exc()
