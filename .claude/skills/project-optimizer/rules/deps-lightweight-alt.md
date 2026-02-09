---
title: Replace Heavy Libraries with Lightweight Alternatives
impact: MEDIUM
impactDescription: 30-80% bundle/install size reduction
tags: deps, lightweight, alternative, bundle-size
languages: all
related: [build-tree-shake, build-minify]
---

## 무거운 라이브러리 경량 대안으로 교체

사용 기능 대비 과도하게 큰 라이브러리를 경량 대안 또는 네이티브 API로 교체합니다.

**흔한 교체 대상:**

| 무거운 라이브러리 | 경량 대안 | 크기 감소 |
|-----------------|----------|----------|
| `moment.js` (300KB) | `date-fns` 또는 `dayjs` (2-7KB) | 97% |
| `lodash` (72KB) | 네이티브 JS 메서드 / `lodash-es` 직접 import | 90%+ |
| `axios` (29KB) | `fetch` (내장) / `ky` (3KB) | 90% |
| `uuid` (12KB) | `crypto.randomUUID()` (내장) | 100% |
| `chalk` (20KB) | `picocolors` (2KB) | 90% |
| `express` | `h3` / `Hono` (더 빠르고 작음) | 50%+ |

**Python:**

| 무거운 | 경량 대안 |
|-------|----------|
| `requests` | `httpx` (async 지원) |
| `beautifulsoup4` | `selectolax` (10x 빠름) |
| `pandas` (작은 작업) | `polars` (메모리 효율) |
| `flake8+isort+black` | `ruff` (100x 빠름, 올인원) |

**판단 기준:**
1. 사용하는 기능이 전체의 10% 미만 → 교체 고려
2. 네이티브 API로 대체 가능 → 교체
3. 번들 크기 50KB+ 차이 → 교체 고려
