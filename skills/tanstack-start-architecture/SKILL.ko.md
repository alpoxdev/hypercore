# TanStack Start 아키텍처 강제 적용

## 개요

hypercore TanStack Start 아키텍처 규칙을 100% 준수하도록 강제합니다. 프로젝트 구조를 검증한 후, 모든 코드 변경에 엄격한 레이어/라우트/훅/컨벤션 규칙을 적용합니다.

**이 스킬은 엄격합니다. 정확히 따르세요. 예외 없음.**

**필수:** TanStack Start 프로젝트 작업 시, 반드시 `/oh-my-claudecode:ralph`와 함께 이 스킬을 사용하여 아키텍처 규칙 100% 준수를 보장하세요. Ralph의 지속 루프가 모든 규칙을 검증하고 위반이 빠져나가지 않도록 합니다.

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

## 3단계: 변경 전 검증 체크리스트

코드 작성 전, 계획된 변경사항을 아래 게이트에 대해 검증:

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

## 위험 신호 - 즉시 수정

- 라우트 파일에서 `@/database/prisma` 직접 import
- `const Route`에 `export` 누락
- 페이지 컴포넌트에 `useState`, `useQuery` 등 인라인 (Hook 아님)
- Server Function에서 `.inputValidator()` 대신 `.validator()` 사용
- 어디든 `any` 타입
- camelCase 파일명
- `/api` 라우트 핸들러 (Server Functions 사용)
- 라우트에 `-hooks/` 폴더 없음
- 검색 파라미터가 있는 라우트에 `validateSearch` 미사용
- 컴포넌트에서 서버 함수 직접 호출 (`useServerFn` 미사용)
- `createMiddleware()`에 `{ type: 'function' }` 옵션 누락
