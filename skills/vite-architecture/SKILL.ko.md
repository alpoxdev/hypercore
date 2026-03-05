---
name: vite-architecture
description: Vite + TanStack Router 프로젝트에서 작업할 때 사용 - 아키텍처 규칙(레이어, 라우트, 훅, 서비스, 컨벤션)을 강제하며 코드 변경 전 필수 검증을 수행. 파일 생성, 라우트 작업, 훅 패턴, 또는 Vite + TanStack Router 코드베이스의 구조적 변경 시 트리거.
---

# Vite + TanStack Router 아키텍처 강제

## 개요

hypercore Vite 아키텍처 규칙을 100% 준수하도록 강제합니다. 프로젝트 구조를 검증한 후, 모든 코드 변경에 엄격한 레이어/라우트/훅/컨벤션 규칙을 적용합니다.

**이 스킬은 RIGID(엄격)합니다. 정확히 따르세요. 예외 없음.**

**필수:** Vite + TanStack Router 프로젝트에서는 반드시 이 스킬을 `/oh-my-claudecode:ralph`와 함께 사용하여 100% 아키텍처 준수를 보장하세요.

## Step 1: 프로젝트 검증

작업 전, Vite + TanStack Router 프로젝트 확인:

```bash
# Vite + TanStack Router 지표 확인 (하나라도 있으면 OK)
grep -r "@tanstack/react-router" package.json 2>/dev/null
grep -r "vite" package.json 2>/dev/null
ls vite.config.ts 2>/dev/null
ls src/routes/__root.tsx 2>/dev/null
```

아무것도 없으면: **STOP. 이 스킬은 적용되지 않습니다.** 사용자에게 알리세요.

있으면: 아키텍처 강제를 진행하세요.

> **주의:** `@tanstack/react-start`가 있으면 `tanstack-start-architecture`를 사용하세요.

## Step 2: 아키텍처 규칙 읽기

상세 규칙 참조 로드:

**필수:** 코드를 작성하기 전에 이 스킬 디렉토리의 `architecture-rules.md`를 읽으세요.

상세 패턴과 예시는 관련 참조 파일도 읽으세요:
- `rules/conventions.md` - 코드 컨벤션 (네이밍, TypeScript, 임포트, 주석)
- `rules/routes.md` - 라우트 구조 (폴더 규칙, 패턴, 로더)
- `rules/services.md` - API 서비스 (스키마, 쿼리, 뮤테이션)
- `rules/hooks.md` - 커스텀 훅 패턴 (분리 규칙, 내부 순서)

## Step 3: 변경 전 검증 체크리스트

**코드를 작성하기 전**, 계획한 변경사항을 다음 게이트에서 검증하세요:

### Gate 1: 레이어 위반

```
Routes -> Services -> External API
```

| 확인 | 규칙 |
|-------|------|
| 라우트에서 직접 fetch/axios 호출? | 차단. Services를 통해야 함 |
| 훅에서 직접 fetch/axios 호출? | 차단. Services를 통해야 함 |
| 서비스가 raw Response 반환? | 차단. 타입된 데이터를 반환해야 함 |
| `createServerFn` 사용? | 차단. Vite 프로젝트에는 서버 함수 없음 |

### Gate 2: 라우트 구조

| 확인 | 규칙 |
|-------|------|
| 플랫 파일 라우트? (`routes/users.tsx`) | 차단. 폴더 사용 (`routes/users/index.tsx`) |
| `-components/` 폴더 없음? | 차단. 모든 페이지에 필요 |
| `-hooks/` 폴더 없음? | 차단. 모든 페이지에 필요 |
| `-functions/` 폴더 존재? | 차단. Vite에는 서버 함수 없음 |
| `export` 없는 `const Route`? | 차단. `export const Route`이어야 함 |
| 페이지 컴포넌트에 로직? | 차단. `-hooks/`로 추출 |
| 레이아웃 라우트에 `route.tsx` 없음? | 차단. beforeLoad/loader가 있는 라우트는 `route.tsx` 필요 |
| 검색 파라미터에 `validateSearch` 없음? | 차단. `zodValidator`로 `validateSearch` 사용 |

### Gate 3: 서비스

| 확인 | 규칙 |
|-------|------|
| POST/PUT/PATCH에 스키마 검증 없음? | 차단. 호출 전 Zod로 검증 |
| 라우트나 훅에 직접 `fetch`/`axios`? | 차단. 서비스 함수 사용 |
| `services/index.ts` 배럴 익스포트? | 차단. 개별 파일에서 직접 임포트 |
| 서비스 함수에 반환 타입 없음? | 차단. 항상 명시적 타입 지정 |

### Gate 4: 훅

| 확인 | 규칙 |
|-------|------|
| 페이지 컴포넌트 안에 훅? | 차단. `-hooks/` 폴더에 있어야 함 |
| 훅 순서 잘못됨? | 차단. State -> Global -> Query -> Handlers -> Memo -> Effect |
| 반환 타입 인터페이스 없음? | 차단 |
| camelCase 훅 파일명? | 차단. `use-kebab-case.ts` 사용 |
| 훅에 `useServerFn`? | 차단. Vite에는 서버 함수 없음 |

### Gate 5: 컨벤션

| 확인 | 규칙 |
|-------|------|
| camelCase 파일명? | 차단. kebab-case 사용 |
| `function` 키워드? | 차단. const 화살표 함수 사용 |
| `any` 타입? | 차단. `unknown` 사용 |
| 명시적 반환 타입 없음? | 차단 |
| 임포트 순서 잘못됨? | 차단. External -> @/ -> Relative -> Type |
| 한국어 블록 주석 없음? | 차단 (코드 그룹에) |
| `z.string().email()` 패턴? | 차단. Zod 4.x `z.email()` 직접 사용 |

## Step 4: 구현 (ralph와 함께)

ralph와 함께 사용할 때, 모든 PRD 스토리에 다음 인수 기준이 포함되어야 합니다:

```
- [ ] 레이어 아키텍처 준수 (Routes -> Services -> External API)
- [ ] 라우트가 -components/, -hooks/ 폴더 구조 사용
- [ ] export const Route = createFileRoute(...) 사용
- [ ] 서버 함수(createServerFn, useServerFn) 없음
- [ ] 검색 파라미터에 @tanstack/zod-adapter의 zodValidator 사용
- [ ] 커스텀 훅이 -hooks/에 있고 올바른 내부 순서 준수
- [ ] 모든 파일명 kebab-case
- [ ] 한국어 블록 주석 있음
- [ ] 명시적 반환 타입이 있는 const 화살표 함수
```

## Step 5: 변경 후 검증

코드 작성 후 검증:

1. **구조 확인**: 라우트 폴더 `ls` - `-components/`, `-hooks/` 존재 확인 (`-functions/` 없음)
2. **익스포트 확인**: 라우트 파일에서 `export const Route` grep
3. **레이어 확인**: 라우트나 훅 파일에 직접 fetch/axios 없음
4. **컨벤션 확인**: camelCase 파일명 없음, `function` 키워드 없음
5. **훅 순서 확인**: 훅 파일 읽기, State -> Global -> Query -> Handlers -> Memo -> Effect 검증

## 빠른 참조: 폴더 구조

```
src/
├── routes/                    # 파일 기반 라우팅
│   └── <page>/
│       ├── index.tsx          # 페이지 (UI만)
│       ├── route.tsx          # 레이아웃 (beforeLoad, loader)
│       ├── -components/       # 필수: 페이지 컴포넌트
│       ├── -hooks/            # 필수: 페이지 훅 (모든 로직)
│       └── -sections/         # 선택: 200줄 이상 페이지
├── services/<domain>/         # API 서비스 래퍼
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
├── stores/                    # Zustand 스토어
├── hooks/                     # 전역 훅
├── components/                # 공유 UI
│   ├── ui/                    # shadcn/ui
│   ├── layout/                # Header, Sidebar, Footer
│   └── shared/                # 공통 컴포넌트
├── types/                     # 전역 타입
├── env/                       # t3-env 검증
├── config/                    # auth, query-client, sentry
└── lib/                       # 유틸리티
    ├── utils/
    ├── constants/
    └── validators/
```

## 자주 하는 실수

| 실수 | 수정 |
|---------|-----|
| `routes/users.tsx` | `routes/users/index.tsx` |
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| `createServerFn(...)` | 서비스 함수 + React Query 사용 |
| `useServerFn(...)` | `useQuery` / `useMutation` 직접 사용 |
| 훅에서 직접 `fetch()` | `services/<domain>/queries.ts`로 추출 |
| 페이지 컴포넌트에 로직 | `-hooks/use-*.ts`로 추출 |
| 라우트에 `-functions/` 폴더 | 제거; Vite에는 서버 함수 없음 |
| `lib/store` 폴더 | `stores/` 사용 |
| 혼합된 순서의 훅 | 순서 준수: State -> Global -> Query -> Handlers -> Memo -> Effect |
| `getUserById.ts` 파일명 | `get-user-by-id.ts` |
| `function doThing() {}` | `const doThing = (): ReturnType => {}` |
| `validateSearch`에 직접 Zod 스키마 | `@tanstack/zod-adapter`의 `zodValidator(schema)` 사용 |

## 빨간 신호 - STOP하고 수정

- 라우트나 훅에서 `fetch`/`axios` 직접 임포트
- `const Route`에 `export` 없음
- 페이지 컴포넌트에 인라인 `useState`, `useQuery` 등 (훅에 없음)
- 코드베이스 어디에나 `createServerFn` 또는 `useServerFn`
- 어디에나 `any` 타입
- camelCase 파일명
- 라우트 안에 `-functions/` 폴더
- `validateSearch` 없이 검색 파라미터 사용하는 라우트
