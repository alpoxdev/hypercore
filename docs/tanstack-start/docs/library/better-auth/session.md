# Better Auth - 세션 관리

> **상위 문서**: [Better Auth](./index.md)

## 세션 설정

```typescript
import { betterAuth } from 'better-auth'

export const auth = betterAuth({
  session: {
    modelName: 'sessions',
    fields: {
      userId: 'user_id',
    },
    expiresIn: 604800, // 7일 (초 단위)
    updateAge: 86400, // 1일마다 갱신
    additionalFields: {
      customField: {
        type: 'string',
      },
    },
  },
})
```

## 쿠키 캐시

세션 조회 성능 최적화를 위한 쿠키 캐시:

```typescript
export const auth = betterAuth({
  session: {
    cookieCache: {
      enabled: true,
      maxAge: 5 * 60, // 5분
      strategy: 'compact', // 'compact' | 'jwt' | 'jwe'
      refreshCache: true,
    },
  },
})
```

## 세션 가져오기

### 클라이언트

```typescript
// 기본
const session = await authClient.getSession()

// 쿠키 캐시 우회 (DB에서 직접 가져오기)
const session = await authClient.getSession({
  query: {
    disableCookieCache: true,
  },
})
```

### 서버

```typescript
await auth.api.getSession({
  query: {
    disableCookieCache: true,
  },
  headers: req.headers,
})
```

## Custom Session Plugin

세션 스키마 확장 및 커스텀 로직 구현:

```typescript
import { betterAuth } from 'better-auth'
import { customSession } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    customSession({
      // 세션 스키마 확장
      schema: {
        session: {
          fields: {
            ipAddress: {
              type: 'string',
              required: false,
            },
            userAgent: {
              type: 'string',
              required: false,
            },
            metadata: {
              type: 'json',
              required: false,
            },
          },
        },
      },

      // 세션 생성 시 커스터마이즈
      async onSessionCreate(session, context) {
        return {
          ...session,
          ipAddress: context.request.headers.get('x-forwarded-for'),
          userAgent: context.request.headers.get('user-agent'),
          metadata: { loginMethod: 'email' },
        }
      },

      // 세션 조회 시 커스터마이즈
      async onSessionGet(session, context) {
        return {
          ...session,
          activeDevices: await getActiveDevices(session.userId),
        }
      },
    }),
  ],
})

// 타입 안전한 커스텀 세션 데이터 접근
const session = await auth.api.getSession({ headers })
console.log('IP Address:', session?.ipAddress)
console.log('Metadata:', session?.metadata)
```
