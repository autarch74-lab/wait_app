# backend/tests/test_api.py
from fastapi.testclient import TestClient

from backend.api.main import app

client = TestClient(app)


def test_collect_indices():
    resp = client.post(
        "/api/collect/indices", json={"sources": ["A", "B"], "force": True}
    )
    assert resp.status_code == 200
    assert resp.json()["collected"] == 2


def test_generate_deduper():
    resp = client.post("/api/generate", json={"texts": ["a b c", "a b c", "unique"]})
    assert resp.status_code == 200
    data = resp.json()
    assert data["count"] == 2
