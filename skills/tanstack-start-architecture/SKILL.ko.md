# TanStack Start 아키텍처 강제 적용

## 개요

hypercore TanStack Start 아키텍처 규칙을 100% 준수하도록 강제합니다. 프로젝트 구조를 검증한 후, 모든 코드 변경에 엄격한 레이어/라우트/훅/컨벤션 규칙을 적용합니다.

**이 스킬은 엄격합니다. 정확히 따르세요. 예외 없음.**

**필수:** TanStack Start 프로젝트 작업 시, 반드시 `/oh-my-claudecode:ralph`와 함께 이 스킬을 사용하여 아키텍처 규칙 100% 준수를 보장하세요. Ralph의 지속 루프가 모든 규칙을 검증하고 위반이 빠져나가지 않도록 합니다.

**매우 중요:** TanStack Start의 import protection은 필수입니다. 클라이언트/서버 import 경계를 반드시 검증하고, `vite.config.ts`를 확인해서 `importProtection` 설정이 없거나 부족하면 직접 추가/확장해야 합니다. 필요한 deny 규칙이 있는데 기본값만 믿고 넘어가면 안 됩니다.

**참고:** 이 스킬의 일부 규칙은 TanStack Start 공식 기본보다 더 엄격합니다. 사용자가 공식 기본 규칙을 따르라고 명시하지 않는 한, hypercore 팀 규칙으로 해석하고 적용하세요.

## 1단계: 프로젝트 검증

작업 전, TanStack Start 프로젝트인지 확인:

```bash
# TanStack Start 지표 확인 (하나라도 있으면 됨)
ls app.config.ts 2>/dev/null        # TanStack Start 설정
grep -r "@tanstack/react-start" package.json 2>/dev/null
grep -r "@tanstack/react-router" package.json 2>/dev/null
ls src/routes/__root.tsx 2>/dev/null
```

하나도 없으면: **중단. 이 스킬은 해당하지 않습니다.** 사용자에게 알림.

확인되면: 아키텍처 강제 적용 진행.

## 2단계: 아키텍처 규칙 읽기

상세 규칙 참조 파일 로드:

**필수:** 코드 작성 전 이 스킬 디렉토리의 `architecture-rules.md`와 `rules/` 폴더의 파일들을 읽으세요.

참조 파일:
- `rules/conventions.md` - 코드 컨벤션 (네이밍, TypeScript, Import 순서, 주석)
- `rules/routes.md` - 라우트 구조 (폴더 규칙, 패턴, Loader)
- `rules/services.md` - Server Functions (스키마, 쿼리, 뮤테이션, 미들웨어)
- `rules/hooks.md` - Custom Hook 패턴 (분리 규칙, 내부 순서)
- `rules/import-protection.md` - 클라이언트/서버 import 경계, marker import, `vite.config.ts` 설정 규칙
- `rules/middleware.md` - Middleware validation, context 전파, `sendContext` 보안
- `rules/execution-model.md` - 서버/클라이언트/isomorphic 실행 경계
- `rules/server-routes.md` - Server Function 대신 HTTP endpoint를 허용하는 경우
- `rules/ssr-hydration.md` - SSR 모드, `ClientOnly`, hydration 안정성 규칙
- `rules/platform.md` - `getRouter()`, env typing/validation, path alias, 운영 endpoint 규칙

## 3단계: 변경 전 검증 체크리스트

코드 작성 전, 계획된 변경사항을 아래 게이트에 대해 검증:

### 브라운필드 적용 규칙

- 레거시 코드의 모든 차이를 곧바로 프로젝트 전체 실패로 보지 않습니다
- 안전 경계 문제는 특히 touched file에서 즉시 차단합니다
- hypercore 전용 스타일/구조 차이는 untouched legacy code에서는 migration backlog로 기록할 수 있습니다
- 직접 수정하는 파일은, 그것이 과도하게 위험한 마이그레이션이 아니라면 규칙에 맞게 끌어올립니다

### 게이트 1: 레이어 위반

```
Routes -> Server Functions -> Features -> Database
```

| 확인 항목 | 규칙 |
|-----------|------|
| 라우트에서 DB 직접 접근? | 차단. Server Functions -> Features를 거쳐야 함 |
| 라우트에서 Prisma 호출? | 차단. Server Functions 사용 |
| Server Function이 Features 건너뜀? | 단순 CRUD만 허용 |
| 클라이언트에서 Server Function 직접 호출? | 차단. TanStack Query 사용 (예외: `loader`/`beforeLoad`는 서버사이드 실행이므로 직접 호출 가능) |

### 게이트 2: 라우트 구조

| 확인 항목 | 규칙 |
|-----------|------|
| 플랫 파일 라우트? (`routes/users.tsx`) | 차단. 폴더 사용 (`routes/users/index.tsx`) |
| `-components/` 폴더 없음? | 차단. 모든 페이지 필수 |
| `-hooks/` 폴더 없음? | 차단. 모든 페이지 필수 |
| `-functions/` 폴더 없음? | 차단. 모든 페이지 필수 |
| `export` 없는 `const Route`? | 차단. `export const Route` 필수 |
| 페이지 컴포넌트에 로직? | 차단. `-hooks/`로 분리 |
| 레이아웃 라우트에 `route.tsx` 없음? | 차단. beforeLoad/loader가 필요한 라우트는 `route.tsx` 필수 |
| 검색 파라미터가 있는 라우트에 `validateSearch` 없음? | 차단. `@tanstack/zod-adapter`의 `zodValidator`와 `validateSearch` 필수 |
| 라우트에 `pendingComponent` 없음? | 경고. loader가 있는 모든 라우트에 권장 |
| 일반 앱 로직용 새 `/api` 라우트 추가? | 차단. Server Functions 사용 |
| `better-auth` 또는 webhook/health/integration HTTP semantics 때문에 필요한 `/api` 라우트인가? | 명시적 근거가 있으면 허용 |

### 게이트 3: Server Functions

| 확인 항목 | 규칙 |
|-----------|------|
| POST/PUT/PATCH에 `inputValidator` 없음? | 차단 |
| 인증 필요한데 `middleware` 없음? | 차단 |
| `.inputValidator()` 대신 `.validator()` 사용? | 차단. `.validator()`는 존재하지 않음 |
| handler가 체인의 마지막이 아님? | 차단. handler는 반드시 마지막 (middleware/inputValidator 순서는 유연) |
| 검색 파라미터에 `zodValidator` 어댑터 미사용? | 차단. `@tanstack/zod-adapter`의 `zodValidator` 사용 |
| 컴포넌트에서 서버 함수 직접 호출? | 차단. `@tanstack/react-start`의 `useServerFn` 훅 사용 |
| `functions/index.ts` 배럴 익스포트? | 차단. 트리 쉐이킹 실패 |

### 게이트 4: Hook

| 확인 항목 | 규칙 |
|-----------|------|
| 페이지 컴포넌트 내부에 Hook? | 차단. `-hooks/` 폴더에 위치해야 함 |
| Hook 순서 잘못됨? | 차단. State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect |
| 반환 타입 인터페이스 없음? | 차단 |
| camelCase Hook 파일명? | 차단. `use-kebab-case.ts` 사용 |

### 게이트 5: 컨벤션

| 확인 항목 | 규칙 |
|-----------|------|
| camelCase 파일명? | 차단. kebab-case 사용 |
| `function` 키워드? | 차단. const 화살표 함수 사용 |
| `any` 타입? | 차단. `unknown` 사용 |
| 명시적 반환 타입 없음? | 차단 |
| Import 순서 잘못됨? | 차단. 외부 -> @/ -> 상대경로 -> Type |
| 한글 묶음 주석 없음? | 차단 |
| `z.string().email()` 패턴 사용? | 차단. Zod 4.x `z.email()` 직접 사용 |

### 게이트 6: Execution Model

| 확인 항목 | 규칙 |
|-----------|------|
| `loader`를 서버 전용이라고 가정함? | 차단. `loader`는 기본적으로 isomorphic |
| secret/DB/filesystem 접근을 `loader`나 클라이언트에서 도달 가능한 코드에 직접 둠? | 차단. `createServerFn` / `createServerOnlyFn` 뒤로 이동 |
| 브라우저 전용 API를 `ClientOnly` / client-only 경계 없이 서버 가능 코드에서 사용함? | 차단 |
| 환경 함수가 더 명확한데 `typeof window` 수동 분기를 사용함? | 경고. `createClientOnlyFn` / `createServerOnlyFn` / `createIsomorphicFn` 우선 |

### 게이트 7: Import Protection

| 확인 항목 | 규칙 |
|-----------|------|
| 클라이언트에서 도달 가능한 코드가 `*.server.*`를 import함? | 차단 |
| 서버 실행 경로가 `*.client.*`를 import함? | 차단 |
| 환경 전용 파일인데 `.server.*` / `.client.*` 접미사나 marker import가 없음? | 차단. 이름 변경 또는 `server-only` / `client-only` marker 추가 |
| 커스텀 디렉터리 deny가 필요한데 `vite.config.ts`에 `tanstackStart({ importProtection: ... })`가 없음? | 차단. 먼저 설정 추가/확장 |
| 기존 `importProtection` 설정을 확장하지 않고 덮어씀? | 차단 |
| `importProtection`이 꺼져 있음? | 사용자가 명시적으로 요청한 경우가 아니면 차단 |
| 서버 전용 import가 `createServerFn` / `createServerOnlyFn` 경계 밖에서 살아남음? | 차단. 파일 분리 또는 `createServerOnlyFn`으로 래핑 |

**Import protection은 선택이 아닙니다.** `vite.config.ts`에 이미 `tanstackStart()`가 있으면 플러그인을 중복 추가하지 말고 기존 설정을 확장해야 합니다.

### 게이트 8: SSR / Hydration

| 확인 항목 | 규칙 |
|-----------|------|
| 첫 렌더에 `Date.now()`, random ID, locale 차이 같은 불안정 값이 직접 나감? | 안정화되지 않았다면 차단 |
| 브라우저 전용 위젯을 `ClientOnly`나 SSR 제한 없이 SSR함? | 차단 |
| `ssr: false` / `ssr: 'data-only'`를 fallback 전략 없이 사용함? | 차단 |
| 루트 SSR을 줄이면서 `shellComponent` 동작을 모름? | 차단 |

### 게이트 9: Platform Setup

| 확인 항목 | 규칙 |
|-----------|------|
| `src/router.tsx`에 `getRouter()` fresh-instance 패턴이 없음? | 차단 |
| env 값을 클라이언트/서버 경계 없이 사용함? | 차단 |
| 중간 이상 규모 앱인데 env typing/runtime validation이 없음? | 경고. `src/env.d.ts`와 validation 추가 |
| Vite 동작을 암묵적으로 가정하고 path alias를 설정함? | 차단. 사용 중인 Vite 버전에 맞게 명시 설정 |

## 3.5단계: Auto-Remediation Policy

이슈가 국소적이고, 되돌리기 쉽고, 저위험이면 직접 자동 수정합니다.

- `vite.config.ts`의 `importProtection` 추가/확장
- `src/router.tsx`의 `getRouter()` fresh-instance 패턴 추가
- env typing/runtime validation 스캐폴딩 추가
- marker import 또는 명시적 boundary wrapper 추가
- 비신뢰 `sendContext`에 대한 middleware validation 추가

다만 범위가 넓거나 잠재적으로 깨질 수 있는 마이그레이션은 명시적 근거 없이 자동 적용하지 않습니다.

- 대량 route/file rename
- 광범위한 `/api` -> Server Function 전환
- 여러 라우트에 걸친 SSR 모드 변경
- alias 전역 import 재작성

## 4단계: 구현 (Ralph와 함께)

Ralph와 함께 사용 시, 모든 PRD 스토리에 다음 수락 기준 포함 필수:

```
- [ ] 레이어 아키텍처 준수 (레이어 건너뛰기 없음)
- [ ] 라우트 폴더 구조 -components/, -hooks/, -functions/ 사용
- [ ] export const Route = createFileRoute(...) 사용
- [ ] Server Functions 올바른 체이닝 (handler 항상 마지막, middleware/inputValidator 순서 유연)
- [ ] 검색 파라미터는 @tanstack/zod-adapter의 zodValidator 사용
- [ ] Custom Hook은 -hooks/에 올바른 내부 순서로 작성
- [ ] 모든 파일명 kebab-case
- [ ] Execution model 규칙 검증 완료 (`loader` isomorphic, env 경계 명시)
- [ ] Import protection 규칙 검증 완료 (`*.server.*` / `*.client.*`, marker, leaky import 없음)
- [ ] Server route가 있다면 실제 HTTP semantics로 정당화됨
- [ ] SSR/hydration 규칙 검증 완료 (`ClientOnly`, `ssr`, 결정적 첫 렌더)
- [ ] `src/router.tsx`가 `getRouter()` 패턴을 사용하고 platform 설정이 명시적임
- [ ] `vite.config.ts`가 `tanstackStart({ importProtection: ... })`를 유지 또는 확장함
- [ ] 한글 묶음 주석 존재
- [ ] const 화살표 함수와 명시적 반환 타입
```

## 5단계: 변경 후 검증

코드 작성 후 검증:

1. **구조 확인**: 라우트 폴더 `ls` - `-components/`, `-hooks/`, `-functions/` 존재 확인
2. **Export 확인**: 라우트 파일에서 `export const Route` grep
3. **레이어 확인**: 라우트 파일에 Prisma import 없음
4. **컨벤션 확인**: camelCase 파일명 없음, `function` 키워드 선언 없음
5. **Hook 순서 확인**: Hook 파일 읽기, State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect 확인
6. **Execution model 확인**: `loader`에 secret/DB 접근이 직접 없고, 브라우저 API가 client-only 경계 안에 있는지 확인
7. **Import 경계 확인**: 클라이언트에서 도달 가능한 `*.server.*` 없음, 서버 경로의 `*.client.*` 없음, suffix가 없으면 marker 사용
8. **SSR/hydration 확인**: 불안정 UI가 안정화되었고, `ClientOnly`/`ssr`가 의도적으로 쓰였는지 확인
9. **Platform 확인**: `src/router.tsx`의 `getRouter()`, env typing/validation, path alias 설정이 명시적인지 확인
10. **Vite 설정 확인**: `vite.config.ts`가 `importProtection`을 유지/확장하고 비활성화하지 않았는지 확인

## 빠른 참조: 폴더 구조

```
src/
├── routes/                    # 파일 기반 라우팅
│   └── <page>/
│       ├── index.tsx          # 페이지 (UI만)
│       ├── route.tsx          # 레이아웃 (beforeLoad, loader)
│       ├── -components/       # 필수: 페이지 컴포넌트
│       ├── -hooks/            # 필수: 페이지 훅 (모든 로직 여기에)
│       ├── -functions/        # 필수: 페이지 서버 함수
│       └── -sections/         # 선택: 200줄 이상 페이지
├── features/<domain>/         # 내부 도메인 (Prisma 쿼리)
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
├── services/<provider>/       # 외부 SDK 래퍼
├── functions/                 # 글로벌 서버 함수 (index.ts 금지!)
│   └── middlewares/
├── database/                  # Prisma 클라이언트 싱글톤
├── stores/                    # Zustand 스토어
├── hooks/                     # 글로벌 훅
├── components/                # 공유 UI
│   ├── ui/                    # shadcn/ui
│   ├── layout/                # Header, Sidebar, Footer
│   └── shared/                # 공용 컴포넌트
├── types/                     # 전역 타입
├── env/                       # t3-env 환경변수 검증
├── config/                    # auth, query-client, sentry
└── lib/                       # 유틸리티
    ├── utils/
    ├── constants/
    └── validators/
```

## 흔한 실수

| 실수 | 수정 |
|------|------|
| `routes/users.tsx` | `routes/users/index.tsx` |
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| `.validator(schema)` | `.inputValidator(schema)` |
| 페이지 컴포넌트에 로직 | `-hooks/use-*.ts`로 분리 |
| `lib/db` 또는 `lib/store` 폴더 | `database/`와 `stores/` 사용 |
| `functions/index.ts` 배럴 | 개별 파일에서 직접 import |
| Hook 순서 혼재 | 순서: State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect |
| `getUserById.ts` 파일명 | `get-user-by-id.ts` |
| `function doThing() {}` | `const doThing = (): ReturnType => {}` |
| `z.string().email()` | `z.email()` (Zod 4.x) |
| `validateSearch`에 Zod 스키마 직접 사용 | `@tanstack/zod-adapter`의 `zodValidator(schema)` 사용 |
| `useServerFn` 없이 서버 함수 호출 | 컴포넌트에서 `useServerFn(serverFn)` 사용 |
| `createMiddleware()` 옵션 없이 사용 | `createMiddleware({ type: 'function' })` 사용 |
| 라우트에 `pendingComponent` 누락 | 로딩 상태를 위해 `pendingComponent` 추가 |
| `loader`에서 secret/DB 접근을 직접 수행 | `createServerFn` / `createServerOnlyFn` 뒤로 이동 |
| 브라우저 전용 위젯을 SSR에 직접 렌더 | `ClientOnly`로 감싸거나 route SSR을 제한 |
| 정당화되지 않은 내부 RPC용 `/api` 라우트 핸들러 | Server Function으로 대체 |
| 서버 전용 헬퍼가 컴파일러 경계 밖에서 사용됨 | `*.server.*`로 분리하거나 `createServerOnlyFn`으로 감싸기 |
| `vite.config.ts`에 `importProtection` 확장 누락 | `tanstackStart({ importProtection: ... })` 추가 또는 확장 |
| `getRouter()` fresh instance 패턴 누락 | `src/router.tsx` 수정 |
| 중간 이상 규모 앱에 env typing/runtime validation 없음 | `src/env.d.ts`와 validation 추가 |
| path alias를 Vite 설정 없이 가정함 | Vite 버전에 맞게 `tsconfigPaths` 설정 |

## 위험 신호 - 즉시 수정

- 라우트 파일에서 `@/database/prisma` 직접 import
- `const Route`에 `export` 누락
- 페이지 컴포넌트에 `useState`, `useQuery` 등 인라인 (Hook 아님)
- Server Function에서 `.inputValidator()` 대신 `.validator()` 사용
- 어디든 `any` 타입
- camelCase 파일명
- 정당화되지 않은 내부 RPC용 `/api` 라우트 핸들러 (Server Functions 사용)
- 정당화되지 않은 server route 또는 내부 RPC용 `/api`
- 라우트에 `-hooks/` 폴더 없음
- 검색 파라미터가 있는 라우트에 `validateSearch` 미사용
- 컴포넌트에서 서버 함수 직접 호출 (`useServerFn` 미사용)
- `createMiddleware()`에 `{ type: 'function' }` 옵션 누락
- `loader` 내부에 secret 또는 DB 접근
- 브라우저 전용 API가 서버 가능 코드 경로에 존재
- 클라이언트에서 도달 가능한 파일이 `*.server.*`를 import함
- 서버 실행 경로가 `*.client.*`를 import함
- hydration에 unsafe한 첫 렌더 출력
- `src/router.tsx`에 `getRouter()` fresh instance 패턴 없음
- `vite.config.ts`에서 `importProtection`이 꺼져 있거나 필요한 deny 규칙이 없음
