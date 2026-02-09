---
title: Remove Unused Dependencies
impact: MEDIUM
impactDescription: Smaller install size, fewer vulnerabilities, faster CI
tags: deps, unused, cleanup, audit
languages: all
related: [build-tree-shake, code-dead-elimination]
---

## 미사용 의존성 제거

설치되었지만 코드에서 import/require 되지 않는 패키지를 제거합니다.

**감지 도구:**

| 언어 | 도구 | 명령어 |
|------|------|--------|
| **JS/TS** | knip | `npx knip` |
| **JS/TS** | depcheck | `npx depcheck` |
| **Python** | deptry | `deptry .` |
| **Go** | go mod tidy | `go mod tidy` (자동 정리) |
| **Rust** | cargo-udeps | `cargo +nightly udeps` |
| **Java** | gradle-dependency-analysis | Gradle 플러그인 |

**주의:** devDependencies (빌드/테스트 도구)는 코드에서 직접 import하지 않아도 필요할 수 있음. 빌드 확인 후 제거.
