# Docs Refactor - Agent Coordination

문서 리팩토링 에이전트 활용.

---

<agents_reference>

@../../instructions/multi-agent/agent-roster.md
@../../instructions/multi-agent/coordination-guide.md
@../../instructions/multi-agent/execution-patterns.md

</agents_reference>

---

<recommended_agents>

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **document-writer** | sonnet | 리팩토링, 구조 개선, 토큰 최적화 |
| **analyst** | sonnet | 중복 식별, 개선점 도출 |
| **code-reviewer** | opus | 품질 검증, Before/After 비교 |

</recommended_agents>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1-3: 기본 조정

| 패턴 | 실행 |
|------|------|
| **병렬 분석** | 여러 analyst → 각 문서 동시 분석 |
| **분석→리팩→검증** | analyst → document-writer → code-reviewer |
| **병렬 리팩토링** | 여러 document-writer → 독립 문서 동시 개선 |

```typescript
// 병렬 분석
Task(subagent_type="analyst", model="sonnet", prompt="CLAUDE.md: 중복, 장황 식별")
Task(subagent_type="analyst", model="sonnet", prompt="SKILL.md: 토큰 효율 분석")

// 분석→리팩→검증
Task(subagent_type="analyst", model="sonnet", prompt="문서 분석")
Task(subagent_type="document-writer", model="sonnet", prompt="분석 기반 리팩토링")
Task(subagent_type="code-reviewer", model="opus", prompt="Before/After 검증")
```

---

### 패턴 4: @imports 추출

**핵심:** 중복 제거 및 70-80% 토큰 절감

```typescript
// 1. 중복 식별
Task(subagent_type="analyst", model="sonnet", prompt="여러 문서 중복 식별")

// 2. 공통 파일 작성 + 원본 리팩토링 (병렬)
Task(subagent_type="document-writer", model="sonnet", prompt="instructions/git-rules.md 작성")
Task(subagent_type="document-writer", model="sonnet", prompt="CLAUDE.md: @imports 참조로 교체")
Task(subagent_type="document-writer", model="sonnet", prompt="SKILL.md: @imports 참조로 교체")
```

**추출 대상 예시:**

| 중복 내용 | 공통 파일 | 참조 문서 |
|-----------|----------|-----------|
| Git 규칙 | `instructions/git-rules.md` | CLAUDE.md, SKILL.md |
| 타입 규칙 | `instructions/typescript-rules.md` | CLAUDE.md, 여러 SKILL.md |
| 라이브러리 패턴 | `docs/library/[lib]/patterns.md` | CLAUDE.md |

</coordination_patterns>

---

<model_routing>

@../docs-creator/AGENTS.md#model_routing

| 작업 | 모델 |
|------|------|
| 문서 분석 | sonnet |
| 리팩토링 | sonnet |
| 품질 검증 | opus |

</model_routing>

---

<practical_examples>

## 실전 예시

### 대규모 리팩토링

```typescript
// Phase 1: 병렬 분석
Task(subagent_type="analyst", model="sonnet", prompt="CLAUDE.md: 중복, 장황 식별")
Task(subagent_type="analyst", model="sonnet", prompt="SKILL.md: 토큰 효율 분석")

// Phase 2: 병렬 리팩토링
Task(subagent_type="document-writer", model="sonnet", prompt="CLAUDE.md: @imports, 표 형식")
Task(subagent_type="document-writer", model="sonnet", prompt="SKILL.md: 코드 중심, 설명 제거")

// Phase 3: 검증
Task(subagent_type="code-reviewer", model="opus", prompt="토큰 50% 감소 확인")
```

---

### @imports 중복 제거

```typescript
// Step 1: 중복 분석
Task(subagent_type="analyst", model="sonnet", prompt="Git 규칙 중복 분석")

// Step 2: 공통 파일 + 리팩토링 (병렬)
Task(subagent_type="document-writer", model="sonnet", prompt="instructions/git-rules.md 작성")
Task(subagent_type="document-writer", model="sonnet", prompt="CLAUDE.md: @imports 참조")
Task(subagent_type="document-writer", model="sonnet", prompt="SKILL.md: @imports 참조")
```

</practical_examples>

---

<best_practices>

| 항목 | 액션 |
|------|------|
| **여러 문서** | 병렬 analyst + document-writer |
| **중복 발견** | @imports 분리 (패턴 4) |
| **토큰 500줄+** | 우선 리팩토링 |
| **품질 중요** | code-reviewer 검증 필수 |
| **독립 문서** | 병렬 리팩토링 |
| **정보 보존** | 토큰 절감보다 우선 |

**목표:** Before 500줄+ → After 250줄- (50%+ 절감)

</best_practices>
