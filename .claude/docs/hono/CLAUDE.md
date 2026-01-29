# CLAUDE.md - Hono

> Web Standards 기반 초경량 프레임워크

<instructions>
@../../commands/git.md
@.claude/docs/guides/getting-started.md
@.claude/docs/library/hono/index.md
@.claude/docs/library/prisma/index.md
@.claude/docs/library/t3-env/index.md
@.claude/docs/library/zod/index.md
</instructions>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **Git** | `Generated with Claude Code`, `🤖`, `Co-Authored-By:`, 여러 줄, 이모지 |
| **Prisma** | `db push/migrate/generate` 자동 실행, schema 임의 변경 |
| **API** | handler 내 수동 검증/인증, 일반 Error throw |
| **검색** | grep, rg, find |

</forbidden>

---

<required>

| 작업 | 필수 |
|------|------|
| 작업 전 | 관련 docs 읽기 (API→hono, DB→prisma) |
| 문서 검색 | serena mcp (문서 인덱싱/검색, context 길이 최적화) |
| 코드 검색 | ast-grep |
| 복잡한 작업 | Sequential Thinking MCP |
| 3+ 파일 수정 | gemini-review |
| Validation | zValidator, HTTPException 에러 처리 |
| 코드 작성 | UTF-8, 코드 묶음별 한글 주석, Prisma Multi-File 모든 요소 주석 |

</required>

---

<tech_stack>

| 기술 | 버전 | 주의 |
|------|------|------|
| Hono | 최신 | - |
| TypeScript | 5.x | strict |
| Prisma | **7.x** | `prisma-client`, output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` |

</tech_stack>

---

<structure>
```
src/
├── routes/
│   ├── index.ts       # Root routes
│   ├── users.ts       # /users/*
│   └── posts.ts       # /posts/*
├── middleware/        # Auth, CORS, Logger
├── services/          # Business logic
├── lib/
│   ├── prisma.ts
│   └── env.ts
└── types/
```

공통 로직 → `src/services/`, 라우트별 로직 → 각 route 파일
</structure>

---

<conventions>

파일명: kebab-case
TypeScript: const 선언, 명시적 return type, interface(객체)/type(유니온), any→unknown
Import 순서: 외부 → 내부 → 상대경로 → type

Prisma Multi-File:
```
prisma/schema/
├── +base.prisma   # datasource, generator
├── +enum.prisma   # enum
└── [model].prisma # 모델별 (한글 주석!)
```

</conventions>

---

<quick_patterns>

```typescript
// App + 에러 핸들러
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

type Bindings = { DATABASE_URL: string }

const app = new Hono<{ Bindings: Bindings }>()

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  console.error(err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

export default app
```

```typescript
// Zod v4 + Validation
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const schema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional()
})

app.post('/users', zValidator('json', schema), (c) => {
  const data = c.req.valid('json')
  return c.json({ user: data }, 201)
})
```

```typescript
// Middleware
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

export const authMiddleware = createMiddleware(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')
  if (!token) throw new HTTPException(401, { message: 'Unauthorized' })

  c.set('userId', decoded.sub)
  await next()
})

// 사용
app.use('/api/*', authMiddleware)
```

```prisma
// +base.prisma (Prisma 7.x)
generator client {
  provider = "prisma-client"
  output   = "./generated/client"
}
```

</quick_patterns>

---

<docs_structure>
```
docs/
├── guides/       # getting-started, conventions, env-setup
├── library/      # hono, prisma, t3-env, zod
└── deployment/   # cloudflare, docker, railway, vercel
```
</docs_structure>
