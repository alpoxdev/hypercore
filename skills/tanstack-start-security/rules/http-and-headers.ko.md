# HTTP / Header 규칙

> TanStack Start 앱의 server route, webhook, header, CSP, CORS, rate limit 규칙

## Server Route 정책

- auth, CSP, logging, shared request context, security header를 전역으로 걸어야 한다면 먼저 `src/start.ts` 요청 미들웨어를 검토합니다.

- 내부 앱 RPC는 기본적으로 `createServerFn`을 사용합니다.
- 아래처럼 실제 HTTP semantics가 필요할 때만 server route를 씁니다.
  - auth callback / auth가 요구하는 endpoint
  - webhook
  - health/readiness
  - public machine-readable endpoint
  - `robots.txt`, feed, verification file 같은 자산성 endpoint

내부 mutation/data RPC를 HTTP endpoint처럼 포장한 것이라면 Server Function으로 되돌립니다.

## 브라우저 응답 Header

보안 동작이 중요한 응답에는 명시적 header를 둡니다.

- auth/session 또는 민감 응답의 `Cache-Control`
- machine-readable endpoint의 `Content-Type`
- 보안 모델과 맞는 cookie attribute
- 필요 시 `X-Content-Type-Options: nosniff`
- 제품 요구에 맞는 `Referrer-Policy`, `Permissions-Policy`

## CSP 가이드

- 인증된 민감 UI를 제공한다면, 가능한 한 무CSP보다 의도적인 CSP를 선호합니다.
- 검증된 제품 요구가 없으면 `unsafe-inline`, `unsafe-eval`은 피합니다.
- inline script/style이 꼭 필요하면 broad wildcard보다 nonce 또는 hash 기반 허용을 선호합니다.
- TanStack/Vite asset 동작 확인 없이 프로덕션 CSP를 그대로 복붙하지 않습니다.

## CORS / Trusted Origin

- 실제 cross-origin 요구가 없으면 same-origin 기본값을 유지합니다.
- cross-origin이 필요하면 origin과 method를 정확히 allowlist 합니다.
- auth 라이브러리 설정과 route-level 동작의 trusted-origin 규칙을 맞춥니다.
- credential/auth endpoint에 `*`를 쓰면 안 됩니다.

## Webhook / 외부 Callback

- payload를 신뢰하기 전에 signature를 먼저 검증합니다.
- provider가 timestamp/event id를 주면 replay protection도 적용합니다.
- invalid signature, stale payload, 처리 실패에 대해 상태 코드를 분명히 나눕니다.
- 무거운 webhook side effect는 rate limit 또는 queue로 보호합니다.

## Rate Limiting / Abuse Control

- login, password reset, email verify, magic link, invite 같은 endpoint에는 rate limit을 둡니다.
- 비용 증폭이 가능한 public search, upload, integration endpoint도 보호합니다.
- auth provider가 client IP 기반 rate limit을 쓴다면 raw header를 그대로 믿지 말고 trusted proxy / forwarded header 처리를 검증합니다.
- 반복 인증 실패나 suspicious origin misuse는 서버 로그/감사 이벤트로 남깁니다.

## 리뷰 체크리스트

- server route가 실제 HTTP semantics가 필요한 경우에만 사용됨
- 민감 응답에 보안 관련 header가 명시됨
- CSP 정책이 의도적이며 복붙이 아님
- cross-origin 동작이 명시적이고 최소화됨
- webhook이 payload 신뢰 전에 signature를 검증함
- 남용 가능 endpoint에 rate limiting 또는 동등한 보호가 있음
