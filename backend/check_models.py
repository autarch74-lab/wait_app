import sys, os, traceback
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), ".")))

candidates = [
    "app.models.models:Base",
    "app.models:Base",
    "models:Base",
    "src.app.models.models:Base",
]

for cand in candidates:
    print("Trying", cand)
    try:
        mod, attr = cand.split(":", 1)
        m = __import__(mod, fromlist=[attr])
        B = getattr(m, attr)
        print("OK ->", cand, "tables:", list(B.metadata.tables.keys()))
        break
    except Exception:
        traceback.print_exc()
