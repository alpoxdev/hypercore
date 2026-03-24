# Middleware

> Middleware rules for request boundaries and shared concerns

---

## Core Rule

Middleware is where request-wide concerns become explicit: auth, request IDs, CORS, logging, and context enrichment.

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Middleware order assumed incorrectly | BLOCKED |
| Shared request concern duplicated in handlers | WARNING |
| `c.set()` values used without typed `Variables` | BLOCKED |
| Cross-request state assumed via `Context` | BLOCKED |

## Review Checklist

- Registration order is intentional
- Shared concerns are centralized
- Context variables are typed
- Middleware does not become a hidden business-logic layer

