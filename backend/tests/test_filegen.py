# backend/tests/test_filegen.py
from pathlib import Path

from backend.filegen.writer import write_q_frame, write_r_index, write_r_news


def read_lines(p):
    return [line.rstrip("\n") for line in Path(p).read_text(encoding="utf-8").splitlines()]


def test_write_files(tmp_path):
    base = tmp_path / "out"
    items = ["line1", "line2", "line3"]
    write_r_index(str(base), items)
    write_r_news(str(base), items)
    write_q_frame(str(base), items)

    assert read_lines(base / "r_index.txt") == items
    assert read_lines(base / "r_news.txt") == items
    assert read_lines(base / "q_frame.txt") == items
