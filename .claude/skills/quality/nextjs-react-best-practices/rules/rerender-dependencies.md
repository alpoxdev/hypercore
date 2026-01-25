---
title: Narrow Effect Dependencies
impact: LOW
impactDescription: minimizes effect re-runs
tags: rerender, useEffect, dependencies, optimization
---

## Effect 의존성 좁히기

객체 대신 원시 타입 의존성을 지정하여 effect 재실행을 최소화하세요.

**❌ 잘못된 예시 (user의 모든 필드 변경 시 재실행):**

```tsx
useEffect(() => {
  console.log(user.id)
}, [user])
```

**✅ 올바른 예시 (id 변경 시에만 재실행):**

```tsx
useEffect(() => {
  console.log(user.id)
}, [user.id])
```

**파생 상태의 경우, effect 밖에서 계산:**

```tsx
// ❌ 잘못된 예시: width=767, 766, 765... 모든 변경 시 실행
useEffect(() => {
  if (width < 768) {
    enableMobileMode()
  }
}, [width])

// ✅ 올바른 예시: boolean 전환 시에만 실행
const isMobile = width < 768
useEffect(() => {
  if (isMobile) {
    enableMobileMode()
  }
}, [isMobile])
```
