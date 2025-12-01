# CLAUDE.md - Claude Code Instructions

> Hono 서버 프레임워크 프로젝트 작업 지침

---

## 🚨 STOP - 작업 전 필수 확인

```
┌─────────────────────────────────────────────────────────────┐
│  이 프로젝트에서 작업하기 전에 이 문서를 끝까지 읽으세요.  │
│  특히 ⛔ NEVER DO 섹션의 규칙은 절대 위반하지 마세요.      │
│                                                             │
│  📖 작업 유형별 상세 문서: docs/ 폴더 참조                  │
└─────────────────────────────────────────────────────────────┘
```

---

## ⛔ NEVER DO (절대 금지 - 예외 없음)

### Git 커밋 금지 사항
```
❌ "Generated with Claude Code" 포함 금지
❌ "🤖" 또는 AI 관련 이모지 포함 금지
❌ "Co-Authored-By:" 헤더 포함 금지
❌ AI/봇이 작성했다는 어떤 표시도 금지
❌ 커밋 메시지 여러 줄 작성 금지
❌ 커밋 메시지에 이모지 사용 금지
```

### Prisma 금지 사항
```
❌ prisma db push 자동 실행 금지
❌ prisma migrate 자동 실행 금지
❌ prisma generate 자동 실행 금지
❌ schema.prisma 임의 변경 금지 (요청된 것만)
```

### API 구현 금지 사항
```
❌ handler 내부에서 수동 검증 금지 (zValidator 사용)
❌ handler 내부에서 수동 인증 체크 금지 (middleware 사용)
❌ app.onError 없이 에러 처리 금지
❌ HTTPException 없이 에러 throw 금지
```

### 코드 검색 금지 사항
```
❌ grep, rg 등 기본 검색 도구 사용 금지
❌ find 명령어로 코드 검색 금지
✅ 코드베이스 검색 시 sgrep 사용 필수
```

---

## ✅ ALWAYS DO (필수 실행)

### 1. 작업 전: 관련 문서 읽기
```
API 작업     → docs/library/hono/ 읽기
DB 작업      → docs/library/prisma/ 읽기
검증 작업    → docs/library/zod/ 읽기
배포 작업    → docs/deployment/ 읽기
```

### 2. MCP 도구 적극 활용
```
코드베이스 검색     → sgrep 사용 (grep/rg 금지)
복잡한 분석/디버깅  → Sequential Thinking 사용
라이브러리 문서     → Context7 사용
```
**상세**: `docs/mcp/` 참고

### 3. 복잡한 작업 시: Gemini Review 실행
```
아키텍처 설계/변경  → gemini-review (architecture)
구현 계획 검증      → gemini-review (plan)
복잡한 코드 리뷰    → gemini-review (code)
```

**실행 조건**:
- 3개 이상 파일 수정하는 기능 구현
- 새로운 아키텍처 패턴 도입
- 보안 관련 코드 (인증, 권한, 암호화)
- 성능 크리티컬 코드

**상세**: `docs/skills/gemini-review/SKILL.md` 참고

### 4. 작업 완료 후: Git 커밋
```bash
git add .
git commit -m "<prefix>: <설명>"
```

**커밋 형식**: `<prefix>: <설명>` (한 줄, 본문 없음)

**Prefix**: `feat` | `fix` | `refactor` | `style` | `docs` | `test` | `chore` | `perf` | `ci`

**예시**:
```bash
feat: 사용자 인증 API 추가
fix: JWT 토큰 검증 오류 수정
docs: API 문서 업데이트
```

---

## 📚 문서 참조 테이블

| 작업 | 문서 경로 | 필독 여부 |
|------|----------|----------|
| **Git 규칙** | `docs/git/git.md` | 🔴 필수 |
| **MCP 도구** | `docs/mcp/` | 🔴 필수 |
| **Gemini Review** | `docs/skills/gemini-review/` | 🟡 복잡한 작업 시 |
| **API 개발** | `docs/library/hono/` | 🔴 필수 |
| **DB** | `docs/library/prisma/` | 🟡 해당 시 |
| **검증** | `docs/library/zod/` | 🟡 해당 시 |
| **배포** | `docs/deployment/` | 🟡 해당 시 |

---

## 🛠 Tech Stack (버전 주의)

| 기술 | 버전 | 주의사항 |
|------|------|----------|
| Hono | 최신 | Web Standards 기반 서버 프레임워크 |
| TypeScript | 5.x | strict mode |
| Prisma | **7.x** | `prisma-client` (js 아님), output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` (string().email() 아님) |
| @hono/zod-validator | 최신 | Zod 검증 미들웨어 |

---

## 📁 Directory Structure

```
src/
├── index.ts              # Entry point
├── routes/               # 라우트 모듈
│   ├── index.ts          # 라우트 통합
│   ├── users.ts          # /users 라우트
│   └── posts.ts          # /posts 라우트
├── middleware/           # 미들웨어
│   ├── auth.ts           # 인증 미들웨어
│   └── logger.ts         # 로깅 미들웨어
├── validators/           # Zod 스키마
│   ├── user.ts           # 사용자 스키마
│   └── post.ts           # 게시글 스키마
├── services/             # 비즈니스 로직
│   └── user.service.ts   # 사용자 서비스
├── database/             # DB 연결
│   └── prisma.ts         # Prisma Client
├── types/                # 타입 정의
│   └── env.d.ts          # 환경변수 타입
└── lib/                  # 유틸리티
    └── errors.ts         # 커스텀 에러
```

---

## 🔧 Code Conventions

### File Naming
- **kebab-case**: `user-service.ts`, `auth-middleware.ts`
- **라우트 파일**: `users.ts`, `posts.ts`

### TypeScript
- `const` 선언 사용 (function 대신)
- 명시적 return type
- `interface` (객체) / `type` (유니온)
- `any` 금지 → `unknown` 사용

### Import
```typescript
// @/ → ./src/
import { prisma } from '@/database/prisma'
import { userSchema } from '@/validators/user'
```

**순서**: 외부 → 내부(@/) → 상대경로 → type imports

---

## 📝 Quick Patterns (복사용)

### App 설정
```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
}

const app = new Hono<{ Bindings: Bindings }>()

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

export default app
```

### 라우트 + Zod 검증 (GET)
```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

// ✅ 올바른 패턴: zValidator 사용
const querySchema = z.object({
  page: z.coerce.number().positive().optional(),
  limit: z.coerce.number().max(100).optional(),
})

app.get('/users', zValidator('query', querySchema), (c) => {
  const { page = 1, limit = 10 } = c.req.valid('query')
  return c.json({ page, limit, users: [] })
})
```

### 라우트 + Zod 검증 (POST)
```typescript
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

// ✅ Zod v4 문법
const createUserSchema = z.object({
  email: z.email(),              // ✅ v4
  name: z.string().min(1).trim(),
  website: z.url().optional(),   // ✅ v4
})

app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  // prisma.user.create({ data })
  return c.json({ user: data }, 201)
})
```

### ❌ 잘못된 패턴 (금지)
```typescript
// ❌ handler 내부에서 수동 검증 금지
app.post('/users', async (c) => {
  const body = await c.req.json()
  // ❌ 이렇게 하지 마세요!
  if (!body.email) {
    return c.json({ error: 'Email required' }, 400)
  }
})

// ❌ 일반 Error throw 금지
app.get('/user/:id', async (c) => {
  throw new Error('Not found')  // ❌ HTTPException 사용해야 함
})
```

### HTTPException 사용
```typescript
import { HTTPException } from 'hono/http-exception'

app.get('/users/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})
```

### 인증 미들웨어
```typescript
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type Env = {
  Variables: {
    userId: string
  }
}

export const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new HTTPException(401, { message: 'Unauthorized' })
  }

  // JWT 검증 로직
  const payload = verifyToken(token)
  c.set('userId', payload.sub)

  await next()
})

// 사용
app.get('/me', authMiddleware, (c) => {
  const userId = c.get('userId')
  return c.json({ userId })
})
```

### Zod Schema (v4 문법!)
```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.email(),           // ✅ v4
  name: z.string().min(1).trim(),
  website: z.url().optional(), // ✅ v4
  age: z.number().min(0),
})

// 커스텀 에러 핸들링
app.post(
  '/users',
  zValidator('json', schema, (result, c) => {
    if (!result.success) {
      return c.json({ errors: result.error.flatten() }, 400)
    }
  }),
  (c) => {
    const data = c.req.valid('json')
    return c.json({ user: data }, 201)
  }
)
```

### RPC Client (Type-safe)
```typescript
// server.ts
const app = new Hono()
  .get('/users', (c) => c.json({ users: [] }))
  .post('/users', zValidator('json', createUserSchema), (c) => {
    const data = c.req.valid('json')
    return c.json({ user: data }, 201)
  })

export type AppType = typeof app

// client.ts
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:8787/')

// Type-safe API 호출
const res = await client.users.$get()
const data = await res.json() // { users: [] }
```

---

## 🔗 Quick Links

- [Hono 가이드](./docs/library/hono/index.md)
- [Git 규칙](./docs/git/git.md)
- [MCP 가이드](./docs/mcp/index.md)
- [배포 가이드](./docs/deployment/index.md)
