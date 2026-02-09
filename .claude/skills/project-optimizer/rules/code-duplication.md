---
title: Extract Duplicated Code (Rule of Three)
impact: MEDIUM
impactDescription: Reduced maintenance burden, single source of truth
tags: code, duplication, dry, extract, refactor
languages: all
related: [code-complexity, arch-interface-segregation]
---

## 중복 코드 추출 (3회 이상부터)

동일/유사 코드가 3회 이상 반복되면 함수/모듈로 추출합니다. 2회까지는 허용 (premature abstraction 방지).

**❌ 잘못된 예시 (3곳에서 반복):**

```python
# file_a.py
data = json.loads(response.text)
if "error" in data:
    logger.error(f"API error: {data['error']}")
    raise ApiError(data["error"])

# file_b.py (동일 패턴 반복)
data = json.loads(response.text)
if "error" in data:
    logger.error(f"API error: {data['error']}")
    raise ApiError(data["error"])
```

**✅ 올바른 예시 (추출):**

```python
# utils/api.py
def parse_api_response(response: Response) -> dict:
    data = response.json()
    if "error" in data:
        logger.error(f"API error: {data['error']}")
        raise ApiError(data["error"])
    return data

# file_a.py, file_b.py
data = parse_api_response(response)
```

**감지 도구:**

| 언어 | 도구 |
|------|------|
| **범용** | `jscpd` (Copy/Paste Detector) |
| **Python** | `pylint --disable=all --enable=duplicate-code` |
| **Java** | PMD CPD |
| **Go** | `dupl` |

**주의:** 비슷해 보이지만 다른 의도의 코드는 추출하지 않음. 추상화 비용 > 중복 비용이면 중복 허용.
