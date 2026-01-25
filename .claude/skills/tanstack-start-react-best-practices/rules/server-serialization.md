---
title: Minimize Serialization at RSC Boundaries
impact: HIGH
impactDescription: reduces data transfer size
tags: server, rsc, serialization, props
---

## RSC 경계에서 직렬화 최소화

React Server/Client 경계는 모든 객체 속성을 문자열로 직렬화하여 HTML 응답 및 후속 RSC 요청에 포함합니다. 이 직렬화된 데이터는 페이지 가중치와 로드 시간에 직접 영향을 미치므로 **크기가 매우 중요합니다**. 클라이언트가 실제로 사용하는 필드만 전달하세요.

**❌ 잘못된 예시 (50개 필드 모두 직렬화):**

```tsx
async function Page() {
  const user = await fetchUser()  // 50개 필드
  return <Profile user={user} />
}

'use client'
function Profile({ user }: { user: User }) {
  return <div>{user.name}</div>  // 1개 필드만 사용
}
```

**✅ 올바른 예시 (1개 필드만 직렬화):**

```tsx
async function Page() {
  const user = await fetchUser()
  return <Profile name={user.name} />
}

'use client'
function Profile({ name }: { name: string }) {
  return <div>{name}</div>
}
```
