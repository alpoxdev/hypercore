---
title: Use Type-Safe Path Params with useParams and getRouteApi
impact: HIGH
impactDescription: ensures correct param types across code-split components
tags: routing, path-params, useParams, getRouteApi, type-safety
---

## useParams와 getRouteApi로 타입 안전한 Path Params

TanStack Router의 `useParams`와 `getRouteApi`로 동적 라우트 파라미터를 타입 안전하게 접근합니다.

**❌ 잘못된 예시 (타입 안전성 없음):**

```tsx
// strict: false는 타입 추론 약화
function PostDetail() {
  const params = useParams({ strict: false })
  const postId = params.postId  // any 타입
}
```

**✅ 올바른 예시 (Route 바인딩):**

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // params.postId는 string 타입으로 자동 추론
    return { post: await getPost(params.postId) }
  },
  component: PostDetail,
})

function PostDetail() {
  // Route에 바인딩된 useParams - 완전한 타입 추론
  const { postId } = Route.useParams()
  const { post } = Route.useLoaderData()

  return <div>{post.title}</div>
}
```

**✅ 올바른 예시 (getRouteApi - 코드 스플릿 컴포넌트):**

```tsx
// components/PostDetail.tsx (별도 파일)
import { getRouteApi } from '@tanstack/react-router'

// Route import 없이 타입 안전하게 접근
const routeApi = getRouteApi('/posts/$postId')

export function PostDetail() {
  const { postId } = routeApi.useParams()
  const { post } = routeApi.useLoaderData()
  const search = routeApi.useSearch()
  const context = routeApi.useRouteContext()

  return <div>{post.title}</div>
}
```

**select로 리렌더 최적화:**

```tsx
// postId만 변경 시 리렌더
const postId = useParams({
  from: '/posts/$postId',
  select: (params) => params.postId,
})
```

**from으로 타입 컨텍스트 지정:**

```tsx
// 다른 라우트의 params 접근
const { postId } = useParams({ from: '/posts/$postId' })

// 현재 라우트 컨텍스트에서 접근 (Route 바인딩)
const { postId } = Route.useParams()
```

**타입 안전성 순위:**
1. `Route.useParams()` - 라우트에 직접 바인딩, 최고 타입 안전성
2. `getRouteApi('/path').useParams()` - 코드 스플릿 시 사용, 순환 의존성 방지
3. `useParams({ from: '/path' })` - from으로 타입 컨텍스트 지정
4. `useParams({ strict: false })` - 전역 접근, 타입 약화 (비권장)

참고: [Path Params Guide](https://tanstack.com/router/latest/docs/framework/react/guide/path-params), [getRouteApi](https://tanstack.com/router/latest/docs/framework/react/api/router/getRouteApiFunction)
