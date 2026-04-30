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

## Compiler Boundary Leak Rule

Server-only imports used inside a `createServerFn` handler may be removed from the client build. If the same import is referenced by code that survives client compilation, import protection should flag it.

Fix with one of:

- Split the surviving helper into `*.server.*`.
- Wrap the helper with `createServerOnlyFn`.
- Move browser-only code behind `*.client.*` or `createClientOnlyFn`.

## Validation Checklist

- [ ] Import protection is not disabled.
- [ ] Custom deny rules are present when project directories/packages require them.
- [ ] Existing `tanstackStart()` options are extended, not overwritten.
- [ ] `.server.*`, `.client.*`, and marker imports are used consistently.
- [ ] Server-only imports do not survive outside recognized boundaries.
- [ ] Dev warnings are confirmed with production build when tree-shaking might remove false positives.
