---
title: Ensure Test Coverage on Critical Paths
impact: MEDIUM
impactDescription: Confidence in refactoring, catches regressions
tags: dx, test, coverage, critical-path
languages: all
related: [code-error-handling, dx-ci-speed]
---

## 핵심 로직 테스트 커버리지 확보

100% 커버리지보다 핵심 비즈니스 로직의 높은 커버리지가 중요합니다.

**우선순위:**

| 우선순위 | 대상 | 이유 |
|---------|------|------|
| **1** | 비즈니스 로직/도메인 | 변경 빈도 높음, 버그 영향 큼 |
| **2** | 데이터 변환/파싱 | 엣지 케이스 많음 |
| **3** | API 엔드포인트 | 외부 계약 |
| **4** | 에러 처리 경로 | 간과하기 쉬움 |
| LOW | UI 컴포넌트 렌더링 | 자주 변경, ROI 낮음 |
| LOW | 외부 서비스 호출 | Mock 필요, 깨지기 쉬움 |

**테스트 도구 (2026):**

| 언어 | 도구 | 특징 |
|------|------|------|
| **JS/TS** | Vitest | Vite 통합, ESM 네이티브, 빠름 |
| **Python** | pytest | 풍부한 에코시스템 |
| **Go** | testing (내장) | `go test -cover` |
| **Rust** | cargo test (내장) | `cargo tarpaulin` (커버리지) |

**목표:** 핵심 로직 80%+, 전체 60%+ (프로젝트 성격에 따라 조정).
