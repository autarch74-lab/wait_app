# backend/deduper/deduper.py
from typing import List

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


def dedupe(texts: List[str], threshold: float = 0.85) -> List[str]:
    """
    TF-IDF + cosine similarity 기반 중복 제거.
    token_pattern을 변경해 한 글자 토큰도 포함하도록 함.
    모든 토큰이 제거되어 벡터가 0인 경우에는 문자열 동일성으로 판단.
    """
    if not texts:
        return []

    # 한 글자 토큰도 포함하도록 token_pattern 변경
    vec = TfidfVectorizer(token_pattern=r"(?u)\b\w+\b").fit_transform(texts)

    # 한 개만 있으면 그대로 반환
    if vec.shape[0] == 1:
        return texts

    sim = cosine_similarity(vec)
    keep: List[str] = []
    removed = set()

    for i in range(len(texts)):
        if i in removed:
            continue
        keep.append(texts[i])
        for j in range(i + 1, len(texts)):
            if j in removed:
                continue

            # 둘 다 영벡터인 경우 문자열 동일성으로 판단
            if vec[i].nnz == 0 and vec[j].nnz == 0:
                if texts[i].strip() == texts[j].strip():
                    removed.add(j)
                continue

            if sim[i, j] >= threshold:
                removed.add(j)

    return keep
