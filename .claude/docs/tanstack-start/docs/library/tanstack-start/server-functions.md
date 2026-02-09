# TanStack Start - Server Functions

> 타입 안전한 백엔드 API

---

<overview>

## Server Function이란?

Server Function은 서버에서만 실행되는 함수로, 클라이언트에서 타입 안전하게 호출할 수 있습니다.

| 특징 | 설명 |
|------|------|
| **타입 안전성** | 입출력 타입이 TypeScript로 자동 추론됨 |
| **직렬화** | JSON 자동 직렬화/역직렬화 |
| **검증** | Zod로 입력값 검증 (.inputValidator()) |
| **미들웨어** | 인증, 로깅, 권한 체크 등 (.middleware()) |
| **HTTP 메서드** | GET, POST, PUT, PATCH, DELETE 지원 |
| **클라이언트 호출** | TanStack Query (useQuery/useMutation) 필수 |

</overview>

---

<http_methods>

## HTTP 메서드별 사용 패턴

| 메서드 | 사용 | inputValidator | middleware |
|--------|------|---------------|-----------|
| **GET** | 데이터 조회 | 선택 | 인증 시 필수 |
| **POST** | 데이터 생성 | 필수 | 인증 시 필수 |
| **PUT** | 전체 수정 | 필수 | 인증 시 필수 |
| **PATCH** | 부분 수정 | 필수 | 인증 시 필수 |
| **DELETE** | 데이터 삭제 | 선택 | 인증 시 필수 |

</http_methods>

---

<get_method>

## GET: 데이터 조회

### 기본 GET

```typescript
// ✅ 간단한 조회
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async (): Promise<User[]> => {
    return prisma.user.findMany()
  })

// ✅ GET + 쿼리 파라미터 (선택적 검증)
export const getUserById = createServerFn({ method: 'GET' })
  .inputValidator(z.object({
    id: z.string().uuid(),
  }))
  .handler(async ({ data }): Promise<User | null> => {
    return prisma.user.findUnique({
      where: { id: data.id },
    })
  })

// ✅ GET + 필터링
const filterSchema = z.object({
  status: z.enum(['active', 'inactive']).optional(),
  limit: z.number().int().min(1).max(100).default(10),
})

export const searchUsers = createServerFn({ method: 'GET' })
  .inputValidator(filterSchema)
  .handler(async ({ data }): Promise<User[]> => {
    return prisma.user.findMany({
      where: {
        ...(data.status && { status: data.status }),
      },
      take: data.limit,
    })
  })
```

### GET + 인증

```typescript
// ✅ 현재 사용자 조회
export const getMyProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }): Promise<User> => {
    return prisma.user.findUnique({
      where: { id: context.user.id },
    })
  })

// ✅ 사용자 전용 데이터
export const getMyPosts = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }): Promise<Post[]> => {
    return prisma.post.findMany({
      where: { authorId: context.user.id },
      orderBy: { createdAt: 'desc' },
    })
  })
```

</get_method>

---

<post_method>

## POST: 데이터 생성

### POST + inputValidator (필수)

```typescript
// ✅ inputValidator 필수
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100).trim(),
  age: z.number().int().min(0).max(150).optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }): Promise<User> => {
    // data는 자동으로 검증됨 (타입 안전)
    return prisma.user.create({
      data,
    })
  })
```

### POST + inputValidator + 인증

```typescript
// ✅ POST + 검증 + 인증
const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(10000),
  tags: z.array(z.string()).max(5).default([]),
})

export const createPost = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createPostSchema)
  .handler(async ({ data, context }): Promise<Post> => {
    return prisma.post.create({
      data: {
        ...data,
        authorId: context.user.id,
        published: false,
      },
    })
  })
```

### POST + 부수 효과

```typescript
// ✅ 중복 체크 + 생성
const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(1),
})

export const registerUser = createServerFn({ method: 'POST' })
  .inputValidator(registerSchema)
  .handler(async ({ data }): Promise<{ user: User }> => {
    // 중복 체크 (내부 헬퍼)
    const exists = await prisma.user.findUnique({
      where: { email: data.email },
    })

    if (exists) {
      throw new Error('Email already registered')
    }

    // 비밀번호 해싱 (내부 헬퍼)
    const hashedPassword = await hashPassword(data.password)

    const user = await prisma.user.create({
      data: {
        ...data,
        password: hashedPassword,
      },
    })

    return { user }
  })
```

### ❌ inputValidator 없이 POST (금지)

```typescript
// ❌ 금지: 입력 검증 없음
export const badCreate = createServerFn({ method: 'POST' })
  .handler(async ({ data }) => {
    // data 타입 불안전, 검증 없음
    return prisma.user.create({ data })
  })
```

</post_method>

---

<put_patch_methods>

## PUT/PATCH: 데이터 수정

### PUT: 전체 수정

```typescript
// ✅ PUT + inputValidator 필수
const updateUserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).optional(),
})

export const updateUser = createServerFn({ method: 'PUT' })
  .middleware([authMiddleware])
  .inputValidator(updateUserSchema)
  .handler(async ({ data, context }): Promise<User> => {
    // 권한 체크
    const user = await prisma.user.findUnique({
      where: { id: data.id },
    })

    if (user?.id !== context.user.id && context.user.role !== 'ADMIN') {
      throw new Error('Unauthorized')
    }

    return prisma.user.update({
      where: { id: data.id },
      data: {
        email: data.email,
        name: data.name,
        ...(data.age !== undefined && { age: data.age }),
      },
    })
  })
```

### PATCH: 부분 수정

```typescript
// ✅ PATCH + inputValidator 필수 (모든 필드 optional)
const patchUserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email().optional(),
  name: z.string().min(1).max(100).optional(),
  age: z.number().int().min(0).optional(),
})

export const patchUser = createServerFn({ method: 'PATCH' })
  .middleware([authMiddleware])
  .inputValidator(patchUserSchema)
  .handler(async ({ data, context }): Promise<User> => {
    const { id, ...updateData } = data

    // 권한 체크
    if (id !== context.user.id && context.user.role !== 'ADMIN') {
      throw new Error('Unauthorized')
    }

    return prisma.user.update({
      where: { id },
      data: updateData,
    })
  })
```

</put_patch_methods>

---

<delete_method>

## DELETE: 데이터 삭제

```typescript
// ✅ DELETE + 권한 체크
const deletePostSchema = z.object({
  id: z.string().uuid(),
})

export const deletePost = createServerFn({ method: 'DELETE' })
  .middleware([authMiddleware])
  .inputValidator(deletePostSchema)
  .handler(async ({ data, context }): Promise<{ success: true }> => {
    // 권한 체크
    const post = await prisma.post.findUnique({
      where: { id: data.id },
    })

    if (!post) {
      throw new Error('Post not found')
    }

    if (post.authorId !== context.user.id && context.user.role !== 'ADMIN') {
      throw new Error('Forbidden')
    }

    await prisma.post.delete({
      where: { id: data.id },
    })

    return { success: true }
  })

// ✅ 관리자 전용 삭제
export const adminDeleteUser = createServerFn({ method: 'DELETE' })
  .middleware([adminMiddleware])
  .inputValidator(z.object({ id: z.string().uuid() }))
  .handler(async ({ data }): Promise<{ success: true }> => {
    await prisma.user.delete({
      where: { id: data.id },
    })
    return { success: true }
  })
```

</delete_method>

---

<input_validator>

## .inputValidator() - Zod 검증

### 기본 검증

```typescript
// ✅ 단순 객체
const emailSchema = z.object({
  email: z.string().email(),
})

export const sendEmail = createServerFn({ method: 'POST' })
  .inputValidator(emailSchema)
  .handler(async ({ data }) => {
    // data.email은 string (타입 안전)
    await sendEmailService(data.email)
    return { sent: true }
  })
```

### 복잡한 검증

```typescript
// ✅ 중첩 객체, 배열, transform
const createProjectSchema = z.object({
  name: z.string().min(1).max(100).trim(),
  description: z.string().min(10).max(1000).optional(),
  tags: z.array(z.string().min(1)).max(10),
  settings: z.object({
    isPublic: z.boolean().default(false),
    allowComments: z.boolean().default(true),
  }),
  startDate: z.coerce.date(),
}).strict() // 추가 필드 금지

export const createProject = createServerFn({ method: 'POST' })
  .inputValidator(createProjectSchema)
  .handler(async ({ data }) => {
    // data 완전 검증됨
    return prisma.project.create({ data })
  })
```

### 조건부 검증

```typescript
// ✅ Zod refine/superRefine
const passwordSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
})

export const resetPassword = createServerFn({ method: 'POST' })
  .inputValidator(passwordSchema)
  .handler(async ({ data }) => {
    // 비밀번호 업데이트
    return { success: true }
  })
```

</input_validator>

---

<middleware>

## .middleware() - 인증 및 권한 체크

### 기본 미들웨어

```typescript
// ✅ 인증 미들웨어
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)
    if (!session?.user) {
      throw redirect({ to: '/login' })
    }
    return next({ context: { user: session.user } })
  })

// 적용
export const getMyPosts = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }): Promise<Post[]> => {
    return prisma.post.findMany({
      where: { authorId: context.user.id },
    })
  })
```

### 권한 체크 미들웨어

```typescript
// ✅ 관리자 미들웨어
const adminMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)
    if (session?.user?.role !== 'ADMIN') {
      throw new Error('Forbidden: Admin only')
    }
    return next({ context: { user: session.user } })
  })

// ✅ 역할 기반 미들웨어
const roleMiddleware = (allowedRoles: string[]) =>
  createMiddleware({ type: 'function' })
    .server(async ({ next, request }) => {
      const session = await getSession(request)
      if (!session?.user || !allowedRoles.includes(session.user.role)) {
        throw new Error('Forbidden')
      }
      return next({ context: { user: session.user } })
    })

// 사용
export const deleteAnyUser = createServerFn({ method: 'DELETE' })
  .middleware([adminMiddleware])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }) => {
    return prisma.user.delete({ where: { id: data.id } })
  })
```

### 미들웨어 체이닝

```typescript
// ✅ 여러 미들웨어 조합
export const protectedFn = createServerFn({ method: 'POST' })
  .middleware([
    authMiddleware,        // 1. 인증
    adminMiddleware,       // 2. 권한
  ])
  .inputValidator(someSchema)
  .handler(async ({ data, context }) => {
    // context.user는 존재 (인증됨) + ADMIN 역할 확인됨
    return { success: true }
  })
```

</middleware>

---

<client_calling>

## 클라이언트에서 호출 (TanStack Query 필수)

### useQuery (GET)

```tsx
// ✅ 데이터 조회
const UsersPage = (): JSX.Element => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

### useMutation (POST/PUT/DELETE)

```tsx
// ✅ 데이터 생성/수정/삭제
const CreateUserForm = (): JSX.Element => {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: (payload: { email: string; name: string }) =>
      createUser(payload),
    onSuccess: () => {
      // 캐시 무효화 → 자동 리페치
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
    onError: (error) => {
      console.error('Creation failed:', error.message)
    },
  })

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    mutation.mutate({
      email: formData.get('email') as string,
      name: formData.get('name') as string,
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        name="email"
        type="email"
        required
        disabled={mutation.isPending}
      />
      <input
        name="name"
        required
        disabled={mutation.isPending}
      />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Creating...' : 'Create'}
      </button>
      {mutation.error && (
        <p style={{ color: 'red' }}>Error: {mutation.error.message}</p>
      )}
    </form>
  )
}
```

### Optimistic Updates

```tsx
// ✅ 낙관적 업데이트
const mutation = useMutation({
  mutationFn: (newPost) => createPost(newPost),
  onMutate: async (newPost) => {
    // 기존 쿼리 취소
    await queryClient.cancelQueries({ queryKey: ['posts'] })

    // 이전 데이터 저장
    const previousPosts = queryClient.getQueryData(['posts'])

    // 낙관적 업데이트
    queryClient.setQueryData(
      ['posts'],
      (old: Post[] = []) => [...old, newPost],
    )

    return { previousPosts }
  },
  onError: (err, newPost, context) => {
    // 실패 시 롤백
    queryClient.setQueryData(['posts'], context?.previousPosts)
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  },
})
```

### ❌ 직접 호출 금지

```tsx
// ❌ 잘못된 패턴 (캐싱 없음, 동기화 안됨)
const BadComponent = (): JSX.Element => {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    setLoading(true)
    getUsers() // ❌ 직접 호출 (TanStack Query 미사용)
      .then(setUsers)
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  return <div>{/* ... */}</div>
}
```

</client_calling>

---

<helper_functions>

## 헬퍼 함수 규칙

### ❌ 잘못된 구조

```typescript
// functions/user-functions.ts

// ❌ 헬퍼 함수를 export (금지!)
export const validateUserEmail = async (email: string): Promise<void> => {
  const exists = await prisma.user.findUnique({ where: { email } })
  if (exists) throw new Error('Email already exists')
}

// Server Function
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    await validateUserEmail(data.email) // ❌ export된 헬퍼
    return prisma.user.create({ data })
  })
```

### ✅ 올바른 구조

```typescript
// functions/user-functions.ts

// ✅ 헬퍼는 export 금지 (내부용)
const validateUserEmail = async (email: string): Promise<void> => {
  const exists = await prisma.user.findUnique({ where: { email } })
  if (exists) throw new Error('Email already exists')
}

// Server Function만 export
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    await validateUserEmail(data.email) // ✅ 내부 헬퍼만 사용
    return prisma.user.create({ data })
  })

// index.ts
export { createUser } from './user-functions'
// ❌ export { validateUserEmail } 금지
```

</helper_functions>

---

<environment_security>

## 환경 변수 보안

### ❌ 잘못된 패턴

```tsx
// routes/config.tsx

// ❌ loader에서 환경변수 직접 사용 (클라이언트에 노출)
export const Route = createFileRoute('/config')({
  loader: () => {
    const apiSecret = process.env.API_SECRET // ❌ 클라이언트에 노출됨!
    return { apiSecret }
  },
  component: ConfigPage,
})
```

### ✅ 올바른 패턴

```typescript
// functions/config.ts

// ✅ Server Function에서만 환경변수 사용
export const getSecretConfig = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async (): Promise<{ apiSecret: string }> => {
    return {
      apiSecret: process.env.API_SECRET, // ✅ 서버에서만 실행
    }
  })

// routes/config.tsx
export const Route = createFileRoute('/config')({
  loader: async () => {
    const config = await getSecretConfig()
    return config
  },
  component: ConfigPage,
})
```

</environment_security>

---

<static_server_functions>

## 정적 Server Functions (Experimental)

```typescript
// ✅ 정적 함수 (빌드 타임에 최적화)
import { staticFunctionMiddleware } from '@tanstack/react-start'

export const getStaticPosts = createServerFn({ method: 'GET' })
  .middleware([staticFunctionMiddleware])
  .handler(async (): Promise<Post[]> => {
    return prisma.post.findMany({
      where: { published: true },
    })
  })
```

**주의:** 이 기능은 실험적이며, TanStack Start 버전에 따라 변경될 수 있습니다.

</static_server_functions>

---

<return_types>

## 명시적 Return Type

```typescript
// ✅ 명시적 return type 필수
export const getUser = createServerFn({ method: 'GET' })
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }): Promise<User | null> => {
    return prisma.user.findUnique({ where: { id: data.id } })
  })

// ✅ 복잡한 타입
export const getStats = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async (): Promise<{
    totalUsers: number
    totalPosts: number
    lastUpdated: Date
  }> => {
    return {
      totalUsers: await prisma.user.count(),
      totalPosts: await prisma.post.count(),
      lastUpdated: new Date(),
    }
  })

// ❌ 암시적 타입 (금지)
export const badFn = createServerFn({ method: 'GET' })
  .handler(async () => {
    // return 타입이 추론됨 (불명확)
    return { data: 'something' }
  })
```

</return_types>

---

<file_organization>

## 파일 구조 권장사항

### 권장 구조

```
src/utils/
├── users.functions.ts   # Server Function 래퍼 (createServerFn)
├── users.server.ts      # 서버 전용 헬퍼 (DB 쿼리, 내부 로직)
└── schemas.ts           # 공유 검증 스키마 (클라이언트에서도 안전)
```

| 파일 | 역할 | import 가능 위치 |
|------|------|-----------------|
| `.functions.ts` | createServerFn 래퍼 export | 어디서든 안전 |
| `.server.ts` | 서버 전용 코드 | Server Function handler 내부에서만 |
| `.ts` (접미사 없음) | 클라이언트 안전 코드 (타입, 스키마, 상수) | 어디서든 안전 |

### 예시

```typescript
// users.server.ts - 서버 전용 헬퍼
import { db } from '~/db'

export async function findUserById(id: string) {
  return db.query.users.findFirst({ where: eq(users.id, id) })
}

// users.functions.ts - Server Functions
import { createServerFn } from '@tanstack/react-start'
import { findUserById } from './users.server'

export const getUser = createServerFn({ method: 'GET' })
  .inputValidator((data: { id: string }) => data)
  .handler(async ({ data }) => {
    return findUserById(data.id)
  })
```

### Static Import 안전성

Server Function은 클라이언트 컴포넌트에서 **정적으로 import 해도 안전**합니다:

```tsx
// ✅ 안전 - 빌드 프로세스가 환경별로 처리
import { getUser } from '~/utils/users.functions'

function UserProfile({ id }) {
  const { data } = useQuery({
    queryKey: ['user', id],
    queryFn: () => getUser({ data: { id } }),
  })
}
```

```tsx
// ❌ 동적 import 피하기 (번들러 문제 발생 가능)
const { getUser } = await import('~/utils/users.functions')
```

</file_organization>

---

<error_redirects>

## 에러 처리 및 리다이렉트

### 기본 에러

```typescript
export const riskyFunction = createServerFn().handler(async () => {
  if (Math.random() > 0.5) {
    throw new Error('Something went wrong!')
  }
  return { success: true }
})

// 에러가 클라이언트로 직렬화됨
try {
  await riskyFunction()
} catch (error) {
  console.log(error.message) // "Something went wrong!"
}
```

### 리다이렉트

```typescript
import { createServerFn } from '@tanstack/react-start'
import { redirect } from '@tanstack/react-router'

export const requireAuth = createServerFn().handler(async () => {
  const user = await getCurrentUser()

  if (!user) {
    throw redirect({ to: '/login' })
  }

  return user
})
```

### Not Found

```typescript
import { createServerFn } from '@tanstack/react-start'
import { notFound } from '@tanstack/react-router'

export const getPost = createServerFn()
  .inputValidator((data: { id: string }) => data)
  .handler(async ({ data }) => {
    const post = await db.findPost(data.id)

    if (!post) {
      throw notFound()
    }

    return post
  })
```

</error_redirects>

---

<server_context>

## Server Context 유틸리티

Server Function 내에서 요청/응답을 직접 제어할 수 있습니다:

```typescript
import { createServerFn } from '@tanstack/react-start'
import {
  getRequest,
  getRequestHeader,
  setResponseHeaders,
  setResponseStatus,
} from '@tanstack/react-start/server'

export const getCachedData = createServerFn({ method: 'GET' }).handler(
  async () => {
    // 요청 정보 접근
    const request = getRequest()
    const authHeader = getRequestHeader('Authorization')

    // 응답 헤더 설정 (캐싱 등)
    setResponseHeaders(
      new Headers({
        'Cache-Control': 'public, max-age=300',
        'CDN-Cache-Control': 'max-age=3600, stale-while-revalidate=600',
      }),
    )

    // 상태 코드 설정 (선택)
    setResponseStatus(200)

    return fetchData()
  },
)
```

### 사용 가능한 유틸리티

| 유틸리티 | 설명 |
|---------|------|
| `getRequest()` | 전체 Request 객체 접근 |
| `getRequestHeader(name)` | 특정 요청 헤더 읽기 |
| `setResponseHeader(name, value)` | 단일 응답 헤더 설정 |
| `setResponseHeaders(headers)` | Headers 객체로 복수 헤더 설정 |
| `setResponseStatus(code)` | HTTP 상태 코드 설정 |

</server_context>

---

<form_data>

## FormData 처리

```typescript
export const submitForm = createServerFn({ method: 'POST' })
  .inputValidator((data) => {
    if (!(data instanceof FormData)) {
      throw new Error('Expected FormData')
    }

    return {
      name: data.get('name')?.toString() || '',
      email: data.get('email')?.toString() || '',
    }
  })
  .handler(async ({ data }) => {
    // data.name, data.email 사용
    return { success: true }
  })
```

</form_data>

---

<version_info>

**Version:** v1.159.4 (2026-02-09 기준)

**주요 변경사항:**
- `.inputValidator()` replaces `.validator()` (deprecated)
- Enhanced middleware system with context
- Improved type safety for async handlers
- Server context utilities (getRequest, setResponseHeaders 등)
- Static import safety (빌드 시 환경별 처리)

**패키지:** `@tanstack/react-start`

</version_info>
