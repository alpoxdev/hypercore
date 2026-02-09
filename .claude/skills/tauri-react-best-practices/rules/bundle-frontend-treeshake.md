---
title: Frontend Tree-Shaking Verification
impact: MEDIUM
impactDescription: removes unused code from bundle
tags: bundle, tree-shaking, vite, optimization, frontend
---

# 프론트엔드 Tree-Shaking 확인

## 왜 중요한가

Tree-shaking은 **사용하지 않는 코드를 번들에서 자동으로 제거**하는 최적화 기법입니다. 하지만 **side effect가 있는 import**나 **default export**를 사용하면 tree-shaking이 작동하지 않아 불필요한 코드가 번들에 포함됩니다.

## ❌ 잘못된 패턴

**Side effect가 있는 import (전체 모듈 번들링):**

```typescript
// ❌ lodash 전체 (~500KB)가 번들에 포함
import _ from 'lodash'

function App() {
  const result = _.chunk([1, 2, 3, 4], 2)
  // chunk 함수만 사용하지만 전체 라이브러리 포함
}
```

**Default export 사용 (tree-shaking 불가):**

```typescript
// ❌ utils.ts
export default {
  add: (a: number, b: number) => a + b,
  subtract: (a: number, b: number) => a - b,
  multiply: (a: number, b: number) => a * b,
  divide: (a: number, b: number) => a / b
}

// App.tsx
import utils from './utils'

function App() {
  const sum = utils.add(1, 2) // add만 사용해도 전체 객체 포함
}
```

**package.json에 sideEffects 설정 없음:**

```json
{
  "name": "my-app",
  "version": "1.0.0"
  // sideEffects 설정 없음 - bundler가 안전하게 제거 못함
}
```

## ✅ 올바른 패턴

**Named export + 직접 import로 tree-shaking 활성화:**

```typescript
// ✅ 필요한 함수만 번들에 포함 (~5KB)
import { chunk } from 'lodash-es'

function App() {
  const result = chunk([1, 2, 3, 4], 2)
  // chunk 함수만 번들에 포함
}
```

**Named export 사용 (tree-shaking 가능):**

```typescript
// ✅ utils.ts
export const add = (a: number, b: number) => a + b
export const subtract = (a: number, b: number) => a - b
export const multiply = (a: number, b: number) => a * b
export const divide = (a: number, b: number) => a / b

// App.tsx
import { add } from './utils'

function App() {
  const sum = add(1, 2) // add만 번들에 포함
}
```

**package.json에 sideEffects 명시:**

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "sideEffects": false
}
```

**CSS import가 있는 경우:**

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "sideEffects": [
    "*.css",
    "*.scss"
  ]
}
```

**Vite 설정으로 tree-shaking 강화:**

```typescript
// vite.config.ts
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    // minify를 활성화하여 dead code 제거
    minify: 'terser',
    terserOptions: {
      compress: {
        // 사용하지 않는 코드 제거
        dead_code: true,
        drop_console: true, // console.log 제거
        drop_debugger: true, // debugger 제거
        pure_funcs: ['console.log', 'console.info'] // 특정 함수 제거
      }
    },
    rollupOptions: {
      treeshake: {
        // aggressive tree-shaking
        moduleSideEffects: 'no-external',
        preset: 'smallest'
      }
    }
  }
})
```

**번들 분석으로 tree-shaking 확인:**

```bash
# Vite Bundle Visualizer 설치
npm install -D rollup-plugin-visualizer
```

```typescript
// vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    visualizer({
      open: true,
      gzipSize: true,
      brotliSize: true,
      template: 'treemap' // or 'sunburst', 'network'
    })
  ]
})
```

```bash
# 빌드 후 자동으로 stats.html 열림
npm run build
```

## 추가 컨텍스트

**Tree-shaking 작동 조건:**

| 조건 | 설명 |
|------|------|
| **ESM** | ES Module (import/export) 사용 필수 |
| **Named Export** | default export 대신 named export |
| **No Side Effects** | package.json에 sideEffects: false |
| **Static Analysis** | 동적 import는 tree-shaking 불가 |

**라이브러리별 tree-shaking 지원:**

| 라이브러리 | CommonJS | ESM | Tree-shakable | 대안 |
|-----------|----------|-----|---------------|------|
| `lodash` | ✅ | ❌ | ❌ | `lodash-es` 사용 |
| `lodash-es` | ❌ | ✅ | ✅ | - |
| `moment` | ✅ | ❌ | ❌ | `date-fns` 또는 `dayjs` |
| `date-fns` | ❌ | ✅ | ✅ | - |
| `axios` | ✅ | ✅ | ⚠️ | 전체 번들 (~20KB) |
| `ky` | ❌ | ✅ | ✅ | axios 대안 (~5KB) |

**Side effect가 있는 코드 예시:**

```typescript
// ❌ Side effect 있음 - tree-shaking 불가
export const API_URL = 'https://api.example.com'
console.log('API initialized') // 부수 효과!

export function fetchData() {
  return fetch(API_URL)
}
```

```typescript
// ✅ Side effect 없음 - tree-shaking 가능
export const API_URL = 'https://api.example.com'

export function fetchData() {
  return fetch(API_URL)
}
```

**동적 import vs 정적 import:**

```typescript
// ✅ 정적 import - tree-shaking 가능
import { chunk } from 'lodash-es'

// ❌ 동적 import - tree-shaking 불가
const { chunk } = await import('lodash-es')
```

**Rollup 플러그인 확인 (Vite 내부 사용):**

```bash
# Vite는 내부적으로 Rollup 사용
# tree-shaking은 Rollup의 기본 기능
```

**효과:**
- lodash → lodash-es: 500KB → 5KB (100배 감소)
- moment → date-fns: 300KB → 20KB (15배 감소)
- 전체 프로젝트: 평균 10-30% 번들 크기 감소

**참고:**
- Vite Tree-shaking: [Build Optimizations](https://vitejs.dev/guide/features.html#build-optimizations)
- Webpack Tree-shaking: [Documentation](https://webpack.js.org/guides/tree-shaking/)
- Rollup Tree-shaking: [Guide](https://rollupjs.org/guide/en/#tree-shaking)

**영향도:**
- 크기: MEDIUM (10-30% 감소)
- 빌드 시간: NEUTRAL
- 런타임 성능: POSITIVE (작은 번들 = 빠른 로드)
