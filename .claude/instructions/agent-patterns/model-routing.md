# Model Routing Guide

**목적**: 작업 복잡도에 따라 최적의 모델 선택

## 모델 선택 기준

| 모델 | 복잡도 | 비용 | 속도 | 사용 시점 |
|------|--------|------|------|----------|
| **haiku** | LOW | 💰 | 🚀🚀🚀 | 간단한 작업 |
| **sonnet** | MEDIUM | 💰💰 | 🚀🚀 | 일반 작업 (기본값) |
| **opus** | HIGH | 💰💰💰 | 🚀 | 복잡한 작업 |

## Haiku 사용 케이스

**특징**: 빠르고 저렴, 단순 작업에 최적

| 작업 유형 | 예시 |
|----------|------|
| 파일 탐색 | 코드베이스 구조 분석, 파일 찾기 |
| 간단한 문서 작성 | README, 상태 문서, 로그 |
| 번역 | 한글↔영어 문서 번역 |
| Git 작업 | 커밋, 푸시 (로직 없음) |
| 단순 검색 | Glob, Grep 작업 |

**복잡도 기준:**
- 1-3개 파일만 다룸
- 로직 변경 없음
- 단순 CRUD

**코드 예시:**
```typescript
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 구조 분석")

Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md 업데이트")

Task(subagent_type="git-operator", model="haiku",
     prompt="변경사항 커밋")
```

## Sonnet 사용 케이스

**특징**: 균형 잡힌 성능, 대부분의 작업에 적합

| 작업 유형 | 예시 |
|----------|------|
| 기능 구현 | 새 API 엔드포인트, 컴포넌트 |
| 버그 수정 | 로직 오류, 타입 에러 |
| 리팩토링 | 코드 구조 개선 |
| 코드 분석 | 성능 분석, 패턴 식별 |
| 테스트 작성 | 단위/통합 테스트 |

**복잡도 기준:**
- 4-10개 파일 수정
- 중간 복잡도 로직
- 일반적인 개발 작업

**코드 예시:**
```typescript
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User CRUD API 구현")

Task(subagent_type="designer", model="sonnet",
     prompt="로그인 폼 UI 구현")

Task(subagent_type="lint-fixer", model="sonnet",
     prompt="타입 에러 수정")
```

## Opus 사용 케이스

**특징**: 최고 성능, 복잡하고 중요한 작업

| 작업 유형 | 예시 |
|----------|------|
| 아키텍처 설계 | 시스템 구조 설계, 기술 선택 |
| 보안 검토 | 취약점 분석, 인증/인가 로직 |
| 복잡한 디버깅 | 다층 스택 이슈, 성능 문제 |
| 계획 검증 | 구현 계획 승인 (Planner) |
| 종합 코드 리뷰 | 품질, 보안, 성능 전체 검토 |

**복잡도 기준:**
- 10개 이상 파일 영향
- 아키텍처 수준 변경
- 보안/성능 중요

**코드 예시:**
```typescript
Task(subagent_type="planner", model="opus",
     prompt="인증 시스템 아키텍처 설계")

Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 취약점 전체 검토")

Task(subagent_type="architect", model="opus",
     prompt="DB 스키마 설계 분석")
```

## 복잡도 판단 플로우차트

```
작업 시작
    ↓
파일 수 확인
    ↓
1-3개? → haiku
4-10개? → sonnet
10개+? → opus
    ↓
로직 복잡도 확인
    ↓
단순 CRUD? → haiku
일반 로직? → sonnet
아키텍처? → opus
    ↓
중요도 확인
    ↓
보안/성능 중요? → opus
일반 기능? → sonnet
문서/탐색? → haiku
```

## 모델 전환 기준

| 상황 | 조치 |
|------|------|
| haiku로 시작했는데 복잡함 발견 | sonnet으로 재시도 |
| sonnet으로도 해결 안 됨 | opus로 에스컬레이션 |
| opus 필요했는데 haiku 사용 | 처음부터 다시 (opus) |

## 비용 최적화 전략

1. **탐색은 항상 haiku** (explore 에이전트)
2. **구현은 기본 sonnet** (implementation-executor)
3. **검증만 opus** (planner, code-reviewer)
4. **문서는 haiku** (document-writer)

**예상 비용 절감:** 40-60%

## Agent별 권장 모델

| Agent | 기본 모델 | 복잡할 때 |
|-------|----------|----------|
| explore | haiku | sonnet |
| implementation-executor | sonnet | opus |
| planner | opus | opus (항상) |
| code-reviewer | opus | opus (항상) |
| designer | sonnet | opus |
| document-writer | haiku | sonnet |
| git-operator | haiku | sonnet |
| lint-fixer | sonnet | sonnet |
| deployment-validator | sonnet | sonnet |
| architect | sonnet | opus |
| analyst | sonnet | opus |
| refactor-advisor | sonnet | opus |

## 체크리스트

에이전트 호출 전 확인:

- [ ] 파일 몇 개 다루는가?
- [ ] 로직 복잡도는?
- [ ] 보안/성능이 중요한가?
- [ ] 비용 대비 효과는?

**적절한 모델 선택 → 비용 절감 + 품질 향상**
