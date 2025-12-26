# 코드 컨벤션

TanStack Start 프로젝트의 코드 작성 규칙.

## 파일 네이밍

**모든 파일은 kebab-case**:

```
✅ user-profile.tsx
✅ auth-service.ts
✅ use-user-filter.ts

❌ UserProfile.tsx
❌ authService.ts
❌ useUserFilter.ts
```

## Import 순서

```typescript
// 1. External libraries
import { createFileRoute } from '@tanstack/react-router'
import { useQuery } from '@tanstack/react-query'

// 2. Internal packages
import { Button } from '@/components/ui/button'
import { prisma } from '@/lib/prisma'

// 3. Relative imports (route-specific)
import { UserCard } from './-components/user-card'
import { useUsers } from './-hooks/use-users'

// 4. Type imports
import type { User } from '@/types'
```

## 함수 스타일

```typescript
// ✅ const 함수
const getUserById = async (id: string): Promise<User> => {
  return prisma.user.findUnique({ where: { id } })
}

// ✅ 명시적 반환 타입
const formatDate = (date: Date): string => {
  return date.toISOString()
}

// ❌ any 금지 → unknown 사용
const parseJSON = (data: string): unknown => {
  return JSON.parse(data)
}
```

## 한글 주석

**묶음 단위로 작성** (너무 세세하게 X):

```typescript
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 사용자 관련 상태
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const [user, setUser] = useState<User | null>(null)
const [isLoading, setIsLoading] = useState(false)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 데이터 조회
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => getUsers(),
})
```

```typescript
// ❌ 너무 세세한 주석 (금지)
const [user, setUser] = useState(null)  // 사용자 상태
const [isLoading, setIsLoading] = useState(false)  // 로딩 상태
```

## 에러 처리

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
```
