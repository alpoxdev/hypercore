# Docs Creator - Agent Coordination

<agents_reference>
@../../instructions/multi-agent/agent-roster.md
@../../instructions/multi-agent/coordination-guide.md
@../../instructions/multi-agent/execution-patterns.md
</agents_reference>

---

<recommended_agents>

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **document-writer** | haiku/sonnet | 문서 작성 |
| **explore** | haiku | 구조 파악, 패턴 분석 |
| **analyst** | sonnet | 요구사항 분석 |
| **code-reviewer** | opus | 품질 검증 |

</recommended_agents>

---

<model_routing>

@../../instructions/agent-patterns/model-routing.md

**문서 작성 특화:**

| 작업 | 모델 | 이유 |
|------|------|------|
| README, 설치 | haiku | 간단 구조, 빠름 |
| CLAUDE.md, SKILL.md | sonnet | XML 태그, 복잡 구조 |
| 아키텍처 | opus | 깊은 분석 |
| 품질 검증 | opus | 정확성 검토 |

</model_routing>

---

<coordination_patterns>

## 병렬 작성

```typescript
// 독립 문서 동시 작성
Task(subagent_type="document-writer", model="sonnet", prompt="CLAUDE.md 작성")
Task(subagent_type="document-writer", model="haiku", prompt="README.md 작성")
Task(subagent_type="document-writer", model="haiku", prompt="CONTRIBUTING.md 작성")
```

## 탐색 → 문서화

```typescript
Task(subagent_type="explore", model="haiku", prompt="프로젝트 구조, 기술 스택 분석")
Task(subagent_type="document-writer", model="sonnet", prompt="분석 기반 CLAUDE.md 작성")
```

## 작성 → 검증 → 개선

```typescript
Task(subagent_type="document-writer", model="sonnet", prompt="SKILL.md 작성")
Task(subagent_type="code-reviewer", model="opus", prompt="SKILL.md 검증")
Task(subagent_type="document-writer", model="sonnet", prompt="피드백 반영")
```

</coordination_patterns>

---

<practical_examples>

## 새 프로젝트

```typescript
// Phase 1: 병렬 탐색
Task(subagent_type="explore", model="haiku", prompt="구조 분석")
Task(subagent_type="explore", model="haiku", prompt="기술 스택 확인")

// Phase 2: 병렬 작성
Task(subagent_type="document-writer", model="sonnet", prompt="CLAUDE.md")
Task(subagent_type="document-writer", model="haiku", prompt="README.md")

// Phase 3: 검증
Task(subagent_type="code-reviewer", model="opus", prompt="품질 검증")
```

## API 문서

```typescript
// 병렬 작성
Task(subagent_type="document-writer", model="haiku", prompt="docs/api/users.md")
Task(subagent_type="document-writer", model="haiku", prompt="docs/api/posts.md")
```

## 스킬 문서

```typescript
Task(subagent_type="analyst", model="sonnet", prompt="요구사항 분석")
Task(subagent_type="document-writer", model="sonnet", prompt="SKILL.md 작성")
Task(subagent_type="code-reviewer", model="opus", prompt="검증 및 개선")
```

</practical_examples>

---

<best_practices>

| 체크리스트 | 패턴 | 모델 |
|----------|------|------|
| 여러 독립 문서 | 병렬 작성 | haiku |
| 기존 프로젝트 | explore → 문서화 | haiku → sonnet |
| 복잡한 구조 (XML, 다층) | 순차 작성 | sonnet/opus |
| 다국어 | 병렬 작성 | sonnet |
| 품질 중요 | 검증 추가 | opus |
| 대량 문서 (10개+) | 병렬 작성 | haiku |

</best_practices>
