# 코드 컨벤션

> TanStack Start 프로젝트 코드 작성 규칙

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| route filename은 TanStack Router convention 준수 | Official | official route name 유지 |
| route 외 filename은 kebab-case | Hypercore convention | touched file에 적용 |
| no `any`, explicit return type, const arrow function | Hypercore convention | touched code에 적용 |
| 의미 있는 code group의 Korean block comment | Hypercore convention | touched implementation file에 적용 |

---

## 파일 네이밍

> camelCase 파일명 금지 - 모든 파일명은 kebab-case 사용

| 타입 | 규칙 | 예시 |
|------|------|------|
| **일반 파일** | kebab-case | `user-profile.tsx`, `auth-service.ts` |
| **Route 파일** | TanStack Router 규칙 | `__root.tsx`, `index.tsx`, `$id.tsx` |
| **Hook 파일** | `use-` 접두사 + kebab-case | `use-user-filter.ts`, `use-auth.ts` |
| **Component** | PascalCase 컴포넌트, kebab-case 파일 | `UserCard` in `user-card.tsx` |
| **Server Function** | kebab-case | `get-users.ts`, `create-post.ts` |

```
camelCase 금지: getUserById.ts, authService.ts, useUserFilter.ts
kebab-case 필수: get-user-by-id.ts, auth-service.ts, use-user-filter.ts
```

---

## TypeScript 규칙

| 규칙 | 설명 | 예시 |
|------|------|------|
| **함수 선언** | const 함수, 명시적 return type | `const fn = (): ReturnType => {}` |
| **타입 정의** | interface (객체), type (유니온) | `interface User {}`, `type Status = 'a' \| 'b'` |
| **any 금지** | unknown 사용 | `const data: unknown = JSON.parse(str)` |
| **Import 타입** | type import 분리 | `import type { User } from '@/types'` |

```typescript
// const 함수, 명시적 타입
const getUserById = async (id: string): Promise<User> => {
  return prisma.user.findUnique({ where: { id } })
}

// any 금지 -> unknown 사용
const parseJSON = (data: string): unknown => {
  return JSON.parse(data)
}

// function 키워드 금지
// function badFunction() {} -> const 화살표 함수 사용
```

---

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

---

## 한글 주석 (묶음 단위)

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

세세한 줄별 주석 금지. 코드 묶음 단위로만 주석 작성.

---

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
