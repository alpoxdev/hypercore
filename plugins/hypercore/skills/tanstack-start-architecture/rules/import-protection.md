# Import Protection

> Enforce Start client/server import boundaries without hiding the fact that Start has defaults.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Start import protection exists and is enabled by default | Official | Verify behavior before custom config |
| `.server.*` denied from client and `.client.*` denied from server | Official | Block leaks |
| Marker imports restrict modules to one environment | Official | Use when suffix is not enough |
| Custom deny rules for `database/`, `server/`, ORM packages | Safety policy | Add/extend when project needs them |
| Never disable import protection silently | Safety policy | Block unless user explicitly requests |

## Official Defaults

TanStack Start import protection is enabled by default. Do not claim an explicit `importProtection` object is always required.

Default-denied patterns include:

- Client environment: `**/*.server.*` and Start server specifiers.
- Server environment: `**/*.client.*`.

Type-only imports and re-exports are ignored because they are erased from the runtime bundle. Mixed imports still count when they include runtime values.

## Marker Imports

```typescript
import '@tanstack/react-start/server-only'
import '@tanstack/react-start/client-only'
```

- Use one marker at most per file.
- Use markers when file names cannot clearly express the environment boundary.

## Custom Deny Rules

Add explicit `tanstackStart({ importProtection })` config when the project needs stronger rules for directories or packages:

```typescript
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [
    tanstackStart({
      importProtection: {
        behavior: { dev: 'mock', build: 'error' },
        client: {
          files: ['**/*.server.*', '**/server/**', '**/database/**', '**/db/**'],
          specifiers: ['@prisma/client', 'bcrypt'],
        },
        server: {
          files: ['**/*.client.*', '**/client/**'],
          specifiers: ['localforage'],
        },
      },
    }),
  ],
})
```

If `tanstackStart()` already exists, extend only the relevant nested options. Do not duplicate plugins or overwrite unrelated options.

Use `behavior: 'error'` when a project wants violations to fail even in development. Current options also include `log`, `include`, `exclude`, `ignoreImporters`, `maxTraceDepth`, and `onViolation` for scoped enforcement and diagnostics.

`client` and `server` rules support `files`, `specifiers`, and `excludeFiles`. The default excludes resolved files under `node_modules`; setting `excludeFiles: []` opts back into those checks for the selected environment and should be deliberate because third-party packages can produce false positives.

## Compiler Boundary Leak Rule

Server-only imports used inside a `createServerFn` handler may be removed from the client build. If the same import is referenced by code that survives client compilation, import protection should flag it.

Fix with one of:

- Split the surviving helper into `*.server.*`.
- Wrap the helper with `createServerOnlyFn`.
- Move browser-only code behind `*.client.*` or `createClientOnlyFn`.
- Put server function wrappers in `*.functions.ts` and split DB/secret/filesystem helpers to sibling `*.server.ts`.
- Do not mix safe exports with server-only exports in `src/modules/<domain>/<feature>/index.ts` or `-functions/index.ts`.

## Server Function Import Shape

Server function wrappers themselves may be statically imported from loaders/components/hooks. A wrapper still leaks if surviving client-build exports reference server-only helpers outside the handler boundary.

Recommended:

```text
src/modules/users/profile/
├── profile.functions.ts  # createServerFn exports
├── profile.server.ts     # DB/secret helper
└── profile.schemas.ts    # client-safe schema
```

Blocked or warned:

- `profile.functions.ts` references `profile.server.ts` from a helper export outside the handler.
- `index.ts` re-exports both `profile.functions.ts` and `profile.server.ts`.
- Client components import `*.server.ts`, `src/db/**`, or privileged SDKs directly.
- Server functions are dynamically imported, obscuring bundler rewrite/import-protection traces.

## Validation Checklist

- [ ] Import protection is not disabled.
- [ ] Custom deny rules are present when project directories/packages require them.
- [ ] Type-only imports are not misreported as runtime boundary leaks.
- [ ] Existing `tanstackStart()` options are extended, not overwritten.
- [ ] `behavior: 'error'` vs `{ dev, build }` behavior is chosen intentionally.
- [ ] `excludeFiles: []` is used only when third-party resolved-file checks are intentionally required.
- [ ] `.server.*`, `.client.*`, and marker imports are used consistently.
- [ ] Server-only imports do not survive outside recognized boundaries.
- [ ] `*.functions.ts` wrappers and `*.server.ts` helpers are split.
- [ ] There are no mixed safe/server-only barrels.
- [ ] Dev warnings are confirmed with production build when tree-shaking might remove false positives.
