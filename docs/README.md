# 문서 가이드

> TanStack Start + React 프로젝트 개발 종합 가이드

---

## 🚀 Quick Reference

### 패턴 복사용

```typescript
// Server Function (GET)
export const getData = createServerFn({ method: 'GET' })
  .handler(async () => prisma.table.findMany())

// Server Function (POST)
export const createData = createServerFn({ method: 'POST' })
  .validator(schema)
  .handler(async ({ data }) => prisma.table.create({ data }))

// Zod Schema (v4)
const schema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
})

// Route Loader
export const Route = createFileRoute('/path')({
  component: Page,
  loader: async () => ({ data: await getData() }),
})

// Query
const { data } = useQuery({ queryKey: ['key'], queryFn: getData })

// Mutation
const mutation = useMutation({
  mutationFn: createData,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['key'] }),
})
```

---

## 📁 문서 구조

```
docs/
├── README.md                 # 이 문서
├── guides/                   # 개발 가이드
│   ├── getting-started.md    # 프로젝트 시작
│   ├── best-practices.md     # 모범 사례
│   └── project-templates.md  # 템플릿
├── architecture/             # 아키텍처
│   └── architecture.md
├── design/                   # UI/UX 가이드
│   ├── index.md              # 개요
│   ├── color.md              # 색상 (60-30-10)
│   ├── typography.md         # 폰트
│   ├── spacing.md            # 간격 (8px)
│   ├── components.md         # 컴포넌트
│   ├── accessibility.md      # 접근성 (WCAG)
│   ├── safe-area.md          # iOS Safe Area
│   └── tailwind-setup.md     # Tailwind v4
├── library/                  # 라이브러리
│   ├── tanstack-start/       # Server Functions
│   ├── tanstack-query/       # Query/Mutation
│   ├── better-auth/          # 인증
│   ├── prisma/               # ORM (v7)
│   └── zod/                  # 검증 (v4)
├── deployment/               # 배포
│   ├── index.md              # 개요
│   ├── nitro.md              # Nitro 설정
│   ├── vercel.md             # Vercel
│   ├── cloudflare.md         # Cloudflare
│   └── railway.md            # Railway
└── git/                      # Git
    └── index.md              # 커밋 컨벤션
```

---

## 📋 작업별 바로가기

### 프로젝트 시작
| 문서 | 내용 |
|------|------|
| [Getting Started](./guides/getting-started.md) | 초기 설정 |
| [Templates](./guides/project-templates.md) | 복사용 템플릿 |
| [Architecture](./architecture/architecture.md) | 구조 이해 |

### UI 개발
| 문서 | 내용 |
|------|------|
| [Design Guide](./design/index.md) | 디자인 개요 |
| [Color](./design/color.md) | 60-30-10 규칙 |
| [Typography](./design/typography.md) | 폰트 시스템 |
| [Spacing](./design/spacing.md) | 8px 그리드 |
| [Components](./design/components.md) | UI 컴포넌트 |
| [Accessibility](./design/accessibility.md) | WCAG AA |
| [Safe Area](./design/safe-area.md) | iOS 노치/홈바 |
| [Tailwind](./design/tailwind-setup.md) | v4 설정 |

### API 개발
| 문서 | 내용 |
|------|------|
| [TanStack Start](./library/tanstack-start/index.md) | 개요 |
| [Server Functions](./library/tanstack-start/server-functions.md) | createServerFn |
| [Middleware](./library/tanstack-start/middleware.md) | 요청 처리 |

### 데이터
| 문서 | 내용 |
|------|------|
| [Prisma](./library/prisma/index.md) | ORM (v7) |
| [Zod](./library/zod/index.md) | 검증 (v4) |
| [TanStack Query](./library/tanstack-query/index.md) | 데이터 페칭 |

### 인증
| 문서 | 내용 |
|------|------|
| [Better Auth](./library/better-auth/index.md) | 개요 |
| [Setup](./library/better-auth/setup.md) | 설치 |
| [Session](./library/better-auth/session.md) | 세션 관리 |
| [2FA](./library/better-auth/2fa.md) | 이중 인증 |

### 배포
| 문서 | 내용 |
|------|------|
| [Overview](./deployment/index.md) | 배포 개요 |
| [Vercel](./deployment/vercel.md) | Vercel |
| [Cloudflare](./deployment/cloudflare.md) | CF Pages |
| [Railway](./deployment/railway.md) | Railway |

### Git
| 문서 | 내용 |
|------|------|
| [Git Workflow](./git/index.md) | 커밋 컨벤션 |

---

## 🛠 기술 스택

| 분류 | 기술 | 버전 |
|------|------|------|
| Framework | TanStack Start | 최신 |
| Language | TypeScript | 5.x |
| Styling | Tailwind CSS | 4.x |
| Database | Prisma | 7.x |
| Validation | Zod | 4.x |
| Auth | Better Auth | 최신 |
| Data | TanStack Query | 5.x |

---

## 📂 프로젝트 구조

```
app/
├── routes/                   # 라우트
│   ├── __root.tsx            # Root layout
│   ├── index.tsx             # /
│   └── users/
│       ├── index.tsx         # /users
│       └── -components/      # 라우트 제외 (- prefix)
├── services/user/            # 서비스
│   ├── schemas.ts            # Zod
│   ├── queries.ts            # GET
│   └── mutations.ts          # POST
├── components/ui/            # 공통 UI
└── database/prisma.ts        # Prisma
```

**Import**: `@/*` → `./app/*`

---

## ⚡ 핵심 규칙 요약

### TypeScript
- `const` 선언 (function 아님)
- 명시적 return type
- `any` 금지 → `unknown`

### Zod v4
- `z.email()` (string().email() 아님)
- `z.url()` (string().url() 아님)

### Prisma v7
- 클라이언트: `./generated/prisma`
- 마이그레이션 자동 실행 금지

### Tailwind v4
- `@theme` 블록 사용
- `oklch()` 색상 권장

### UI
- 60-30-10 색상 규칙
- 8px 그리드
- WCAG AA 대비
