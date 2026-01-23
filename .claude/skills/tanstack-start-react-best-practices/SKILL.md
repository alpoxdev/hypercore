---
name: tanstack-start-react-best-practices
description: TanStack Start와 React 성능 최적화 가이드. React 컴포넌트, TanStack Start 페이지 작성/리뷰/리팩토링 시 최적 성능 패턴 보장. React 컴포넌트, TanStack Router 라우트, 데이터 페칭, 번들 최적화, 성능 개선 작업에 트리거.
license: MIT
metadata:
  author: vercel
  version: "1.0.0"
  adapted_for: tanstack-start
---

# TanStack Start React 베스트 프랙티스

React와 TanStack Start 애플리케이션 성능 최적화 가이드. 7개 카테고리, 38개 규칙 포함. 영향도별 우선순위로 자동 리팩토링과 코드 생성 가이드 제공.

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

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 접두사 |
|---------|---------|--------|--------|
| 1 | Waterfall 제거 | **CRITICAL** | `async-` |
| 2 | 번들 크기 최적화 | **CRITICAL** | `bundle-` |
| 3 | 서버 사이드 성능 | HIGH | `server-` |
| 4 | 클라이언트 데이터 페칭 | MEDIUM-HIGH | `client-` |
| 5 | Re-render 최적화 | MEDIUM | `rerender-` |
| 6 | 렌더링 성능 | MEDIUM | `rendering-` |
| 7 | JavaScript 성능 | LOW-MEDIUM | `js-` |

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

### 3. 서버 사이드 성능 (HIGH)

| 규칙 | 설명 |
|------|------|
| `server-cache-lru` | LRU 캐시로 요청 간 캐싱 |
| `server-serialization` | 클라이언트로 전달 데이터 최소화 |
| `server-parallel-fetching` | loader에서 병렬 데이터 페칭 |
| `server-deferred-data` | defer()로 비차단 데이터 로딩 |

### 4. 클라이언트 데이터 페칭 (MEDIUM-HIGH)

| 규칙 | 설명 |
|------|------|
| `client-tanstack-query` | TanStack Query로 자동 캐싱/중복 제거 |
| `client-event-listeners` | 전역 이벤트 리스너 중복 제거 |

### 5. Re-render 최적화 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `rerender-defer-reads` | 콜백 전용 상태는 구독 안 함 |
| `rerender-memo` | 비싼 작업은 memoized 컴포넌트로 추출 |
| `rerender-dependencies` | effect에 원시값 의존성 사용 |
| `rerender-derived-state` | 파생 boolean 구독, raw 값 구독 회피 |
| `rerender-functional-setstate` | 안정적 콜백용 함수형 setState |
| `rerender-lazy-state-init` | 비싼 초기값은 함수로 useState에 전달 |
| `rerender-transitions` | 비긴급 업데이트는 startTransition |

### 6. 렌더링 성능 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `rendering-animate-svg-wrapper` | SVG 대신 wrapper div 애니메이션 |
| `rendering-content-visibility` | 긴 리스트는 content-visibility 사용 |
| `rendering-hoist-jsx` | 정적 JSX 컴포넌트 외부로 추출 |
| `rendering-svg-precision` | SVG 좌표 정밀도 감소 |
| `rendering-conditional-render` | 조건부 렌더링은 &&가 아닌 삼항 연산자 |

### 7. JavaScript 성능 (LOW-MEDIUM)

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

// ✅ 기본 Server Function
const getUser = createServerFn().handler(async () => {
  // 서버에서만 실행
  return await db.user.findMany()
})

// ✅ POST + Validation
const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email()
})

const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    // data는 완전히 타입 검증됨
    return await db.user.create({ data })
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

### TanStack 공식 문서
1. [React 공식 문서](https://react.dev)
2. [TanStack Start Overview](https://tanstack.com/start/latest/docs/framework/react/overview)
3. [TanStack Start Quick Start](https://tanstack.com/start/latest/docs/framework/react/quick-start)
4. [TanStack Router](https://tanstack.com/router)
5. [TanStack Router Deferred Data Loading](https://tanstack.com/router/v1/docs/framework/react/guide/deferred-data-loading)
6. [TanStack Query](https://tanstack.com/query)
7. [Server Functions Guide](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)

### 외부 자료
8. [better-all](https://github.com/shuding/better-all)
9. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
10. [Using Server Functions and TanStack Query](https://www.brenelz.com/posts/using-server-functions-and-tanstack-query/)

</references>
