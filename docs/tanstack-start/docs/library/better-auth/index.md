# Better Auth

> **Version**: Latest
> **Framework**: TypeScript Authentication Library
> **Source**: [Better Auth Documentation](https://www.better-auth.com)

Better Auth는 TypeScript를 위한 프레임워크 독립적인 인증 및 권한 부여 라이브러리입니다.

## 문서 구조

- [설치 및 설정](./setup.md) - 서버/클라이언트 설정, 소셜 로그인
- [세션 관리](./session.md) - 세션 설정, 쿠키 캐시
- [플러그인](./plugins.md) - Multi-Session, Custom Session
- [2단계 인증](./2fa.md) - TOTP, OTP, 백업 코드
- [고급 기능](./advanced.md) - CAPTCHA, SSO, SIWE, Stateless 모드

## 빠른 시작

```bash
yarn add better-auth
```

### 기본 서버 설정

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { prisma } from './prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: false,
  },
})
```

### 기본 클라이언트 설정

```typescript
// lib/auth-client.ts
import { createAuthClient } from 'better-auth/react'

export const authClient = createAuthClient({
  // 옵션
})
```

## 핵심 개념

### 이메일/비밀번호 인증
```typescript
// 로그인
await authClient.signIn.email({
  email: 'user@example.com',
  password: 'password123',
})

// 회원가입
await authClient.signUp.email({
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
})
```

### 세션 조회
```typescript
// 클라이언트
const session = await authClient.getSession()

// 서버
const session = await auth.api.getSession({
  headers: request.headers,
})
```

## 참고 자료

- [Better Auth 공식 문서](https://www.better-auth.com)
- [Better Auth GitHub](https://github.com/better-auth/better-auth)
