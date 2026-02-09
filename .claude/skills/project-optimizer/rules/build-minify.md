---
title: Minify and Compress Production Output
impact: HIGH
impactDescription: 30-50% output size reduction
tags: build, minify, compression, production
languages: [js, ts, css]
related: [build-tree-shake, build-code-split]
---

## 프로덕션 출력 최소화

프로덕션 빌드에서 minification, compression을 활성화하여 배포 크기를 줄입니다.

**✅ 올바른 예시:**

```typescript
// Vite
export default defineConfig({
  build: {
    minify: 'terser',  // 또는 'esbuild' (빠름)
    cssMinify: true,
    rollupOptions: {
      output: { manualChunks: { vendor: ['react', 'react-dom'] } }
    }
  }
})
```

```toml
# Rust
[profile.release]
opt-level = "z"       # 크기 최적화 (또는 "3" 속도 최적화)
lto = "thin"          # LTO
strip = "symbols"
panic = "abort"       # unwind 코드 제거
codegen-units = 1     # 최적화 극대화 (빌드 느려짐)
```

```go
// Go
// go build -ldflags="-s -w" -trimpath ./cmd/app
// -s: 심볼 테이블 제거, -w: DWARF 제거, -trimpath: 경로 정보 제거
```

```dockerfile
# Docker 멀티스테이지 빌드
FROM golang:1.22 AS builder
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /app

FROM scratch
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
```

**서버 압축:**

| 방법 | 감소율 | 도구 |
|------|--------|------|
| gzip | ~70% | Nginx, CDN 기본 |
| Brotli | ~80% | Nginx, Cloudflare |
| 빌드 시 사전 압축 | 서버 CPU 절약 | `vite-plugin-compression` |
