---
name: docs-creator
description: Claude Code 문서 작성. CLAUDE.md, SKILL.md, COMMAND.md 효율적 작성.
metadata:
  author: kood
  version: "2.0.0"
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Docs Creator Skill

> Anthropic 가이드라인 기반 고밀도 문서 작성

<purpose>
고밀도, 실행 가능, 유지보수 가능한 문서 작성
</purpose>

---

<trigger_conditions>

| 상황 | 작성 필요 |
|------|----------|
| **새 프로젝트** | CLAUDE.md |
| **새 스킬** | SKILL.md |
| **새 커맨드** | COMMAND.md |

</trigger_conditions>

---

<parallel_agent_execution>

## 핵심 원칙

| 원칙 | 방법 | 효과 |
|------|------|------|
| **PARALLEL** | 단일 메시지 여러 에이전트 호출 | 5-10배 속도 |
| **DELEGATE** | 전문 에이전트 즉시 위임 | 품질 향상 |
| **SMART MODEL** | 작업 복잡도별 모델 | 비용 최적화 |

```typescript
// ❌ 순차 (120초)
Task(...) // 60초
Task(...) // 60초

// ✅ 병렬 (60초) - 단일 메시지
Task(subagent_type="explore", model="haiku", prompt="...")
Task(subagent_type="document-writer", model="haiku", prompt="...")
```

---

## Phase별 활용

| Phase | 작업 | 에이전트 | 모델 | 병렬 |
|-------|------|---------|------|------|
| **1** | 구조 파악 | explore | haiku | ✅ |
| **1** | 규칙 추출 | analyst | sonnet | ✅ |
| **2** | 문서 작성 | document-writer | haiku/sonnet | ✅ |
| **3** | 검증 (복잡) | architect | opus | ✅ |

---

## 실전 패턴

### 패턴 1: 다중 문서 동시 작성

```typescript
// CLAUDE.md + 3개 라이브러리 가이드 (60초)
Task(subagent_type="document-writer", model="haiku",
     prompt="CLAUDE.md 작성 - 프로젝트 규칙")
Task(subagent_type="document-writer", model="haiku",
     prompt="TanStack Start 가이드")
Task(subagent_type="document-writer", model="haiku",
     prompt="Prisma 가이드")
Task(subagent_type="document-writer", model="haiku",
     prompt="Zod 가이드")
```

**효과:** 순차 240초 → 병렬 60초 (4배)

---

### 패턴 2: 조사 + 작성 병렬

```typescript
// 탐색과 작성 동시
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 React Query 사용 패턴 조사")
Task(subagent_type="document-writer", model="haiku",
     prompt="React Query 가이드 초안 (버전 나중 추가)")

// 탐색 결과로 버전 정보 추가
Read(".../react-query-usage.md")
Edit("docs/library/react-query/index.md", ...)
```

---

### 모델 라우팅

| 복잡도 | 모델 | 문서 | 비용 |
|--------|------|------|------|
| **LOW** | haiku | 간단 규칙, 반복 패턴 | 💰 |
| **MEDIUM** | sonnet | CLAUDE.md, 라이브러리 가이드 | 💰💰 |
| **HIGH** | opus | 아키텍처, 보안/성능 | 💰💰💰 |

</parallel_agent_execution>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **설명** | 장황, 중복, Claude가 아는 것 반복 |
| **구조** | XML 태그 없음, 모호한 지시 |
| **표현** | 부정형 (Don't X → Do Y) |
| **복잡도** | 조건문, 엣지 케이스 나열 |
| **강조** | CRITICAL/MUST 남발 |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **구조** | XML 태그 섹션, 명확한 계층 |
| **표현** | 표 형식, ✅/❌ 마커 |
| **예시** | 코드 중심, 복사 가능 |
| **로딩** | @imports just-in-time |
| **지시** | 긍정형, 명시적 |
| **버전** | 라이브러리 버전 명시 |

</required>

---

<document_types>

## CLAUDE.md

```markdown
# CLAUDE.md - [프로젝트명]

<instructions>
@path/to/common.md
@.claude/docs/library/[lib]/index.md
</instructions>

---

<forbidden>
| 분류 | 금지 |
|------|------|
| **Git** | AI 표시, 이모지 |
</forbidden>

---

<required>
| 분류 | 필수 |
|------|------|
| **타입** | 명시적 return type |
</required>

---

<tech_stack>
| 기술 | 버전 | 주의 |
|------|------|------|
| TypeScript | 5.x | strict |
</tech_stack>

---

<quick_patterns>
```typescript
// 복사 가능 패턴
const fn = (): ReturnType => { ... }
```
</quick_patterns>
```

---

## SKILL.md

```markdown
---
name: skill-name
description: 한 줄 설명
---

<trigger_conditions>
| 트리거 | 반응 |
|--------|------|
| "키워드" | 즉시 실행 |
</trigger_conditions>

---

<workflow>
<step number="1">
<action>작업</action>
<tools>Tool1</tools>
</step>
</workflow>

---

<examples>
```typescript
// 실행 가능 코드
```
</examples>
```

---

## COMMAND.md

```markdown
---
description: 커맨드 설명
allowed-tools: Read, Edit
argument-hint: <인자>
---

<purpose>
구체적 목표
</purpose>

---

<workflow>
실행 단계
</workflow>

---

<examples>
✅/❌ 비교
</examples>
```

</document_types>

---

<workflow>

| Step | 작업 | 도구 |
|------|------|------|
| **1** | 유형 결정, 구조 파악 | Glob, Read |
| **2** | 규칙 추출 (forbidden → required → patterns) | Grep |
| **3** | 작성 (XML 태그, 표, 코드, @imports) | Write |
| **4** | 검증 (체크리스트) | - |

</workflow>

---

<examples>

## TanStack Start CLAUDE.md

```markdown
# CLAUDE.md - TanStack Start

<instructions>
@.claude/instructions/git-rules.md
@.claude/docs/library/tanstack-start/index.md
</instructions>

---

<forbidden>
| 분류 | 금지 |
|------|------|
| **API** | `/api` 라우터 (명시 요청 제외) |
| **타입** | any (unknown 사용) |
</forbidden>

---

<required>
| 분류 | 필수 |
|------|------|
| **Server Function** | POST/PUT → inputValidator + middleware |
| **타입** | 명시적 return type |
</required>

---

<tech_stack>
| 기술 | 버전 | 주의 |
|------|------|------|
| Prisma | 7.x | prisma-client, output 필수 |
| Zod | 4.x | z.email(), z.url() |
</tech_stack>

---

<quick_patterns>
```typescript
// Server Function
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))

// Zod v4
const schema = z.object({
  email: z.email(),
  website: z.url().optional(),
})
```
</quick_patterns>
```

</examples>

---

<validation>

| 항목 | 기준 | 검증 |
|------|------|------|
| **토큰** | 500줄 이하 | wc -l |
| **XML** | 올바른 중첩 | 수동 |
| **예시** | 실행 가능 | 테스트 |
| **긍정형** | Don't < 5 | grep -c |

**체크리스트:**
- [ ] XML 태그 섹션 구분
- [ ] 표 형식 압축
- [ ] 코드 예시 실행 가능
- [ ] ✅/❌ 마커
- [ ] @imports 중복 제거
- [ ] 버전 명시
- [ ] 긍정형 지시

</validation>

---

<best_practices>

| 원칙 | 방법 |
|------|------|
| **Show, Don't Tell** | 설명 < 코드 |
| **High Density** | 1줄당 최대 정보 |
| **Copy-Paste Ready** | 바로 사용 가능 |
| **Version Explicit** | 버전 명시 |
| **Positive Language** | Do X > Don't Y |

## 일반적 실수

| 실수 | 올바른 방법 |
|------|------------|
| 장황한 설명 | 표 + 코드 |
| XML 태그 없음 | 섹션 태그 구분 |
| 추상적 예시 | 실행 가능 코드 |
| 중복 정보 | @imports |
| 버전 누락 | 버전 명시 |

</best_practices>
