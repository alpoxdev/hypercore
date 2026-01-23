# Docs Refactor - Agent Coordination

문서 리팩토링 스킬에서 에이전트 활용 가이드.

---

<agents_reference>

전체 에이전트 조정 가이드: @../../PARALLEL_AGENTS.md

</agents_reference>

---

<recommended_agents>

## 추천 에이전트

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **document-writer** | sonnet | 문서 리팩토링, 구조 개선, 토큰 최적화 |
| **analyst** | sonnet | 문서 분석, 중복 식별, 개선점 도출 |
| **code-reviewer** | opus | 리팩토링 품질 검증, Before/After 비교 |
| **explore** | haiku | 여러 문서 병렬 분석 |

</recommended_agents>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1: 병렬 문서 분석

**용도:** 여러 문서의 개선점을 동시에 분석

```typescript
// CLAUDE.md, SKILL.md, README.md 동시 분석
Task(
  subagent_type="analyst",
  model="sonnet",
  prompt="CLAUDE.md 분석: 중복, 장황한 설명, XML 태그 누락 확인"
)

Task(
  subagent_type="analyst",
  model="sonnet",
  prompt="SKILL.md 분석: 토큰 효율, 예시 품질 검토"
)

Task(
  subagent_type="analyst",
  model="sonnet",
  prompt="README.md 분석: 불필요한 섹션, 구조 개선점"
)
```

**효과:** 순차 분석 대비 3배 빠름

---

### 패턴 2: 분석 → 리팩토링 → 검증

**용도:** 고품질 리팩토링

```typescript
// Step 1: 문서 분석
Task(
  subagent_type="analyst",
  model="sonnet",
  prompt="CLAUDE.md 분석: 중복, 토큰 효율, 구조 문제 식별"
)

// Step 2: 리팩토링 실행
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="분석 결과 기반 CLAUDE.md 리팩토링: 표 형식, @imports 분리"
)

// Step 3: 품질 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="Before/After 비교: 토큰 50% 감소 확인, 정보 보존 검증"
)
```

---

### 패턴 3: 병렬 리팩토링

**용도:** 독립적인 문서 동시 개선

```typescript
// 여러 문서 동시 리팩토링
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="CLAUDE.md 리팩토링: @imports 분리, tech_stack 표 형식"
)

Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="SKILL.md 리팩토링: 설명 제거, 코드 예시 중심"
)

Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="README.md 리팩토링: 간결화, 필수 정보만 유지"
)
```

---

### 패턴 4: @imports 추출 전략

**용도:** 중복 제거 및 토큰 절감

```typescript
// Step 1: 중복 내용 식별
Task(
  subagent_type="analyst",
  model="sonnet",
  prompt="여러 문서에서 반복되는 Git 규칙, 타입 규칙 식별"
)

// Step 2: 공통 파일 작성 + 원본 문서 리팩토링 (병렬)
Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="instructions/git-rules.md 작성: Git 규칙 통합"
)

Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="CLAUDE.md 리팩토링: @instructions/git-rules.md 참조"
)

Task(
  subagent_type="document-writer",
  model="sonnet",
  prompt="SKILL.md 리팩토링: @instructions/git-rules.md 참조"
)
```

**효과:** 70-80% 토큰 절감

</coordination_patterns>

---

<model_routing>

## 모델 라우팅

| 작업 | 모델 | 이유 |
|------|------|------|
| **문서 분석** | sonnet | 중복, 구조 문제 식별 |
| **간단한 리팩토링** | sonnet | 표 형식 변환, 설명 제거 |
| **복잡한 리팩토링** | sonnet | @imports 분리, XML 태그 구조화 |
| **품질 검증** | opus | Before/After 비교, 정보 보존 확인 |

</model_routing>

---

<practical_examples>

## 실전 예시

### 예시 1: 대규모 문서 리팩토링

```typescript
// Phase 1: 병렬 분석
Task(subagent_type="analyst", model="sonnet",
     prompt="CLAUDE.md: 중복, 장황한 설명 식별")
Task(subagent_type="analyst", model="sonnet",
     prompt="SKILL.md: 토큰 효율 분석")
Task(subagent_type="analyst", model="sonnet",
     prompt="README.md: 불필요한 섹션 식별")

// Phase 2: 병렬 리팩토링
Task(subagent_type="document-writer", model="sonnet",
     prompt="CLAUDE.md 리팩토링: @imports 분리, 표 형식")
Task(subagent_type="document-writer", model="sonnet",
     prompt="SKILL.md 리팩토링: 코드 중심, 설명 제거")
Task(subagent_type="document-writer", model="sonnet",
     prompt="README.md 리팩토링: 간결화")

// Phase 3: 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="전체 문서 토큰 50% 감소 확인, 정보 보존 검증")
```

---

### 예시 2: @imports 중복 제거

```typescript
// Step 1: 중복 분석
Task(subagent_type="analyst", model="sonnet",
     prompt="Git 규칙 중복 분석: CLAUDE.md, SKILL.md 비교")

// Step 2: 공통 파일 + 리팩토링 (병렬)
Task(subagent_type="document-writer", model="sonnet",
     prompt="instructions/git-rules.md 작성")
Task(subagent_type="document-writer", model="sonnet",
     prompt="CLAUDE.md: @instructions/git-rules.md 참조")
Task(subagent_type="document-writer", model="sonnet",
     prompt="SKILL.md: @instructions/git-rules.md 참조")
```

---

### 예시 3: 토큰 최적화 집중

```typescript
// Step 1: 분석
Task(subagent_type="analyst", model="sonnet",
     prompt="CLAUDE.md 토큰 분석: 장황한 설명, 반복 표현")

// Step 2: 리팩토링
Task(subagent_type="document-writer", model="sonnet",
     prompt="표 형식 변환, 단어 최적화, 코드 중심")

// Step 3: 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="Before 650 토큰 → After 280 토큰 확인")
```

</practical_examples>

---

<best_practices>

## 모범 사례

### 작업 시작 전 체크

- [ ] 여러 문서 리팩토링? → 병렬 analyst + document-writer
- [ ] 중복 내용 있는가? → @imports 분리 전략
- [ ] 토큰 500줄 초과? → 우선 리팩토링
- [ ] 품질 중요한가? → code-reviewer 검증 필수

### 에이전트 활용 원칙

**DO:**
- 독립 문서 → 병렬 리팩토링
- 중복 발견 → @imports 분리 (병렬)
- 토큰 최적화 → sonnet 사용
- 검증 필수 → opus로 Before/After 확인

**DON'T:**
- 정보 손실 (토큰 절감보다 정보 우선)
- 검증 없이 완료
- 순차 리팩토링 (병렬 가능한 경우)

### 토큰 절감 목표

| Before | After | 절감률 |
|--------|-------|--------|
| 500줄+ | 250줄- | 50%+ |

</best_practices>
