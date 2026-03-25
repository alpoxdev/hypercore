# Data Fetching and Caching

> Server-first reads, streaming, cache intent, and freshness rules.

---

## Preferred Read Path

- Fetch initial page data in Server Components when possible
- Fetch close to the component that needs the data
- Use parallel fetching where independent reads exist
- Stream with `loading.tsx` or `<Suspense>` instead of blocking the whole route unnecessarily

## Important Runtime Facts

- Identical `fetch` requests in a request tree can be memoized by Next.js
- Reading `cookies()`, `headers()`, request-time APIs, or explicitly uncached data can opt a route into dynamic behavior
- A layout that reads uncached runtime data can block same-segment `loading.tsx`; move the read lower or wrap it in a closer `<Suspense>` boundary

## Cache Rules

| Check | Rule |
|------|------|
| Cache behavior is not understood or not documented in the change | BLOCKED |
| Dynamic rendering is triggered accidentally by request-time APIs | BLOCKED |
| Uncached or request-time data is read high in the tree without an intentional boundary | BLOCKED |
| Server read belongs in a repeated privileged pattern but lives directly in page code | WARNING. Prefer DAL or server-only helper |

## Freshness After Mutations

After a mutation, the UI must have an explicit freshness path:

- `revalidatePath`
- `revalidateTag`
- redirect to a route that re-renders fresh data
- another clearly explained strategy

## Streaming Guidance

Use:

- `loading.tsx` for segment-level loading states
- `<Suspense>` for more granular streaming near slow or dynamic subtrees
- promise passing plus React `use()` only when it improves structure and keeps boundaries clear

## Official-First Decision Rule

Prefer:

1. Server Component reads for initial data
2. Server-only helper or DAL for privileged reads
3. Client-side fetching only for client-driven refresh, polling, or browser-only state

## Review Checklist

- Initial reads happen on the server unless there is a real client-only reason
- Dynamic rendering triggers are intentional
- Suspense or `loading.tsx` is placed close enough to the blocking work
- Mutation freshness is explicit
