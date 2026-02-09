---
title: Preload Routes on User Intent for Instant Navigation
impact: MEDIUM-HIGH
impactDescription: eliminates perceived loading time on navigation
tags: routing, preload, performance, link, UX
---

## 사용자 의도 기반 라우트 프리로딩

`preload="intent"`로 hover/touch 시 라우트 데이터를 미리 로드하여 즉각적인 네비게이션을 구현합니다.

**❌ 잘못된 예시 (프리로딩 없음):**

```tsx
// 클릭 후 loader 실행 → 사용자 대기
<Link to="/posts/$postId" params={{ postId: '123' }}>
  View Post
</Link>
```

**✅ 올바른 예시 (intent 프리로딩):**

```tsx
// hover 시 미리 loader 실행 → 클릭 시 즉시 렌더링
<Link
  to="/posts/$postId"
  params={{ postId: '123' }}
  preload="intent"
>
  View Post
</Link>
```

**Router 레벨 기본값 설정:**

```tsx
const router = createRouter({
  routeTree,
  defaultPreload: 'intent',          // 전역 기본값
  defaultPreloadDelay: 50,           // hover 후 50ms 대기
  defaultPreloadStaleTime: 30_000,   // 프리로드 데이터 30초간 fresh
})
```

**프리로딩 모드:**

| 모드 | 트리거 | 사용 시점 |
|------|--------|---------|
| `'intent'` | hover/touch 50ms 후 | 일반적인 네비게이션 링크 (권장) |
| `'viewport'` | 뷰포트 진입 시 | 목록 페이지, 무한 스크롤 |
| `'render'` | 컴포넌트 마운트 시 | 확실히 이동할 링크 |
| `false` | 비활성 | 인증/외부 링크 |

**Link별 오버라이드:**

```tsx
// 목록 아이템은 viewport 프리로딩
{posts.map(post => (
  <Link
    key={post.id}
    to="/posts/$postId"
    params={{ postId: post.id }}
    preload="viewport"
  >
    {post.title}
  </Link>
))}

// 특정 링크는 프리로딩 비활성
<Link to="/settings" preload={false}>
  Settings
</Link>
```

**프로그래밍 방식 프리로딩:**

```tsx
const router = useRouter()

// 검색 결과 hover 시 수동 프리로드
const handleMouseEnter = (postId: string) => {
  router.preloadRoute({
    to: '/posts/$postId',
    params: { postId },
  })
}
```

**캐싱:** 프리로드된 데이터는 기본 30초(`defaultPreloadStaleTime`) 동안 fresh 상태로 유지됩니다.

참고: [Preloading Guide](https://tanstack.com/router/latest/docs/framework/react/guide/preloading)
