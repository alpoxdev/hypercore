# Server Routes

> TanStack Start server route는 공식 HTTP endpoint 기능입니다. hypercore는 실제 HTTP semantics가 있을 때 사용합니다.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| `createFileRoute(... )({ server })`로 정의하는 server route | Official | 허용 |
| simple handlers는 `server.handlers`, composed handlers는 `createHandlers` function 사용 | Official | 현재 handler shape 사용 |
| Route-level middleware는 `server.middleware`로 선언 가능 | Official | 모든 handler가 request behavior를 공유할 때 적용 |
| webhook/file/health/auth/public machine endpoint | Official + Hypercore convention | justification 있으면 허용 |
| duplicate route path + HTTP method handlers | Official | collision 차단 |
| internal app RPC를 server route로 구현 | Hypercore convention | server function 선호 |
| 검증 없는 request body 신뢰 | Safety policy | trust 전 validation |

## Current Server Route Shape

Server routes는 TanStack Router file-route convention을 따릅니다. `createFileRoute(...)(...)`에 `server` property가 있으면 API route가 됩니다.

Simple handlers는 `server.handlers` object를 사용합니다:

```ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/hello')({
  server: {
    handlers: {
      GET: async ({ request }) => {
        return new Response('Hello, World! from ' + request.url)
      },
    },
  },
})
```

Handlers에 middleware composition이 필요하면 current server-routes guide의 `createHandlers` function form을 사용합니다. 동일 route-level middleware가 모든 handlers에 적용되어야 하면 `server.middleware`를 사용합니다.

같은 resolved route path에 duplicate methods를 만들지 않습니다. `users.ts`와 `users.index.ts` 같은 file-route variants는 같은 API route로 resolve될 수 있으며 duplicate HTTP methods는 invalid입니다. wildcard/splat server routes는 `routes/file/$.ts`처럼 trailing `$` convention을 사용합니다.

## Allowed Uses

단순 app-internal RPC가 아니라 HTTP semantics가 있을 때 server route를 사용합니다:

- Third-party webhook.
- Auth provider callback 또는 required auth endpoint.
- Health/readiness endpoint.
- File upload/download 또는 wildcard HTTP handler.
- `robots.txt`, `sitemap.xml`, LLMO/metadata endpoint.
- Public machine-readable resource.

## Prefer Server Functions For

- React component 또는 route loader가 소비하는 app read/mutation.
- End-to-end typing과 server function middleware가 유리한 internal RPC.
- TanStack Query invalidation pattern을 공유해야 하는 operation.

## Validation Checklist

- [ ] 새 server route마다 HTTP justification이 있음.
- [ ] Simple server routes는 `server.handlers` object를 사용하고, composed handlers는 current `createHandlers` function form을 사용함.
- [ ] `server.middleware`는 모든 handler가 공유하는 route-level behavior에만 사용함.
- [ ] Duplicate route path + HTTP method collision을 확인함.
- [ ] Wildcard/splat routes는 필요할 때 trailing `$` file-route convention을 사용함.
- [ ] request body, params, headers, client-sent context를 trust 전에 검증함.
- [ ] user가 HTTP endpoint를 명시 요청하지 않았다면 internal app RPC는 server function을 사용함.
- [ ] 필요한 경우 route/handler level middleware가 적용됨.
