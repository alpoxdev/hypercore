---
description: Claude Code documentation writing guide
allowed-tools: Read, Write, Glob, Grep
argument-hint: <document type: CLAUDE.md | SKILL.md | COMMAND.md>
---

# Docs Creator Command

> Effectively create Claude Code documents (CLAUDE.md, SKILL.md, COMMAND.md) following Anthropic guidelines

<purpose>

**Goal:** Create high-density, executable, maintainable documentation

</purpose>

---

<trigger_conditions>

| Situation | Create |
|-----------|--------|
| **New project** | Create CLAUDE.md |
| **New skill** | Create SKILL.md |
| **New command** | Create COMMAND.md |
| **Missing docs** | Document project rules |
| **Knowledge sharing** | Team onboarding guide |

</trigger_conditions>

---

<forbidden>

| Category | Prohibited |
|----------|-----------|
| **Description** | Verbose text, unnecessary content, duplication |
| **Structure** | Complex without XML tags, vague instructions |
| **Expression** | Negative instructions (Don't X → Do Y) |
| **Complexity** | Complex conditionals, all edge cases |
| **Emphasis** | Excessive (CRITICAL, MUST overuse) |

</forbidden>

---

<required>

| Category | Required |
|----------|----------|
| **Structure** | XML tag sections, clear hierarchy |
| **Expression** | Compressed tables, ✅/❌ markers |
| **Examples** | Code-focused, copy-paste-ready patterns |
| **Loading** | Just-in-time with @imports |
| **Instructions** | Explicit, positive expression |
| **Version** | Library versions specified |

</required>

---

<document_types>

## CLAUDE.md - Project Rules

**Usage:** Project-specific coding rules, forbidden/required items, quick reference

**Structure:**
```markdown
# CLAUDE.md - [Project Name]

<instructions>
@path/to/common-rules.md
@docs/library/[library]/index.md
</instructions>

---

<forbidden>
| Category | Forbidden |
|----------|----------|
| **Git** | AI indicators, emoji, multiple lines |
</forbidden>

---

<required>
| Category | Required |
|----------|----------|
| **Type** | Explicit return type |
</required>

---

<tech_stack>
| Technology | Version | Note |
|----------|---------|------|
| TypeScript | 5.x | strict |
</tech_stack>

---

<quick_patterns>
```typescript
// Copy-paste-ready pattern
const example = () => { ... }
```
</quick_patterns>
```

---

## SKILL.md - Reusable Task

**Usage:** Define skill for specific task automation

**Structure:**
```markdown
---
name: skill-name
description: Brief description (1 line)
---

<trigger_conditions>
| Keyword/Situation | Action |
|------------------|--------|
| "keyword" | Execute immediately |
</trigger_conditions>

---

<workflow>
<step number="1">
<action>Action description</action>
<tools>Tool1, Tool2</tools>
</step>
</workflow>

---

<examples>
```typescript
// Actual code
```
</examples>
```

---

## COMMAND.md - CLI Command

**Usage:** Define slash command (/commit, /review)

**Structure:**
```markdown
---
description: Command description
allowed-tools: Read, Edit, Bash
argument-hint: <argument description>
---

<purpose>
Specific goal
</purpose>

---

<workflow>
Execution steps
</workflow>

---

<examples>
✅/❌ Comparison examples
</examples>
```

</document_types>

---

<templates>

## Template 1: CLAUDE.md

```markdown
# CLAUDE.md - [프로젝트명]

<instructions>
@.claude/instructions/git-rules.md
@docs/library/react/index.md
</instructions>

---

<forbidden>
| 분류 | 금지 |
|------|------|
| **Git** | AI 표시, 이모지 |
| **타입** | any (unknown 사용) |
</forbidden>

---

<required>
| 분류 | 필수 |
|------|------|
| **함수** | const 선언, 명시적 return type |
| **Import** | 절대 경로 (@/) |
</required>

---

<quick_patterns>
```typescript
// ✅ 올바른 패턴
const fetchUser = async (id: string): Promise<User> => {
  return await prisma.user.findUnique({ where: { id } })
}

// ❌ 잘못된 패턴
function fetchUser(id) { ... }
```
</quick_patterns>
```

---

## Template 2: SKILL.md

```markdown
---
name: test-runner
description: 테스트 실행 및 실패 수정
---

<trigger_conditions>
| 트리거 | 반응 |
|--------|------|
| 코드 수정 완료 | 자동 실행 |
| "테스트 실행" | 즉시 실행 |
</trigger_conditions>

---

<forbidden>
| 금지 |
|------|
| 테스트 삭제로 통과, 테스트 없이 완료 |
</forbidden>

---

<required>
| 필수 |
|------|
| 모든 테스트 통과, 실패 원인 설명 |
</required>

---

<workflow>
<step number="1">
<action>테스트 실행</action>
<tools>Bash</tools>
<command>npm test</command>
</step>

<step number="2">
<action>실패 분석</action>
<tools>Read</tools>
</step>

<step number="3">
<action>코드 수정</action>
<tools>Edit</tools>
</step>

<step number="4">
<action>재실행</action>
<criteria>모든 테스트 통과</criteria>
</step>
</workflow>

---

<examples>
```typescript
// ❌ 버그
const sum = (a: number, b: number) => a - b

// ✅ 수정
const sum = (a: number, b: number) => a + b
```
</examples>
```

</templates>

---

<workflow>

<step number="1">
<action>문서 유형 결정 및 프로젝트 분석</action>
<output>
- CLAUDE.md | SKILL.md | COMMAND.md 선택
- 프로젝트 구조 파악 (Glob, Read)
- 기존 패턴 식별 (Grep)
- 라이브러리 버전 확인
</output>
</step>

<step number="2">
<action>핵심 규칙 추출</action>
<priority>
1. 절대 금지 사항 (forbidden)
2. 필수 사항 (required)
3. 일반적 패턴 (patterns)
</priority>
</step>

<step number="3">
<action>템플릿 선택 및 작성</action>
<guidelines>
- XML 태그로 섹션 구분
- 표 형식으로 정보 압축
- 코드 예시 중심
- @imports로 공통 규칙 분리
- 버전 명시
</guidelines>
</step>

<step number="4">
<action>품질 검증</action>
<checklist>
- [ ] 토큰 효율 (500줄 이하)
- [ ] XML 태그 올바른 중첩
- [ ] 코드 예시 실행 가능
- [ ] 긍정형 지시 (Don't → Do)
- [ ] 버전 명시
- [ ] ✅/❌ 마커 사용
</checklist>
</step>

</workflow>

---

<examples>

### Example 1: TanStack Start CLAUDE.md

**상황:** 새 TanStack Start 프로젝트, Prisma + Zod 사용

**작성 결과:**
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
| **API** | `/api` 라우터 (명시 요청 제외) |
| **Server Function** | handler 내부 수동 검증/인증 |
| **타입** | any (unknown 사용) |
</forbidden>

---

<required>
| 분류 | 필수 |
|------|------|
| **Server Function** | POST/PUT → inputValidator + middleware |
| **클라이언트** | Server Function → TanStack Query |
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
// Server Function (POST + Validation + Auth)
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))

// Zod v4
const schema = z.object({
  email: z.email(),
  website: z.url().optional(),
})

// TanStack Query
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
})
```
</quick_patterns>
```


</examples>

---

<validation>

| 항목 | 기준 | 검증 |
|------|------|------|
| **토큰 효율** | 500줄 이하 | `wc -l` |
| **XML 태그** | 올바른 중첩 | `grep -o '<[^>]*>'` |
| **예시 품질** | 실행 가능 | 테스트 |
| **긍정형** | Don't < 5 | `grep -c "Don't"` |

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

## 작성 원칙

| 원칙 | 방법 |
|------|------|
| **Show, Don't Tell** | 설명보다 코드 예시 |
| **High Density** | 1줄당 최대 정보 압축 |
| **Copy-Paste Ready** | 바로 사용 가능한 패턴 |
| **Version Explicit** | 라이브러리 버전 명시 |
| **Positive Language** | "Do X" > "Don't Y" |

## 일반적 실수

| 실수 | 올바른 방법 |
|------|------------|
| 장황한 설명 | 표 형식 + 코드 예시 |
| XML 태그 없음 | 모든 섹션 태그 구분 |
| 추상적 예시 | 실행 가능한 코드 |
| 중복 정보 | @imports 분리 |
| 버전 누락 | 모든 라이브러리 버전 명시 |

## 문서별 팁

| 문서 | 핵심 |
|------|------|
| **CLAUDE.md** | @imports 최대 활용, tech_stack 표준화 |
| **SKILL.md** | trigger_conditions 명확, workflow 코드 중심 |
| **COMMAND.md** | purpose 간결, workflow 실행 가능 코드 |

</best_practices>
