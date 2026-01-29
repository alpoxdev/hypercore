# Consola

> **Version 3.x** | Elegant Console Logger for Node.js & Browser

---

<context>

**Purpose:** 타입 안전하고 우아한 콘솔 로깅 라이브러리

**Key Features:**
- 우아한 콘솔 출력 (색상, 아이콘, 포맷팅)
- 로그 레벨 관리 (0-5, Silent, Verbose)
- 커스텀 리포터 지원
- 테스트 환경 Mock 지원
- 타입스크립트 완벽 지원
- 작은 번들 크기 (`consola/basic`, `consola/core` - 80% 크기 감소)

**Bundle Size:**
- `consola`: ~8KB (전체 기능)
- `consola/basic`: ~2KB (기본 로깅)
- `consola/core`: ~1KB (최소 기능)

</context>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **로깅** | ❌ `console.log()` 직접 사용 (consola 사용) |
| **로그 레벨** | ❌ 프로덕션 환경에서 로그 레벨 미설정 |
| **에러 핸들링** | ❌ 에러를 `console.error()` 직접 출력 |
| **테스트** | ❌ 테스트에서 실제 콘솔 출력 (Mock 사용) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **환경 변수** | ✅ `CONSOLA_LEVEL` 설정 (프로덕션) |
| **로그 레벨** | ✅ 프로덕션: 3 (log) 이하, 개발: 4 (debug) 이상 |
| **에러 처리** | ✅ `consola.error()` 사용 |
| **테스트** | ✅ `mockTypes()` 또는 `pauseLogs()` 사용 |
| **Hono** | ✅ Middleware 및 Route Handler에서 consola 사용 |

</required>

---

<installation>

## 설치

```bash
npm install consola@^3.0.0
```

## Bundle 최적화

```typescript
// ✅ 전체 기능 (8KB)
import { consola } from 'consola'

// ✅ 기본 로깅 (2KB, 80% 크기 감소)
import { consola } from 'consola/basic'

// ✅ 최소 기능 (1KB)
import { consola } from 'consola/core'
```

**권장사항:**
- 서버: `consola` (전체 기능) 또는 `consola/basic` (크기 최적화)

</installation>

---

<basic_usage>

## 기본 사용법

```typescript
import { consola } from 'consola'

// 기본 로그 레벨 (0-5)
consola.fatal('Fatal error!')        // 0: 치명적 에러
consola.error('Error occurred!')     // 1: 에러
consola.warn('Warning message')      // 2: 경고
consola.log('Log message')           // 3: 일반 로그 (기본값)
consola.info('Info message')         // 4: 정보
consola.debug('Debug message')       // 5: 디버그
consola.trace('Trace message')       // 5: 추적
consola.verbose('Verbose message')   // +999: 상세 로그
consola.silent('Silent message')     // -999: 출력 안 됨

// 성공/시작/준비 메시지
consola.success('Task completed!')   // ✅ 성공
consola.start('Starting task...')    // ⏳ 시작
consola.ready('Server is ready!')    // ✅ 준비 완료

// 박스 출력
consola.box('Important Message')     // 박스로 감싸서 출력
```

## 로거 생성

```typescript
import { createConsola } from 'consola'

// 커스텀 태그
const logger = createConsola({
  level: 4,  // info 레벨까지 출력
  fancy: true,  // 색상 및 아이콘 사용
  formatOptions: {
    date: true,  // 타임스탬프 표시
  },
})

// 태그 추가
const apiLogger = logger.withTag('API')
apiLogger.info('Request received')  // [API] Request received
```

## 환경 변수

```bash
# 로그 레벨 설정
CONSOLA_LEVEL=3  # 0: fatal, 1: error, 2: warn, 3: log, 4: info, 5: debug/trace

# 프로덕션
CONSOLA_LEVEL=3  # log까지만 출력

# 개발
CONSOLA_LEVEL=5  # 모든 로그 출력
```

</basic_usage>

---

<log_levels>

## 로그 레벨

| 레벨 | 값 | 메서드 | 사용 |
|------|------|--------|------|
| **fatal** | 0 | `consola.fatal()` | 치명적 에러 (프로세스 종료) |
| **error** | 1 | `consola.error()` | 에러 발생 |
| **warn** | 2 | `consola.warn()` | 경고 메시지 |
| **log** | 3 | `consola.log()` | 일반 로그 (기본값) |
| **info** | 4 | `consola.info()` | 정보성 메시지 |
| **debug** | 5 | `consola.debug()` | 디버그 정보 |
| **trace** | 5 | `consola.trace()` | 추적 정보 |
| **verbose** | +999 | `consola.verbose()` | 상세 로그 |
| **silent** | -999 | `consola.silent()` | 출력 안 됨 |

### 로그 레벨 설정

```typescript
import { consola } from 'consola'

// 레벨 설정
consola.level = 3  // log까지만 출력
consola.level = 5  // 모든 로그 출력 (debug/trace 포함)

// 환경별 설정
if (process.env.NODE_ENV === 'production') {
  consola.level = 2  // warn, error, fatal만 출력
} else {
  consola.level = 5  // 개발 환경: 모든 로그 출력
}
```

### 환경 변수로 제어

```bash
# .env.production
CONSOLA_LEVEL=2  # warn, error, fatal

# .env.development
CONSOLA_LEVEL=5  # 모든 로그
```

</log_levels>

---

<custom_reporters>

## 커스텀 리포터

```typescript
import { consola, createConsola, type ConsolaReporter } from 'consola'

// 파일 리포터
const fileReporter: ConsolaReporter = {
  log(logObj) {
    const message = `[${logObj.date.toISOString()}] ${logObj.type}: ${logObj.args.join(' ')}`
    fs.appendFileSync('app.log', message + '\n')
  },
}

// Sentry 리포터
const sentryReporter: ConsolaReporter = {
  log(logObj) {
    if (logObj.level <= 1) {  // error, fatal
      Sentry.captureException(new Error(logObj.args.join(' ')))
    }
  },
}

// 리포터 추가
const logger = createConsola({
  reporters: [
    consola.options.reporters[0],  // 기본 콘솔 리포터
    fileReporter,
    sentryReporter,
  ],
})

logger.error('This will be logged to console, file, and Sentry')
```

## 프로덕션 리포터 패턴

```typescript
import { createConsola } from 'consola'

// 환경별 리포터 설정
const reporters = [consola.options.reporters[0]]  // 기본 콘솔

if (process.env.NODE_ENV === 'production') {
  // 프로덕션: 파일 + 외부 로깅 서비스
  reporters.push(fileReporter, sentryReporter)
} else {
  // 개발: 콘솔만
}

export const logger = createConsola({
  level: process.env.NODE_ENV === 'production' ? 2 : 5,
  reporters,
})
```

</custom_reporters>

---

<testing>

## 테스트 통합

### Mock 사용

```typescript
import { consola } from 'consola'

describe('User Service', () => {
  beforeEach(() => {
    // 모든 로그 Mock
    consola.mockTypes(() => vi.fn())
  })

  afterEach(() => {
    // Mock 복원
    consola.restoreAll()
  })

  it('should log user creation', async () => {
    const spy = vi.fn()
    consola.mockTypes((type) => spy)

    await createUser({ name: 'Alice' })

    expect(spy).toHaveBeenCalledWith('User created:', 'Alice')
  })
})
```

### Pause/Resume

```typescript
import { consola } from 'consola'

describe('API Tests', () => {
  beforeAll(() => {
    // 테스트 중 로그 일시 중지
    consola.pauseLogs()
  })

  afterAll(() => {
    // 로그 재개
    consola.resumeLogs()
  })

  it('should not log during test', () => {
    consola.log('This will not be printed')
  })
})
```

### Vitest 통합

```typescript
import { consola } from 'consola'
import { beforeEach, afterEach, vi } from 'vitest'

beforeEach(() => {
  consola.mockTypes(() => vi.fn())
})

afterEach(() => {
  consola.restoreAll()
})
```

</testing>

---

<advanced>

## 고급 기능

### Console Redirect

```typescript
import { consola } from 'consola'

// console.log를 consola로 리다이렉트
consola.wrapConsole()

console.log('This uses consola now!')  // consola.log()로 출력됨

// 복원
consola.restoreConsole()
```

**Pause/Resume, Mock 기능:** 자세한 내용은 `<testing>` 및 `<utilities>` 섹션을 참고하세요.

</advanced>

---

<utilities>

## 유틸리티

### withTag

```typescript
import { consola } from 'consola'

// 태그 추가
const apiLogger = consola.withTag('API')
apiLogger.info('Request received')  // [API] Request received

const dbLogger = consola.withTag('DB')
dbLogger.warn('Connection slow')    // [DB] Connection slow

// 다중 태그
const authLogger = consola.withTag('API').withTag('Auth')
authLogger.info('User logged in')   // [API] [Auth] User logged in
```

### wrapConsole

```typescript
import { consola } from 'consola'

// console.* 메서드를 consola로 래핑
consola.wrapConsole()

console.log('Uses consola')     // consola.log()
console.error('Uses consola')   // consola.error()

// 복원
consola.restoreConsole()
```

### wrapStd

```typescript
import { consola } from 'consola'

// process.stdout/stderr를 consola로 래핑
consola.wrapStd()

process.stdout.write('Uses consola\n')  // consola.log()
process.stderr.write('Uses consola\n')  // consola.error()

// 복원
consola.restoreStd()
```

### wrapAll

```typescript
import { consola } from 'consola'

// console + process.std* 모두 래핑
consola.wrapAll()

console.log('Uses consola')
process.stdout.write('Uses consola\n')

// 복원
consola.restoreAll()
```

</utilities>

---

<patterns>

## Hono 패턴

### Middleware에서 consola 사용

```typescript
import { createMiddleware } from 'hono/factory'
import { logger } from '@/lib/logger'

// ✅ 요청 로깅 미들웨어
export const requestLogger = createMiddleware(async (c, next) => {
  const start = Date.now()
  logger.info(`→ ${c.req.method} ${c.req.path}`)

  await next()

  const ms = Date.now() - start
  logger.success(`← ${c.req.method} ${c.req.path} - ${ms}ms`)
})
```

### Route Handler에서 consola 사용

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { logger } from '@/lib/logger'
import { createUserSchema } from '@/schemas/user'

const app = new Hono()

// ✅ GET 요청 로깅
app.get('/users', async (c) => {
  logger.debug('Fetching users...')
  const users = await prisma.user.findMany()
  logger.info(`Found ${users.length} users`)
  return c.json(users)
})

// ✅ POST 요청 로깅 (zValidator + consola)
app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')

  logger.info('Creating user:', data.email)

  try {
    const user = await prisma.user.create({ data })
    logger.success('User created:', user.id)
    return c.json(user, 201)
  } catch (error) {
    logger.error('Failed to create user:', error)
    throw error
  }
})
```

### Error Handler에서 consola 사용

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { logger } from '@/lib/logger'

const app = new Hono()

// ✅ 에러 핸들러
app.onError((err, c) => {
  // HTTPException 처리
  if (err instanceof HTTPException) {
    logger.warn('HTTP Exception:', err.status, err.message)
    return c.json({ error: err.message }, err.status)
  }

  // 일반 에러
  logger.error('Unhandled error:', err)
  return c.json({ error: 'Internal Server Error' }, 500)
})
```

### 환경별 로거 설정

```typescript
// lib/logger.ts
import { createConsola } from 'consola'

export const logger = createConsola({
  level: process.env.NODE_ENV === 'production' ? 2 : 5,  // prod: warn, dev: trace
  fancy: process.env.NODE_ENV !== 'production',  // 개발 환경에서만 색상/아이콘
  formatOptions: {
    date: true,  // 타임스탬프
  },
})

// 사용
import { logger } from '@/lib/logger'

logger.info('Application started')
```

### Sentry 통합 (서버용)

```typescript
import { createConsola, type ConsolaReporter } from 'consola'
import * as Sentry from '@sentry/node'

// Sentry 리포터
const sentryReporter: ConsolaReporter = {
  log(logObj) {
    if (logObj.level <= 1) {  // error, fatal
      Sentry.captureException(new Error(logObj.args.join(' ')), {
        level: logObj.level === 0 ? 'fatal' : 'error',
        tags: {
          type: logObj.type,
        },
      })
    }
  },
}

export const logger = createConsola({
  level: 2,  // warn, error, fatal
  reporters: [
    consola.options.reporters[0],  // 콘솔
    sentryReporter,  // Sentry
  ],
})
```

### 라우트별 로거 생성

```typescript
import { Hono } from 'hono'
import { logger } from '@/lib/logger'

const app = new Hono()

// ✅ 라우트별 태그 로거
app.get('/api/posts', async (c) => {
  const postLogger = logger.withTag('Post')

  postLogger.debug('Fetching posts...')
  const posts = await prisma.post.findMany()
  postLogger.info(`Found ${posts.length} posts`)

  return c.json(posts)
})

app.get('/api/users', async (c) => {
  const userLogger = logger.withTag('User')

  userLogger.debug('Fetching users...')
  const users = await prisma.user.findMany()
  userLogger.info(`Found ${users.length} users`)

  return c.json(users)
})
```

</patterns>

---

<dos_and_donts>

## Do's & Don'ts

### ✅ Do

| 상황 | 방법 |
|------|------|
| **로깅** | `consola.log()` 사용 |
| **에러** | `consola.error()` 사용 |
| **성공** | `consola.success()` 사용 |
| **태그** | `.withTag()` 사용 |
| **환경별** | `CONSOLA_LEVEL` 환경 변수 설정 |
| **테스트** | `mockTypes()` 또는 `pauseLogs()` 사용 |
| **프로덕션** | 로그 레벨 2 이하 (warn, error, fatal) |
| **개발** | 로그 레벨 5 (debug/trace 포함) |

### ❌ Don't

| 상황 | 이유 |
|------|------|
| **console.log** | ❌ 직접 사용 금지 → `consola.log()` 사용 |
| **프로덕션 로그** | ❌ 로그 레벨 미설정 → 불필요한 로그 출력 |
| **테스트 출력** | ❌ 실제 콘솔 출력 → Mock 사용 |
| **에러 무시** | ❌ `console.error()` 직접 사용 → `consola.error()` + 리포터 |

### 환경별 패턴

```typescript
// ❌ 로그 레벨 미설정
import { consola } from 'consola'
consola.debug('This will be printed in production!')  // 불필요한 로그

// ✅ 환경별 로그 레벨 설정
import { createConsola } from 'consola'

export const logger = createConsola({
  level: process.env.NODE_ENV === 'production' ? 2 : 5,
})

logger.debug('This is only printed in development')
```

### 테스트 패턴

```typescript
// ❌ 테스트 중 콘솔 출력
describe('Test', () => {
  it('should work', () => {
    consola.log('This will clutter test output')  // 출력됨
  })
})

// ✅ Mock 사용
describe('Test', () => {
  beforeEach(() => consola.mockTypes(() => vi.fn()))
  afterEach(() => consola.restoreAll())

  it('should work', () => {
    consola.log('This will not clutter test output')  // Mock됨
  })
})
```

</dos_and_donts>

---

<quick_reference>

## Quick Reference

```typescript
// 설치
import { consola } from 'consola'
import { consola } from 'consola/basic'  // 80% 크기 감소

// 기본 로깅
consola.log('Log')
consola.info('Info')
consola.warn('Warning')
consola.error('Error')
consola.success('Success')

// 태그
const logger = consola.withTag('API')
logger.info('Request')  // [API] Request

// 로그 레벨
consola.level = 3  // log까지만 출력
CONSOLA_LEVEL=3    # 환경 변수

// 테스트
consola.mockTypes(() => vi.fn())
consola.pauseLogs()
consola.resumeLogs()
consola.restoreAll()

// 커스텀 리포터
const logger = createConsola({
  reporters: [consola.options.reporters[0], customReporter],
})
```

</quick_reference>
