# TanStack Start - Server Functions

> **상위 문서**: [TanStack Start](./index.md)

Server Functions는 서버에서만 실행되는 타입 안전한 함수입니다.

## 기본 Server Function

```typescript
import { createServerFn } from '@tanstack/react-start'

// GET 요청 (데이터 조회)
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany()
  })

// POST 요청 (데이터 생성/수정)
export const createUser = createServerFn({ method: 'POST' })
  .handler(async () => {
    return { success: true }
  })
```

## Input Validation

### 기본 Validator

```typescript
import { createServerFn } from '@tanstack/react-start'

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator((data: { email: string; name: string }) => data)
  .handler(async ({ data }) => {
    // data는 타입 안전함
    return prisma.user.create({ data })
  })
```

### Zod Validation 사용

```typescript
import { createServerFn } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/react-start/validators'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  bio: z.string().max(500).optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

## FormData 처리

```typescript
import { createServerFn } from '@tanstack/react-start'

export const submitForm = createServerFn({ method: 'POST' })
  .inputValidator((formData: FormData) => {
    const name = formData.get('name') as string
    const email = formData.get('email') as string
    return { name, email }
  })
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

## 컴포넌트에서 호출

### useServerFn 사용

```tsx
import { useServerFn } from '@tanstack/react-start'
import { useQuery } from '@tanstack/react-query'
import { getServerPosts } from '~/lib/server-functions'

function PostList() {
  const getPosts = useServerFn(getServerPosts)

  const { data, isLoading, error } = useQuery({
    queryKey: ['posts'],
    queryFn: () => getPosts(),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

## 보안 패턴

### 서버 전용 데이터 보호

```tsx
// ❌ 잘못된 방법 - 클라이언트에 노출됨
export const Route = createFileRoute('/users')({
  loader: () => {
    const secret = process.env.SECRET // 클라이언트에 노출!
    return fetch(`/api/users?key=${secret}`)
  },
})

// ✅ 올바른 방법 - 서버 함수 사용
const getUsersSecurely = createServerFn().handler(() => {
  const secret = process.env.SECRET // 서버에서만 접근
  return fetch(`/api/users?key=${secret}`)
})

export const Route = createFileRoute('/users')({
  loader: () => getUsersSecurely(),
})
```
