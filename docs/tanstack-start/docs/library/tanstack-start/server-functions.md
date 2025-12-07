# TanStack Start - Server Functions

서버에서만 실행되는 타입 안전한 함수.

## ⚠️ 필수: TanStack Query 사용

클라이언트 호출 시 반드시 useQuery/useMutation 사용.
- 자동 캐싱, 중복 요청 제거, 로딩/에러 상태 관리, invalidateQueries 동기화

## 기본 패턴

```typescript
// GET
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => prisma.user.findMany())

// POST + Zod Validation
const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => prisma.user.create({ data }))
```

## 컴포넌트에서 호출

```tsx
// ✅ useQuery (조회)
const { data, isLoading } = useQuery({
  queryKey: ['posts'],
  queryFn: () => getServerPosts(),
})

// ✅ useMutation (변경)
const mutation = useMutation({
  mutationFn: createPost,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['posts'] }),
})

// ❌ 직접 호출 금지 (캐싱 없음, 동기화 안됨)
```

## 함수 분리 규칙

```typescript
// 내부 헬퍼 (export 금지!)
const validateUserData = async (email: string) => { ... }

// Server Function (export 가능)
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    await validateUserData(data.email)
    return prisma.user.create({ data })
  })

// index.ts: Server Function만 export
export { createUser } from './mutations'
// ❌ export { validateUserData } 금지
```

## 보안

```tsx
// ❌ loader에서 환경변수 직접 사용 (노출됨)
loader: () => { const secret = process.env.SECRET }

// ✅ Server Function 사용
const fn = createServerFn().handler(() => {
  const secret = process.env.SECRET // 서버에서만
})
```
