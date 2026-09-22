# Errors and Responses

> Centralize HTTP failure handling and preserve response intent

---
## Stable Hono 4.13 Baseline

`app.notFound()` runs only on the top-level app. A child route's `onError` handler takes priority over a parent handler. `HTTPException.getResponse()` does not know headers already accumulated on `Context`.

- Define one public error envelope and map expected domain failures deliberately to literal HTTP statuses.
- Never expose stack traces, SQL, provider payloads, secrets, or raw validation internals.
- Preserve required CORS, request ID, cache, and authentication headers when replacing an error response.
- RPC does not infer global middleware or `onError()` responses automatically; use `ApplyGlobalResponse` when the client contract includes a shared global response.
- Do not use `c.notFound()` as the only typed 404 contract for an RPC route; return a route-local typed JSON variant when the client must infer it.
- Test thrown `HTTPException`, unknown error, route-local error handler precedence, top-level 404, and required headers.

## Core Rule

- Expected HTTP failures should use `HTTPException` or one explicit translation layer
- Non-trivial apps should define `app.onError()`
- Preserve context-set headers when rebuilding an error response

## Example

```ts
import { HTTPException } from 'hono/http-exception'

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    const response = err.getResponse()
    c.res.headers.forEach((value, key) => {
      response.headers.set(key, value)
    })
    return response
  }

  return c.json({ message: 'Internal Server Error' }, 500)
})
```

## Review Checklist

- Central error translation exists when needed
- Error responses preserve deliberate headers/status
- Expected HTTP errors are not all generic throws
- Typed RPC/public-client 404 behavior is covered by `app.notFound()` or an explicit JSON response contract when clients depend on it

## Sources

> No external sources were used in this file. Official Hono behavior is delegated to `references/official/hono-docs.md` (last verified 2026-08-04). Repository-local links checked 2026-09-21.
