---
description: Claude Code 문서 작성 가이드
allowed-tools: Read, Write, Glob, Grep
argument-hint: <문서 유형: CLAUDE.md | SKILL.md | COMMAND.md>
---

# Docs Creator Command

> Claude Code 문서 (CLAUDE.md, SKILL.md, COMMAND.md)를 Anthropic 가이드라인에 따라 효과적으로 작성

<purpose>

**목표:** 고밀도, 실행 가능한, 유지보수 가능한 문서 작성

</purpose>

---

<trigger_conditions>

| 상황 | 작성 필요 |
|------|----------|
| **새 프로젝트** | CLAUDE.md 생성 |
| **새 스킬** | SKILL.md 생성 |
| **새 커맨드** | COMMAND.md 생성 |
| **문서 부재** | 프로젝트 규칙 문서화 |
| **지식 공유** | 팀 온보딩 가이드 |

</trigger_conditions>

---

<forbidden>

| 분류 | 금지 사항 |
|------|----------|
| **설명** | 장황한 설명, 불필요한 텍스트, 중복 정보 |
| **구조** | XML 태그 없는 복잡 구조, 모호한 지시 |
| **표현** | 부정형 지시 (Don't X → Do Y) |
| **복잡도** | 복잡한 조건문, 모든 엣지 케이스 |
| **강조** | 과도한 강조 (CRITICAL, MUST 남발) |

</forbidden>

---

<required>

| 분류 | 필수 사항 |
|------|----------|
| **구조** | XML 태그 섹션 구분, 명확한 계층 |
| **표현** | 표 형식 압축, ✅/❌ 마커 |
| **예시** | 코드/예시 중심, 복사 가능 패턴 |
| **로딩** | @imports로 just-in-time |
| **지시** | 명시적 지시, 긍정형 표현 |
| **버전** | 라이브러리 버전 명시 |

</required>

---

<document_types>

## CLAUDE.md - 프로젝트 규칙

**용도:** 프로젝트별 코딩 규칙, 금지/필수 사항, 빠른 참조

**구조:**
```markdown
# CLAUDE.md - [프로젝트명]

<instructions>
@path/to/common-rules.md
@docs/library/[라이브러리]/index.md
</instructions>

---

<forbidden>
| 분류 | 금지 |
|------|------|
| **Git** | AI 표시, 이모지, 여러 줄 |
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
// 복사 가능한 패턴
const example = () => { ... }
```
</quick_patterns>
```

---

## SKILL.md - 재사용 작업

**용도:** 특정 작업 자동화 스킬 정의

**구조:**
```markdown
---
name: skill-name
description: 짧은 설명 (1줄)
---

<trigger_conditions>
| 키워드/상황 | 반응 |
|-----------|------|
| "키워드" | 즉시 실행 |
</trigger_conditions>

---

<workflow>
<step number="1">
<action>액션 설명</action>
<tools>Tool1, Tool2</tools>
</step>
</workflow>

---

<examples>
```typescript
// 실제 코드
```
</examples>
```

---

## COMMAND.md - CLI 커맨드

**용도:** 슬래시 커맨드 정의 (/commit, /review)

**구조:**
```markdown
---
description: 커맨드 설명
allowed-tools: Read, Edit, Bash
argument-hint: <인자 설명>
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
✅/❌ 비교 예시
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
