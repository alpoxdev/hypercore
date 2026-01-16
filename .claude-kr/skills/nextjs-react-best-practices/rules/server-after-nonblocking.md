---
title: Use after() for Non-Blocking Operations
impact: MEDIUM
impactDescription: faster response times
tags: server, async, logging, analytics, side-effects
---

## 논블로킹 작업을 위한 after() 사용

Next.js의 `after()`를 사용하여 응답이 전송된 후 실행되어야 하는 작업을 예약하세요. 이를 통해 로깅, 분석, 기타 부수 효과가 응답을 차단하는 것을 방지할 수 있습니다.

**잘못된 예 (응답 차단):**

```tsx
import { logUserAction } from '@/app/utils'

export async function POST(request: Request) {
  // 변경 수행
  await updateDatabase(request)

  // 로깅이 응답을 차단함
  const userAgent = request.headers.get('user-agent') || 'unknown'
  await logUserAction({ userAgent })

  return new Response(JSON.stringify({ status: 'success' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
```

**올바른 예 (논블로킹):**

```tsx
import { after } from 'next/server'
import { headers, cookies } from 'next/headers'
import { logUserAction } from '@/app/utils'

export async function POST(request: Request) {
  // 변경 수행
  await updateDatabase(request)

  // 응답 전송 후 로깅
  after(async () => {
    const userAgent = (await headers()).get('user-agent') || 'unknown'
    const sessionCookie = (await cookies()).get('session-id')?.value || 'anonymous'

    logUserAction({ sessionCookie, userAgent })
  })

  return new Response(JSON.stringify({ status: 'success' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
```

응답은 즉시 전송되고 로깅은 백그라운드에서 실행됩니다.

**일반적인 사용 사례:**

- 분석 추적
- 감사 로깅
- 알림 전송
- 캐시 무효화
- 정리 작업

**중요 사항:**

- `after()`는 응답이 실패하거나 리다이렉트되어도 실행됩니다
- Server Action, Route Handler, Server Component에서 작동합니다

참고: [https://nextjs.org/docs/app/api-reference/functions/after](https://nextjs.org/docs/app/api-reference/functions/after)
