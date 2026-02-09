---
title: Optimize Linter and Formatter Configuration
impact: MEDIUM
impactDescription: Consistent code style, faster feedback loop
tags: dx, lint, format, eslint, prettier, biome, ruff
languages: all
related: [dx-type-safety, code-complexity]
---

## 린터/포매터 최적 설정

프로젝트에 맞는 린터/포매터를 설정하여 일관된 코드 스타일과 빠른 피드백을 보장합니다.

**언어별 권장 도구 (2026):**

| 언어 | 린터 | 포매터 | 비고 |
|------|------|--------|------|
| **JS/TS** | ESLint 9 (flat config) | Prettier 또는 Biome | Biome = lint+format 올인원 |
| **Python** | Ruff | Ruff (format) | flake8+isort+black 100x 빠른 대체 |
| **Go** | go vet + staticcheck | gofmt (내장) | |
| **Rust** | clippy | rustfmt (내장) | |
| **Java** | SpotBugs / Error Prone | google-java-format | |

**빠른 피드백을 위한 설정:**

```json
// lint-staged (Git 커밋 시 변경 파일만)
{
  "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.py": ["ruff check --fix", "ruff format"],
  "*.go": ["gofmt -w"],
  "*.rs": ["rustfmt"]
}
```

**원칙:** 전체 프로젝트 린트는 CI에서, 로컬은 변경 파일만 (lint-staged).
