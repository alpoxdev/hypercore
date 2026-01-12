---
description: 기존 Claude Code 문서 개선
allowed-tools: Read, Edit, Glob, Grep
argument-hint: <document path>
---

# Docs Refactor Command

> Improve existing CLAUDE.md, SKILL.md, COMMAND.md documents to align with Anthropic guidelines

<purpose>

**Goal:** Improve token efficiency 50%, enhance clarity, strengthen maintainability

</purpose>

---

<trigger_conditions>

| Situation | Refactoring Needed |
|-----------|-------------------|
| **Token overuse** | File exceeds 500 lines |
| **Readability drop** | No XML tags, unclear structure |
| **Duplication found** | Same content repeated 2+ times |
| **Excessive description** | More description than code examples |
| **@imports unused** | Common rules repeated |
| **Vague instructions** | "Appropriately", "if needed", etc. |
| **Negative overuse** | Focused on Don't, Never, Avoid |

</trigger_conditions>

---

<forbidden>

| Category | Prohibited |
|----------|-----------|
| **Structure** | Remove XML tags, simple deletion |
| **Content** | Lose core info, remove version info |
| **Expression** | Maintain vagueness, negative → negative |
| **Style** | Inconsistent markers |

</forbidden>

---

<required>

| Category | Required Task |
|----------|---------------|
| **Analyze** | Full read → token count → identify duplication |
| **Structure** | Apply XML tags |
| **Compress** | Convert to table format, remove description |
| **Exemplify** | Description → code examples |
| **Verify** | Confirm Before/After 50% reduction |

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
