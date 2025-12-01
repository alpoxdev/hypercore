# Pino - Structured Logging

> 초고속 JSON 로거

---

## 왜 console.log 대신 Pino를 사용해야 하나요?

| 항목 | console.log | Pino |
|------|-------------|------|
| **출력 형식** | 비정형 텍스트 | 구조화된 JSON |
| **성능** | 느림 | 초고속 (30x 빠름) |
| **로그 레벨** | 없음 | debug, info, warn, error, fatal |
| **컨텍스트 추가** | 수동 문자열 연결 | 자동 객체 바인딩 |
| **프로덕션 분석** | 어려움 | JSON 파싱으로 쉬움 |
| **Child Logger** | 불가 | 요청별 컨텍스트 분리 |

---

## 설치

```bash
# pino + pino-pretty (개발용 포맷터)
npm install pino pino-pretty

# pino-http (HTTP 요청 로깅)
npm install pino-http
```

---

## 기본 설정

### lib/logger.ts

```typescript
import pino from 'pino'

const isDev = process.env.NODE_ENV === 'development'

export const logger = pino({
  level: isDev ? 'debug' : 'info',
  transport: isDev
    ? {
        target: 'pino-pretty',
        options: {
          colorize: true,
          translateTime: 'SYS:yyyy-mm-dd HH:MM:ss',
          ignore: 'pid,hostname',
        },
      }
    : undefined,
})
```

### 환경별 출력

**개발 환경** (pino-pretty):
```
2024-01-15 10:30:45 INFO: User created successfully
    userId: "user_123"
    email: "user@example.com"
```

**프로덕션** (JSON):
```json
{"level":30,"time":1705312245000,"msg":"User created successfully","userId":"user_123","email":"user@example.com"}
```

---

## Hono와 통합

### 방법 1: pino-http 미들웨어

```typescript
// middleware/logger.ts
import { createMiddleware } from 'hono/factory'
import { pinoHttp } from 'pino-http'
import { logger } from '@/lib/logger'

type Env = {
  Variables: {
    log: pino.Logger
  }
}

export const loggerMiddleware = createMiddleware<Env>(async (c, next) => {
  // Hono의 request-id를 pino-http에 전달
  c.env.incoming.id = c.req.header('x-request-id') ?? crypto.randomUUID()

  // pino-http 미들웨어 실행
  await new Promise((resolve) =>
    pinoHttp({ logger })(c.env.incoming, c.env.outgoing, () => resolve(undefined))
  )

  // child logger를 변수로 설정
  c.set('log', c.env.incoming.log)

  await next()
})
```

### 방법 2: 간단한 커스텀 미들웨어 (권장)

```typescript
// middleware/logger.ts
import { createMiddleware } from 'hono/factory'
import { logger } from '@/lib/logger'
import type { Logger } from 'pino'

type Env = {
  Variables: {
    log: Logger
    requestId: string
  }
}

export const loggerMiddleware = createMiddleware<Env>(async (c, next) => {
  const requestId = c.req.header('x-request-id') ?? crypto.randomUUID()
  const start = Date.now()

  // 요청별 child logger 생성
  const log = logger.child({
    requestId,
    method: c.req.method,
    path: c.req.path,
  })

  c.set('log', log)
  c.set('requestId', requestId)

  log.info('Request started')

  await next()

  const duration = Date.now() - start
  log.info({ status: c.res.status, duration: `${duration}ms` }, 'Request completed')
})
```

### App에 적용

```typescript
// index.ts
import { Hono } from 'hono'
import { loggerMiddleware } from '@/middleware/logger'

const app = new Hono()

// 모든 라우트에 로깅 미들웨어 적용
app.use(loggerMiddleware)

app.get('/users/:id', async (c) => {
  const log = c.get('log')
  const id = c.req.param('id')

  log.info({ userId: id }, 'Fetching user')

  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    log.warn({ userId: id }, 'User not found')
    return c.json({ error: 'User not found' }, 404)
  }

  log.debug({ user }, 'User fetched')
  return c.json({ user })
})

export default app
```

---

## 로그 레벨

```typescript
const log = c.get('log')

log.trace('매우 상세한 디버깅 정보')  // level: 10
log.debug('디버깅 정보')              // level: 20
log.info('일반 정보')                 // level: 30
log.warn('경고')                      // level: 40
log.error('에러')                     // level: 50
log.fatal('치명적 에러')              // level: 60
```

### 레벨별 사용 가이드

| 레벨 | 용도 | 예시 |
|------|------|------|
| `trace` | 매우 상세한 흐름 추적 | 함수 진입/종료, 변수 값 |
| `debug` | 개발 중 디버깅 | 쿼리 결과, 중간 계산값 |
| `info` | 주요 이벤트 | 사용자 생성, 결제 완료 |
| `warn` | 주의 필요 | 재시도 발생, 느린 쿼리 |
| `error` | 에러 발생 | API 실패, 예외 처리 |
| `fatal` | 시스템 중단 | 서버 시작 실패 |

---

## 구조화된 로깅 패턴

### 객체와 메시지 함께 로깅

```typescript
// ✅ 올바른 패턴: 객체 먼저, 메시지 나중
log.info({ userId: '123', action: 'login' }, 'User logged in')

// ❌ 잘못된 패턴: 문자열 연결
log.info('User ' + userId + ' logged in')  // 구조화되지 않음
```

### 에러 로깅

```typescript
app.get('/risky', async (c) => {
  const log = c.get('log')

  try {
    await riskyOperation()
  } catch (error) {
    // ✅ err 키로 에러 객체 전달 (스택 트레이스 자동 포함)
    log.error({ err: error, context: 'riskyOperation' }, 'Operation failed')
    throw error
  }
})
```

**출력**:
```json
{
  "level": 50,
  "time": 1705312245000,
  "requestId": "req_abc123",
  "method": "GET",
  "path": "/risky",
  "err": {
    "type": "Error",
    "message": "Connection refused",
    "stack": "Error: Connection refused\n    at ..."
  },
  "context": "riskyOperation",
  "msg": "Operation failed"
}
```

---

## 서비스 레이어에서 사용

### Child Logger 전달 패턴

```typescript
// services/user.ts
import type { Logger } from 'pino'
import { prisma } from '@/database/prisma'

export const createUser = async (
  data: CreateUserInput,
  log: Logger  // child logger 전달받음
) => {
  log.info({ email: data.email }, 'Creating user')

  const user = await prisma.user.create({ data })

  log.info({ userId: user.id }, 'User created')
  return user
}
```

```typescript
// routes/users.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { createUser } from '@/services/user'
import { createUserSchema } from '@/validators/user'

const users = new Hono()

users.post('/', zValidator('json', createUserSchema), async (c) => {
  const log = c.get('log')
  const data = c.req.valid('json')

  const user = await createUser(data, log)
  return c.json({ user }, 201)
})

export { users }
```

---

## 고급 설정

### pino-pretty 전체 옵션

```typescript
// lib/logger.ts
import pino from 'pino'

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport:
    process.env.NODE_ENV === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
            translateTime: 'SYS:yyyy-mm-dd HH:MM:ss.l',
            ignore: 'pid,hostname',
            singleLine: false,
            levelFirst: true,
            messageFormat: '{levelLabel} - {msg}',
            customColors: 'info:blue,warn:yellow,error:red,fatal:bgRed',
            errorProps: 'stack,code,cause',
          },
        }
      : undefined,
})
```

### TypeScript 타입 강제

```typescript
// types/pino.d.ts
declare module 'pino' {
  interface LogFnFields {
    userId?: string
    requestId?: string
    action?: string
  }
}
```

---

## 글로벌 에러 핸들러와 통합

```typescript
// index.ts
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { logger } from '@/lib/logger'

const app = new Hono()

app.onError((err, c) => {
  const log = c.get('log') ?? logger

  if (err instanceof HTTPException) {
    log.warn({ status: err.status, message: err.message }, 'HTTP Exception')
    return c.json({ error: err.message }, err.status)
  }

  log.error({ err }, 'Unhandled error')
  return c.json({ error: 'Internal Server Error' }, 500)
})
```

---

## 프로덕션 설정

### 환경 변수

```bash
# .env
LOG_LEVEL=info  # production
# LOG_LEVEL=debug  # staging
```

### 멀티 스트림 (파일 + stdout)

```typescript
import pino from 'pino'

const streams = [
  { level: 'info', stream: process.stdout },
  { level: 'error', stream: pino.destination('./logs/error.log') },
]

export const logger = pino(
  { level: 'debug' },
  pino.multistream(streams)
)
```

---

## Cloudflare Workers 주의사항

Cloudflare Workers에서는 `pino-pretty` transport를 사용할 수 없습니다. 대신 JSON 출력을 사용하세요:

```typescript
// lib/logger.ts (Cloudflare Workers)
import pino from 'pino'

export const logger = pino({
  level: 'info',
  // transport 옵션 제거 (Workers에서는 지원 안 됨)
})
```

로컬 개발 시 CLI에서 pino-pretty 사용:

```bash
wrangler dev | npx pino-pretty
```

---

## ❌ 하지 말아야 할 것

```typescript
// ❌ 민감한 정보 로깅 금지
log.info({ password: user.password }, 'User logged in')

// ❌ 문자열 연결 사용 금지
log.info('User ' + userId + ' created at ' + new Date())

// ❌ console.log 사용 금지 (pino 사용하세요)
console.log('Processing request')  // ❌
log.info('Processing request')     // ✅

// ❌ 로그 레벨 무시 금지
log.debug('중요한 에러 발생!')  // ❌ error 레벨 사용해야 함
log.error('중요한 에러 발생!')  // ✅
```

---

## 관련 문서

- [미들웨어](../hono/middleware.md)
- [에러 처리](../hono/error-handling.md)
- [아키텍처](../../architecture/architecture.md)
