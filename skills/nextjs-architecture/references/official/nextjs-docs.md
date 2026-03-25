# Official Next.js Docs Map

> Canonical doc surfaces this skill was built from. Re-check these when behavior drifts or a rule becomes ambiguous.

## Core Sources

- Project Structure
  URL: `https://nextjs.org/docs/app/getting-started/project-structure`
  Use for: App Router file conventions, route groups, private folders, colocated files

- Server and Client Components
  URL: `https://nextjs.org/docs/app/getting-started/server-and-client-components`
  Use for: `'use client'`, provider placement, server/client composition, bundle boundary decisions

- Fetching Data
  URL: `https://nextjs.org/docs/app/getting-started/fetching-data`
  Use for: server-first data fetching, streaming, Suspense, request memoization basics

- Caching
  URL: `https://nextjs.org/docs/app/getting-started/caching`
  Use for: cache intent, dynamic vs cached behavior, and freshness decisions

- Updating Data
  URL: `https://nextjs.org/docs/app/getting-started/updating-data`
  Use for: Server Action mutation flow, revalidation, redirect ordering, and server roundtrip updates

- Forms
  URL: `https://nextjs.org/docs/app/guides/forms`
  Use for: form handling with Server Actions, validation patterns, and action-level auth/authz reminders

- Error Handling
  URL: `https://nextjs.org/docs/app/getting-started/error-handling`
  Use for: expected errors, `error.tsx`, `notFound()`, nested boundaries

- `use server`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-server`
  Use for: Server Action placement, auth/authz expectations, minimal return values

- Route Handlers
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/route`
  Use for: `route.ts`, method-based HTTP handling, segment config, non-UI responses

- Proxy
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/proxy`
  Use for: `proxy.ts`, matcher placement, pre-render request handling, middleware rename

- Environment Variables
  URL: `https://nextjs.org/docs/app/guides/environment-variables`
  Use for: `.env*` loading, `NEXT_PUBLIC_`, runtime vs build-time env behavior, `@next/env`

- Redirecting
  URL: `https://nextjs.org/docs/app/guides/redirecting`
  Use for: mutation redirects, `revalidatePath` / `revalidateTag` ordering, and pre-render redirect strategy

- Data Security
  URL: `https://nextjs.org/docs/app/guides/data-security`
  Use for: DAL guidance, `server-only`, Server Action security, auth/authz inside actions, return-value minimization

## Interpretation Rules

- Prefer the latest official docs over stale community habits.
- If a newer Next.js release changes caching, Proxy, or Server Action behavior, update the relevant rule file rather than bloating `SKILL.md`.
- When local repo conventions exceed the docs, label them as local conventions in reviews and change reports.
