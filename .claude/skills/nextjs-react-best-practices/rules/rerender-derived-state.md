---
title: Subscribe to Derived State
impact: MEDIUM
impactDescription: reduces re-render frequency
tags: rerender, derived-state, media-query, optimization
---

## 파생 상태 구독

연속적인 값 대신 파생된 boolean 상태를 구독하여 리렌더링 빈도를 줄이세요.

**❌ 잘못된 예시 (픽셀 변경마다 리렌더링):**

```tsx
function Sidebar() {
  const width = useWindowWidth()  // 연속적으로 업데이트
  const isMobile = width < 768
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}
```

**✅ 올바른 예시 (boolean 변경 시에만 리렌더링):**

```tsx
function Sidebar() {
  const isMobile = useMediaQuery('(max-width: 767px)')
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}
```
