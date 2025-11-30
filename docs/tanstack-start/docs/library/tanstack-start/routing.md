# TanStack Start - Routing

> **상위 문서**: [TanStack Start](./index.md)

TanStack Start는 파일 기반 라우팅을 지원합니다.

## 기본 라우트

```tsx
// routes/about.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/about')({
  component: AboutPage,
})

function AboutPage() {
  return <h1>About</h1>
}
```

## Loader를 사용한 데이터 로딩

```tsx
// routes/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: Page,
  loader: async () => {
    const res = await fetch('https://api.example.com/posts')
    return res.json()
  },
})

function Page() {
  const posts = Route.useLoaderData()
  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

## 동적 라우트

```tsx
// routes/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users/$id')({
  loader: async ({ params }) => {
    const user = await getUserById(params.id)
    return { user }
  },
  component: UserDetailPage,
})

function UserDetailPage() {
  const { user } = Route.useLoaderData()
  return <h1>{user.name}</h1>
}
```

## SSR 설정

```tsx
// routes/posts/$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  ssr: true,  // SSR 활성화
  beforeLoad: () => {
    console.log('서버에서 초기 요청 시 실행')
  },
  loader: () => {
    console.log('서버에서 초기 요청 시 실행')
  },
  component: () => <div>서버에서 렌더링됨</div>,
})
```

### SSR 옵션

```typescript
// ssr: true - 전체 SSR (기본값)
// ssr: false - 클라이언트 사이드만
// ssr: 'data-only' - 데이터만 서버에서 로드, 렌더링은 클라이언트
```

## Server Routes (API)

### 기본 API 라우트

```typescript
// routes/api/hello.ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/api/hello')({
  server: {
    handlers: {
      GET: async ({ request }) => {
        return new Response('Hello, World!')
      },
      POST: async ({ request }) => {
        const body = await request.json()
        return new Response(`Hello, ${body.name}!`)
      },
    },
  },
})
```

### JSON 응답

```typescript
import { createFileRoute } from '@tanstack/react-router'
import { json } from '@tanstack/react-start'

export const Route = createFileRoute('/api/users')({
  server: {
    handlers: {
      GET: async ({ request }) => {
        const users = await getUsers()
        return json({ users })
      },
    },
  },
})
```

## 라우트 파일 구조

```
routes/
├── __root.tsx           → Root layout
├── index.tsx            → /
├── about.tsx            → /about
├── users/
│   ├── index.tsx        → /users
│   └── $id.tsx          → /users/:id
├── posts/
│   ├── index.tsx        → /posts
│   ├── $postId.tsx      → /posts/:postId
│   └── new.tsx          → /posts/new
└── api/
    ├── hello.ts         → /api/hello
    └── users.ts         → /api/users
```

## Catch-All 라우트

```tsx
// routes/$.tsx - 모든 매칭되지 않는 경로 처리
export const Route = createFileRoute('/$')({
  component: NotFoundPage,
})

function NotFoundPage() {
  return <h1>404 - Page Not Found</h1>
}
```
