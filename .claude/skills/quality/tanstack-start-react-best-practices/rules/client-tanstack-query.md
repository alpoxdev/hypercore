---
title: TanStack Query로 자동 캐싱 및 중복 제거
impact: MEDIUM-HIGH
impactDescription: 중복 요청 제거
tags: client, cache, tanstack-query, deduplication
---

## TanStack Query로 자동 캐싱 및 중복 제거

서버 함수 호출을 TanStack Query로 래핑하여 자동 요청 중복 제거 (deduplication), 캐싱, 백그라운드 재페칭 활성화.

**❌ 잘못된 예 (중복 제거 없음, 각 컴포넌트가 페칭):**

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

// UserList를 페이지에 3번 사용하면 getUsers()가 3번 호출됨
```

**✅ 올바른 예 (자동 중복 제거, 단일 요청):**

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

// 여러 인스턴스가 하나의 요청 공유, 자동 캐시 무효화 포함
```

**Mutation과 함께:**

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
      // 자동으로 users 재페칭
      queryClient.invalidateQueries({ queryKey: ['users'] })
    }
  })

  return <div>...</div>
}
```

TanStack Query가 제공하는 것: 요청 중복 제거, 백그라운드 재페칭, 캐시 무효화, 낙관적 업데이트 (optimistic updates), 재시도 로직, 로딩/에러 상태.

참고: [TanStack Query](https://tanstack.com/query)
