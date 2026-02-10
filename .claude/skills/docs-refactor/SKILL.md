---
name: docs-refactor
description: 기존 Claude Code 문서 개선. CLAUDE.md, SKILL.md, COMMAND.md 토큰 효율 50% 개선 및 명확성 강화.
metadata:
  author: kood
  version: "1.2.0"
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Docs Refactor Skill

> 기존 문서 Anthropic 가이드라인 기반 50% 토큰 감소

<purpose>
토큰 50% 감소, 명확성 향상, 유지보수성 강화
</purpose>

---

<trigger_conditions>

| 상황 | 리팩토링 필요 |
|------|--------------|
| **토큰 과다** | 500줄 초과 |
| **가독성 저하** | XML 태그 미사용 |
| **중복 발견** | 2회 이상 반복 |
| **설명 과다** | 코드 < 설명 |
| **@imports 미사용** | 공통 규칙 반복 |
| **모호한 지시** | "적절히", "필요시" |
| **부정형 과다** | Don't 위주 |

</trigger_conditions>

---

<parallel_agent_execution>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "docs-refactor-team", description: "문서 리팩토링" })
Task(subagent_type="document-writer", team_name="docs-refactor-team", name="writer", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

@../docs-creator/SKILL.md#parallel_agent_execution

**리팩토링 특화:**

| 작업 | 패턴 | 효과 |
|------|------|------|
| **독립 문서** | 병렬 document-writer | 3-4배 향상 |
| **@imports 추출** | 분석 + 공통화 병렬 | 70-90% 절감 |
| **배치 처리** | 동일 패턴 여러 문서 | 순차 대비 3배 |

```typescript
// 여러 SKILL.md 동시 리팩토링 (순차 180초 → 병렬 60초)
Task(subagent_type="document-writer", model="sonnet",
     prompt="@.claude/skills/bug-fix/SKILL.md 리팩토링 (50% 감소)")
Task(subagent_type="document-writer", model="sonnet",
     prompt="@.claude/skills/refactor/SKILL.md 리팩토링 (50% 감소)")
```

</parallel_agent_execution>

---

<forbidden>

| 분류 | 금지 사항 |
|------|----------|
| **구조** | XML 태그 제거, 단순 삭제 |
| **내용** | 핵심 정보 손실, 버전 정보 제거 |
| **표현** | 모호한 지시 유지, 부정형 → 부정형 |
| **스타일** | 일관성 없는 마커 |

</forbidden>

---

<required>

| 분류 | 필수 작업 |
|------|----------|
| **분석** | 전체 읽기 → 토큰 확인 → 중복 식별 |
| **구조화** | XML 태그 적용 |
| **압축** | 표 형식 변환, 설명 제거 |
| **예시화** | 설명 → 코드 예시 |
| **검증** | Before/After 50% 감소 확인 |

</required>

---

<refactoring_patterns>

| 패턴 | Before | After | 절약 |
|------|--------|-------|------|
| **설명 → 표** | 장황한 설명문 (80 토큰) | 표 형식 (25 토큰) | 69% |
| **중복 → @imports** | 각 파일 반복 (150 토큰) | @imports (10 토큰) | 93% |
| **설명 → 코드** | 설명 중심 (180 토큰) | 코드 예시 (65 토큰) | 64% |
| **부정 → 긍정** | Don't 나열 (100 토큰) | required 표 (70 토큰) | 30% |

**우선순위:** @imports > 표 > 코드 > 긍정형

</refactoring_patterns>

---

<strategies>

| 문서 | 최우선 | 절약 |
|------|--------|------|
| **CLAUDE.md** | @imports → tech_stack 표 → quick_patterns 코드 | 60-70% |
| **SKILL.md** | trigger_conditions 표 → workflow 간소화 → 설명 제거 | 65-75% |
| **COMMAND.md** | purpose 1문장 → workflow bash → examples ✅/❌ | 55-65% |

**기법:**
- 단어: "사용해야 합니다" → "사용" (80%)
- 구조: 리스트 → 표 (40%)
- 반복: @imports (70%)
- 우선: 설명 → 코드 (50%)

</strategies>

---

<workflow>

| Step | 작업 | 도구/방법 |
|------|------|----------|
| **1** | 분석 (Read → `wc -w` → 유형 확인 → 중복 식별) | Read, Bash |
| **2** | 계획 (@imports → XML → 표 → 코드 → 긍정형) | - |
| **3** | 실행 (패턴 적용, 문서별 전략) | Edit |
| **4** | 검증 (50% 감소, 정보 보존, XML, 코드 블록, 부정형 < 5) | Bash, 수동 |

</workflow>

---

<examples>

## CLAUDE.md 리팩토링

**Before (650 토큰):**
```markdown
# Project Guidelines

이 프로젝트에서는 TanStack Start를 사용합니다...
Server Function을 만들 때는 createServerFn을 사용해야 합니다...
절대로 any 타입을 사용하지 마세요...

Git 커밋 시에는 반드시 다음 규칙을 따라야 합니다:
- 한 줄 커밋 메시지만 사용
- 이모지 사용 금지...
```

**After (280 토큰):**
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
| **타입** | any (unknown 사용) |
</forbidden>

---

<tech_stack>
| 기술 | 버전 |
|------|------|
| Prisma | 7.x |
| Zod | 4.x |
</tech_stack>

---

<quick_patterns>
```typescript
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(schema)
  .handler(async ({ data }) => ...)
```
</quick_patterns>
```

**효과:** 650 → 280 (57% 감소)

</examples>

---

<validation>

| 항목 | 기준 | 검증 |
|------|------|------|
| **토큰** | 50% 감소 | `wc -w` |
| **XML** | 올바른 중첩 | 수동 |
| **코드 블록** | 짝수 | `grep -c '\`\`\`'` |
| **부정형** | < 5 | `grep -c "Don't"` |

**체크리스트:**
- [ ] 토큰 50% 감소
- [ ] 핵심 정보 보존
- [ ] XML 태그 중첩
- [ ] 코드 실행 가능
- [ ] @imports 중복 제거

</validation>

---

<best_practices>

| 원칙 | 방법 |
|------|------|
| **정보 우선** | 토큰 < 정보 |
| **코드 중심** | 설명 → 코드 |
| **점진적** | 한 번에 하나 |
| **측정 기반** | Before/After |

</best_practices>
