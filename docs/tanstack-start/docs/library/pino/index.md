# Pino - Structured Logging

> 초고속 JSON 로거 (Server Functions 전용)

---

## ⚠️ 중요: Server Functions에서만 사용

Pino는 **Server Functions에서만** 사용해야 합니다. 클라이언트 컴포넌트에서는 사용하지 마세요.

```
✅ src/functions/*.ts          → Pino 사용 가능
✅ routes/*/-functions/*.ts    → Pino 사용 가능
❌ routes/*.tsx (컴포넌트)      → Pino 사용 금지 (console.log 사용)
❌ components/*.tsx            → Pino 사용 금지
```

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

## Server Functions에서 사용

### 기본 사용법

```typescript
// functions/user.ts
import { createServerFn } from '@tanstack/react-start'
import { logger } from '@/lib/logger'
import { prisma } from '@/database/prisma'
import { createUserSchema } from '@/validators/user'
import { authMiddleware } from '@/middleware/auth'

export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data, context }) => {
    logger.info({ email: data.email }, 'Creating new user')

    try {
      const user = await prisma.user.create({ data })
      logger.info({ userId: user.id }, 'User created successfully')
      return user
    } catch (error) {
      logger.error({ error, email: data.email }, 'Failed to create user')
      throw error
    }
  })
```

### Child Logger로 요청 컨텍스트 추가

```typescript
// functions/user.ts
import { createServerFn } from '@tanstack/react-start'
import { logger } from '@/lib/logger'
import { prisma } from '@/database/prisma'

export const getUser = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    // 요청별 컨텍스트가 포함된 child logger 생성
    const log = logger.child({
      requestId: context.requestId,
      userId: context.userId,
    })

    log.info('Fetching user profile')

    const user = await prisma.user.findUnique({
      where: { id: context.userId },
    })

    if (!user) {
      log.warn('User not found')
      throw new Error('User not found')
    }

    log.debug({ user }, 'User fetched successfully')
    return user
  })
```

**출력 예시**:
```json
{"level":30,"time":1705312245000,"requestId":"req_abc123","userId":"user_456","msg":"Fetching user profile"}
{"level":20,"time":1705312245050,"requestId":"req_abc123","userId":"user_456","user":{"id":"user_456","name":"John"},"msg":"User fetched successfully"}
```

---

## 로그 레벨

```typescript
logger.trace('매우 상세한 디버깅 정보')  // level: 10
logger.debug('디버깅 정보')              // level: 20
logger.info('일반 정보')                 // level: 30
logger.warn('경고')                      // level: 40
logger.error('에러')                     // level: 50
logger.fatal('치명적 에러')              // level: 60
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
logger.info({ userId: '123', action: 'login' }, 'User logged in')

// ❌ 잘못된 패턴: 문자열 연결
logger.info('User ' + userId + ' logged in')  // 구조화되지 않음
```

### 에러 로깅

```typescript
try {
  await riskyOperation()
} catch (error) {
  // ✅ err 키로 에러 객체 전달 (스택 트레이스 자동 포함)
  logger.error({ err: error, context: 'riskyOperation' }, 'Operation failed')
}
```

**출력**:
```json
{
  "level": 50,
  "time": 1705312245000,
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

```typescript
// 사용 시 타입 검사
logger.info({ userId: '123' }, 'User action')  // ✅
logger.info({ userId: 123 }, 'User action')    // ❌ 타입 에러
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

## ❌ 하지 말아야 할 것

```typescript
// ❌ 클라이언트 컴포넌트에서 pino 사용 금지
const MyComponent = () => {
  logger.info('Component rendered')  // ❌ 서버에서만 동작
  return <div>Hello</div>
}

// ❌ 민감한 정보 로깅 금지
logger.info({ password: user.password }, 'User logged in')  // ❌

// ❌ 문자열 연결 사용 금지
logger.info('User ' + userId + ' created at ' + new Date())  // ❌

// ❌ console.log와 혼용 금지 (Server Functions에서)
console.log('Processing...')  // ❌ pino 사용하세요
logger.info('Processing...')  // ✅
```

---

## 관련 문서

- [Server Functions](../tanstack-start/server-functions.md)
- [미들웨어](../tanstack-start/middleware.md)
- [아키텍처](../../architecture/architecture.md)
