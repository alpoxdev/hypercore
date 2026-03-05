# Server Functions

> TanStack Start 데이터 레이어 (Server Functions)

---

## API 이름 (중요)

| 올바른 API | 잘못된 API | 설명 |
|-------------|-------------|------|
| `.inputValidator()` | ~~`.validator()`~~ | TanStack Start는 `inputValidator`만 지원 |
| `.middleware()` | - | Middleware 체이닝 |
| `.handler()` | - | 최종 handler 함수 |
| `zodValidator()` | - | `@tanstack/zod-adapter`의 Zod 어댑터 |
| `useServerFn()` | - | 클라이언트 서버 함수 호출 훅 |

**주의:** `validator`는 존재하지 않는 API입니다. 반드시 `inputValidator`를 사용하세요.

---

## 서비스 폴더 구조

```
services/
├── user/
│   ├── index.ts         # 진입점 (re-export)
│   ├── schemas.ts       # Zod 스키마
│   ├── queries.ts       # GET (읽기)
│   └── mutations.ts     # POST (쓰기)
```

| 파일 | 용도 |
|------|------|
| `index.ts` | 모든 함수 re-export |
| `schemas.ts` | Zod 검증 스키마 |
| `queries.ts` | GET 요청 (읽기) |
| `mutations.ts` | POST/PUT/DELETE (쓰기) |

---

## Schemas 패턴

```typescript
// services/user/schemas.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
```

## Queries 패턴 (GET)

> `createServerFn()`에서 `method` 옵션을 생략하면 기본값은 `GET`입니다.

```typescript
// services/user/queries.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany({ orderBy: { createdAt: 'desc' } })
  })

export const getUserById = createServerFn({ method: 'GET' })
  .handler(async ({ data: id }: { data: string }) => {
    const user = await prisma.user.findUnique({ where: { id } })
    if (!user) throw new Error('User not found')
    return user
  })
```

## Mutations 패턴 (POST)

```typescript
// services/user/mutations.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'
import { createUserSchema } from './schemas'

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

---

## zodValidator 어댑터 패턴

> `@tanstack/zod-adapter`를 사용한 명시적 검증

```typescript
import { createServerFn } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const UserSchema = z.object({
  name: z.string().min(1),
  age: z.number().min(0),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(UserSchema))
  .handler(async ({ data }) => {
    // data는 완전히 타입 안전하고 검증됨
    return prisma.user.create({ data })
  })
```

> 직접 Zod 스키마(`inputValidator(schema)`)와 어댑터(`inputValidator(zodValidator(schema))`) 모두 지원됩니다. 어댑터는 명시적 타입 좁힘을 제공합니다.

---

## useServerFn 훅 (클라이언트)

> 리액트 컴포넌트에서 서버 함수 호출을 위한 공식 훅

```typescript
import { useServerFn } from '@tanstack/react-start'
import { useQuery } from '@tanstack/react-query'
import { getUsers } from './-functions/get-users'

const UserList = (): JSX.Element => {
  const getServerUsers = useServerFn(getUsers)

  const { data } = useQuery({
    queryKey: ['users'],
    queryFn: () => getServerUsers(),
  })

  return <div>{/* 사용자 렌더링 */}</div>
}
```

| 패턴 | 사용 시점 |
|------|----------|
| loader에서 직접 호출 | `loader: () => getUsers()` (서버사이드) |
| `useServerFn` + `useQuery` | 컴포넌트에서 클라이언트 데이터 페칭 |
| `useServerFn` + `useMutation` | 컴포넌트에서 클라이언트 뮤테이션 |

---

## Middleware 패턴

```typescript
// functions/middlewares/auth.ts
import { createMiddleware } from '@tanstack/react-start'

export const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session) throw new Error('Unauthorized')
    return next({ context: { userId: session.userId } })
  })

// 사용
export const getMyProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return prisma.user.findUnique({ where: { id: context.userId } })
  })
```

---

## Method Chaining 순서 (필수)

```typescript
// 패턴 A: middleware 먼저
createServerFn({ method: 'POST' })
  .middleware([authMiddleware])      // 1. middleware
  .inputValidator(createUserSchema)  // 2. inputValidator
  .handler(async ({ data }) => {})   // 3. handler (항상 마지막)

// 패턴 B: inputValidator 먼저 (역시 유효)
createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))  // 1. inputValidator
  .middleware([authMiddleware])                     // 2. middleware
  .handler(async ({ data, context }) => {})        // 3. handler (항상 마지막)

// 잘못된 순서 (TypeScript 에러)
createServerFn({ method: 'POST' })
  .handler(async () => {})           // handler가 먼저 -> 에러
  .inputValidator(schema)

// 잘못된 API 이름 (존재하지 않음)
createServerFn({ method: 'POST' })
  .validator(schema)                 // validator는 없음! inputValidator 사용
```

> 두 순서 모두 유효합니다. `handler`는 반드시 마지막이어야 합니다.

---

## 모범 사례

| 원칙 | 설명 |
|------|------|
| **파일 분리** | schemas, queries, mutations 분리 필수 |
| **진입점** | index.ts에서 모든 함수 re-export |
| **Validation** | POST/PUT/DELETE는 inputValidator 필수 |
| **Middleware** | 인증/권한은 middleware 사용 |
| **TanStack Query** | 클라이언트에서 직접 호출 금지, Query/Mutation 사용 |
| **zodValidator** | 명시적 검증을 위해 `@tanstack/zod-adapter` 사용 |
| **useServerFn** | 컴포넌트에서 타입 안전한 서버 함수 호출에 사용 |
