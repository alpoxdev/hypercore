# Import Protection

> TanStack Start import boundary rules for client/server safety

---

## Why This Rule Exists

TanStack Start builds separate client and server bundles. Import protection prevents:

- server-only code from leaking into the client bundle
- client-only code from leaking into the server bundle
- environment-specific helpers from surviving outside supported compiler boundaries

This protection is built into the TanStack Start Vite plugin and should be treated as a required architecture guardrail, not an optional nicety.

---

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Client-reachable code imports `*.server.*`? | BLOCKED |
| Server-only execution path imports `*.client.*`? | BLOCKED |
| File contains server-only code but no `.server.*` suffix or marker? | BLOCKED. Rename or add marker import |
| File contains client-only code but no `.client.*` suffix or marker? | BLOCKED. Rename or add marker import |
| Same file imports both `@tanstack/react-start/server-only` and `@tanstack/react-start/client-only`? | BLOCKED |
| `vite.config.ts` disables import protection? | BLOCKED unless user explicitly requests it |
| `vite.config.ts` has no explicit `importProtection` config when project rules need directory denies? | FIX IT before proceeding |
| Server-only import survives outside `createServerFn`, `createServerOnlyFn`, or other compiler-recognized boundary? | BLOCKED. Refactor immediately |

---

## Default TanStack Start Behavior

TanStack Start enables import protection by default.

### Client environment denies

- `**/*.server.*`
- `@tanstack/react-start/server`

### Server environment denies

- `**/*.client.*`

### Default behavior

- dev: `mock`
- build: `error`
- repeated logs: `once`

This means dev mode may warn and keep going with mocks, but build mode is the source of truth. If there is any doubt, run a production build.

---

## Required Naming and Markers

Prefer file naming first:

- server-only modules: `*.server.ts`, `*.server.tsx`
- client-only modules: `*.client.ts`, `*.client.tsx`

If renaming is not practical, add an explicit marker import at the top of the file:

```ts
import '@tanstack/react-start/server-only'
```

```ts
import '@tanstack/react-start/client-only'
```

Use markers when the file is environment-bound but the filename cannot clearly express that. Never place both markers in the same file.

---

## Required `vite.config.ts` Enforcement

If the project already has `tanstackStart()` configured, extend `importProtection`; do not overwrite unrelated plugin options.

If `vite.config.ts` does not explicitly configure `importProtection`, add a baseline config like this:

```ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [
    tanstackStart({
      importProtection: {
        behavior: {
          dev: 'mock',
          build: 'error',
        },
        client: {
          files: [
            '**/*.server.*',
            '**/server/**',
            '**/database/**',
            '**/db/**',
          ],
        },
        server: {
          files: ['**/*.client.*', '**/client/**'],
        },
      },
    }),
  ],
})
```

### Enforcement notes

- If `importProtection` is missing, add it.
- If `importProtection` exists, extend the existing `client.files` and `server.files` lists instead of replacing them blindly.
- Never set `enabled: false` unless the user explicitly asks for that tradeoff.
- Keep TanStack defaults intact unless there is a strong reason to narrow or expand them.

---

## Leaky Import Pattern

This is the failure mode to watch for:

```ts
import { getUsers } from './db/queries.server'
import { createServerFn } from '@tanstack/react-start'

export const fetchUsers = createServerFn().handler(async () => {
  return getUsers()
})

export const leakyHelper = () => {
  return getUsers()
}
```

`fetchUsers` is safe because the compiler rewrites the server function boundary. `leakyHelper` is not safe because the server-only import remains live in code that survives for the client build.

### Fix options

1. Split the leaking helper into a dedicated `*.server.*` module.
2. Wrap the helper with `createServerOnlyFn`.
3. Remove the shared import from client-reachable code.

Example:

```ts
import { createServerOnlyFn } from '@tanstack/react-start'
import { getUsers } from './db/queries.server'

export const leakyHelper = createServerOnlyFn(() => {
  return getUsers()
})
```

---

## Review Checklist

Before approving a TanStack Start change, verify:

- No client-reachable module imports `*.server.*`
- No server execution path imports `*.client.*`
- Environment-specific modules use filename suffixes or marker imports
- `vite.config.ts` contains or extends `importProtection` when needed
- No one disabled import protection silently
- Server-only helpers do not escape compiler-recognized boundaries
- Dev-only warnings are confirmed with a real build when the import graph is ambiguous
