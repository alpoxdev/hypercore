# Architecture

Hono 서버 애플리케이션의 기술 아키텍처 가이드입니다.

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (Browser/App)                     │
│                                                                  │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │   HTTP Client  │───▶│   hono/client  │───▶│    React UI   │  │
│  │  (fetch/axios) │◀───│   (RPC Client) │◀───│  (Components) │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
│                                │                                 │
└────────────────────────────────┼─────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Hono Server                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     Middleware Stack                        │ │
│  │   - logger             → 요청 로깅                          │ │
│  │   - cors               → CORS 설정                          │ │
│  │   - secureHeaders      → 보안 헤더                          │ │
│  │   - authMiddleware     → 인증 처리                          │ │
│  └────────────────────────┬───────────────────────────────────┘ │
│                           │                                      │
│  ┌────────────────────────▼───────────────────────────────────┐ │
│  │                      Routes Layer                           │ │
│  │   - routes/users.ts        → /users/*                       │ │
│  │   - routes/posts.ts        → /posts/*                       │ │
│  │   - routes/auth.ts         → /auth/*                        │ │
│  └────────────────────────┬───────────────────────────────────┘ │
│                           │                                      │
│  ┌────────────────────────▼───────────────────────────────────┐ │
│  │                   Validation Layer                          │ │
│  │   - @hono/zod-validator    → 요청 검증                      │ │
│  │   - Zod v4 Schemas         → 타입 안전 검증                 │ │
│  └────────────────────────┬───────────────────────────────────┘ │
│                           │                                      │
│  ┌────────────────────────▼───────────────────────────────────┐ │
│  │                    Services Layer                           │ │
│  │   - Business Logic                                          │ │
│  │   - Data Transformation                                     │ │
│  │   - Error Handling (HTTPException)                          │ │
│  └────────────────────────┬───────────────────────────────────┘ │
│                           │                                      │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
│                                                                  │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  Prisma Client │───▶│   PostgreSQL   │    │  Cloudflare   │  │
│  │   (ORM v7)     │    │   (Primary)    │    │   D1/KV/R2    │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
my-app/
├── src/
│   ├── index.ts                   # Entry point & App 설정
│   ├── routes/                    # 라우트 모듈
│   │   ├── index.ts               # 라우트 통합 (re-export)
│   │   ├── users.ts               # /users/* 라우트
│   │   ├── posts.ts               # /posts/* 라우트
│   │   └── auth.ts                # /auth/* 라우트
│   ├── middleware/                # 커스텀 미들웨어
│   │   ├── index.ts               # re-export
│   │   ├── auth.ts                # 인증 미들웨어
│   │   ├── logger.ts              # 로깅 미들웨어
│   │   └── rate-limit.ts          # 레이트 리밋 미들웨어
│   ├── validators/                # Zod 스키마 정의
│   │   ├── index.ts               # re-export
│   │   ├── user.ts                # 사용자 스키마
│   │   ├── post.ts                # 게시글 스키마
│   │   └── common.ts              # 공통 스키마 (pagination 등)
│   ├── services/                  # 비즈니스 로직 레이어
│   │   ├── user/
│   │   │   ├── index.ts           # re-export
│   │   │   ├── queries.ts         # 조회 로직
│   │   │   └── mutations.ts       # 생성/수정/삭제 로직
│   │   └── post/
│   │       ├── index.ts
│   │       ├── queries.ts
│   │       └── mutations.ts
│   ├── database/                  # 데이터베이스 연결
│   │   └── prisma.ts              # Prisma Client 싱글톤
│   ├── types/                     # 타입 정의
│   │   ├── index.ts               # re-export
│   │   ├── env.d.ts               # 환경변수 타입
│   │   └── bindings.ts            # Cloudflare Bindings 타입
│   └── lib/                       # 공통 유틸리티
│       ├── errors.ts              # 커스텀 에러 클래스
│       ├── jwt.ts                 # JWT 유틸리티
│       └── utils.ts               # 범용 유틸리티
├── prisma/
│   ├── schema.prisma              # Prisma 스키마
│   └── generated/                 # Prisma Client 출력
│       └── client/
├── wrangler.toml                  # Cloudflare Workers 설정
├── .dev.vars                      # 로컬 환경변수
├── package.json
└── tsconfig.json
```

## Layer Architecture

### 1. Entry Point (src/index.ts)

애플리케이션의 진입점으로, 전역 설정과 라우트 마운트를 담당합니다.

```typescript
// src/index.ts
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'
import { secureHeaders } from 'hono/secure-headers'
import { HTTPException } from 'hono/http-exception'
import { users } from './routes/users'
import { posts } from './routes/posts'
import { auth } from './routes/auth'

type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
  NODE_ENV: string
}

type Variables = {
  userId: string
}

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// 글로벌 미들웨어
app.use(logger())
app.use(secureHeaders())
app.use('/api/*', cors())

// 글로벌 에러 핸들러
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  console.error(err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

// 404 핸들러
app.notFound((c) => {
  return c.json({ error: 'Not Found', path: c.req.path }, 404)
})

// 라우트 마운트
app.route('/api/users', users)
app.route('/api/posts', posts)
app.route('/api/auth', auth)

// Health Check
app.get('/health', (c) => c.json({ status: 'ok' }))

export default app
```

### 2. Routes Layer (Presentation)

파일 기반으로 라우트를 모듈화하여 관리합니다.

```
routes/
├── index.ts              # 라우트 통합
├── users.ts              # /users 라우트
├── posts.ts              # /posts 라우트
└── auth.ts               # /auth 라우트
```

**특징**:
- 각 파일은 독립적인 Hono 인스턴스
- zValidator로 요청 검증
- 미들웨어 적용 가능
- RPC 타입 추론 지원

```typescript
// routes/users.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { authMiddleware } from '@/middleware/auth'
import { createUserSchema, updateUserSchema, userIdSchema } from '@/validators/user'
import { paginationSchema } from '@/validators/common'
import { getUsers, getUserById, createUser, updateUser, deleteUser } from '@/services/user'

const users = new Hono()

// 목록 조회 (공개)
users.get('/', zValidator('query', paginationSchema), async (c) => {
  const { page, limit } = c.req.valid('query')
  const result = await getUsers({ page, limit })
  return c.json(result)
})

// 단일 조회 (공개)
users.get('/:id', zValidator('param', userIdSchema), async (c) => {
  const { id } = c.req.valid('param')
  const user = await getUserById(id)
  return c.json({ user })
})

// 생성 (인증 필요)
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

// 수정 (인증 필요)
users.put(
  '/:id',
  authMiddleware,
  zValidator('param', userIdSchema),
  zValidator('json', updateUserSchema),
  async (c) => {
    const { id } = c.req.valid('param')
    const data = c.req.valid('json')
    const user = await updateUser(id, data)
    return c.json({ user })
  }
)

// 삭제 (인증 필요)
users.delete(
  '/:id',
  authMiddleware,
  zValidator('param', userIdSchema),
  async (c) => {
    const { id } = c.req.valid('param')
    await deleteUser(id)
    return c.json({ success: true })
  }
)

export { users }
```

### 3. Middleware Layer

요청/응답 파이프라인을 처리합니다.

```
middleware/
├── index.ts              # re-export
├── auth.ts               # 인증 미들웨어
├── logger.ts             # 로깅 미들웨어
└── rate-limit.ts         # 레이트 리밋
```

**규칙**:
- `createMiddleware`로 타입 안전 미들웨어 작성
- `HTTPException`으로 에러 처리
- `c.set()`으로 변수 전달

```typescript
// middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'
import { verifyToken } from '@/lib/jwt'

type Env = {
  Bindings: {
    JWT_SECRET: string
  }
  Variables: {
    userId: string
  }
}

export const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new HTTPException(401, { message: 'Unauthorized' })
  }

  try {
    const payload = await verifyToken(token, c.env.JWT_SECRET)
    c.set('userId', payload.sub)
    await next()
  } catch {
    throw new HTTPException(401, { message: 'Invalid token' })
  }
})
```

### 4. Validators Layer (Input Validation)

Zod v4를 사용한 타입 안전 요청 검증을 담당합니다.

```
validators/
├── index.ts              # re-export
├── user.ts               # 사용자 스키마
├── post.ts               # 게시글 스키마
└── common.ts             # 공통 스키마
```

**Zod v4 문법**:

```typescript
// validators/user.ts
import { z } from 'zod'

// ✅ Zod v4 문법
export const createUserSchema = z.object({
  email: z.email(),               // ✅ v4: z.email()
  name: z.string().min(1).max(100).trim(),
  password: z.string().min(8),
  website: z.url().optional(),    // ✅ v4: z.url()
})

export const updateUserSchema = createUserSchema.partial().omit({ password: true })

export const userIdSchema = z.object({
  id: z.string().uuid(),
})

// 타입 추출
export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
```

```typescript
// validators/common.ts
import { z } from 'zod'

export const paginationSchema = z.object({
  page: z.coerce.number().positive().optional().default(1),
  limit: z.coerce.number().min(1).max(100).optional().default(10),
})

export const searchSchema = z.object({
  q: z.string().min(1),
  page: z.coerce.number().positive().optional(),
  limit: z.coerce.number().max(100).optional(),
})

export type PaginationInput = z.infer<typeof paginationSchema>
```

### 5. Services Layer (Business Logic)

비즈니스 로직을 라우트와 분리하여 관리합니다.

```
services/
├── user/
│   ├── index.ts           # re-export
│   ├── queries.ts         # 조회 로직
│   └── mutations.ts       # 생성/수정/삭제 로직
└── post/
    ├── index.ts
    ├── queries.ts
    └── mutations.ts
```

**Queries** - 읽기 작업:

```typescript
// services/user/queries.ts
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'
import type { PaginationInput } from '@/validators/common'

export const getUsers = async ({ page, limit }: PaginationInput) => {
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
      },
    }),
    prisma.user.count(),
  ])

  return {
    users,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  }
}

export const getUserById = async (id: string) => {
  const user = await prisma.user.findUnique({
    where: { id },
    include: { posts: true },
  })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return user
}
```

**Mutations** - 쓰기 작업:

```typescript
// services/user/mutations.ts
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'
import type { CreateUserInput, UpdateUserInput } from '@/validators/user'

export const createUser = async (data: CreateUserInput) => {
  // 중복 체크
  const existing = await prisma.user.findUnique({
    where: { email: data.email },
  })

  if (existing) {
    throw new HTTPException(409, { message: 'Email already exists' })
  }

  // 비밀번호 해싱 (실제로는 bcrypt 사용)
  const hashedPassword = await hashPassword(data.password)

  return prisma.user.create({
    data: {
      ...data,
      password: hashedPassword,
    },
    select: {
      id: true,
      email: true,
      name: true,
      createdAt: true,
    },
  })
}

export const updateUser = async (id: string, data: UpdateUserInput) => {
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return prisma.user.update({
    where: { id },
    data,
    select: {
      id: true,
      email: true,
      name: true,
      updatedAt: true,
    },
  })
}

export const deleteUser = async (id: string) => {
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  await prisma.user.delete({ where: { id } })
}
```

### 6. Database Layer (Data Access)

Prisma v7을 통한 데이터베이스 액세스를 담당합니다.

```typescript
// database/prisma.ts
import { PrismaClient } from '../../prisma/generated/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

## Data Flow

### Query Flow (읽기)

```
1. Client sends GET request
   │
   ▼
┌─────────────────┐
│  Middleware     │ ← logger, cors, secureHeaders
│  Stack          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Route Handler  │ ← zValidator('query', schema)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Service Query  │ ← getUsers(), getUserById()
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Prisma Client  │ ← findMany(), findUnique()
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Database     │
└─────────────────┘
```

### Mutation Flow (쓰기)

```
1. Client sends POST/PUT/DELETE request
   │
   ▼
┌─────────────────┐
│  Middleware     │ ← authMiddleware (인증)
│  Stack          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Zod Validation │ ← zValidator('json', schema)
└────────┬────────┘
         │ Valid
         ▼
┌─────────────────┐
│  Service        │ ← createUser(), updateUser()
│  Mutation       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Business Logic │ ← 중복 체크, 권한 검증
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Prisma Mutation│ ← create(), update(), delete()
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Database     │
└─────────────────┘
```

### Error Flow

```
1. Error occurs anywhere
   │
   ▼
┌─────────────────┐
│ HTTPException   │ ← 비즈니스 에러
│ throw           │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  app.onError()  │ ← 글로벌 에러 핸들러
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  JSON Response  │ ← { error: message }
└─────────────────┘
```

## RPC Pattern (Type-safe Client)

### Server 설정

```typescript
// src/index.ts
const app = new Hono()
  .route('/api/users', users)
  .route('/api/posts', posts)

export type AppType = typeof app
export default app
```

### Client 사용

```typescript
// client.ts
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:8787')

// Type-safe API 호출
const getUsers = async () => {
  const res = await client.api.users.$get({
    query: { page: '1', limit: '10' },
  })
  return res.json()
}

const createUser = async (data: CreateUserInput) => {
  const res = await client.api.users.$post({
    json: data,
  })
  return res.json()
}
```

## Technology Stack

### Core Framework

| Technology | Purpose | Version |
|------------|---------|---------|
| Hono | Web Standards 서버 프레임워크 | latest |
| TypeScript | 타입 안전 개발 | 5.x |

### Validation

| Technology | Purpose | Version |
|------------|---------|---------|
| Zod | 스키마 검증 | **4.x** |
| @hono/zod-validator | Zod 미들웨어 | latest |

### Database

| Technology | Purpose | Version |
|------------|---------|---------|
| Prisma | ORM | **7.x** |
| PostgreSQL | Primary Database | - |
| Cloudflare D1 | Edge Database | - |

### Runtime

| Technology | Purpose |
|------------|---------|
| Cloudflare Workers | Edge Runtime |
| Node.js | 로컬 개발 |
| Bun | 대안 런타임 |

## TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "jsxImportSource": "hono/jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "types": ["@cloudflare/workers-types"],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"]
}
```

## Deployment Architecture

### Cloudflare Workers

```
┌─────────────────────────────────────┐
│       Cloudflare Edge Network        │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │   Workers   │  │     KV      │  │
│  │  (Hono App) │  │  (Cache)    │  │
│  └──────┬──────┘  └─────────────┘  │
│         │                           │
│  ┌──────▼──────┐  ┌─────────────┐  │
│  │     D1      │  │     R2      │  │
│  │ (Database)  │  │  (Storage)  │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### Node.js / Bun

```
┌─────────────────────────────────────┐
│          Server (Node/Bun)           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │        Hono App             │   │
│  │     (Full-stack Server)     │   │
│  └─────────────────────────────┘   │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
            ┌───────────────┐
            │   Database    │
            │  (PostgreSQL) │
            └───────────────┘
```

## Documentation Structure

```
docs/
├── library/                    # 라이브러리 레퍼런스
│   ├── hono/                   # Hono 가이드
│   │   ├── index.md            # 기본 사용법
│   │   ├── middleware.md       # 미들웨어
│   │   ├── validation.md       # Zod 검증
│   │   ├── error-handling.md   # 에러 처리
│   │   └── rpc.md              # RPC Client
│   ├── prisma/                 # Prisma 가이드
│   │   ├── index.md            # 기본 사용법
│   │   └── cloudflare-d1.md    # D1 연동
│   └── zod/                    # Zod 가이드
│       └── index.md
├── deployment/                 # 배포 가이드
│   ├── index.md                # 배포 개요
│   └── cloudflare.md           # Cloudflare 배포
├── mcp/                        # MCP 도구 가이드
│   ├── index.md
│   ├── sgrep.md
│   ├── sequential-thinking.md
│   └── context7.md
├── skills/                     # 스킬 가이드
│   └── gemini-review/
├── git/                        # Git 규칙
│   └── index.md
└── architecture/               # 아키텍처
    └── architecture.md         # 시스템 아키텍처
```

## Security Considerations

### Input Validation

모든 라우트에서 Zod를 통한 입력 검증:

```typescript
// ✅ 올바른 패턴: zValidator 사용
app.post(
  '/users',
  zValidator('json', createUserSchema),  // 자동 검증
  (c) => {
    const data = c.req.valid('json')  // data는 이미 검증됨
    // ...
  }
)

// ❌ 잘못된 패턴: 수동 검증 금지
app.post('/users', async (c) => {
  const body = await c.req.json()
  if (!body.email) {  // ❌ 이렇게 하지 마세요
    return c.json({ error: 'Email required' }, 400)
  }
})
```

### Error Handling

HTTPException을 통한 안전한 에러 처리:

```typescript
// ✅ 올바른 패턴
import { HTTPException } from 'hono/http-exception'

if (!user) {
  throw new HTTPException(404, { message: 'User not found' })
}

// ❌ 잘못된 패턴
if (!user) {
  throw new Error('User not found')  // ❌ HTTPException 사용해야 함
}
```

### Authentication

미들웨어를 통한 인증 처리:

```typescript
// ✅ 올바른 패턴: 미들웨어 사용
app.post('/protected', authMiddleware, (c) => {
  const userId = c.get('userId')
  // ...
})

// ❌ 잘못된 패턴: 핸들러 내부에서 인증
app.post('/protected', async (c) => {
  const token = c.req.header('Authorization')  // ❌ 미들웨어 사용해야 함
  // ...
})
```

### Environment Variables

```typescript
// types/env.d.ts
type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
  NODE_ENV: 'development' | 'production'
}

// 사용
const app = new Hono<{ Bindings: Bindings }>()

app.get('/', (c) => {
  const secret = c.env.JWT_SECRET  // 타입 안전
})
```

## Performance Considerations

### Middleware Optimization

```typescript
// 필요한 경로에만 미들웨어 적용
app.use('/api/*', cors())              // API 전용
app.use('/api/protected/*', authMiddleware)  // 인증 필요 경로만

// 불필요한 미들웨어 중복 적용 금지
```

### Database Optimization

```typescript
// 필요한 필드만 선택
const users = await prisma.user.findMany({
  select: {                    // ✅ select 사용
    id: true,
    name: true,
    email: true,
  },
  take: 20,                    // ✅ 페이지네이션
  skip: (page - 1) * 20,
})

// 병렬 쿼리 실행
const [users, total] = await Promise.all([
  prisma.user.findMany({ take: 20 }),
  prisma.user.count(),
])
```

### Response Optimization

```typescript
// 적절한 상태 코드 사용
app.post('/users', (c) => {
  return c.json({ user }, 201)  // Created
})

// 불필요한 데이터 제외
const { password, ...safeUser } = user
return c.json({ user: safeUser })
```

## Related Documentation

- [Hono 기본 사용법](../library/hono/index.md)
- [미들웨어](../library/hono/middleware.md)
- [Zod 검증](../library/hono/validation.md)
- [에러 처리](../library/hono/error-handling.md)
- [RPC Client](../library/hono/rpc.md)
- [Prisma v7](../library/prisma/index.md)
- [Cloudflare 배포](../deployment/cloudflare.md)
