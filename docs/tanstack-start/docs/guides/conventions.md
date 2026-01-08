# 코드 컨벤션

> TanStack Start 프로젝트 코드 작성 규칙

---

<naming>

## 파일 네이밍

| 타입 | 규칙 | 예시 |
|------|------|------|
| **일반 파일** | kebab-case | `user-profile.tsx`, `auth-service.ts` |
| **Route 파일** | TanStack Router 규칙 | `__root.tsx`, `index.tsx`, `$id.tsx` |
| **Hook 파일** | `use-` 접두사 | `use-user-filter.ts`, `use-auth.ts` |
| **Component** | PascalCase (파일은 kebab) | `UserCard` in `user-card.tsx` |

</naming>

---

<typescript>

## TypeScript 규칙

| 규칙 | 설명 | 예시 |
|------|------|------|
| **함수 선언** | const 함수, 명시적 return type | `const fn = (): ReturnType => {}` |
| **타입 정의** | interface (객체), type (유니온) | `interface User {}`, `type Status = 'a' \| 'b'` |
| **any 금지** | unknown 사용 | `const data: unknown = JSON.parse(str)` |
| **Import 타입** | type import 분리 | `import type { User } from '@/types'` |

## 패턴

```typescript
// ✅ const 함수, 명시적 타입
const getUserById = async (id: string): Promise<User> => {
  return prisma.user.findUnique({ where: { id } })
}

// ✅ 간단한 함수도 명시적 타입
const formatDate = (date: Date): string => {
  return date.toISOString()
}

// ✅ any 금지 → unknown 사용
const parseJSON = (data: string): unknown => {
  return JSON.parse(data)
}

// ❌ any 사용 금지
const badParse = (data: string): any => {  // ❌
  return JSON.parse(data)
}

// ❌ function 키워드 금지
function badFunction() {  // ❌
  return 'use const arrow function'
}
```

</typescript>

---

<imports>

## Import 순서

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

## 한글 주석 (묶음 단위)

```typescript
// ✅ 코드 묶음 단위 주석
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 사용자 관련 상태
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const [user, setUser] = useState<User | null>(null)
const [isLoading, setIsLoading] = useState(false)
const [error, setError] = useState<Error | null>(null)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 데이터 조회
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => getUsers(),
})
```

```typescript
// ❌ 세세한 주석 (금지)
const [user, setUser] = useState(null)  // 사용자 상태
const [isLoading, setIsLoading] = useState(false)  // 로딩 상태
const [error, setError] = useState(null)  // 에러 상태
```

</comments>

---

<error_handling>

## 에러 처리 패턴

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

## 사용 예시

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

## 파일명 예시

| 타입 | ❌ 잘못된 예시 | ✅ 올바른 예시 |
|------|---------------|---------------|
| Component | `UserProfile.tsx` | `user-profile.tsx` |
| Service | `authService.ts` | `auth-service.ts` |
| Hook | `useUserFilter.ts` | `use-user-filter.ts` |
| Utility | `formatUtils.ts` | `format-utils.ts` |
| Type | `UserTypes.ts` | `user-types.ts` |

## Route 파일명

| 경로 | 파일명 | 설명 |
|------|--------|------|
| `/` | `index.tsx` | 인덱스 라우트 |
| `/users` | `users/index.tsx` | 사용자 목록 |
| `/users/:id` | `users/$id.tsx` | 동적 라우트 |
| `/posts/:slug` | `posts/$slug.tsx` | URL 파라미터 |
| Layout | `__root.tsx` | Root 레이아웃 |

</examples>
