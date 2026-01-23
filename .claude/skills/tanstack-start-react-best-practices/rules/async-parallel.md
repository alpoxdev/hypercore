---
title: Promise.all() for Independent Operations
impact: CRITICAL
impactDescription: 2-10× improvement
tags: async, parallelization, promises, waterfalls
---

## 독립적인 작업에 Promise.all() 사용하기

비동기 작업들이 서로 의존성이 없을 때는 `Promise.all()`을 사용하여 동시에 실행합니다.

**❌ 잘못된 예시 (순차 실행, 3번의 라운드 트립):**

```typescript
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()
```

**✅ 올바른 예시 (병렬 실행, 1번의 라운드 트립):**

```typescript
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```
