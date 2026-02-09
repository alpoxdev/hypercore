---
title: Speed Up Local Development Server
impact: MEDIUM
impactDescription: Faster feedback loop, improved developer productivity
tags: dx, dev-server, hmr, startup, watch
languages: [js, ts, go, python, rust]
related: [build-incremental, dx-ci-speed]
---

## 로컬 개발 서버 시작 속도 개선

개발 서버 시작 시간과 HMR(Hot Module Replacement) 속도를 최적화합니다.

**프론트엔드:**

| 도구 | 팁 |
|------|-----|
| **Vite** | 이미 빠름. `server.warmup` 활성화, `optimizeDeps.include` 프리번들링 |
| **webpack** | Vite/Turbopack으로 마이그레이션 고려 |
| **Next.js** | Turbopack (`next dev --turbo`) |

**백엔드:**

| 언어 | 도구 | 설정 |
|------|------|------|
| **Node.js** | `tsx --watch` | 네이티브 ESM, 즉시 시작 |
| **Go** | `air` | `.air.toml` 설정 |
| **Python** | `uvicorn --reload` | FastAPI 기본 |
| **Rust** | `cargo-watch` | `cargo watch -x run` |

**공통 개선:**

- TypeScript: `tsconfig.json`에서 `skipLibCheck: true` (개발 시)
- 불필요 플러그인 비활성화 (개발 시 린팅 플러그인 분리)
- `.gitignore`/`watchignore`에 빌드 출력 디렉토리 추가
