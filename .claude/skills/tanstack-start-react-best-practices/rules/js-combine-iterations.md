---
title: Combine Multiple Array Iterations
impact: LOW-MEDIUM
impactDescription: reduces iterations
tags: javascript, arrays, loops, performance
---

## 여러 배열 반복 결합

여러 개의 `.filter()` 또는 `.map()` 호출은 배열을 여러 번 반복합니다. 하나의 루프로 결합하세요.

**❌ 잘못된 예시 (3번 반복):**

```typescript
const admins = users.filter(u => u.isAdmin)
const testers = users.filter(u => u.isTester)
const inactive = users.filter(u => !u.isActive)
```

**✅ 올바른 예시 (1번 반복):**

```typescript
const admins: User[] = []
const testers: User[] = []
const inactive: User[] = []

for (const user of users) {
  if (user.isAdmin) admins.push(user)
  if (user.isTester) testers.push(user)
  if (!user.isActive) inactive.push(user)
}
```
