---
title: Remove Dead Code and Unused Imports
impact: MEDIUM-HIGH
impactDescription: Cleaner codebase, smaller bundles, faster comprehension
tags: code, dead-code, unused, imports, cleanup
languages: all
related: [build-tree-shake, deps-unused-removal]
---

## 미사용 코드/변수/import 제거

사용되지 않는 코드는 혼란을 주고 번들 크기를 증가시킵니다. 도구로 감지하고 즉시 제거합니다.

**감지 도구:**

| 언어 | 도구 | 명령어 |
|------|------|--------|
| **JS/TS** | `knip` | `npx knip` |
| **JS/TS** | ESLint `no-unused-vars` | 자동 |
| **Python** | `vulture` | `vulture src/` |
| **Python** | `autoflake` | `autoflake --remove-all-unused-imports` |
| **Go** | 컴파일러 (내장) | 미사용 import/변수 = 컴파일 에러 |
| **Rust** | 컴파일러 (내장) | `#[warn(dead_code)]` 기본 활성화 |
| **Java** | IntelliJ / SonarQube | 자동 감지 |

**제거 대상:**
- 미사용 import/require
- 미사용 변수/상수
- 호출되지 않는 함수/메서드
- 도달 불가능한 코드 (unreachable after return/throw)
- 주석 처리된 코드 블록 (Git 히스토리에 보존됨)
- 미사용 타입/인터페이스 정의
