# Auth / Session 규칙

> TanStack Start의 인증, 인가, 쿠키, 브라우저 요청 안전성 규칙

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| 보호된 페이지에 route guard 또는 서버 세션 체크가 없음? | 차단 |
| mutation이 클라이언트 입력의 `userId`, `role`, tenant scope를 신뢰함? | 차단. 서버에서 세션/컨텍스트로 다시 계산 |
| 인증이 필요한 server function에 session/authz 강제가 없음? | 차단 |
| 쿠키 설정이 환경별로 모호함? | 의도가 명확해질 때까지 차단 |
| state-changing browser endpoint에 origin / CSRF 전략이 없음? | 차단 |

## 라우트 보호

- 페이지 수준 접근 제어와 redirect는 route `beforeLoad`를 사용합니다.
- 보호된 데이터 접근과 mutation은 `createServerFn` 내부에서도 서버 세션 검증을 다시 합니다.
- `beforeLoad`는 라우팅 보호일 뿐, 서버 authorization 대체 수단이 아닙니다.
- 인증만으로 끝내지 말고, 실제 action 가까이에서 authorization scope까지 확인합니다.
- 클라이언트 리다이렉트나 숨겨진 UI만으로 보호가 된다고 가정하면 안 됩니다.
- 인증 실패(`401 Unauthorized` — 호출자는 로그인/자격증명 갱신 필요)와 인가 실패(`403 Forbidden` — 로그인은 되어 있으나 scope/권한 부족)를 구분합니다. 잘못된 코드를 반환하면 scope 정보가 새거나 정상 재시도 흐름이 깨집니다.

## 세션 파생 규칙

- 세션 상태는 서버에서 request headers/cookies 기준으로 읽습니다.
- TanStack Start auth helper는 request header를 읽어 서버에서 세션을 결정하는 형태를 우선합니다. Better Auth라면 보통 `createServerFn` / route `beforeLoad` 안에서 `auth.api.getSession({ headers: getRequestHeaders() })` 형태로 호출하고, 클라이언트에서는 호출하지 않습니다.
- 브라우저가 보낸 user id, org id, role, feature flag는 서버에서 다시 검증되기 전까지 비신뢰 입력입니다.
- 세션 토큰, API key, auth-bearing 값은 `localStorage`나 `sessionStorage`에 저장하지 않습니다. `HttpOnly` 서버 발급 쿠키에 보관합니다. `localStorage`는 페이지 내 모든 스크립트가 읽을 수 있으므로 보안 경계가 아닙니다.

## Better Auth 메모

앱이 Better Auth를 쓴다면:

- 필요한 경우 TanStack Start cookies integration을 사용합니다
- `tanstackStartCookies()`는 Better Auth plugin 배열의 마지막에 둡니다
- cross-origin auth flow가 있으면 `trustedOrigins`를 명시적으로 설정합니다
- cross-subdomain cookie는 실제 배포 모델이 필요할 때만 켭니다
- 브라우저에서 도달 가능한 경로가 있다면 `disableCSRFCheck: true` 같은 완화 설정은 명시적 리스크 승인 없이는 금지합니다

## 쿠키 규칙

- 세션 쿠키는 프로덕션에서 `HttpOnly`, `Secure`를 기본으로 둡니다
- `SameSite`는 의도적으로 선택합니다
- cookie `domain`은 cross-subdomain 공유가 필요할 때만 설정합니다
- 로컬 개발과 프로덕션의 차이를 문서화합니다
- 세션이 실리는 값을 클라이언트 JavaScript에 노출하지 않습니다. 정말 필요한 낮은 위험 노출만 예외입니다

## CSRF / 브라우저 mutation 안전성

- 브라우저에서 도달 가능한 state-changing endpoint는 아래 중 하나 이상이 분명해야 합니다.
  - same-origin only + origin 검증
  - trusted origin allowlist
  - CSRF token 또는 동등한 라이브러리 보호
- `POST`라는 이유만으로 CSRF-safe하다고 보면 안 됩니다.
- 외부 auth 스택을 쓰면 그 스택이 요구하는 anti-CSRF / trusted-origin 규칙을 그대로 따릅니다.

## 리뷰 체크리스트

- 보호된 라우트가 privileged UI/data 사용 전에 redirect 또는 deny 처리됨
- 보호된 mutation이 서버 세션에서 identity / authorization을 파생함
- 쿠키 설정이 명시적이고 환경을 인지함
- cross-origin auth flow가 의도적으로 allowlist 됨
- 브라우저 state change에 대해 CSRF / origin 체크가 존재함
- Better Auth 보안 완화 설정이 이유 없이 켜져 있지 않음
