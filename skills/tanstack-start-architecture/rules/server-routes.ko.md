# Server Routes

> TanStack Start server route는 공식 HTTP endpoint 기능입니다. hypercore는 실제 HTTP semantics가 있을 때 사용합니다.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| `createFileRoute(... )({ server })`로 정의하는 server route | Official | 허용 |
| webhook/file/health/auth/public machine endpoint | Official + Hypercore convention | justification 있으면 허용 |
| internal app RPC를 server route로 구현 | Hypercore convention | server function 선호 |
| 검증 없는 request body 신뢰 | Safety policy | trust 전 validation |

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
- [ ] request body, params, headers, client-sent context를 trust 전에 검증함.
- [ ] user가 HTTP endpoint를 명시 요청하지 않았다면 internal app RPC는 server function을 사용함.
- [ ] 필요한 경우 route/handler level middleware가 적용됨.
