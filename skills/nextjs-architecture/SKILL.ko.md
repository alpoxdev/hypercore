# Next.js 아키텍처 강제 적용

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

## 개요

코드 변경 전에 공식 Next.js 아키텍처 규칙을 강제합니다. 먼저 실제 Next.js 프로젝트인지와 App Router 사용 여부를 검증한 뒤, 라우팅, Server/Client Component 경계, 서버 우선 데이터 페칭, Server Actions, Route Handlers, Proxy, 환경 설정 규칙을 적용합니다.

**이 스킬은 official-first입니다.** Next.js 공식 문서를 기준으로 판단하세요. 저장소 로컬 규칙이 더 엄격하다면, 프레임워크 규칙처럼 섞지 말고 별도 컨벤션으로 명확히 표시하세요.

**운영 모드:** 이 스킬은 자체적으로 동작합니다. 아키텍처 검증만 하려고 외부 오케스트레이션에 의존하지 마세요. 사용자가 exhaustive verification을 요구하면 더 깊게 확인하고, 그렇지 않으면 이 스킬의 검증 흐름으로 바로 진행합니다.

**중요:** 이 스킬의 기본 대상은 App Router입니다. 저장소가 Pages Router만 쓰고 있다면, 공통 플랫폼/경계 규칙만 적용하고 사용자가 마이그레이션이나 `app/` 도입을 명시하지 않는 한 App Router 전용 파일 규칙을 강제하지 마세요.

**중요:** 내부 UI 쓰기, 특히 form submit과 앱 내부 mutation은 기본적으로 Server Actions를 우선하세요. webhook, feed, CORS 민감 엔드포인트, public/machine-readable endpoint처럼 진짜 HTTP-native 표면일 때만 Route Handler를 우선 검토합니다.

**중요:** 모든 Server Action은 외부에서 도달 가능한 POST 엔드포인트처럼 취급하세요. 검증, 인증, 권한 확인, 반환값 축소는 폼을 렌더하는 페이지가 아니라 action 내부 또는 위임된 server-only 데이터 계층에서 처리해야 합니다.

## 빠른 표면 선택표

전체 게이트를 읽기 전에 먼저 이 표로 기본 결정을 내립니다.

| 작업이 이런 느낌이면... | 기본 표면 | 기본값으로 두면 안 되는 것 |
|------|------|------|
| `App Router에서 form 또는 내부 앱 mutation 추가` | Server Action | `route.ts` |
| `webhook, feed, CORS 엔드포인트, public machine-readable endpoint 추가` | Route Handler | Server Action |
| `UI용 초기 페이지 데이터 읽기` | Server Component | 진짜 이유 없는 client-first fetching |
| `렌더 전에 많은 요청 경로에 redirect logic 필요` | `next.config.*` 또는 Proxy, 단 Proxy는 마지막 수단 | Server Action |
| `Client Component가 DB 코드나 private env를 import함` | server-only 경계 뒤로 이동 | secret을 client reachable code에 남김 |
| `Pages Router만 있고 migration 요청 없음` | 공통 Next.js 안전 규칙만 적용 | App Router 파일 규칙 강제 |

이 표의 한 줄과 맞는 작업이라면, 먼저 그 결정을 따르고 세부사항은 2단계의 관련 rule 파일에서 확인하세요.

## 트리거 예시

### Positive

- `이 Next.js 앱 구조 먼저 점검하고 App Router 작업하자.`
- `Next.js 기능을 리팩터링하는데 Server Component, client boundary, caching, server action을 공식 문서 기준으로 맞춰줘.`
- `Next.js Route Handler나 Server Action을 추가하는데 아키텍처도 같이 맞춰줘.`

### Negative

- `일반 React 아키텍처 가이드 만들어줘.`
- `Remix나 TanStack Start 앱을 리뷰해줘.`

### Boundary

- `Next.js 페이지에서 문구만 아주 작게 바꿔줘.`
아키텍처 경계가 안 걸리면 direct edit만으로 충분하지만, touched file에 대한 빠른 경계 점검은 해야 합니다.

- `이 저장소는 Pages Router만 쓰고 있고 App Router로 옮길 생각은 없어.`
이 경우에도 스킬은 적용되지만, Next.js 공통 플랫폼/경계 규칙 위주로만 보고 App Router 전용 파일 규칙은 완화해야 합니다.

## 1단계: 프로젝트 검증

작업 전, Next.js 프로젝트인지와 라우터 모드를 확인:

```bash
rg -n '"next"' package.json
find . -maxdepth 3 \( -path './app' -o -path './src/app' -o -path './pages' -o -path './src/pages' \)
test -f next.config.ts -o -f next.config.mjs -o -f next.config.js
```

해석:

- `next` 의존성이 없으면 중단. 이 스킬은 해당하지 않습니다.
- `app/` 또는 `src/app/`가 있으면 App Router 전체 규칙 적용.
- `pages/` 또는 `src/pages/`만 있으면 공통 Next.js 규칙만 적용.
- `app/`과 `pages/`가 섞여 있으면, touched `app/` 코드는 App Router 규칙으로 보고 레거시 `pages/`는 명시적 migration 의도 없이 건드리지 마세요.

## 2단계: 아키텍처 규칙 읽기

상세 규칙 참조 파일을 읽습니다.

**필수:** 코드 작성 전에 이 스킬 디렉토리의 `architecture-rules.md`를 읽으세요.

그 다음 변경에 맞는 규칙 파일을 읽습니다:

- `rules/routes.md` - App Router 구조, 특수 파일, route group, private folder, 세그먼트 경계
- `rules/execution-model.md` - Server/Client Component, `use client`, provider 위치, serializable props, `server-only`
- `rules/data-fetching.md` - 서버 데이터 페칭, 스트리밍, 캐시 의도, dynamic rendering 트리거, revalidation
- `rules/server-actions.md` - `use server`, 입력 검증, 인증/권한, DAL 위임, revalidation, redirect 순서, side-effect 규칙
- `rules/route-handlers.md` - `route.ts`가 정당한 경우, 메서드 처리, 캐시 기본값, HTTP 전용 표면
- `rules/platform.md` - 환경 변수, `next.config.*`, `typedRoutes`, Proxy, 배포 민감 설정

프레임워크 동작이 바뀌었을 가능성이 있으면 다음도 읽습니다:

- `references/official/nextjs-docs.md` - 이 스킬이 의존하는 공식 문서 지도

## 3단계: 변경 전 검증 체크리스트

코드 작성 전, 아래 게이트에 맞는지 확인합니다.

### 브라운필드 적용 규칙

- untouched legacy code의 모든 차이를 즉시 프로젝트 전체 실패로 보지 않습니다.
- 안전/경계 문제는 특히 touched file에서 즉시 차단합니다.
- 로컬 작업이고 마이그레이션 의도가 없다면 기존 `pages/` 코드는 유지할 수 있습니다.
- 직접 수정하는 파일은, 과도하게 위험한 마이그레이션이 아니라면 규칙 쪽으로 끌어올립니다.

### 게이트 1: 라우팅과 파일 규칙

| 확인 항목 | 규칙 |
|-----------|------|
| `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, `route.ts`가 잘못된 세그먼트에 있음? | 차단 |
| 같은 세그먼트에 `route.ts`와 `page.tsx`를 같이 만듦? | 차단 |
| 이미 `app/`가 있는데 해당 기능을 굳이 `pages/`로 추가함? | 명시적 요청 없으면 차단 |
| route group / private folder의 URL 의미를 잘못 이해함? | 경고. `(group)`은 URL에 안 들어가고 `_folder`는 라우트가 아님 |
| 세그먼트에 loading/error/not-found UX가 필요한데 경계 파일이 없음? | 경고. 의도적으로 추가 검토 |

### 게이트 2: 서버/클라이언트 경계

| 확인 항목 | 규칙 |
|-----------|------|
| 인터랙션이 필요한 컴포넌트에 `'use client'`가 없음? | 차단 |
| 필요 이상으로 트리 상단에 `'use client'`를 둠? | 차단. client boundary는 가능한 좁게 |
| Client Component가 server-only 코드, secret, DB client, private `process.env` 값을 import함? | 차단 |
| 서버 전용 헬퍼에 `import 'server-only'` 또는 명확한 서버 경계가 없음? | 경고. 명시적 경계 추가 권장 |
| Client Component props에 넓은 DB 레코드나 non-serializable 값이 들어감? | 차단 |
| provider를 너무 루트에 두어 정적 최적화를 해침? | 경고. 가능한 깊게 렌더 |

### 게이트 3: 데이터 페칭과 캐싱

| 확인 항목 | 규칙 |
|-----------|------|
| 초기 페이지 데이터를 Server Component 대신 Client Component에서 가져옴? | 진짜 client-only 이유가 없으면 차단 |
| layout이 uncached runtime data를 읽어서 같은 세그먼트 `loading.tsx`를 무력화하고, 더 가까운 `<Suspense>`도 없음? | 차단 |
| 캐시 동작이 우연에 맡겨져 있고 설명이 없음? | 차단. 캐시 전략을 의도적으로 선택 |
| 민감/권한 데이터 접근을 DAL 또는 server-only 모듈 없이 직접 흩뿌림? | 프로토타입은 경고, 운영성 코드면 차단 |
| mutation 후 UI가 새 데이터를 기대하는데 revalidation/redirect/신선도 전략이 없음? | 차단 |

### 게이트 4: Server Actions

| 확인 항목 | 규칙 |
|-----------|------|
| 내부 UI mutation 또는 form submit을 Server Action으로 충분히 처리할 수 있는데 `route.ts`로 구현함? | 실제 HTTP semantics가 필요하지 않으면 차단 |
| form data, params, headers, search params를 검증 없이 신뢰함? | 차단 |
| 페이지 레벨 auth 체크만 믿고 action 내부 재검증이 없음? | 차단 |
| raw DB row나 내부 객체를 그대로 반환함? | 차단 |
| DAL이 있거나 있어야 하는데 action이 DB/secret-heavy 로직을 직접 가짐? | 작은 코드면 경고, 반복 도메인 로직이면 차단 |
| render 중 부수효과로 mutation을 수행함? | 차단 |
| 필요한 revalidation 전에 `redirect()`를 호출함? | 차단. 먼저 revalidate, 그 다음 redirect |

### 게이트 5: Route Handlers와 Proxy

| 확인 항목 | 규칙 |
|-----------|------|
| Server Action으로 충분한 내부 UI mutation을 `route.ts`로 구현함? | 실제 HTTP semantics가 없으면 차단 |
| webhook, feed, CORS, public machine endpoint 용도로 Route Handler를 사용함? | 허용 |
| Route Handler에서 `NextResponse.next()`로 Proxy처럼 전달하려고 함? | 차단 |
| `redirects`, `rewrites`, headers, render-time 로직으로 충분한데 Proxy를 추가함? | 차단. Proxy는 마지막 수단 |
| `proxy.ts`가 프로젝트 루트나 `src/` 루트가 아니라 다른 곳에 있음? | 차단 |
| Proxy matcher가 없거나 너무 넓음? | 차단 |

### 게이트 6: 플랫폼과 환경 변수

| 확인 항목 | 규칙 |
|-----------|------|
| `.env*` 파일이 `src/`에서 로드된다고 가정함? | 차단. 프로젝트 루트에 있어야 함 |
| client 코드가 `NEXT_PUBLIC_` 없는 env를 읽음? | 차단 |
| runtime client env가 필요한데 build-time inline 값처럼 취급함? | 차단. 서버 경로/API로 노출 |
| reverse proxy / multi-proxy 배포에서 Server Actions를 쓰면서 `serverActions.allowedOrigins` 필요성을 검토하지 않음? | 경고 |
| 캐시/라우팅/Server Actions 동작을 바꾸는 Next config가 의도 설명 없이 들어감? | 차단 |
| TypeScript 코드베이스인데 `typedRoutes`가 라우팅 실수 방지에 유의미해도 완전히 무시함? | 경고. 의도적으로 검토 |

## 3.5단계: Auto-Remediation Policy

국소적이고 되돌리기 쉽고 저위험이면 직접 수정합니다.

- 너무 넓은 `'use client'` 경계 축소
- touched 세그먼트에 `loading.tsx`, `error.tsx`, `not-found.tsx` 추가
- privileged read를 server-only helper 또는 DAL로 이동
- `server-only` marker 추가 및 client props 축소
- Server Action mutation 뒤 revalidation 추가
- 작은 범위에서 잘못 쓴 내부 mutation용 `route.ts`를 Server Action으로 이동
- Proxy matcher 범위 축소 또는 단순 redirect를 `next.config.*`로 이동
- `.env` / `NEXT_PUBLIC_` 사용과 명시적 설정 정리

다만 명시적 근거 없이 넓고 깨질 수 있는 마이그레이션은 자동 적용하지 않습니다.

- 대규모 route tree 재작성
- Pages Router -> App Router 광범위 마이그레이션
- 캐시 모델 전체 변경
- 많은 Route Handler를 한 번에 Server Action으로 치환
- 배포 민감한 Server Action origin / encryption key 변경

## 4단계: 구현

현재 작업에 다음 수락 기준을 가져가세요:

```text
- [ ] 편집 전 Next.js 프로젝트 모드를 검증했다
- [ ] App Router 규칙은 실제로 맞는 표면에만 적용했다
- [ ] 라우팅 파일이 올바른 세그먼트 구조에 있다
- [ ] Server/Client Component 경계가 명시적이고 최소화되어 있다
- [ ] client 코드가 server-only 데이터, env, 모듈에 닿지 않는다
- [ ] 데이터 페칭과 캐싱 전략이 의도적이다
- [ ] 내부 UI 쓰기의 기본 표면이 Server Actions다
- [ ] Server Actions가 입력 검증, 재인증, 최소 반환값 규칙을 지킨다
- [ ] Route Handlers는 실제 HTTP-native 요구가 있을 때만 존재한다
- [ ] Proxy는 더 단순한 수단이 부족할 때만 사용한다
- [ ] 환경 변수와 next.config 설정이 경계 안전하다
```

## 5단계: 변경 후 검증

코드 변경 후 확인:

1. 프로젝트 모드와 편집 표면이 일치하는지 (`app/`, `pages/`, mixed)
2. route segment 파일 배치가 맞는지
3. `'use client'` 경계가 가능한 좁은지
4. client 코드가 server-only 모듈이나 private env를 import하지 않는지
5. mutation 후 freshness 전략이 명시적인지 (`revalidatePath`, `revalidateTag`, redirect flow 등)
6. Route Handlers와 Proxy 사용 근거가 여전히 유효한지
7. `next.config.*`, env 로딩, 배포 민감 설정이 일관적인지

## 빠른 구조 참고: App Router

```text
app/
├── layout.tsx
├── page.tsx
├── dashboard/
│   ├── page.tsx
│   ├── loading.tsx
│   ├── error.tsx
│   ├── not-found.tsx
│   ├── _components/
│   └── _lib/
├── api/
│   └── webhooks/
│       └── route.ts
└── (marketing)/
    └── about/
        └── page.tsx
```

핵심 의미:

- `(group)`은 URL에 영향을 주지 않는 구조화 폴더
- `_folder`는 private implementation 폴더로 라우트가 아님
- `route.ts`는 HTTP 처리용이지 페이지 UI용이 아님
- `loading.tsx`, `error.tsx`, `not-found.tsx`는 일반 컴포넌트가 아니라 세그먼트 경계 파일입니다
