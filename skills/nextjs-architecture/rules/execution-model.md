# Execution Model

> Next.js server and client boundary rules.

---

## Core Rule

Do not guess where code runs.

- Server Components are the default in App Router
- Client Components need `'use client'`
- Client Components also render during prerendering, so they must still obey browser-security assumptions
- Server-only code must stay out of the client environment

## Default Strategy

1. Start with a Server Component
2. Add `'use client'` only for interactivity, browser APIs, or client-side hooks
3. Keep the client boundary as low as possible in the tree
4. Keep privileged reads in server-only modules or a DAL

## Hard Rules

| Check | Rule |
|------|------|
| Interactive code without `'use client'` | BLOCKED |
| High-level layout or root marked `'use client'` without a real need | BLOCKED |
| Client Component imports DB clients, secret env, `cookies()`, `headers()`, or server-only helpers | BLOCKED |
| Broad raw records passed from Server Components to Client Components | BLOCKED |
| Server-only helper lacks `import 'server-only'` or equivalent boundary clarity | WARNING |
| Provider rendered broader than needed | WARNING. Render providers as deep as possible |

## Serializable Props Rule

Props passed from Server Components to Client Components must be serializable and intentionally small.

Prefer:

- DTOs
- small view models
- explicit primitive props

Avoid:

- whole ORM records
- class instances
- secrets
- internal fields the UI does not need

## Provider Placement

Context providers should wrap only the subtree that needs them. This preserves more of the tree for static optimization and keeps client bundles smaller.

## Server-Only Protection

Use `import 'server-only'` for modules that must never run in the client environment:

- DAL modules
- DB access
- secret-bearing SDK wrappers
- authorization helpers that must stay server-side

## Review Checklist

- `'use client'` appears only where needed
- Client Components do not reach server-only modules
- Props crossing the server/client boundary are narrow and serializable
- Providers are placed as deep as practical
