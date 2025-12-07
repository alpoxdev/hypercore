# Better Auth

> TypeScript Authentication Library

@setup.md
@session.md
@plugins.md
@2fa.md
@advanced.md

## Quick Reference

```typescript
// 서버
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: { enabled: true },
})

// 클라이언트
import { createAuthClient } from 'better-auth/react'
export const authClient = createAuthClient({})

// 로그인/가입
await authClient.signIn.email({ email, password })
await authClient.signUp.email({ email, password, name })

// 세션
const session = await authClient.getSession()  // 클라이언트
const session = await auth.api.getSession({ headers })  // 서버
```
