# Code Conventions

> TanStack Start project coding rules

---

<naming>

## File Naming

> ⚠️ **No camelCase filenames** - All filenames must use **kebab-case**

| Type | Rule | Example |
|------|------|------|
| **General Files** | kebab-case | `user-profile.tsx`, `auth-service.ts` |
| **Route Files** | TanStack Router rules | `__root.tsx`, `index.tsx`, `$id.tsx` |
| **Hook Files** | `use-` prefix + kebab-case | `use-user-filter.ts`, `use-auth.ts` |
| **Component** | PascalCase component, kebab-case file | `UserCard` in `user-card.tsx` |
| **Server Function** | kebab-case | `get-users.ts`, `create-post.ts` |

```
❌ No camelCase: getUserById.ts, authService.ts, useUserFilter.ts
✅ kebab-case required: get-user-by-id.ts, auth-service.ts, use-user-filter.ts
```

</naming>

---

<typescript>

## TypeScript Rules

| Rule | Description | Example |
|------|------|------|
| **Function Declaration** | const function, explicit return type | `const fn = (): ReturnType => {}` |
| **Type Definition** | interface (objects), type (unions) | `interface User {}`, `type Status = 'a' \| 'b'` |
| **No any** | Use unknown | `const data: unknown = JSON.parse(str)` |
| **Import Types** | Separate type imports | `import type { User } from '@/types'` |

## Patterns

```typescript
// ✅ const function, explicit type
const getUserById = async (id: string): Promise<User> => {
  return prisma.user.findUnique({ where: { id } })
}

// ✅ Simple functions also need explicit types
const formatDate = (date: Date): string => {
  return date.toISOString()
}

// ✅ No any → use unknown
const parseJSON = (data: string): unknown => {
  return JSON.parse(data)
}

// ❌ No any
const badParse = (data: string): any => {  // ❌
  return JSON.parse(data)
}

// ❌ No function keyword
function badFunction() {  // ❌
  return 'use const arrow function'
}
```

</typescript>

---

<imports>

## Import Order

```typescript
// 1. External libraries
import { createFileRoute } from '@tanstack/react-router'
import { useQuery } from '@tanstack/react-query'
import { z } from 'zod'

// 2. Internal packages (@/)
import { Button } from '@/components/ui/button'
import { prisma } from '@/database/prisma'
import { getUsers } from '@/services/user'

// 3. Relative imports (route-specific)
import { UserCard } from './-components/user-card'
import { useUsers } from './-hooks/use-users'

// 4. Type imports
import type { User } from '@/types'
import type { UseUsersReturn } from './-hooks/use-users'
```

</imports>

---

<comments>

## Korean Comments (Code Blocks)

```typescript
// ✅ Comments per code block
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// User-related state
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const [user, setUser] = useState<User | null>(null)
const [isLoading, setIsLoading] = useState(false)
const [error, setError] = useState<Error | null>(null)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Data fetching
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => getUsers(),
})
```

```typescript
// ❌ Line-by-line comments (forbidden)
const [user, setUser] = useState(null)  // User state
const [isLoading, setIsLoading] = useState(false)  // Loading state
const [error, setError] = useState(null)  // Error state
```

</comments>

---

<error_handling>

## Error Handling Pattern

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR'
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND')
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR')
  }
}

export class UnauthorizedError extends AppError {
  constructor() {
    super('Unauthorized', 401, 'UNAUTHORIZED')
  }
}
```

## Usage Example

```typescript
// services/user/queries.ts
import { NotFoundError } from '@/lib/errors'

export const getUserById = createServerFn({ method: 'GET' })
  .handler(async ({ data: id }: { data: string }) => {
    const user = await prisma.user.findUnique({ where: { id } })
    if (!user) throw new NotFoundError('User')
    return user
  })
```

</error_handling>

---

<examples>

## Filename Examples

| Type | ❌ Wrong | ✅ Correct |
|------|---------------|---------------|
| Component | `UserProfile.tsx` | `user-profile.tsx` |
| Service | `authService.ts` | `auth-service.ts` |
| Hook | `useUserFilter.ts` | `use-user-filter.ts` |
| Utility | `formatUtils.ts` | `format-utils.ts` |
| Type | `UserTypes.ts` | `user-types.ts` |

## Route Filenames

| Path | Filename | Description |
|------|--------|------|
| `/` | `index.tsx` | Index route |
| `/users` | `users/index.tsx` | User list |
| `/users/:id` | `users/$id.tsx` | Dynamic route |
| `/posts/:slug` | `posts/$slug.tsx` | URL parameter |
| Layout | `__root.tsx` | Root layout |

</examples>
