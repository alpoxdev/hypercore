# CLAUDE.md - Claude Code Instructions

> TanStack Start + React 프로젝트 작업 지침

---

## 🚨 STOP - 작업 전 필수 확인

```
┌─────────────────────────────────────────────────────────────┐
│  이 프로젝트에서 작업하기 전에 이 문서를 끝까지 읽으세요.  │
│  특히 ⛔ NEVER DO 섹션의 규칙은 절대 위반하지 마세요.      │
│                                                             │
│  📖 작업 유형별 상세 문서: docs/ 폴더 참조                  │
└─────────────────────────────────────────────────────────────┘
```

---

## ⛔ NEVER DO (절대 금지 - 예외 없음)

### Git 커밋 금지 사항
```
❌ "Generated with Claude Code" 포함 금지
❌ "🤖" 또는 AI 관련 이모지 포함 금지
❌ "Co-Authored-By:" 헤더 포함 금지
❌ AI/봇이 작성했다는 어떤 표시도 금지
❌ 커밋 메시지 여러 줄 작성 금지
❌ 커밋 메시지에 이모지 사용 금지
```

### Prisma 금지 사항
```
❌ prisma db push 자동 실행 금지
❌ prisma migrate 자동 실행 금지
❌ prisma generate 자동 실행 금지
❌ schema.prisma 임의 변경 금지 (요청된 것만)
```

---

## ✅ ALWAYS DO (필수 실행)

### 1. 작업 전: 관련 문서 읽기
```
UI 작업      → docs/design/ 읽기
API 작업     → docs/library/tanstack-start/ 읽기
DB 작업      → docs/library/prisma/ 읽기
인증 작업    → docs/library/better-auth/ 읽기
```

### 2. 작업 완료 후: Git 커밋
```bash
git add .
git commit -m "<prefix>: <설명>"
```

**커밋 형식**: `<prefix>: <설명>` (한 줄, 본문 없음)

**Prefix**: `feat` | `fix` | `refactor` | `style` | `docs` | `test` | `chore` | `perf` | `ci`

**예시**:
```bash
feat: 사용자 로그인 기능 추가
fix: 세션 만료 오류 수정
docs: API 문서 업데이트
```

---

## 📚 문서 참조 테이블

| 작업 | 문서 경로 | 필독 여부 |
|------|----------|----------|
| **전체 가이드** | `docs/README.md` | 🔴 필수 |
| **Git 규칙** | `docs/git/index.md` | 🔴 필수 |
| **UI 개발** | `docs/design/` | 🟡 해당 시 |
| **API 개발** | `docs/library/tanstack-start/` | 🟡 해당 시 |
| **인증** | `docs/library/better-auth/` | 🟡 해당 시 |
| **DB** | `docs/library/prisma/` | 🟡 해당 시 |
| **데이터 페칭** | `docs/library/tanstack-query/` | 🟡 해당 시 |
| **검증** | `docs/library/zod/` | 🟡 해당 시 |
| **배포** | `docs/deployment/` | 🟡 해당 시 |

---

## 🛠 Tech Stack (버전 주의)

| 기술 | 버전 | 주의사항 |
|------|------|----------|
| TanStack Start | 최신 | Framework |
| TypeScript | 5.x | strict mode |
| Tailwind CSS | 4.x | `@theme` 사용 |
| Prisma | **7.x** | `prisma-client` (js 아님), output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` (string().email() 아님) |
| Better Auth | 최신 | 인증 |
| TanStack Query | 5.x | 데이터 페칭 |

---

## 📁 Directory Structure

```
app/
├── routes/                   # File-based routes
│   ├── __root.tsx            # Root layout
│   ├── index.tsx             # / (Home)
│   ├── $slug.tsx             # Dynamic route
│   └── users/
│       ├── index.tsx         # /users
│       ├── -components/      # 페이지 전용 (라우트 제외)
│       └── -hooks/           # 페이지 전용 (라우트 제외)
├── components/ui/            # 공통 UI 컴포넌트
├── services/                 # 도메인별 서비스
│   └── user/
│       ├── index.ts          # re-export
│       ├── schemas.ts        # Zod 스키마
│       ├── queries.ts        # GET (createServerFn)
│       └── mutations.ts      # POST (createServerFn)
├── database/prisma.ts        # Prisma Client
└── lib/                      # 유틸리티
```

**`-` prefix**: 라우트에서 제외되는 폴더

---

## 🔧 Code Conventions

### File Naming
- **kebab-case**: `user-profile.tsx`, `auth-service.ts`
- **Routes**: `__root.tsx`, `$param.tsx`

### TypeScript
- `const` 선언 사용 (function 대신)
- 명시적 return type
- `interface` (객체) / `type` (유니온)
- `any` 금지 → `unknown` 사용

### Import
```typescript
// @/* → ./app/*
import { prisma } from '@/database/prisma'
import { getUsers } from '@/services/user'
```

**순서**: 외부 → 내부(@/) → 상대경로 → type imports

---

## 📝 Quick Patterns (복사용)

### Server Function (GET)
```typescript
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => prisma.user.findMany())
```

### Server Function (POST + Validation)
```typescript
export const createUser = createServerFn({ method: 'POST' })
  .validator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

### Zod Schema (v4 문법!)
```typescript
const schema = z.object({
  email: z.email(),           // ✅ v4
  name: z.string().min(1).trim(),
  website: z.url().optional(), // ✅ v4
})
```

### Route with Loader
```tsx
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => ({ users: await getUsers() }),
})
```

### TanStack Query
```tsx
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: () => getUsers(),
})

const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
})
```

---

## 🎨 UI/UX Rules

- **색상**: 60-30-10 규칙 (배경-보조-강조)
- **간격**: 8px 그리드 (8의 배수)
- **접근성**: WCAG AA (대비 4.5:1+)
- **폰트**: 최대 2-3개
- **Safe Area**: `tailwindcss-safe-area` 사용

**상세**: `docs/design/` 참고

---

## 🔗 Quick Links

- [문서 가이드](./docs/README.md)
- [Git 규칙](./docs/git/index.md)
- [디자인 가이드](./docs/design/index.md)
- [아키텍처](./docs/architecture/architecture.md)
