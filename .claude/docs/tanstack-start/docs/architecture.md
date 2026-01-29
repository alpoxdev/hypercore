# Architecture

> TanStack Start Application Architecture

<instructions>
@../guides/conventions.md
@../guides/routes.md
@../guides/services.md
@../guides/hooks.md
</instructions>

---

<forbidden>

| Category | Forbidden |
|----------|-----------|
| **Routes** | Flat file routes (`routes/users.tsx`) |
| **Route Export** | `export const IndexRoute`, `const Route` (without export) |
| **API** | Creating `/api` routes (use Server Functions) |
| **Layers** | Skipping Service Layer, direct DB access from Routes |
| **Validation** | Manual validation inside handler, scattered auth logic |
| **Barrel Export** | Creating `functions/index.ts` (Tree Shaking fails, server libraries pollute Client bundle) |

</forbidden>

---

<required>

| Category | Required |
|----------|----------|
| **Route Structure** | Create folder per page (`routes/users/index.tsx`) |
| **Route Export** | `export const Route = createFileRoute(...)` required |
| **Layer Structure** | Routes → Server Functions → Services → Database |
| **Route Group** | List pages → `(main)/`, create/edit → outside |
| **Page Separation** | 100+ lines → `-components`, 200+ lines → `-sections` |
| **beforeLoad** | Auth check, Context passing, redirects |
| **loader** | Data loading (runs in parallel after beforeLoad) |
| **Server Fn** | Use `createServerFn` by default |
| **Validation** | `inputValidator` (POST/PUT/PATCH), Zod schemas |
| **Auth** | `middleware` (authMiddleware) |
| **Error Handling** | `errorComponent` (route), `notFoundComponent` (404) |
| **Type Safety** | TypeScript strict, Prisma types |

</required>

---

<system_overview>

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (Browser)                         │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  React Router  │───▶│ TanStack Query │───▶│    React UI   │  │
│  │  (Navigation)  │◀───│   (Caching)    │◀───│  (Components) │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TanStack Start Server                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Server Functions                         │ │
│  │   routes/-functions/ → Page-specific | functions/ → Global │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Services Layer                           │ │
│  │   Zod Validation | Business Logic | Data Transformation    │ │
│  └────────────────────────────┬───────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  Prisma Client │───▶│   PostgreSQL   │    │    Redis      │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

</system_overview>

---

<route_export_rule>

## Route Export Rules

> ⚠️ **`export const Route` Required**
>
> TanStack Router requires all route files to export **exactly the name `Route`**.
>
> The `tsr generate` and `tsr watch` commands automatically generate and update routes.

| ❌ Forbidden | ✅ Required |
|--------------|-------------|
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| `export const IndexRoute = ...` | `export const Route = ...` |
| `export default createFileRoute(...)` | `export const Route = createFileRoute(...)` |

```typescript
// ❌ Forbidden: No export
const Route = createFileRoute('/users')({
  component: UsersPage,
})

// ❌ Forbidden: Different name
export const UsersRoute = createFileRoute('/users')({
  component: UsersPage,
})

// ✅ Required: Export with exactly 'Route' name
export const Route = createFileRoute('/users')({
  component: UsersPage,
})
```

</route_export_rule>

---

<layers>

## Layer Architecture

### 1. Routes Layer

> ⚠️ **Create Folder Per Page (Required)**
>
> All pages **must use folder structure**. Flat file approach (`routes/users.tsx`) is forbidden.
>
> **Reason:** To systematically manage page-specific resources like -components/, -functions/, -hooks/.
>
> | ❌ Forbidden | ✅ Required |
> |--------------|-------------|
> | `routes/users.tsx` | `routes/users/index.tsx` |
> | `routes/posts.tsx` | `routes/posts/(main)/index.tsx` |

```
routes/<route-name>/
├── (main)/                # Route group (list page)
│   ├── index.tsx          # Page component
│   ├── -components/       # Page-specific components
│   ├── -sections/         # UI section separation (200+ lines)
│   ├── -tabs/             # Tab content separation
│   ├── -hooks/            # Page-specific hooks
│   └── -utils/            # Constants, helpers
├── new/                   # Create page (outside route group)
│   └── index.tsx
├── route.tsx              # Route config (loader, beforeLoad)
└── -functions/            # Page-specific server functions
```

| Pattern | Location | Purpose |
|---------|----------|---------|
| **Route Group** | `(main)/` | List pages, excluded from URL |
| **-components/** | 100-200 lines | Separate page-specific components |
| **-sections/** | 200+ lines | Logical section separation |
| **-tabs/** | Tab UI | Tab content separation |
| **route.tsx** | Layout | Shared layout for child routes |

#### Layout Routes Pattern

> ⚠️ **Use route.tsx for Layouts**
>
> `route.tsx` serves as a shared layout for child routes.
> `index.tsx` must be wrapped with Route Group `()`.
>
> **Required:** `route.tsx` must export a `component`.
>
> | ❌ Forbidden | ✅ Required |
> |--------------|-------------|
> | `export const Route = createFileRoute(...)({})` | `export const Route = createFileRoute(...)({ component: ... })` |

```
routes/
├── (auth)/
│   ├── route.tsx           # Layout (<Outlet />)
│   ├── (main)/
│   │   └── index.tsx       # /auth (list/main)
│   ├── login/
│   │   └── index.tsx       # /auth/login
│   └── register/
│       └── index.tsx       # /auth/register
```

```typescript
// ❌ Forbidden: No component
export const Route = createFileRoute('/(auth)')({
  beforeLoad: async () => ({ user: await getUser() }),
})

// ✅ Required: Component must be included
// routes/(auth)/route.tsx - Layout
export const Route = createFileRoute('/(auth)')({
  component: () => (
    <div className="auth-container">
      <Outlet />
    </div>
  ),
})

// routes/(auth)/(main)/index.tsx - Main page
export const Route = createFileRoute('/(auth)/')({
  component: AuthMainPage,
})

// routes/(auth)/login/index.tsx
export const Route = createFileRoute('/(auth)/login')({
  component: LoginPage,
})
```

### 2. Services Layer

```
services/<domain>/
├── index.ts            # Entry point (re-export)
├── schemas.ts          # Zod schemas
├── queries.ts          # GET requests
└── mutations.ts        # POST/PUT/PATCH
```

### 3. Server Functions Layer

```
functions/                    # Global (reusable)
├── <function-name>.ts        # One per file
└── middlewares/
    └── <middleware-name>.ts

routes/<route>/-functions/    # Page-specific
└── <function-name>.ts
```

> ⚠️ **Do Not Create `functions/index.ts`**
>
> Do not create `index.ts` (barrel export) file in `functions/` folder.
>
> **Issues:**
> 1. **Tree Shaking Fails** - Bundler includes unused functions
> 2. **Client Bundle Pollution** - Server-only libraries like `pg`, `prisma` get imported to client, causing build errors
>
> ```typescript
> // ❌ Do not create functions/index.ts
> export * from './get-users'
> export * from './create-post'  // pg import → client build fails
>
> // ✅ Import directly from individual files
> import { getUsers } from '@/functions/get-users'
> import { createPost } from '@/functions/create-post'
> ```

### 4. Database Layer

```typescript
// database/prisma.ts
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

</layers>

---

<route_lifecycle>

## Route Lifecycle

### beforeLoad vs loader

| Item | beforeLoad | loader |
|------|-----------|--------|
| **Execution Order** | Sequential (outermost → innermost) | Parallel (after beforeLoad completes) |
| **Purpose** | Auth, Context passing, redirects | Data loading |
| **Blocking** | Blocks all loaders | Runs in parallel with other loaders |
| **Performance Impact** | ⚠️ High | ✅ Low |

```
1. Parent beforeLoad (sequential) ──┐
2. Child beforeLoad (sequential)  ──┼→ After completion
3. All loaders (parallel) ───────────┘
```

### Code Patterns

```typescript
// ✅ beforeLoad: Auth & Context
beforeLoad: async () => {
  const user = await getUser()
  if (!user) throw redirect({ to: '/login' })
  return { user }
}

// ✅ loader: Data Loading
loader: async () => {
  const [users, roles] = await Promise.all([
    getUsers(),
    getRoles(),
  ])
  return { users, roles }
}
```

| ❌ Avoid | ✅ Recommended |
|----------|----------------|
| Data loading in beforeLoad | Data loading in loader |
| Blocking loaders | Parallel execution |

</route_lifecycle>

---

<context_management>

## Context Management

| Step | File | Action |
|------|------|--------|
| **Create** | `__root.tsx` | `createRootRouteWithContext` |
| **Extend** | `route.tsx` | Extend Context in `beforeLoad` |
| **Use** | `component` | `useRouteContext()` |

```typescript
// 1. Root: Define Context
interface RouterContext {
  user: User | null
}

export const Route = createRootRouteWithContext<RouterContext>()({
  beforeLoad: async () => ({ user: await getUser() }),
})

// 2. Extend: Extend Context
beforeLoad: async ({ context }) => ({
  ...context,
  permissions: await getPermissions(context.user.id),
})

// 3. Use: Component
const { user, permissions } = useRouteContext({ from: '/dashboard' })

// 4. Use: Loader
loader: async ({ context }) => {
  if (!context.permissions.includes('users:read')) {
    throw new Error('Unauthorized')
  }
  return { users: await getUsers() }
}
```

</context_management>

---

<data_flow>

## Data Flow

### Query Flow (Read)

```
Page → useQuery → Server Function → Prisma → Database
          ↑
    TanStack Query (Cache)
```

```typescript
// Page
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: getUsers,
})

// Server Function
export const getUsers = createServerFn()
  .middleware([authMiddleware])
  .handler(async () => prisma.user.findMany())
```

### Mutation Flow (Write)

```
Form → useMutation → Server Function
                          ↓
                    inputValidator
                          ↓
                    Prisma → Database
                          ↓
                    invalidateQueries
```

```typescript
// Page
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
  },
})

// Server Function
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

</data_flow>

---

<server_functions_advanced>

## Server Functions (Advanced)

### Server Functions Types

| Type | Execution | Use Cases |
|------|-----------|-----------|
| **createServerFn** | Server | DB access, secrets, server logic (default) |
| createClientOnlyFn | Client | localStorage, window |
| createIsomorphicFn | Both | Environment-specific implementations |

**Default Rule**: Use `createServerFn` unless specified otherwise

### Middleware Pattern

```typescript
// 1. authMiddleware
export const authMiddleware = createMiddleware()
  .server(async ({ next, context }) => {
    const session = await getSession()
    if (!session?.user) throw new Error('Unauthorized')
    return next({ context: { ...context, user: session.user } })
  })

// 2. Usage
export const createPost = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createPostSchema)
  .handler(async ({ data, context }) => {
    return prisma.post.create({
      data: { ...data, authorId: context.user.id },
    })
  })
```

**Execution Order**: Middleware → inputValidator → handler

</server_functions_advanced>

---

<error_handling>

## Error Handling

| Component | Scope | Location | Required |
|-----------|-------|----------|----------|
| **errorComponent** | Route errors | Each route | ✅ |
| **notFoundComponent** | 404 | __root.tsx | ✅ |
| **pendingComponent** | Loading | Each route | Optional |

```typescript
// __root.tsx
export const Route = createRootRoute({
  errorComponent: ({ error }) => <div>{error.message}</div>,
  notFoundComponent: () => <div>404 Not Found</div>,
})

// Route level
export const Route = createFileRoute('/dashboard')({
  errorComponent: ({ error }) => <div>{error.message}</div>,
})

// Loader errors
loader: async () => {
  try {
    return { users: await getUsers() }
  } catch (error) {
    throw new Error('Failed to load data')
  }
}

// Server Function errors
.handler(async ({ data }) => {
  try {
    return await prisma.user.create({ data })
  } catch (error) {
    if (error.code === 'P2002') {
      throw new Error('Email already exists')
    }
    throw new Error('Failed to create user')
  }
})
```

</error_handling>

---

<tech_stack>

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | TanStack Start | latest |
| Router | TanStack Router | latest |
| Data | TanStack Query | latest |
| ORM | Prisma | 7.x |
| Validation | Zod | 4.x |
| Database | PostgreSQL | - |
| UI | React 18+ | - |

</tech_stack>
