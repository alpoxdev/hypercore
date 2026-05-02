# API 서비스

> Vite 프로젝트 데이터 레이어 (공개 가능한 클라이언트 API 래퍼)

---

## 개요

Vite 프로젝트에는 서버 함수가 없습니다. 모든 데이터 접근은 `fetch`/`axios` 호출을 래핑하고 타입된 데이터를 반환하는 **서비스 함수**를 통해 이루어집니다. route, hook, loader는 얇게 유지하고 직접 네트워킹 대신 service/query-option 헬퍼를 호출합니다.

| 레이어 | 도구 | 용도 |
|-------|------|---------|
| 검증 | Zod 스키마 | 입력/출력 검증 |
| 쿼리 | 서비스 함수 + `useQuery` | GET 요청 |
| 뮤테이션 | 서비스 함수 + `useMutation` | POST/PUT/DELETE |
| 프리페치 | `queryClient.ensureQueryData` | 로더 프리페치 |

---

## 서비스 폴더 구조

```
services/
├── user/
│   ├── schemas.ts       # Zod 스키마 + 추론된 타입
│   ├── queries.ts       # GET 요청 + queryOptions
│   └── mutations.ts     # POST/PUT/DELETE
```

| 파일 | 용도 |
|------|---------|
| `schemas.ts` | Zod 검증 스키마 |
| `queries.ts` | GET 요청 (읽기) + queryOptions |
| `mutations.ts` | POST/PUT/DELETE (쓰기) |

서비스 함수는 `queries.ts` 또는 `mutations.ts`에서 직접 임포트하세요. `services/index.ts` 배럴 익스포트는 추가하지 않습니다.

---

## 스키마 패턴

```typescript
// services/user/schemas.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
})

export type CreateUserInput = z.infer<typeof createUserSchema>

export const userSchema = z.object({
  id: z.string(),
  email: z.email(),
  name: z.string(),
  createdAt: z.string(),
})

export type User = z.infer<typeof userSchema>
```

---

## 쿼리 패턴 (GET)

```typescript
// services/user/queries.ts
import { queryOptions } from '@tanstack/react-query'
import { apiClient } from '@/config/api-client'
import type { User } from './schemas'

export const getUsers = async (): Promise<User[]> => {
  const response = await apiClient.get('/users')
  return response.data
}

export const getUserById = async (id: string): Promise<User> => {
  const response = await apiClient.get(`/users/${id}`)
  return response.data
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TanStack Query 옵션
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
export const usersQueryOptions = () =>
  queryOptions({
    queryKey: ['users'],
    queryFn: getUsers,
  })

export const userQueryOptions = (id: string) =>
  queryOptions({
    queryKey: ['users', id],
    queryFn: () => getUserById(id),
  })
```

---

## 뮤테이션 패턴 (POST/PUT/DELETE)

```typescript
// services/user/mutations.ts
import { apiClient } from '@/config/api-client'
import { createUserSchema } from './schemas'
import type { CreateUserInput, User } from './schemas'

export const createUser = async (input: CreateUserInput): Promise<User> => {
  createUserSchema.parse(input)
  const response = await apiClient.post('/users', input)
  return response.data
}

export const updateUser = async (
  id: string,
  input: Partial<CreateUserInput>
): Promise<User> => {
  const response = await apiClient.put(`/users/${id}`, input)
  return response.data
}

export const deleteUser = async (id: string): Promise<void> => {
  await apiClient.delete(`/users/${id}`)
}
```

---

## 로더 프리페치 패턴

> route loader에서 공개 가능한 프리페치를 위해 `ensureQueryData`를 사용합니다. 프로젝트가 나중에 SSR/manual rendering을 추가하면 같은 loader가 서버 렌더에도 참여할 수 있으므로, secret이나 private env는 loader에서 직접 읽지 않습니다.

최신 TanStack Router 권장 조합은 loader의 `ensureQueryData` + 컴포넌트의 `useSuspenseQuery`입니다. loader가 채워둔 캐시를 컴포넌트가 그대로 읽으므로 로딩 깜빡임이 없습니다.

```typescript
// routes/users/index.tsx
import { useSuspenseQuery } from '@tanstack/react-query'

export const Route = createFileRoute('/users/')({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(usersQueryOptions()),
  component: UsersPage,
})

const UsersPage = (): JSX.Element => {
  const { data: users } = useSuspenseQuery(usersQueryOptions())
  return <UserList users={users} />
}
```

`useQuery`는 loader가 await하지 않은 보조 데이터(예: analytics 위젯)에 한해 사용하고, loader가 프리페치한 데이터는 기본적으로 `useSuspenseQuery`로 읽습니다.

우선순위가 섞인 페이지에서는 비-크리티컬 fetch를 `queryClient.prefetchQuery(...)`로 await 없이 시작하면 SSR 도중 스트리밍되어 들어옵니다. 크리티컬 쿼리는 그대로 await:

```typescript
// routes/dashboard/index.tsx
export const Route = createFileRoute('/dashboard/')({
  loader: ({ context: { queryClient } }) => {
    // 크리티컬 — 네비게이션을 막고 준비 완료될 때까지 대기
    const user = queryClient.ensureQueryData(userQueryOptions())

    // 비-크리티컬 — 요청만 시작하고 await하지 않음; SSR 도중 스트리밍
    queryClient.prefetchQuery(analyticsQueryOptions())

    return user
  },
  component: DashboardPage,
})
```

---

## API 클라이언트 설정

```typescript
// config/api-client.ts
import axios from 'axios'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: { 'Content-Type': 'application/json' },
})

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 인증 토큰 인터셉터
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
apiClient.interceptors.request.use((config) => {
  const token = getAuthToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      redirectToLogin()
    }
    return Promise.reject(error)
  }
)
```

---

## 모범 사례

| 원칙 | 설명 |
|-----------|-------------|
| **파일 분리** | 스키마, 쿼리, 뮤테이션 분리 필수 |
| **반환 타입** | 모든 서비스 함수에 명시적 반환 타입 |
| **검증** | POST/PUT/PATCH 전 Zod로 입력 검증 |
| **queryOptions** | 로더와 훅에서 재사용을 위한 `queryOptions` 팩토리 익스포트 |
| **직접 fetch 금지** | 라우트나 훅에서 `fetch`/`axios` 직접 호출 금지 |
| **공개 가능한 loader** | loader는 services/query options만 호출하고 secret/private env를 직접 읽지 않음 |
| **에러 처리** | 에러는 `errorComponent`로 전파; 401/403은 인터셉터에서 처리 |
