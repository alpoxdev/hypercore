# Data Fetching and Caching

> 서버 우선 읽기, 스트리밍, Cache Components, cache intent, freshness 규칙.

---

## Preferred Read Path

- 가능하면 초기 페이지 데이터는 Server Components에서 가져옵니다.
- 데이터를 쓰는 컴포넌트 가까이에서 읽습니다.
- 독립적인 reads는 병렬화합니다.
- 전체 route를 불필요하게 막지 말고 `loading.tsx` 또는 `<Suspense>`로 스트리밍합니다.
- 반복되는 privileged reads는 server-only helper 또는 DAL에 둡니다.

## Current Runtime Facts

- 현재 App Router docs 기준 `fetch` requests는 기본 cached가 아닙니다.
- `fetch`가 있는 route도 여전히 prerender되고 HTML이 cached될 수 있으므로 dynamic/static intent를 명시해야 합니다.
- `cookies()`, `headers()`, `searchParams`, `params`, `connection()` 및 request-time APIs는 해당 work를 runtime-dependent하게 만듭니다.
- `cacheComponents: true`에서는 uncached runtime data를 `connection()` + `<Suspense>` 같은 dynamic boundary 뒤에 두거나, 안전할 때 `use cache`로 명시적으로 cache해야 합니다.
- 새 request-time dynamic work에는 `unstable_noStore` 대신 `connection()`을 사용합니다. `unstable_noStore`는 legacy code 유지보수 때만 남깁니다.
- 동일 read는 request tree 안에서 memoized될 수 있지만 request memoization은 persistent cache policy가 아닙니다.

## Cache Components and `use cache`

Next.js 16+ 프로젝트에서 Cache Components를 opt in할 때 이 경로를 사용합니다:

1. 명확한 migration 이유가 있을 때만 `next.config.*`에서 `cacheComponents: true`를 활성화합니다.
2. cache 가능한 pages, components, async functions에 `use cache`를 표시합니다.
3. `use cache` input과 return value는 관련 React/Next.js serialization 규칙에 맞게 serializable해야 합니다.
4. normal cached scope 안에서 `cookies()`, `headers()`, `searchParams` 또는 다른 request-time APIs를 읽지 않습니다. 밖에서 읽어 serializable value로 넘깁니다.
5. storage, latency, platform cost를 감수할 가치가 있는 durable shared cache일 때만 `use cache: remote`를 사용합니다.
6. experimental `use cache: private`는 compliance 또는 refactor가 어려운 request API case에만 사용합니다. browser-memory-only이며 기본적으로 production 권장은 아닙니다.
7. lifetime에는 `cacheLife`, invalidation groups에는 `cacheTag`를 사용합니다.

## Cache and Freshness Rules

| 확인 | 규칙 |
|---|---|
| 캐시 동작을 이해하지 못했거나 변경에 문서화되지 않음 | 차단 |
| request-time APIs 때문에 dynamic rendering이 우발적으로 발생 | 차단 |
| `fetch` caching이 pre-Next.js-16 기본값을 가정 | 차단 |
| `cacheComponents`가 켜졌는데 uncached data에 `use cache`, `connection()`, `loading.tsx`, `<Suspense>` 의도가 없음 | 차단 |
| `use cache: remote` 또는 `use cache: private`를 cost, durability, privacy, experimental-risk 정당화 없이 사용 | 차단 |
| 새 code가 `connection()` 대신 `unstable_noStore` 사용 | legacy code 유지보수가 아니면 차단 |
| 반복 privileged logic에 속한 server read가 page code에 직접 존재 | 경고. DAL 또는 server-only helper 권장 |

## Freshness After Mutations

mutation 후 UI에는 명시적 freshness path가 있어야 합니다:

- Server Action read-your-own-writes 시나리오는 `updateTag`
- Server Actions 또는 Route Handlers에서 stale-while-revalidate tag refresh는 `revalidateTag(tag, 'max')`; deprecated single-argument form은 피합니다
- path-based invalidation은 `revalidatePath`
- tag invalidation 없이 current client router를 refresh해야 할 때는 Server Action 안에서 `next/cache`의 `refresh`
- freshness 작업 뒤 redirect, 또는 명확히 설명된 다른 전략

`redirect()`를 사용하면 이후 code가 실행되지 않으므로 필요한 cache invalidation을 먼저 수행합니다.

## Streaming Guidance

사용 기준:

- segment-level loading state는 `loading.tsx`
- 느리거나 dynamic한 subtree 가까이는 `<Suspense>`
- incoming request를 의도적으로 기다리는 subtree는 `connection()`
- promise passing + React `use()`는 구조가 더 명확하고 boundary가 유지될 때만

## Official-First Decision Rule

권장 우선순위:

1. 초기 데이터는 Server Component reads
2. 안전하게 재사용 가능한 data/UI는 `use cache` / `cacheTag` / `cacheLife`
3. privileged reads는 server-only helper 또는 DAL
4. Client-side fetching은 client-driven refresh, polling, browser-only state일 때만

## Review Checklist

- 초기 reads가 진짜 client-only 이유 없이 client로 내려가지 않음
- Cache Components, `fetch`, route prerendering 가정이 current docs와 호환됨
- dynamic rendering triggers가 의도적임
- Suspense 또는 `loading.tsx`가 blocking work 가까이에 있음
- mutation freshness가 명시적임
