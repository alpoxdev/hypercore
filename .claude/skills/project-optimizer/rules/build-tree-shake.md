---
title: Enable Tree Shaking / Dead Code Elimination
impact: CRITICAL
impactDescription: 20-60% bundle size reduction
tags: build, tree-shaking, dead-code, bundle-size
languages: [js, ts, rust, go]
related: [build-code-split, code-dead-elimination, deps-unused-removal]
---

## 미사용 코드 자동 제거

번들러/컴파일러의 dead code elimination을 활성화하여 실제 사용하는 코드만 출력에 포함합니다.

**❌ 잘못된 예시:**

```json
// package.json - sideEffects 미지정
{ "name": "my-lib" }
// 번들러가 어떤 코드가 부작용 있는지 몰라서 전부 포함
```

```typescript
// 배럴 파일에서 전체 import
import { oneUtil } from './utils'  // utils/index.ts가 50개 모듈 re-export
```

**✅ 올바른 예시:**

```json
// package.json - sideEffects 지정
{ "name": "my-lib", "sideEffects": false }
// 또는 특정 파일만: "sideEffects": ["*.css", "./src/polyfill.js"]
```

```typescript
// 직접 import (배럴 파일 우회)
import { oneUtil } from './utils/oneUtil'
```

```toml
# Rust - release 최적화
[profile.release]
lto = "thin"          # Link-Time Optimization
strip = "symbols"     # 심볼 제거
opt-level = "z"       # 크기 최적화
```

```go
// Go - 기본 활성화. 추가 최적화:
// go build -ldflags="-s -w"  # 심볼 테이블, DWARF 디버그 정보 제거
```

**도구별 설정:**

| 빌드 도구 | 설정 |
|-----------|------|
| Vite/Rollup | 기본 활성화 (`build.rollupOptions`) |
| webpack | `mode: 'production'`, `usedExports: true` |
| esbuild | `--tree-shaking=true` (기본) |
| tsup | `treeshake: true` |
