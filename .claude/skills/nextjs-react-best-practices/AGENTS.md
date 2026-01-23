# Next.js React 베스트 프랙티스

**Version 1.0.0**
Vercel Engineering
January 2026

> **참고:**
> 이 문서는 주로 에이전트와 LLM이 React 및 Next.js 코드베이스를 유지보수, 생성, 리팩토링할 때 따르기 위한 것입니다. 사람도 유용하게 사용할 수 있지만, AI 지원 워크플로의 자동화 및 일관성을 위해 최적화되어 있습니다.

---

## 요약

AI 에이전트와 LLM을 위한 React 및 Next.js 애플리케이션 종합 성능 최적화 가이드. 8개 카테고리에 걸쳐 40개 이상의 규칙을 포함하며, 영향도별로 우선순위를 매겼습니다 (critical: waterfall 제거, 번들 크기 감소 → incremental: 고급 패턴). 각 규칙은 자동 리팩토링 및 코드 생성을 위한 상세한 설명, 올바른 구현 대 잘못된 구현을 비교하는 실제 예시, 구체적인 영향 지표를 포함합니다.

---

<instructions>

## 문서 사용 지침

@rules/async-defer-await.md
@rules/async-parallel.md
@rules/async-dependencies.md
@rules/async-api-routes.md
@rules/async-suspense-boundaries.md
@rules/bundle-barrel-imports.md
@rules/bundle-conditional.md
@rules/bundle-defer-third-party.md
@rules/bundle-dynamic-imports.md
@rules/bundle-preload.md
@rules/server-cache-react.md
@rules/server-cache-lru.md
@rules/server-serialization.md
@rules/server-parallel-fetching.md
@rules/server-after-nonblocking.md
@rules/client-event-listeners.md
@rules/client-swr-dedup.md
@rules/rerender-defer-reads.md
@rules/rerender-memo.md
@rules/rerender-dependencies.md
@rules/rerender-derived-state.md
@rules/rerender-functional-setstate.md
@rules/rerender-lazy-state-init.md
@rules/rerender-transitions.md
@rules/rendering-animate-svg-wrapper.md
@rules/rendering-content-visibility.md
@rules/rendering-hoist-jsx.md
@rules/rendering-svg-precision.md
@rules/rendering-hydration-no-flicker.md
@rules/rendering-activity.md
@rules/rendering-conditional-render.md
@rules/js-batch-dom-css.md
@rules/js-index-maps.md
@rules/js-cache-property-access.md
@rules/js-cache-function-results.md
@rules/js-cache-storage.md
@rules/js-combine-iterations.md
@rules/js-length-check-first.md
@rules/js-early-exit.md
@rules/js-hoist-regexp.md
@rules/js-min-max-loop.md
@rules/js-set-map-lookups.md
@rules/js-tosorted-immutable.md
@rules/advanced-event-handler-refs.md
@rules/advanced-use-latest.md

</instructions>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 설명 |
|---------|---------|--------|------|
| 1 | Waterfall 제거 | **CRITICAL** | 순차 await를 병렬로 전환. 가장 큰 성능 향상 제공 |
| 2 | 번들 크기 최적화 | **CRITICAL** | TTI와 LCP 개선. 초기 로딩 속도 향상 |
| 3 | 서버 사이드 성능 | HIGH | 서버 사이드 waterfall 제거, 응답 시간 단축 |
| 4 | 클라이언트 데이터 페칭 | MEDIUM-HIGH | 자동 중복 제거, 효율적 데이터 페칭 |
| 5 | Re-render 최적화 | MEDIUM | 불필요한 re-render 최소화, UI 반응성 향상 |
| 6 | 렌더링 성능 | MEDIUM | 브라우저 렌더링 작업 최적화 |
| 7 | JavaScript 성능 | LOW-MEDIUM | Hot path 마이크로 최적화 |
| 8 | 고급 패턴 | LOW | 특정 케이스용 고급 구현 패턴 |

</categories>

---

<critical_patterns>

## 1. Waterfall 제거 (CRITICAL)

Waterfall은 가장 큰 성능 저해 요소입니다. 순차 await는 전체 네트워크 지연을 추가합니다.

### 병렬 실행

```typescript
// ❌ 순차 실행 (3번 왕복)
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()

// ✅ 병렬 실행 (1번 왕복)
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```

### 의존성 기반 병렬화

```typescript
// ❌ profile이 config을 불필요하게 대기
const [user, config] = await Promise.all([
  fetchUser(),
  fetchConfig()
])
const profile = await fetchProfile(user.id)

// ✅ better-all로 최대 병렬화
import { all } from 'better-all'

const { user, config, profile } = await all({
  async user() { return fetchUser() },
  async config() { return fetchConfig() },
  async profile() {
    return fetchProfile((await this.$.user).id)
  }
})
```

### Suspense 경계

```tsx
// ❌ 전체 레이아웃이 데이터 대기
async function Page() {
  const data = await fetchData()
  return (
    <div>
      <Sidebar />
      <Header />
      <DataDisplay data={data} />
      <Footer />
    </div>
  )
}

// ✅ 래퍼는 즉시 표시, 데이터는 스트리밍
function Page() {
  return (
    <div>
      <Sidebar />
      <Header />
      <Suspense fallback={<Skeleton />}>
        <DataDisplay />
      </Suspense>
      <Footer />
    </div>
  )
}

async function DataDisplay() {
  const data = await fetchData()
  return <div>{data.content}</div>
}
```

</critical_patterns>

---

<bundle_optimization>

## 2. 번들 크기 최적화 (CRITICAL)

### Barrel Import 회피

```tsx
// ❌ 전체 라이브러리 import (1583개 모듈, ~2.8초)
import { Check, X, Menu } from 'lucide-react'

// ✅ 직접 import (3개 모듈만)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'

// ✅ Next.js 13.5+ 자동 최적화
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@mui/material']
  }
}
```

영향 받는 라이브러리: `lucide-react`, `@mui/material`, `@mui/icons-material`, `@tabler/icons-react`, `react-icons`, `@headlessui/react`, `@radix-ui/react-*`, `lodash`, `ramda`, `date-fns`, `rxjs`, `react-use`

### Dynamic Import

```tsx
// ❌ Monaco가 메인 청크에 포함 (~300KB)
import { MonacoEditor } from './monaco-editor'

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}

// ✅ Monaco는 필요시 로드
import dynamic from 'next/dynamic'

const MonacoEditor = dynamic(
  () => import('./monaco-editor').then(m => m.MonacoEditor),
  { ssr: false }
)

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}
```

</bundle_optimization>

---

<server_performance>

## 3. 서버 사이드 성능 (HIGH)

### React.cache() - 요청별 중복 제거

```typescript
import { cache } from 'react'

export const getCurrentUser = cache(async () => {
  const session = await auth()
  if (!session?.user?.id) return null
  return await db.user.findUnique({ where: { id: session.user.id } })
})

// 단일 요청 내에서 여러 번 호출해도 쿼리는 1번만 실행
```

### LRU 캐시 - 요청 간 캐싱

```typescript
import { LRUCache } from 'lru-cache'

const cache = new LRUCache<string, any>({
  max: 1000,
  ttl: 5 * 60 * 1000  // 5분
})

export async function getUser(id: string) {
  const cached = cache.get(id)
  if (cached) return cached

  const user = await db.user.findUnique({ where: { id } })
  cache.set(id, user)
  return user
}

// 요청 1: DB 쿼리, 결과 캐싱
// 요청 2: 캐시 히트, DB 쿼리 없음
```

### RSC 경계에서 직렬화 최소화

```tsx
// ❌ 50개 필드 모두 직렬화
async function Page() {
  const user = await fetchUser()  // 50개 필드
  return <Profile user={user} />
}

'use client'
function Profile({ user }: { user: User }) {
  return <div>{user.name}</div>  // 1개 필드만 사용
}

// ✅ 1개 필드만 직렬화
async function Page() {
  const user = await fetchUser()
  return <Profile name={user.name} />
}

'use client'
function Profile({ name }: { name: string }) {
  return <div>{name}</div>
}
```

### after()로 비차단 작업

```tsx
import { after } from 'next/server'

export async function POST(request: Request) {
  await updateDatabase(request)

  // 응답 전송 후 로깅
  after(async () => {
    const userAgent = (await headers()).get('user-agent') || 'unknown'
    logUserAction({ userAgent })
  })

  return new Response(JSON.stringify({ status: 'success' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
```

</server_performance>

---

<client_data_fetching>

## 4. 클라이언트 데이터 페칭 (MEDIUM-HIGH)

### SWR로 자동 중복 제거

```tsx
import useSWR from 'swr'

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
  const { data: users } = useSWR('/api/users', fetcher)
}
```

</client_data_fetching>

---

<rerender_optimization>

## 5. Re-render 최적화 (MEDIUM)

### 함수형 setState

```tsx
// ❌ items가 의존성, 매번 재생성
function TodoList() {
  const [items, setItems] = useState(initialItems)

  const addItems = useCallback((newItems: Item[]) => {
    setItems([...items, ...newItems])
  }, [items])  // items 변경마다 재생성
}

// ✅ 안정적 콜백, 재생성 없음
function TodoList() {
  const [items, setItems] = useState(initialItems)

  const addItems = useCallback((newItems: Item[]) => {
    setItems(curr => [...curr, ...newItems])
  }, [])  // 의존성 없음, 항상 최신 상태 사용
}
```

### Lazy 상태 초기화

```tsx
// ❌ 매 렌더마다 실행
function FilteredList({ items }: { items: Item[] }) {
  const [searchIndex, setSearchIndex] = useState(buildSearchIndex(items))
  const [query, setQuery] = useState('')
}

// ✅ 초기 렌더 시에만 실행
function FilteredList({ items }: { items: Item[] }) {
  const [searchIndex, setSearchIndex] = useState(() => buildSearchIndex(items))
  const [query, setQuery] = useState('')
}
```

### 파생 상태 구독

```tsx
// ❌ 픽셀 변경마다 re-render
function Sidebar() {
  const width = useWindowWidth()  // 연속 업데이트
  const isMobile = width < 768
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}

// ✅ boolean 변경 시에만 re-render
function Sidebar() {
  const isMobile = useMediaQuery('(max-width: 767px)')
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}
```

</rerender_optimization>

---

<rendering_performance>

## 6. 렌더링 성능 (MEDIUM)

### SVG 래퍼 애니메이션

```tsx
// ❌ SVG 직접 애니메이션 - 하드웨어 가속 없음
function LoadingSpinner() {
  return (
    <svg className="animate-spin" width="24" height="24">
      <circle cx="12" cy="12" r="10" />
    </svg>
  )
}

// ✅ 래퍼 div 애니메이션 - 하드웨어 가속
function LoadingSpinner() {
  return (
    <div className="animate-spin">
      <svg width="24" height="24">
        <circle cx="12" cy="12" r="10" />
      </svg>
    </div>
  )
}
```

### content-visibility

```css
/* 긴 리스트 최적화 */
.message-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 80px;
}
```

```tsx
function MessageList({ messages }: { messages: Message[] }) {
  return (
    <div className="overflow-y-auto h-screen">
      {messages.map(msg => (
        <div key={msg.id} className="message-item">
          <Avatar user={msg.author} />
          <div>{msg.content}</div>
        </div>
      ))}
    </div>
  )
}
```

1000개 메시지 기준, 브라우저가 ~990개 오프스크린 항목의 레이아웃/페인트 스킵 (초기 렌더 10배 빠름)

### Hydration 불일치 방지

```tsx
// ❌ SSR 실패
function ThemeWrapper({ children }: { children: ReactNode }) {
  const theme = localStorage.getItem('theme') || 'light'  // localStorage는 서버에서 undefined
  return <div className={theme}>{children}</div>
}

// ❌ 깜빡임
function ThemeWrapper({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState('light')

  useEffect(() => {
    const stored = localStorage.getItem('theme')
    if (stored) setTheme(stored)  // hydration 후 실행 → 깜빡임
  }, [])

  return <div className={theme}>{children}</div>
}

// ✅ 깜빡임 없음, hydration 불일치 없음
function ThemeWrapper({ children }: { children: ReactNode }) {
  return (
    <>
      <div id="theme-wrapper">{children}</div>
      <script
        dangerouslySetInnerHTML={{
          __html: `
            (function() {
              try {
                var theme = localStorage.getItem('theme') || 'light';
                var el = document.getElementById('theme-wrapper');
                if (el) el.className = theme;
              } catch (e) {}
            })();
          `,
        }}
      />
    </>
  )
}
```

</rendering_performance>

---

<javascript_performance>

## 7. JavaScript 성능 (LOW-MEDIUM)

### 반복 조회용 Map

```typescript
// ❌ O(n) per lookup
function processOrders(orders: Order[], users: User[]) {
  return orders.map(order => ({
    ...order,
    user: users.find(u => u.id === order.userId)
  }))
}

// ✅ O(1) per lookup
function processOrders(orders: Order[], users: User[]) {
  const userById = new Map(users.map(u => [u.id, u]))
  return orders.map(order => ({
    ...order,
    user: userById.get(order.userId)
  }))
}
```

1000 orders × 1000 users: 1M ops → 2K ops

### 배열 비교 시 길이 체크

```typescript
// ❌ 항상 비싼 비교 실행
function hasChanges(current: string[], original: string[]) {
  return current.sort().join() !== original.sort().join()
}

// ✅ O(1) 길이 체크 먼저
function hasChanges(current: string[], original: string[]) {
  if (current.length !== original.length) return true

  const currentSorted = current.toSorted()
  const originalSorted = original.toSorted()
  for (let i = 0; i < currentSorted.length; i++) {
    if (currentSorted[i] !== originalSorted[i]) return true
  }
  return false
}
```

### toSorted()로 불변성 유지

```typescript
// ❌ 원본 배열 변경
function UserList({ users }: { users: User[] }) {
  const sorted = useMemo(
    () => users.sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
}

// ✅ 새 배열 생성
function UserList({ users }: { users: User[] }) {
  const sorted = useMemo(
    () => users.toSorted((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
}
```

</javascript_performance>

---

<advanced_patterns>

## 8. 고급 패턴 (LOW)

### useLatest로 안정적 콜백

```typescript
function useLatest<T>(value: T) {
  const ref = useRef(value)
  useEffect(() => {
    ref.current = value
  }, [value])
  return ref
}
```

```tsx
// ❌ effect가 콜백 변경마다 재실행
function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('')

  useEffect(() => {
    const timeout = setTimeout(() => onSearch(query), 300)
    return () => clearTimeout(timeout)
  }, [query, onSearch])
}

// ✅ 안정적 effect, 최신 콜백
function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('')
  const onSearchRef = useLatest(onSearch)

  useEffect(() => {
    const timeout = setTimeout(() => onSearchRef.current(query), 300)
    return () => clearTimeout(timeout)
  }, [query])
}
```

</advanced_patterns>

---

<references>

## 참고 자료

1. [React](https://react.dev)
2. [Next.js](https://nextjs.org)
3. [SWR](https://swr.vercel.app)
4. [better-all](https://github.com/shuding/better-all)
5. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
6. [Next.js Package Import 최적화](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
7. [Vercel Dashboard 2배 빠르게](https://vercel.com/blog/how-we-made-the-vercel-dashboard-twice-as-fast)

</references>
