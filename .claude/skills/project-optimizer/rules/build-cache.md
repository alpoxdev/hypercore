---
title: Leverage Build Cache in CI and Local
impact: HIGH
impactDescription: 40-80% CI pipeline time reduction
tags: build, cache, ci, pipeline
languages: all
related: [build-incremental, dx-ci-speed]
---

## 빌드 캐시 활용

CI와 로컬 환경에서 빌드 아티팩트, 의존성, 컴파일 캐시를 재사용합니다.

**✅ GitHub Actions 캐시:**

```yaml
# Node.js
- uses: actions/cache@v4
  with:
    path: node_modules
    key: node-${{ hashFiles('yarn.lock') }}

# Rust
- uses: actions/cache@v4
  with:
    path: |
      ~/.cargo/registry
      ~/.cargo/git
      target
    key: rust-${{ hashFiles('Cargo.lock') }}

# Go
- uses: actions/cache@v4
  with:
    path: |
      ~/go/pkg/mod
      ~/.cache/go-build
    key: go-${{ hashFiles('go.sum') }}

# Python
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: pip-${{ hashFiles('requirements.txt') }}
```

**모노레포 캐시 도구:**

| 도구 | 특징 |
|------|------|
| **Turborepo** | 원격 캐시, 태스크 그래프 |
| **Nx** | 영향 받은 프로젝트만 빌드 |
| **Bazel** | 세밀한 캐시, 원격 실행 |
| **sccache** | Rust/C/C++ 컴파일 캐시 |
| **ccache** | C/C++ 컴파일 캐시 |

**핵심:** 캐시 키에 lockfile 해시 포함, 의존성 변경 시에만 캐시 무효화.
