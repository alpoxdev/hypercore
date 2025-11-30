# Hono RPC Client

> Type-safe API 호출을 위한 RPC 클라이언트

---

## 개요

Hono의 RPC 기능은 서버 타입을 클라이언트에서 직접 사용하여 타입 안전한 API 호출을 가능하게 합니다.

---

## 기본 사용법

### 서버 설정

```typescript
// server.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()
  .get('/hello', (c) => {
    return c.json({ message: 'Hello!' })
  })
  .get('/users/:id', (c) => {
    const id = c.req.param('id')
    return c.json({ id, name: 'John' })
  })
  .post(
    '/users',
    zValidator(
      'json',
      z.object({
        name: z.string(),
        email: z.email(),
      })
    ),
    (c) => {
      const data = c.req.valid('json')
      return c.json({ id: '1', ...data }, 201)
    }
  )

// ⭐ 타입 export 필수
export type AppType = typeof app
export default app
```

### 클라이언트 사용

```typescript
// client.ts
import { hc } from 'hono/client'
import type { AppType } from './server'

// 클라이언트 생성
const client = hc<AppType>('http://localhost:8787/')

// GET 요청
async function getHello() {
  const res = await client.hello.$get()
  if (res.ok) {
    const data = await res.json() // { message: string }
    console.log(data.message)
  }
}

// Path Parameter
async function getUser() {
  const res = await client.users[':id'].$get({
    param: { id: '123' },
  })
  const data = await res.json() // { id: string, name: string }
}

// POST 요청
async function createUser() {
  const res = await client.users.$post({
    json: {
      name: 'John',
      email: 'john@example.com',
    },
  })
  if (res.status === 201) {
    const data = await res.json()
    console.log(data.id)
  }
}
```

---

## 요청 옵션

### Query Parameters

```typescript
// 서버
const app = new Hono().get(
  '/search',
  zValidator('query', z.object({ q: z.string(), page: z.coerce.number() })),
  (c) => {
    const { q, page } = c.req.valid('query')
    return c.json({ query: q, page, results: [] })
  }
)

// 클라이언트
const res = await client.search.$get({
  query: { q: 'hono', page: '1' },
})
```

### Form Data

```typescript
// 서버
const app = new Hono().post(
  '/posts',
  zValidator('form', z.object({ title: z.string(), body: z.string() })),
  (c) => {
    const data = c.req.valid('form')
    return c.json({ post: data }, 201)
  }
)

// 클라이언트
const res = await client.posts.$post({
  form: {
    title: 'Hello',
    body: 'World',
  },
})
```

### Headers

```typescript
const res = await client.posts.$post(
  {
    json: { title: 'Test', body: 'Content' },
  },
  {
    headers: {
      'X-Custom-Header': 'value',
    },
  }
)
```

---

## 클라이언트 설정

### 공통 헤더

```typescript
const client = hc<AppType>('http://localhost:8787/', {
  headers: {
    Authorization: 'Bearer TOKEN',
  },
})
```

### Credentials (쿠키 전송)

```typescript
const client = hc<AppType>('http://localhost:8787/', {
  init: {
    credentials: 'include',
  },
})
```

### 전체 설정

```typescript
const client = hc<AppType>('http://localhost:8787/', {
  headers: {
    Authorization: 'Bearer TOKEN',
    'Content-Type': 'application/json',
  },
  init: {
    credentials: 'include',
    mode: 'cors',
  },
})
```

---

## 타입 추론

### InferRequestType

```typescript
import type { InferRequestType } from 'hono/client'

// POST 요청의 body 타입 추론
type CreateUserRequest = InferRequestType<typeof client.users.$post>['json']
// { name: string; email: string }

// Form 타입 추론
type PostFormRequest = InferRequestType<typeof client.posts.$post>['form']
```

### InferResponseType

```typescript
import type { InferResponseType } from 'hono/client'

// 응답 타입 추론
type UserResponse = InferResponseType<typeof client.users[':id'].$get>
// { id: string; name: string }

// 특정 상태 코드의 응답 타입
type NotFoundResponse = InferResponseType<typeof client.users[':id'].$get, 404>
// { error: string }
```

---

## 상태 코드 처리

### 서버에서 명시적 상태 코드

```typescript
// server.ts
const app = new Hono().get(
  '/posts/:id',
  zValidator('param', z.object({ id: z.string() })),
  async (c) => {
    const { id } = c.req.valid('param')
    const post = await getPost(id)

    if (!post) {
      return c.json({ error: 'Post not found' }, 404) // 명시적 404
    }

    return c.json({ post }, 200) // 명시적 200
  }
)

export type AppType = typeof app
```

### 클라이언트에서 상태 코드 처리

```typescript
// client.ts
async function getPost(id: string) {
  const res = await client.posts[':id'].$get({
    param: { id },
  })

  if (res.status === 404) {
    const data = await res.json() // { error: string }
    console.log(data.error)
    return null
  }

  if (res.status === 200) {
    const data = await res.json() // { post: Post }
    return data.post
  }

  throw new Error('Unexpected status')
}
```

---

## URL 생성

```typescript
// URL 객체 생성 (요청 없이)
const url = client.posts[':id'].$url({
  param: { id: '123' },
})

console.log(url.pathname) // /posts/123
console.log(url.toString()) // http://localhost:8787/posts/123
```

---

## 라우트 그룹화

### 서버

```typescript
// routes/users.ts
import { Hono } from 'hono'

const users = new Hono()
  .get('/', (c) => c.json({ users: [] }))
  .get('/:id', (c) => c.json({ id: c.req.param('id') }))
  .post('/', (c) => c.json({ created: true }, 201))

export default users
export type UsersType = typeof users

// index.ts
import { Hono } from 'hono'
import users from './routes/users'

const app = new Hono().route('/users', users)

export type AppType = typeof app
export default app
```

### 클라이언트

```typescript
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:8787/')

// /users 엔드포인트 호출
await client.users.$get()
await client.users[':id'].$get({ param: { id: '123' } })
await client.users.$post({ json: { name: 'John' } })
```

---

## 에러 처리

```typescript
async function fetchUser(id: string) {
  try {
    const res = await client.users[':id'].$get({
      param: { id },
    })

    if (!res.ok) {
      const error = await res.json()
      throw new Error(error.message || 'Request failed')
    }

    return await res.json()
  } catch (err) {
    if (err instanceof TypeError) {
      // 네트워크 에러
      console.error('Network error:', err)
    }
    throw err
  }
}
```

---

## 완전한 예제

### 서버

```typescript
// server.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const userSchema = z.object({
  name: z.string().min(1),
  email: z.email(),
})

const app = new Hono()
  .get('/users', (c) => {
    return c.json({ users: [{ id: '1', name: 'John' }] })
  })
  .get('/users/:id', (c) => {
    const id = c.req.param('id')
    return c.json({ user: { id, name: 'John' } })
  })
  .post('/users', zValidator('json', userSchema), (c) => {
    const data = c.req.valid('json')
    return c.json({ user: { id: '1', ...data } }, 201)
  })
  .put('/users/:id', zValidator('json', userSchema.partial()), (c) => {
    const id = c.req.param('id')
    const data = c.req.valid('json')
    return c.json({ user: { id, ...data } })
  })
  .delete('/users/:id', (c) => {
    return c.json({ success: true })
  })

export type AppType = typeof app
export default app
```

### 클라이언트

```typescript
// client.ts
import { hc } from 'hono/client'
import type { InferRequestType, InferResponseType } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:8787/', {
  headers: {
    Authorization: 'Bearer TOKEN',
  },
})

// 타입 추론
type CreateUserInput = InferRequestType<typeof client.users.$post>['json']
type User = InferResponseType<typeof client.users[':id'].$get>['user']

// CRUD 함수
export const userApi = {
  list: async () => {
    const res = await client.users.$get()
    return res.json()
  },

  get: async (id: string) => {
    const res = await client.users[':id'].$get({ param: { id } })
    return res.json()
  },

  create: async (data: CreateUserInput) => {
    const res = await client.users.$post({ json: data })
    return res.json()
  },

  update: async (id: string, data: Partial<CreateUserInput>) => {
    const res = await client.users[':id'].$put({
      param: { id },
      json: data,
    })
    return res.json()
  },

  delete: async (id: string) => {
    const res = await client.users[':id'].$delete({ param: { id } })
    return res.json()
  },
}
```

---

## 관련 문서

- [기본 사용법](./index.md)
- [Zod 검증](./validation.md)
- [에러 처리](./error-handling.md)
