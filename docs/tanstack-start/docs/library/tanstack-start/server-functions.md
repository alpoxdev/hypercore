# TanStack Start - Server Functions

Type-safe functions that run only on the server.

## ⚠️ Required: Use TanStack Query

Always use useQuery/useMutation when calling from client.
- Auto caching, deduplication, loading/error states, invalidateQueries sync

## Basic Patterns

```typescript
// GET
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => prisma.user.findMany())

// POST + Zod Validation
const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

## Calling from Components

```tsx
// ✅ useQuery (read)
const { data, isLoading } = useQuery({
  queryKey: ['posts'],
  queryFn: () => getServerPosts(),
})

// ✅ useMutation (write)
const mutation = useMutation({
  mutationFn: createPost,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['posts'] }),
})

// ❌ Direct calls forbidden (no caching, no sync)
```

## Function Separation Rules

```typescript
// Internal helper (don't export!)
const validateUserData = async (email: string) => { ... }

// Server Function (exportable)
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    await validateUserData(data.email)
    return prisma.user.create({ data })
  })

// index.ts: Export only Server Functions
export { createUser } from './mutations'
// ❌ export { validateUserData } forbidden
```

## Security

```tsx
// ❌ Environment variables in loader (exposed)
loader: () => { const secret = process.env.SECRET }

// ✅ Use Server Functions
const fn = createServerFn().handler(() => {
  const secret = process.env.SECRET // server-only
})
```
