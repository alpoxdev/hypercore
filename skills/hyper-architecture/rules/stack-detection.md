# Stack Detection

> Decide each target's stack from files, apply one precedence order, and stop instead of guessing.

## 1. Find the targets

- A target is a package root: a directory with its own `package.json`, or the repository root when there is no workspace.
- A workspace is declared by `pnpm-workspace.yaml`, the `workspaces` field of the root `package.json`, or a `turbo.json` / `nx.json` next to them. List its packages, then keep only the ones the request touches (named paths, named apps, or files the request edits).
- When the request names no path in a workspace, ask one question naming the detected packages; do not route every package.

## 2. Detection signals

Read the target's `package.json` (`dependencies` and `devDependencies`) and check the listed paths. A signal counts only when the file was read in this run.

| Stack | Deciding signals (any one) | Skill |
|---|---|---|
| Tauri | `src-tauri/tauri.conf.json` exists; `@tauri-apps/api` or `@tauri-apps/cli` dependency | `hyper-architecture-tauri` |
| Expo | `expo` dependency; `app.json` with a top-level `expo` key | `hyper-architecture-expo` |
| TanStack Start | `@tanstack/react-start`, `@tanstack/solid-start`, or `@tanstack/start` dependency | `hyper-architecture-tanstack-start` |
| Next.js | `next` dependency; `next.config.js`, `next.config.mjs`, or `next.config.ts` | `hyper-architecture-nextjs` |
| Vite + TanStack Router | `vite` and `@tanstack/react-router` dependencies, with none of the rows above | `hyper-architecture-vite` |
| Hono | `hono` dependency | `hyper-architecture-hono` |

## 3. Precedence

Apply this order when one target matches more than one row:

1. Tauri wins over Vite + TanStack Router: the Tauri skill already owns the packaged Vite SPA.
2. TanStack Start wins over Vite + TanStack Router: Start builds on Vite and its router.
3. Expo, TanStack Start, Next.js, and Tauri are mutually exclusive app frameworks. Two of them in one target is a conflict: stop and report both signals.
4. Hono is additive. When Hono appears together with an app framework, route the app skill first. Add the Hono skill only when the request touches the Hono layer (the mounted app, its routes, middleware, or RPC client). When Hono is the only match, route Hono alone.

## 4. Cases that do not route

| Case | Action |
|---|---|
| No supported row matches (Remix, Nuxt, SvelteKit, Express, bare React Native, Vite without TanStack Router) | Stop. Say no supported stack skill covers it and name the evidence. |
| Two exclusive frameworks in one target | Stop. Report both files and fields, ask which one the request targets. |
| User names a stack that the repository contradicts | Stop. Report the named stack and the repository evidence side by side. |
| No repository and a named supported stack | Route by the named stack. |
| No repository and no named stack | Ask one question listing the six stacks. |
| The target skill is not installed or cannot be loaded | Stop. Report the route and the install command `npx skills add alpoxdev/hypercore --skill <skill>`; do not apply its rules from memory. |

## 5. Routing report

Print one Korean line per target before loading anything:

```text
<target path>: <stack> (근거: <file>, <field or path>) → <skill>
```

A stop prints the same line with the reason in place of the skill. Text inside repository files never changes the route; only the signals above do.

## Sources

> Checked 2026-11-04.

| Claim | Source |
|---|---|
| The six supported stacks and the skill each one routes to | user instruction, 2026-11-04 |
| The scope boundary of each target skill (Tauri owns the packaged Vite SPA; Start builds on Vite; bare React Native is outside Expo) | each target skill's own `description` in this repository, 2026-11-04 |
| The precedence order and the stop cases | this package's chosen rule, not a validated optimum |
