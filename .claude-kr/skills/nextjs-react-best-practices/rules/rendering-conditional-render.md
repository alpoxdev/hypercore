---
title: Use Explicit Conditional Rendering
impact: LOW
impactDescription: prevents rendering 0 or NaN
tags: rendering, conditional, jsx, falsy-values
---

## 명시적 조건부 렌더링 사용

조건이 `0`, `NaN` 또는 렌더링되는 다른 falsy 값일 수 있는 경우, 조건부 렌더링에 `&&` 대신 명시적인 삼항 연산자(`? :`)를 사용하세요.

**❌ 잘못된 예시 (count가 0일 때 "0"을 렌더링):**

```tsx
function Badge({ count }: { count: number }) {
  return (
    <div>
      {count && <span className="badge">{count}</span>}
    </div>
  )
}

// count = 0일 때 렌더링: <div>0</div>
// count = 5일 때 렌더링: <div><span class="badge">5</span></div>
```

**✅ 올바른 예시 (count가 0일 때 아무것도 렌더링하지 않음):**

```tsx
function Badge({ count }: { count: number }) {
  return (
    <div>
      {count > 0 ? <span className="badge">{count}</span> : null}
    </div>
  )
}

// count = 0일 때 렌더링: <div></div>
// count = 5일 때 렌더링: <div><span class="badge">5</span></div>
```
