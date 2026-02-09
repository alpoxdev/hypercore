---
title: Code Splitting by Entry Point
impact: HIGH
impactDescription: 30-70% initial load reduction
tags: build, code-splitting, lazy-loading, bundle
languages: [js, ts]
related: [build-tree-shake, memory-lazy-init]
---

## 진입점/라우트별 코드 분할

단일 거대 번들 대신 진입점/라우트/기능별로 분할하여 초기 로딩 크기를 줄입니다.

**❌ 잘못된 예시 (단일 번들):**

```typescript
// 모든 페이지가 하나의 번들에 포함
import { Dashboard } from './pages/Dashboard'
import { Settings } from './pages/Settings'
import { Admin } from './pages/Admin'  // 대부분 사용자에게 불필요
```

**✅ 올바른 예시 (동적 import):**

```typescript
// JS/TS - 라우트별 코드 분할
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Settings = lazy(() => import('./pages/Settings'))
const Admin = lazy(() => import('./pages/Admin'))
```

```python
# Python - 무거운 모듈 지연 로딩
def analyze():
    import pandas as pd  # 필요 시점에만 로드 (import 시간 ~200ms)
    return pd.read_csv("data.csv")
```

```go
// Go - 플러그인 시스템으로 런타임 로딩
p, _ := plugin.Open("analytics.so")
analyze, _ := p.Lookup("Analyze")
```

**프레임워크별 패턴:**

| 프레임워크 | 코드 분할 방법 |
|-----------|-------------|
| React | `React.lazy()` + `Suspense` |
| Vue | `defineAsyncComponent()` |
| Svelte | `import()` in routes |
| Next.js | `next/dynamic` |
| TanStack Router | `.lazy.tsx` 파일 컨벤션 |
| Angular | `loadChildren` (lazy routes) |

**적용 기준:** 50KB+ 모듈, 조건부 표시 UI, 관리자 전용 기능.
