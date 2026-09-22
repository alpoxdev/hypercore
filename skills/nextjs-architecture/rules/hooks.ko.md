# Client Hooks and Orchestration Boundaries

> server, data, privileged runtime layers를 넘지 않는 client orchestration을 위한 Next.js hook guidance입니다.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Hooks는 Client Components 또는 client modules에서만 실행됨 | React/Next.js fact | client entry point에 `'use client'`를 추가하거나 좁힘 |
| Client hooks는 server-only code를 import할 수 없음 | Safety policy | DB, private env, `cookies()`, `headers()`, DAL, provider secret imports 차단 |
| Hooks는 UI state와 client-side effects를 orchestrate함 | Hypercore local convention | touched interactive UI에 적용 |
| Server reads/writes는 Server Components 또는 Server Actions를 우선함 | Official + safety policy | privileged data를 hook으로 우회하지 않음 |

## Boundary Rule

훅은 client orchestration boundary이지 server/data layer가 아닙니다. hook은 UI state, browser APIs, optimistic UI, transitions, client cache libraries, Server Actions 호출을 조율할 수 있습니다. database access, Drizzle queries, private env, cookies/headers reads, provider SDK secrets, authorization decisions를 소유하면 안 됩니다.

기본 flow:

```text
Client Component
  -> useFeatureHook()
  -> Server Action or client-safe query/cache call
  -> server-only service/DAL
  -> DB or integration
```

초기 page data는 Server Components를 우선하고 serializable minimal props를 client leaf로 넘깁니다. client hooks는 hydration 후 interaction이나 진짜 browser-only data에 사용합니다.

## Placement

repository의 기존 convention을 먼저 따릅니다. 흔한 Hypercore local shapes:

```text
src/app/dashboard/_hooks/use-dashboard-filters.ts
src/modules/billing/invoices/hooks/use-invoice-selection.ts
src/components/data-table/use-column-visibility.ts
```

하나의 App Router segment에만 쓰이는 segment-local hooks는 그 segment의 `_hooks/` 아래에 둘 수 있습니다. cross-route hooks는 domain module 또는 shared component folder에 둡니다.

## Hook Responsibilities

좋은 hook responsibilities:

- UI state, reducers, refs, browser events
- form pending/error state와 optimistic client state
- `useActionState`, transitions, Server Action invocation state
- project가 client cache library를 쓸 때 client cache invalidation wrappers
- 이미 safe한 DTO에서 파생된 view state

server-side에 남아야 하는 responsibilities:

- Drizzle queries, repository calls, transactions, schema migration concerns
- protected data 또는 mutations에 대한 auth/authz decisions
- private env reads, `cookies()`, `headers()`, filesystem, server-only provider clients
- security-sensitive output을 위한 raw DB row shaping
- public HTTP contracts에 대한 Route Handler 또는 Server Action 대체

## Internal Order

touched non-trivial hooks는 일관된 순서를 선호합니다:

```typescript
export const useInvoices = (): UseInvoicesReturn => {
  // 1. Local state and refs
  // 2. Context/global client stores
  // 3. Server Action state or client cache bindings
  // 4. Handlers and callbacks
  // 5. Memoized derived view data
  // 6. Effects
  // 7. Return object
}
```

## Review Checklist

- [ ] Hook file은 필요한 경우에만 client-reachable이고 broad root-level `'use client'`를 강제하지 않음.
- [ ] Hook이 DB client, Drizzle schema, private env, `server-only`, `cookies()`, `headers()`, privileged provider client를 import하지 않음.
- [ ] browser-only reason 없이 initial Server Component data를 client-side에서 다시 fetch하지 않음.
- [ ] Server Action calls는 여전히 server-side에서 validate/authorize됨. hook-level checks는 UX aid일 뿐임.
- [ ] Hook은 internal records가 아니라 client-safe DTO/view state를 반환함.
- [ ] segment-local hooks는 `_hooks/`에 있고 cross-route hooks는 shared domain/component folder로 이동함.

## Sources

> 이 파일에는 외부 출처를 사용하지 않았습니다. 공식 Next.js 동작은 `references/official/nextjs-docs.md`(last verified 2026-05-24)와 `references/official/current-docs-2026-06-02.md`(스냅샷 날짜 2026-06-02)에 위임합니다. 저장소 로컬 링크 확인 2026-09-21.
