---
name: tanstack-start-react-best-practices
description: TanStack Start와 React 성능 최적화 가이드. React 컴포넌트, TanStack Start 페이지 작성/리뷰/리팩토링 시 최적 성능 패턴 보장. React 컴포넌트, TanStack Router 라우트, 데이터 페칭, 번들 최적화, 성능 개선 작업에 트리거.
license: MIT
framework: tanstack-start
metadata:
  author: vercel
  version: "3.0.0"
  adapted_for: tanstack-start
---

@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md
@../../instructions/multi-agent/coordination-guide.md
@../../instructions/multi-agent/execution-patterns.md

# TanStack Start React 베스트 프랙티스

React 19와 TanStack Start v1 애플리케이션 성능 최적화 가이드. 8개 카테고리, 55개 규칙 포함. 영향도별 우선순위로 자동 리팩토링과 코드 생성 가이드 제공. TanStack Router 라우팅 패턴(Link, useNavigate, useSearch, useParams, beforeLoad, Outlet, pendingComponent, 프리로딩), React Compiler, use() hook, useOptimistic, Middleware, Streaming 등 최신 패턴 반영.

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| **컴포넌트 작성** | React 컴포넌트, TanStack Start 라우트 신규 작성 |
| **데이터 페칭** | 클라이언트/서버 사이드 데이터 페칭 구현 |
| **코드 리뷰** | 성능 이슈 검토 |
| **리팩토링** | 기존 React/TanStack Start 코드 개선 |
| **최적화** | 번들 크기, 로딩 시간 최적화 |

</when_to_use>

---

<parallel_agent_execution>

## 병렬 에이전트 실행

**ULTRAWORK MODE:** TanStack Start 최적화 작업 시 여러 규칙을 동시에 적용하여 5-15배 성능 향상.

### 기본 원칙

| 원칙 | 실행 방법 | 효과 |
|------|----------|------|
| **PARALLEL** | 독립 작업을 단일 메시지에서 동시 실행 | 5-15배 속도 향상 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | 품질 향상, 컨텍스트 격리 |
| **SMART MODEL** | 복잡도별 모델 선택 (haiku/sonnet/opus) | 비용 최적화 |

### Phase별 에이전트 활용

| Phase | 작업 | 에이전트 | 병렬 실행 |
|-------|------|---------|----------|
| **1. 코드베이스 분석** | 라우트 구조, Server Functions, 컴포넌트 파악 | explore (haiku) | ✅ 여러 도메인 동시 탐색 |
| **2. 규칙 적용** | waterfall 제거, 번들 최적화, re-render 최적화 | implementation-executor (sonnet) | ✅ 독립 라우트/컴포넌트 동시 수정 |
| **3. 검증** | typecheck/lint/build, 성능/보안 리뷰 | lint-fixer (sonnet), code-reviewer (opus) | ❌ lint-fixer 순차, code-reviewer 병렬 |
| **4. 완료** | git commit | git-operator (sonnet) | ❌ 순차 |

### 에이전트별 역할

| 에이전트 | 모델 | TanStack Start 작업 | 병렬 실행 |
|---------|------|---------------------|----------|
| **explore** | haiku | 라우트/Server Functions/컴포넌트 구조 분석 | ✅ |
| **implementation-executor** | sonnet | 규칙 적용 (async-parallel, bundle-lazy-routes 등) | ✅ |
| **code-reviewer** | opus | 성능/보안 검토 (server-cache-lru, client-tanstack-query) | ✅ |
| **lint-fixer** | sonnet | tsc/eslint 에러 자동 수정 | ❌ (순차) |

### 실전 패턴

#### 패턴 1: 독립 라우트 병렬 최적화

```typescript
// 시나리오: 여러 라우트에 async-parallel, bundle-lazy-routes 적용

// ❌ 순차 실행 (느림)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="/posts 라우트 최적화: async-parallel, bundle-lazy-routes")
// 60초 대기
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="/users 라우트 최적화: async-parallel, bundle-lazy-routes")
// 총 120초

// ✅ 병렬 실행 (빠름)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`/posts 라우트 최적화:
     - async-parallel: loader에서 Promise.all()
     - bundle-lazy-routes: 무거운 컴포넌트 lazy()`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`/users 라우트 최적화:
     - async-parallel: loader에서 Promise.all()
     - bundle-lazy-routes: 무거운 컴포넌트 lazy()`)
// 총 60초 (가장 긴 작업 기준)
```

#### 패턴 2: Server Function + UI 동시 구현

```typescript
// 시나리오: 새 기능 추가 (API + UI + 테스트)

// ✅ Fan-Out: 병렬 실행
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`createServerFn으로 Comment API 구현:
     - getComments (GET)
     - createComment (POST + inputValidator)
     - server-parallel-fetching 적용`)

Task(subagent_type="designer", model="sonnet",
     prompt=`Comment UI 구현:
     - client-tanstack-query 사용
     - rerender-memo로 최적화
     - bundle-barrel-imports 준수 (직접 import)`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`Comment 통합 테스트:
     - API 테스트
     - UI 테스트`)

// Fan-In: 결과 수집 후 통합
Read("functions/comments.ts")
Read("components/Comments.tsx")
Read("tests/comments.test.ts")
```

#### 패턴 3: 대규모 리팩토링 (배치 처리)

```typescript
// 시나리오: 10개 컴포넌트에 rerender-memo, rerender-dependencies 적용

// ✅ 배치 처리 (토큰 70-90% 절감)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`다음 컴포넌트들에 re-render 최적화 적용:

     파일 목록:
     - components/UserList.tsx
     - components/PostList.tsx
     - ... (10개)

     공통 규칙:
     1. rerender-memo: 비싼 작업 → React.memo() 추출
     2. rerender-dependencies: effect 의존성 → 원시값 사용
     3. rerender-functional-setstate: setState → 함수형 업데이트

     패턴:
     ❌ setItems([...items, newItem])
     ✅ setItems(curr => [...curr, newItem])`)
```

### Model Routing

**원칙:** 작업 복잡도에 따라 모델 선택.

| 복잡도 | 모델 | TanStack Start 작업 예시 | 비용 | 속도 |
|--------|------|------------------------|------|------|
| **LOW** | haiku | 라우트 구조 파악, Server Functions 위치 확인 | 💰 | ⚡⚡⚡ |
| **MEDIUM** | sonnet | async-parallel 적용, bundle-lazy-routes 구현 | 💰💰 | ⚡⚡ |
| **HIGH** | opus | 아키텍처 설계, server-cache-lru 전략, 보안 검토 | 💰💰💰 | ⚡ |

### 체크리스트

**실행 전 확인:**

- [ ] 독립 작업 파악 → 병렬 실행 (여러 라우트, 컴포넌트)
- [ ] 10개 이상 유사 작업 → 배치 처리 (동일 규칙 적용)
- [ ] 복잡도별 모델 선택 (탐색=haiku, 구현=sonnet, 리뷰=opus)
- [ ] Phase별 실행 (분석 → 구현 → 검증 → 완료)
- [ ] 의존성 확인 (Server Function 완료 후 UI 통합)

**효율 목표:**

- 순차 실행 대비 5-15배 속도 향상
- 토큰 사용 70-90% 절감 (배치 처리)
- 병렬도 3-10개 (과도한 병렬 방지)

</parallel_agent_execution>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 접두사 |
|---------|---------|--------|--------|
| 1 | Waterfall 제거 | **CRITICAL** | `async-` |
| 2 | 번들 크기 최적화 | **CRITICAL** | `bundle-` |
| 3 | TanStack Router 라우팅 | **HIGH** | `routing-` |
| 4 | 서버 사이드 성능 | HIGH | `server-` |
| 5 | 클라이언트 데이터 페칭 | MEDIUM-HIGH | `client-` |
| 6 | Re-render 최적화 | MEDIUM | `rerender-` |
| 7 | 렌더링 성능 | MEDIUM | `rendering-` |
| 8 | JavaScript 성능 | LOW-MEDIUM | `js-` |

</categories>

---

<rules>

## 빠른 참조

### 1. Waterfall 제거 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `async-defer-await` | await를 실제 사용 지점으로 이동 |
| `async-parallel` | 독립 작업은 Promise.all() 사용 |
| `async-dependencies` | 부분 의존성은 better-all 사용 |
| `async-loader` | TanStack Router loader에서 병렬 데이터 페칭 |

### 2. 번들 크기 최적화 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `bundle-barrel-imports` | 직접 import, barrel 파일 회피 |
| `bundle-lazy-routes` | 라우트 기반 코드 스플리팅 |
| `bundle-defer-third-party` | 분석/로깅은 hydration 후 로드 |
| `bundle-conditional` | 기능 활성화 시에만 모듈 로드 |
| `bundle-preload` | hover/focus 시 preload로 체감 속도 향상 |

### 3. TanStack Router 라우팅 (HIGH)

| 규칙 | 설명 |
|------|------|
| `routing-file-conventions` | 파일 기반 라우팅 컨벤션 (__root, $param, _layout, lazy) |
| `routing-link-navigation` | Link 컴포넌트와 useNavigate로 타입 안전 네비게이션 |
| `routing-search-params` | useSearch + Zod 스키마로 search params 검증 |
| `routing-path-params` | useParams와 getRouteApi로 타입 안전 path params |
| `routing-beforeload-auth` | beforeLoad로 인증 가드, pathless layout 조합 |
| `routing-nested-layouts` | Outlet과 pathless layout으로 중첩 UI |
| `routing-router-context` | createRootRouteWithContext로 의존성 주입 |
| `routing-preload-strategy` | Link preload="intent"로 즉각적 네비게이션 |
| `routing-pending-component` | pendingComponent로 로딩 상태 (pendingMs/pendingMinMs) |

### 4. 서버 사이드 성능 (HIGH)

| 규칙 | 설명 |
|------|------|
| `server-cache-lru` | LRU 캐시로 요청 간 캐싱 |
| `server-serialization` | loader 데이터 직렬화 최소화 |
| `server-parallel-fetching` | loader에서 병렬 데이터 페칭 |
| `server-deferred-data` | Promise 반환으로 비차단 데이터 로딩 |
| `server-middleware` | createMiddleware()로 인증/로깅 중앙화 |
| `server-validator` | inputValidator()로 타입 안전한 Server Functions |
| `server-streaming` | async generator/ReadableStream으로 데이터 스트리밍 |
| `server-error-boundaries` | 라우트 레벨 errorComponent/notFoundComponent |

### 5. 클라이언트 데이터 페칭 (MEDIUM-HIGH)

| 규칙 | 설명 |
|------|------|
| `client-tanstack-query` | TanStack Query로 자동 캐싱/중복 제거 |
| `client-suspense-query` | useSuspenseQuery로 선언적 데이터 로딩 (v5) |
| `client-optimistic-updates` | useOptimistic으로 즉각적 UI 피드백 (React 19) |
| `client-use-hook` | use() hook으로 Promise 처리 (React 19) |
| `client-event-listeners` | 전역 이벤트 리스너 중복 제거 |

### 6. Re-render 최적화 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `rerender-defer-reads` | 콜백 전용 상태는 구독 안 함 |
| `rerender-memo` | 비싼 작업은 memoized 컴포넌트로 추출 |
| `rerender-react-compiler` | React Compiler로 자동 메모이제이션 (React 19) |
| `rerender-dependencies` | effect에 원시값 의존성 사용 |
| `rerender-derived-state` | 파생 boolean 구독, raw 값 구독 회피 |
| `rerender-functional-setstate` | 안정적 콜백용 함수형 setState |
| `rerender-lazy-state-init` | 비싼 초기값은 함수로 useState에 전달 |
| `rerender-transitions` | 비긴급 업데이트는 startTransition |

### 7. 렌더링 성능 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `rendering-animate-svg-wrapper` | SVG 대신 wrapper div 애니메이션 |
| `rendering-content-visibility` | 긴 리스트는 content-visibility 사용 |
| `rendering-hoist-jsx` | 정적 JSX 컴포넌트 외부로 추출 |
| `rendering-svg-precision` | SVG 좌표 정밀도 감소 |
| `rendering-conditional-render` | 조건부 렌더링은 &&가 아닌 삼항 연산자 |

### 8. JavaScript 성능 (LOW-MEDIUM)

| 규칙 | 설명 |
|------|------|
| `js-batch-dom-css` | CSS 변경은 클래스나 cssText로 그룹화 |
| `js-index-maps` | 반복 조회용 Map 빌드 |
| `js-cache-property-access` | 루프에서 객체 속성 캐싱 |
| `js-cache-function-results` | 함수 결과를 모듈 레벨 Map에 캐싱 |
| `js-cache-storage` | localStorage/sessionStorage 읽기 캐싱 |
| `js-combine-iterations` | 여러 filter/map을 하나의 루프로 결합 |
| `js-length-check-first` | 비싼 비교 전 배열 길이 먼저 체크 |
| `js-early-exit` | 함수에서 조기 반환 |
| `js-hoist-regexp` | RegExp 생성을 루프 밖으로 |
| `js-min-max-loop` | sort 대신 루프로 min/max |
| `js-set-map-lookups` | O(1) 조회용 Set/Map 사용 |
| `js-tosorted-immutable` | 불변성용 toSorted() 사용 |

</rules>

---

<patterns>

## 핵심 패턴

### ✅ Waterfall 제거

```typescript
// ❌ 순차 실행, 3번 왕복
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()

// ✅ 병렬 실행, 1번 왕복
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```

### ✅ TanStack Router Loader + createServerFn

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

// Server Functions 정의
const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

const getComments = createServerFn().handler(async (postId: string) => {
  return await db.comment.findMany({ where: { postId } })
})

// ❌ 순차 로딩
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    const comments = await getComments(params.postId)
    return { post, comments }
  }
})

// ✅ 병렬 로딩
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const [post, comments] = await Promise.all([
      getPost(params.postId),
      getComments(params.postId)
    ])
    return { post, comments }
  }
})
```

### ✅ 번들 최적화

```tsx
// ❌ 전체 라이브러리 import (1583개 모듈, ~2.8초)
import { Check, X, Menu } from 'lucide-react'

// ✅ 직접 import (3개 모듈만)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'
```

### ✅ TanStack Query로 캐싱

```typescript
import { useQuery } from '@tanstack/react-query'

// ❌ 중복 제거 없음, 각 인스턴스가 fetch
function UserList() {
  const [users, setUsers] = useState([])
  useEffect(() => {
    fetch('/api/users')
      .then(r => r.json())
      .then(setUsers)
  }, [])
}

// ✅ 여러 인스턴스가 하나의 요청 공유
function UserList() {
  const { data: users } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers
  })
}
```

### ✅ Re-render 최적화

```tsx
// ❌ items가 의존성, 매번 재생성
const addItems = useCallback((newItems: Item[]) => {
  setItems([...items, ...newItems])
}, [items])

// ✅ 안정적 콜백, 재생성 없음
const addItems = useCallback((newItems: Item[]) => {
  setItems(curr => [...curr, ...newItems])
}, [])
```

</patterns>

---

<tanstack_specific>

## TanStack Start 특화 패턴

### createServerFn으로 Server Functions

```typescript
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

// ✅ 기본 Server Function (GET)
const getUser = createServerFn().handler(async () => {
  // 서버에서만 실행
  return await db.user.findMany()
})

// ✅ POST + Validation (inputValidator는 함수 형태 필수)
const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email()
})

const createUser = createServerFn({ method: 'POST' })
  .inputValidator((d: unknown) => UserSchema.parse(d))
  .handler(async ({ data }) => {
    // data는 자동으로 { name: string; email: string } 타입
    return await db.user.create({ data })
  })
```

### Middleware로 인증 중앙화

```typescript
import { createMiddleware } from '@tanstack/react-start'

const authMiddleware = createMiddleware()
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session?.user) throw redirect({ to: '/login' })
    return next({ context: { user: session.user } })
  })

// 보호된 Server Function
const getMyTodos = createServerFn()
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return await db.todo.findMany({ where: { userId: context.user.id } })
  })
```

### Loader 최적화

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

const getUser = createServerFn().handler(async () => {
  return await db.user.findMany()
})

const getStats = createServerFn().handler(async () => {
  return await db.stats.findMany()
})

// ✅ 병렬 데이터 페칭
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const [user, stats] = await Promise.all([
      getUser(),
      getStats()
    ])
    return { user, stats }
  }
})
```

### Deferred Data (자동 처리)

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

const getComments = createServerFn().handler(async (postId: string) => {
  await new Promise(r => setTimeout(r, 3000)) // 느린 쿼리 시뮬레이션
  return await db.comment.findMany({ where: { postId } })
})

// ✅ 중요 데이터는 await, 비중요 데이터는 Promise 그대로 반환
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // 빠른 데이터는 await
    const post = await getPost(params.postId)

    // 느린 데이터는 Promise 그대로 반환 (자동으로 deferred 처리됨)
    const deferredComments = getComments(params.postId)

    return {
      post,
      deferredComments
    }
  }
})

// 컴포넌트에서 Await로 처리
function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()

  return (
    <div>
      <PostContent post={post} />
      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

### 라우트 기반 코드 스플리팅

```typescript
import { lazy } from 'react'
import { createFileRoute } from '@tanstack/react-router'

// ✅ 무거운 컴포넌트는 lazy load
const HeavyEditor = lazy(() => import('./components/HeavyEditor'))

export const Route = createFileRoute('/editor')({
  component: () => (
    <Suspense fallback={<EditorSkeleton />}>
      <HeavyEditor />
    </Suspense>
  )
})
```

</tanstack_specific>

---

<usage>

## 사용법

**상세 규칙 및 예시:**

```
rules/async-parallel.md
rules/bundle-barrel-imports.md
rules/client-tanstack-query.md
rules/server-deferred-data.md
```

각 규칙 파일 포함 내용:
- 중요한 이유 설명
- ❌ 잘못된 코드 예시 + 설명
- ✅ 올바른 코드 예시 + 설명
- 추가 컨텍스트 및 참조

**전체 컴파일 문서:** `PARALLEL_AGENTS.md`

</usage>

---

<references>

## 참고 자료

### TanStack Start 공식 문서
1. [React 공식 문서](https://react.dev)
2. [TanStack Start Overview](https://tanstack.com/start/latest/docs/framework/react/overview)
3. [TanStack Start Quick Start](https://tanstack.com/start/latest/docs/framework/react/quick-start)
4. [TanStack Query](https://tanstack.com/query/latest/docs/framework/react/overview)
5. [Server Functions Guide](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
6. [Middleware Guide](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)
7. [Streaming Data Guide](https://tanstack.com/start/latest/docs/framework/react/guide/streaming-data-from-server-functions)
8. [Authentication Guide](https://tanstack.com/start/latest/docs/framework/react/guide/authentication)

### TanStack Router
9. [TanStack Router](https://tanstack.com/router)
10. [Navigation Guide](https://tanstack.com/router/latest/docs/framework/react/guide/navigation)
11. [Link Options](https://tanstack.com/router/latest/docs/framework/react/guide/link-options)
12. [Search Params](https://tanstack.com/router/latest/docs/framework/react/guide/search-params)
13. [Path Params](https://tanstack.com/router/latest/docs/framework/react/guide/path-params)
14. [Authenticated Routes](https://tanstack.com/router/latest/docs/framework/react/guide/authenticated-routes)
15. [Outlets](https://tanstack.com/router/latest/docs/framework/react/guide/outlets)
16. [Route Trees](https://tanstack.com/router/latest/docs/framework/react/guide/route-trees)
17. [File-Based Routing](https://tanstack.com/router/latest/docs/framework/react/routing/file-based-routing)
18. [Router Context](https://tanstack.com/router/latest/docs/framework/react/guide/router-context)
19. [Preloading](https://tanstack.com/router/latest/docs/framework/react/guide/preloading)
20. [Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
21. [Deferred Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/deferred-data-loading)

### React 19
22. [React 19 Blog](https://react.dev/blog/2024/12/05/react-19)
23. [React use() API](https://react.dev/reference/react/use)
24. [React useOptimistic](https://react.dev/reference/react/useOptimistic)
25. [React useActionState](https://react.dev/reference/react/useActionState)
26. [React Compiler](https://react.dev/learn/react-compiler)

### 외부 자료
27. [better-all](https://github.com/shuding/better-all)
28. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
29. [Using Server Functions and TanStack Query](https://www.brenelz.com/posts/using-server-functions-and-tanstack-query/)

</references>
