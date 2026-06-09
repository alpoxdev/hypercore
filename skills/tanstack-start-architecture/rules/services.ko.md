# Server Functions and Domain Modules

> Server function API 사용, runtime validation, route/modules/lib/database layering 규칙.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| client-callable server RPC는 `createServerFn` 사용 | Official | server RPC에 필요 |
| canonical validation API는 `.inputValidator(...)` | Official + Drift note | installed types가 다르지 않으면 `.validator(...)` 차단 |
| mutation input runtime validation | Safety policy | POST/PUT/PATCH validation 없으면 차단 |
| chain에서 handler는 마지막 | Official/API shape | malformed chain 차단 |
| non-trivial logic은 domain module/lib layer | Hypercore convention | touched non-trivial logic에 적용 |
| server function wrapper와 server-only helper 분리 | Official + Safety policy | `.functions.ts`와 `.server.ts` 역할 분리 |
| `functions/index.ts` barrel 금지 | Hypercore convention + Safety policy | import-protection/tree-shaking ambiguity 방지 |
| server functions는 same-origin app RPC | Official + Safety policy | public/cross-origin HTTP endpoint는 server route 사용 |

`.inputValidator()`와 stale `.validator()` 예시는 `references/official/api-drift-notes.md`를 봅니다.

## Canonical Server Function Pattern

```typescript
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .middleware([authMiddleware])
  .handler(async ({ data, context }) => {
    return createUserMutation({ data, user: context.user })
  })
```

Notes:

- 현재 canonical guide에서 `inputValidator`는 Zod schema를 직접 받을 수 있습니다.
- middleware와 input validation 순서는 바뀔 수 있지만 `handler`는 chain 마지막입니다.
- project-local installed version이 다르면 typecheck로 확인하고 예외를 기록합니다.
- Server function은 app same-origin RPC입니다. public API, webhook, cross-origin endpoint, raw HTTP semantics가 필요하면 `rules/server-routes.ko.md`에 따라 server route를 사용합니다.

## Server Function File Organization

TanStack Start 공식 guidance는 큰 앱에서 server function wrapper와 server-only helper를 분리합니다. Hypercore는 이 패턴을 route-local `-functions/` exception과 shared `src/modules/<domain>/<feature>/` nested folder에 적용합니다.

Route-local exception 예시:

```text
src/routes/billing/
├── route.tsx
├── index.tsx
├── -hooks/
│   └── use-invoices.ts
└── -functions/
    ├── invoices.functions.ts
    ├── invoices.server.ts
    └── invoices.schemas.ts
```

Default domain module 예시:

```text
src/modules/billing/invoices/
├── invoices.functions.ts
├── invoices.server.ts
├── invoices.schemas.ts
├── invoices-query-keys.ts
├── hooks/
└── components/
```

역할:

| File | Import 가능 위치 | 허용 내용 |
|---|---|---|
| `*.functions.ts` | loader, component, hook, 다른 server function에서 static import | `createServerFn` wrapper, middleware/inputValidator/handler chain |
| `*.server.ts` | `*.functions.ts` handler 내부 또는 server-only module | DB, secrets, filesystem, privileged SDK, internal business logic |
| `*.schemas.ts` / `schemas.ts` | client/server 모두 | Zod schemas, serializable DTOs, constants |
| `*-query-keys.ts` | client/server 모두 | TanStack Query key builders, cache tags |

규칙:

- server function은 dynamic import하지 않습니다. Client bundle rewrite와 import protection 추적을 위해 direct static import를 사용합니다.
- `*.functions.ts`는 server-only helper를 handler 밖 surviving export에서 참조하지 않습니다.
- safe exports와 `.server.ts` exports를 같은 `index.ts` barrel에서 re-export하지 않습니다.
- route-local `-functions/`가 cross-route reuse, domain noun, cache/auth/permission 책임을 얻으면 `src/modules/<domain>/<feature>/`로 승격합니다.
- shared domain code는 domain/feature 단위 nested folder를 사용합니다. `src/modules/foo.ts` direct leaf를 새로 만들지 않습니다.
- external provider client는 domain module에 섞지 않고 `src/integrations/<provider>/` 또는 server-only module로 분리합니다.

## Layering

```text
Route / hook / query
  -> routes/<page>/-functions/<resource>.functions.ts
     또는 src/modules/<domain>/<feature>/<resource>.functions.ts
  -> src/modules/<domain>/<feature>/<resource>.server.ts
  -> src/lib/<domain>/shared helpers, src/db/<domain>/repositories,
     또는 src/integrations/<provider>/server-only clients
  -> database/ORM client 또는 external SDK
```

- **Safety policy:** route는 database/ORM client를 직접 import하지 않습니다.
- **Safety policy:** `*.server.ts` 또는 DB/repository imports는 client-reachable file에 살아남지 않게 합니다.
- **Hypercore convention:** non-trivial business logic은 route file이 아니라 `modules/<domain>/<feature>/` 또는 domain-specific `lib/<domain>/` folders에 둡니다.
- **Hypercore convention:** extraction이 noise라면 simple CRUD는 server function에 남길 수 있습니다.

## Query and Mutation Pattern

- Reads: 안전하고 cache semantic이 맞으면 GET server function 사용.
- Mutations: POST/PUT/PATCH + runtime `inputValidator`.
- Client hook은 보통 `useServerFn`과 TanStack Query로 server function/cache invalidation을 감쌉니다.
- Loader는 React component가 아니므로 server function을 직접 호출할 수 있습니다.
- Auth-required server function은 route `beforeLoad`만 믿지 않습니다. Server function 자체에 middleware 또는 handler-level auth check를 둡니다.
- Custom `src/start.ts`를 정의했다면 server function CSRF request middleware가 유지되는지 확인합니다.
- User/session/tenant에 의존하는 GET server function은 public cache header를 쓰지 않습니다. 응답 cache policy는 identity dependency를 기준으로 정합니다.

## Validation Checklist

- [ ] 새 mutation server function에 `.inputValidator(...)`가 있음.
- [ ] 새 `.validator(...)` 사용이 없거나 installed package types로 정당화됨.
- [ ] `handler`가 chain 마지막임.
- [ ] auth-required server function이 middleware 또는 equivalent checked boundary를 사용함.
- [ ] `*.functions.ts`와 `*.server.ts`가 분리되어 있고 server-only import가 recognized boundary 밖에 살아남지 않음.
- [ ] server functions가 direct static import되며 dynamic import나 mixed barrel을 통하지 않음.
- [ ] public/cross-origin/raw HTTP endpoint는 server function이 아니라 server route로 구현됨.
- [ ] custom `src/start.ts`가 있으면 server function CSRF middleware를 보존함.
- [ ] route가 ORM/database client에 직접 접근하지 않음.
- [ ] non-trivial logic이 `modules/<domain>/<feature>/` 또는 domain-specific `lib/<domain>/` folders로 분리됨.
- [ ] `functions/index.ts` barrel export를 만들지 않음.
