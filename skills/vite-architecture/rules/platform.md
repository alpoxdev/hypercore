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
    // tanstackRouter() MUST come before react()
    tanstackRouter({
      target: 'react',
      autoCodeSplitting: true,
    }),
    react(),
  ],
})
```

- Keep `tanstackRouter()` explicit and pass `target: 'react'`
- Enable `autoCodeSplitting: true` so the plugin code-splits route components
- Register `tanstackRouter()` before `react()` (incorrect ordering fails silently)
- Do not add duplicate router plugins
- File-convention options that must stay consistent with hypercore folders: `routeFileIgnorePrefix` defaults to `'-'` (this is what excludes `-components/` and `-hooks/` from the route tree); customize `routeToken` / `indexToken` only if the repo declares them in `tsr.config.json`

---

## Generated Files

- `routeTree.gen.ts` is generated output
- Do not hand-edit it
- If routing changes look wrong, fix source routes or router config, then regenerate

If the repo declares `tsr.config.json`, keep the canonical keys explicit so the plugin and CLI agree:

```json
{
  "routesDirectory": "./src/routes",
  "generatedRouteTree": "./src/routeTree.gen.ts"
}
```

Only add `routeToken`, `indexToken`, `routeFilePrefix`, or `routeFileIgnorePrefix` when the repo really customizes them — otherwise rely on the documented defaults.

---

## Router Setup

- Keep router wiring explicit in `src/router.tsx`
- Root context setup should be discoverable from router/root-route files
- If the repo adds SSR or manual rendering, prefer a fresh per-request router factory instead of a process-global singleton (a module-level QueryClient leaks data across SSR requests)
- Cite the standard `createRouter` options: `defaultPreload: 'intent'`, `defaultPreloadStaleTime: 0`, `scrollRestoration: true`, and use `Wrap` to mount `QueryClientProvider`

```tsx
// src/router.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

export const createAppRouter = () => {
  // Fresh QueryClient per request — prevents SSR data leaks
  const queryClient = new QueryClient()

  return createRouter({
    routeTree,
    context: { queryClient },
    defaultPreload: 'intent',
    defaultPreloadStaleTime: 0,
    scrollRestoration: true,
    Wrap: ({ children }) => (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    ),
  })
}

declare module '@tanstack/react-router' {
  interface Register {
    router: ReturnType<typeof createAppRouter>
  }
}
```

- Root route uses the factory pattern with `createRootRouteWithContext<{ queryClient: QueryClient }>()` so the context type is preserved through nested routes
- For SSR streaming with TanStack Query, wire `setupRouterSsrQueryIntegration({ router, queryClient })` from `@tanstack/react-router-ssr-query` inside the same factory

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
