# Better Auth

> v1.x | TypeScript Authentication Framework

<context>

**Purpose:** Framework-agnostic authentication and authorization for TypeScript
**Features:** Email/Password, Social OAuth, 2FA, Passkeys, Multi-session, SSO

</context>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **보안** | 하드코딩된 시크릿, HTTP 프로덕션 배포 |
| **클라이언트** | 직접 세션 조작, 토큰 localStorage 저장 |
| **서버** | `authClient` 사용 (서버는 `auth.api.*`) |
| **설정** | 절대 경로 하드코딩 (환경변수 사용) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **환경변수** | `BETTER_AUTH_SECRET` (32+ chars), `BETTER_AUTH_URL` |
| **서버** | `auth.api.getSession()` 사용 |
| **클라이언트** | `authClient.*` 메서드 사용 |
| **프로덕션** | HTTPS, 환경별 `baseURL` 설정 |

</required>

---

<installation>

## Installation

```bash
npm install better-auth
```

## Environment Variables

```bash
# .env
BETTER_AUTH_SECRET="$(openssl rand -base64 32)"
BETTER_AUTH_URL="http://localhost:3000"
```

</installation>

---

<setup>

## Minimal Setup

```typescript
// src/lib/auth.ts - Server
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { prisma } from '@/database/prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma, { provider: 'postgresql' }),
  emailAndPassword: { enabled: true },
})

// src/lib/auth-client.ts - Client
import { createAuthClient } from 'better-auth/react'

export const authClient = createAuthClient({
  baseURL: 'http://localhost:3000',
})
```

## TanStack Start Handler

```typescript
// src/routes/api/auth/$.ts
import { auth } from '@/lib/auth'

export const GET = async ({ request }: { request: Request }) => auth.handler(request)
export const POST = async ({ request }: { request: Request }) => auth.handler(request)
```

## Database Adapters

| Adapter | Import | Provider |
|---------|--------|----------|
| **Prisma** | `better-auth/adapters/prisma` | `postgresql`, `mysql`, `sqlite` |
| **Drizzle** | `better-auth/adapters/drizzle` | `pg`, `mysql2`, `better-sqlite3` |
| **Kysely** | `better-auth/adapters/kysely` | dialect 기반 |

## Config Options

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `database` | `Adapter` | 필수 | DB 어댑터 |
| `baseURL` | `string` | `http://localhost:3000` | 앱 URL |
| `basePath` | `string` | `/api/auth` | Auth 경로 |
| `secret` | `string` | 환경변수 | JWT 시크릿 |
| `trustedOrigins` | `string[]` | `[]` | CORS 허용 오리진 |

</setup>

---

<auth_methods>

## Email & Password

```typescript
// ✅ 서버 설정
export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: false,
    sendResetPassword: async ({ user, url }) => {
      await sendEmail({
        to: user.email,
        subject: 'Reset Password',
        html: `<a href="${url}">Reset</a>`,
      })
    },
  },
})

// ✅ 회원가입
await authClient.signUp.email({
  email: 'user@example.com',
  password: 'password123',
  name: 'User Name',
})

// ✅ 로그인
await authClient.signIn.email({
  email: 'user@example.com',
  password: 'password123',
})

// ✅ 비밀번호 재설정
await authClient.forgetPassword({ email: 'user@example.com' })
await authClient.resetPassword({ token, password: 'newpassword' })
```

## Social OAuth

```typescript
// ✅ 서버 설정
export const auth = betterAuth({
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },
})

// ✅ 클라이언트 로그인
await authClient.signIn.social({ provider: 'google', callbackURL: '/dashboard' })
await authClient.signIn.social({ provider: 'github', callbackURL: '/dashboard' })
```

## Two-Factor Authentication

```typescript
// ✅ 서버 플러그인
import { twoFactor } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    twoFactor({
      issuer: 'My App',
      otpOptions: {
        async sendOTP({ user, otp }) {
          await sendEmail({
            to: user.email,
            subject: 'Your OTP Code',
            html: `Your code: ${otp}`,
          })
        },
        period: 300,  // 5분
        length: 6,    // 6자리
      },
      backupCodeLength: 10,
      backupCodeCount: 10,
    }),
  ],
})

// ✅ 클라이언트 플러그인
import { twoFactorClient } from 'better-auth/client/plugins'

export const authClient = createAuthClient({
  plugins: [
    twoFactorClient({
      twoFactorPage: '/two-factor',
    }),
  ],
})

// ✅ TOTP 활성화
const { data } = await authClient.twoFactor.enable({ password: 'current-password' })
// → { totpURI: 'otpauth://...', backupCodes: ['ABCD-1234', ...] }

// ✅ TOTP 검증
await authClient.twoFactor.verifyTotp({ code: '123456' })

// ✅ OTP 전송/검증
await authClient.twoFactor.sendOtp()
await authClient.twoFactor.verifyOtp({ code: '123456' })

// ✅ 백업 코드
await authClient.twoFactor.useBackupCode({ code: 'ABCD-1234' })
await authClient.twoFactor.regenerateBackupCodes({ password: 'current-password' })

// ✅ 2FA 비활성화
await authClient.twoFactor.disable({ password: 'current-password' })
```

</auth_methods>

---

<session>

## Session Config

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `expiresIn` | `number` | `604800` (7일) | 세션 만료 (초) |
| `updateAge` | `number` | `86400` (1일) | 세션 갱신 주기 (초) |
| `cookieCache.enabled` | `boolean` | `true` | 쿠키 캐시 활성화 |
| `cookieCache.maxAge` | `number` | `300` (5분) | 캐시 유효 시간 (초) |
| `cookieCache.strategy` | `'compact' \| 'jwt' \| 'jwe'` | `'compact'` | 캐시 전략 |

```typescript
export const auth = betterAuth({
  session: {
    expiresIn: 604800,
    updateAge: 86400,
    cookieCache: {
      enabled: true,
      maxAge: 300,
      strategy: 'compact',
    },
  },
})
```

## Session Methods

| 환경 | 메서드 |
|------|--------|
| **클라이언트** | `authClient.getSession()` |
| **서버** | `auth.api.getSession({ headers })` |

```typescript
// ✅ 클라이언트
const session = await authClient.getSession()
const session = await authClient.getSession({ query: { disableCookieCache: true } })

// ✅ 서버 (TanStack Start)
export const getSession = createServerFn({ method: 'GET' })
  .handler(async ({ request }) => {
    const session = await auth.api.getSession({ headers: request.headers })
    return session
  })

// ✅ 세션 업데이트
await authClient.updateUser({ name: 'New Name' })

// ✅ 로그아웃
await authClient.signOut()
```

## Custom Session Fields

```typescript
import { customSession } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    customSession({
      schema: {
        session: {
          fields: {
            ipAddress: { type: 'string' },
            userAgent: { type: 'string' },
            metadata: { type: 'json' },
          },
        },
      },
      async onSessionCreate(session, context) {
        return {
          ...session,
          ipAddress: context.request.headers.get('x-forwarded-for') || 'unknown',
          userAgent: context.request.headers.get('user-agent') || 'unknown',
        }
      },
    }),
  ],
})
```

</session>

---

<plugins>

## Plugin System

| Plugin | 기능 |
|--------|------|
| `twoFactor` | TOTP, OTP, 백업 코드 |
| `multiSession` | 다중 세션 관리 |
| `customSession` | 세션 필드 확장 |
| `captcha` | reCAPTCHA 검증 |

## Multi-Session

```typescript
// ✅ 서버
import { multiSession } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    multiSession({
      maximumSessions: 5,
    }),
  ],
})

// ✅ 클라이언트
import { multiSessionClient } from 'better-auth/client/plugins'

export const authClient = createAuthClient({
  plugins: [multiSessionClient()],
})

// ✅ 사용
const sessions = await authClient.multiSession.listSessions()
await authClient.multiSession.revokeSession({ sessionId: 'session-id' })
await authClient.multiSession.revokeOtherSessions()
```

## CAPTCHA

```typescript
// ✅ 서버
import { captcha } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    captcha({
      provider: 'recaptcha',
      siteKey: process.env.RECAPTCHA_SITE_KEY!,
      secretKey: process.env.RECAPTCHA_SECRET_KEY!,
      protectEndpoints: ['/sign-up/email', '/sign-in/email'],
    }),
  ],
})

// ✅ 클라이언트
import { captchaClient } from 'better-auth/client/plugins'

export const authClient = createAuthClient({
  plugins: [
    captchaClient({
      siteKey: process.env.NEXT_PUBLIC_RECAPTCHA_SITE_KEY!,
    }),
  ],
})
```

</plugins>

---

<advanced>

## SIWE (Ethereum)

```typescript
// ✅ 서버
import { siwe } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    siwe({
      domain: 'example.com',
      uri: 'https://example.com',
    }),
  ],
})

// ✅ 클라이언트
const { data } = await authClient.siwe.getNonce()
const message = await authClient.siwe.prepareMessage({
  address: '0x...',
  nonce: data.nonce,
})
const signature = await signer.signMessage(message)
await authClient.siwe.signIn({ message, signature })
```

## Stateless Mode

```typescript
// ✅ DB 없이 소셜 로그인만
export const auth = betterAuth({
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
})
```

## Redis Secondary Storage

```typescript
import { Redis } from 'ioredis'

const redis = new Redis()

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  secondaryStorage: {
    get: async (key: string) => {
      const value = await redis.get(key)
      return value ? JSON.parse(value) : null
    },
    set: async (key: string, value: any, ttl: number) => {
      await redis.set(key, JSON.stringify(value), 'EX', ttl)
    },
    delete: async (key: string) => {
      await redis.del(key)
    },
  },
})
```

</advanced>

---

<patterns>

## TanStack Start Integration

| 패턴 | 파일 |
|------|------|
| API Handler | `src/routes/api/auth/$.ts` |
| Server Function | `createServerFn` + `auth.api.getSession` |
| Middleware | `auth.api.getSession` + redirect |

### Server Function Pattern

```typescript
// ✅ 인증 체크
export const requireAuth = createServerFn({ method: 'GET' })
  .handler(async ({ request }) => {
    const session = await auth.api.getSession({ headers: request.headers })
    if (!session?.user) {
      throw redirect({ to: '/login' })
    }
    return session.user
  })

// ✅ 보호된 데이터 조회
export const getProtectedData = createServerFn({ method: 'GET' })
  .handler(async ({ request }) => {
    const user = await requireAuth()
    return prisma.data.findMany({ where: { userId: user.id } })
  })
```

### Route Protection

```typescript
// ✅ Route Loader
export const Route = createFileRoute('/dashboard')({
  component: Dashboard,
  async loader() {
    const user = await requireAuth()
    const data = await getProtectedData()
    return { user, data }
  },
})
```

## Common Patterns

| 작업 | 패턴 |
|------|------|
| 로그인 | `authClient.signIn.email({ email, password })` |
| 회원가입 | `authClient.signUp.email({ email, password, name })` |
| 로그아웃 | `authClient.signOut()` |
| 세션 조회 | `authClient.getSession()` |
| 사용자 업데이트 | `authClient.updateUser({ name })` |
| 비밀번호 재설정 | `authClient.forgetPassword({ email })` → `authClient.resetPassword({ token, password })` |

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|----------|
| `auth.api.getSession()` 서버에서 사용 | 클라이언트에서 직접 세션 조작 |
| `authClient` 클라이언트에서 사용 | 하드코딩된 시크릿 |
| 환경변수로 시크릿 관리 | 세션 토큰 localStorage 저장 |
| HTTPS 프로덕션 필수 | HTTP 프로덕션 배포 |
| `baseURL` 환경별 설정 | 절대 경로 하드코딩 |

</patterns>
