# TanStack Start - 인증 패턴

> Better Auth 통합 및 인증 구현 (v1.159.4)

---

<overview>

## 인증 시스템 구성

| 계층 | 담당 | 예시 |
|------|------|------|
| **인증 라이브러리** | 세션/토큰 관리 | Better Auth, Clerk, WorkOS, Auth.js |
| **Server Functions** | 로그인/로그아웃 | `login()`, `logout()`, `register()` |
| **미들웨어** | 인증 검증 | `authMiddleware` |
| **라우트 보호** | 접근 제어 | `beforeLoad`, `_authed` 패턴 |
| **컴포넌트** | 로그인 폼 | `LoginForm`, 인증 UI |

### 인증 vs 인가

- **인증 (Authentication)**: 이 사용자가 누구인가? (로그인/로그아웃)
- **인가 (Authorization)**: 이 사용자가 무엇을 할 수 있는가? (권한/역할)

### 아키텍처 모델

| 영역 | 역할 | 예시 |
|------|------|------|
| **서버 사이드 (보안)** | 세션 저장/검증, 자격 증명 확인, DB 작업, 토큰 생성 | Server Functions, 미들웨어 |
| **클라이언트 사이드 (공개)** | 인증 상태 관리, 라우트 보호 UI, 리다이렉트 | beforeLoad, 컴포넌트 |
| **이소모픽 (양쪽)** | 라우트 로더 인증 체크, 공유 검증 로직 | Loader, 스키마 |

</overview>

---

<auth_options>

## 인증 옵션 비교

### 호스팅 솔루션

| 솔루션 | 특징 |
|--------|------|
| **[Clerk](https://clerk.dev)** | UI 컴포넌트, 소셜 로그인 20+, MFA, 조직/팀 지원 |
| **[WorkOS](https://workos.com)** | SSO (SAML/OIDC), Directory Sync, SOC 2/GDPR 준수 |

### OSS 솔루션

| 솔루션 | 특징 |
|--------|------|
| **[Better Auth](https://www.better-auth.com/)** | TypeScript-first, 오픈소스 |
| **[Auth.js](https://authjs.dev/)** | 80+ OAuth 프로바이더, 커뮤니티 주도 |
| **[Supabase Auth](https://supabase.com/auth)** | Firebase 대안, 내장 인증 |

### DIY 구현

- **전체 제어**: 인증 흐름 완전 커스터마이징
- **벤더 종속 없음**: 인증 로직과 사용자 데이터 소유
- **비용 제어**: 사용자당 과금 없음

</auth_options>

---

<session_management>

## 세션 관리 패턴

### HTTP-Only 쿠키 (권장)

TanStack Start 내장 세션 관리:

```typescript
// utils/session.ts
import { useSession } from '@tanstack/react-start/server'

type SessionData = {
  userId?: string
  email?: string
  role?: string
}

export function useAppSession() {
  return useSession<SessionData>({
    name: 'app-session',
    password: process.env.SESSION_SECRET!,  // 32자 이상
    cookie: {
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      httpOnly: true,
    },
  })
}
```

### 세션 패턴 비교

| 패턴 | 장점 | 단점 |
|------|------|------|
| **HTTP-Only 쿠키** | 가장 안전, 브라우저 자동 처리, CSRF 보호 | 전통적 웹앱에 적합 |
| **JWT 토큰** | Stateless, API-first에 적합 | XSS 취약, refresh token 관리 필요 |
| **서버 사이드 세션** | 즉시 세션 철회, 중앙 제어 | Redis/DB 스토리지 필요 |

</session_management>

---

<better_auth_setup>

## Better Auth 설정

### 설치

```bash
npm install better-auth
npm install -D @types/better-auth
```

### 기본 설정

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { prisma } from '@/database/prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: {
    enabled: true,
    minPasswordLength: 8,
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7일
    updateAge: 60 * 60 * 24,      // 1일마다 세션 갱신
    cookieCache: {
      enabled: true,
      maxAge: 5 * 60, // 5분
    },
  },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID || '',
      clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
    },
  },
})

// 타입 내보내기
export type Session = typeof auth.$Infer.Session
export type User = typeof auth.$Infer.User
```

### Prisma 마이그레이션

```bash
npx better-auth-cli migration run
npx prisma migrate dev --name init
```

</better_auth_setup>

---

<server_functions>

## 인증 Server Functions

### 로그인 (Login)

```typescript
// functions/auth.ts
import { createServerFn } from '@tanstack/react-start'
import { redirect } from '@tanstack/react-router'
import { z } from 'zod'
import { auth } from '@/lib/auth'

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
})

export const login = createServerFn({ method: 'POST' })
  .inputValidator(loginSchema)
  .handler(async ({ data, request }): Promise<never> => {
    try {
      const result = await auth.api.signInEmail({
        email: data.email,
        password: data.password,
        headers: request.headers,
      })

      if (!result.user) {
        throw new Error('Invalid email or password')
      }

      throw redirect({ to: '/dashboard' })
    } catch (error) {
      if (error instanceof Response) throw error
      throw new Error('Login failed')
    }
  })
```

### 로그아웃 (Logout)

```typescript
export const logout = createServerFn({ method: 'POST' })
  .handler(async ({ request }): Promise<never> => {
    await auth.api.signOut({
      headers: request.headers,
    })

    throw redirect({ to: '/' })
  })
```

### 회원가입 (Register)

```typescript
const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(1, 'Name is required'),
})

export const register = createServerFn({ method: 'POST' })
  .inputValidator(registerSchema)
  .handler(async ({ data, request }): Promise<never> => {
    try {
      const existingUser = await prisma.user.findUnique({
        where: { email: data.email },
      })

      if (existingUser) {
        throw new Error('Email already registered')
      }

      const result = await auth.api.signUpEmail({
        email: data.email,
        password: data.password,
        name: data.name,
        headers: request.headers,
      })

      if (!result.user) {
        throw new Error('Registration failed')
      }

      throw redirect({ to: '/dashboard' })
    } catch (error) {
      if (error instanceof Response) throw error
      throw new Error('Registration failed')
    }
  })
```

### 현재 사용자 (Get Current User)

```typescript
export const getCurrentUser = createServerFn({ method: 'GET' })
  .handler(async ({ request }): Promise<Session['user'] | null> => {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    return session?.user ?? null
  })
```

### DIY 인증 (Better Auth 없이)

```typescript
import bcrypt from 'bcryptjs'

export const loginFn = createServerFn({ method: 'POST' })
  .inputValidator((data: { email: string; password: string }) => data)
  .handler(async ({ data }) => {
    const user = await authenticateUser(data.email, data.password)

    if (!user) {
      return { error: 'Invalid credentials' }
    }

    const session = await useAppSession()
    await session.update({
      userId: user.id,
      email: user.email,
    })

    throw redirect({ to: '/dashboard' })
  })

async function authenticateUser(email: string, password: string) {
  const user = await getUserByEmail(email)
  if (!user) return null

  const isValid = await bcrypt.compare(password, user.password)
  return isValid ? user : null
}
```

### 비밀번호 변경 / 재설정

```typescript
const changePasswordSchema = z.object({
  currentPassword: z.string().min(8),
  newPassword: z.string().min(8),
  confirmPassword: z.string().min(8),
}).refine((data) => data.newPassword === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
})

export const changePassword = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(changePasswordSchema)
  .handler(async ({ data, context }): Promise<{ success: true }> => {
    await auth.api.changePassword({
      newPassword: data.newPassword,
    })

    return { success: true }
  })

// 비밀번호 재설정 요청
export const requestPasswordReset = createServerFn({ method: 'POST' })
  .inputValidator(z.object({ email: z.string().email() }))
  .handler(async ({ data }): Promise<{ sent: true }> => {
    const user = await prisma.user.findUnique({
      where: { email: data.email },
    })

    if (user) {
      const resetToken = generateResetToken()
      await prisma.passwordReset.create({
        data: {
          userId: user.id,
          token: resetToken,
          expiresAt: new Date(Date.now() + 1000 * 60 * 60),
        },
      })
      await sendPasswordResetEmail(user.email, resetToken)
    }

    return { sent: true }  // 이메일 존재 여부 노출 방지
  })
```

</server_functions>

---

<auth_middleware>

## 인증 미들웨어

### 기본 인증 미들웨어

```typescript
// middleware/auth.ts
import { createMiddleware } from '@tanstack/react-start'
import { redirect } from '@tanstack/react-router'
import { auth } from '@/lib/auth'

export const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    if (!session?.user) {
      throw redirect({
        to: '/login',
        search: { returnUrl: new URL(request.url).pathname },
      })
    }

    return next({ context: { user: session.user } })
  })
```

### 역할 기반 미들웨어

```typescript
// middleware/roles.ts

export const adminMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    if (session?.user?.role !== 'ADMIN') {
      throw new Error('Forbidden: Admin access only')
    }

    return next({ context: { user: session.user } })
  })

export const moderatorMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    const allowedRoles = ['ADMIN', 'MODERATOR']
    if (!session?.user || !allowedRoles.includes(session.user.role)) {
      throw new Error('Forbidden: Insufficient permissions')
    }

    return next({ context: { user: session.user } })
  })
```

</auth_middleware>

---

<protected_server_functions>

## 보호된 Server Functions

### 인증 필수

```typescript
// functions/posts.ts

const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(10000),
})

export const createPost = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createPostSchema)
  .handler(async ({ data, context }): Promise<Post> => {
    return prisma.post.create({
      data: {
        ...data,
        authorId: context.user.id,
        published: false,
      },
    })
  })

export const getMyPosts = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }): Promise<Post[]> => {
    return prisma.post.findMany({
      where: { authorId: context.user.id },
      orderBy: { createdAt: 'desc' },
    })
  })

export const deletePost = createServerFn({ method: 'DELETE' })
  .middleware([authMiddleware])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data, context }): Promise<{ success: true }> => {
    const post = await prisma.post.findUnique({
      where: { id: data.id },
    })

    if (post?.authorId !== context.user.id && context.user.role !== 'ADMIN') {
      throw new Error('Forbidden: Cannot delete this post')
    }

    await prisma.post.delete({ where: { id: data.id } })
    return { success: true }
  })
```

### 관리자 전용

```typescript
export const deleteAnyUser = createServerFn({ method: 'DELETE' })
  .middleware([adminMiddleware])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }): Promise<{ success: true }> => {
    await prisma.user.delete({ where: { id: data.id } })
    return { success: true }
  })
```

</protected_server_functions>

---

<route_protection>

## 라우트 보호

### beforeLoad로 인증 체크

```tsx
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ location }): Promise<{ user: Session['user'] }> => {
    const user = await getCurrentUser()

    if (!user) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }

    return { user }
  },
  component: DashboardPage,
})

const DashboardPage = (): JSX.Element => {
  const { user } = Route.useRouteContext()
  return <h1>Welcome, {user?.name}!</h1>
}
```

### _authed 패턴 (Layout Route 보호 - 권장)

전체 라우트 서브트리를 한번에 보호:

```tsx
// routes/_authed.tsx (pathless layout)
import { createFileRoute, Outlet } from '@tanstack/react-router'
import { redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ location }): Promise<{ user: Session['user'] }> => {
    const user = await getCurrentUser()

    if (!user) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }

    return { user }
  },
  component: AuthedLayout,
})

const AuthedLayout = (): JSX.Element => {
  const { user } = Route.useRouteContext()

  return (
    <div>
      <header>
        <div>Welcome, {user?.name}!</div>
        <LogoutButton />
      </header>
      <Outlet />
    </div>
  )
}

// routes/_authed/dashboard.tsx -> /dashboard (자동 보호)
export const Route = createFileRoute('/_authed/dashboard')({
  component: DashboardPage,
})

// routes/_authed/settings.tsx -> /settings (자동 보호)
export const Route = createFileRoute('/_authed/settings')({
  component: SettingsPage,
})
```

### 권한별 라우트

```tsx
export const Route = createFileRoute('/admin')({
  beforeLoad: async ({ context }): Promise<{ user: Session['user'] }> => {
    const user = await getCurrentUser()

    if (!user || user.role !== 'ADMIN') {
      throw redirect({ to: '/' })
    }

    return { user }
  },
  component: AdminPage,
})
```

### RBAC (역할 기반 접근 제어)

```typescript
export const roles = {
  USER: 'user',
  ADMIN: 'admin',
  MODERATOR: 'moderator',
} as const

type Role = (typeof roles)[keyof typeof roles]

export function hasPermission(userRole: Role, requiredRole: Role): boolean {
  const hierarchy = {
    [roles.USER]: 0,
    [roles.MODERATOR]: 1,
    [roles.ADMIN]: 2,
  }

  return hierarchy[userRole] >= hierarchy[requiredRole]
}

// 사용
export const Route = createFileRoute('/_authed/admin/')({
  beforeLoad: async ({ context }) => {
    if (!hasPermission(context.user.role, roles.ADMIN)) {
      throw redirect({ to: '/unauthorized' })
    }
  },
})
```

</route_protection>

---

<login_form>

## 로그인 폼 (TanStack Query)

```tsx
// routes/login.tsx
import { useMutation } from '@tanstack/react-query'
import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'

export const Route = createFileRoute('/login')({
  component: LoginPage,
})

const LoginPage = (): JSX.Element => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  })
  const [error, setError] = useState<string | null>(null)

  const mutation = useMutation({
    mutationFn: (data: typeof formData) => login(data),
    onError: (err) => {
      setError((err as Error).message)
    },
  })

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(null)
    mutation.mutate(formData)
  }

  return (
    <div style={{ maxWidth: '400px', margin: '0 auto', padding: '2rem' }}>
      <h1>Login</h1>

      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: '1rem' }}>
          <label htmlFor="email">Email:</label>
          <input
            id="email"
            name="email"
            type="email"
            value={formData.email}
            onChange={handleChange}
            disabled={mutation.isPending}
            required
          />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label htmlFor="password">Password:</label>
          <input
            id="password"
            name="password"
            type="password"
            value={formData.password}
            onChange={handleChange}
            disabled={mutation.isPending}
            required
          />
        </div>

        {error && <p style={{ color: 'red' }}>{error}</p>}

        <button type="submit" disabled={mutation.isPending}>
          {mutation.isPending ? 'Logging in...' : 'Login'}
        </button>
      </form>

      <p>
        No account? <a href="/register">Register</a>
      </p>
    </div>
  )
}
```

</login_form>

---

<register_form>

## 회원가입 폼

```tsx
// routes/register.tsx
import { useMutation } from '@tanstack/react-query'
import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'

export const Route = createFileRoute('/register')({
  component: RegisterPage,
})

const RegisterPage = (): JSX.Element => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
  })
  const [error, setError] = useState<string | null>(null)

  const mutation = useMutation({
    mutationFn: (data) => register(data),
    onError: (err) => {
      setError((err as Error).message)
    },
  })

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(null)

    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match')
      return
    }

    const { confirmPassword, ...registerData } = formData
    mutation.mutate(registerData)
  }

  return (
    <div style={{ maxWidth: '400px', margin: '0 auto', padding: '2rem' }}>
      <h1>Register</h1>

      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: '1rem' }}>
          <label htmlFor="name">Name:</label>
          <input id="name" name="name" type="text" value={formData.name} onChange={handleChange} disabled={mutation.isPending} required />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label htmlFor="email">Email:</label>
          <input id="email" name="email" type="email" value={formData.email} onChange={handleChange} disabled={mutation.isPending} required />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label htmlFor="password">Password:</label>
          <input id="password" name="password" type="password" value={formData.password} onChange={handleChange} disabled={mutation.isPending} required />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label htmlFor="confirmPassword">Confirm Password:</label>
          <input id="confirmPassword" name="confirmPassword" type="password" value={formData.confirmPassword} onChange={handleChange} disabled={mutation.isPending} required />
        </div>

        {error && <p style={{ color: 'red' }}>{error}</p>}

        <button type="submit" disabled={mutation.isPending}>
          {mutation.isPending ? 'Registering...' : 'Register'}
        </button>
      </form>

      <p>
        Already have an account? <a href="/login">Login</a>
      </p>
    </div>
  )
}
```

</register_form>

---

<session_context>

## Session Context 제공

```tsx
// lib/session-context.tsx
import { createContext, useContext } from 'react'
import { Session } from '@/lib/auth'

const SessionContext = createContext<{
  user: Session['user'] | null
  isLoading: boolean
} | null>(null)

export const SessionProvider = ({
  children,
}: {
  children: React.ReactNode
}): JSX.Element => {
  const { data: user, isLoading } = useQuery({
    queryKey: ['currentUser'],
    queryFn: () => getCurrentUser(),
    staleTime: Infinity,
  })

  return (
    <SessionContext.Provider value={{ user: user || null, isLoading }}>
      {children}
    </SessionContext.Provider>
  )
}

export const useSession = () => {
  const context = useContext(SessionContext)
  if (!context) {
    throw new Error('useSession must be used within SessionProvider')
  }
  return context
}
```

### 상태 관리 패턴 비교

| 패턴 | 설명 | 적합한 경우 |
|------|------|-----------|
| **서버 주도 (권장)** | 매 요청마다 서버에서 인증 상태 확인 | SSR, 최고 보안 |
| **Context 기반** | 클라이언트에서 인증 상태 관리 | 서드파티 인증 (Auth0, Firebase) |
| **하이브리드** | 서버 초기 상태 + 클라이언트 업데이트 | 보안과 UX 균형 |

</session_context>

---

<oauth_integration>

## OAuth 통합 (Google)

```typescript
// lib/auth.ts
export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: { enabled: true },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID || '',
      clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
    },
  },
})
```

```tsx
const GoogleLoginButton = (): JSX.Element => {
  return (
    <form action={auth.api.signInSocial('google')}>
      <button type="submit">Login with Google</button>
    </form>
  )
}
```

</oauth_integration>

---

<security_best_practices>

## 보안 모범 사례

### 비밀번호 보안

```typescript
import bcrypt from 'bcryptjs'

const saltRounds = 12  // 보안 요구에 맞게 조정
const hashedPassword = await bcrypt.hash(password, saltRounds)
```

### 세션 보안

```typescript
export function useAppSession() {
  return useSession({
    name: 'app-session',
    password: process.env.SESSION_SECRET!,  // 32자 이상
    cookie: {
      secure: process.env.NODE_ENV === 'production',  // HTTPS only
      sameSite: 'lax',    // CSRF 보호
      httpOnly: true,     // XSS 보호
      maxAge: 7 * 24 * 60 * 60,  // 7일
    },
  })
}
```

### Rate Limiting

```typescript
const loginAttempts = new Map<string, { count: number; resetTime: number }>()

export const rateLimitLogin = (ip: string): boolean => {
  const now = Date.now()
  const attempts = loginAttempts.get(ip)

  if (!attempts || now > attempts.resetTime) {
    loginAttempts.set(ip, { count: 1, resetTime: now + 15 * 60 * 1000 })
    return true
  }

  if (attempts.count >= 5) {
    return false  // 너무 많은 시도
  }

  attempts.count++
  return true
}
```

### 입력 검증

```typescript
import { z } from 'zod'

const loginSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(8).max(100),
})

export const loginFn = createServerFn({ method: 'POST' })
  .inputValidator(loginSchema)
  .handler(async ({ data }) => {
    // data는 검증 완료 상태
  })
```

### 보안 체크리스트

| 항목 | 구현 |
|------|------|
| HTTPS | 프로덕션에서 필수 |
| HTTP-Only 쿠키 | 가능한 경우 항상 사용 |
| 서버 입력 검증 | 모든 입력을 서버에서 검증 |
| 시크릿 보호 | 서버 전용 함수에서만 사용 |
| Rate Limiting | 인증 엔드포인트에 적용 |
| CSRF 보호 | 폼 제출 시 적용 |

</security_best_practices>

---

<best_practices>

## 인증 모범 사례

| 원칙 | 구현 |
|------|------|
| **Server Functions 사용** | 로그인/로그아웃은 Server Function |
| **미들웨어 분리** | 인증/권한 검증은 미들웨어 |
| **beforeLoad 사용** | 라우트 접근 전 인증 체크 |
| **_authed 패턴** | Layout Route로 라우트 서브트리 한번에 보호 |
| **TanStack Query** | 로그인 폼은 useMutation |
| **환경변수 보안** | Better Auth secrets는 .env |
| **에러 처리** | 명확한 에러 메시지 제공 |
| **세션 갱신** | 주기적 세션 갱신 설정 |
| **이메일 미노출** | 비밀번호 재설정 시 이메일 존재 여부 노출 방지 |

</best_practices>

---

<version_info>

**Version:** TanStack Start/Router v1.159.4 with Better Auth latest

**Key Points:**
- Better Auth 2.x for session management
- TanStack Start 내장 useSession 지원 (HTTP-Only 쿠키)
- Server Functions for auth actions
- Middleware for role-based access
- beforeLoad for route protection
- _authed Pathless Layout 패턴 (권장)
- TanStack Query for form handling
- RBAC 역할 계층 패턴
- Rate Limiting, CSRF, XSS 보호

</version_info>
