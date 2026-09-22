# Platform Setup: Tauri v2 + Vite + React + TanStack Router + Query

> Use this rule for renderer/bootstrap/configuration review. Read the dated evidence first: [Tauri v2 evidence](../references/official/tauri-v2-2026-07-30.md) and [TanStack + Vite + React evidence](../references/official/tanstack-vite-react-2026-07-30.md). TanStack Start projects are outside this rule’s scope; route them to the full-stack architecture workflow whose deliverable is a server-owned route tree, loader, and SSR data-flow plan.

## Classification

| Rule | Classification | Enforcement |
|---|---|---|
| The TanStack Router Vite plugin precedes the React Vite plugin | Official fact | Correct plugin order before diagnosing route transforms. |
| `tanstackRouter({ target: 'react', autoCodeSplitting: true })` owns file-route transforms and route-tree generation | Official fact | Use it once; do not hand-edit its generated route tree. |
| TanStack Router owns file-based routing; TanStack Query owns asynchronous data cache and freshness | Official fact | Do not claim that Query has a file-routing system. |
| `build.devUrl` and `build.frontendDist` are Tauri v2 configuration keys | Official fact | Match them to real Vite endpoints/output. |
| `VITE_*` values are exposed to renderer code and public assets are publicly shipped | Official fact | Block secrets in either surface. |
| Loopback host, strict dev port, explicit asset-base decision, and a verified build target are the packaged-app default | Hypercore convention + safety policy | Require build evidence and a documented exception for network exposure or a different target/base. |
| Bootstrap has one owner and effects clean up external work | React official fact + Hypercore convention | Correct duplicate mounts, global listeners, and timers. |

“Official fact” records framework behavior documented as of 2026-07-30. “Hypercore convention” is a review default, not a replacement for an existing proven project contract.

## Vite plugin composition

Use the Router Vite plugin before React for file-based routing:

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackRouter } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    tanstackRouter({ target: 'react', autoCodeSplitting: true }),
    react(),
  ],
})
```

- The Router plugin discovers route sources and generates `routeTree.gen.ts`; route files and plugin configuration are human input, while the generated tree is tool output.
- Keep exactly one Router plugin registration. It must precede `react()` so route transforms complete before React processes the modules.
- `target: 'react'` selects the React Router integration. `autoCodeSplitting: true` keeps eligible route components in generated lazy boundaries; provide loading and rendering-error UI where those boundaries are visible.
- TanStack Query is not a route generator. Put one `QueryClient` in typed router context when routes and loaders need shared data access; Query then owns cache and freshness decisions.

## Tauri and Vite must describe the same app

Tauri launches/loads the URL and directory named in its v2 config; Vite must actually serve/build those values.

```json
// src-tauri/tauri.conf.json
{
  "build": {
    "beforeDevCommand": "pnpm dev",
    "devUrl": "http://127.0.0.1:1420",
    "beforeBuildCommand": "pnpm build",
    "frontendDist": "../frontend-build-output"
  }
}
```

```ts
// vite.config.ts
export default defineConfig({
  base: './',
  server: {
    host: '127.0.0.1',
    port: 1420,
    strictPort: true,
  },
  build: {
    outDir: 'frontend-build-output',
    target: 'es2021',
  },
})
```

- **Official fact:** `devUrl` is the frontend URL used for development and `frontendDist` is the packaged frontend directory. Tauri v2 config reference: <https://v2.tauri.app/reference/config/>; Vite guide: <https://v2.tauri.app/start/frontend/vite/>.
- Keep the protocol, hostname, and port in `devUrl` identical to the Vite server’s actual address. Do not point Tauri at a fallback port that Vite silently selected.
- Use a narrow loopback host (`127.0.0.1` or `::1`) and `strictPort: true` by default. Binding `0.0.0.0`, a LAN interface, or a non-loopback development URL requires explicit authority because it exposes the dev server beyond the local machine.
- `frontendDist` must resolve from `src-tauri/tauri.conf.json` to Vite’s actual `build.outDir`. Align the build command and both paths deliberately, then inspect the resolved directory rather than assuming `dist`.
- The shown `base: './'` is an embedded-asset choice, not a universal default. Select the base for the packaged WebView asset origin, then verify entry, lazy-chunk, and non-root route URLs from production output.
- The shown `target: 'es2021'` is a support-policy example, not a browser capability assumption. Retain or choose an explicit target supported by every declared Tauri platform and its oldest supported WebView.

## Build target and output checks

The packaged renderer executes in the target platform’s WebView, not necessarily the browser used for local development.

- **Official fact:** Vite’s `build.target` controls JavaScript/CSS transform targets. Tauri’s Vite guide provides platform-aware target guidance: <https://v2.tauri.app/start/frontend/vite/>; Vite build options: <https://vite.dev/config/build-options>.
- Do not copy an old browser-target example as the current support policy; reconcile the installed Vite version, Tauri target platforms, and oldest supported system WebView.
- After a target/base change, inspect the configured frontend output and referenced assets: URLs resolve from the packaged location, no unsupported syntax is intentionally emitted for a supported WebView, and `frontendDist` contains the entry document. Test packaged navigation for a non-root file route.

## Renderer environment and public-input boundary

| Surface | Rule |
|---|---|
| `import.meta.env.VITE_*` | Renderer-visible, statically replaced at build time; use only non-secret configuration. |
| Other build-time environment variables | Not automatically exposed to renderer code; keep validation/consumption in the appropriate runtime boundary. |
| `public/` | Copied/served as public static input; never place credentials, private keys, internal configuration, or unlicensed sensitive data here. |
| Rust/native configuration | Keep native secrets and privileged configuration out of renderer bundles; expose only a minimal, authorization-checked result through IPC when needed. |

Do not read renderer configuration from `process.env` as a browser fallback. Do not rely on a client-side prefix, obfuscation, or a public asset filename to protect a secret. Vite’s environment and public-directory rules are documented at <https://vite.dev/guide/env-and-mode> and <https://vite.dev/guide/assets>.

## Bootstrap ownership and React lifecycle

- `src/main.tsx` is the single React client entry. It owns `createRoot`, `StrictMode`, the `QueryClientProvider`, and the `RouterProvider`; no route, feature component, or hot-reload helper creates another root.
- Create one `QueryClient` for the app and pass it through both `QueryClientProvider` and typed router context. Route loaders and `beforeLoad` receive context but cannot call React hooks.
- Mount the app once. Keep `StrictMode` enabled in development unless an investigated library incompatibility is documented and isolated. Its development checks reveal impure renders and incomplete effect cleanup.
- Effects that subscribe, listen, start timers, hold object URLs, or begin cancellable async work return cleanup that reverses it. Use the cleanup to unsubscribe, remove listeners, clear timers, revoke URLs, and abort/cancel in-flight work where the API supports it.
- Effects must not be the default place for Tauri initialization with visible side effects; make initialization idempotent and explicitly owned so development re-runs cannot duplicate native subscriptions or writes.

React references: [createRoot](https://react.dev/reference/react-dom/client/createRoot), [StrictMode](https://react.dev/reference/react/StrictMode), and [useEffect cleanup](https://react.dev/reference/react/useEffect).

## Do not carry Tauri v1 configuration forward

Reject or deliberately migrate these common v1 keys rather than leaving them as ignored compatibility debris:

| Tauri v1 key | Tauri v2 direction |
|---|---|
| `build.devPath` | `build.devUrl` |
| `build.distDir` | `build.frontendDist` |
| `tauri.allowlist` | capability manifests plus plugin/core permissions |
| `tauri.security.csp` | `app.security.csp` |
| `tauri.bundle.identifier` | root `identifier` |

These are **official migration facts**; use the v2 configuration schema and migration guide to check the project’s exact configuration rather than applying a blind search-and-replace: <https://v2.tauri.app/start/migrate/from-tauri-1/> and <https://v2.tauri.app/reference/config/>. Permission migration can change native access and requires the authority required by the security rules.

## Review exit criteria

Before accepting platform setup, establish all of the following from configuration and build output:

1. `tanstackRouter({ target: 'react', autoCodeSplitting: true })` precedes `react()` and is the only route-tree generator.
2. `src/routes`, generated `routeTree.gen.ts`, typed router context, and one `src/main.tsx` have clear ownership.
3. Tauri `devUrl` equals the strict, narrow Vite listener and `frontendDist` resolves to Vite’s configured `build.outDir`.
4. The output uses a base that works from packaged static assets and a target justified by supported WebViews.
5. No secret reaches `VITE_*`, `public/`, or renderer source.
6. Query owns async cache/freshness, while Router owns file-based routing; data needed by loaders is available through typed context.
7. No v1 config keys remain unless a documented, completed migration intentionally handles them.

## Sources

> Links checked 2026-07-30.

| Claim | Source |
|---|---|
| `devUrl`, `frontendDist`, the Tauri v1 -> v2 key mapping, and the build-hook configuration keys | [tauri-v2-2026-07-30.md](../references/official/tauri-v2-2026-07-30.md); <https://v2.tauri.app/reference/config/>; <https://v2.tauri.app/start/frontend/vite/>; <https://v2.tauri.app/start/migrate/from-tauri-1/> |
| Router plugin order, `tanstackRouter({ target: 'react', autoCodeSplitting: true })`, and Router-versus-Query ownership | [tanstack-vite-react-2026-07-30.md](../references/official/tanstack-vite-react-2026-07-30.md); <https://tanstack.com/router/latest/docs/framework/react/routing/file-based-routing> |
| `VITE_*` renderer exposure, `build.target`, and the public-directory rule | [tanstack-vite-react-2026-07-30.md](../references/official/tanstack-vite-react-2026-07-30.md); <https://vite.dev/guide/env-and-mode>; <https://vite.dev/config/build-options> |
| One React bootstrap, `StrictMode` development checks, and effect cleanup | [tanstack-vite-react-2026-07-30.md](../references/official/tanstack-vite-react-2026-07-30.md); <https://react.dev/reference/react-dom/client/createRoot>; <https://react.dev/reference/react/useEffect> |
| Loopback host, strict dev port, explicit asset-base/target decisions, and the classification of the "Hypercore convention" rows | This repository's convention and safety policy; no external source |
