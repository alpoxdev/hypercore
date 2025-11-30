# Better Auth - 고급 기능

> **상위 문서**: [Better Auth](./index.md)

## CAPTCHA 보호

```typescript
import { betterAuth } from 'better-auth'
import { captcha } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    captcha({
      provider: 'recaptcha', // 'recaptcha' | 'hcaptcha'
      siteKey: process.env.RECAPTCHA_SITE_KEY!,
      secretKey: process.env.RECAPTCHA_SECRET_KEY!,
      protectEndpoints: ['/sign-up/email', '/sign-in/email'],
    }),
  ],
})

// 클라이언트
import { captchaClient } from 'better-auth/client/plugins'

const authClient = createAuthClient({
  plugins: [
    captchaClient({
      siteKey: process.env.NEXT_PUBLIC_RECAPTCHA_SITE_KEY!,
    }),
  ],
})

// CAPTCHA는 보호된 요청에 자동 포함됨
await authClient.signUp.email({
  email: 'user@example.com',
  password: 'SecurePassword123!',
})
```

## SSO (Single Sign-On)

```typescript
// Provider ID로 SSO 로그인
const res = await authClient.signIn.sso({
  providerId: 'example-provider-id',
  callbackURL: '/dashboard',
})
```

## SIWE (Sign-In with Ethereum)

### 서버 설정

```typescript
import { betterAuth } from 'better-auth'
import { siwe } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    siwe({
      domain: 'example.com',
      uri: 'https://example.com',
      statement: 'Sign in with your Ethereum account',
    }),
  ],
})
```

### 클라이언트 사용

```typescript
import { siweClient } from 'better-auth/client/plugins'
import { ethers } from 'ethers'

const authClient = createAuthClient({
  plugins: [siweClient()],
})

// Nonce 가져오기
const { data: nonce } = await authClient.siwe.getNonce()

// 메시지 생성 및 서명
const provider = new ethers.BrowserProvider(window.ethereum)
const signer = await provider.getSigner()
const address = await signer.getAddress()

const message = await authClient.siwe.prepareMessage({
  address,
  nonce: nonce.nonce,
})

const signature = await signer.signMessage(message)

// 검증 및 로그인
await authClient.siwe.signIn({
  message,
  signature,
})
```

## Stateless 모드

데이터베이스 없이 사용:

```typescript
import { betterAuth } from 'better-auth'

export const auth = betterAuth({
  // 데이터베이스 설정 없음 - 자동으로 stateless 모드
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    },
  },
})
```

### Redis와 함께 하이브리드 모드

```typescript
import { betterAuth } from 'better-auth'
import { redis } from './redis'

export const auth = betterAuth({
  secondaryStorage: {
    get: async (key) => await redis.get(key),
    set: async (key, value, ttl) => await redis.set(key, value, 'EX', ttl),
    delete: async (key) => await redis.del(key),
  },
  session: {
    cookieCache: {
      maxAge: 5 * 60, // 5분
      refreshCache: false,
    },
  },
})
```
