# Getting Started

> Hono 프로젝트 빠른 시작

<instructions>
@conventions.md
@env-setup.md
@../library/hono/index.md
</instructions>

---

<prerequisites>

| 요구사항 | 버전 |
|----------|------|
| Node.js | 18+ |
| 패키지 관리자 | npm / yarn / pnpm |

</prerequisites>

---

<installation>

## 프로젝트 생성

```bash
# npm
npm create hono@latest my-app

# 템플릿 선택
? Which template do you want to use?
❯ cloudflare-workers
  nodejs
  bun
  deno

cd my-app
npm install
```

## 필수 패키지

```bash
# Validation (Zod 4.x)
npm install zod @hono/zod-validator

# Database (Prisma 7.x)
npm install @prisma/client@7
npm install -D prisma@7

# Environment Variables
npm install @t3-oss/env-core
```

</installation>

---

<project_setup>

## 프로젝트 구조

```
src/
├── index.ts           # App 진입점
├── routes/
│   ├── index.ts       # Root routes
│   ├── users.ts       # /users/*
│   └── posts.ts       # /posts/*
├── middleware/
│   ├── auth.ts
│   └── logger.ts
├── services/
│   ├── user.ts
│   └── post.ts
├── lib/
│   ├── prisma.ts
│   └── env.ts
└── types/
    └── index.ts
```

## App 설정

```typescript
// src/index.ts
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { HTTPException } from 'hono/http-exception'

import users from './routes/users'
import posts from './routes/posts'

type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
}

const app = new Hono<{ Bindings: Bindings }>()

// 미들웨어
app.use('*', logger())
app.use('*', cors())

// 라우트
app.route('/users', users)
app.route('/posts', posts)

// 에러 핸들러
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  console.error(err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => c.json({ error: 'Not Found' }, 404))

export default app
```

## 라우트 예시

```typescript
// src/routes/users.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'

const users = new Hono()

// GET /users
users.get('/', async (c) => {
  const users = [
    { id: '1', name: 'Alice' },
    { id: '2', name: 'Bob' },
  ]
  return c.json({ users })
})

// GET /users/:id
users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = { id, name: 'Alice' }

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})

// POST /users
const createUserSchema = z.object({
  name: z.string().min(1).trim(),
  email: z.email(),
})

users.post('/', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  const user = { id: '3', ...data }

  return c.json({ user }, 201)
})

export default users
```

## 미들웨어 예시

```typescript
// src/middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type Variables = {
  userId: string
}

export const authMiddleware = createMiddleware<{ Variables: Variables }>(
  async (c, next) => {
    const token = c.req.header('Authorization')?.replace('Bearer ', '')

    if (!token) {
      throw new HTTPException(401, { message: 'Unauthorized' })
    }

    // JWT 검증 로직
    // const decoded = await verifyJWT(token)

    c.set('userId', 'user-id')
    await next()
  }
)
```

</project_setup>

---

<commands>

| Command | Description |
|---------|-------------|
| `npm run dev` | 개발 서버 시작 |
| `npm run build` | 프로덕션 빌드 |
| `npm start` | 프로덕션 서버 실행 |
| `npm run deploy` | 배포 (Cloudflare Workers 등) |

</commands>

---

<next_steps>

| 문서 | 내용 |
|------|------|
| [conventions.md](./conventions.md) | 코드 컨벤션, 파일명 규칙 |
| [env-setup.md](./env-setup.md) | 환경 변수 설정 |
| [../library/hono/](../library/hono/) | Hono API 상세 가이드 |
| [../library/prisma/](../library/prisma/) | Prisma ORM 사용법 |
| [../deployment/](../deployment/) | 배포 가이드 |

</next_steps>

---

<sources>

- [Hono Documentation](https://hono.dev/)
- [Hono Getting Started](https://hono.dev/getting-started/basic)
- [Hono Examples](https://github.com/honojs/hono/tree/main/examples)

</sources>
