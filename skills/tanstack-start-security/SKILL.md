---
name: tanstack-start-security
description: "[Hyper] Use when working on TanStack Start projects and the task involves auth, sessions, cookies, CSRF, secrets, env exposure, server functions/routes, headers/CSP, webhooks, or security review/fixes. Triggers on protecting routes, hardening auth flows, preventing secret leaks, securing server boundaries, or reviewing HTTP/security behavior in a TanStack Start app."
---

@rules/auth-and-session.md
@rules/server-boundaries.md
@rules/http-and-headers.md
@rules/validation.md
@references/official-security-notes.md

# TanStack Start Security

## Purpose

Harden TanStack Start applications without turning every change into a full security rewrite.

Use this skill when the job is specifically about security posture in a TanStack Start app:

- auth and session protection
- cookies, CSRF, trusted origins, and browser request safety
- request middleware in `src/start.ts`
- server function and server route hardening
- secret and env boundary protection
- SSR, hydration, and client/server execution leaks
- security headers, CSP, webhook verification, and rate limiting

Do not use this skill for generic React work or non-security copy edits.

If the task is mainly TanStack Start architecture compliance rather than security hardening, use `skills/tanstack-start-architecture/` instead of stretching this skill.

If the request is a generic non-TanStack security review, route away to the normal security-review path instead of forcing TanStack Start rules.

## Trigger Examples

### Positive

- `Review TanStack Start login and session handling security.`
- `Prevent secrets from leaking through a TanStack Start server function.`
- `Review auth, cookies, CSRF, and webhook security in this TanStack Start app.`

### Negative

- `Make a small style-only change to a plain React page.`
- `Security review an Express API server that is not a TanStack Start app.`

### Boundary

- `Change only the copy on a TanStack Start page.`
If there is no change to security boundaries, auth, env handling, server routes, or headers, this skill may be too heavy.

## Step 1: Project Validation

Apply this skill only when the repository is actually using TanStack Start signals such as:

- `app.config.ts`
- `@tanstack/react-start` in `package.json`
- `@tanstack/react-router` in `package.json`
- `src/routes/__root.tsx`

If those signals are absent, stop and fall back to the normal implementation or security-review path.

## Step 2: Read The Right Rules

Read these files before editing security-sensitive code:

- `rules/auth-and-session.md` for authentication, authorization, cookies, and request-origin rules
- `rules/server-boundaries.md` for `createServerFn`, `createServerOnlyFn`, env/secrets, and import boundaries
- `rules/http-and-headers.md` for server routes, CSP, headers, CORS, rate limiting, and webhook handling
- `rules/validation.md` for review gates and verification steps

Read `references/official-security-notes.md` when auth stack details, TanStack execution rules, or Better Auth specifics matter.

### Start Here By Prompt Type

- auth, session, cookie, CSRF, `beforeLoad`, and authorization issues: start with `rules/auth-and-session.md`
- secret leaks, env exposure, `loader`, SSR context, hydration leaks, and import-boundary issues: start with `rules/server-boundaries.md`
- `src/start.ts` middleware, CSP, CORS, headers, webhooks, rate limiting, and server routes: start with `rules/http-and-headers.md`
- if the prompt is a copy-only edit or a non-TanStack security request, stop at the core boundary decision and route away instead of reading deeper files

## Step 3: Security Mapping

Before changing code, map which security surface you are touching:

1. Auth/session
2. Secrets/env
3. Request middleware in `src/start.ts`
4. Server functions
5. Server routes / HTTP endpoints
6. Browser-delivered headers and CSP
7. SSR / hydration / import boundary leaks

If more than one surface is affected, validate all linked rule files before editing.

## Step 4: Preferred Fix Order

Use the lightest fix that closes the actual risk:

1. Stop secret or boundary leaks first
2. Add session/authz enforcement next
3. Tighten cookies, origins, and mutation safety
4. Add explicit headers, CSP, webhook checks, and rate limits
5. Only then consider larger auth-stack or route-structure migrations

## Step 5: Auto-Remediation Policy

Auto-fix directly when the change is local, reversible, and clearly safer:

- move privileged logic behind `createServerFn` or `createServerOnlyFn`
- add route/session guard checks
- replace client-exposed secret access with server-only access
- add missing input validation or origin/signature checks
- tighten cookie or header defaults when the current stack is clear

Do not auto-apply broad, risky migrations without explicit justification:

- replacing the auth library
- sweeping session model changes
- site-wide CSP rewrites without checking asset/script requirements
- broad CORS or cookie-domain changes across environments

## Core Security Gates

Block the change until fixed if any of these are true:

- client-reachable code can import or derive a secret
- protected data mutation trusts client-provided identity or role claims
- a TanStack Start `loader` or shared utility performs privileged work without an explicit server boundary
- a route relies on `beforeLoad` only, without equivalent server-side protection for protected actions
- loader output, SSR context, or hydrated state serializes secrets or internal-only auth data
- a server route is accepting browser state-changing input without auth/origin/CSRF strategy
- webhook handlers trust payloads before signature verification
- auth/session cookies are configured loosely without deliberate environment rules

## Verification

Before claiming completion:

- verify the relevant rule-file checklist
- run the project checks that prove the change did not break the app
- summarize what was hardened and what remains stack-dependent

For detailed review and command guidance, use `rules/validation.md`.
