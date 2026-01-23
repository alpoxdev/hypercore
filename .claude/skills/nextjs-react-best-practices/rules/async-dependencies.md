---
title: Dependency-Based Parallelization
impact: CRITICAL
impactDescription: 2-10× improvement
tags: async, parallelization, dependencies, better-all
---

## 의존성 기반 병렬화

부분적으로 의존성이 있는 작업의 경우 `better-all`을 사용하여 병렬성을 최대화합니다. 각 작업을 가능한 빠른 시점에 자동으로 시작합니다.

**잘못된 예 (profile이 불필요하게 config를 기다림):**

```typescript
const [user, config] = await Promise.all([
  fetchUser(),
  fetchConfig()
])
const profile = await fetchProfile(user.id)
```

**올바른 예 (config와 profile이 병렬로 실행됨):**

```typescript
import { all } from 'better-all'

const { user, config, profile } = await all({
  async user() { return fetchUser() },
  async config() { return fetchConfig() },
  async profile() {
    return fetchProfile((await this.$.user).id)
  }
})
```

참고: [https://github.com/shuding/better-all](https://github.com/shuding/better-all)
