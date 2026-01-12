# TanStack Start

> 1.x | Full-stack React Framework

@setup.md
@server-functions.md
@middleware.md
@routing.md
@auth-patterns.md

---

## ⛔ Required Rules

| Forbidden | Use Instead |
|------|------|
| /api routes | Server Functions |
| Manual validation in handler | inputValidator |
| Manual auth in handler | middleware |

✅ POST/PUT/PATCH → inputValidator required
✅ Auth needed → middleware required

---

## Quick Reference

```typescript
// GET + Auth
export const getUsers = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => prisma.user.findMany())

// POST + Validation + Auth
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))

// Route with Loader
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => ({ users: await getUsers() }),
})

// Using Loader data
const UsersPage = (): JSX.Element => {
  const { users } = Route.useLoaderData()
  return <div>{/* render */}</div>
}
```

### Structure

```
routes/
├── __root.tsx          # Root layout
├── index.tsx           # /
├── users/
│   ├── index.tsx       # /users
│   ├── $id.tsx         # /users/:id
│   ├── -components/    # Page-specific
│   └── -functions/     # Page-specific Server Functions

Shared functions → @/functions/
Route-specific → routes/[path]/-functions/
```
