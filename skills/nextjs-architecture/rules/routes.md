# Routes and File Conventions

> Official App Router structure, special files, segments, route groups, and private organization.

---

## Core Structure

```text
app/
├── layout.tsx
├── page.tsx
├── dashboard/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── loading.tsx
│   ├── error.tsx
│   ├── not-found.tsx
│   ├── _components/
│   └── _lib/
└── api/
    └── webhooks/
        └── route.ts
```

## Segment File Meaning

| File | Purpose |
|---|---|
| `page.tsx` | UI entry for a route segment; required to make that route publicly accessible |
| `layout.tsx` | Shared UI shell for the segment and children |
| `template.tsx` | Layout-like wrapper that remounts on navigation |
| `loading.tsx` | Suspense fallback for the segment |
| `error.tsx` | Segment-level error boundary; must be a Client Component |
| `not-found.tsx` | Segment-level 404 UI |
| `forbidden.tsx` / `unauthorized.tsx` | Auth interruption UI when the project intentionally enables that feature |
| `route.ts` | HTTP-native Route Handler |

## Non-Routable Organization

| Pattern | Meaning |
|---|---|
| `(marketing)` | Route group; organizes files without affecting the URL |
| `_components/` | Private folder; safe for colocated route internals |
| `_lib/` | Private folder for segment-local helpers |
| `@slot` | Parallel route slot passed to the parent layout |
| `(.)`, `(..)`, `(...)` | Intercepting route patterns for modal/overlay style navigation |

Use private folders for colocated implementation files that must not become route segments.

## Hard Rules

| Check | Rule |
|---|---|
| `route.ts` and `page.tsx` in the same route segment | BLOCKED |
| App Router feature work added under `pages/` when `app/` already owns that surface | BLOCKED unless explicitly requested |
| Route groups used as if they change the URL | BLOCKED |
| Internal route helpers exposed as route segments instead of private folders | BLOCKED |
| Parallel routes added without parent layout slot props and default/fallback behavior | BLOCKED |
| Intercepted routes added without hard-navigation fallback behavior | WARNING/BLOCKED by risk |

## Placement Guidance

- Keep page UI in `page.tsx`.
- Keep segment-shared UI in `layout.tsx`.
- Put route-specific helper modules in `_` private folders.
- Use `route.ts` only when the route responds with HTTP semantics instead of page UI.
- Use route groups when organization matters but the pathname must stay unchanged.
- Use metadata file conventions (`sitemap`, `robots`, icons, Open Graph images) before custom handlers when they fit.

## Error and Loading Boundaries

- `error.tsx` must be a Client Component.
- `loading.tsx` is best for segment-level streaming fallbacks.
- If the blocking work is deep inside the tree, prefer a closer `<Suspense>` boundary instead of pushing all fallback responsibility to the segment root.
- Use `notFound()` with `not-found.tsx` for missing resource flows.

## Mixed Router Repos

- Do not force `page.tsx` / `layout.tsx` conventions onto untouched `pages/` routes.
- Do not add new `pages/api/*` endpoints when the same feature belongs naturally in App Router `route.ts` or a Server Action, unless legacy compatibility is required.

## Review Checklist

- Special files are in valid route segments.
- No `route.ts` / `page.tsx` conflict exists.
- Route groups and private folders are used intentionally.
- Parallel/intercepted route patterns have the required layout and navigation behavior.
- Loading, error, not-found, and auth interruption boundaries are present where the UX needs them.
