# Better Auth - 2단계 인증 (2FA)

> **상위 문서**: [Better Auth](./index.md)

## 서버 설정

```typescript
import { betterAuth } from 'better-auth'
import { twoFactor } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    twoFactor({
      issuer: 'My Application',
      otpOptions: {
        async sendOTP({ user, otp }) {
          await sendEmail({
            to: user.email,
            subject: 'Your verification code',
            html: `Your code is: ${otp}`,
          })
        },
        period: 300, // 5분
        length: 6,
      },
      backupCodeLength: 10,
      backupCodeCount: 10,
    }),
  ],
})
```

## 클라이언트 설정

```typescript
import { twoFactorClient } from 'better-auth/client/plugins'

const authClient = createAuthClient({
  plugins: [
    twoFactorClient({
      twoFactorPage: '/two-factor',
    }),
  ],
})
```

## 2FA 활성화

```typescript
// 2FA 활성화
const { data } = await authClient.twoFactor.enable({
  password: 'userPassword123',
})
console.log('TOTP URI:', data.totpURI)
console.log('Backup codes:', data.backupCodes)
```

## TOTP 코드 검증

```typescript
// TOTP 코드 검증
await authClient.twoFactor.verifyTotp({
  code: '123456',
})
```

## OTP 전송 및 검증

```typescript
// OTP 전송
await authClient.twoFactor.sendOtp()

// OTP 검증
await authClient.twoFactor.verifyOtp({
  code: '123456',
})
```

## 백업 코드

```typescript
// 백업 코드 사용
await authClient.twoFactor.useBackupCode({
  code: 'ABCD-1234-EFGH',
})

// 백업 코드 재생성
const { data: newCodes } = await authClient.twoFactor.regenerateBackupCodes({
  password: 'userPassword123',
})
```

## 2FA 비활성화

```typescript
await authClient.twoFactor.disable({
  password: 'userPassword123',
})
```

## 2FA 페이지 구현

```tsx
// pages/two-factor.tsx
import { useState } from 'react'
import { authClient } from '@/lib/auth-client'

export default function TwoFactorPage() {
  const [code, setCode] = useState('')
  const [error, setError] = useState('')

  const handleVerify = async () => {
    try {
      await authClient.twoFactor.verifyTotp({ code })
      // 성공 시 대시보드로 이동
      window.location.href = '/dashboard'
    } catch (e) {
      setError('Invalid code')
    }
  }

  return (
    <div>
      <h1>2단계 인증</h1>
      <input
        type="text"
        value={code}
        onChange={(e) => setCode(e.target.value)}
        placeholder="6자리 코드 입력"
      />
      <button onClick={handleVerify}>확인</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  )
}
```
