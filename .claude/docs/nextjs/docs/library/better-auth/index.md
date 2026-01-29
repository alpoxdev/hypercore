# Better Auth

> TypeScript Authentication Library

---

<quick_start>

## Installation

```bash
npm install better-auth
```

## Minimal Setup

```typescript
// src/lib/auth.ts - Server
import { betterAuth } from "better-auth"
import { prismaAdapter } from "better-auth/adapters/prisma"
import { prisma } from "@/database/prisma"

export const auth = betterAuth({
  database: prismaAdapter(prisma, { provider: "postgresql" }),
  emailAndPassword: { enabled: true },
})

// src/lib/auth-client.ts - Client
import { createAuthClient } from "better-auth/react"

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000",
})
```

## Next.js Route Handler

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth"

export const GET = (request: Request) => auth.handler(request)
export const POST = (request: Request) => auth.handler(request)
```

</quick_start>

---

<setup>

## Database Adapters

| Adapter | Import | Provider |
|---------|--------|----------|
| Prisma | `better-auth/adapters/prisma` | `postgresql`, `mysql`, `sqlite` |
| Drizzle | `better-auth/adapters/drizzle` | `pg`, `mysql2`, `better-sqlite3` |
| Kysely | `better-auth/adapters/kysely` | dialect-based |

## Auth Config

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `database` | `Adapter` | required | Database adapter |
| `baseURL` | `string` | `http://localhost:3000` | App URL |
| `basePath` | `string` | `/api/auth` | Auth path |
| `secret` | `string` | environment variable | JWT secret |
| `trustedOrigins` | `string[]` | `[]` | CORS allowed origins |

## Social Providers

```typescript
export const auth = betterAuth({
  database: prismaAdapter(prisma),
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
```

## Email & Password

```typescript
export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: false,
    sendResetPassword: async ({ user, url }) => {
      await sendEmail({
        to: user.email,
        subject: "Reset Password",
        html: `<a href="${url}">Reset</a>`,
      })
    },
  },
})
```

</setup>

---

<session>

## Session Config

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `expiresIn` | `number` | `604800` (7 days) | Session expiration time (seconds) |
| `updateAge` | `number` | `86400` (1 day) | Session update interval (seconds) |
| `cookieCache.enabled` | `boolean` | `true` | Enable cookie cache |
| `cookieCache.maxAge` | `number` | `300` (5 min) | Cache validity (seconds) |
| `cookieCache.strategy` | `'compact' \| 'jwt' \| 'jwe'` | `'compact'` | Cache strategy |

```typescript
export const auth = betterAuth({
  session: {
    expiresIn: 604800, // 7 days
    updateAge: 86400, // Update every 1 day
    cookieCache: {
      enabled: true,
      maxAge: 300, // 5 minutes
      strategy: "compact",
    },
  },
})
```

## Session Methods

```typescript
// ✅ Client
const session = await authClient.getSession()
const session = await authClient.getSession({ query: { disableCookieCache: true } })

// ✅ Server (Server Component)
import { auth } from "@/lib/auth"
import { headers } from "next/headers"

export default async function Page() {
  const session = await auth.api.getSession({ headers: headers() })
  if (!session?.user) redirect("/login")

  return <div>Welcome {session.user.name}</div>
}

// ✅ Server (Server Action)
"use server"

import { auth } from "@/lib/auth"
import { headers } from "next/headers"

export async function getSession() {
  const session = await auth.api.getSession({ headers: headers() })
  return session
}

// ✅ Update session
await authClient.updateUser({ name: "New Name" })

// ✅ Logout
await authClient.signOut()
```

## Custom Session Fields

```typescript
import { customSession } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    customSession({
      schema: {
        session: {
          fields: {
            ipAddress: { type: "string" },
            userAgent: { type: "string" },
            metadata: { type: "json" },
          },
        },
      },
      async onSessionCreate(session, context) {
        return {
          ...session,
          ipAddress: context.request.headers.get("x-forwarded-for") || "unknown",
          userAgent: context.request.headers.get("user-agent") || "unknown",
        }
      },
    }),
  ],
})
```

</session>

---

<auth_methods>

## Email/Password

```typescript
// ✅ Sign up
await authClient.signUp.email({
  email: "user@example.com",
  password: "password123",
  name: "User Name",
})

// ✅ Sign in
await authClient.signIn.email({
  email: "user@example.com",
  password: "password123",
})

// ✅ Request password reset
await authClient.forgetPassword({ email: "user@example.com" })

// ✅ Reset password
await authClient.resetPassword({ token, password: "newpassword" })
```

## Social Login

```typescript
// ✅ Social sign in
await authClient.signIn.social({ provider: "google", callbackURL: "/dashboard" })
await authClient.signIn.social({ provider: "github", callbackURL: "/dashboard" })

// ✅ SSO
await authClient.signIn.sso({ providerId: "provider-id", callbackURL: "/dashboard" })
```

## Two-Factor Authentication

### Server Setup

```typescript
import { twoFactor } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    twoFactor({
      issuer: "My App",
      otpOptions: {
        async sendOTP({ user, otp }) {
          await sendEmail({
            to: user.email,
            subject: "Your OTP Code",
            html: `Your code: ${otp}`,
          })
        },
        period: 300, // 5 minutes
        length: 6, // 6 digits
      },
      backupCodeLength: 10,
      backupCodeCount: 10,
    }),
  ],
})
```

### Client Setup

```typescript
import { twoFactorClient } from "better-auth/client/plugins"

export const authClient = createAuthClient({
  plugins: [
    twoFactorClient({
      twoFactorPage: "/two-factor",
    }),
  ],
})
```

### 2FA Usage

```typescript
// ✅ Enable TOTP
const { data } = await authClient.twoFactor.enable({ password: "current-password" })
// data: { totpURI: 'otpauth://...', backupCodes: ['ABCD-1234', ...] }

// ✅ Verify TOTP
await authClient.twoFactor.verifyTotp({ code: "123456" })

// ✅ Send OTP
await authClient.twoFactor.sendOtp()

// ✅ Verify OTP
await authClient.twoFactor.verifyOtp({ code: "123456" })

// ✅ Use backup code
await authClient.twoFactor.useBackupCode({ code: "ABCD-1234" })

// ✅ Regenerate backup codes
const { data } = await authClient.twoFactor.regenerateBackupCodes({ password: "current-password" })

// ✅ Disable 2FA
await authClient.twoFactor.disable({ password: "current-password" })
```

</auth_methods>

---

<plugins>

## Plugin System

| Plugin | Import | Feature |
|--------|--------|---------|
| `multiSession` | `better-auth/plugins` | Multi-session management |
| `customSession` | `better-auth/plugins` | Extend session fields |
| `twoFactor` | `better-auth/plugins` | Two-factor authentication |
| `captcha` | `better-auth/plugins` | CAPTCHA validation |

## Multi-Session

```typescript
// ✅ Server
import { multiSession } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    multiSession({
      maximumSessions: 5, // Maximum sessions
    }),
  ],
})

// ✅ Client
import { multiSessionClient } from "better-auth/client/plugins"

export const authClient = createAuthClient({
  plugins: [multiSessionClient()],
})

// Usage
const sessions = await authClient.multiSession.listSessions()
await authClient.multiSession.revokeSession({ sessionId: "session-id" })
await authClient.multiSession.revokeOtherSessions()
```

## CAPTCHA

```typescript
// ✅ Server
import { captcha } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    captcha({
      provider: "recaptcha",
      siteKey: process.env.RECAPTCHA_SITE_KEY!,
      secretKey: process.env.RECAPTCHA_SECRET_KEY!,
      protectEndpoints: ["/sign-up/email", "/sign-in/email"],
    }),
  ],
})

// ✅ Client
import { captchaClient } from "better-auth/client/plugins"

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
// Server: siwe({ domain, uri })
// Client:
const { data } = await authClient.siwe.getNonce()
const message = await authClient.siwe.prepareMessage({ address: "0x...", nonce: data.nonce })
const signature = await signer.signMessage(message)
await authClient.siwe.signIn({ message, signature })
```

## Stateless Mode

```typescript
// ✅ Social login only without DB
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
import { Redis } from "ioredis"

const redis = new Redis()

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  secondaryStorage: {
    get: async (key: string) => {
      const value = await redis.get(key)
      return value ? JSON.parse(value) : null
    },
    set: async (key: string, value: any, ttl: number) => {
      await redis.set(key, JSON.stringify(value), "EX", ttl)
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

## Next.js Integration

| Pattern | Usage |
|---------|-------|
| Route Handler | `app/api/auth/[...all]/route.ts` |
| Server Component | `auth.api.getSession({ headers })` |
| Server Action | `auth.api.getSession({ headers })` |
| Middleware | `auth.api.getSession({ headers })` + redirect |

### Server Component Pattern

```typescript
// app/dashboard/page.tsx
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { redirect } from "next/navigation"

export default async function DashboardPage() {
  const session = await auth.api.getSession({ headers: headers() })

  if (!session?.user) {
    redirect("/login")
  }

  return <div>Welcome {session.user.name}</div>
}
```

### Server Action Pattern

```typescript
// actions/auth.ts
"use server"

import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { redirect } from "next/navigation"

export async function requireAuth() {
  const session = await auth.api.getSession({ headers: headers() })

  if (!session?.user) {
    redirect("/login")
  }

  return session.user
}

export async function getProtectedData() {
  const user = await requireAuth()
  return prisma.data.findMany({ where: { userId: user.id } })
}
```

### Middleware Pattern

```typescript
// middleware.ts
import { auth } from "@/lib/auth"
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({ headers: request.headers })

  if (!session?.user) {
    return NextResponse.redirect(new URL("/login", request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

## Common Patterns

| Task | Pattern |
|------|---------|
| Sign in | `authClient.signIn.email({ email, password })` |
| Sign up | `authClient.signUp.email({ email, password, name })` |
| Sign out | `authClient.signOut()` |
| Get session | `authClient.getSession()` (client) |
| Get session | `auth.api.getSession({ headers })` (server) |
| Update user | `authClient.updateUser({ name })` |
| Reset password | `authClient.forgetPassword({ email })` → `authClient.resetPassword({ token, password })` |

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|----------|
| Use `auth.api.getSession()` on server | Manipulate session directly on client |
| Use `authClient` on client | Hardcode secrets |
| Manage secrets with environment variables | Store session tokens in localStorage |
| HTTPS required in production | Deploy with HTTP in production |
| Configure `baseURL` per environment | Hardcode absolute paths |

</patterns>
