# Better Auth - 설치 및 설정

> **상위 문서**: [Better Auth](./index.md)

## 설치

```bash
yarn add better-auth
```

## 서버 설정

### 기본 설정

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { prisma } from './prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),

  // 이메일/비밀번호 인증 활성화
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: false,
  },
})
```

### 소셜 로그인 설정

```typescript
import { betterAuth } from 'better-auth'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID as string,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET as string,
    },
    github: {
      clientId: process.env.GITHUB_CLIENT_ID as string,
      clientSecret: process.env.GITHUB_CLIENT_SECRET as string,
    },
    spotify: {
      clientId: process.env.SPOTIFY_CLIENT_ID as string,
      clientSecret: process.env.SPOTIFY_CLIENT_SECRET as string,
    },
  },
})
```

## 클라이언트 설정

### 기본 클라이언트

```typescript
// lib/auth-client.ts
import { createAuthClient } from 'better-auth/client'

export const authClient = createAuthClient({
  // 옵션
})
```

### React 클라이언트

```typescript
import { createAuthClient } from 'better-auth/react'

export const authClient = createAuthClient({
  // 옵션
})
```

### 플러그인 포함 클라이언트

```typescript
import { createAuthClient } from 'better-auth/client'
import { twoFactorClient } from 'better-auth/client/plugins'

const authClient = createAuthClient({
  plugins: [
    twoFactorClient({
      twoFactorPage: '/two-factor',
      onTwoFactorRedirect() {
        router.push('/two-factor')
      },
    }),
  ],
})
```

## TanStack Start 통합

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { prisma } from './prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: {
    enabled: true,
  },
})

// Server Function에서 사용
import { createServerFn } from '@tanstack/react-start'
import { auth } from '@/lib/auth'

export const getSession = createServerFn({ method: 'GET' })
  .handler(async ({ request }) => {
    const session = await auth.api.getSession({
      headers: request.headers,
    })
    return session
  })
```
