# CLAUDE.md - Hono Server Framework

> Web Standards 기반 초경량 서버 프레임워크

## Instructions

@../../commands/git.md
@docs/library/hono/index.md
@docs/library/prisma/index.md
@docs/library/zod/index.md
@docs/deployment/index.md

---

## STOP - 금지 사항

| 분류 | 금지 항목 |
|------|----------|
| **Git** | `Generated with Claude Code`, `🤖`, `Co-Authored-By:`, 여러 줄 커밋, 이모지 |
| **Prisma** | `db push`, `migrate`, `generate` 자동 실행, schema 임의 변경 |
| **API** | handler 내부 수동 검증 (→ zValidator), 수동 인증 (→ middleware), 일반 Error throw (→ HTTPException) |
| **검색** | grep, rg, find (→ ast-grep 사용) |

---

## ALWAYS - 필수 사항

| 작업 | 필수 |
|------|------|
| 작업 전 | 관련 docs 읽기 |
| 코드 검색 | ast-grep 사용 |
| 복잡한 분석 | Sequential Thinking MCP |
| 3+ 파일 수정 | gemini-review 실행 |
| 코드 작성 | UTF-8, 코드 묶음별 한글 주석 |
| Prisma | Multi-File 구조, 모든 요소 한글 주석 |

---

## Tech Stack

| 기술 | 버전 | 주의사항 |
|------|------|----------|
| Hono | 최신 | Web Standards 기반 |
| TypeScript | 5.x | strict mode |
| Prisma | **7.x** | `prisma-client`, output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` (v4 문법) |

---

## Quick Patterns

### App + 에러 핸들러

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

type Bindings = { DATABASE_URL: string; JWT_SECRET: string }

const app = new Hono<{ Bindings: Bindings }>()

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

### Zod 검증 (v4 문법)

```typescript
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const schema = z.object({
  email: z.email(),           // ✅ v4
  name: z.string().min(1).trim(),
  website: z.url().optional() // ✅ v4
})

app.post('/users', zValidator('json', schema), (c) => {
  const data = c.req.valid('json')
  return c.json({ user: data }, 201)
})
```

### Prisma Multi-File 구조

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # enum 정의
├── user.prisma     # User 모델 (한글 주석 필수)
└── post.prisma     # Post 모델
```

```prisma
// +base.prisma
generator client {
  provider = "prisma-client"      // ✅ v7
  output   = "./generated/client" // ✅ 필수
}
```

---

## 문서 구조

```
docs/
├── library/
│   ├── hono/       # 라우팅, 미들웨어, 검증, RPC
│   ├── prisma/     # CRUD, 관계, D1 연동
│   ├── zod/        # v4 문법, 검증 패턴
│   ├── ai-sdk/     # LLM 통합 (streaming, tools)
│   └── pino/       # 로깅
├── deployment/     # Docker, Railway, Vercel, Cloudflare
└── architecture/   # 아키텍처 패턴
```
