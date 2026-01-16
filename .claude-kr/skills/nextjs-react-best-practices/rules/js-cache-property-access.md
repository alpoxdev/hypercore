---
title: Cache Property Access in Loops
impact: LOW-MEDIUM
impactDescription: reduces lookups
tags: javascript, loops, optimization, caching
---

## 루프에서 프로퍼티 접근 캐싱

핫 패스에서 객체 프로퍼티 조회를 캐시하세요.

**❌ 잘못된 예시 (3번 조회 × N번 반복):**

```typescript
for (let i = 0; i < arr.length; i++) {
  process(obj.config.settings.value)
}
```

**✅ 올바른 예시 (총 1번 조회):**

```typescript
const value = obj.config.settings.value
const len = arr.length
for (let i = 0; i < len; i++) {
  process(value)
}
```
