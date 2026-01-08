# 코드 컨벤션

> Hono 프로젝트 코드 작성 규칙

---

<naming>

## 파일 네이밍

| 타입 | 규칙 | 예시 |
|------|------|------|
| **일반 파일** | kebab-case | `user-service.ts`, `auth-middleware.ts` |
| **Route 파일** | kebab-case | `users.ts`, `posts.ts` |
| **타입 파일** | kebab-case | `user-types.ts`, `api-types.ts` |

</naming>

---

<typescript>

## TypeScript 규칙

| 규칙 | 설명 | 예시 |
|------|------|------|
| **함수 선언** | const 함수, 명시적 return type | `const fn = (): ReturnType => {}` |
| **타입 정의** | interface (객체), type (유니온) | `interface User {}`, `type Status = 'a' \| 'b'` |
| **any 금지** | unknown 사용 | `const data: unknown = JSON.parse(str)` |
| **Import 타입** | type import 분리 | `import type { User } from '@/types'` |

## 패턴

```typescript
// ✅ const 함수, 명시적 타입
const getUserById = async (id: string): Promise<User | null> => {
  return prisma.user.findUnique({ where: { id } })
}

// ✅ 간단한 함수도 명시적 타입
const formatDate = (date: Date): string => {
  return date.toISOString()
}

// ✅ any 금지 → unknown 사용
const parseJSON = (data: string): unknown => {
  return JSON.parse(data)
}

// ❌ any 사용 금지
const badParse = (data: string): any => {  // ❌
  return JSON.parse(data)
}

// ❌ function 키워드 금지
function badFunction() {  // ❌
  return 'use const arrow function'
}
```

</typescript>

---

<imports>

## Import 순서

```typescript
// 1. External libraries
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

// 2. Internal modules
import { authMiddleware } from './middleware/auth'
import { prisma } from './lib/prisma'
import { env } from './lib/env'

// 3. Type imports
import type { User } from './types'
import type { Context } from 'hono'
```

</imports>

---

<comments>

## 한글 주석 (묶음 단위)

```typescript
// ✅ 코드 묶음 단위 주석
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 사용자 조회
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
users.get('/', async (c) => {
  const users = await prisma.user.findMany()
  return c.json({ users })
})

users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })
  if (!user) throw new HTTPException(404, { message: 'User not found' })
  return c.json({ user })
})

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 사용자 생성/수정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
users.post('/', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  const user = await prisma.user.create({ data })
  return c.json({ user }, 201)
})
```

```typescript
// ❌ 세세한 주석 (금지)
users.get('/', async (c) => {  // 사용자 목록 조회
  const users = await prisma.user.findMany()  // DB에서 조회
  return c.json({ users })  // JSON 반환
})
```

</comments>

---

<error_handling>

## 에러 처리 패턴

### HTTPException 사용

```typescript
import { HTTPException } from 'hono/http-exception'

// ✅ HTTPException 사용
users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})

// ❌ 일반 Error 사용 금지
users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new Error('User not found')  // ❌
  }

  return c.json({ user })
})
```

### 전역 에러 핸들러

```typescript
// src/index.ts
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json(
      {
        error: err.message,
        status: err.status,
      },
      err.status
    )
  }

  console.error('Unexpected error:', err)
  return c.json(
    {
      error: 'Internal Server Error',
      status: 500,
    },
    500
  )
})

app.notFound((c) => {
  return c.json(
    {
      error: 'Not Found',
      status: 404,
    },
    404
  )
})
```

### 커스텀 에러 클래스

```typescript
// lib/errors.ts
import { HTTPException } from 'hono/http-exception'

export class NotFoundError extends HTTPException {
  constructor(resource: string) {
    super(404, { message: `${resource} not found` })
  }
}

export class ValidationError extends HTTPException {
  constructor(message: string) {
    super(400, { message })
  }
}

export class UnauthorizedError extends HTTPException {
  constructor() {
    super(401, { message: 'Unauthorized' })
  }
}

// 사용
import { NotFoundError } from '@/lib/errors'

users.get('/:id', async (c) => {
  const user = await prisma.user.findUnique({ where: { id } })
  if (!user) throw new NotFoundError('User')
  return c.json({ user })
})
```

</error_handling>

---

<validation>

## Validation 패턴

### zValidator 사용

```typescript
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

// ✅ zValidator 사용
const createUserSchema = z.object({
  name: z.string().min(1).trim(),
  email: z.email(),
  age: z.number().int().min(18).optional(),
})

users.post('/', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')  // 타입 안전
  const user = await prisma.user.create({ data })
  return c.json({ user }, 201)
})

// ❌ 수동 검증 금지
users.post('/', async (c) => {
  const body = await c.req.json()

  if (!body.name || !body.email) {  // ❌
    return c.json({ error: 'Invalid input' }, 400)
  }

  const user = await prisma.user.create({ data: body })
  return c.json({ user }, 201)
})
```

### 여러 Validator

```typescript
// Query Params
users.get('/', zValidator('query', z.object({ page: z.string() })), (c) => {
  const { page } = c.req.valid('query')
  return c.json({ page })
})

// Path Params
users.get('/:id', zValidator('param', z.object({ id: z.string() })), (c) => {
  const { id } = c.req.valid('param')
  return c.json({ id })
})

// JSON Body
users.post('/', zValidator('json', createUserSchema), (c) => {
  const data = c.req.valid('json')
  return c.json({ data }, 201)
})
```

</validation>

---

<examples>

## 파일명 예시

| 타입 | ❌ 잘못된 예시 | ✅ 올바른 예시 |
|------|---------------|---------------|
| Route | `Users.ts` | `users.ts` |
| Service | `userService.ts` | `user-service.ts` |
| Middleware | `authMiddleware.ts` | `auth-middleware.ts` |
| Utility | `formatUtils.ts` | `format-utils.ts` |
| Type | `UserTypes.ts` | `user-types.ts` |

## 디렉토리 구조

```
src/
├── routes/
│   ├── users.ts           # /users/*
│   ├── posts.ts           # /posts/*
│   └── auth.ts            # /auth/*
├── middleware/
│   ├── auth.ts            # 인증 미들웨어
│   ├── logger.ts          # 로깅 미들웨어
│   └── cors.ts            # CORS 미들웨어
├── services/
│   ├── user-service.ts    # 사용자 비즈니스 로직
│   └── post-service.ts    # 게시글 비즈니스 로직
├── lib/
│   ├── prisma.ts          # Prisma 클라이언트
│   ├── env.ts             # 환경 변수
│   └── errors.ts          # 커스텀 에러
└── types/
    ├── user-types.ts      # 사용자 타입
    └── api-types.ts       # API 타입
```

</examples>

---

<sources>

- [Hono Best Practices](https://hono.dev/guides/best-practices)
- [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)

</sources>
