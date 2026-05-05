# Route Handlers

> `route.ts`가 맞는 surface인지, 아닌지 판단하는 규칙.

---

## Use Route Handlers For

- webhooks
- feeds
- CORS-sensitive endpoints
- machine-readable public endpoints
- XML, JSON, streams 같은 non-UI content
- method-level handling, headers, status codes, raw body access가 필요한 HTTP-native integrations

## Do Not Default To Route Handlers For

- Server Actions로 충분한 일반 internal form mutations
- Server Components에서 가능한 internal UI data reads
- Proxy가 맡아야 하는 forwarding behavior

mutation이 app UI에서 시작된다면 Server Action을 먼저 가정하고, 실제 요구가 HTTP semantics일 때만 `route.ts`를 정당화합니다.

## Current Facts

- Route Handlers는 App Router에서 사용할 수 있습니다.
- `route.ts` file은 `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS` 표준 HTTP method exports를 지원합니다.
- Route Handlers는 Web `Request` / `Response` APIs를 사용하며 Next.js helper가 필요할 때 `NextRequest` / `NextResponse`를 사용합니다.
- 현재 App Router examples에서 dynamic segment `params`는 promise-shaped입니다. 사용 전에 await합니다.
- Route Handlers는 route segment config를 공유하지만, `cacheComponents`가 켜진 경우 config behavior를 확인해야 합니다.

## Hard Rules

| 확인 | 규칙 |
|---|---|
| 같은 segment에 `route.ts`와 `page.tsx` 배치 | 차단 |
| UI-only flow에 Route Handler를 default internal RPC로 사용 | HTTP semantics가 필요하지 않으면 차단 |
| Route Handler 안에서 `NextResponse.next()` 사용 | 차단. 해당 behavior는 Proxy 영역 |
| 현재 behavior 확인 없이 오래된 기본값으로 Route Handler caching 가정 | 차단 |
| sitemap, robots, icons, Open Graph images 같은 built-in metadata files를 필요 없이 custom Route Handler로 중복 | 위험도에 따라 경고/차단 |

## Cache and Freshness

- cached Route Handler data는 `revalidate`, `cacheTag`, `revalidateTag`, `generateStaticParams` 또는 다른 명시 전략 중 무엇인지 밝힙니다.
- Cache Components가 켜진 경우 Route Handler prerendering이 target version에서 pages와 같은 model을 따르는지 확인합니다.
- correctness-critical endpoints에서는 문서화되지 않은 `GET` caching defaults에 의존하지 않습니다.

## Decision Rule

선택 순서:

1. server-rendered UI reads는 Server Component
2. internal UI mutations와 forms는 Server Action
3. genuinely HTTP-native surface일 때만 Route Handler
4. pre-route request boundary behavior는 Proxy

## Review Checklist

- endpoint가 실제로 HTTP semantics를 필요로 함
- `page.tsx` conflict 없음
- method exports와 request/response handling이 명시적임
- 현재 caching behavior를 이해하고 문서화함
- Proxy-specific behavior가 Route Handler로 새지 않음
