---
name: docs-fetch
description: 라이브러리 공식 문서를 수집하여 AI Agent 최적화 문서 자동 생성. llms.txt → GitHub → Firecrawl/SearXNG 순서로 소싱.
metadata:
  author: kood
  version: "1.0.0"
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md
@../../instructions/sourcing/reliable-search.md

# Docs Fetch Skill

> 라이브러리/프레임워크 공식 문서 수집 → AI Agent 최적화 문서 자동 생성

---

<purpose>

Context7 업데이트 지연, Tavily 비용 문제를 해결.
공식 문서를 직접 읽고, 기존 `docs-creator` 포맷으로 AI 최적화 문서 생성.

**입력:** 라이브러리명 또는 URL
**출력:** `docs/library/[name]/index.md` + 주제별 상세 파일

</purpose>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| `/docs-fetch prisma@7` | 라이브러리명+버전으로 문서 생성 |
| `/docs-fetch https://tanstack.com/start/latest/docs` | URL로 문서 생성 |
| "라이브러리 문서 만들어줘" | 라이브러리명 확인 후 실행 |
| "OO 최신 문서로 업데이트" | 기존 문서 재생성 |

</trigger_conditions>

---

<argument_validation>

```
ARGUMENT 없음 → 즉시 질문:

"어떤 라이브러리 문서를 생성할까요?

예시:
- /docs-fetch prisma@7
- /docs-fetch zod@4
- /docs-fetch https://tanstack.com/start/latest/docs"

ARGUMENT 있음 → 다음 단계 진행
```

</argument_validation>

---

<sourcing_strategy>

## 소싱 우선순위 (docs-fetch 특화)

| 순서 | 소스 | 이유 |
|------|------|------|
| **1** | `llms.txt` / `llms-full.txt` | AI 최적화 완료, 토큰 효율 최고 |
| **2** | GitHub MCP + gh CLI | README, docs/, CHANGELOG 직접 접근 |
| **3** | Firecrawl `/map`→`/crawl` + SearXNG 검색 | 문서 일괄 수집 + breaking changes 보충 (동시 실행) |
| **4** | Context7 MCP | 라이브러리 문서 즉시 조회, 업데이트 지연 가능성 있음 |
| **5** | Jina Reader | `WebFetch('https://r.jina.ai/{URL}')` JS 렌더링 클린 MD (WebFetch 실패 시) |
| **6** | WebFetch | 개별 페이지 직접 읽기 |
| **7** | WebSearch | 최후 보충 검색 |

**Smart Tier Fallback 및 MCP 통합 전략**: @../../instructions/sourcing/reliable-search.md 참조

</sourcing_strategy>

---

<workflow>

## Phase 0: 환경 감지 + 입력 파싱

```
1. 입력 파싱
   - "prisma@7" → name: prisma, version: 7
   - "https://..." → URL에서 라이브러리명 추론

2. MCP 도구 감지 (ToolSearch로 감지)
   - Firecrawl, SearXNG, Context7, GitHub MCP 활성화 여부 확인

3. 버전 최신성 확인
   - npm registry에서 latest 버전 확인 (WebFetch 'https://registry.npmjs.org/{name}/latest')
   - 사용자 지정 버전과 비교, 최신 아니면 경고 표시

4. 기존 문서 확인
   - docs/library/[name]/ 이미 존재? → 생성일 확인
   - 6개월 이상 경과 → "기존 문서 업데이트 권장" 표시
```

---

## Phase 1: 정보 수집 (병렬)

### Step 1-1: llms.txt 확인 (최우선)

```typescript
// 공식 사이트 llms.txt 확인
WebFetch("{공식사이트}/llms.txt", "문서 구조와 핵심 링크 목록 추출")
WebFetch("{공식사이트}/llms-full.txt", "전체 문서 내용 추출")
```

**llms.txt 있으면** → 핵심 링크 목록 획득, Phase 2에서 링크된 페이지만 읽기
**llms-full.txt 있으면** → 전체 내용 이미 확보, Phase 2 대부분 스킵 가능

### Step 1-2: 메타데이터 + GitHub + 코드 탐색 (병렬)

```typescript
// 병렬 실행 (researcher + explore 동시)
Task(subagent_type="researcher", model="haiku",
     prompt="npm registry에서 {name} 패키지 메타데이터 조회:
     - 최신 버전, GitHub repo URL, 공식 사이트 URL
     - WebFetch('https://registry.npmjs.org/{name}/latest')")

Task(subagent_type="researcher", model="haiku",
     prompt="GitHub에서 {name} 문서 수집:
     - gh api repos/{owner}/{repo}/readme
     - gh api repos/{owner}/{repo}/contents/docs
     - CHANGELOG.md 또는 RELEASES
     - GitHub MCP 사용 가능하면 get_file_contents 활용")

Task(subagent_type="explore", model="haiku",
     prompt="{name} GitHub repo 코드 구조 탐색:
     - 주요 export 패턴 (public API surface)
     - 타입 정의 파일 (*.d.ts, types/)
     - 설정 파일 패턴 (config, setup)
     - 예제 코드 (examples/, __tests__/)")
```

### Step 1-3: Context7 조회 (병렬)

```typescript
// Context7 MCP 있으면 → 라이브러리 문서 즉시 조회
// Context7는 업데이트 지연 가능성 있으므로 다른 소스와 교차 확인
Task(subagent_type="researcher", model="haiku",
     prompt="Context7 MCP로 {name} 라이브러리 문서 조회.
     Context7 MCP 없으면 스킵.")
```

### Step 1-4: 보충 검색 (병렬, 현재 연도 포함 필수)

```typescript
// 현재 연도 포함 필수 (2026년 기준)
Task(subagent_type="researcher", model="haiku",
     prompt="{name} v{version} breaking changes 2026 migration guide 검색.
     검색 쿼리에 현재 연도 포함, 12개월 이내 자료 우선.
     'v{version} [2026] migration', '{name} breaking changes 2026' 패턴 사용.")

Task(subagent_type="researcher", model="haiku",
     prompt="{name} v{version} best practices 2026, common mistakes 검색.
     현재 연도 포함, 최신 트렌드 반영.")
```

---

## Phase 2: 핵심 페이지 읽기

| Tier | 경로 | 실행 |
|------|------|------|
| **1 (MCP)** | Firecrawl + SearXNG | `firecrawl_map` → `firecrawl_crawl` (최대 50p) + `searxng_search` 병렬 |
| **2 (내장)** | Jina Reader + WebFetch | llms.txt 링크 우선, SPA 문서는 `r.jina.ai` 경유, 없으면 GitHub docs/ + 공식 문서 10-15p (5개씩 병렬) |

### 공통: Breaking Changes 추출

```
CHANGELOG.md에서 추출할 정보:
- 더 이상 사용 불가한 API → <forbidden>
- 새로 필수가 된 설정 → <required>
- 패키지명 변경 → <forbidden> + <required>
- 기본값 변경 → <required>
```

---

## Phase 2.5: 수집 정보 분석 (analyst + architect 병렬)

```typescript
Task(subagent_type="analyst", model="sonnet",
     prompt=`수집된 {name} v{version} 정보 분석:
     - 수집 자료 발행일 검증 (12개월 초과 시 최신 자료 보충 검색)
     - 핵심 주제 식별, 누락 영역 확인
     - forbidden/required 패턴 추출, breaking changes 정리`)

Task(subagent_type="architect", model="sonnet",
     prompt=`{name} v{version} 아키텍처 분석:
     - 핵심 API surface, 사용 패턴/안티패턴
     - quick_reference 코드 패턴 선별`)
```

---

## Phase 3: 문서 생성 (병렬 writer)

```typescript
// index.md 생성 (핵심 문서)
Task(subagent_type="document-writer", model="sonnet",
     prompt=`다음 정보를 기반으로 AI Agent 최적화 문서 생성.

     [수집된 정보 전달]

     출력 형식: 아래 템플릿 참조.
     파일 경로: docs/library/{name}/index.md

     필수 섹션: <context>, <forbidden>, <required>, <quick_reference>, <version_info>
     선택 섹션: <setup>, <configuration>, 주제별 섹션`)

// 주제별 상세 문서 (필요시 병렬)
Task(subagent_type="document-writer", model="haiku",
     prompt="[주제1] 상세 문서 생성: docs/library/{name}/[topic1].md")
Task(subagent_type="document-writer", model="haiku",
     prompt="[주제2] 상세 문서 생성: docs/library/{name}/[topic2].md")
```

---

## Phase 4: 저장 + 연결

```
1. docs/library/[name]/ 폴더 생성 (없으면)
2. 생성된 파일 저장
3. CLAUDE.md에 @참조 추가 제안
```

---

## Phase 5: 품질 검증 (critic)

```typescript
Task(subagent_type="critic", model="sonnet",
     prompt=`생성된 docs/library/{name}/index.md 검증:
     - 필수 섹션 (<context>, <forbidden>, <required>, <quick_reference>, <version_info>)
     - 버전 최신성 (npm latest 버전과 비교)
     - 코드 예시 복사 가능 여부
     - 기존 docs/ 포맷 일관성
     OKAY/REJECT 판정.`)
```

**REJECT** → document-writer 재실행 | **OKAY** → 결과 리포트 (파일 목록, 소싱 경로, 검증 결과)

</workflow>

---

<output_template>

## index.md 출력 형식

```markdown
# {라이브러리명}

> **Version {X.x}** | {한줄 설명}

---

<context>
**Purpose:** {목적}
**Generated:** {YYYY-MM-DD}
**Source:** {소스 URL 목록}
**Key Features:**
- {기능 1}
- {기능 2}
- {기능 3}
</context>

<forbidden>
| 분류 | 금지 | 이유 |
|------|------|------|
| {분류} | ❌ {금지 패턴} | {이유} |
</forbidden>

<required>
| 분류 | 필수 | 상세 |
|------|------|------|
| {분류} | ✅ {필수 패턴} | {상세} |
</required>

<setup>
## 설치

```bash
{설치 명령어}
```

## 초기 설정

```typescript
// {설정 코드}
```
</setup>

<quick_reference>
```typescript
// {자주 사용하는 패턴 - 복사 가능}
```
</quick_reference>

<version_info>
**Version:** {X.x}
**Package:** {패키지명}
**Breaking Changes:**
- {변경 1}
- {변경 2}
</version_info>
```

### 주제별 상세 파일

```
docs/library/{name}/
├── index.md          # 개요 + forbidden + required + quick_reference
├── setup.md          # 설치 + 초기 설정 (상세)
├── [topic].md        # 주제별 상세 가이드
└── migration.md      # 마이그레이션 가이드 (메이저 버전 변경 시)
```

</output_template>

---

<parallel_agent_execution>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "docs-fetch-team", description: "문서 수집" })
Task(subagent_type="researcher", team_name="docs-fetch-team", name="researcher", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

## Agent 활용 패턴

| Phase | Agent | Model | 용도 |
|-------|-------|-------|------|
| **1** | researcher x3 | haiku | npm 메타데이터, llms.txt, GitHub 문서 수집 |
| **1** | explore | haiku | GitHub repo 코드 구조 탐색 (API surface, 타입, 예제) |
| **1** | researcher | haiku | Context7 MCP 문서 조회 |
| **1** | researcher x2 | haiku | Firecrawl+SearXNG / WebSearch 보충 검색 |
| **2** | researcher x3 | haiku | WebFetch 멀티페이지 (5개씩 병렬) |
| **2.5** | analyst | sonnet | 수집 정보 분석, 핵심 주제 식별, 누락 영역 발견 |
| **2.5** | architect | sonnet | 라이브러리 아키텍처 분석, API 패턴, 안티패턴 |
| **3** | document-writer | sonnet | index.md 핵심 문서 생성 |
| **3** | document-writer x N | haiku | 주제별 상세 문서 생성 |
| **5** | critic | sonnet | 생성된 문서 품질 검증 (OKAY/REJECT) |

### 병렬 실행 규칙

```
Phase 1:   7개 동시 실행 (researcher x5 + explore x1 + llms.txt WebFetch)
Phase 2:   3개 researcher 동시 실행 (WebFetch 5페이지씩)
Phase 2.5: 2개 동시 실행 (analyst + architect)
Phase 3:   1 sonnet + N haiku 동시 실행 (index.md + 주제별)
Phase 4:   순차 (저장 + 연결)
Phase 5:   critic 검증 → REJECT 시 Phase 3 재실행
```

### Agent 협업 흐름

```
researcher(수집) ──┐
explore(탐색)   ──┤
                   ├→ analyst(분석) + architect(패턴) ──→ document-writer(생성) ──→ critic(검증)
researcher(검색) ──┘                                                                    │
                                                                              REJECT → 재생성
```

</parallel_agent_execution>

---

<mcp_integration>

## MCP 도구별 용도

| MCP | 도구 | 용도 |
|-----|------|------|
| **Firecrawl** | `firecrawl_map/crawl/scrape` | 문서 사이트 구조 파악 → 일괄 수집 (MD 변환) |
| **SearXNG** | `web_search` | Breaking changes 검색 (연도 포함 필수) |
| **Context7** | `resolve-library-id`, `get-library-docs` | 라이브러리 문서 즉시 조회 (업데이트 지연 가능) |
| **GitHub** | `get_file_contents`, `get_latest_release` | README, docs/, CHANGELOG |

**MCP 미설치** → Jina Reader (`r.jina.ai`) → WebFetch (페이지별) → WebSearch (내장) → `gh api` (CLI) 폴백

</mcp_integration>

---

<chaining>

## Skill 체이닝

```
/docs-fetch prisma@7
    ↓ 문서 생성 완료
/docs-refactor docs/library/prisma/index.md
    ↓ 토큰 50% 최적화
/docs-creator
    ↓ CLAUDE.md에 @참조 추가
```

| 순서 | Skill | 역할 |
|------|-------|------|
| 1 | **docs-fetch** | 외부 문서 수집 + AI 최적화 문서 생성 |
| 2 | **docs-refactor** | 생성된 문서 토큰 효율 개선 (선택) |
| 3 | **docs-creator** | CLAUDE.md 업데이트, @참조 추가 (선택) |

</chaining>

---

<examples>

## 핵심 예시: llms.txt 있는 라이브러리

```bash
/docs-fetch zod@4

Phase 0: npm latest 확인 → 4.x 최신 ✅
Phase 1: llms.txt ✅ + GitHub + 검색 (병렬, 연도 포함)
Phase 2: llms.txt 링크 10페이지 WebFetch
Phase 2.5: analyst (발행일 검증 + 주제 식별) + architect (패턴 선별)
Phase 3: index.md + validation.md 생성
Phase 5: critic 검증 ✅ → docs/library/zod/ 저장
```

**Firecrawl MCP 있으면**: `/map` → `/crawl` 50페이지 일괄 수집
**URL 지정**: `/docs-fetch https://www.prisma.io/docs/orm` → 직접 WebFetch

</examples>

---

<validation>

## 검증 체크리스트

| 단계 | 체크 |
|------|------|
| **실행 전** | ARGUMENT, MCP 감지, llms.txt 확인, npm latest 버전 확인 |
| **수집 후** | 최소 README + 1p 문서, 수집 자료 발행일 12개월 이내, Breaking Changes 확인 |
| **생성 후** | 필수 섹션 (`<context>`, `<forbidden>`, `<required>`, `<quick_reference>`, `<version_info>`) |
| **저장 후** | docs/library/[name]/ 저장, 결과 리포트, CLAUDE.md @참조 제안 |

## 절대 금지

- ❌ llms.txt 확인 없이 크롤링
- ❌ 단일 소스만으로 문서 생성 (최소 2개 교차)
- ❌ 버전 정보 누락, 연도 없는 검색 쿼리
- ❌ 기존 docs 포맷과 다른 형식

</validation>
