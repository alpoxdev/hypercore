---
name: docs-refactor
description: 기존 Claude Code 문서 개선. CLAUDE.md, SKILL.md, COMMAND.md 토큰 효율 50% 개선 및 명확성 강화.
metadata:
  author: kood
  version: "1.0.0"
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Docs Refactor Skill

> 기존 CLAUDE.md, SKILL.md, COMMAND.md 문서를 Anthropic 가이드라인에 맞게 개선

<purpose>

**목표:** 토큰 효율 50% 개선, 명확성 향상, 유지보수성 강화

</purpose>

---

<trigger_conditions>

| 상황 | 리팩토링 필요 |
|------|--------------|
| **토큰 과다** | 파일 500줄 초과 |
| **가독성 저하** | XML 태그 미사용, 구조 불명확 |
| **중복 발견** | 동일 내용 2회 이상 반복 |
| **설명 과다** | 코드 예시보다 설명 많음 |
| **@imports 미사용** | 공통 규칙 반복 |
| **모호한 지시** | "적절히", "필요시" 등 |
| **부정형 과다** | Don't, Never, Avoid 위주 |

</trigger_conditions>

---

<parallel_agent_execution>

## 병렬 에이전트 실행 (ULTRAWORK MODE)

**목표:** 여러 문서 동시 리팩토링, 대기 시간 최소화, 처리량 극대화.

### 기본 원칙

| 원칙 | 적용 방법 | 효과 |
|------|----------|------|
| **PARALLEL** | 독립 문서 동시 리팩토링 | 5-15배 속도 향상 |
| **DELEGATE** | 에이전트별 전문화 (분석/리팩토링/검증) | 품질 향상 |
| **SMART MODEL** | 복잡도별 모델 (haiku/sonnet/opus) | 비용 최적화 |

---

### Phase별 에이전트 활용

| Phase | 에이전트 | 모델 | 작업 | 병렬 |
|-------|---------|------|------|------|
| **1. 분석** | explore | haiku | 여러 문서 구조 분석 | ✅ |
| **2. 리팩토링** | document-writer | sonnet | 독립 문서 개선 | ✅ |
| **3. 검증** | analyst | sonnet | 토큰 감소 확인 | ✅ |
| **4. 리뷰** | code-reviewer | opus | 정보 손실 체크 | ✅ |

---

### 실전 패턴

### Read 도구 병렬화

**프로젝트 분석 시 파일 병렬 읽기:**

```typescript
// ❌ 순차 읽기 (느림)
Read({ file_path: "src/file1.ts" })
// 대기...
Read({ file_path: "src/file2.ts" })

// ✅ 병렬 읽기 (빠름)
Read({ file_path: "src/file1.ts" })
Read({ file_path: "src/file2.ts" })
Read({ file_path: "src/file3.ts" })
Read({ file_path: "docs/api.md" })
```

**복잡한 탐색은 explore 에이전트 활용:**

```typescript
// 여러 영역 동시 탐색
Task(subagent_type="explore", model="haiku",
     prompt="영역 1 파일 구조 및 패턴 분석")
Task(subagent_type="explore", model="haiku",
     prompt="영역 2 의존성 및 관계 분석")
```

---

#### Pattern 1: 독립 문서 병렬 개선

```typescript
// 여러 SKILL.md 동시 리팩토링
Task(subagent_type="document-writer", model="sonnet",
     prompt="@.claude/skills/bug-fix/SKILL.md 리팩토링 (50% 토큰 감소)")

Task(subagent_type="document-writer", model="sonnet",
     prompt="@.claude/skills/refactor/SKILL.md 리팩토링 (50% 토큰 감소)")

Task(subagent_type="document-writer", model="sonnet",
     prompt="@.claude/skills/feature-add/SKILL.md 리팩토링 (50% 토큰 감소)")
```

**효과:** 순차 180초 → 병렬 60초 (3배 향상)

---

#### Pattern 2: 분석 + 리팩토링 동시

```typescript
// 현재 문서 리팩토링하며 다음 문서 분석
Task(subagent_type="document-writer", model="sonnet",
     prompt="현재 SKILL.md 리팩토링")

Task(subagent_type="explore", model="haiku",
     prompt="다음 COMMAND.md 구조 분석 및 중복 식별")
```

---

#### Pattern 3: 배치 처리

```typescript
// 동일 패턴 여러 문서 (토큰 70-90% 절감)
Task(subagent_type="document-writer", model="sonnet",
     prompt=`다음 CLAUDE.md 파일들 일괄 리팩토링:

     파일 목록:
     - projects/project-a/CLAUDE.md
     - projects/project-b/CLAUDE.md
     - projects/project-c/CLAUDE.md

     공통 규칙:
     1. @imports 분리
     2. tech_stack 표 형식
     3. quick_patterns 코드만
     4. 50% 토큰 감소`)
```

---

### Model Routing

| 작업 | 모델 | 이유 |
|------|------|------|
| **구조 분석** | haiku | 빠르고 저렴 |
| **리팩토링** | sonnet | 일반 품질 |
| **검증/리뷰** | opus | 정보 손실 방지 |

---

### 체크리스트

**병렬 실행 전:**
- [ ] 문서 독립적인가?
- [ ] 3개 이상 문서인가?
- [ ] 동일 패턴 적용 가능한가?

**실행 중:**
- [ ] 단일 메시지에서 다중 Tool 호출
- [ ] 복잡도별 모델 선택
- [ ] TaskList로 진행 상황 모니터링

**실행 후:**
- [ ] 각 문서 50% 토큰 감소 확인
- [ ] 정보 손실 없는지 검증
- [ ] XML 태그 중첩 오류 확인

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

### Pattern 1: 장황한 설명 → 표 형식

**절약:** 60-70%

```markdown
❌ Before (80 토큰):
파일을 읽을 때는 Read 도구를 사용하세요. 파일을 수정할 때는 Edit...

✅ After (25 토큰):
| 작업 | 도구 |
|------|------|
| 읽기 | Read |
| 수정 | Edit |
| 생성 | Write |
```

---

### Pattern 2: 중복 내용 → @imports

**절약:** 70-80%

```markdown
❌ Before (각 파일 150 토큰):
Git 커밋: "Co-Authored-By:" 금지, 한 줄, 이모지 금지...
(CLAUDE.md, SKILL.md에 동일 내용 반복)

✅ After (각 파일 10 토큰):
# CLAUDE.md
@instructions/git-rules.md

# git-rules.md (60 토큰, 공유)
<git_commit>
| 규칙 | 설명 |
|------|------|
| **형식** | `<prefix>: <설명>` |
| **금지** | 이모지, "Co-Authored-By:" |
</git_commit>
```

---

### Pattern 3: XML 태그 미사용 → 구조화

**절약:** 30-40%

```markdown
❌ Before (120 토큰):
절대 하지 말 것: any 타입, 불필요한 추상화
반드시 할 것: 명시적 return type, const 함수

✅ After (75 토큰):
<forbidden>
| 분류 | 금지 |
|------|------|
| **타입** | any |
| **구조** | 불필요한 추상화 |
</forbidden>

<required>
| 분류 | 필수 |
|------|------|
| **타입** | 명시적 return type |
| **선언** | const 함수 |
</required>
```

---

### Pattern 4: 설명 과다 → 코드 예시

**절약:** 50-60%

```markdown
❌ Before (180 토큰):
Server Function을 만들 때는 createServerFn을 사용합니다.
method를 지정하고, 인증이 필요하면 middleware를...

✅ After (65 토큰):
```typescript
// POST + Validation + Auth
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(schema)
  .handler(async ({ data }) => ...)
```
```

---

### Pattern 5: 부정형 → 긍정형

**절약:** 20-30%

```markdown
❌ Before (100 토큰):
Don't use any type
Don't create unnecessary abstractions
Don't skip validation

✅ After (70 토큰):
<required>
| 분류 | 필수 |
|------|------|
| **타입** | 명시적 타입 (unknown) |
| **구조** | 직접적 코드 |
| **검증** | inputValidator 사용 |
</required>
```

</refactoring_patterns>

---

<document_type_strategies>

| 문서 유형 | 최우선 작업 | 절약 효과 |
|----------|------------|----------|
| **CLAUDE.md** | @imports 분리 → tech_stack 표 형식 → quick_patterns 코드만 | 60-70% |
| **SKILL.md** | trigger_conditions 표 → workflow 코드 블록 → 설명 제거 | 65-75% |
| **COMMAND.md** | purpose 1-2문장 → workflow bash 코드 → examples ✅/❌ | 55-65% |

**공통 체크리스트:**
- [ ] XML 태그로 모든 섹션 구분
- [ ] 표 형식 최대 활용
- [ ] 코드 예시 중심
- [ ] 라이브러리 버전 명시
- [ ] @imports로 중복 제거

</document_type_strategies>

---

<token_optimization>

| 기법 | Before → After | 절약 |
|------|----------------|------|
| **단어 최적화** | "사용해야 합니다" → "사용" | 80% |
| **구조 압축** | 리스트 → 표 형식 | 40% |
| **반복 제거** | 각 파일 반복 → @imports | 70% |
| **코드 우선** | 설명 + 코드 → 코드만 | 50% |
| **공백 제거** | 빈 줄 최소화 | 10% |
| **예시 통합** | 개별 예시 → 통합 코드 블록 | 60% |

**체크리스트:**
- [ ] "~해야 합니다" → 필수
- [ ] "~하지 마세요" → 금지
- [ ] 반복 표현 → 표
- [ ] 설명 + 코드 → 코드만
- [ ] @imports 중복 제거

</token_optimization>

---

<workflow>

<step number="1">
<action>문서 분석</action>
<checklist>
- [ ] 전체 읽기 (Read)
- [ ] 토큰 수 추정 (`wc -w`)
- [ ] 문서 유형 확인
- [ ] 중복 내용 표시
</checklist>
</step>

<step number="2">
<action>리팩토링 계획</action>
<priority>
1. 중복 → @imports 분리
2. XML 태그 구조화
3. 표 형식 변환
4. 코드 중심 전환
5. 긍정형 변환
</priority>
</step>

<step number="3">
<action>리팩토링 실행</action>
<guidelines>
- Pattern 1-5 적용
- 문서 유형별 전략 사용
- 토큰 최적화 기법 적용
</guidelines>
</step>

<step number="4">
<action>검증</action>
<validation>
- [ ] 토큰 50% 감소 확인
- [ ] 핵심 정보 보존 확인
- [ ] XML 태그 중첩 확인
- [ ] 코드 블록 짝수 확인
- [ ] 부정형 5개 미만
</validation>
</step>

</workflow>

---

<examples>

### CLAUDE.md 리팩토링 (TanStack Start)

**Before (650 토큰):**
```markdown
# Project Guidelines

이 프로젝트에서는 TanStack Start를 사용합니다...
Server Function을 만들 때는 createServerFn을 사용해야 합니다...
절대로 any 타입을 사용하지 마세요...

Git 커밋 시에는 반드시 다음 규칙을 따라야 합니다:
- 한 줄 커밋 메시지만 사용
- 이모지 사용 금지...

TypeScript는 5.x 버전을 사용하고...
```

**After (280 토큰):**
```markdown
# CLAUDE.md - TanStack Start Project

<instructions>
@.claude/instructions/git-rules.md
@docs/library/tanstack-start/index.md
@docs/library/prisma/index.md
@docs/library/zod/index.md
</instructions>

---

<forbidden>
| 분류 | 금지 |
|------|------|
| **Server Function** | handler 내부 수동 검증/인증 |
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
| TanStack Start | 최신 | File-based routing |
| Prisma | 7.x | prisma-client, output 필수 |
| Zod | 4.x | z.email(), z.url() |
</tech_stack>

---

<quick_patterns>
```typescript
// Server Function
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(schema)
  .handler(async ({ data }) => ...)

// Zod v4
const schema = z.object({
  email: z.email(),
  website: z.url().optional(),
})
```
</quick_patterns>
```

**개선 효과:** 650 → 280 토큰 (57% 감소)

</examples>

---

<common_mistakes>

### 실수 1: 핵심 정보 손실

```markdown
❌ After (정보 손실):
Prisma 사용

✅ After (정보 보존):
| 기술 | 버전 | 필수 설정 |
|------|------|----------|
| Prisma | 7.x | prisma-client, output |
```

---

### 실수 2: XML 태그 불일치

```markdown
❌ 불일치:
<forbidden>
...
</required>  ← 잘못됨

✅ 일치:
<forbidden>
...
</forbidden>
```

---

### 실수 3: 버전 정보 누락

```markdown
❌ 버전 없음:
Zod, Prisma 사용

✅ 버전 명시:
| 기술 | 버전 |
|------|------|
| Zod | 4.x |
| Prisma | 7.x |
```

</common_mistakes>

---

<validation>

## 검증 방법

| 항목 | 기준 | 명령어 |
|------|------|--------|
| **토큰 효율** | 50% 감소 | `wc -w file.md` |
| **XML 태그** | 올바른 중첩 | `grep -o '<[^>]*>' file.md` |
| **코드 블록** | 짝수 개 | `grep -c '\`\`\`' file.md` |
| **부정형** | < 5개 | `grep -c "Don't\|Never" file.md` |

## 체크리스트

**구조:**
- [ ] 모든 섹션 XML 태그
- [ ] forbidden/required 분리

**내용:**
- [ ] 토큰 50% 감소
- [ ] 핵심 정보 보존
- [ ] 버전 명시

**예시:**
- [ ] 코드 블록 짝수
- [ ] ✅/❌ 마커
- [ ] 실행 가능한 코드

**표현:**
- [ ] 부정형 < 5
- [ ] 긍정형 지시

**최적화:**
- [ ] @imports 중복 제거
- [ ] 표 형식 압축
- [ ] 코드 중심

</validation>

---

<best_practices>

| 원칙 | 방법 | 효과 |
|------|------|------|
| **정보 보존 우선** | 토큰보다 정보 | 신뢰성 |
| **코드 중심** | 설명 → 예시 | 명확성 |
| **점진적 개선** | 한 번에 하나씩 | 안정성 |
| **측정 기반** | Before/After | 객관성 |

**문서별 팁:**

| 문서 | 핵심 작업 |
|------|----------|
| **CLAUDE.md** | @imports 최대 활용, quick_patterns 코드만 |
| **SKILL.md** | trigger_conditions 명확, 설명 제거 |
| **COMMAND.md** | workflow 실행 가능 코드, examples ✅/❌ |

</best_practices>
