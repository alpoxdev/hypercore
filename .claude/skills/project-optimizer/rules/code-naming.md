---
title: Use Intent-Revealing Names
impact: MEDIUM
impactDescription: Self-documenting code, reduced cognitive load
tags: code, naming, readability, maintainability
languages: all
related: [code-complexity, dx-type-safety]
---

## 의도를 드러내는 이름 사용

변수/함수/클래스 이름만으로 역할과 의도를 파악할 수 있게 합니다.

**❌ 잘못된 예시:**

```python
d = {}          # 무엇의 딕셔너리?
tmp = get()     # 임시? 무엇을 가져옴?
flag = True     # 어떤 플래그?
def proc(x):    # 무엇을 처리?
    pass

for i in lst:   # i와 lst가 무엇?
    if i.s == 1:  # s가 무엇? 1이 무엇?
        do(i)
```

**✅ 올바른 예시:**

```python
user_scores = {}
active_user = get_current_user()
is_premium = True
def calculate_shipping_cost(order):
    pass

STATUS_ACTIVE = 1
for user in users:
    if user.status == STATUS_ACTIVE:
        send_notification(user)
```

**명명 패턴:**

| 유형 | 패턴 | 예시 |
|------|------|------|
| **Boolean** | `is_`, `has_`, `can_`, `should_` | `is_valid`, `has_permission` |
| **함수** | 동사 + 목적어 | `calculate_total`, `send_email` |
| **컬렉션** | 복수형 | `users`, `order_items` |
| **맵/딕셔너리** | `x_by_y` | `user_by_id`, `orders_by_date` |
| **상수** | `UPPER_SNAKE` | `MAX_RETRY_COUNT` |
| **축약 금지** | 풀네임 사용 | `transaction` (not `txn`) |
