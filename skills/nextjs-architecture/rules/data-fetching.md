# Data Fetching and Caching

> Server-first reads, streaming, Cache Components, cache intent, and freshness rules.

---

## Preferred Read Path

- Fetch initial page data in Server Components when possible.
- Fetch close to the component that needs the data.
- Use parallel fetching for independent reads.
- Stream with `loading.tsx` or `<Suspense>` instead of blocking the whole route unnecessarily.
- Keep privileged reads in a server-only helper or DAL when the pattern repeats.

## Current Runtime Facts

- In current App Router docs, `fetch` requests are not cached by default.
- A route containing `fetch` can still be prerendered and have its HTML cached, so dynamic/static intent must be explicit.
- `cookies()`, `headers()`, `connection()`, and other request-time APIs make the affected work runtime-dependent.
- With `cacheComponents: true`, uncached runtime data must be isolated behind a dynamic boundary such as `connection()` plus `<Suspense>`, or explicitly cached with `use cache` where safe.
- Identical reads may be memoized in a request tree, but request memoization is not a persistence/cache policy.

## Cache Components and `use cache`

Use this path in Next.js 16+ projects that opt into Cache Components:

1. Enable `cacheComponents: true` in `next.config.*` only with an explicit migration reason.
2. Mark cacheable pages, components, or async functions with `use cache`.
3. Keep `use cache` inputs and return values serializable according to the relevant React/Next.js serialization rules.
4. Do not read `cookies()` or `headers()` inside a cached scope; read them outside and pass serializable values as arguments, or use a documented private/remote cache variant only when justified.
5. Use `cacheLife` for lifetime and `cacheTag` for invalidation groups.

## Cache and Freshness Rules

| Check | Rule |
|---|---|
| Cache behavior is not understood or not documented in the change | BLOCKED |
| Dynamic rendering is triggered accidentally by request-time APIs | BLOCKED |
| `fetch` caching assumes pre-Next.js-16 defaults | BLOCKED |
| `cacheComponents` is enabled but uncached data lacks `use cache`, `connection()`, `loading.tsx`, or `<Suspense>` intent | BLOCKED |
| Server read belongs in repeated privileged logic but lives directly in page code | WARNING. Prefer DAL or server-only helper |

## Freshness After Mutations

After a mutation, the UI must have an explicit freshness path:

- `updateTag` for Server Action read-your-own-writes scenarios
- `revalidateTag(tag, 'max')` for stale-while-revalidate tag refresh from Server Actions or Route Handlers
- `revalidatePath` for path-based invalidation
- `refresh` from `next/cache` in a Server Action when the current client router should refresh without tag invalidation
- redirect after freshness work, or another clearly explained strategy

If `redirect()` is used, perform needed cache invalidation first because code after `redirect()` will not run.

## Streaming Guidance

Use:

- `loading.tsx` for segment-level loading states
- `<Suspense>` for granular streaming near slow or dynamic subtrees
- `connection()` when a subtree intentionally waits for an incoming request
- promise passing plus React `use()` only when it improves structure and keeps boundaries clear

## Official-First Decision Rule

Prefer:

1. Server Component reads for initial data
2. `use cache` / `cacheTag` / `cacheLife` when data or UI can be safely reused
3. server-only helper or DAL for privileged reads
4. Client-side fetching only for client-driven refresh, polling, or browser-only state

## Review Checklist

- Initial reads happen on the server unless there is a real client-only reason
- Cache Components, `fetch`, and route prerendering assumptions are current-docs compatible
- Dynamic rendering triggers are intentional
- Suspense or `loading.tsx` is placed close enough to blocking work
- Mutation freshness is explicit
