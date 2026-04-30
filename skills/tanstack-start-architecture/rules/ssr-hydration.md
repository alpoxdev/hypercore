# SSR And Hydration

> Route SSR mode and hydration-safety rules

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Route SSR options and `ClientOnly` are official Start concepts | Official | Use deliberately |
| Deterministic first render | Safety policy | Block hydration-unsafe output |
| Prefer stabilization before disabling SSR | Hypercore convention | Apply to touched routes |

---

## Core Rule

If server HTML and client render can differ, treat it as a design problem, not a harmless warning.

---

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Component renders unstable values on first render (`Date.now()`, random IDs, locale-dependent text, viewport-only branching)? | BLOCKED unless stabilized |
| Browser-only widget rendered during SSR without `ClientOnly` or SSR restriction? | BLOCKED |
| Route uses `ssr: false` or `ssr: 'data-only'` without a deliberate fallback strategy? | BLOCKED |
| Root disables SSR without understanding `shellComponent` behavior? | BLOCKED |

---

## Preferred Fix Order

1. Make server and client output deterministic
2. Compute once on the server and hydrate from loader data
3. Use `ClientOnly` for genuinely browser-only UI
4. Use route `ssr: 'data-only'` or `ssr: false` only when needed

---

## Approved Patterns

- Locale/timezone-sensitive UI should use a deterministic server value, typically cookie-backed
- Client environment discovery may set cookies after hydration for future SSR requests
- Unstable widgets may be wrapped in `ClientOnly`
- Use `pendingComponent` when SSR mode changes route rendering behavior
- If the root route limits SSR, understand that `shellComponent` still renders the HTML shell

---

## Review Checklist

- No hydration-unsafe first render output
- `ClientOnly` is used intentionally, not as a blanket escape hatch
- `ssr` mode is explicit for unstable routes
- Fallback and shell behavior are understood for reduced SSR routes
