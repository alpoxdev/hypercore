# Better Auth - 2단계 인증 (2FA)

## 서버

```typescript
import { twoFactor } from 'better-auth/plugins'

plugins: [
  twoFactor({
    issuer: 'My App',
    otpOptions: {
      async sendOTP({ user, otp }) { await sendEmail({ to: user.email, html: `Code: ${otp}` }) },
      period: 300, length: 6,
    },
    backupCodeLength: 10,
    backupCodeCount: 10,
  }),
]
```

## 클라이언트

```typescript
import { twoFactorClient } from 'better-auth/client/plugins'
plugins: [twoFactorClient({ twoFactorPage: '/two-factor' })]
```

## 사용법

```typescript
// 활성화
const { data } = await authClient.twoFactor.enable({ password })
// data.totpURI, data.backupCodes

// TOTP 검증
await authClient.twoFactor.verifyTotp({ code: '123456' })

// OTP 전송 및 검증
await authClient.twoFactor.sendOtp()
await authClient.twoFactor.verifyOtp({ code })

// 백업 코드
await authClient.twoFactor.useBackupCode({ code: 'ABCD-1234' })
await authClient.twoFactor.regenerateBackupCodes({ password })

// 비활성화
await authClient.twoFactor.disable({ password })
```
