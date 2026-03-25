# Server Actions

> `use server` 기반 mutation, 검증, 보안 규칙.

---

## 핵심 규칙

모든 Server Action을 외부에서 도달 가능한 POST 엔드포인트처럼 취급하세요.

App Router에서 앱 UI에서 시작된 mutation의 기본 표면은 Server Action입니다.

즉:

- 입력 검증
- 호출자 인증
- 리소스 권한 확인
- UI에 필요한 최소 반환값만 제공

페이지 레벨 UI gating만 믿으면 안 됩니다.

## 배치

- 재사용 가능한 action은 전용 `"use server"` 파일을 우선합니다
- 특정 라우트에 강하게 묶인 경우에는 Server Component 내부 inline action도 허용됩니다
- 반복되는 DB/auth 로직은 server-only DAL 또는 helper로 이동해야 합니다
- 내부 앱 UI에서 시작된 쓰기이고 HTTP-native 계약이 필요 없다면 `route.ts`보다 Server Action을 우선합니다

## 강한 규칙

| 확인 항목 | 규칙 |
|-----------|------|
| `FormData`, params, headers, search params를 그대로 신뢰함 | 차단 |
| 페이지 레벨 auth redirect/gating만 믿음 | 차단 |
| raw DB record나 내부 객체를 그대로 반환함 | 차단 |
| render 중 side effect로 mutation을 실행함 | 차단 |
| 반복되는 도메인 권한 로직을 매번 action에 인라인으로 작성함 | 경고. DAL로 이동 |
| 필요한 `revalidatePath()` / `revalidateTag()` 전에 `redirect()` 호출 | 차단 |

## DAL 가이드

권장 분리:

- Action: 입력 경계, auth 재확인, mutation orchestration, revalidation, redirect
- DAL/server-only 모듈: DB 접근, 권한 로직, DTO shaping, 민감한 비즈니스 규칙

## 보안 메모

- auth는 action 파라미터로 받은 신뢰된 토큰이 아니라 cookies/headers에서 읽습니다
- Server Action 반환값은 직렬화되어 클라이언트로 돌아가므로 최소화해야 합니다
- 비용이 큰 action은 rate limiting도 고려합니다
- reverse proxy / multi-proxy 배포에서는 `serverActions.allowedOrigins`가 필요한지 확인합니다

## render side-effect 규칙

render 중 mutation side effect를 일으키지 마세요. 명시적 form, action, client event 경로를 사용해야 합니다.

## 리뷰 체크리스트

- 입력 검증이 존재함
- auth/authz가 action 내부 또는 위임된 server-only 레이어에서 재검증됨
- 반환값이 최소화되어 있음
- 필요할 때 redirect 전에 revalidation이 일어남
- 반복 도메인 로직이 여러 action에 중복되지 않음
