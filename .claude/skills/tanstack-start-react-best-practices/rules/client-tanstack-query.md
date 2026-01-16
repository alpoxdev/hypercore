---
title: Use TanStack Query for Automatic Caching and Deduplication
impact: MEDIUM-HIGH
impactDescription: eliminates duplicate requests
tags: client, cache, tanstack-query, deduplication
---

## Use TanStack Query for Automatic Caching and Deduplication

Wrap server function calls with TanStack Query to enable automatic request deduplication, caching, and background refetching.

**Incorrect (no deduplication, each component fetches):**

```tsx
import { useState, useEffect } from 'react'
import { getUsers } from '@/functions/data'

function UserList() {
  const [users, setUsers] = useState([])

  useEffect(() => {
    getUsers().then(setUsers)
  }, [])

  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}

// If UserList is used 3 times on a page, getUsers() is called 3 times
```

**Correct (automatic deduplication, single request):**

```tsx
import { useQuery } from '@tanstack/react-query'
import { getUsers } from '@/functions/data'

function UserList() {
  const { data: users = [] } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers()
  })

  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}

// Multiple instances share one request, with automatic cache invalidation
```

**With mutations:**

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser } from '@/functions/data'

function UserManager() {
  const queryClient = useQueryClient()

  const { data: users = [] } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers()
  })

  const mutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      // Automatically refetch users
      queryClient.invalidateQueries({ queryKey: ['users'] })
    }
  })

  return <div>...</div>
}
```

TanStack Query provides: request deduplication, background refetching, cache invalidation, optimistic updates, retry logic, and loading/error states.

Reference: [TanStack Query](https://tanstack.com/query)
