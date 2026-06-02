# Server Boundaries

> TanStack Start execution-boundary rules for secrets, envs, loaders, and privileged code

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Secret used in client-reachable code? | BLOCKED |
| `loader` performs privileged access directly? | BLOCKED. Put it behind `createServerFn` or `createServerOnlyFn` |
| Server-only helper imported from code that the client can reach? | BLOCKED |
| Browser-only helper imported into server-capable code path? | BLOCKED |
| Request input used without validation in privileged handler? | BLOCKED |

## Execution Primitives

- Use `createServerFn` for server RPC that may be initiated from the client.
- Use `createServerOnlyFn` for helpers that must never execute on the client.
- Use `createClientOnlyFn` for browser-only helpers.
- Use `createIsomorphicFn` only when both environments are truly supported with explicit implementations.
- Avoid dynamic imports for server functions or privileged helpers when they obscure the boundary review.

## Secrets And Env

- Server secrets stay in `process.env` behind server boundaries.
- Public browser config must be explicitly safe to ship to the client.
- Do not rename secrets into a public env prefix just to make code compile.
- Prefer typed env access and runtime validation for required secrets, URLs, and origins.

## Loader Rule

- Treat route `loader` as client-reachable unless a stronger boundary proves otherwise.
- Data loading is fine; privileged work is not.
- If a loader needs privileged data, call a secure server function from the loader instead of placing secret logic in the loader itself.
- Treat loader return data, SSR context, and hydrated state as client-visible unless proven otherwise.

## Import And File Boundaries

- Respect `*.server.*` and `*.client.*` file intent.
- Preserve or extend TanStack Start import protection instead of relying on guesswork.
- Use explicit server-only or client-only markers when file naming alone is not enough.
- If a file mixes public and privileged code, split it.

## Validation

- Validate untrusted input before privileged work.
- Do not scatter manual validation ad hoc through handlers when a typed validator can gate the input earlier.
- Normalize and authorize after validation, before side effects.
- Validate route-controlled input too: `validateSearch`, `params.parse`, and request body parsing all count as security boundaries.

## Review Checklist

- No secret value is reachable from client bundles or client-importable modules
- Loaders and shared utilities do not perform privileged work directly
- Privileged code lives behind explicit TanStack Start server boundaries
- File/import boundaries match actual runtime intent
- Input validation happens before privileged side effects
- Loader output and hydrated state do not serialize secrets or internal-only auth state
