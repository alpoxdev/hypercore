# 라우트 구조

> Vite + TanStack Router 파일 기반 라우팅

---

## 라우트 폴더 구조

```
routes/
├── __root.tsx           # 루트 레이아웃
├── index.tsx            # / (홈)
├── users/
│   ├── index.tsx        # /users (목록)
│   ├── $id.tsx          # /users/:id (상세)
│   ├── -components/     # 페이지 전용 컴포넌트 (필수)
│   ├── -hooks/          # 페이지 전용 훅 (필수)
│   └── -sections/       # 섹션 분리 (선택, 복잡한 페이지만)
└── posts/
    ├── index.tsx
    ├── $slug.tsx
    ├── -components/     # 필수
    └── -hooks/          # 필수
```

| 접두사 | 용도 | 라우트 생성 |
|--------|---------|-----------------|
| `-` | 라우트 제외 폴더 | 제외됨 |
| `$` | 동적 파라미터 | 생성됨 |
| `_` | Pathless 레이아웃 | 생성됨 (경로 없음) |

**필수 규칙:**
- 모든 페이지는 `-components/`, `-hooks/` 폴더가 있어야 함
- `-functions/` 폴더 없음 (Vite에는 서버 함수 없음)
- 커스텀 훅은 **페이지 크기와 무관하게** 반드시 `-hooks/` 폴더로 분리
- `-sections/`는 선택사항, 복잡한 페이지(200줄 이상)만

---

## 라우트 파일명 규칙

| 경로 | 파일명 | 설명 |
|------|----------|-------------|
| `/` | `index.tsx` | 인덱스 라우트 |
| `/users` | `users/index.tsx` | 목록 페이지 |
| `/users/:id` | `users/$id.tsx` | 동적 파라미터 |
| `/dashboard/*` | `dashboard/$.tsx` | 캐치올 라우트 |
| 레이아웃 | `__root.tsx` | 루트 레이아웃 |
| Pathless | `_layout.tsx` | Pathless 레이아웃 |

---

## 기본 라우트 패턴

```tsx
// routes/users/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { UserListSection } from './-sections/user-list-section'

export const Route = createFileRoute('/users/')({
  component: UsersPage,
})

const UsersPage = (): JSX.Element => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Users</h1>
      <UserListSection />
    </div>
  )
}
```

## 로더 패턴 (클라이언트 사이드 프리페치)

> Vite의 로더는 클라이언트에서 실행됩니다. `ensureQueryData`로 TanStack Query 데이터를 프리페치하세요.

```tsx
// routes/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router'
import { userQueryOptions } from '@/services/user/queries'

export const Route = createFileRoute('/users/$id')({
  loader: ({ params: { id }, context: { queryClient } }) =>
    queryClient.ensureQueryData(userQueryOptions(id)),
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const { id } = Route.useParams()
  const { data: user } = useQuery(userQueryOptions(id))
  return (
    <div>
      <h1>{user?.name}</h1>
      <p>{user?.email}</p>
    </div>
  )
}
```

---

## 검색 파라미터 검증

> `@tanstack/zod-adapter`로 타입 안전한 검색 파라미터

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { zodValidator, fallback } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({
  page: fallback(z.number().int().positive(), 1),
  filter: z.string().optional(),
  sortBy: z.enum(['newest', 'oldest', 'price']).default('newest'),
})

export const Route = createFileRoute('/products/')({
  validateSearch: zodValidator(searchSchema),
  component: ProductsPage,
})
```

| API | 출처 | 용도 |
|-----|--------|---------|
| `zodValidator` | `@tanstack/zod-adapter` | 검색 파라미터 스키마 검증 |
| `fallback` | `@tanstack/zod-adapter` | 잘못된 파라미터 기본값 |
| `Route.useSearch()` | `@tanstack/react-router` | 검증된 검색 파라미터 접근 |
| `Route.useNavigate()` | `@tanstack/react-router` | 검색 파라미터 업데이트로 탐색 |

---

## 라우트 옵션: 로딩 & 에러 상태

```tsx
export const Route = createFileRoute('/posts/')({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(postsQueryOptions()),
  pendingComponent: () => <div>Loading posts...</div>,
  errorComponent: ({ error }) => (
    <div>
      <h2>에러</h2>
      <p>{error.message}</p>
    </div>
  ),
  component: PostsPage,
})
```

| 라우트 옵션 | 용도 | 필수 여부 |
|--------------|---------|----------|
| `pendingComponent` | 로더 실행 중 로딩 UI | 권장 |
| `errorComponent` | 로더/컴포넌트 실패 시 에러 UI | 필수 |
| `notFoundComponent` | 404 UI (루트 라우트) | `__root.tsx`에 필수 |
| `validateSearch` | 검색 파라미터 검증 | 검색 파라미터 사용 시 |

---

## 인증 가드 패턴 (beforeLoad)

```tsx
// routes/dashboard/route.tsx
import { createFileRoute, redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }
  },
})
```

---

## 로더 실행 순서

| 단계 | 실행 | 설명 |
|------|-----------|-------------|
| 0. `validateSearch` | 탐색 전 | 검색 파라미터 검증 |
| 1. `beforeLoad` | 순차 (바깥 -> 안) | 인증 확인, 리다이렉트 |
| 2. `loader` | 병렬 (모든 로더 동시) | 쿼리 프리페치 |

---

## 폴더 구조 규칙

| 페이지 크기 | 필수 | 선택 |
|-----------|----------|----------|
| ~100줄 | `-components/`, `-hooks/` | - |
| 100-200줄 | `-components/`, `-hooks/` | - |
| 200줄+ | `-components/`, `-hooks/` | `-sections/` |
