# Errors and Responses

> Centralize HTTP failure handling and preserve response intent

---

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
