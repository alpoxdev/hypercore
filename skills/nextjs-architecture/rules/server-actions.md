# Server Actions

> `use server` rules for mutations, validation, and security.

---

## Core Rule

Treat every Server Action as a reachable POST entry point.

For App Router mutations that originate from app UI, Server Actions are the default surface.

This means:

- validate input
- authenticate the caller
- authorize the resource access
- return only what the UI needs

Do not rely on page-level UI gating alone.

## Placement

- Dedicated `"use server"` files are preferred for reusable actions
- Inline actions inside a Server Component are acceptable when the action is tightly bound to that route and the closure is intentional
- Repeated DB and auth logic should move into a server-only DAL or helper
- If the write comes from internal app UI and does not need an HTTP-native contract, prefer a Server Action over `route.ts`

## Hard Rules

| Check | Rule |
|------|------|
| Action trusts `FormData`, params, headers, or search params directly | BLOCKED |
| Action relies only on page-level auth redirect/gating | BLOCKED |
| Action returns raw DB records or internal objects | BLOCKED |
| Action mutates during render instead of through a form/event path | BLOCKED |
| Action performs repeated domain authorization logic inline everywhere | WARNING. Move it into a DAL |
| `redirect()` used before required `revalidatePath()` or `revalidateTag()` | BLOCKED |

## DAL Guidance

Prefer this split:

- Action: input edge, auth re-check, mutation orchestration, revalidation, redirect
- DAL/server-only module: DB access, authorization logic, DTO shaping, sensitive business rules

## Security Notes

- Read auth from cookies or headers, not from trusted client-supplied tokens passed into the action
- Server Action return values are serialized back to the client, so keep them minimal
- For expensive actions, consider rate limiting
- In multi-proxy or reverse-proxy setups, verify whether `serverActions.allowedOrigins` is required

## Render Side-Effect Rule

Never trigger mutation side effects during rendering. Use explicit forms, actions, or client event paths.

## Review Checklist

- Input validation exists
- Auth and authz are re-checked inside the action or delegated server-only layer
- Return values are minimized
- Revalidation happens before redirect when needed
- Repeated domain logic is not duplicated across many actions
