# 파일: app/core/filegen.py
from pathlib import Path
import os
import logging

logger = logging.getLogger(__name__)

def _get_articles_from_db(limit=20):
    try:
        from app.db.session import SessionLocal
        from app.models.models import Article
    except Exception:
        return None
    session = SessionLocal()
    try:
        rows = session.query(Article).order_by(Article.published_at.desc()).limit(limit).all()
        return [{"title": r.title or "", "url": getattr(r, "url", ""), "summary": getattr(r, "summary", "")} for r in rows]
    finally:
        session.close()

def generate_all(mode="news", out_dir=None):
    out_dir = Path(out_dir or os.environ.get("WAIT_OUTPUT_DIR", Path.cwd()))
    out_dir.mkdir(parents=True, exist_ok=True)

    articles = _get_articles_from_db() or [
        {"title": "stub article 1", "url": "", "summary": "no DB available"},
        {"title": "stub article 2", "url": "", "summary": "no DB available"},
    ]

    r_news = out_dir / "r_news.txt"
    q_frame = out_dir / "q_frame.txt"

    with r_news.open("w", encoding="utf-8") as f:
        for a in articles:
            f.write(f"{a['title']}\n{a['url']}\n{a['summary']}\n---\n")

    with q_frame.open("w", encoding="utf-8") as f:
        f.write("Q_FRAME\n")
        for i, a in enumerate(articles[:10], 1):
            f.write(f"{i}. {a['title']}\n")

    logger.info("filegen wrote %d articles to %s", len(articles), out_dir)
    return {"status": "ok", "mode": mode, "files": [str(r_news), str(q_frame)], "count": len(articles)}
