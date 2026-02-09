---
title: Enable Incremental Builds
impact: CRITICAL
impactDescription: 50-90% build time reduction on repeat builds
tags: build, incremental, cache, compile
languages: all
related: [build-cache, dx-ci-speed]
---

## 증분 빌드 활성화

전체 재빌드 대신 변경된 파일만 컴파일하여 빌드 시간을 대폭 줄입니다.

**❌ 잘못된 예시 (매번 전체 빌드):**

```json
// tsconfig.json - incremental 비활성화
{ "compilerOptions": { "incremental": false } }
```

```toml
# Cargo.toml - release에서 증분 비활성화
[profile.release]
incremental = false
```

**✅ 올바른 예시:**

```json
// TypeScript
{ "compilerOptions": { "incremental": true, "tsBuildInfoFile": ".tsbuildinfo" } }
```

```toml
# Rust
[profile.dev]
incremental = true
```

```python
# Python (mypy)
[tool.mypy]
incremental = true
cache_dir = ".mypy_cache"
```

```gradle
// Gradle
org.gradle.caching=true
org.gradle.parallel=true
```

```yaml
# CI 캐시 (GitHub Actions)
- uses: actions/cache@v4
  with:
    path: |
      node_modules/.cache
      .tsbuildinfo
      target/
      ~/.cargo/registry
    key: ${{ runner.os }}-build-${{ hashFiles('**/lockfile') }}
```

**효과:** TypeScript 50-70% 감소, Rust dev 40-60% 감소, Gradle 30-50% 감소.
