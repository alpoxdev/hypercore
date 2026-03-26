# 라우트 구조

> TanStack Start 파일 기반 라우팅

---

## 라우트 폴더 구조

```
routes/
├── __root.tsx           # Root Layout
├── index.tsx            # / (Home)
├── users/
│   ├── index.tsx        # /users (List)
│   ├── $id.tsx          # /users/:id (Detail)
│   ├── -components/     # 페이지 전용 컴포넌트 (필수)
│   ├── -hooks/          # 페이지 전용 Hook (필수)
│   ├── -functions/      # 페이지 전용 Server Functions (필수)
│   └── -sections/       # 섹션 분리 (선택, 복잡한 경우만)
└── posts/
    ├── index.tsx
    ├── $slug.tsx
    ├── -components/     # 필수
    ├── -hooks/          # 필수
    └── -functions/      # 필수
```

| 접두사 | 용도 | 라우트 생성 |
|--------|------|-----------|
| `-` | 라우트 제외 폴더 | 제외 |
| `$` | 동적 파라미터 | 생성 |
| `_` | Pathless Layout | 생성 (경로 없음) |

**필수 규칙:**
- **로직이 있는** 모든 페이지에 `-components/`, `-hooks/`, `-functions/` 폴더 **필수**
- **단순 퍼블리싱 예외:** 인터랙티브 로직도 없고 서버 연동도 없이 정적 콘텐츠만 표시하는 페이지는 이 폴더들이 **필요 없습니다**. 예시: about, terms, privacy policy, 단순 마케팅 페이지.
- **서버 연동 = 폴더 필수:** 페이지에 서버 연동이 하나라도 있으면(loader에서 서버 함수 호출, `useQuery`, `useMutation`, `useServerFn`) → `-functions/`와 `-hooks/`는 **반드시** 생성
- 인터랙티브 UI 로직(`useState`, `useCallback`, 커스텀 훅)이 있으면 페이지 크기와 무관하게 세 폴더 모두 필수
- Custom Hook은 반드시 `-hooks/` 폴더에 분리
- `-sections/`는 200줄 이상 복잡한 페이지에서만 선택적 사용
- **자동 셋업:** TanStack Start 프로젝트에 라우트가 있지만 필수 폴더가 없으면, 코드 작성 전에 생성

---

## 라우트 파일명 규칙

| 경로 | 파일명 | 설명 |
|------|--------|------|
| `/` | `index.tsx` | 인덱스 라우트 |
| `/users` | `users/index.tsx` | 목록 페이지 |
| `/users/:id` | `users/$id.tsx` | 동적 파라미터 |
| `/dashboard/*` | `dashboard/$.tsx` | Catch-all 라우트 |
| Layout | `__root.tsx` | Root 레이아웃 |
| Pathless | `_layout.tsx` | 경로 없는 레이아웃 |

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

## 동적 라우트 + Loader

```tsx
// routes/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getUserById } from '@/services/user'

export const Route = createFileRoute('/users/$id')({
  loader: ({ params: { id } }) => getUserById({ data: id }),
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const user = Route.useLoaderData()
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

## Deferred Data Loading

```tsx
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

export const Route = createFileRoute('/dashboard/')({
  loader: async () => {
    const slowDataPromise = getSlowData()
    const fastData = await getFastData()
    return { fastData, deferredSlowData: slowDataPromise }
  },
  component: DashboardPage,
})

const DashboardPage = (): JSX.Element => {
  const { fastData, deferredSlowData } = Route.useLoaderData()
  return (
    <div>
      <div>{JSON.stringify(fastData)}</div>
      <Suspense fallback={<div>Loading...</div>}>
        <Await promise={deferredSlowData}>
          {(data) => <div>{JSON.stringify(data)}</div>}
        </Await>
      </Suspense>
    </div>
  )
}
```

---

## 검색 파라미터 검증

> `@tanstack/zod-adapter`를 사용한 타입 안전 검색 파라미터

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

const ProductsPage = (): JSX.Element => {
  const { page, filter, sortBy } = Route.useSearch()
  const navigate = Route.useNavigate()

  return (
    <div>
      <select
        value={sortBy}
        onChange={(e) =>
          navigate({
            search: (prev) => ({ ...prev, sortBy: e.target.value as 'newest' | 'oldest' | 'price' }),
          })
        }
      >
        <option value="newest">최신순</option>
        <option value="oldest">오래된순</option>
        <option value="price">가격순</option>
      </select>
    </div>
  )
}
```

| API | 출처 | 용도 |
|-----|------|------|
| `zodValidator` | `@tanstack/zod-adapter` | 검색 파라미터 스키마 검증 |
| `fallback` | `@tanstack/zod-adapter` | 유효하지 않은 파라미터의 기본값 |
| `Route.useSearch()` | `@tanstack/react-router` | 검증된 검색 파라미터 접근 |
| `Route.useNavigate()` | `@tanstack/react-router` | 검색 파라미터 업데이트 네비게이션 |

---

## 라우트 옵션: 로딩 & 에러 상태

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/')({
  loader: async () => {
    const response = await fetch('https://api.example.com/posts')
    if (!response.ok) throw new Error('Failed to fetch')
    return response.json()
  },
  pendingComponent: () => <div>게시물 로딩 중...</div>,
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
|-------------|------|----------|
| `pendingComponent` | loader 실행 중 로딩 UI | 권장 |
| `errorComponent` | loader/컴포넌트 실패 시 에러 UI | 필수 |
| `notFoundComponent` | 404 UI (루트 라우트) | `__root.tsx`에 필수 |
| `validateSearch` | 검색 파라미터 검증 | 검색 파라미터 사용 시 |

---

## Loader 실행 순서

| 단계 | 실행 방식 | 설명 |
|------|----------|------|
| 0. `validateSearch` | 네비게이션 전 | 검색 파라미터 검증 |
| 1. `beforeLoad` | 순차 (outermost -> innermost) | 인증 체크, 컨텍스트 설정 |
| 2. `loader` | 병렬 (모든 loader 동시) | 데이터 페칭 |

---

## 폴더 구조 규칙

| 페이지 유형 | 필수 | 선택 |
|------------|------|------|
| 단순 퍼블리싱 (정적 콘텐츠, 로직 없음) | 없음 | - |
| 로직 있는 페이지 (~100줄) | `-components/`, `-hooks/`, `-functions/` | - |
| 로직 있는 페이지 (100-200줄) | `-components/`, `-hooks/`, `-functions/` | - |
| 로직 있는 페이지 (200줄+) | `-components/`, `-hooks/`, `-functions/` | `-sections/` |

> **단순 퍼블리싱** = `useState`, `useCallback`, 커스텀 훅, 서버 함수 호출 없음. 정적/서버 페치 콘텐츠만 표시. 로직이 **하나라도** 있으면 세 폴더 모두 필수.
