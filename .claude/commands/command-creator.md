---
description: Slash command creation guide. Based on ANTHROPIC_CONTEXT_ENGINEERING.md rules.
allowed-tools: Read, Write, Glob, Grep
argument-hint: <command name>
---

# Command Creator

> Create slash command. 100% compliance with @ANTHROPIC_CONTEXT_ENGINEERING.md rules. Location: `.claude/commands/[name].md`

---

<argument_validation>

```
No $ARGUMENTS → "What command to create? (e.g., review-code, optimize, refactor)"
Has $ARGUMENTS → Proceed
```

</argument_validation>

---

<rules>

| Category | ❌ Forbidden | ✅ Required |
|----------|-------------|-----------|
| **Description** | Verbose, duplicate | Compressed table, ✅/❌ markers |
| **Structure** | No XML tags, vague | XML sections, clear hierarchy |
| **Expression** | Don't X (negative) | Do Y (positive) |
| **Examples** | Abstract | Copy-paste-ready code |
| **Emphasis** | CRITICAL overuse | Only when needed |
| **Meta** | - | YAML frontmatter |

</rules>

---

<structure_reference>

## Command File Structure

```markdown
---
description: Command description (1 line, include trigger keywords)
allowed-tools: Tool1, Tool2  # Optional
argument-hint: <argument description>
---

# Command Name

> Purpose (1-2 sentences)

---

<purpose>
Specific goal
</purpose>

---

<arguments>
| Example | Action |
|---------|--------|
| `arg` | Description |
</arguments>

---

<workflow>
| Step | Task | Tool |
|------|------|------|
| 1. | ... | Tool |
</workflow>

---

<forbidden>
| Prohibited |
|----------|
| Item |
</forbidden>

---

<required>
| Required |
|----------|
| Item |
</required>

---

<examples>
```typescript
// ✅ Correct pattern
// ❌ Wrong pattern
```
</examples>

---

<validation>
```text
✅ Checklist
❌ Prohibited
```
</validation>
```

## Section Reference

| Section | Purpose | Format | Required |
|---------|---------|--------|----------|
| **\<purpose\>** | Command goal | Concise sentence | ✅ |
| **\<arguments\>** | Argument description | Table (example\|action) | ✅ |
| **\<workflow\>** | Execution steps | Table (step\|task\|tool) | ✅ |
| **\<forbidden\>** | Prohibited | Table/list | ✅ |
| **\<required\>** | Required | Table/list | ✅ |
| **\<examples\>** | Code example | Runnable code | ✅ |
| **\<validation\>** | Checklist | ✅/❌ markers | ✅ |
| **\<critical_requirements\>** | Agent delegation | Task pattern | Conditional |
| **\<thinking_strategy\>** | Sequential Thinking | Complexity guide | Conditional |

## YAML Fields

| Field | Description | Example | Required |
|-------|-------------|---------|----------|
| **description** | Description with trigger keywords | `Git commit. Support push/pull.` | ✅ |
| **argument-hint** | Argument example | `[push\|pull\|message...]` | ✅ |
| **allowed-tools** | Tool restriction | `Bash, Read, Grep` | ❌ |

</structure_reference>

---

<workflow>

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. | ARGUMENT 검증 | - |
| 2. | 기존 커맨드 참고 | Glob, Read |
| 3. | YAML frontmatter | - |
| 4. | XML 섹션 구성 | - |
| 5. | 예시 작성 | - |
| 6. | 검증 | - |

</workflow>

---

<template>

## 통합 템플릿

```markdown
---
description: [목적]. [트리거 키워드] 처리.
argument-hint: <인자>
# 조건부: allowed-tools: [도구 목록]
---

# [Command Name]

> [1-2문장 설명]

# 조건부: 에이전트 위임 시
---
<critical_requirements>

## ⚠️ CRITICAL: @agent-name 필수

```typescript
Task({
  subagent_type: 'agent-name',
  description: '[설명]',
  prompt: `$ARGUMENTS 처리: [상세]`
})
```

**❌ 금지**: 직접 실행
**✅ 필수**: Task로 에이전트 호출

**자가 점검:**
```text
□ Task 도구 사용?
□ @agent-name 위임?
```

</critical_requirements>
# 조건부 끝

# 조건부: Sequential Thinking 시
---
<thinking_strategy>

## Sequential Thinking

| 복잡도 | 횟수 | 기준 | 패턴 |
|--------|------|------|------|
| 간단 | 2 | 1파일 | 판단 → 실행 |
| 보통 | 3-4 | 2-3파일 | 판단 → 분석 → 실행 |
| 복잡 | 5+ | 다중 모듈 | 판단 → 분석 → 계획 → 실행 |

</thinking_strategy>
# 조건부 끝

---

<purpose>
[목표]
</purpose>

---

<arguments>

**$ARGUMENTS 있음**: [동작]

| 예시 | 동작 |
|------|------|
| `ex1` | 설명 |
| `ex2` | 설명 |

**$ARGUMENTS 없음**: [기본]

</arguments>

---

<workflow>

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. | 입력 확인 | - |
| 2. | 분석 | Tool |
| 3. | 실행 | Tool |
| 4. | 검증 | Tool |

</workflow>

---

<forbidden>

| 금지 |
|------|
| 항목 1 |
| 항목 2 |

</forbidden>

---

<required>

| 필수 |
|------|
| 항목 1 |
| 항목 2 |

</required>

---

<examples>

```typescript
// ✅ 올바른 패턴
const example = () => { ... }

// ❌ 잘못된 패턴
function bad() { ... }
```

</examples>

---

<validation>

```text
✅ ARGUMENT 확인
✅ XML 섹션
✅ 코드 실행 가능
✅ 긍정형 지시

❌ 장황한 설명
❌ 태그 누락
```

</validation>
```

## 템플릿 변형

| 유형 | 추가 섹션 | 특징 |
|------|----------|------|
| **기본** | 없음 | purpose + workflow + examples |
| **에이전트** | `<critical_requirements>` | Task 패턴, 자가 점검 |
| **복잡** | `<thinking_strategy>` | Sequential Thinking 가이드 |

</template>

---

<example>

## 압축 예시

### /format - 코드 포맷팅

```markdown
---
description: 코드 포맷팅. Prettier/ESLint 적용.
argument-hint: [파일 패턴]
---

# Format Command

> Prettier + ESLint로 코드 포맷팅.

---

<purpose>
일관된 코드 스타일 유지
</purpose>

---

<arguments>

**$ARGUMENTS 있음**: 해당 패턴만

| 예시 | 동작 |
|------|------|
| `src/**/*.ts` | TypeScript만 |
| `components/` | 특정 디렉토리 |

**$ARGUMENTS 없음**: 전체

</arguments>

---

<workflow>

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. | 패턴 확인 | - |
| 2. | Prettier | Bash |
| 3. | ESLint | Bash |
| 4. | 검증 | Bash |

</workflow>

---

<forbidden>

| 금지 |
|------|
| 규칙 임의 변경 |
| .prettierrc 수정 |

</forbidden>

---

<required>

| 필수 |
|------|
| 모든 파일 통과 |
| 에러 보고 |

</required>

---

<examples>

```bash
# ✅ 전체
npx prettier --write .
npx eslint --fix .

# ✅ 패턴
npx prettier --write "src/**/*.ts"
```

</examples>

---

<validation>

```text
✅ Prettier 통과
✅ ESLint 통과

❌ 실패 무시
```

</validation>
```

## 예시 변형

| 커맨드 | 유형 | 핵심 차이 |
|--------|------|----------|
| **/format** | 기본 | 단순 workflow |
| **/security-scan** | 에이전트 | `<critical_requirements>` + Task 패턴 |
| **/optimize** | 복잡 | `<thinking_strategy>` + sequentialthinking |

**에이전트 위임 패턴:**
```typescript
<critical_requirements>
Task({ subagent_type: 'agent', prompt: '$ARGUMENTS' })
**❌ 금지**: 직접 실행
**✅ 필수**: Task 위임
</critical_requirements>
```

**Sequential Thinking 패턴:**
```markdown
<thinking_strategy>
| 복잡도 | 횟수 | 기준 |
|--------|------|------|
| 간단 | 2 | 1파일 |
| 보통 | 3-4 | 2-3파일 |
| 복잡 | 5+ | 다중 모듈 |
</thinking_strategy>
```

</example>

---

<validation>

## 생성 체크리스트

**생성 전:**
```text
✅ ARGUMENT 검증
✅ YAML frontmatter
✅ XML 섹션 구분
✅ 표 압축
✅ 코드 실행 가능
✅ ✅/❌ 마커
✅ 긍정형 지시
```

**생성 후:**
```text
✅ 위치: .claude/commands/[name].md
✅ XML 태그 중첩 올바름
✅ 표 정렬
✅ 코드 구문 검사
✅ Don't < 5개
✅ 500줄 이하 (권장)
```

## 품질 기준

| 항목 | 기준 | 검증 방법 |
|------|------|----------|
| **길이** | 500줄 이하 권장 | `wc -l` |
| **XML** | 올바른 중첩 | `grep -o '<[^>]*>'` |
| **긍정형** | Don't < 5 | `grep -c "Don't"` |
| **예시** | 실행 가능 | 테스트 |

</validation>

---

<best_practices>

| 원칙 | 방법 | 안티패턴 | 해결 |
|------|------|----------|------|
| **Show, Don't Tell** | 코드 예시 | 장황한 설명 | 표 + 코드 |
| **High Density** | 1줄당 최대 정보 | 중복 정보 | 표 압축 |
| **Copy-Paste** | 바로 사용 가능 | 추상적 예시 | 실행 코드 |
| **Positive** | Do X | Don't Y | 긍정형 변환 |
| **Explicit** | 명시적 지시 | 모호함 | 구체적 표현 |
| **Structured** | XML 태그 | 태그 없음 | 모든 섹션 태그화 |

## 섹션별 팁

| 섹션 | 핵심 | 실수 | 해결 |
|------|------|------|------|
| **purpose** | 1-2문장, 구체적 | 장황함 | 목표만 |
| **arguments** | 표 + 예시 | 설명만 | 예시 추가 |
| **workflow** | 단계\|작업\|도구 | 서술형 | 표 형식 |
| **examples** | 실행 가능, ✅/❌ | 추상적 | 구체적 코드 |
| **validation** | 체크리스트 | 모호함 | 명확한 기준 |

## 압축 기법

| 기법 | 적용 | 효과 |
|------|------|------|
| **표 병합** | 유사 섹션 통합 | 30-40% 감소 |
| **예시 압축** | 변형 표로 요약 | 50-60% 감소 |
| **조건부 섹션** | 주석으로 표시 | 명확성 유지 |
| **참조 분리** | references/ 이동 | 메인 파일 간결 |

</best_practices>
