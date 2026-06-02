# Testing and RPC

> Protect typed clients and tests from route-shape regressions

---

## Core Rule

- If the app uses `testClient()` or `hc`, preserve route type inference
- Export `AppType` when a typed client or shared contract depends on the app
- In larger apps, keep sub-app composition typed all the way to the exported surface

## Example

```ts
export const app = new Hono()
  .get('/search', (c) => {
    const query = c.req.query('q')
    return c.json({ query })
  })

export type AppType = typeof app
```

## Review Checklist

- Route types still flow through the exported app
- `testClient()` remains useful after refactors
- `hc<typeof app>` or sub-app clients still infer correctly
- Detached registration did not silently erase route typing

