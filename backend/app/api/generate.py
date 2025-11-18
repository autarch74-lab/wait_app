from fastapi import APIRouter
router = APIRouter()

@router.post("/")
async def generate(mode: str = "combined", template_id: str | None = None):
    # filegen 호출 스텁
    return {"status":"filegen_started", "mode": mode, "template_id": template_id}
