# Execution Model

> TanStack Start runtime boundary rules for server, client, and isomorphic code

---

## Core Rule

Do not guess where code runs. In TanStack Start:

- route `loader` is isomorphic by default
- `beforeLoad` and component rendering may run on server, client, or both depending on SSR mode
- browser APIs are not automatically safe in route code
- secrets are never safe in client-reachable code

---

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| `loader` directly reads secrets, DB, filesystem, or privileged SDKs? | BLOCKED. Move to `createServerFn` or `createServerOnlyFn` |
| Client-reachable code reads secret values directly from `process.env`? | BLOCKED |
| Browser-only APIs (`window`, `localStorage`, `document`) used in server-capable code without guard or boundary? | BLOCKED |
| Manual `typeof window` branching used where `createClientOnlyFn` / `createServerOnlyFn` / `createIsomorphicFn` is clearer? | WARNING. Prefer framework primitives |
| Shared utility mixes server-only and client-only logic in one unbounded function? | BLOCKED. Split or use explicit environment function |

---

## Pick The Right Primitive

| Need | Use |
|------|-----|
| Server RPC callable from routes/components | `createServerFn` |
| Server-only helper that must crash on client | `createServerOnlyFn` |
| Client-only helper that must crash on server | `createClientOnlyFn` |
| Same API with different server/client implementations | `createIsomorphicFn` |

---

## Loader Rule

`loader` is not a safe place for secrets by itself.

Wrong:

```ts
export const Route = createFileRoute('/users')({
  loader: () => {
    return fetch(`/api/users?key=${process.env.SECRET_KEY}`)
  },
})
```

Right:

```ts
const getUsersSecurely = createServerFn().handler(async () => {
  return fetch(`/api/users?key=${process.env.SECRET_KEY}`)
})

export const Route = createFileRoute('/users')({
  loader: () => getUsersSecurely(),
})
```

---

## Security Rules

- Secrets, DB clients, filesystem access, and privileged SDKs stay behind `createServerFn` or `createServerOnlyFn`
- Browser APIs stay behind `createClientOnlyFn`, `ClientOnly`, or client-only components/hooks
- If code can be imported by the client, assume it is public unless import protection and execution boundaries prove otherwise

---

## Review Checklist

- No `loader` contains secret or privileged access directly
- Environment-specific helpers use TanStack Start primitives
- Server-only code is not reachable from client code
- Browser-only code is not reachable during server render
