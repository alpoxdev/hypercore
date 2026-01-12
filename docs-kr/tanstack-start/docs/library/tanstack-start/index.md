# TanStack Start

> 1.x | Full-stack React Framework

@setup.md
@server-functions.md
@middleware.md
@routing.md
@auth-patterns.md

---

## ⛔ 필수 규칙

| 금지 | 대신 |
|------|------|
| /api 라우터 | Server Functions |
| handler 내 수동 검증 | inputValidator |
| handler 내 수동 인증 | middleware |

✅ POST/PUT/PATCH → inputValidator 필수
✅ 인증 필요 → middleware 필수

---

## Quick Reference

```typescript
// GET + 인증
export const getUsers = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => prisma.user.findMany())

// POST + Validation + 인증
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))

// Route with Loader
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => ({ users: await getUsers() }),
})

// Loader 데이터 사용
const UsersPage = (): JSX.Element => {
  const { users } = Route.useLoaderData()
  return <div>{/* render */}</div>
}
```

### 구조

```
routes/
├── __root.tsx          # Root layout
├── index.tsx           # /
├── users/
│   ├── index.tsx       # /users
│   ├── $id.tsx         # /users/:id
│   ├── -components/    # 페이지 전용
│   └── -functions/     # 페이지 전용 Server Functions

공통 함수 → @/functions/
라우트 전용 → routes/[경로]/-functions/
```
