# Architecture

TanStack Start 애플리케이션 아키텍처 가이드.

## 목차

- [System Overview](#system-overview)
- [Layer Architecture](#layer-architecture)
  - [Routes Layer](#1-routes-layer)
  - [Services Layer](#2-services-layer)
  - [Server Functions Layer](#3-server-functions-layer)
  - [Database Layer](#4-database-layer)
- [Data Flow](#data-flow)
- [Technology Stack](#technology-stack)

---

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
├── (main)/                # route group (목록 페이지)
│   ├── index.tsx          # 페이지 컴포넌트
│   ├── -components/       # 페이지 전용 컴포넌트
│   ├── -sections/         # UI 섹션 분리 (200줄+ 페이지)
│   ├── -tabs/             # 탭 콘텐츠 분리
│   ├── -hooks/            # 페이지 전용 훅
│   └── -utils/            # 상수, 헬퍼
├── new/                   # 생성 페이지 (route group 외부)
│   └── index.tsx
├── route.tsx              # route 설정 (loader, beforeLoad)
└── -functions/            # 페이지 전용 서버 함수
```

#### Route Group 패턴 `(main)`

목록 페이지는 반드시 `(main)` route group으로 감싸야 한다:

```
routes/dashboard/companies/
├── (main)/                # /dashboard/companies (목록)
│   ├── index.tsx
│   └── -components/
└── new/                   # /dashboard/companies/new (생성)
    └── index.tsx
```

**규칙:**
- 목록 페이지 → `(main)/` 내부
- 생성/편집 페이지 → `(main)/` 외부
- URL에 `(main)`은 포함되지 않음

#### 페이지 크기 기준

| 줄 수 | 권장 조치 |
|-------|----------|
| ~100줄 | 단일 파일 OK |
| 100-200줄 | -components 분리 검토 |
| 200줄+ | -sections 분리 필수 |
| 탭 UI | -tabs 분리 권장 |

#### `-sections/` 패턴 (200줄+ 페이지)

큰 페이지는 논리적 섹션으로 분리:

```tsx
// routes/settings/(main)/index.tsx
import { GeneralSection } from './-sections/general-section'
import { SecuritySection } from './-sections/security-section'
import { NotificationSection } from './-sections/notification-section'

function SettingsPage() {
  return (
    <div className="space-y-8">
      <GeneralSection />
      <SecuritySection />
      <NotificationSection />
    </div>
  )
}
```

```
routes/settings/(main)/
├── index.tsx
└── -sections/
    ├── general-section.tsx
    ├── security-section.tsx
    └── notification-section.tsx
```

#### `-tabs/` 패턴 (탭 UI)

탭 기반 페이지는 각 탭을 별도 파일로 분리:

```tsx
// routes/project-settings/(main)/index.tsx
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { GeneralTab } from './-tabs/general-tab'
import { MembersTab } from './-tabs/members-tab'
import { DangerTab } from './-tabs/danger-tab'

function ProjectSettingsPage() {
  return (
    <Tabs defaultValue="general">
      <TabsList>
        <TabsTrigger value="general">일반</TabsTrigger>
        <TabsTrigger value="members">멤버</TabsTrigger>
        <TabsTrigger value="danger">위험</TabsTrigger>
      </TabsList>
      <TabsContent value="general"><GeneralTab /></TabsContent>
      <TabsContent value="members"><MembersTab /></TabsContent>
      <TabsContent value="danger"><DangerTab /></TabsContent>
    </Tabs>
  )
}
```

```
routes/project-settings/(main)/
├── index.tsx
└── -tabs/
    ├── general-tab.tsx
    ├── members-tab.tsx
    └── danger-tab.tsx
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