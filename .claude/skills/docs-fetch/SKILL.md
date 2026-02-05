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
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

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

## 3-Tier Fallback

```
Tier 1 (MCP 도구 우선):
  Firecrawl MCP + SearXNG MCP → /map 구조 파악 → /crawl 수집 + 보충 검색 병렬
  Context7 MCP               → 라이브러리 문서 직접 조회

Tier 2 (내장 도구):
  llms.txt     → WebFetch("{도메인}/llms.txt") 우선 확인
  GitHub       → gh API + GitHub MCP (README, docs/, CHANGELOG)
  WebFetch     → 공식 문서 핵심 페이지 직접 읽기
  WebSearch    → 보충 검색

Tier 3 (최후 수단):
  Playwright   → SPA 사이트, JS 렌더링 필요 시 crawler skill 연계
```

### 소싱 우선순위 (항상 이 순서)

| 순서 | 소스 | 이유 |
|------|------|------|
| **1** | `llms.txt` / `llms-full.txt` | AI 최적화 완료, 토큰 효율 최고 |
| **2** | GitHub MCP + gh CLI | README, docs/, CHANGELOG 직접 접근 |
| **3** | Firecrawl `/map`→`/crawl` + SearXNG 검색 | 문서 일괄 수집 + breaking changes 보충 (동시 실행) |
| **4** | Context7 MCP | 라이브러리 문서 즉시 조회, 업데이트 지연 가능성 있음 |
| **5** | WebFetch | 개별 페이지 직접 읽기 |
| **6** | WebSearch | 최후 보충 검색 |

</sourcing_strategy>

---

<workflow>

## Phase 0: 환경 감지 + 입력 파싱

```
1. 입력 파싱
   - "prisma@7" → name: prisma, version: 7
   - "https://..." → URL에서 라이브러리명 추론

2. MCP 도구 감지
   - Firecrawl MCP 사용 가능? → Tier 1 활성화
   - SearXNG MCP 사용 가능?  → Tier 1 검색 활성화 (Firecrawl과 병렬)
   - Context7 MCP 사용 가능? → Tier 1 문서 조회 활성화
   - GitHub MCP 사용 가능?   → GitHub MCP 우선 사용
   - 모두 없으면             → Tier 2 (내장 도구만)

3. 기존 문서 확인
   - docs/library/[name]/ 이미 존재? → 업데이트 모드
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

### Step 1-4: 보충 검색 (병렬)

```typescript
// SearXNG MCP 있으면 사용, 없으면 WebSearch
Task(subagent_type="researcher", model="haiku",
     prompt="{name} v{version} breaking changes, migration guide 검색.
     SearXNG MCP 있으면 사용, 없으면 WebSearch.")

Task(subagent_type="researcher", model="haiku",
     prompt="{name} v{version} best practices, common mistakes 검색.
     SearXNG MCP 있으면 사용, 없으면 WebSearch.")
```

---

## Phase 2: 핵심 페이지 읽기

### Tier 1 경로 (Firecrawl + SearXNG MCP 있을 때)

```typescript
// Firecrawl + SearXNG 병렬 실행
// 1. 문서 사이트 URL 구조 파악 + 보충 검색 동시
firecrawl_map({ url: "{docs_url}" })
searxng_search("{name} v{version} breaking changes migration")

// 2. 핵심 페이지 일괄 크롤링 (최대 50페이지)
firecrawl_crawl({
  url: "{docs_url}",
  limit: 50,
  scrapeOptions: { formats: ["markdown"] }
})
```

### Tier 2 경로 (내장 도구만)

```typescript
// llms.txt 링크가 있으면 → 링크된 페이지만 WebFetch
// 없으면 → GitHub docs/ + 공식 문서 상위 10-15페이지

// 병렬 WebFetch (최대 5개씩)
Task(subagent_type="researcher", model="haiku",
     prompt="다음 URL들을 WebFetch로 읽기: {url_list_1}")
Task(subagent_type="researcher", model="haiku",
     prompt="다음 URL들을 WebFetch로 읽기: {url_list_2}")
Task(subagent_type="researcher", model="haiku",
     prompt="다음 URL들을 WebFetch로 읽기: {url_list_3}")
```

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
// 수집된 정보 기반 분석 (Phase 3 전에 실행)
Task(subagent_type="analyst", model="sonnet",
     prompt=`수집된 {name} v{version} 정보를 분석:
     - 문서에 반드시 포함해야 할 핵심 주제 식별
     - 누락된 정보 영역 (추가 수집 필요?)
     - forbidden/required 후보 패턴 추출
     - 버전별 breaking changes 정리`)

Task(subagent_type="architect", model="sonnet",
     prompt=`{name} v{version} 라이브러리 아키텍처 분석:
     - 핵심 API surface (public API 구조)
     - 주요 사용 패턴 및 안티패턴
     - 의존성 관계 및 설정 요구사항
     - quick_reference에 포함할 코드 패턴 선별`)
```

**분석 결과** → Phase 3 document-writer에 전달하여 문서 품질 향상

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
// 생성된 문서 품질 검증
Task(subagent_type="critic", model="sonnet",
     prompt=`생성된 docs/library/{name}/index.md 문서 검증:
     - <context>, <forbidden>, <required>, <quick_reference>, <version_info> 섹션 존재 여부
     - 버전 정보 정확성
     - 코드 예시 복사 가능 여부
     - 기존 docs/ 포맷과 일관성
     - 한글 주석, ✅/❌ 마커 사용 여부
     OKAY/REJECT 판정.`)
```

**REJECT 시** → 피드백 기반으로 document-writer 재실행
**OKAY 시** → 결과 리포트 출력

```
결과 리포트:
   - 생성된 파일 목록
   - 소싱 경로 (어떤 Tier 사용했는지)
   - 토큰 수 추정
   - critic 검증 결과
```

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

## MCP 도구 활용

### Firecrawl MCP (자체 호스팅)

```bash
# 셋업
claude mcp add firecrawl \
  -e FIRECRAWL_API_URL=http://localhost:3002 \
  -- npx -y firecrawl-mcp
```

| 도구 | 용도 |
|------|------|
| `firecrawl_map` | 문서 사이트 URL 구조 파악 |
| `firecrawl_crawl` | 핵심 페이지 일괄 수집 (MD 변환) |
| `firecrawl_scrape` | 단일 페이지 스크랩 |

### SearXNG MCP (자체 호스팅)

```bash
# 셋업
claude mcp add searxng \
  -e SEARXNG_BASE_URL=http://localhost:8080 \
  -- npx -y @sacode/searxng-simple-mcp
```

| 용도 | 검색 쿼리 예시 |
|------|---------------|
| Breaking Changes | `"{name} v{ver} breaking changes migration"` |
| Best Practices | `"{name} v{ver} best practices common mistakes"` |
| 비교 | `"{name} vs {alt} comparison 2026"` |

### Context7 MCP

| 도구 | 용도 |
|------|------|
| `resolve-library-id` | 라이브러리 식별자 확인 |
| `get-library-docs` | 라이브러리 문서 조회 (업데이트 지연 가능성 있음) |

### GitHub MCP

| 도구 | 용도 |
|------|------|
| `get_file_contents` | README.md, docs/ 폴더 내용 |
| `list_commits` | 최근 변경사항 확인 |
| `get_latest_release` | 최신 릴리스 + CHANGELOG |

### MCP 미설치 시 폴백

| MCP 없음 | 대체 도구 |
|----------|----------|
| Firecrawl + SearXNG | WebFetch (페이지별) + WebSearch (내장) |
| Context7 | WebFetch (개별 페이지 직접 읽기) |
| GitHub MCP | `gh api` (CLI) |

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

## 예시 1: llms.txt 있는 라이브러리

```bash
사용자: /docs-fetch zod@4

Phase 0: 환경 감지
  → Firecrawl MCP: 없음, SearXNG MCP: 없음 → Tier 2

Phase 1: 정보 수집 (병렬)
  researcher 1: WebFetch("https://zod.dev/llms.txt") → ✅ 있음!
  researcher 2: npm registry → version 4.x, repo: colinhacks/zod
  researcher 3: gh api repos/colinhacks/zod/readme
  researcher 4: WebSearch "zod v4 breaking changes"

Phase 2: llms.txt 링크된 페이지만 WebFetch
  → 10페이지 병렬 읽기 (효율적)

Phase 3: 문서 생성
  document-writer (sonnet): docs/library/zod/index.md
  document-writer (haiku): docs/library/zod/validation.md

Phase 4: 저장
  → docs/library/zod/ 에 2개 파일 생성
  → "CLAUDE.md에 @docs/library/zod/index.md 추가 권장"
```

## 예시 2: Firecrawl + SearXNG MCP 있는 경우

```bash
사용자: /docs-fetch tanstack-query@5

Phase 0: 환경 감지
  → Firecrawl MCP: ✅ + SearXNG MCP: ✅ → Tier 1 활성화

Phase 1: 정보 수집 (병렬)
  firecrawl_map: https://tanstack.com/query/latest/docs → URL 200개 발견
  searxng: "tanstack query v5 breaking changes migration" → 보충 정보
  researcher 1: npm registry → version 5.x
  researcher 2: GitHub README + CHANGELOG
  researcher 3: Context7 → 문서 조회

Phase 2: Firecrawl 일괄 수집
  firecrawl_crawl: 핵심 50페이지 → 깨끗한 MD

Phase 3: 문서 생성 (병렬)
  document-writer (sonnet): index.md
  document-writer (haiku): use-query.md
  document-writer (haiku): use-mutation.md
  document-writer (haiku): invalidation.md

Phase 4: 저장
  → docs/library/tanstack-query/ 에 4개 파일 생성
```

## 예시 3: URL 직접 지정

```bash
사용자: /docs-fetch https://www.prisma.io/docs/orm

Phase 0: URL 파싱 → name: prisma, docs_url: prisma.io/docs/orm

Phase 1-2: WebFetch로 주요 페이지 수집
Phase 3: 문서 생성
Phase 4: docs/library/prisma/ 에 저장
```

</examples>

---

<validation>

## 검증 체크리스트

**실행 전:**
- [ ] ARGUMENT 확인 (라이브러리명 또는 URL)
- [ ] MCP 도구 감지 완료
- [ ] llms.txt 확인 완료

**수집 후:**
- [ ] 최소 README + 1개 이상 문서 페이지 수집
- [ ] 버전 정보 확인
- [ ] Breaking Changes 확인 시도

**생성 후:**
- [ ] `<context>` 섹션 포함
- [ ] `<forbidden>` 섹션 포함 (Breaking Changes 있으면)
- [ ] `<required>` 섹션 포함
- [ ] `<quick_reference>` 코드 예시 포함
- [ ] `<version_info>` 버전 명시
- [ ] 한글 주석 포함
- [ ] ✅/❌ 마커 사용

**저장 후:**
- [ ] docs/library/[name]/ 에 파일 저장됨
- [ ] 결과 리포트 출력 (파일 목록 + 소싱 경로)
- [ ] CLAUDE.md @참조 추가 제안

## 절대 금지

- ❌ llms.txt 확인 없이 바로 크롤링
- ❌ 단일 소스만으로 문서 생성 (최소 2개 소스 교차)
- ❌ 버전 정보 누락
- ❌ `<forbidden>` 섹션 없이 생성 (Breaking Changes 확인 필수)
- ❌ 기존 docs 포맷과 다른 형식 사용
- ❌ 결과 저장 없이 종료

</validation>
