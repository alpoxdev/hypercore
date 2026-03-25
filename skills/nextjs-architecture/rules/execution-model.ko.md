# 실행 모델

> Next.js 서버/클라이언트 경계 규칙.

---

## 핵심 규칙

코드가 어디서 실행되는지 추측하지 마세요.

- App Router에서 기본은 Server Component입니다
- Client Component에는 `'use client'`가 필요합니다
- Client Component도 prerender 단계에서 서버에서 렌더되므로, 브라우저 보안 가정을 그대로 따라야 합니다
- 서버 전용 코드는 클라이언트 환경으로 새면 안 됩니다

## 기본 전략

1. 먼저 Server Component로 시작
2. 인터랙션, 브라우저 API, client-side hook이 필요할 때만 `'use client'` 추가
3. client boundary는 가능한 트리 아래로 내리기
4. privileged read는 server-only 모듈이나 DAL에 두기

## 강한 규칙

| 확인 항목 | 규칙 |
|-----------|------|
| 인터랙션 코드인데 `'use client'` 없음 | 차단 |
| 실질적 이유 없이 상위 layout/root를 `'use client'`로 만듦 | 차단 |
| Client Component가 DB client, secret env, `cookies()`, `headers()`, server-only helper를 import함 | 차단 |
| Server Component에서 Client Component로 넓은 raw record를 전달함 | 차단 |
| 서버 전용 헬퍼에 `import 'server-only'` 또는 동등한 경계 표시가 없음 | 경고 |
| provider를 필요 이상 넓게 감쌈 | 경고. 가능한 깊게 렌더 |

## Serializable Props 규칙

Server Component에서 Client Component로 넘기는 props는 serializable 해야 하고, 의도적으로 좁아야 합니다.

권장:

- DTO
- 작은 view model
- 명시적 primitive props

지양:

- ORM 레코드 전체
- class instance
- secret
- UI에 필요 없는 내부 필드

## Provider 배치

Context provider는 필요한 subtree만 감싸야 합니다. 그래야 더 많은 트리를 정적으로 최적화할 수 있고 client bundle도 줄어듭니다.

## Server-Only 보호

클라이언트에서 절대 실행되면 안 되는 모듈에는 `import 'server-only'`를 사용하세요:

- DAL 모듈
- DB 접근
- secret을 다루는 SDK 래퍼
- 서버 전용 권한 확인 헬퍼

## 리뷰 체크리스트

- `'use client'`가 필요한 곳에만 있음
- Client Component가 server-only 모듈에 닿지 않음
- 서버/클라이언트 경계를 넘는 props가 좁고 serializable 함
- provider가 가능한 깊게 배치됨
