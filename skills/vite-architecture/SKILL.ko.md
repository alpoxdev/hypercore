---
name: vite-architecture
description: Vite + TanStack Router 프로젝트에서 작업할 때 사용 - 아키텍처 규칙(레이어, 라우트, 훅, 서비스, 컨벤션)을 강제하며 코드 변경 전 필수 검증을 수행. 파일 생성, 라우트 작업, 훅 패턴, 또는 Vite + TanStack Router 코드베이스의 구조적 변경 시 트리거.
---

# Vite + TanStack Router 아키텍처 강제

## 개요

hypercore의 Vite + TanStack Router 아키텍처 규칙을 코드 수정 전부터 엄격하게 적용합니다.

**이 스킬은 엄격합니다. 정확히 따르세요. 예외 없음.**

**운영 모드:** 이 스킬은 자체적으로 동작해야 합니다. 아키텍처 규칙을 적용하기 위해 외부 오케스트레이션 표면을 기다리지 마세요. 저장소 로컬의 지속 실행 루프가 이미 있다면 그 안으로 게이트를 가져가고, 없으면 이 스킬만으로 바로 진행합니다.

**참고:** 이 스킬의 일부 규칙은 TanStack Router 공식 기본보다 더 엄격합니다. 사용자가 공식 기본 규칙을 따르라고 명시하지 않는 한 hypercore 팀 규칙으로 해석합니다.

## 트리거 예시

### Positive

- `이 Vite + TanStack Router 앱에서 route 구조, validateSearch, service boundary를 먼저 점검해줘.`
- `Vite + TanStack Router 앱에 새 route folder를 추가하고 hooks/services 규칙까지 맞춰줘.`
- `TanStack Router 페이지를 리팩터링해서 UI는 route에 남기고 로직은 -hooks/로 옮겨줘.`

### Negative

- `browser QA용 새 Codex skill을 만들어줘.`
- `createServerFn과 @tanstack/react-start를 쓰는 TanStack Start 앱을 리뷰해줘.`

### Boundary

- `Vite route 파일에서 아주 작은 문구만 수정해줘.`
직접 수정만으로 끝날 수 있지만, touched file에는 빠른 아키텍처 준수 점검이 여전히 필요합니다.

- `이 저장소는 사실 @tanstack/react-start를 쓰고 있어.`
이 경우 Vite 규칙을 강제로 적용하지 말고 `tanstack-start-architecture`로 전환합니다.

## 1단계: 프로젝트 검증

작업 전, Vite + TanStack Router 프로젝트인지 확인:

```bash
# Vite + TanStack Router 지표 확인 (하나라도 있으면 통과)
grep -r "@tanstack/react-router" package.json 2>/dev/null
grep -r "vite" package.json 2>/dev/null
ls vite.config.ts 2>/dev/null
ls src/routes/__root.tsx 2>/dev/null
```

아무것도 없으면: **중단. 이 스킬은 해당하지 않습니다.** 사용자에게 알리고 일반 구현/리뷰 경로로 돌아갑니다.

`@tanstack/react-start` 또는 `app.config.ts`가 있으면: **중단.** `tanstack-start-architecture`로 라우팅합니다.

Vite + TanStack Router 프로젝트가 맞다면 아키텍처 강제 적용 진행.

## 2단계: 아키텍처 규칙 읽기

상세 규칙 참조 파일 로드:

**필수:** 코드 작성 전 이 스킬 디렉토리의 `architecture-rules.md`를 읽습니다.

필요한 규칙 파일:
- `rules/conventions.ko.md` - 네이밍, TypeScript, import, 주석
- `rules/routes.ko.md` - route folder 구조, `route.tsx`, loader, search params
- `rules/services.ko.md` - 공개 API 서비스, query options, mutation, client 경계
- `rules/hooks.ko.md` - custom hook 분리와 내부 순서
- `rules/execution-model.ko.md` - loader/runtime 경계, SSR 주의점, env 안전성
- `rules/platform.ko.md` - `vite.config.ts`, router 설정, generated file, env/alias 규칙

## 3단계: 변경 전 검증 체크리스트

코드 작성 전, 계획된 변경사항을 아래 게이트에 대해 검증합니다.

### 브라운필드 적용 규칙

- untouched legacy code의 모든 차이를 즉시 프로젝트 전체 실패로 보지 않습니다.
- 안전/경계 문제는 특히 touched file에서 즉시 차단합니다.
- hypercore 전용 스타일/구조 드리프트는 untouched legacy code라면 migration backlog로 기록할 수 있습니다.
- 직접 수정하는 파일은 과도하게 위험한 마이그레이션이 아니라면 규칙에 맞게 끌어올립니다.

### 게이트 1: 레이어 위반

```text
Routes -> Services -> External API
```

| 확인 항목 | 규칙 |
|-----------|------|
| route에서 `fetch`/`axios` 직접 호출? | 차단. services를 거쳐야 함 |
| hook에서 `fetch`/`axios` 직접 호출? | 차단. services를 거쳐야 함 |
| service가 raw `Response`를 route/hook으로 넘김? | 차단. 타입된 데이터 반환 |
| Vite 앱에서 `createServerFn`, `useServerFn`, Start 전용 middleware API 사용? | 차단 |

### 게이트 2: 라우트 구조

| 확인 항목 | 규칙 |
|-----------|------|
| UI/logic를 가진 페이지가 flat file route임? (`routes/users.tsx`) | 차단. 폴더형 route(`routes/users/index.tsx`) 사용 |
| `-components/` 폴더 없음? | 차단. 모든 페이지 필수 |
| `-hooks/` 폴더 없음? | 차단. 모든 페이지 필수 |
| `-functions/` 폴더 존재? | 차단. 이 Vite 스킬에서는 허용하지 않음 |
| `export` 없는 `const Route`? | 차단. `export const Route` 필수 |
| 페이지 컴포넌트 안에 로직이 남아 있음? | 차단. `-hooks/`로 분리 |
| shared loader/beforeLoad/layout을 가지는데 `route.tsx`가 없음? | 차단 |
| search params가 있는데 `validateSearch`가 없음? | 차단. `zodValidator` 사용 |
| loader가 있는데 `pendingComponent`가 없음? | 경고. 권장 |

### 게이트 3: 서비스

| 확인 항목 | 규칙 |
|-----------|------|
| POST/PUT/PATCH 전에 스키마 검증 없음? | 차단. Zod 검증 필요 |
| route나 hook에 직접 `fetch`/`axios`? | 차단. service 함수 사용 |
| `services/index.ts` 배럴 export? | 차단. 구체 파일에서 직접 import |
| service 함수의 명시적 반환 타입 없음? | 차단 |

### 게이트 4: Hook

| 확인 항목 | 규칙 |
|-----------|------|
| 페이지 컴포넌트 안에 hook 로직이 남아 있음? | 차단. `-hooks/`로 이동 |
| Hook 순서가 잘못됨? | 차단. State -> Global -> Query -> Handlers -> Memo -> Effect |
| export된 반환 타입 interface 없음? | 차단 |
| camelCase hook 파일명? | 차단. `use-kebab-case.ts` 사용 |
| Vite hook 안에 `useServerFn` 사용? | 차단 |

### 게이트 5: 컨벤션

| 확인 항목 | 규칙 |
|-----------|------|
| camelCase 파일명? | 차단. kebab-case 사용 |
| `function` 키워드? | 차단. const 화살표 함수 사용 |
| `any` 타입? | 차단. `unknown` 사용 |
| 명시적 반환 타입 없음? | 차단 |
| import 순서 잘못됨? | 차단. External -> @/ -> Relative -> Type |
| 로직 묶음용 한글 블록 주석 없음? | 차단 |
| `z.string().email()` 사용? | 차단. Zod 4의 `z.email()` 사용 |

### 게이트 6: 실행 모델

| 확인 항목 | 규칙 |
|-----------|------|
| route `loader`를 private server-only 경계로 취급함? | 차단. loader는 클라이언트에서 도달 가능하며 SSR/manual rendering에도 참여할 수 있음 |
| route module 또는 loader 안에서 secret, DB, filesystem, privileged SDK 접근? | 차단. 실제 backend/API 경계 뒤로 이동 |
| 브라우저 전용 API를 module scope나 shared route helper에서 경계 없이 사용함? | 차단 |
| client에서 도달 가능한 코드에서 `VITE_`가 아닌 env 접근? | 차단 |

### 게이트 7: 플랫폼 설정

| 확인 항목 | 규칙 |
|-----------|------|
| `vite.config.ts`에 `tanstackRouter()`가 없거나 plugin 순서가 잘못됨? | 차단. router plugin은 명시적이어야 하고 `react()`보다 앞서야 함 |
| `routeTree.gen.ts`를 수동 편집함? | 차단. generated file로 취급 |
| router 설정이 숨겨져 있거나 SSR/manual rendering 요구와 충돌함? | 경고. `src/router.tsx`를 명시적으로 유지하고 SSR/manual rendering이 있으면 fresh router factory 사용 |
| path alias/env 설정을 암묵적 동작에만 의존함? | 경고. `tsconfig`/Vite config/runtime validation을 명시 |

## 3.5단계: Auto-Remediation Policy

이슈가 국소적이고, 되돌리기 쉽고, 저위험이면 직접 수정합니다.

- 누락된 `validateSearch` 추가
- route/hook의 직접 네트워크 호출을 `services/`로 이동
- 누락된 `pendingComponent` 또는 `errorComponent` 추가
- touched page에 필요한 `-components/`, `-hooks/` 폴더 생성
- `tanstackRouter()` plugin 설정, router scaffolding, env/alias wiring 보강

다음과 같은 넓고 위험한 변경은 명시적 근거 없이 자동 적용하지 않습니다.

- 대량 route/file rename
- 많은 페이지를 한 번에 재구성하는 route tree 변경
- SPA-only 저장소에 SSR/manual server rendering 도입
- 대규모 auth/API client 재작성

## 4단계: 구현

현재 작업의 acceptance criteria에 아래 항목을 포함합니다.

```text
- [ ] Layer architecture respected (Routes -> Services -> External API)
- [ ] Route uses folder structure with -components/ and -hooks/
- [ ] export const Route = createFileRoute(...) used
- [ ] No Start-only server-function APIs in this Vite project
- [ ] Search params use zodValidator from @tanstack/zod-adapter
- [ ] Custom Hooks live in -hooks/ with correct internal order
- [ ] Loaders stay public-safe and SSR-safe
- [ ] Vite/router platform setup stays explicit (router plugin, router file, generated files)
- [ ] All filenames kebab-case
- [ ] Korean block comments present
- [ ] const arrow functions with explicit return types
```

## 5단계: 변경 후 검증

코드 작성 후 아래를 검증합니다.

1. **구조 확인**: touched page에 `-components/`, `-hooks/`가 있고 `-functions/`는 없는지 확인
2. **익스포트 확인**: `export const Route` 사용 여부 확인
3. **레이어 확인**: touched route/hook 파일에 직접 `fetch`/`axios`가 없는지 확인
4. **컨벤션 확인**: camelCase 파일명, `function` 선언이 없는지 확인
5. **Hook 순서 확인**: State -> Global -> Query -> Handlers -> Memo -> Effect 순서 확인
6. **실행 경계 확인**: loader/route module이 secret, DB client, private env를 직접 만지지 않는지 확인
7. **플랫폼 확인**: `vite.config.ts`, `src/router.tsx`, env wiring, generated router file이 일관적인지 확인

## 빠른 참조: 폴더 구조

```text
src/
├── routes/
│   ├── __root.tsx
│   ├── index.tsx
│   └── users/
│       ├── route.tsx          # shared layout / beforeLoad / loader
│       ├── index.tsx          # /users
│       ├── -components/
│       ├── -hooks/
│       ├── $id/
│       │   ├── index.tsx      # /users/$id
│       │   ├── -components/
│       │   └── -hooks/
│       └── -sections/         # 큰 페이지에서만 선택
├── services/<domain>/
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
├── hooks/
├── stores/
├── components/
├── config/
├── env/
├── lib/
├── src/router.tsx
└── routeTree.gen.ts           # generated, 수동 편집 금지
```

## 자주 하는 실수

| 실수 | 수정 |
|------|------|
| `routes/users.tsx`로 전체 페이지 구성 | `routes/users/index.tsx` |
| 자체 UI/logic 폴더가 필요한데 `routes/users/$id.tsx` 사용 | `routes/users/$id/index.tsx` |
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| route/hook에서 직접 `fetch()` | `services/<domain>/queries.ts` 또는 `mutations.ts`로 이동 |
| `createServerFn(...)`, `useServerFn(...)` 사용 | services + TanStack Query 사용 |
| 페이지 컴포넌트 안에 `useState`, `useQuery`, mutation 로직 유지 | `-hooks/use-*.ts`로 추출 |
| `routeTree.gen.ts` 수동 편집 | 재생성하고 수동 편집 금지 |
| loader가 secret이나 `VITE_`가 아닌 env를 읽음 | 실제 backend/API 경계 뒤로 이동 |
| `validateSearch` 없이 search params 사용 | `zodValidator(schema)` 추가 |

## 빨간 신호 - 멈추고 수정

- `@tanstack/react-start`가 있는데 Vite 스킬을 적용하려고 함
- route나 hook이 `fetch`/`axios`를 직접 import함
- `const Route`에 `export`가 없음
- 페이지 컴포넌트 안에 state/query/mutation 로직이 인라인으로 있음
- route tree에 `createServerFn`, `useServerFn`, `-functions/`가 등장함
- loader나 route module이 secret, DB client, private env를 직접 읽음
- `routeTree.gen.ts`에 수동 편집이 있음
- `validateSearch` 없이 search params 사용
