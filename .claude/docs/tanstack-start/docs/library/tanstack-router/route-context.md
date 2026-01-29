# TanStack Router - Route Context

<patterns>

```tsx
// beforeLoad: auth check + add context
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }
    return { userPermissions: await fetchPermissions(context.auth.user.id) }
  },
  loader: async ({ context }) => fetchDashboardData(context.userPermissions),
  component: DashboardPage,
})

// Protected Routes: _authed.tsx (pathless layout)
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ location }) => {
    const user = await getCurrentUser()
    if (!user) throw redirect({ to: '/login', search: { redirect: location.href } })
    return { user }
  },
  component: () => <Outlet />,
})

// _authed/dashboard.tsx
export const Route = createFileRoute('/_authed/dashboard')({
  component: DashboardPage,
})
const DashboardPage = () => {
  const { user } = Route.useRouteContext()  // Context from _authed
  return <h1>Welcome, {user.name}!</h1>
}

// Root Context
interface RouterContext {
  queryClient: QueryClient
  auth: { isAuthenticated: boolean; user: User | null }
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootLayout,
})

const router = createRouter({
  routeTree,
  context: { queryClient, auth: { isAuthenticated: false, user: null } },
})

// redirect
throw redirect({ to: '/login' })
throw redirect({ to: '/login', search: { redirect: '/dashboard' } })
throw redirect({ to: '/posts/$postId', params: { postId: '123' } })
throw redirect({ to: '/home', replace: true })
```

</patterns>

<structure>

```
routes/
├── _authed.tsx           # Protected layout
├── _authed/
│   ├── dashboard.tsx     # /dashboard (protected)
│   ├── settings.tsx      # /settings (protected)
│   └── profile.tsx       # /profile (protected)
├── login.tsx             # /login (public)
└── index.tsx             # / (public)
```

</structure>

<usage>

| Location | Access Method |
|------|----------|
| beforeLoad | `{ context }` parameter |
| loader | `{ context }` parameter |
| component | `Route.useRouteContext()` |

</usage>
