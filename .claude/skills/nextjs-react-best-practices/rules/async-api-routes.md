---
title: Prevent Waterfall Chains in API Routes
impact: CRITICAL
impactDescription: 2-10× improvement
tags: api-routes, server-actions, waterfalls, parallelization
---

## API 라우트에서 워터폴 체인 방지

API 라우트와 Server Actions에서는 아직 await하지 않더라도 독립적인 작업을 즉시 시작합니다.

**잘못된 예 (config가 auth를 기다리고, data가 둘 다 기다림):**

```typescript
export async function GET(request: Request) {
  const session = await auth()
  const config = await fetchConfig()
  const data = await fetchData(session.user.id)
  return Response.json({ data, config })
}
```

**올바른 예 (auth와 config가 즉시 시작됨):**

```typescript
export async function GET(request: Request) {
  const sessionPromise = auth()
  const configPromise = fetchConfig()
  const session = await sessionPromise
  const [config, data] = await Promise.all([
    configPromise,
    fetchData(session.user.id)
  ])
  return Response.json({ data, config })
}
```

더 복잡한 의존성 체인을 가진 작업의 경우, `better-all`을 사용하여 자동으로 병렬성을 최대화할 수 있습니다 (의존성 기반 병렬화 참조).
