# TanStack Start 보안 강화

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

@rules/auth-and-session.ko.md
@rules/server-boundaries.ko.md
@rules/http-and-headers.ko.md
@rules/validation.ko.md
@references/official-security-notes.ko.md

## 목적

TanStack Start 앱에서 보안 이슈를 직접 줄이는 데 쓰는 스킬입니다. 모든 작업을 대규모 보안 리라이트로 끌고 가지 말고, 실제 위험 경계를 먼저 닫는 데 집중합니다.

이 스킬은 다음처럼 보안 성격이 분명할 때 사용합니다.

- auth, session, authorization 처리
- cookie, trusted origin, CSRF, 브라우저 요청 안전성
- `src/start.ts` 요청 미들웨어 검토
- server function / server route 하드닝
- secret, env, import boundary 보호
- SSR, hydration, client/server 실행 경계 누수
- security header, CSP, webhook 검증, rate limiting

일반 React 작업이나 단순 문구 수정에는 쓰지 않습니다.

작업의 중심이 보안 하드닝이 아니라 TanStack Start 아키텍처 준수라면 이 스킬을 늘리지 말고 `skills/tanstack-start-architecture/`로 보냅니다.

TanStack Start가 아닌 일반 보안 리뷰 요청이면 이 스킬을 강제로 적용하지 말고 일반 security-review 경로로 돌립니다.

## 트리거 예시

### Positive

- `TanStack Start 로그인/세션 처리 보안 점검해줘.`
- `TanStack Start server function에서 secret이 새지 않게 막아줘.`
- `TanStack Start 앱의 auth, cookie, CSRF, webhook 보안까지 같이 봐줘.`

### Negative

- `일반 React 페이지 스타일만 조금 수정해줘.`
- `TanStack Start가 아닌 Express API 서버를 보안 리뷰해줘.`

### Boundary

- `TanStack Start 페이지 문구만 바꿔줘.`
보안 경계, auth, env, server route, headers 변경이 없으면 이 스킬은 과합니다.

## 1단계: 프로젝트 검증

다음 신호가 있을 때만 이 스킬을 적용합니다.

- `app.config.ts`
- `package.json`의 `@tanstack/react-start`
- `package.json`의 `@tanstack/react-router`
- `src/routes/__root.tsx`

없으면 TanStack Start 보안 스킬을 억지로 적용하지 말고 일반 구현 또는 보안 리뷰 경로로 전환합니다.

## 2단계: 필요한 규칙 읽기

보안 민감 변경 전에 아래 파일을 읽습니다.

- `rules/auth-and-session.ko.md`
- `rules/server-boundaries.ko.md`
- `rules/http-and-headers.ko.md`
- `rules/validation.ko.md`

TanStack Start 실행 모델이나 Better Auth 세부 규칙이 걸리면 `references/official-security-notes.ko.md`도 읽습니다.

### 프롬프트 유형별 시작점

- auth, session, cookie, CSRF, `beforeLoad`, authorization 이슈: `rules/auth-and-session.ko.md`부터 시작
- secret leak, env 노출, `loader`, SSR context, hydration leak, import boundary 이슈: `rules/server-boundaries.ko.md`부터 시작
- `src/start.ts` middleware, CSP, CORS, header, webhook, rate limiting, server route 이슈: `rules/http-and-headers.ko.md`부터 시작
- copy-only edit 또는 비-TanStack 보안 요청이면 core 경계 판단에서 멈추고 더 읽지 말고 route-away 합니다

## 3단계: 보안 표면 매핑

수정 전에 지금 만지는 표면을 먼저 분류합니다.

1. auth / session
2. secret / env
3. `src/start.ts` 요청 미들웨어
4. server function
5. server route / HTTP endpoint
6. 브라우저 응답 header / CSP
7. SSR / hydration / import boundary 누수

둘 이상이 걸리면 연결된 규칙 파일을 모두 확인한 뒤 수정합니다.

## 4단계: 선호하는 수정 순서

가장 가벼운 수정으로 실제 위험부터 닫습니다.

1. secret 또는 boundary leak 차단
2. session / authz 강제
3. cookie, origin, mutation 안전성 강화
4. header, CSP, webhook 검증, rate limiting 추가
5. 마지막에만 더 큰 auth-stack / route 구조 변경 검토

## 5단계: Auto-Remediation Policy

다음처럼 국소적이고 되돌리기 쉬운 수정은 바로 적용합니다.

- privileged 로직을 `createServerFn` 또는 `createServerOnlyFn` 뒤로 이동
- route / session guard 추가
- 클라이언트에 노출된 secret 접근 제거
- 입력 검증, origin 체크, signature 검증 추가
- 현재 auth 스택이 명확할 때 cookie / header 기본값 강화

다음처럼 범위가 크고 위험한 변경은 명시적 근거 없이 자동 적용하지 않습니다.

- auth 라이브러리 교체
- session 모델 전면 변경
- 자산/스크립트 영향 확인 없는 사이트 전역 CSP 재작성
- 여러 환경에 걸친 CORS / cookie domain 정책 변경

## 핵심 보안 게이트

아래 중 하나라도 걸리면 고치기 전까지 완료로 보고하지 않습니다.

- 클라이언트에서 도달 가능한 코드가 secret을 import하거나 유도할 수 있음
- 보호된 데이터 mutation이 클라이언트가 보낸 userId / role을 그대로 신뢰함
- `loader`나 공용 유틸이 명시적 서버 경계 없이 privileged 작업을 수행함
- `beforeLoad`만 있고, 보호된 action에 대한 서버단 강제가 없음
- loader 결과, SSR context, hydrated state에 secret 또는 내부 전용 auth 데이터가 직렬화됨
- server route가 browser state-changing 입력을 auth/origin/CSRF 전략 없이 받음
- webhook handler가 signature 검증 전에 payload를 신뢰함
- auth/session cookie가 환경 규칙 없이 느슨하게 설정되어 있음

## 검증

완료 전에:

- 관련 규칙 파일 체크리스트를 확인하고
- 프로젝트 검증 명령을 실행하고
- 무엇을 강화했고 무엇이 스택 의존 리스크로 남는지 요약합니다

자세한 검증 명령과 리뷰 게이트는 `rules/validation.ko.md`를 따릅니다.
