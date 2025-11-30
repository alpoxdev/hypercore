# Better Auth - 플러그인

> **상위 문서**: [Better Auth](./index.md)

## Multi-Session Plugin

여러 계정으로 동시 로그인을 지원합니다.

### 서버 설정

```typescript
import { betterAuth } from 'better-auth'
import { multiSession } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    multiSession({
      maximumSessions: 5, // 최대 동시 세션 수
    }),
  ],
})
```

### 클라이언트 사용

```typescript
import { createAuthClient } from 'better-auth/client'
import { multiSessionClient } from 'better-auth/client/plugins'

export const authClient = createAuthClient({
  plugins: [multiSessionClient()],
})

// 활성 세션 목록 조회
const { data: sessions } = await authClient.multiSession.listSessions()

sessions?.forEach((session) => {
  console.log(`Device: ${session.userAgent}, Last active: ${session.updatedAt}`)
})

// 특정 세션 취소
await authClient.multiSession.revokeSession({
  sessionId: 'session_456',
})

// 다른 모든 세션 취소
await authClient.multiSession.revokeOtherSessions()
```

## Polar Checkout Plugin

결제 통합을 위한 플러그인입니다.

```typescript
import { polar, checkout } from '@polar-sh/better-auth'

const auth = betterAuth({
  plugins: [
    polar({
      use: [
        checkout({
          products: [{ productId: '123-456-789', slug: 'pro' }],
          successUrl: '/success?checkout_id={CHECKOUT_ID}',
          authenticatedUsersOnly: true,
        }),
      ],
    }),
  ],
})

// 클라이언트
import { polarClient } from '@polar-sh/better-auth'

export const authClient = createAuthClient({
  plugins: [polarClient()],
})
```

## 플러그인 조합

```typescript
import { betterAuth } from 'better-auth'
import {
  multiSession,
  customSession,
  twoFactor,
  captcha
} from 'better-auth/plugins'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  plugins: [
    multiSession({ maximumSessions: 5 }),
    customSession({
      schema: {
        session: {
          fields: {
            ipAddress: { type: 'string', required: false },
          },
        },
      },
    }),
    twoFactor({ issuer: 'My App' }),
    captcha({
      provider: 'recaptcha',
      siteKey: process.env.RECAPTCHA_SITE_KEY!,
      secretKey: process.env.RECAPTCHA_SECRET_KEY!,
    }),
  ],
})
```
