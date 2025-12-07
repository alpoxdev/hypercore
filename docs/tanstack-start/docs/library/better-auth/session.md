# Better Auth - 세션 관리

## 설정

```typescript
export const auth = betterAuth({
  session: {
    expiresIn: 604800,   // 7일 (초)
    updateAge: 86400,    // 1일마다 갱신
    cookieCache: {
      enabled: true,
      maxAge: 5 * 60,    // 5분
      strategy: 'compact',  // 'compact' | 'jwt' | 'jwe'
    },
  },
})
```

## 세션 조회

```typescript
// 클라이언트
const session = await authClient.getSession()
const session = await authClient.getSession({ query: { disableCookieCache: true } })

// 서버
await auth.api.getSession({ headers: req.headers })
```

## Custom Session Plugin

```typescript
import { customSession } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    customSession({
      schema: {
        session: { fields: { ipAddress: { type: 'string' }, metadata: { type: 'json' } } },
      },
      async onSessionCreate(session, context) {
        return { ...session, ipAddress: context.request.headers.get('x-forwarded-for') }
      },
    }),
  ],
})
```
