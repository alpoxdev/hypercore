# TanStack Start - Server Functions

> **상위 문서**: [TanStack Start](./index.md)

Server Functions는 서버에서만 실행되는 타입 안전한 함수입니다.

## ⚠️ 필수: TanStack Query 사용

**Server Function을 클라이언트에서 호출할 때는 반드시 TanStack Query를 사용해야 합니다.**

```
❌ 금지: Server Function 직접 호출
✅ 필수: useQuery/useMutation과 함께 사용
```

**이유**:
- 자동 캐싱 및 중복 요청 제거
- 로딩/에러 상태 관리
- 자동 재시도 및 백그라운드 갱신
- invalidateQueries로 일관된 데이터 동기화

## 기본 Server Function

```typescript
import { createServerFn } from '@tanstack/react-start'

// GET 요청 (데이터 조회)
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany()
  })

// POST 요청 (데이터 생성/수정)
export const createUser = createServerFn({ method: 'POST' })
  .handler(async () => {
    return { success: true }
  })
```

## Input Validation

### 기본 Validator

```typescript
import { createServerFn } from '@tanstack/react-start'

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator((data: { email: string; name: string }) => data)
  .handler(async ({ data }) => {
    // data는 타입 안전함
    return prisma.user.create({ data })
  })
```

### Zod Validation 사용

```typescript
import { createServerFn } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/react-start/validators'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  bio: z.string().max(500).optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

## FormData 처리

```typescript
import { createServerFn } from '@tanstack/react-start'

export const submitForm = createServerFn({ method: 'POST' })
  .inputValidator((formData: FormData) => {
    const name = formData.get('name') as string
    const email = formData.get('email') as string
    return { name, email }
  })
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

## 컴포넌트에서 호출 (TanStack Query 필수)

### ✅ 올바른 패턴: useQuery 사용 (데이터 조회)

```tsx
import { useServerFn } from '@tanstack/react-start'
import { useQuery } from '@tanstack/react-query'
import { getServerPosts } from '~/lib/server-functions'

function PostList() {
  const getPosts = useServerFn(getServerPosts)

  const { data, isLoading, error } = useQuery({
    queryKey: ['posts'],
    queryFn: () => getPosts(),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

### ✅ 올바른 패턴: useMutation 사용 (데이터 변경)

```tsx
import { useServerFn } from '@tanstack/react-start'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createPost, deletePost } from '~/lib/server-functions'

function PostForm() {
  const queryClient = useQueryClient()
  const createPostFn = useServerFn(createPost)

  const mutation = useMutation({
    mutationFn: (data: { title: string; content: string }) => createPostFn({ data }),
    onSuccess: () => {
      // 관련 쿼리 무효화로 데이터 동기화
      queryClient.invalidateQueries({ queryKey: ['posts'] })
    },
  })

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    mutation.mutate({
      title: formData.get('title') as string,
      content: formData.get('content') as string,
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? '저장 중...' : '저장'}
      </button>
    </form>
  )
}
```

### ❌ 금지: Server Function 직접 호출

```tsx
// ❌ 이렇게 하지 마세요!
function BadExample() {
  const [posts, setPosts] = useState([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    setLoading(true)
    getPosts()
      .then(setPosts)
      .finally(() => setLoading(false))
  }, [])

  // 문제점:
  // - 중복 요청 발생 가능
  // - 캐싱 없음
  // - 에러 처리 수동
  // - 다른 컴포넌트와 데이터 동기화 안됨
}
```

## 보안 패턴

### 서버 전용 데이터 보호

```tsx
// ❌ 잘못된 방법 - 클라이언트에 노출됨
export const Route = createFileRoute('/users')({
  loader: () => {
    const secret = process.env.SECRET // 클라이언트에 노출!
    return fetch(`/api/users?key=${secret}`)
  },
})

// ✅ 올바른 방법 - 서버 함수 사용
const getUsersSecurely = createServerFn().handler(() => {
  const secret = process.env.SECRET // 서버에서만 접근
  return fetch(`/api/users?key=${secret}`)
})

export const Route = createFileRoute('/users')({
  loader: () => getUsersSecurely(),
})
```
