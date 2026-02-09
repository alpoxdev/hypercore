---
title: Follow File-Based Routing Conventions
impact: HIGH
impactDescription: ensures correct route generation and code splitting
tags: routing, file-conventions, file-based-routing, code-splitting
---

## 파일 기반 라우팅 컨벤션

TanStack Router의 파일 이름 컨벤션을 따르면 라우트 트리가 자동 생성됩니다.

**파일 이름 규칙:**

| 패턴 | 파일명 | URL | 설명 |
|------|--------|-----|------|
| **Root** | `__root.tsx` | - | 앱 최상위 레이아웃 (필수) |
| **Index** | `index.tsx` | `/` | 디렉토리 인덱스 |
| **Static** | `about.tsx` | `/about` | 정적 경로 |
| **Dynamic** | `$postId.tsx` | `/posts/:postId` | 동적 파라미터 |
| **Pathless Layout** | `_layout.tsx` | - | URL 없는 레이아웃 래퍼 |
| **Route Group** | `(group)/` | - | 파일 정리용 (URL 영향 없음) |
| **Excluded** | `-helpers.tsx` | - | 라우트 생성 제외 |
| **Lazy** | `route.lazy.tsx` | - | 코드 스플릿 컴포넌트 |

**디렉토리 구조 예시:**

```
src/routes/
├── __root.tsx                 # 루트 레이아웃 (필수)
├── index.tsx                  # / (홈)
├── about.tsx                  # /about
├── posts.tsx                  # /posts (레이아웃)
├── posts/
│   ├── index.tsx              # /posts (목록)
│   └── $postId.tsx            # /posts/:postId
├── _authenticated.tsx         # pathless 인증 가드
├── _authenticated/
│   ├── dashboard.tsx          # /dashboard
│   └── settings.tsx           # /settings
├── (marketing)/               # route group (정리용)
│   ├── pricing.tsx            # /pricing
│   └── features.tsx           # /features
└── -components/               # 제외 (라우트 아님)
    └── Sidebar.tsx
```

**코드 스플리팅 (lazy route):**

```tsx
// src/routes/posts.$postId.tsx - 크리티컬 설정만
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    return { post: await fetchPost(params.postId) }
  },
  validateSearch: zodValidator(searchSchema),
  beforeLoad: async ({ context }) => { /* auth */ },
})

// src/routes/posts.$postId.lazy.tsx - 컴포넌트만 (코드 스플릿)
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/posts/$postId')({
  component: PostDetail,
  pendingComponent: PostSkeleton,
  errorComponent: PostError,
})
```

**Flat vs Directory 스타일:**

```
# Flat (점 구분자)
posts.tsx                → /posts
posts.index.tsx          → /posts (index)
posts.$postId.tsx        → /posts/:postId

# Directory (폴더)
posts/
  route.tsx              → /posts
  index.tsx              → /posts (index)
  $postId.tsx            → /posts/:postId
```

**tsr.config.json 설정:**

```json
{
  "routesDirectory": "./src/routes",
  "generatedRouteTree": "./src/routeTree.gen.ts",
  "routeFileIgnorePrefix": "-",
  "indexToken": "index",
  "routeToken": "route"
}
```

**주의사항:**
- `routeTree.gen.ts`는 자동 생성 파일 → 직접 수정 금지
- `__root.tsx`는 반드시 존재해야 함
- `_prefix`는 pathless layout, `(group)`은 정리 전용 (레이아웃 불가)
- lazy 파일에는 `loader`, `beforeLoad`, `validateSearch` 넣지 않음

참고: [File-Based Routing](https://tanstack.com/router/latest/docs/framework/react/routing/file-based-routing), [File Naming Conventions](https://tanstack.com/router/latest/docs/framework/react/routing/file-naming-conventions)
