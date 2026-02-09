---
title: Optimize CI Pipeline Speed
impact: MEDIUM
impactDescription: 30-70% CI time reduction
tags: dx, ci, pipeline, speed, cache
languages: all
related: [build-cache, build-incremental, dx-test-coverage]
---

## CI 파이프라인 속도 최적화

CI 파이프라인의 불필요한 단계를 제거하고 병렬화/캐싱을 적용합니다.

**최적화 전략:**

| 전략 | 효과 | 적용 |
|------|------|------|
| **의존성 캐시** | 50-80% 설치 시간 감소 | lockfile 해시 기반 캐시 키 |
| **병렬 단계** | 단계 수에 비례 감소 | lint, test, build 동시 실행 |
| **변경 파일만** | 대규모 모노레포에서 효과적 | `turbo run --filter=...` |
| **불필요 단계 제거** | 즉시 효과 | 중복 설치, 불필요 빌드 제거 |

```yaml
# GitHub Actions - 병렬 + 캐시
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/cache@v4
        with: { path: node_modules, key: deps-${{ hashFiles('yarn.lock') }} }
      - run: yarn lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/cache@v4
        with: { path: node_modules, key: deps-${{ hashFiles('yarn.lock') }} }
      - run: yarn test

  build:
    runs-on: ubuntu-latest
    needs: [lint, test]  # lint/test 병렬 후 build
    steps:
      - run: yarn build
```

**모노레포:** Turborepo `--filter=[HEAD^1]`, Nx `affected:test`.
