# Architecture

> Hono 애플리케이션 아키텍처

<instructions>
@../guides/conventions.md
@../guides/routes.md
@../guides/middleware.md
</instructions>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **컨트롤러** | Rails 스타일 클래스 컨트롤러 (`class UserController`) |
| **타입** | `Context` 직접 타입 지정 (타입 추론 불가) |
| **RPC** | `c.notFound()` 사용 (클라이언트 타입 추론 불가) |
| **에러** | 일반 `Error` throw (`HTTPException` 사용) |
| **검증** | handler 내부 수동 검증 (`zValidator` 사용) |
| **Barrel Export** | `routes/index.ts`에서 모든 라우트 re-export |
| **폴더 구조** | `lib/db`, `controllers/` (→ `database/`, `services/` 사용) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **핸들러** | 경로 정의 후 직접 작성 (타입 추론 최적화) |
| **라우트 분리** | `app.route()` 사용 (`routes/users.ts` → `app.route('/users', users)`) |
| **RPC 타입** | 메서드 체이닝 + `export type AppType = typeof app` |
| **Env 타입** | `Hono<{ Bindings; Variables }>` 명시 |
| **검증** | `zValidator('json' \| 'query' \| 'param', schema)` |
| **인증** | 미들웨어로 분리 (`jwt()`, `bearerAuth()`, 커스텀) |
| **에러 처리** | `app.onError()` + `HTTPException` |
| **타입 안전** | TypeScript strict, Zod 스키마 |

</required>

---

<system_overview>

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client                                   │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │   hc (RPC)     │───▶│  fetch/axios   │───▶│   React/Vue   │  │
│  │  Type-safe     │◀───│   HTTP Client  │◀───│   Frontend    │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Hono Server                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Middleware: Logger | CORS | Auth              │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Routes (Handlers)                        │ │
│  │         /api/users | /api/posts | /api/auth                │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │               Validation: Zod + zValidator                  │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                   Services Layer                            │ │
│  │       queries.ts (조회)  |  mutations.ts (생성/수정/삭제)   │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │              Error Handling: HTTPException                  │ │
│  └────────────────────────────┬───────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  Prisma Client │───▶│   PostgreSQL   │    │    Redis      │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

</system_overview>

---

<folder_structure>

## Folder Structure

```
src/
├── index.ts              # 엔트리포인트, 앱 구성
├── routes/               # 라우트 모듈
│   ├── users.ts          # /api/users/*
│   ├── posts.ts          # /api/posts/*
│   └── auth.ts           # /api/auth/*
├── middleware/           # 커스텀 미들웨어
│   ├── auth.ts           # JWT/Bearer 인증
│   ├── logging.ts        # 요청 로깅
│   └── error.ts          # 전역 에러 핸들러
├── validators/           # Zod 스키마
│   ├── user.ts
│   ├── post.ts
│   └── common.ts         # 공통 스키마 (pagination 등)
├── services/             # 비즈니스 로직
│   └── user/
│       ├── queries.ts    # 조회 로직
│       └── mutations.ts  # 생성/수정/삭제 로직
├── database/             # Prisma Client
│   └── prisma.ts
├── types/                # 타입 정의
│   └── env.ts            # Bindings, Variables
├── errors/               # 커스텀 에러 클래스
│   └── domain.ts
└── lib/                  # 유틸리티
    └── utils.ts
```

### 폴더 역할

| 폴더 | 역할 | 예시 |
|------|------|------|
| **routes/** | HTTP 라우팅, 핸들러 | users.ts, posts.ts |
| **middleware/** | 요청/응답 처리 | auth.ts, logging.ts |
| **validators/** | Zod 스키마 정의 | user.ts, post.ts |
| **services/** | 비즈니스 로직, DB 쿼리 | queries.ts, mutations.ts |
| **database/** | Prisma 싱글톤 | prisma.ts |
| **types/** | TypeScript 타입 | env.ts (Bindings, Variables) |
| **errors/** | 커스텀 에러 클래스 | DomainError, NotFoundError |

</folder_structure>

---

<folder_structure_advanced>

## Clean Architecture (대규모)

> ⚠️ 대규모 프로젝트에서만 권장. 소규모는 위 기본 구조 사용.

```
src/
├── domain/               # 순수 비즈니스 로직
│   ├── entities/         # DTOs, Value Objects
│   ├── repositories/     # 저장소 인터페이스 (추상)
│   ├── schemas/          # Zod 검증 스키마
│   └── use-cases/        # 비즈니스 규칙
├── infrastructure/       # 외부 시스템 연동
│   ├── database/         # DB 연결, 마이그레이션
│   ├── repositories/     # 저장소 구현체
│   └── external/         # 외부 API 클라이언트
├── presentation/         # HTTP 계층
│   ├── routes/           # 라우트 정의
│   ├── handlers/         # HTTP 핸들러
│   └── middlewares/      # 인증, 로깅, 에러
├── shared/               # 공유 유틸
│   ├── errors/           # 커스텀 에러
│   ├── utils/            # 유틸 함수
│   └── types/            # 공유 타입
└── index.ts              # 엔트리포인트
```

### 의존성 방향

```
Domain ← Application ← Presentation ← Infrastructure
(내부)                                    (외부)
```

| 프로젝트 규모 | 권장 구조 |
|--------------|----------|
| **소규모** | 기본 구조 (routes + services + database) |
| **중규모** | 3계층 (presentation + services + infrastructure) |
| **대규모** | Clean Architecture 4-5계층 |

</folder_structure_advanced>

---

<layers>

## Layer Architecture

### 1. Routes Layer

> ⚠️ **핸들러 직접 작성 필수** (타입 추론 최적화)
>
> | ❌ 금지 | ✅ 필수 |
> |--------|--------|
> | `class UserController` | `app.get('/users', (c) => ...)` |
> | `app.get('/users', controller.getUser)` | `app.route('/users', usersRoute)` |

```typescript
// routes/users.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { authMiddleware } from '@/middleware/auth'
import { createUserSchema, userIdSchema } from '@/validators/user'
import { getUsers, getUserById, createUser } from '@/services/user'

const users = new Hono()

// 목록 조회
users.get('/', async (c) => {
  const result = await getUsers()
  return c.json(result)
})

// 단건 조회
users.get('/:id', zValidator('param', userIdSchema), async (c) => {
  const { id } = c.req.valid('param')
  const user = await getUserById(id)
  return c.json(user)
})

// 생성 (인증 + 검증)
users.post(
  '/',
  authMiddleware,
  zValidator('json', createUserSchema),
  async (c) => {
    const data = c.req.valid('json')
    const user = await createUser(data)
    return c.json({ user }, 201)
  }
)

export { users }
```

### RPC 타입 안전성

> 메서드 체이닝으로 타입 내보내기

```typescript
// routes/users.ts (RPC 버전)
const users = new Hono()
  .get('/', listUsers)
  .get('/:id', getUser)
  .post('/', createUser)
  .put('/:id', updateUser)
  .delete('/:id', deleteUser)

export { users }
export type UsersType = typeof users

// index.ts
const app = new Hono()
  .route('/api/users', users)
  .route('/api/posts', posts)

export type AppType = typeof app

// client
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:3000')
const res = await client.api.users.$get()  // 완전한 타입 추론
```

### 2. Middleware Layer

> 양파 구조 (Onion): 요청 → 미들웨어1 → 미들웨어2 → 핸들러 → 미들웨어2 → 미들웨어1 → 응답

```typescript
// middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type AuthEnv = {
  Bindings: { JWT_SECRET: string }
  Variables: { user: { id: string; role: string } }
}

export const authMiddleware = createMiddleware<AuthEnv>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new HTTPException(401, { message: 'Unauthorized' })
  }

  try {
    const user = await verifyToken(token, c.env.JWT_SECRET)
    c.set('user', user)
    await next()
  } catch {
    throw new HTTPException(401, { message: 'Invalid token' })
  }
})

// 역할 기반 접근 제어
export const requireRole = (allowedRoles: string[]) => {
  return createMiddleware<AuthEnv>(async (c, next) => {
    const user = c.get('user')

    if (!allowedRoles.includes(user.role)) {
      throw new HTTPException(403, { message: 'Forbidden' })
    }

    await next()
  })
}
```

#### 빌트인 미들웨어

| 카테고리 | 미들웨어 | 용도 |
|----------|----------|------|
| **인증** | `jwt`, `bearerAuth`, `basicAuth` | 토큰/자격증명 검증 |
| **성능** | `cache`, `compress`, `etag`, `timeout` | 캐싱, 압축 |
| **보안** | `cors`, `csrf`, `secureHeaders` | 보안 헤더, CORS |
| **유틸** | `logger`, `bodyLimit`, `requestId` | 로깅, 제한 |

### 3. Validators Layer

> Zod v4 + @hono/zod-validator

```typescript
// validators/user.ts
import { z } from 'zod'

// 생성 스키마
export const createUserSchema = z.object({
  email: z.email(),                    // Zod v4
  name: z.string().min(1).trim(),
  password: z.string().min(8),
})

// 수정 스키마
export const updateUserSchema = createUserSchema.partial()

// 파라미터 스키마
export const userIdSchema = z.object({
  id: z.string().uuid(),
})

// 쿼리 스키마
export const paginationSchema = z.object({
  page: z.coerce.number().positive().default(1),
  limit: z.coerce.number().max(100).default(10),
})

// 타입 내보내기
export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
```

#### 다중 Validator 조합

```typescript
app.put(
  '/users/:id',
  zValidator('param', userIdSchema),
  zValidator('query', paginationSchema),
  zValidator('json', updateUserSchema),
  async (c) => {
    const { id } = c.req.valid('param')
    const query = c.req.valid('query')
    const body = c.req.valid('json')
    // 모든 입력값 타입 안전
  }
)
```

### 4. Services Layer

> 비즈니스 로직, Prisma 쿼리

```typescript
// services/user/queries.ts
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'

export const getUsers = async ({ page = 1, limit = 10 }) => {
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      skip: (page - 1) * limit,
      take: limit,
      select: { id: true, email: true, name: true, createdAt: true },
    }),
    prisma.user.count(),
  ])

  return {
    users,
    pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
  }
}

export const getUserById = async (id: string) => {
  const user = await prisma.user.findUnique({
    where: { id },
    select: { id: true, email: true, name: true, createdAt: true },
  })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return user
}
```

```typescript
// services/user/mutations.ts
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'
import type { CreateUserInput } from '@/validators/user'

export const createUser = async (data: CreateUserInput) => {
  const existing = await prisma.user.findUnique({
    where: { email: data.email },
  })

  if (existing) {
    throw new HTTPException(409, { message: 'Email already exists' })
  }

  return prisma.user.create({
    data: {
      ...data,
      password: await hashPassword(data.password),
    },
    select: { id: true, email: true, name: true },
  })
}

export const updateUser = async (id: string, data: Partial<CreateUserInput>) => {
  return prisma.user.update({
    where: { id },
    data,
    select: { id: true, email: true, name: true },
  })
}

export const deleteUser = async (id: string) => {
  return prisma.user.delete({ where: { id } })
}
```

### 5. Database Layer

```typescript
// database/prisma.ts
import { PrismaClient } from '../../prisma/generated/client'

const globalForPrisma = globalThis as { prisma?: PrismaClient }

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

</layers>

---

<data_flow>

## Data Flow

### Request Flow (요청)

```
Client → Middleware (Logger → CORS → Auth) → Route → zValidator → Handler → Service → Prisma → Database
```

```typescript
// 1. Client 요청
const res = await client.api.users.$post({
  json: { email: 'user@example.com', name: 'User', password: '12345678' }
})

// 2. 미들웨어 체인
app.use(logger())                    // 로깅
app.use('/api/*', cors())            // CORS
app.use('/api/*', authMiddleware)    // 인증

// 3. 라우트 + 검증 + 핸들러
app.post('/api/users',
  zValidator('json', createUserSchema),  // 검증
  async (c) => {
    const data = c.req.valid('json')
    const user = await createUser(data)  // 서비스 호출
    return c.json({ user }, 201)
  }
)

// 4. 서비스 → DB
export const createUser = async (data) => {
  return prisma.user.create({ data })
}
```

### Response Flow (응답)

```
Database → Prisma → Service → Handler → (Error Handler?) → Middleware → Client
```

```typescript
// 정상 응답
return c.json({ user }, 201)

// 에러 응답 (HTTPException → onError)
throw new HTTPException(404, { message: 'User not found' })

// 전역 에러 핸들러
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  console.error(err)
  return c.json({ error: 'Internal Server Error' }, 500)
})
```

</data_flow>

---

<error_handling>

## Error Handling

### 전역 에러 핸들러

```typescript
// index.ts
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

// 전역 에러 핸들러
app.onError((err, c) => {
  console.error(`[Error] ${err.message}`, err.stack)

  if (err instanceof HTTPException) {
    return c.json({
      success: false,
      error: err.message,
      ...(err.cause && { details: err.cause }),
    }, err.status)
  }

  return c.json({
    success: false,
    error: 'Internal Server Error',
  }, 500)
})

// 404 핸들러
app.notFound((c) => {
  return c.json({
    success: false,
    error: 'Not Found',
  }, 404)
})
```

### HTTPException 사용

| 상태 코드 | 용도 | 예시 |
|----------|------|------|
| **400** | 잘못된 요청 | 검증 실패 |
| **401** | 인증 필요 | 토큰 없음/만료 |
| **403** | 권한 없음 | 역할 부족 |
| **404** | 리소스 없음 | 사용자 없음 |
| **409** | 충돌 | 이메일 중복 |
| **500** | 서버 오류 | 예외 처리 안됨 |

```typescript
import { HTTPException } from 'hono/http-exception'

// 기본 사용
throw new HTTPException(404, { message: 'User not found' })

// 상세 정보 포함
throw new HTTPException(400, {
  message: 'Validation failed',
  cause: { field: 'email', error: 'Invalid format' },
})
```

### 커스텀 에러 클래스 (선택)

```typescript
// errors/domain.ts
export class DomainError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 400
  ) {
    super(message)
    this.name = 'DomainError'
  }
}

export class NotFoundError extends DomainError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404)
  }
}

// 사용
throw new NotFoundError('User')
```

</error_handling>

---

<context_management>

## Context & Type Management

### Env 타입 정의

```typescript
// types/env.ts
export type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
  REDIS_URL?: string
}

export type Variables = {
  user: { id: string; email: string; role: string }
  requestId: string
}

export type AppEnv = {
  Bindings: Bindings
  Variables: Variables
}
```

### 앱에 타입 적용

```typescript
// index.ts
import { Hono } from 'hono'
import type { AppEnv } from '@/types/env'

const app = new Hono<AppEnv>()

// Bindings 접근
app.get('/config', (c) => {
  const dbUrl = c.env.DATABASE_URL  // 타입 안전
  return c.json({ configured: !!dbUrl })
})

// Variables 접근
app.get('/me', authMiddleware, (c) => {
  const user = c.get('user')  // 타입 안전
  return c.json(user)
})
```

### Factory로 타입 중앙화

```typescript
// lib/factory.ts
import { createFactory } from 'hono/factory'
import type { AppEnv } from '@/types/env'

export const factory = createFactory<AppEnv>({
  initApp: (app) => {
    app.use(logger())
    app.use(requestId())
  },
})

// 다른 파일에서 사용
const app = factory.createApp()
const middleware = factory.createMiddleware(...)
const handlers = factory.createHandlers(...)
```

</context_management>

---

<rpc_pattern>

## RPC Pattern

### 서버 설정

```typescript
// server.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { createPostSchema } from '@/validators/post'

const app = new Hono()
  .get('/posts', async (c) => {
    const posts = await getPosts()
    return c.json(posts)
  })
  .post('/posts', zValidator('json', createPostSchema), async (c) => {
    const data = c.req.valid('json')
    const post = await createPost(data)
    return c.json(post, 201)
  })
  .get('/posts/:id', async (c) => {
    const id = c.req.param('id')
    const post = await getPostById(id)
    return c.json(post)
  })

export type AppType = typeof app
export default app
```

### 클라이언트 사용

```typescript
// client.ts
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:3000')

// GET 요청
const posts = await client.posts.$get()
const data = await posts.json()

// POST 요청 (타입 안전)
const newPost = await client.posts.$post({
  json: { title: 'Hello', content: 'World' },
})

// 파라미터
const post = await client.posts[':id'].$get({
  param: { id: '123' },
})
```

</rpc_pattern>

---

<quick_patterns>

## Quick Patterns

```typescript
// 앱 기본 구조
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'
import { HTTPException } from 'hono/http-exception'

type Bindings = { DATABASE_URL: string; JWT_SECRET: string }
type Variables = { userId: string }

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

app.use(logger())
app.use('/api/*', cors())

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => c.json({ error: 'Not Found' }, 404))

export default app


// Zod v4 스키마
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional(),
})

const paginationSchema = z.object({
  page: z.coerce.number().positive().default(1),
  limit: z.coerce.number().max(100).default(10),
})


// 라우트 + 검증
import { zValidator } from '@hono/zod-validator'

app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  return c.json({ user: await createUser(data) }, 201)
})


// 커스텀 미들웨어
import { createMiddleware } from 'hono/factory'

const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')
  if (!token) throw new HTTPException(401, { message: 'Unauthorized' })
  c.set('userId', await verifyToken(token))
  await next()
})

app.use('/api/*', authMiddleware)


// 라우트 분리 + 통합
// routes/users.ts
const users = new Hono()
  .get('/', listUsers)
  .post('/', createUser)
  .get('/:id', getUser)

export { users }

// index.ts
app.route('/api/users', users)
app.route('/api/posts', posts)


// RPC 타입 내보내기
const app = new Hono()
  .route('/api/users', users)
  .route('/api/posts', posts)

export type AppType = typeof app
```

</quick_patterns>

---

<routers>

## Router Types

| 라우터 | 특성 | 사용 케이스 |
|--------|------|-------------|
| **SmartRouter** (기본) | RegExp + Trie 자동 선택 | 대부분의 경우 |
| **RegExpRouter** | 단일 정규식, 최고 속도 | 고성능 필요 시 |
| **TrieRouter** | 모든 패턴 지원 | 복잡한 라우팅 |
| **LinearRouter** | 빠른 초기화 | Serverless, Edge |
| **PatternRouter** | 최소 번들 (15KB 미만) | 번들 크기 중요 시 |

```typescript
import { Hono } from 'hono'
import { RegExpRouter } from 'hono/router/reg-exp-router'

const app = new Hono({ router: new RegExpRouter() })
```

</routers>

---

<tech_stack>

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Hono | latest |
| Validation | Zod | **4.x** |
| ORM | Prisma | **7.x** |
| Runtime | Cloudflare Workers, Bun, Node.js, Deno | - |
| Auth | JWT, Bearer Auth | built-in |
| Testing | Vitest | latest |

</tech_stack>

---

<deployment>

## Deployment Targets

| 환경 | 특징 | 설정 |
|------|------|------|
| **Cloudflare Workers** | Edge, 초저지연 | `wrangler.toml` |
| **Bun** | 고성능 런타임 | `bun run` |
| **Node.js** | 호환성 최고 | `@hono/node-server` |
| **Deno** | 보안, 내장 TS | `deno serve` |
| **AWS Lambda** | 서버리스 | `@hono/aws-lambda` |
| **Vercel** | Edge Functions | `vercel.json` |

```typescript
// Node.js 어댑터
import { serve } from '@hono/node-server'
import app from './app'

serve({ fetch: app.fetch, port: 3000 })

// Cloudflare Workers
export default app

// Bun
export default app
```

</deployment>
