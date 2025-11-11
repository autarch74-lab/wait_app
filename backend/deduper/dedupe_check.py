from backend.deduper.deduper import dedupe
texts = ["a b c", "a b c", "unique"]
print("input:", texts)
print("deduped:", dedupe(texts, threshold=0.8))
