# Server Actions

> `use server` rules for mutations, validation, freshness, and security.

---

## Core Rule

Treat every Server Action as a reachable POST entry point.

For App Router mutations that originate from app UI, Server Actions are the default surface.

This means:

- validate input
- authenticate the caller
- authorize resource access
- return only what the UI needs
- refresh or revalidate affected data intentionally

Do not rely on page-level UI gating alone.

## Placement

- Use a dedicated top-level `'use server'` file for reusable actions, especially actions imported into Client Components.
- Inline actions inside a Server Component are acceptable when tightly bound to that route and the closure is intentional.
- Repeated DB/auth logic should move into a server-only DAL or helper.
- If the write comes from internal app UI and does not need an HTTP-native contract, prefer a Server Action over `route.ts`.

## Forms and Client Calls

- Forms can invoke Server Actions with the `action` attribute and receive `FormData`.
- Use server-side validation for authoritative checks; client validation is only a UX aid.
- Use `useActionState`, pending state, optimistic updates, or transitions only in a narrow Client Component wrapper when the UI needs them.

## Freshness APIs

- Use `updateTag` inside Server Actions for read-your-own-writes cache expiration.
- Use `revalidateTag(tag, 'max')` when stale-while-revalidate behavior is acceptable.
- Use `revalidatePath` for path-based invalidation.
- Use `refresh` from `next/cache` in a Server Action to refresh the current client router without tag invalidation.
- Call required invalidation before `redirect()`.

## Hard Rules

| Check | Rule |
|---|---|
| Action trusts `FormData`, params, headers, or search params directly | BLOCKED |
| Action relies only on page-level auth redirect/gating | BLOCKED |
| Action returns raw DB records or internal objects | BLOCKED |
| Action mutates during render instead of through a form/event/transition path | BLOCKED |
| Action performs repeated domain authorization logic inline everywhere | WARNING. Move it into a DAL |
| `redirect()` used before required `updateTag`, `revalidatePath`, or `revalidateTag` | BLOCKED |

## DAL Guidance

Prefer this split:

- Action: input edge, auth re-check, mutation orchestration, freshness, redirect
- DAL/server-only module: DB access, authorization logic, DTO shaping, sensitive business rules

## Security Notes

- Read auth from cookies or headers, not from trusted client-supplied tokens passed into the action.
- Server Action return values are serialized back to the client, so keep them minimal.
- For expensive actions, consider rate limiting and abuse controls.
- In multi-proxy or reverse-proxy setups, verify whether `serverActions.allowedOrigins` is required.

## Review Checklist

- Input validation exists
- Auth and authz are re-checked inside the action or delegated server-only layer
- Return values are minimized
- Freshness happens before redirect when needed
- Repeated domain logic is not duplicated across many actions
