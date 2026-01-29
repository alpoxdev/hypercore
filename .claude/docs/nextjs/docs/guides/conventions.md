# Conventions

> 코드 작성 규칙

---

## 파일명

| 유형 | 규칙 | 예시 |
|------|------|------|
| 컴포넌트 | kebab-case | `user-profile.tsx` |
| 라우트 | Next.js 규칙 | `page.tsx`, `layout.tsx`, `[id]/page.tsx` |
| Server Actions | kebab-case | `create-post.ts`, `posts.ts` |
| 유틸리티 | kebab-case | `format-date.ts` |

---

## TypeScript

### 변수 선언

```typescript
// ✅ const 우선
const user = { name: "Alice" }
const posts = await prisma.post.findMany()

// ❌ let 최소화
let count = 0 // 변경 필요시만
```

### 함수 선언

```typescript
// ✅ const 화살표 함수 + 명시적 return type
const getUser = async (id: string): Promise<User> => {
  return prisma.user.findUnique({ where: { id } })
}

// ❌ function 키워드 (export default 제외)
function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } })
}
```

### 타입 정의

```typescript
// ✅ interface (객체)
interface User {
  id: string
  name: string
  email: string
}

// ✅ type (유니온, 기타)
type Status = "active" | "inactive"
type UserOrNull = User | null

// ❌ any 금지 → unknown 사용
const data: unknown = JSON.parse(jsonString)
```

---

## Import 순서

```typescript
// 1. 외부 라이브러리
import { useState } from "react"
import { useQuery } from "@tanstack/react-query"

// 2. @/ alias
import { Button } from "@/components/ui/button"
import { prisma } from "@/database/prisma"

// 3. 상대경로
import { UserProfile } from "./-components/user-profile"

// 4. 타입 (분리)
import type { User } from "@/types"
```

---

## 컴포넌트

### Server Component (기본)

```typescript
// ✅ async 함수 + 직접 데이터 페칭
export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
```

### Client Component

```typescript
// ✅ "use client" + 상호작용
"use client"

import { useState } from "react"

export function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```

---

## Server Actions

### 파일 상단

```typescript
// ✅ "use server" + 여러 함수
"use server"

export async function createPost(formData: FormData) {
  // ...
}

export async function deletePost(id: string) {
  // ...
}
```

### Zod 검증

```typescript
"use server"

import { z } from "zod"

const schema = z.object({
  title: z.string().min(1),
  content: z.string(),
})

export async function createPost(formData: FormData) {
  const parsed = schema.parse({
    title: formData.get("title"),
    content: formData.get("content"),
  })

  // ...
}
```

---

## 주석

```typescript
// ✅ 코드 묶음 단위로 한글 주석
// 사용자 인증 체크
const session = await auth.api.getSession({ headers: headers() })
if (!session?.user) redirect("/login")

// 게시글 조회
const posts = await prisma.post.findMany({
  where: { userId: session.user.id },
  orderBy: { createdAt: "desc" },
})

// ❌ 모든 줄마다 주석
const session = await auth.api.getSession({ headers: headers() }) // 세션 조회
if (!session?.user) redirect("/login") // 로그인 리다이렉트
```

---

## Prisma

### Multi-File 구조

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # 모든 enum
└── user.prisma     # User 모델
```

### 한글 주석 필수

```prisma
/// 사용자
model User {
  id        String   @id @default(cuid())  /// 고유 ID
  email     String   @unique                /// 이메일 (고유)
  name      String?                         /// 이름 (옵션)
  role      Role     @default(USER)         /// 역할
  createdAt DateTime @default(now())        /// 생성일
  updatedAt DateTime @updatedAt             /// 수정일
}

/// 역할
enum Role {
  USER   /// 일반 사용자
  ADMIN  /// 관리자
}
```

---

## 폴더 구조

```
app/
├── (auth)/              # Route Group
│   ├── login/
│   │   └── page.tsx
│   └── signup/
│       └── page.tsx
├── dashboard/
│   ├── page.tsx
│   ├── -components/     # 페이지 전용 (필수)
│   │   ├── stats.tsx
│   │   └── chart.tsx
│   └── settings/
│       └── page.tsx
└── _components/         # 공통 Client Components
```

**규칙:**
- `-components/` - 페이지 전용 (밖에서 import 불가)
- `_components/` - 공통 (라우트에 포함 안됨)

---

## Custom Hook 순서

```typescript
"use client"

export function useExample() {
  // 1. State (useState, zustand)
  const [count, setCount] = useState(0)

  // 2. Global Hooks
  const router = useRouter()
  const params = useParams()
  const searchParams = useSearchParams()

  // 3. React Query
  const { data: posts } = useQuery({ queryKey: ["posts"], queryFn: getPosts })
  const mutation = useMutation({ mutationFn: createPost })

  // 4. Event Handlers
  const handleClick = () => {
    setCount(count + 1)
  }

  // 5. useMemo
  const total = useMemo(() => posts?.length || 0, [posts])

  // 6. useEffect
  useEffect(() => {
    console.log(count)
  }, [count])

  return { count, handleClick, total }
}
```

---

## 베스트 프랙티스

### ✅ DO

```typescript
// 1. 명시적 타입
const getUser = async (id: string): Promise<User> => { /* ... */ }

// 2. Zod 검증
const schema = z.object({ email: z.email() })
const parsed = schema.parse(data)

// 3. 에러 처리
try {
  await prisma.post.create({ data })
} catch (error) {
  console.error("Error creating post:", error)
  throw error
}

// 4. revalidatePath
await prisma.post.create({ data })
revalidatePath("/posts")
```

### ❌ DON'T

```typescript
// 1. any 사용
const data: any = await fetchData() // ❌

// 2. 검증 누락
const email = formData.get("email") // ❌ Zod 검증 필요
await createUser({ email })

// 3. 에러 무시
await prisma.post.create({ data }) // ❌ try-catch 필요

// 4. 캐시 무효화 누락
await prisma.post.create({ data }) // ❌ revalidatePath 필요
```

---

## Git 커밋

```bash
# ✅ 한 줄, prefix 사용
git commit -m "feat: 게시글 생성 기능 추가"
git commit -m "fix: 로그인 버그 수정"

# ❌ 여러 줄, 이모지, AI 표시
git commit -m "feat: 게시글 생성 기능 추가

상세 설명...

Co-Authored-By: Claude Code <noreply@anthropic.com>"  # ❌
```

**Prefix:**
- `feat` - 새 기능
- `fix` - 버그 수정
- `refactor` - 리팩토링
- `style` - 코드 스타일
- `docs` - 문서
- `test` - 테스트
- `chore` - 기타

---

## 참조

- [Next.js 공식 문서](https://nextjs.org/docs)
- [TypeScript 공식 문서](https://www.typescriptlang.org/)
