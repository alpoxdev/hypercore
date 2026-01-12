# Hono RPC Client

> Type-safe API calls

<patterns>

## Server Setup

```typescript
// server.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()
  .get('/hello', (c) => c.json({ message: 'Hello!' }))
  .get('/users/:id', (c) => {
    const id = c.req.param('id')
    return c.json({ id, name: 'John' })
  })
  .post('/users',
    zValidator('json', z.object({ name: z.string(), email: z.email() })),
    (c) => {
      const data = c.req.valid('json')
      return c.json({ id: '1', ...data }, 201)
    }
  )

export type AppType = typeof app  // ✅ Required
export default app
```

## Client

```typescript
// client.ts
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:8787/')

// GET
const res = await client.hello.$get()
const data = await res.json() // { message: string }

// Path Parameter
const res = await client.users[':id'].$get({ param: { id: '123' } })
const data = await res.json() // { id: string, name: string }

// POST
const res = await client.users.$post({
  json: { name: 'John', email: 'john@example.com' },
})

// Query
const res = await client.search.$get({
  query: { q: 'hono', page: '1' },
})

// Form
const res = await client.posts.$post({
  form: { title: 'Hello', body: 'World' },
})

// Headers
const res = await client.posts.$post(
  { json: { title: 'Test' } },
  { headers: { 'X-Custom': 'value' } }
)

// Config
const client = hc<AppType>('http://localhost:8787/', {
  headers: { Authorization: 'Bearer TOKEN' },
  init: { credentials: 'include' },
})
```

## Type Inference

```typescript
import type { InferRequestType, InferResponseType } from 'hono/client'

type CreateUserInput = InferRequestType<typeof client.users.$post>['json']
// { name: string; email: string }

type UserResponse = InferResponseType<typeof client.users[':id'].$get>
// { id: string; name: string }
```

## CRUD Wrapper

```typescript
const userApi = {
  list: async () => {
    const res = await client.users.$get()
    return res.json()
  },

  get: async (id: string) => {
    const res = await client.users[':id'].$get({ param: { id } })
    return res.json()
  },

  create: async (data: CreateUserInput) => {
    const res = await client.users.$post({ json: data })
    return res.json()
  },

  update: async (id: string, data: Partial<CreateUserInput>) => {
    const res = await client.users[':id'].$put({ param: { id }, json: data })
    return res.json()
  },

  delete: async (id: string) => {
    const res = await client.users[':id'].$delete({ param: { id } })
    return res.json()
  },
}

// URL generation
const url = client.posts[':id'].$url({ param: { id: '123' } })
console.log(url.pathname) // /posts/123
```

</patterns>
