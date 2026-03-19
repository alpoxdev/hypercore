# Server Routes

> Server Function 대신 HTTP 엔드포인트를 써도 되는 경우의 규칙

---

## 기본 정책

일반 앱 기능은 TanStack Start `createServerFn`을 우선합니다.

실제 HTTP 엔드포인트가 필요한 경우에만 server route를 사용합니다.

---

## 허용되는 경우

| 경우 | 허용 여부 |
|------|---------|
| `better-auth`가 요구하는 엔드포인트 | 허용 |
| 외부 서비스의 webhook 수신 | 허용 |
| health/readiness 엔드포인트 | 허용 |
| `sitemap.xml`, `robots.txt`, feed, verification 파일 | 허용 |
| 통합/SEO/LLMO를 위해 명시적으로 필요한 machine-readable public endpoint | 허용 |
| 앱 내부에서만 소비하는 RPC/데이터 mutation | 금지. Server Functions 사용 |

---

## 설계 규칙

- 앱 내부 비즈니스 RPC는 Server Functions에 둡니다
- server route는 좁고, protocol-oriented하며, HTTP-native하게 유지합니다
- 공통 auth/logging은 route-level middleware를, method별 validation은 handler-level middleware를 우선합니다
- 캐시/auth/content-type가 중요하면 실제 `Response`와 명시적 headers/status를 반환합니다
- dynamic param과 splat은 endpoint shape에 꼭 필요할 때만 사용합니다

---

## Middleware 와 Context

- server route는 route-level, handler-level middleware를 모두 사용할 수 있습니다
- middleware는 `context`를 확장할 수 있습니다
- request body, headers, query params, client가 보낸 context는 모두 비신뢰 입력으로 취급합니다

---

## 리뷰 체크리스트

- 이 endpoint가 정말 HTTP semantics가 필요한지
- 단순 내부 RPC를 server route로 포장한 것이 아닌지
- 필요한 auth/validation/logging middleware가 붙어 있는지
- 캐시, 인증, content-type이 중요하면 response headers/status가 명시되어 있는지
