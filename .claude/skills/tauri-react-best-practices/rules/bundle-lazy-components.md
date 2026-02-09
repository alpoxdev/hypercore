---
title: Lazy Load Heavy Components
impact: HIGH
impactDescription: splits bundle and loads on demand
tags: bundle, lazy, code-splitting, suspense, react
---

# 무거운 컴포넌트 Lazy 로드

## 왜 중요한가

차트, 에디터, PDF 뷰어 등 무거운 컴포넌트를 메인 번들에 포함하면 **초기 로드 시간이 크게 증가**합니다. React의 `lazy()`와 `Suspense`를 사용하면 필요할 때만 로드하여 **초기 번들 크기를 크게 줄일 수 있습니다**.

## ❌ 잘못된 패턴

**무거운 컴포넌트 직접 import (메인 번들에 포함):**

```tsx
// ❌ 메인 번들: 2.5MB (react-chartjs-2 + chart.js 포함)
import { Line } from 'react-chartjs-2'
import { Chart as ChartJS, registerables } from 'chart.js'

ChartJS.register(...registerables)

function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Line data={chartData} /> {/* 500KB 라이브러리 */}
    </div>
  )
}
```

**다른 무거운 라이브러리 예시:**

```tsx
// ❌ 메인 번들: 3.2MB
import { Editor } from '@monaco-editor/react' // ~1.8MB
import { PDFViewer } from '@react-pdf/renderer' // ~800KB
import { DataGrid } from '@mui/x-data-grid' // ~600KB

function App() {
  return (
    <div>
      <Editor />
      <PDFViewer />
      <DataGrid />
    </div>
  )
}
```

**번들 분석:**
```
main.js: 3.2 MB (gzipped: 1.1 MB)
- Monaco Editor: 1.8 MB
- React PDF: 800 KB
- MUI DataGrid: 600 KB
```

## ✅ 올바른 패턴

**React.lazy()로 코드 스플리팅:**

```tsx
// ✅ 메인 번들: 200KB (차트 제외)
import { lazy, Suspense } from 'react'

// 동적 import로 별도 chunk 생성
const ChartComponent = lazy(() => import('./components/ChartComponent'))

function Dashboard() {
  const [showChart, setShowChart] = useState(false)

  return (
    <div>
      <h1>Dashboard</h1>
      <button onClick={() => setShowChart(true)}>
        Show Chart
      </button>

      {showChart && (
        <Suspense fallback={<div>Loading chart...</div>}>
          <ChartComponent data={chartData} />
        </Suspense>
      )}
    </div>
  )
}
```

**별도 파일로 분리 (components/ChartComponent.tsx):**

```tsx
// ChartComponent.tsx - 별도 chunk로 빌드됨
import { Line } from 'react-chartjs-2'
import { Chart as ChartJS, registerables } from 'chart.js'

ChartJS.register(...registerables)

export default function ChartComponent({ data }: { data: any }) {
  return <Line data={data} />
}
```

**여러 무거운 컴포넌트 lazy 로드:**

```tsx
import { lazy, Suspense } from 'react'

const Editor = lazy(() => import('@monaco-editor/react'))
const PDFViewer = lazy(() => import('./components/PDFViewer'))
const DataGrid = lazy(() => import('./components/DataGridWrapper'))

function App() {
  return (
    <div>
      <Suspense fallback={<div>Loading editor...</div>}>
        <Editor />
      </Suspense>

      <Suspense fallback={<div>Loading PDF viewer...</div>}>
        <PDFViewer />
      </Suspense>

      <Suspense fallback={<div>Loading data grid...</div>}>
        <DataGrid />
      </Suspense>
    </div>
  )
}
```

**번들 분석:**
```
main.js: 200 KB (gzipped: 70 KB)
ChartComponent-[hash].js: 500 KB (gzipped: 180 KB)
Editor-[hash].js: 1.8 MB (gzipped: 600 KB)
PDFViewer-[hash].js: 800 KB (gzipped: 250 KB)
DataGrid-[hash].js: 600 KB (gzipped: 200 KB)
```

**Route-based code splitting (추가 최적화):**

```tsx
// App.tsx
import { lazy, Suspense } from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'

// 라우트 레벨에서 lazy loading
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Settings = lazy(() => import('./pages/Settings'))
const Analytics = lazy(() => import('./pages/Analytics'))

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<div>Loading page...</div>}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="/analytics" element={<Analytics />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  )
}
```

## 추가 컨텍스트

**Lazy Loading 대상 라이브러리:**

| 라이브러리 | 크기 | Lazy 로드 권장 |
|-----------|------|----------------|
| `@monaco-editor/react` | ~1.8MB | ✅ 필수 |
| `react-chartjs-2` + `chart.js` | ~500KB | ✅ 권장 |
| `@react-pdf/renderer` | ~800KB | ✅ 권장 |
| `@mui/x-data-grid` | ~600KB | ✅ 권장 |
| `react-quill` | ~400KB | ✅ 권장 |
| `katex` (수식 렌더링) | ~300KB | ✅ 권장 |
| `prismjs` (코드 하이라이팅) | ~200KB | ⚠️ 선택 |

**Suspense fallback 패턴:**

```tsx
// 스켈레톤 UI로 로딩 상태 표시
function ChartSkeleton() {
  return (
    <div className="animate-pulse">
      <div className="h-64 bg-gray-200 rounded" />
    </div>
  )
}

<Suspense fallback={<ChartSkeleton />}>
  <ChartComponent />
</Suspense>
```

**Preloading 패턴 (UX 개선):**

```tsx
import { lazy, Suspense } from 'react'

const ChartComponent = lazy(() => import('./ChartComponent'))

function Dashboard() {
  const handleMouseEnter = () => {
    // 마우스 호버 시 미리 로드
    import('./ChartComponent')
  }

  return (
    <button onMouseEnter={handleMouseEnter}>
      Show Chart
    </button>
  )
}
```

**Vite 설정 확인:**

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          // 특정 라이브러리를 별도 chunk로 분리
          'chart-lib': ['react-chartjs-2', 'chart.js'],
          'editor-lib': ['@monaco-editor/react'],
          'pdf-lib': ['@react-pdf/renderer']
        }
      }
    }
  }
})
```

**효과:**
- 초기 번들: 3.2MB → 200KB (16배 감소)
- 초기 로드 시간: 3초 → 0.5초 (6배 빠름)
- 차트 표시 시 추가 로드: ~500KB (병렬 로드 가능)

**참고:**
- React Documentation: [Code-Splitting](https://react.dev/reference/react/lazy)
- Vite Guide: [Code Splitting](https://vitejs.dev/guide/features.html#code-splitting)

**영향도:**
- 크기: HIGH (초기 번들 1-3MB 감소)
- 초기 로드 시간: HIGH (2-6배 빠름)
- UX: POSITIVE (페이지 즉시 표시)
