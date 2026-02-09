---
title: Minimize Serialization in Loader Data
impact: HIGH
impactDescription: reduces data transfer size
tags: server, loader, serialization, tanstack-start
---

## Loader 데이터 직렬화 최소화

TanStack Start의 loader에서 반환하는 데이터는 서버 → 클라이언트로 직렬화되어 전달됩니다. 이 직렬화된 데이터는 HTML 응답 크기와 하이드레이션 시간에 직접 영향을 미치므로 **클라이언트가 실제로 사용하는 필드만 반환하세요**.

**❌ 잘못된 예시 (50개 필드 모두 직렬화):**

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

const getUser = createServerFn().handler(async () => {
  return await db.user.findUnique({ where: { id: '1' } }) // 50개 필드
})

export const Route = createFileRoute('/profile')({
  loader: async () => {
    const user = await getUser()
    return { user } // 50개 필드 모두 직렬화
  }
})

function ProfilePage() {
  const { user } = Route.useLoaderData()
  return <div>{user.name}</div> // 1개 필드만 사용
}
```

**✅ 올바른 예시 (필요한 필드만 직렬화):**

```typescript
const getUser = createServerFn().handler(async () => {
  const user = await db.user.findUnique({ where: { id: '1' } })
  return { name: user.name, email: user.email } // 필요한 필드만
})

export const Route = createFileRoute('/profile')({
  loader: async () => {
    const user = await getUser()
    return { userName: user.name, userEmail: user.email }
  }
})

function ProfilePage() {
  const { userName, userEmail } = Route.useLoaderData()
  return (
    <div>
      <div>{userName}</div>
      <div>{userEmail}</div>
    </div>
  )
}
```

**✅ Server Function에서 select로 필드 제한:**

```typescript
const getUser = createServerFn().handler(async () => {
  // DB 쿼리 자체에서 필드 제한 (가장 효율적)
  return await db.user.findUnique({
    where: { id: '1' },
    select: { name: true, email: true, avatar: true }
  })
})
```

loader 데이터가 클수록 SSR HTML 크기, 하이드레이션 시간, 클라이언트 네비게이션 데이터 전송량이 모두 증가합니다.
