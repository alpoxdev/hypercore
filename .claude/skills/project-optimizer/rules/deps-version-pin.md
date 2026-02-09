---
title: Pin Production Dependency Versions
impact: MEDIUM
impactDescription: Reproducible builds, no surprise breakages
tags: deps, version, pin, lock, reproducible
languages: all
related: [deps-security-audit, deps-peer-align]
---

## 프로덕션 의존성 버전 고정

lockfile을 커밋하고 프로덕션 의존성은 정확한 버전으로 설치합니다.

**✅ 필수:**

| 파일 | 언어 | Git 커밋 |
|------|------|---------|
| `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` | JS/TS | 필수 |
| `Cargo.lock` | Rust (바이너리) | 필수 |
| `go.sum` | Go | 필수 |
| `poetry.lock` / `uv.lock` | Python | 필수 |
| `Gemfile.lock` | Ruby | 필수 |

**CI에서 lockfile 기반 설치:**

```bash
# npm
npm ci  # (npm install 아님!)

# yarn
yarn install --immutable

# pnpm
pnpm install --frozen-lockfile

# pip
pip install -r requirements.txt --no-deps
```

**원칙:** `npm install`/`yarn install`은 lockfile을 수정할 수 있으므로 CI에서는 `ci`/`--frozen-lockfile` 사용.
