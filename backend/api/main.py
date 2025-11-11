# backend/api/main.py
from fastapi import FastAPI
from pydantic import BaseModel
from backend.deduper.deduper import dedupe

app = FastAPI()

class CollectRequest(BaseModel):
    sources: list[str]
    force: bool = False

@app.post("/api/collect/indices")
def collect_indices(req: CollectRequest):
    # 실제 수집 로직 대신 시뮬레이션 반환
    return {"status": "ok", "collected": len(req.sources)}

class GenerateRequest(BaseModel):
    texts: list[str]

@app.post("/api/generate")
def generate(req: GenerateRequest):
    deduped = dedupe(req.texts)
    return {"count": len(deduped), "items": deduped}
