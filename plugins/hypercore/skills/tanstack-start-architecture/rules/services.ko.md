# Server Functions and Service Layer

> Server function API 사용, runtime validation, route/features/services/database layering 규칙.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| client-callable server RPC는 `createServerFn` 사용 | Official | server RPC에 필요 |
| canonical validation API는 `.inputValidator(...)` | Official + Drift note | installed types가 다르지 않으면 `.validator(...)` 차단 |
| mutation input runtime validation | Safety policy | POST/PUT/PATCH validation 없으면 차단 |
| chain에서 handler는 마지막 | Official/API shape | malformed chain 차단 |
| non-trivial logic은 feature/service layer | Hypercore convention | touched non-trivial logic에 적용 |
| `functions/index.ts` barrel 금지 | Hypercore convention + Safety policy | import-protection/tree-shaking ambiguity 방지 |

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

## Layering

```text
Route / hook / query
  -> routes/<page>/-functions/ 또는 functions/ server function
  -> features/<domain>/queries.ts 또는 mutations.ts
  -> database/ ORM client 또는 services/<provider>/ SDK wrapper
```

- **Safety policy:** route는 database/ORM client를 직접 import하지 않습니다.
- **Hypercore convention:** non-trivial business logic은 route file이 아니라 `features/` 또는 `services/`에 둡니다.
- **Hypercore convention:** extraction이 noise라면 simple CRUD는 server function에 남길 수 있습니다.

## Query and Mutation Pattern

- Reads: 안전하고 cache semantic이 맞으면 GET server function 사용.
- Mutations: POST/PUT/PATCH + runtime `inputValidator`.
- Client hook은 보통 `useServerFn`과 TanStack Query로 server function/cache invalidation을 감쌉니다.
- Loader는 React component가 아니므로 server function을 직접 호출할 수 있습니다.

## Validation Checklist

- [ ] 새 mutation server function에 `.inputValidator(...)`가 있음.
- [ ] 새 `.validator(...)` 사용이 없거나 installed package types로 정당화됨.
- [ ] `handler`가 chain 마지막임.
- [ ] auth-required server function이 middleware 또는 equivalent checked boundary를 사용함.
- [ ] route가 ORM/database client에 직접 접근하지 않음.
- [ ] non-trivial logic이 `features/` 또는 `services/`로 분리됨.
- [ ] `functions/index.ts` barrel export를 만들지 않음.
