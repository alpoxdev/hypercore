---
description: 슬래시 커맨드 생성 가이드. ANTHROPIC_CONTEXT_ENGINEERING.md 규칙 기반.
allowed-tools: Read, Write, Glob, Grep
argument-hint: <커맨드명>
---

# Command Creator

> 슬래시 커맨드 생성. @ANTHROPIC_CONTEXT_ENGINEERING.md 규칙 100% 준수. 위치: `.claude/commands/[name].md`

---

<argument_validation>

```
$ARGUMENTS 없음 → "어떤 커맨드를 만들까요? (예: review-code, optimize, refactor)"
$ARGUMENTS 있음 → 진행
```

</argument_validation>

---

<rules>

| 분류 | ❌ 금지 | ✅ 필수 |
|------|---------|---------|
| **설명** | 장황한 설명, 중복 | 표 압축, ✅/❌ 마커 |
| **구조** | XML 태그 없음, 모호 | XML 섹션, 명확한 계층 |
| **표현** | Don't X (부정형) | Do Y (긍정형) |
| **예시** | 추상적 | 복사 가능 코드 |
| **강조** | CRITICAL 남발 | 필요 시에만 |
| **메타** | - | YAML frontmatter |

</rules>

---

<structure_reference>

## 커맨드 파일 구조

```markdown
---
description: 커맨드 설명 (1줄, 트리거 키워드 포함)
allowed-tools: Tool1, Tool2  # 선택적
argument-hint: <인자 설명>
---

# Command Name

> 목적 (1-2문장)

---

<purpose>
구체적 목표
</purpose>

---

<arguments>
| 예시 | 동작 |
|------|------|
| `arg` | 설명 |
</arguments>

---

<workflow>
| 단계 | 작업 | 도구 |
|------|------|------|
| 1. | ... | Tool |
</workflow>

---

<forbidden>
| 금지 |
|------|
| 항목 |
</forbidden>

---

<required>
| 필수 |
|------|
| 항목 |
</required>

---

<examples>
```typescript
// ✅ 올바른 패턴
// ❌ 잘못된 패턴
```
</examples>

---

<validation>
```text
✅ 체크리스트
❌ 금지사항
```
</validation>
```

## 섹션 레퍼런스

| 섹션 | 용도 | 형식 | 필수 |
|------|------|------|------|
| **\<purpose\>** | 커맨드 목표 | 간결한 문장 | ✅ |
| **\<arguments\>** | 인자 설명 | 표 (예시\|동작) | ✅ |
| **\<workflow\>** | 실행 단계 | 표 (단계\|작업\|도구) | ✅ |
| **\<forbidden\>** | 금지사항 | 표/리스트 | ✅ |
| **\<required\>** | 필수사항 | 표/리스트 | ✅ |
| **\<examples\>** | 코드 예시 | 실행 가능 코드 | ✅ |
| **\<validation\>** | 체크리스트 | ✅/❌ 마커 | ✅ |
| **\<critical_requirements\>** | 에이전트 위임 | Task 패턴 | 조건부 |
| **\<thinking_strategy\>** | Sequential Thinking | 복잡도 가이드 | 조건부 |

## YAML 필드

| 필드 | 설명 | 예시 | 필수 |
|------|------|------|------|
| **description** | 트리거 키워드 포함 설명 | `Git 커밋. push/pull 지원.` | ✅ |
| **argument-hint** | 인자 예시 | `[push\|pull\|메시지...]` | ✅ |
| **allowed-tools** | 도구 제한 | `Bash, Read, Grep` | ❌ |

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
