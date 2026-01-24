---
name: docs-creator
description: Claude Code 문서 작성 가이드. CLAUDE.md, SKILL.md, COMMAND.md 등 효과적인 문서 작성 시 사용.
metadata:
  author: kood
  version: "1.0.0"
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Docs Creator Skill

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

<parallel_agent_execution>

## 병렬 에이전트 실행

**목표:** 독립적인 문서 작업을 동시에 처리하여 작업 시간 최소화, 품질 향상.

### 핵심 원칙

| 원칙 | 실행 방법 | 효과 |
|------|----------|------|
| **PARALLEL** | 단일 메시지에서 여러 에이전트 동시 호출 | 5-10배 속도 향상 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | 품질 향상, 컨텍스트 격리 |
| **SMART MODEL** | 작업 복잡도별 모델 선택 | 비용 최적화 |

**기본 패턴:**
```typescript
// ❌ 순차 실행 (느림)
Task(...) // 60초 대기
Task(...) // 60초 대기
// 총 120초

// ✅ 병렬 실행 (빠름) - 단일 메시지에서
Task(subagent_type="explore", model="haiku", prompt="...")
Task(subagent_type="document-writer", model="haiku", prompt="...")
// 총 60초 (가장 긴 작업 기준)
```

---

### Phase별 에이전트 활용

#### Phase 1: 탐색 + 문서 정의 (병렬)

```typescript
// 탐색: 프로젝트 구조 파악 (haiku, 빠름)
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 코드베이스 구조 분석 - 주요 패턴, 라이브러리, 컨벤션 파악")

// 분석: 문서 구조 결정 (sonnet, 정확)
Task(subagent_type="analyst", model="sonnet",
     prompt="CLAUDE.md 작성을 위한 핵심 규칙 추출 - forbidden, required, patterns 식별")
```

**예상 시간:** 60초 (병렬 실행)

---

#### Phase 2: 병렬 문서 작성

```typescript
// 여러 문서 동시 작성 (haiku/sonnet)
Task(subagent_type="document-writer", model="haiku",
     prompt=`CLAUDE.md 작성
     - 프로젝트: TanStack Start
     - 포함: forbidden, required, tech_stack, quick_patterns
     - 참조: @docs/library/tanstack-start/index.md`)

Task(subagent_type="document-writer", model="haiku",
     prompt=`Git 규칙 문서 작성
     - 파일: .claude/instructions/git-rules.md
     - 포함: 커밋 메시지 규칙, 브랜치 전략`)

Task(subagent_type="document-writer", model="sonnet",
     prompt=`Prisma 가이드 작성
     - 파일: docs/library/prisma/index.md
     - 버전: 7.x 특화
     - Multi-file 구조 패턴`)
```

**예상 시간:** 60초 (3개 문서 동시 작성)

---

#### Phase 3: 검증 (복잡한 경우)

```typescript
// 아키텍처 문서는 Opus로 검토
Task(subagent_type="architect", model="opus",
     prompt=`작성된 CLAUDE.md 검토
     - XML 구조 올바름
     - 예시 코드 실행 가능
     - 토큰 효율성 (500줄 이하)
     - 버전 명시 확인`)
```

**적용:** 복잡한 아키텍처 문서, 보안/성능 패턴 문서만.

---

### 에이전트별 역할

| 에이전트 | 모델 | 문서 작업 용도 | 병렬 가능 |
|---------|------|---------------|----------|
| **explore** | haiku | 프로젝트 구조 탐색, 기존 패턴 검색 | ✅ |
| **analyst** | sonnet | 규칙 추출, 문서 구조 결정 | ✅ |
| **document-writer** | haiku/sonnet | 실제 문서 작성 (CLAUDE.md, SKILL.md) | ✅ |
| **architect** | opus | 복잡한 아키텍처 문서 검토 | ✅ |

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

#### 패턴 1: 여러 문서 동시 작성

**상황:** CLAUDE.md + 3개 라이브러리 가이드 작성

```typescript
// 단일 메시지에서 4개 작업 병렬 실행
Task(subagent_type="document-writer", model="haiku",
     prompt="CLAUDE.md 작성 - 프로젝트 규칙")
Task(subagent_type="document-writer", model="haiku",
     prompt="TanStack Start 가이드 작성")
Task(subagent_type="document-writer", model="haiku",
     prompt="Prisma 가이드 작성")
Task(subagent_type="document-writer", model="haiku",
     prompt="Zod 가이드 작성")
```

**효과:**
- 순차 실행: 240초 (60 × 4)
- 병렬 실행: 60초
- **4배 향상**

---

#### 패턴 2: 조사 + 작성 병렬

**상황:** 새 라이브러리 문서 작성 (버전/API 조사 필요)

```typescript
// 탐색과 작성 동시 진행
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트에서 React Query 사용 패턴 조사 - 버전, 주요 패턴")

Task(subagent_type="document-writer", model="haiku",
     prompt=`React Query 가이드 초안 작성
     - 기본 구조만 작성 (버전은 나중에 추가)
     - useQuery, useMutation 패턴
     - 에러 처리`)

// 탐색 결과 확인 후 버전 정보 추가
Read(".../react-query-usage.md") // explore 결과
Edit("docs/library/react-query/index.md", ...) // 버전 정보 추가
```

**효과:**
- 대기 시간 제거
- 초안 작성 중 조사 완료

---

#### 패턴 3: 다중 SKILL 문서

**상황:** 5개 스킬 문서 작성

```typescript
// 공통 조사 (1회만)
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트의 스킬 패턴 분석 - 기존 SKILL.md 구조")

// 병렬 작성 (5개 동시)
const skills = ["test-runner", "db-migrate", "api-generator", "ui-builder", "deploy"]
skills.forEach(skill => {
  Task(subagent_type="document-writer", model="haiku",
       prompt=`${skill} 스킬 문서 작성
       - trigger_conditions
       - workflow
       - examples`)
})
```

**효과:**
- 순차: 300초 (60 × 5)
- 병렬: 60초
- **5배 향상**

---

### 모델 라우팅

| 복잡도 | 모델 | 문서 유형 | 비용 | 속도 |
|--------|------|----------|------|------|
| **LOW** | haiku | 간단한 규칙 문서, 반복 패턴 | 💰 | ⚡⚡⚡ |
| **MEDIUM** | sonnet | CLAUDE.md, 라이브러리 가이드 | 💰💰 | ⚡⚡ |
| **HIGH** | opus | 아키텍처 문서, 보안/성능 패턴 | 💰💰💰 | ⚡ |

**선택 기준:**
```typescript
// ✅ 간단한 문서 → haiku
Task(subagent_type="document-writer", model="haiku",
     prompt="Git 커밋 메시지 규칙 문서")

// ✅ 일반 가이드 → sonnet
Task(subagent_type="document-writer", model="sonnet",
     prompt="TanStack Start CLAUDE.md 작성")

// ✅ 복잡한 아키텍처 → opus
Task(subagent_type="architect", model="opus",
     prompt="마이크로서비스 아키텍처 문서 설계 및 검토")
```

---

### 체크리스트

**병렬 실행 전:**
- [ ] 독립적인 작업인가? (서로 의존성 없음)
- [ ] 3개 이상 작업인가? (2개 이하는 순차도 OK)
- [ ] 각 작업의 복잡도별 모델 선택했는가?

**실행 중:**
- [ ] 단일 메시지에서 여러 Task 호출했는가?
- [ ] explore는 haiku 사용했는가?
- [ ] document-writer는 haiku/sonnet 적절히 사용했는가?

**실행 후:**
- [ ] 모든 문서 생성 확인
- [ ] XML 구조 올바름
- [ ] 코드 예시 실행 가능
- [ ] 버전 명시 확인

</parallel_agent_execution>

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
