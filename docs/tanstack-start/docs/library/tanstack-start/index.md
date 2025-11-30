# TanStack Start

> **Version**: 1.x | Full-stack React Framework

---

## ⛔ 필수 규칙

```
❌ /api 라우터 사용 금지 → Server Functions 사용
❌ handler 내부 수동 검증 금지 → inputValidator 사용
❌ handler 내부 수동 인증 체크 금지 → middleware 사용
✅ POST/PUT/PATCH에는 반드시 inputValidator 추가
✅ 인증 필요 시 반드시 middleware 추가
```

---

## 🚀 Quick Reference (복사용)

```typescript
// ✅ Server Function (GET + 인증)
export const getUsers = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])  // ⭐ 인증 미들웨어
  .handler(async () => prisma.user.findMany())

// ✅ Server Function (POST + Validation + 인증)
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])        // ⭐ 인증 미들웨어
  .inputValidator(createUserSchema)    // ⭐ Zod 스키마
  .handler(async ({ data }) => prisma.user.create({ data }))

// Route with Loader
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => ({ users: await getUsers() }),
})

// Component에서 Loader 데이터 사용
const UsersPage = (): JSX.Element => {
  const { users } = Route.useLoaderData()
  return <div>{/* render */}</div>
}
```

### 라우트 파일 구조

```
routes/
├── __root.tsx            # Root layout
├── index.tsx             # /
├── about.tsx             # /about
└── users/
    ├── index.tsx         # /users
    ├── $id.tsx           # /users/:id
    ├── -components/      # 페이지 전용 컴포넌트
    └── -functions/       # 페이지 전용 Server Functions ⭐
```

### Server Functions 위치

```
공통 함수 (여러 라우트)  → @/functions/
라우트 전용 함수         → routes/[경로]/-functions/
```

---

## 문서 구조

- [설치 및 설정](./setup.md) - 패키지 설치, Vite 설정, TypeScript 설정
- [Server Functions](./server-functions.md) - 서버 함수 정의 및 사용법
- [Middleware](./middleware.md) - 미들웨어 정의 및 적용
- [Routing](./routing.md) - 파일 기반 라우팅, 동적 라우트, SSR
- [인증 패턴](./auth-patterns.md) - 로그인, 로그아웃, 세션 관리

## 빠른 시작

```bash
yarn add @tanstack/react-start @tanstack/react-router vinxi
yarn add -D vite @vitejs/plugin-react vite-tsconfig-paths
```

## 핵심 개념

### Server Functions
서버에서만 실행되는 타입 안전한 함수를 정의합니다.

```typescript
import { createServerFn } from '@tanstack/react-start'

export const getData = createServerFn({ method: 'GET' })
  .handler(async () => {
    return { message: 'Hello from server' }
  })
```

### File-based Routing
파일 시스템 기반의 자동 라우팅을 지원합니다.

```
routes/
├── index.tsx        → /
├── about.tsx        → /about
└── users/
    ├── index.tsx    → /users
    └── $id.tsx      → /users/:id
```

## 참고 자료

- [TanStack Start 공식 문서](https://tanstack.com/start/latest)
- [TanStack Router 문서](https://tanstack.com/router/latest)
- [Vinxi 문서](https://vinxi.dev)
