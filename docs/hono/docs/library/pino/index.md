# Pino - Structured Logging

> 초고속 JSON 로거

---

## 설치

```bash
npm install pino pino-pretty
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

---

## 로그 레벨

```typescript
logger.debug({ data }, 'Debug message')  // 10
logger.info({ userId }, 'User logged in') // 30
logger.warn({ attempt }, 'Rate limit')    // 40
logger.error({ err }, 'Failed')           // 50
logger.fatal({ err }, 'Crash')            // 60
```

---

## Hono 통합

### 미들웨어

```typescript
import { createMiddleware } from 'hono/factory'
import { logger } from '@/lib/logger'

type Env = { Variables: { log: pino.Logger } }

export const loggerMiddleware = createMiddleware<Env>(async (c, next) => {
  const requestId = c.req.header('x-request-id') ?? crypto.randomUUID()
  const log = logger.child({ requestId })

  c.set('log', log)

  const start = Date.now()
  await next()

  log.info({
    method: c.req.method,
    path: c.req.path,
    status: c.res.status,
    duration: Date.now() - start,
  }, 'Request completed')
})
```

### 사용

```typescript
app.use(loggerMiddleware)

app.post('/users', async (c) => {
  const log = c.get('log')
  const data = c.req.valid('json')

  log.info({ email: data.email }, 'Creating user')

  const user = await prisma.user.create({ data })
  log.info({ userId: user.id }, 'User created')

  return c.json({ user }, 201)
})
```

---

## Child Logger

```typescript
const log = logger.child({
  requestId: 'abc-123',
  userId: 'user-456',
})

log.info('Message with context')
// {"requestId":"abc-123","userId":"user-456","msg":"Message with context"}
```

---

## 에러 로깅

```typescript
app.onError((err, c) => {
  const log = c.get('log')

  log.error({
    err: {
      message: err.message,
      stack: err.stack,
      name: err.name,
    },
    path: c.req.path,
  }, 'Request failed')

  return c.json({ error: 'Internal Server Error' }, 500)
})
```

---

## 프로덕션 출력

```json
{"level":30,"time":1705312245000,"requestId":"abc-123","msg":"Request completed","method":"POST","path":"/users","status":201,"duration":45}
```

---

## 관련 문서

- [Hono 미들웨어](../hono/middleware.md)
