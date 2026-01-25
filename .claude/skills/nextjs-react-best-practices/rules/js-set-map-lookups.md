---
title: Use Set/Map for O(1) Lookups
impact: LOW-MEDIUM
impactDescription: O(n) to O(1)
tags: javascript, set, map, data-structures, performance
---

## O(1) 조회를 위해 Set/Map 사용

반복적인 멤버십 검사를 위해 배열을 Set/Map으로 변환하세요.

**❌ 잘못된 예 (검사마다 O(n)):**

```typescript
const allowedIds = ['a', 'b', 'c', ...]
items.filter(item => allowedIds.includes(item.id))
```

**✅ 올바른 예 (검사마다 O(1)):**

```typescript
const allowedIds = new Set(['a', 'b', 'c', ...])
items.filter(item => allowedIds.has(item.id))
```
