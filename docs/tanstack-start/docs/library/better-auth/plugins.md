# Better Auth - 플러그인

## Multi-Session

```typescript
// 서버
import { multiSession } from 'better-auth/plugins'
plugins: [multiSession({ maximumSessions: 5 })]

// 클라이언트
import { multiSessionClient } from 'better-auth/client/plugins'
plugins: [multiSessionClient()]

// 사용
await authClient.multiSession.listSessions()
await authClient.multiSession.revokeSession({ sessionId })
await authClient.multiSession.revokeOtherSessions()
```

## 플러그인 조합

```typescript
import { multiSession, customSession, twoFactor, captcha } from 'better-auth/plugins'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  plugins: [
    multiSession({ maximumSessions: 5 }),
    customSession({ schema: { session: { fields: { ipAddress: { type: 'string' } } } } }),
    twoFactor({ issuer: 'My App' }),
    captcha({ provider: 'recaptcha', siteKey: SITE_KEY, secretKey: SECRET_KEY }),
  ],
})
```
