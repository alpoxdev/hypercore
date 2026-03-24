# Platform Setup

> Vite + TanStack Router project setup rules that architecture reviews should enforce

---

## Vite Plugin Rules

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackRouter } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    tanstackRouter(),
    react(),
  ],
})
```

- Keep `tanstackRouter()` explicit
- Register `tanstackRouter()` before `react()`
- Do not add duplicate router plugins

---

## Generated Files

- `routeTree.gen.ts` is generated output
- Do not hand-edit it
- If routing changes look wrong, fix source routes or router config, then regenerate

---

## Router Setup

- Keep router wiring explicit in `src/router.tsx`
- Root context setup should be discoverable from router/root-route files
- If the repo adds SSR or manual rendering, prefer a fresh router factory instead of a process-global singleton

---

## Route Token And Layout Convention

- TanStack Router supports `route.tsx`, `posts.route.tsx`, and other `routeToken`-based layouts
- Hypercore prefers folder routes with `route.tsx` for shared layout, `beforeLoad`, and shared loader behavior
- If the repo customizes `routeToken` or `indexToken`, keep that config explicit in `tsr.config.json`

---

## Env And Alias Rules

- Public client config must use `import.meta.env.VITE_*`
- Secret values do not belong in client-reachable route code
- Keep path aliases explicit in both Vite config and TypeScript config
- Prefer explicit env typing/runtime validation for non-trivial apps

---

## Review Checklist

- `vite.config.ts` keeps `tanstackRouter()` before `react()`
- `routeTree.gen.ts` is not hand-edited
- Router setup is explicit and not hidden behind ad-hoc globals
- `tsr.config.json`, if present, documents any `routeToken`/`indexToken` customization
- Env and alias setup are explicit
