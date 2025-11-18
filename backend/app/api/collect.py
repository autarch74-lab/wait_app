from fastapi import APIRouter, BackgroundTasks
router = APIRouter()

@router.post("/news")
async def collect_news(sources: list[str], dedupe: bool = True):
    # job 생성 스텁: 실제 collector 호출은 background task로 처리
    return {"status":"job_created", "sources": sources, "dedupe": dedupe}
