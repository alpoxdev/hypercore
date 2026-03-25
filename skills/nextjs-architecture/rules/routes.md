# Routes and File Conventions

> Official App Router structure, special files, and segment rules.

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
|------|---------|
| `page.tsx` | UI entry for a route segment |
| `layout.tsx` | Shared UI shell for the segment and children |
| `template.tsx` | A layout-like wrapper that remounts on navigation |
| `loading.tsx` | Suspense fallback for the segment |
| `error.tsx` | Segment-level error boundary. Must be a Client Component |
| `not-found.tsx` | Segment-level 404 UI |
| `route.ts` | HTTP-native route handler |

## Non-Routable Organization

| Pattern | Meaning |
|---------|---------|
| `(marketing)` | Route group. Organizes files without affecting the URL |
| `_components/` | Private folder. Safe for colocated route internals |
| `_lib/` | Private folder for segment-local helpers |

Use private folders for colocated implementation files that must not become route segments.

## Hard Rules

| Check | Rule |
|------|------|
| `route.ts` and `page.tsx` in the same route segment | BLOCKED |
| App Router feature work added under `pages/` when `app/` already owns that surface | BLOCKED unless explicitly requested |
| Route groups used as if they change the URL | BLOCKED |
| User-facing loading or error state needed but boundary files omitted everywhere | WARNING |
| Internal route helpers exposed as route segments instead of private folders | BLOCKED |

## Placement Guidance

- Keep page UI in `page.tsx`
- Keep segment-shared UI in `layout.tsx`
- Put route-specific helper modules in `_` private folders
- Use `route.ts` only when the route responds with HTTP semantics instead of page UI
- Use route groups when organization matters but the pathname must stay unchanged

## Error and Loading Boundaries

- `error.tsx` must be a Client Component
- `loading.tsx` is best for segment-level streaming fallbacks
- If the blocking work is deep inside the tree, prefer a closer `<Suspense>` boundary instead of pushing all fallback responsibility to the segment root
- Use `notFound()` with `not-found.tsx` for missing resource flows

## Mixed Router Repos

- Do not force `page.tsx`/`layout.tsx` conventions onto untouched `pages/` routes
- Do not add new `pages/api/*` endpoints when the same feature now belongs naturally in App Router `route.ts` or a Server Action, unless legacy compatibility is required

## Review Checklist

- Special files are in valid route segments
- No `route.ts` / `page.tsx` conflict exists
- Route groups and private folders are used intentionally
- Loading, error, and not-found boundaries are present where the UX needs them
