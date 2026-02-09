---
title: Reduce Cyclomatic Complexity
impact: MEDIUM
impactDescription: Easier testing, fewer bugs, better readability
tags: code, complexity, early-return, guard-clause, extract
languages: all
related: [code-duplication, code-error-handling]
---

## 순환 복잡도 감소

깊은 중첩, 긴 if-else 체인, 복잡한 조건문을 단순화합니다.

**❌ 잘못된 예시 (깊은 중첩):**

```python
def process(request):
    if request:
        if request.user:
            if request.user.is_active:
                if request.data:
                    return do_work(request.data)
                else:
                    return Error("no data")
            else:
                return Error("inactive")
        else:
            return Error("no user")
    else:
        return Error("no request")
```

**✅ 올바른 예시 (guard clause + early return):**

```python
def process(request):
    if not request:
        return Error("no request")
    if not request.user:
        return Error("no user")
    if not request.user.is_active:
        return Error("inactive")
    if not request.data:
        return Error("no data")
    return do_work(request.data)
```

**✅ 올바른 예시 (table-driven):**

```python
# ❌ 긴 if-else 체인
def get_discount(tier):
    if tier == "bronze": return 0.05
    elif tier == "silver": return 0.10
    elif tier == "gold": return 0.15
    elif tier == "platinum": return 0.20
    else: return 0

# ✅ 맵/딕셔너리
DISCOUNTS = {"bronze": 0.05, "silver": 0.10, "gold": 0.15, "platinum": 0.20}
def get_discount(tier):
    return DISCOUNTS.get(tier, 0)
```

**목표:** 함수당 순환 복잡도 10 이하, 중첩 깊이 3 이하.
