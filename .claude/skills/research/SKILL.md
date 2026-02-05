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

brainstorm = **아이디어 발산** / research = **팩트 수렴**
docs-fetch = **AI용 문서** / research = **사람이 읽는 리포트**

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

ARGUMENT 없음 → 즉시 질문: "어떤 주제를 조사할까요?"

</trigger_conditions>

---

<depth_levels>

| 설정 | quick | standard (기본) | deep |
|------|-------|----------------|------|
| **플래그** | `--quick` | (없음) | `--deep` |
| **검색 쿼리** | 3-5개 | 5-10개 | 10-15개 |
| **에이전트** | researcher 2 + explore 0-1 | researcher 3-4 + explore 0-1 | researcher 4-5 + explore 1 + MCP |
| **Iterative** | X | X | O (analyst → 2차 수집) |
| **소스 최소** | 5개 | 10개 | 20개+ |
| **리포트** | 500-1000자 | 1500-3000자 | 3000-6000자 |

</depth_levels>

---

<topic_classification>

Phase 0에서 자동 분류 → 채널 조합 결정:

| 유형 | 키워드 | 채널 |
|------|--------|------|
| **기술 비교** | "vs", "비교" | WebSearch + explore(gh) |
| **시장/트렌드** | "시장", "트렌드" | WebSearch + Firecrawl |
| **경쟁사 분석** | "경쟁사", "대안" | WebSearch + GitHub MCP |
| **학술/개념** | "원리", "논문" | WebSearch (arxiv) + WebFetch |
| **프로젝트 내부** | "우리 코드" | explore + Grep |
| **라이브러리** | 패키지명@버전 | → **docs-fetch 위임** |

</topic_classification>

---

<sourcing_strategy>

## Smart Tier Fallback

```
Tier 1 (MCP, Phase 0에서 ToolSearch로 감지):
  SearXNG MCP  → 메타검색 | Firecrawl MCP → 페이지→MD | GitHub MCP → 코드/리포

Tier 2 (내장, 항상 가용):
  WebSearch → 웹 검색 | WebFetch → 페이지 읽기 | gh CLI → GitHub API (Bash)

Tier 3: Playwright → SPA/JS 필요 시 (crawler skill)
```

**MCP는 main agent가 직접 실행** (subagent는 MCP 도구 사용 불가)

| MCP 도구 | 용도 | 미설치 시 폴백 |
|----------|------|--------------|
| `firecrawl_map/scrape/crawl` | 사이트 구조/페이지 수집 | WebFetch (페이지별) |
| SearXNG `search` | 246+ 엔진 메타검색 | WebSearch (내장) |
| `search_repositories/code/issues` | GitHub 리포/코드/이슈 | `gh search` (Bash via explore) |

</sourcing_strategy>

---

<workflow>

## 실행 흐름

| Phase | 작업 | 도구 |
|-------|------|------|
| **0** | 입력 파싱 + MCP 감지 + 주제 분류 | ToolSearch × 3 |
| **1** | 검색 전략 (Sequential Thinking 2단계) | ST: 질문 도출 → 쿼리 생성 |
| **2** | 병렬 자료 수집 | researcher + explore + MCP |
| **3** | 갭 분석 + 2차 수집 (**deep만**) | analyst → researcher |
| **4** | 리포트 생성 | general-purpose |
| **5** | 저장 + 터미널 출력 | Write |

---

### Phase 0: 환경 감지

```
1. 입력 파싱: 주제, --quick/--deep, 특수 지시 ("한국어 우선" 등)
2. 주제 분류: <topic_classification> 참조 (라이브러리 → docs-fetch 위임)
3. MCP 감지: ToolSearch("firecrawl"), ToolSearch("searxng"), ToolSearch("github")
4. 기존 조사: .claude/research/ 동일 주제 → 업데이트 모드
```

### Phase 1: 검색 전략

```
Sequential Thinking (2단계):
  thought 1: 핵심 질문 3-5개, 주제 유형 확정, 범위 결정 (시간/지역/언어)
  thought 2: 다각도 쿼리 생성 (영어+한국어, 연도 포함), 채널별 배분, 에이전트 역할 분배
```

### Phase 2: 병렬 수집

**에이전트 도구 제약 (@.claude/agents/ 정의 준수):**

| Agent | Model | 도구 | 역할 |
|-------|-------|------|------|
| researcher | sonnet | WebSearch, WebFetch, Read | 웹 조사 + 출처 수집 |
| explore | haiku | Read, Glob, Grep, **Bash** | `gh` CLI GitHub 분석 |
| main agent | - | MCP 도구들 | Firecrawl/SearXNG/GitHub MCP 직접 실행 |

```typescript
// 기술 비교 (standard: researcher 3 + explore 1 병렬)
Task({ subagent_type: 'researcher', prompt: '기술 A 장단점, 성능. 출처 URL 필수.' })
Task({ subagent_type: 'researcher', prompt: '기술 B 장단점, 성능. 출처 URL 필수.' })
Task({ subagent_type: 'researcher', prompt: 'A vs B 벤치마크, 비교, 후기. 출처 URL 필수.' })
Task({ subagent_type: 'explore', model: 'haiku',
       prompt: 'gh search repos "기술 A/B" --sort stars. 스타, 커밋, 이슈 비교.' })
// MCP 가용 시 main agent가 동시에 search_repositories, firecrawl_scrape 등 실행
```

**researcher 출력:** `요약 → 공식 문서 → GitHub 이슈/PR → 추가 참고 → 권장사항` (researcher agent 정의 준수)
**시장/트렌드:** researcher를 글로벌/한국/투자 등 관점별 배분
**경쟁사:** researcher를 경쟁사별 1개씩 + 비교 리뷰 1개

### Phase 3: Iterative Deep Search (deep만)

```
analyst (opus, 6-gap 프레임워크):
  1차 수집 갭 분석 → 커버/빈 영역 식별, 미검증 가정, 추가 쿼리 2-5개 도출

researcher × 2-3: 빈 영역 집중 검색
```

### Phase 4: 리포트 생성

**document-writer는 AI용 문서 전문 → general-purpose 사용.**

```typescript
Task({ subagent_type: 'general-purpose',
       prompt: `수집 자료 기반 리포트 작성.
       형식: <report_template> 참조. 경로: .claude/research/[NN].주제_요약.md
       필수: Executive Summary 250-400자 (결론 우선), 출처 URL, 비교 테이블, 권장사항
       사람용 문서: XML 태그/토큰 최적화 하지 말 것` })
```

### Phase 5: 저장

```
파일: .claude/research/[NN].주제_요약.md (기존 파일 다음 번호, 한글+언더스코어)
넘버링: ls .claude/research/ | sort -r | head -1 → 다음 번호
출력: Executive Summary + 핵심 발견 3-5개 + "전체 리포트: [경로]" 안내
```

</workflow>

---

<report_template>

@./report-template.md

### 작성 원칙

| 원칙 | 설명 |
|------|------|
| **결론 우선** | 가장 중요한 결론을 첫 문장에 (Pyramid Principle) |
| **팩트 기반** | 모든 핵심 주장에 출처 URL 필수 |
| **시각적 계층** | H1 하나, H2-H3, 테이블 활용 |
| **Progressive Disclosure** | 요약→상세, Executive Summary만 읽어도 충분 |

</report_template>

---

<chaining>

| 흐름 | 사용 시점 |
|------|---------|
| research → brainstorm | 팩트 조사 후 아이디어 도출 |
| research → prd | 시장 조사 → 요구사항 정의 |
| brainstorm → research | 아이디어 실현 가능성 검증 |

</chaining>

---

<examples>

```
/research WebSocket vs SSE vs gRPC 실시간 통신

Phase 0: 기술 비교, standard
Phase 1: 쿼리 7개 (장단점, 성능, 사용사례, 스케일링)
Phase 2: researcher 3 + explore 1 (gh search repos)
Phase 4: 리포트 → .claude/research/02.실시간_통신_기술_비교.md

Executive Summary:
gRPC가 처리량/레이턴시 우위(HTTP/2)이나 브라우저 미지원.
웹 → WebSocket, 단방향 → SSE, 마이크로서비스 → gRPC.

| 기준 | WebSocket | SSE | gRPC |
|------|-----------|-----|------|
| 방향 | 양방향 | 서버→클라 | 양방향 |
| 브라우저 | ✅ | ✅ | ❌ |
| 복잡도 | 중간 | 낮음 | 높음 |
```

**deep 예시:** `/research --deep 한국 AI SaaS 시장 2026` → researcher 5 + explore 1 + Phase 3 analyst 갭분석 → .claude/research/03.한국_AI_SaaS_시장_2026.md (~5000자)

</examples>

---

<validation>

| 단계 | 체크 |
|------|------|
| **실행 전** | ARGUMENT, 주제 분류, MCP 감지, 깊이 확인 |
| **수집 후** | 최소 소스 충족 (5/10/20), 출처 URL, 다각도 수집 |
| **리포트** | Exec Summary 250-400자, 출처, 비교 테이블, 권장사항, 참고자료, 메타데이터 |
| **저장** | .claude/research/ 저장, 터미널 출력, 경로 안내 |

**절대 금지:** 출처 없는 주장 / 단일 소스 리포트 / Exec Summary 누락 / 권장사항 누락 / 저장 안 함 / 라이브러리 주제 (→ docs-fetch)

</validation>
