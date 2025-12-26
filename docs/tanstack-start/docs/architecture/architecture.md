# Architecture

TanStack Start 애플리케이션 아키텍처 가이드.

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (Browser)                         │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  React Router  │───▶│ TanStack Query │───▶│    React UI   │  │
│  │  (Navigation)  │◀───│   (Caching)    │◀───│  (Components) │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TanStack Start Server                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Server Functions                         │ │
│  │   routes/-functions/ → 페이지 전용 | functions/ → 글로벌   │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Services Layer                           │ │
│  │   Zod Validation | Business Logic | Data Transformation    │ │
│  └────────────────────────────┬───────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  Prisma Client │───▶│   PostgreSQL   │    │    Redis      │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Layer Architecture

### 1. Routes Layer

```
routes/<route-name>/
├── index.tsx              # 페이지 컴포넌트
├── route.tsx              # route 설정 (loader, beforeLoad)
├── -functions/            # 페이지 전용 서버 함수
├── -components/           # 페이지 전용 컴포넌트
├── -sections/             # 섹션 분리
└── -hooks/                # 페이지 전용 훅
```

### 2. Services Layer

```
services/<domain>/
├── index.ts            # 진입점 (re-export)
├── schemas.ts          # Zod 스키마
├── queries.ts          # GET 요청
└── mutations.ts        # POST 요청
```

### 3. Server Functions Layer

```
functions/                    # 글로벌 서버 함수
├── index.ts
├── <function-name>.ts        # 파일당 하나의 함수
└── middlewares/
    └── <middleware-name>.ts

routes/<route>/-functions/    # 페이지 전용
└── <function-name>.ts
```

**규칙**: 파일당 하나의 함수, 글로벌 vs 로컬 분리

### 4. Database Layer

```typescript
// database/prisma.ts
import { PrismaClient } from '../../generated/prisma'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

## Data Flow

### Query Flow (읽기)

```
Page Hook → useQuery → Server Function (GET) → Prisma → Database
                 ↑
           TanStack Query (Cache)
```

### Mutation Flow (쓰기)

```
Form Submit → useMutation → Server Function (POST)
                                    ↓
                            Zod Validation
                                    ↓
                            Prisma Mutation → Database
                                    ↓
                            Cache Invalidate
```

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | TanStack Start | latest |
| Router | TanStack Router | latest |
| Data | TanStack Query | latest |
| ORM | Prisma | 7.x |
| Validation | Zod | 4.x |
| Database | PostgreSQL | - |
| UI | React 18+ | - |

## 관련 문서

- [conventions.md](../guides/conventions.md) - 코드 컨벤션
- [routes.md](../guides/routes.md) - 라우트 구조
- [hooks.md](../guides/hooks.md) - Custom Hook 패턴
- [services.md](../guides/services.md) - Service Layer
