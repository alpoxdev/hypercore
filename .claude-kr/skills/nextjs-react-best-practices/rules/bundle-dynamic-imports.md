---
title: Dynamic Imports for Heavy Components
impact: CRITICAL
impactDescription: directly affects TTI and LCP
tags: bundle, dynamic-import, code-splitting, next-dynamic
---

## 무거운 컴포넌트에 동적 임포트 사용

초기 렌더링에 필요하지 않은 대형 컴포넌트는 `next/dynamic`을 사용하여 지연 로드하세요.

**잘못된 예 (Monaco가 메인 청크와 함께 번들됨 ~300KB):**

```tsx
import { MonacoEditor } from './monaco-editor'

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}
```

**올바른 예 (Monaco가 온디맨드로 로드됨):**

```tsx
import dynamic from 'next/dynamic'

const MonacoEditor = dynamic(
  () => import('./monaco-editor').then(m => m.MonacoEditor),
  { ssr: false }
)

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}
```
