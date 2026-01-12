# TanStack Start - Auth Patterns

<patterns>

```typescript
// Login
export const loginFn = createServerFn({ method: 'POST' })
  .inputValidator((data: { email: string; password: string }) => data)
  .handler(async ({ data }) => {
    const user = await authenticateUser(data.email, data.password)
    if (!user) return { error: 'Invalid credentials' }
    const session = await useAppSession()
    await session.update({ userId: user.id, email: user.email })
    throw redirect({ to: '/dashboard' })
  })

// Logout
export const logoutFn = createServerFn({ method: 'POST' })
  .handler(async () => {
    const session = await useAppSession()
    await session.clear()
    throw redirect({ to: '/' })
  })

// Get current user
export const getCurrentUserFn = createServerFn({ method: 'GET' })
  .handler(async () => {
    const session = await useAppSession()
    if (!session.data.userId) return null
    return getUserById(session.data.userId)
  })

// Auth middleware
export const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await useAppSession()
    if (!session.data.userId) throw redirect({ to: '/login' })
    const user = await getUserById(session.data.userId)
    return next({ context: { user } })
  })

// Apply to Server Function
export const protectedFn = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => ({ user: context.user }))

// Protected route
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async () => {
    const user = await getCurrentUserFn()
    if (!user) throw redirect({ to: '/login' })
    return { user }
  },
  component: () => {
    const { user } = Route.useRouteContext()
    return <h1>Welcome, {user.name}!</h1>
  },
})

// Better Auth integration
export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: { enabled: true },
})

export const getSession = createServerFn({ method: 'GET' })
  .handler(async ({ request }) => auth.api.getSession({ headers: request.headers }))
```

</patterns>
