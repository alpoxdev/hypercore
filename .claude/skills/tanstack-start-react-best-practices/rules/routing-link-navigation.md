---
title: Use Link Component and useNavigate for Type-Safe Navigation
impact: HIGH
impactDescription: type-safe navigation prevents runtime route errors
tags: routing, navigation, link, useNavigate, type-safety
---

## Link와 useNavigate로 타입 안전한 네비게이션

TanStack Router는 `<Link>`(선언적)와 `useNavigate()`(명령적) 두 가지 네비게이션 방식을 제공합니다. 모든 라우트 경로, params, search가 자동 타입 추론됩니다.

**❌ 잘못된 예시 (타입 안전성 없는 네비게이션):**

```tsx
// 문자열 하드코딩 - 오타 감지 불가
<a href="/posts/123">Post</a>

// useNavigate에서 from 없이 사용
const navigate = useNavigate()
navigate({ to: '/posts/$postId', params: { postId: '123' } })
```

**✅ 올바른 예시 (Link 컴포넌트):**

```tsx
import { Link } from '@tanstack/react-router'

// 기본 네비게이션 - to, params 모두 타입 추론
<Link to="/posts/$postId" params={{ postId: '123' }}>
  Post Detail
</Link>

// search params 병합 (함수형 - 기존 params 유지)
<Link to="/posts" search={(prev) => ({ ...prev, page: 2 })}>
  Next Page
</Link>

// 활성 링크 스타일링
<Link
  to="/dashboard"
  activeProps={{ className: 'font-bold text-blue-600' }}
  activeOptions={{ exact: true }}
>
  Dashboard
</Link>

// 프리로딩 - hover 시 미리 로드
<Link to="/posts/$postId" params={{ postId: '123' }} preload="intent">
  View Post
</Link>
```

**✅ 올바른 예시 (useNavigate):**

```tsx
import { useNavigate } from '@tanstack/react-router'

function PostActions({ postId }: { postId: string }) {
  // from을 지정하면 상대 경로 + 타입 추론 향상
  const navigate = useNavigate({ from: '/posts/$postId' })

  const handleDelete = async () => {
    await deletePost(postId)
    navigate({ to: '/posts', replace: true })
  }

  const handleEdit = () => {
    navigate({
      to: '/posts/$postId/edit',
      params: { postId },
    })
  }

  return (
    <div>
      <button onClick={handleEdit}>Edit</button>
      <button onClick={handleDelete}>Delete</button>
    </div>
  )
}
```

**search params 주의사항:**

```tsx
// ❌ 기존 search params 덮어쓰기
<Link to="/posts" search={{ page: 2 }}>Next</Link>

// ✅ 기존 search params 유지 + 병합
<Link to="/posts" search={(prev) => ({ ...prev, page: 2 })}>Next</Link>

// ✅ 모든 search params 유지
<Link to="/about" search={true}>About</Link>
```

**activeOptions 설정:**

```tsx
<Link
  to="/products"
  search={{ category: 'electronics' }}
  activeOptions={{
    exact: false,           // 하위 경로도 활성 처리
    includeSearch: true,    // search params도 매칭 조건에 포함
  }}
  activeProps={{ className: 'active' }}
>
  Electronics
</Link>

// children render function으로 동적 콘텐츠
<Link to="/profile">
  {({ isActive }) => (
    <span className={isActive ? 'font-bold' : ''}>Profile</span>
  )}
</Link>
```

참고: [Navigation Guide](https://tanstack.com/router/latest/docs/framework/react/guide/navigation), [Link Options](https://tanstack.com/router/latest/docs/framework/react/guide/link-options)
