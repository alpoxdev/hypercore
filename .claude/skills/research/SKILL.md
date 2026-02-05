---
name: research
description: 범용 자료조사 후 사람이 읽기 쉬운 구조화 리포트 생성. 모든 검색 채널(WebSearch, WebFetch, GitHub MCP, Firecrawl, SearXNG) 동원.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Research Skill

> 범용 자료조사 → 사람이 읽기 쉬운 구조화 리포트 자동 생성

---

<purpose>

brainstorm이 **아이디어 발산**이라면, research는 **팩트 수렴**.
docs-fetch가 **AI용 문서**라면, research는 **사람이 읽는 리포트**.

**입력:** 주제 (자연어) + 선택적 깊이 (--quick/--deep)
**출력:** `.claude/research/[NN].주제_요약.md` (Consulting Style 리포트)

</purpose>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| `/research AI 에이전트 프레임워크 비교` | 기술 비교 조사 |
| `/research --deep 한국 SaaS 시장 트렌드` | 심층 시장 조사 |
| `/research --quick WebSocket vs SSE` | 빠른 기술 비교 |
| "OO에 대해 자료조사 해줘" | 주제 확인 후 실행 |
| "OO 트렌드/현황 알아봐줘" | 트렌드 조사 |

</trigger_conditions>

---

<argument_validation>

```
ARGUMENT 없음 → 즉시 질문:

"어떤 주제를 조사할까요?

예시:
- /research AI 에이전트 프레임워크 비교
- /research --deep 한국 핀테크 시장 트렌드 2026
- /research --quick gRPC vs REST 성능 비교"

ARGUMENT 있음 → 다음 단계 진행
```

</argument_validation>

---

<depth_levels>

## 조사 깊이

| 설정 | quick | standard (기본) | deep |
|------|-------|----------------|------|
| **플래그** | `--quick` | (없음) | `--deep` |
| **검색 쿼리** | 3-5개 | 5-10개 | 10-15개 |
| **병렬 에이전트** | 2-3개 | 3-5개 | 5-7개 |
| **Iterative Search** | X | X | O (2차 수집) |
| **소스 최소** | 5개 | 10개 | 20개+ |
| **리포트 길이** | 500-1000자 | 1500-3000자 | 3000-6000자 |

</depth_levels>

---

<topic_classification>

## 주제 유형 분류

Phase 0에서 자동 분류 → 채널 조합 결정:

| 유형 | 키워드 예시 | 1차 채널 | 2차 채널 |
|------|-----------|---------|---------|
| **기술 비교** | "vs", "비교", "선택" | WebSearch + GitHub MCP/gh | Firecrawl (공식 문서) |
| **시장/트렌드** | "시장", "트렌드", "현황" | WebSearch | Firecrawl (리포트 사이트) |
| **경쟁사 분석** | "경쟁사", "대안", "alternative" | WebSearch + GitHub MCP | WebFetch |
| **학술/개념** | "원리", "이론", "논문" | WebSearch (arxiv, scholar) | WebFetch |
| **프로젝트 내부** | "우리 코드", "현재 구현" | explore (haiku) + Grep | - |
| **라이브러리** | 패키지명@버전 | → **docs-fetch 위임** | - |

</topic_classification>

---

<sourcing_strategy>

## 검색 채널 전략: Smart Tier Fallback

```
Tier 1 (MCP 도구 있으면 우선):
  SearXNG MCP  → 246+ 엔진 메타검색 (무제한, 프라이버시)
  Firecrawl MCP → 웹페이지 → 깨끗한 MD (/map + /scrape)
  GitHub MCP   → 코드/리포/이슈/릴리스 검색

Tier 2 (내장 도구 - 항상 사용 가능):
  WebSearch    → 기본 웹 검색
  WebFetch     → 개별 페이지 읽기 (HTML→MD)
  gh CLI       → GitHub API (Bash)

Tier 3 (보충):
  Playwright   → SPA/JS 렌더링 필요 시 (crawler skill 연계)
```

### MCP 감지 로직

```
Phase 0에서 ToolSearch로 MCP 가용성 확인:
  - "firecrawl" → Firecrawl MCP 도구 있으면 Tier 1 활성화
  - "searxng"   → SearXNG MCP 도구 있으면 Tier 1 검색 활성화
  - "github"    → GitHub MCP 도구 확인

MCP 없으면 → Tier 2 내장 도구만으로 전체 워크플로우 동작
```

### 채널별 용도

| 채널 | 최적 용도 | 한계 |
|------|----------|------|
| **SearXNG MCP** | 범용 검색, breaking changes, 트렌드 | 자체 호스팅 필요 |
| **Firecrawl MCP** | 문서 사이트 일괄 수집, URL 구조 파악 | 자체 호스팅 필요 |
| **GitHub MCP** | 코드 검색, 리포 분석, 릴리스 확인 | GitHub 콘텐츠만 |
| **WebSearch** | 빠른 범용 검색 | 결과 수 제한 |
| **WebFetch** | 특정 URL 직접 읽기 | 1페이지씩, JS 미지원 |
| **gh CLI** | GitHub API 직접 호출 | GitHub만 |

</sourcing_strategy>

---

<workflow>

## 실행 흐름

| Phase | 작업 | 도구 | 깊이별 |
|-------|------|------|--------|
| **0** | 입력 파싱 + 환경 감지 + 주제 분류 | ToolSearch | 공통 |
| **1** | 검색 전략 수립 (쿼리 생성) | Sequential Thinking (2단계) | 공통 |
| **2** | 병렬 자료 수집 | Task × 2-7 (researcher + explore) | 에이전트 수 다름 |
| **3** | Iterative Deep Search (2차 수집) | Task × 2-3 (researcher) | **deep만** |
| **4** | 리포트 생성 | Task (document-writer) | 길이 다름 |
| **5** | 저장 + 제시 | Write + 터미널 출력 | 공통 |

---

### Phase 0: 입력 파싱 + 환경 감지

```
1. 입력 파싱
   - 주제 추출
   - 깊이 플래그: --quick / (기본) / --deep
   - 특수 지시: "한국어 소스 우선", "2026년 이후만" 등

2. 주제 유형 분류
   - <topic_classification> 테이블 참조
   - 라이브러리 주제 → docs-fetch 위임 후 종료

3. MCP 가용성 감지
   - ToolSearch("firecrawl"), ToolSearch("searxng"), ToolSearch("github")
   - 가용 채널 목록 확정

4. 기존 조사 확인
   - .claude/research/ 에 동일 주제 존재? → 업데이트 모드
```

---

### Phase 1: 검색 전략 수립

```
Sequential Thinking (2단계):

thought 1: 주제 분석
  - 핵심 질문 3-5개 도출
  - 주제 유형 확정 (기술/시장/경쟁사/학술)
  - 검색 범위 결정 (시간, 지역, 언어)

thought 2: 검색 쿼리 생성
  - 다각도 검색 쿼리 생성 (깊이별 수량)
  - 채널별 쿼리 배분
  - 에이전트 역할 분배
```

**쿼리 생성 원칙:**
- 동일 주제를 다른 각도에서 검색 (정의, 비교, 트렌드, 사례, 한계)
- 영어 + 한국어 쿼리 혼합
- 연도 포함 (최신성 보장)

---

### Phase 2: 병렬 자료 수집

```typescript
// 패턴 1: 기술 비교 (standard)
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '기술 A 장단점, 성능, 사용 사례 조사. WebSearch + WebFetch 사용.' })
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '기술 B 장단점, 성능, 사용 사례 조사. WebSearch + WebFetch 사용.' })
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '기술 A vs B 벤치마크, 비교 기사, 실사용 후기 검색.' })
Task({ subagent_type: 'researcher', model: 'haiku',
       prompt: 'GitHub에서 기술 A/B 관련 리포지토리 스타 수, 최근 활동, 이슈 분석.' })

// 패턴 2: 시장/트렌드 (standard)
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '[주제] 시장 규모, 성장률, 주요 플레이어 조사.' })
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '[주제] 2025-2026 트렌드, 전문가 예측 조사.' })
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '[주제] 한국 시장 특화 정보, 국내 사례 조사.' })

// 패턴 3: 경쟁사 분석 (standard)
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '경쟁사 A 기능, 가격, 장단점 조사.' })
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '경쟁사 B 기능, 가격, 장단점 조사.' })
Task({ subagent_type: 'researcher', model: 'sonnet',
       prompt: '경쟁사 비교 리뷰, 사용자 평가 검색.' })
```

**에이전트 프롬프트 필수 포함:**
- 검색 쿼리 (구체적으로)
- 사용할 도구 (WebSearch, WebFetch, GitHub MCP 등)
- 수집할 정보 유형 (팩트, 데이터, 사례, 의견)
- **출처 URL 필수 기록** 지시

---

### Phase 3: Iterative Deep Search (deep 모드만)

```
1차 수집 결과 분석 (Sequential Thinking 1단계):
  - 커버된 영역 vs 빈 영역 식별
  - "답변되지 않은 질문" 목록 도출
  - 추가 검색 쿼리 2-5개 생성

2차 수집:
  Task (researcher × 2-3): 빈 영역 집중 검색
```

---

### Phase 4: 리포트 생성

```typescript
Task({ subagent_type: 'document-writer', model: 'sonnet',
       prompt: `다음 수집 자료를 기반으로 리포트 작성.

       [수집된 자료 전달]

       형식: <report_template> 섹션 참조.
       파일 경로: .claude/research/[NN].주제_요약.md

       필수:
       - Executive Summary 250-400자 (결론 우선)
       - 모든 핵심 주장에 출처 URL 표시
       - 비교 대상 있으면 비교 테이블 포함
       - 실행 가능한 권장사항
       - 참고자료 섹션 (제목 + URL + 1줄 요약)` })
```

---

### Phase 5: 저장 + 제시

```
1. 넘버링 결정
   - .claude/research/ 기존 파일 조회 → 다음 번호
   - 파일명: [NN].주제_요약.md (한글, 언더스코어)

2. 저장
   - mkdir -p .claude/research
   - Write → .claude/research/[NN].주제_요약.md

3. 터미널 출력
   - Executive Summary 전문 출력
   - 핵심 발견사항 3-5개 요약
   - "전체 리포트: .claude/research/[NN].주제_요약.md" 안내
```

</workflow>

---

<report_template>

## 리포트 템플릿

```markdown
# [주제] 조사 리포트

> **조사일:** YYYY-MM-DD | **깊이:** quick/standard/deep | **소스:** N개 검토, M개 인용

---

## Executive Summary

[250-400자. 핵심 발견사항 3-5개를 결론 우선으로 서술.
가장 중요한 결론을 첫 문장에 배치 (McKinsey Pyramid Principle).]

---

## 1. 조사 개요

### 1.1 배경
[왜 이 조사가 필요한가]

### 1.2 조사 범위
[포함/제외 범위, 시간 범위, 지역]

### 1.3 방법론
[사용한 검색 채널, 수집 소스 수, 검색 쿼리 개수]

---

## 2. 핵심 발견사항

### 2.1 [발견사항 1 제목]

**핵심:** [한 문장 요약]

[상세 설명. 데이터, 수치, 사례 포함.]

> 출처: [제목](URL)

### 2.2 [발견사항 2 제목]
...

(발견사항 개수: quick 3개 / standard 5개 / deep 7개+)

---

## 3. 비교 분석
(비교 대상이 있을 때만 포함)

| 기준 | 옵션 A | 옵션 B | 옵션 C |
|------|--------|--------|--------|
| [기준 1] | ... | ... | ... |
| [기준 2] | ... | ... | ... |
| **종합 평가** | ... | ... | ... |

---

## 4. 트렌드 및 시사점

- **트렌드 1:** [설명] ([출처](URL))
- **트렌드 2:** [설명] ([출처](URL))

---

## 5. 결론 및 권장사항

### 핵심 결론
[Executive Summary의 확장. 조사에서 도출된 최종 판단.]

### 권장사항
1. **[권장 1]:** [구체적이고 실행 가능한 액션]
2. **[권장 2]:** [구체적이고 실행 가능한 액션]

### 추가 조사 필요 영역
- [이번 조사에서 충분히 커버하지 못한 영역]

---

## 참고자료

### 공식 문서 / 1차 자료
- [제목](URL) - [핵심 내용 1줄]

### 기술 블로그 / 분석
- [제목](URL) - [핵심 내용 1줄]

### 기타
- [제목](URL) - [핵심 내용 1줄]

---

**메타데이터**
- 생성일: YYYY-MM-DD
- 검색 채널: [사용한 도구 목록]
- 검색 쿼리: N개
- 검토 소스: N개
- 인용 소스: M개
```

### 리포트 작성 원칙

| 원칙 | 설명 |
|------|------|
| **결론 우선** | Executive Summary에 가장 중요한 결론 먼저 (Pyramid Principle) |
| **팩트 기반** | 모든 핵심 주장에 출처 URL 필수 |
| **시각적 계층** | H1 단 하나, H2-H3 계층, 테이블 적극 활용 |
| **실행 가능** | 권장사항은 구체적이고 바로 실행 가능하게 |
| **Progressive Disclosure** | 요약→상세 순서, 바쁜 독자는 Executive Summary만 읽어도 충분 |

</report_template>

---

<parallel_agent_execution>

## Agent 활용 패턴

### Agent & Model Routing

| Phase | Agent | Model | 용도 |
|-------|-------|-------|------|
| **2** | researcher | sonnet | 웹 검색 + 페이지 읽기 + 출처 수집 |
| **2** | researcher | haiku | GitHub 분석, npm 메타데이터 |
| **2** | explore | haiku | 코드베이스 관련 분석 (있으면) |
| **3** | researcher | sonnet | 2차 심화 검색 (deep 모드) |
| **4** | document-writer | sonnet | 리포트 작성 |

### 병렬 실행 규칙

```
Phase 2: 2-7개 researcher 동시 실행 (깊이에 따라)
  - quick: 2-3개
  - standard: 3-5개
  - deep: 5-7개

Phase 3: 2-3개 researcher 추가 (deep만)

Phase 4: 1개 document-writer (sonnet)

Phase 5: 순차 (저장 + 출력)
```

### researcher 에이전트 프롬프트 템플릿

```
[주제]에 대해 다음을 조사해주세요:

검색할 내용:
- [구체적 질문 1]
- [구체적 질문 2]

사용할 도구:
- WebSearch로 "[검색 쿼리]" 검색
- 유용한 결과는 WebFetch로 상세 읽기
- (GitHub MCP/SearXNG MCP 가용 시) 추가 검색

결과 형식:
- 발견사항별로 정리
- 각 발견사항에 출처 URL 필수
- 데이터/수치가 있으면 포함
- 신뢰도 표시: [확인됨] 2개+ 소스 / [단일 소스] 1개 소스
```

</parallel_agent_execution>

---

<mcp_integration>

## MCP 도구 활용

### Firecrawl MCP (자체 호스팅)

| 도구 | 용도 | 사용 시점 |
|------|------|---------|
| `firecrawl_map` | 사이트 URL 구조 파악 | 문서 사이트 전체 분석 |
| `firecrawl_scrape` | 단일 페이지 → 깨끗한 MD | 핵심 페이지 읽기 |
| `firecrawl_crawl` | 여러 페이지 일괄 수집 | 심층 조사 |

### SearXNG MCP (자체 호스팅)

| 용도 | 검색 쿼리 예시 |
|------|---------------|
| 기술 비교 | `"{A} vs {B} benchmark performance 2026"` |
| 트렌드 | `"{주제} market trends 2026 report"` |
| 사례 | `"{주제} case study enterprise adoption"` |

### GitHub MCP

| 도구 | 용도 |
|------|------|
| `search_repositories` | 관련 리포지토리 검색 (스타 수, 활동량) |
| `search_code` | 특정 패턴/API 사용 사례 검색 |
| `get_latest_release` | 최신 릴리스 + CHANGELOG |
| `list_issues` | 커뮤니티 이슈/문제점 파악 |

### MCP 미설치 시 폴백

| MCP 없음 | 대체 도구 |
|----------|----------|
| SearXNG | WebSearch (내장) |
| Firecrawl | WebFetch (페이지별) |
| GitHub MCP | `gh api` (Bash) 또는 `gh search` |

</mcp_integration>

---

<chaining>

## Skill 체이닝

```
/research AI 에이전트 프레임워크 비교
    ↓ 조사 완료, 기술 선택 결정
/brainstorm 선택한 프레임워크로 구현 아이디어
    ↓ 아이디어 도출 완료
/prd 기능 요구사항 정의
    ↓ PRD 완료
/plan 구현 계획 수립
```

| 방향 | 흐름 | 사용 시점 |
|------|------|---------|
| **research → brainstorm** | 팩트 조사 → 아이디어 도출 | 기술 선택 후 구현 아이디어 |
| **research → prd** | 시장 조사 → 요구사항 정의 | 시장 데이터 기반 기획 |
| **brainstorm → research** | 아이디어 → 실현 가능성 조사 | 아이디어 검증 |

</chaining>

---

<examples>

## 예시 1: 기술 비교 (standard)

```bash
사용자: /research WebSocket vs SSE vs gRPC 실시간 통신

Phase 0: 주제 유형 → 기술 비교, 깊이 → standard
Phase 1: 쿼리 7개 생성 (장단점, 성능, 사용 사례, 스케일링 등)

Phase 2: 병렬 수집 (4 에이전트)
  researcher 1: "WebSocket 장단점, 성능 벤치마크, 사용 사례"
  researcher 2: "SSE 장단점, 브라우저 지원, 제약사항"
  researcher 3: "gRPC 장단점, 양방향 스트리밍, 모바일 지원"
  researcher 4: "WebSocket vs SSE vs gRPC 비교 벤치마크, 실사용 후기"

Phase 4: 리포트 생성 (Consulting Style)
Phase 5: .claude/research/02.실시간_통신_기술_비교.md 저장

## Executive Summary
gRPC가 처리량과 레이턴시에서 우위(HTTP/2 기반)이나, 브라우저 직접 지원 불가.
웹 클라이언트 중심이면 WebSocket, 서버→클라이언트 단방향이면 SSE가 최적.
모바일/마이크로서비스 간 통신은 gRPC 추천.

| 기준 | WebSocket | SSE | gRPC |
|------|-----------|-----|------|
| 방향 | 양방향 | 서버→클라이언트 | 양방향 |
| 프로토콜 | TCP | HTTP/1.1 | HTTP/2 |
| 브라우저 | ✅ | ✅ | ❌ (프록시 필요) |
| 복잡도 | 중간 | 낮음 | 높음 |
```

## 예시 2: 시장 트렌드 (deep)

```bash
사용자: /research --deep 한국 AI SaaS 시장 트렌드 2026

Phase 0: 주제 유형 → 시장/트렌드, 깊이 → deep
Phase 1: 쿼리 12개 생성 (시장 규모, 주요 플레이어, 투자, 규제 등)

Phase 2: 병렬 수집 (6 에이전트)
  researcher 1-2: 글로벌 AI SaaS 시장 (영어 소스)
  researcher 3-4: 한국 AI SaaS 시장 (한국어 소스)
  researcher 5: 투자/펀딩 데이터
  researcher 6: 규제/정책 동향

Phase 3: Iterative Deep Search
  → "국내 AI SaaS 스타트업 성공 사례" 부족 감지
  → researcher 2개 추가 투입

Phase 4-5: 리포트 생성 + 저장
  → .claude/research/03.한국_AI_SaaS_시장_2026.md (약 5000자)
```

## 예시 3: 빠른 조사 (quick)

```bash
사용자: /research --quick HTMX 장단점

Phase 0: 주제 유형 → 기술, 깊이 → quick
Phase 1: 쿼리 4개

Phase 2: 병렬 수집 (2 에이전트)
  researcher 1: "HTMX 장단점, 사용 사례, 한계"
  researcher 2: "HTMX vs React/Vue 비교, 실사용 후기"

Phase 4-5: 리포트 생성 + 저장 (약 800자)
  → .claude/research/04.HTMX_장단점.md
```

</examples>

---

<document_storage>

## 결과 저장

### 폴더 구조

```
.claude/research/
├── 00.AI_에이전트_프레임워크_비교.md
├── 01.한국_SaaS_시장_2026.md
├── 02.실시간_통신_기술_비교.md
└── ...
```

### 파일명 형식

`[NN].주제_요약.md`
- **NN**: 00, 01, 02... (기존 파일 다음 번호)
- **주제 요약**: 한글, 언더스코어 구분, 간결하게

### 넘버링 결정

```bash
ls .claude/research/ 2>/dev/null | grep -E '^[0-9]+' | sort -r | head -1
# → 마지막 번호 + 1
```

</document_storage>

---

<validation>

## 검증 체크리스트

**실행 전:**
- [ ] ARGUMENT 확인 (주제 없으면 질문)
- [ ] 주제 유형 분류 완료
- [ ] MCP 가용성 감지 완료
- [ ] 깊이 설정 확인 (quick/standard/deep)

**수집 후:**
- [ ] 최소 소스 수 충족 (quick 5 / standard 10 / deep 20)
- [ ] 각 발견사항에 출처 URL 있음
- [ ] 다각도 수집 (단일 관점만이 아님)

**리포트 생성 후:**
- [ ] Executive Summary 250-400자 (결론 우선)
- [ ] 핵심 발견사항에 출처 URL 표시
- [ ] 비교 대상 있으면 비교 테이블 포함
- [ ] 실행 가능한 권장사항 포함
- [ ] 참고자료 섹션 (제목 + URL + 1줄 요약)
- [ ] 메타데이터 (생성일, 채널, 소스 수)

**저장 후:**
- [ ] .claude/research/ 에 파일 저장됨
- [ ] Executive Summary 터미널에 출력됨
- [ ] 파일 경로 사용자에게 안내됨

## 절대 금지

- ❌ 출처 없이 주장 작성
- ❌ 단일 소스만으로 리포트 생성
- ❌ Executive Summary 없이 리포트 생성
- ❌ 권장사항 없이 리포트 종료
- ❌ 결과 저장 없이 종료
- ❌ 라이브러리 문서 주제에 research 사용 (→ docs-fetch 위임)

</validation>
