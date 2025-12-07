# Better Auth - 설치 및 설정

## 설치

```bash
yarn add better-auth
```

## 서버

```typescript
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: { enabled: true },
  socialProviders: {
    google: { clientId: process.env.GOOGLE_CLIENT_ID, clientSecret: process.env.GOOGLE_CLIENT_SECRET },
    github: { clientId: process.env.GITHUB_CLIENT_ID, clientSecret: process.env.GITHUB_CLIENT_SECRET },
  },
})
```

## 클라이언트

```typescript
import { createAuthClient } from 'better-auth/react'
import { twoFactorClient } from 'better-auth/client/plugins'

export const authClient = createAuthClient({
  plugins: [twoFactorClient({ twoFactorPage: '/two-factor' })],
})
```

## TanStack Start 연동

```typescript
export const getSession = createServerFn({ method: 'GET' })
  .handler(async ({ request }) => auth.api.getSession({ headers: request.headers }))
```
