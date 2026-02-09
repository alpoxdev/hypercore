---
title: Leverage React Compiler for Automatic Memoization
impact: MEDIUM
impactDescription: eliminates manual memo/useMemo/useCallback
tags: rerender, react-compiler, memoization, react-19
---

## React Compiler로 자동 메모이제이션

React Compiler가 활성화되어 있다면 `memo()`, `useMemo()`, `useCallback()`을 수동으로 작성할 필요가 없습니다. 컴파일러가 빌드 타임에 자동으로 최적화합니다.

**React Compiler 없을 때 (수동 메모이제이션):**

```tsx
import { memo, useMemo, useCallback } from 'react'

const UserList = memo(function UserList({ users, onSelect }: Props) {
  const sorted = useMemo(
    () => users.toSorted((a, b) => a.name.localeCompare(b.name)),
    [users]
  )

  const handleSelect = useCallback((id: string) => {
    onSelect(id)
  }, [onSelect])

  return (
    <ul>
      {sorted.map(user => (
        <UserItem key={user.id} user={user} onSelect={handleSelect} />
      ))}
    </ul>
  )
})
```

**React Compiler 있을 때 (자동 최적화):**

```tsx
function UserList({ users, onSelect }: Props) {
  const sorted = users.toSorted((a, b) => a.name.localeCompare(b.name))

  const handleSelect = (id: string) => {
    onSelect(id)
  }

  return (
    <ul>
      {sorted.map(user => (
        <UserItem key={user.id} user={user} onSelect={handleSelect} />
      ))}
    </ul>
  )
  // Compiler가 자동으로 memo, useMemo, useCallback 삽입
}
```

**Compiler 활성화 확인:**

```typescript
// vite.config.ts (TanStack Start)
import { defineConfig } from '@tanstack/react-start/config'

export default defineConfig({
  react: {
    babel: {
      plugins: [['babel-plugin-react-compiler', {}]]
    }
  }
})
```

**수동 메모이제이션이 여전히 필요한 경우:**
- React Compiler가 비활성화된 프로젝트
- 써드파티 라이브러리가 `===` 참조 비교를 요구하는 경우
- Effect 의존성에 대한 정확한 제어가 필요한 경우
- 함수형 setState는 정확성(stale closure 방지)을 위해 Compiler와 무관하게 권장

**성능:** Meta 프로덕션에서 평균 12% 더 빠른 로드, 2.5배 빠른 상호작용 측정.

참고: [React Compiler](https://react.dev/learn/react-compiler)
