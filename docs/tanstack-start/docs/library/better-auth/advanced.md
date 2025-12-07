# Better Auth - 고급 기능

## CAPTCHA

```typescript
// 서버
import { captcha } from 'better-auth/plugins'
plugins: [captcha({
  provider: 'recaptcha',
  siteKey: SITE_KEY, secretKey: SECRET_KEY,
  protectEndpoints: ['/sign-up/email', '/sign-in/email'],
})]

// 클라이언트
import { captchaClient } from 'better-auth/client/plugins'
plugins: [captchaClient({ siteKey: SITE_KEY })]
```

## SSO

```typescript
await authClient.signIn.sso({ providerId: 'provider-id', callbackURL: '/dashboard' })
```

## SIWE (Ethereum)

```typescript
// 서버
import { siwe } from 'better-auth/plugins'
plugins: [siwe({ domain: 'example.com', uri: 'https://example.com' })]

// 클라이언트
const { data: nonce } = await authClient.siwe.getNonce()
const message = await authClient.siwe.prepareMessage({ address, nonce: nonce.nonce })
const signature = await signer.signMessage(message)
await authClient.siwe.signIn({ message, signature })
```

## Stateless 모드

```typescript
// DB 없이 소셜 로그인만
export const auth = betterAuth({
  socialProviders: { google: { clientId, clientSecret } },
})

// Redis 하이브리드
export const auth = betterAuth({
  secondaryStorage: {
    get: (key) => redis.get(key),
    set: (key, value, ttl) => redis.set(key, value, 'EX', ttl),
    delete: (key) => redis.del(key),
  },
})
```
