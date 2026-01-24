# Docs Creator - Agent Coordination

문서 작성 스킬에서 에이전트 활용 가이드.

---

<agents_reference>

다중 에이전트 구조:
- 에이전트 목록: @../../instructions/multi-agent/agent-roster.md
- 조정 가이드: @../../instructions/multi-agent/coordination-guide.md
- 실행 패턴: @../../instructions/multi-agent/execution-patterns.md

</agents_reference>

---

<recommended_agents>

## 추천 에이전트

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **document-writer** | haiku/sonnet | 문서 작성, README, 주석, 기술 문서 |
| **explore** | haiku | 코드베이스 구조 파악, 기존 패턴 분석 |
| **analyst** | sonnet | 프로젝트 요구사항 분석, 패턴 도출 |
| **code-reviewer** | opus | 문서 품질 검증, 정확성 검토 |

</recommended_agents>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1: 병렬 문서 작성

**용도:** 여러 문서를 동시에 작성

```typescript
// CLAUDE.md, SKILL.md, README.md 동시 작성
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="CLAUDE.md 작성: 프로젝트 규칙 및 금지/필수 사항"
)

Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="README.md 작성: 설치 및 빠른 시작 가이드"
)

Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="CONTRIBUTING.md 작성: 기여 가이드"
)
```

**효과:** 순차 실행 대비 3배 빠름

---

### 패턴 2: 탐색 → 문서화 파이프라인

**용도:** 기존 프로젝트 문서화

```typescript
// Step 1: 구조 분석
Task(
  subagent_type="explore",
  model="haiku",
  prompt="프로젝트 구조, 기술 스택, 주요 패턴 분석"
)

// Step 2: 분석 결과 바탕 문서 작성
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="분석 결과 기반 CLAUDE.md 작성"
)
```

---

### 패턴 3: 작성 → 검증 → 개선

**용도:** 고품질 문서 생성

```typescript
// Step 1: 문서 작성
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="SKILL.md 작성: workflow, examples 포함"
)

// Step 2: 품질 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="SKILL.md 검증: 명확성, 실행 가능성, 예시 품질"
)

// Step 3: 피드백 반영 개선
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="code-reviewer 피드백 반영하여 SKILL.md 개선"
)
```

---

### 패턴 4: 다국어 문서 병렬 작성

**용도:** 한/영 동시 문서화

```typescript
// 한국어/영어 문서 동시 작성
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="한국어 문서 작성: docs/ko/guide.md"
)

Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="영어 문서 작성: docs/en/guide.md"
)
```

</coordination_patterns>

---

<model_routing>

## 모델 라우팅

| 작업 | 모델 | 이유 |
|------|------|------|
| **README, 설치 가이드** | haiku | 간단한 구조, 빠른 작성 |
| **CLAUDE.md, SKILL.md** | sonnet | 복잡한 구조, XML 태그 필요 |
| **아키텍처 문서** | opus | 깊은 분석, 설계 패턴 설명 |
| **문서 품질 검증** | opus | 정확성, 일관성 검토 |

</model_routing>

---

<practical_examples>

## 실전 예시

### 예시 1: 새 프로젝트 문서화

```typescript
// Phase 1: 병렬 탐색
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 구조 분석")
Task(subagent_type="explore", model="haiku",
     prompt="기술 스택 및 버전 확인")

// Phase 2: 병렬 문서 작성
Task(subagent_type="document-writer", model="sonnet",
     prompt="CLAUDE.md: 프로젝트 규칙, 금지/필수 사항")
Task(subagent_type="document-writer", model="haiku",
     prompt="README.md: 빠른 시작, 설치 가이드")
Task(subagent_type="document-writer", model="haiku",
     prompt="CONTRIBUTING.md: 기여 방법")

// Phase 3: 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="문서 품질 검증: 명확성, 실행 가능성")
```

---

### 예시 2: API 문서 작성

```typescript
// 여러 API 엔드포인트 문서 동시 작성
Task(subagent_type="document-writer", model="haiku",
     prompt="docs/api/users.md: User API 문서")
Task(subagent_type="document-writer", model="haiku",
     prompt="docs/api/posts.md: Post API 문서")
Task(subagent_type="document-writer", model="haiku",
     prompt="docs/api/comments.md: Comment API 문서")
```

---

### 예시 3: 스킬 문서 작성

```typescript
// Step 1: 스킬 분석
Task(subagent_type="analyst", model="sonnet",
     prompt="스킬 요구사항 분석 및 구조 도출")

// Step 2: 문서 작성
Task(subagent_type="document-writer", model="sonnet",
     prompt="SKILL.md 작성: trigger, workflow, examples")

// Step 3: 검증 및 개선
Task(subagent_type="code-reviewer", model="opus",
     prompt="SKILL.md 검증 및 개선사항 제안")
```

</practical_examples>

---

<best_practices>

## 모범 사례

### 작업 시작 전 체크

- [ ] 여러 문서를 작성하는가? → 병렬 document-writer
- [ ] 기존 프로젝트인가? → explore 먼저, 그 후 문서화
- [ ] 복잡한 구조인가? → sonnet/opus 모델 사용
- [ ] 다국어 필요한가? → 병렬 작성

### 에이전트 활용 원칙

**DO:**
- 독립 문서 → 병렬 작성
- 복잡한 문서 → sonnet/opus
- 품질 중요 → code-reviewer 검증
- 대량 문서 → haiku로 빠르게

**DON'T:**
- 간단한 문서에 opus 사용
- 순차 작성 (병렬 가능한 경우)
- 검증 없이 완료

</best_practices>
