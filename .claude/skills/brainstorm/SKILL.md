---
name: brainstorm
description: 자료 수집 + 웹 검색 + 코드베이스 분석 기반 체계적 브레인스토밍. 아이디어 도출 및 구조화.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Brainstorm Skill

> 자료 수집 + 웹 검색 + 코드베이스 분석 기반 체계적 브레인스토밍

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **신규 기능 아이디어** | "사용자 참여를 높일 방법" |
| **기술 선택** | "상태 관리 라이브러리 비교" |
| **UX 개선** | "온보딩 플로우 개선 방안" |
| **아키텍처 설계** | "마이크로서비스 분리 전략" |
| **문제 해결** | "성능 병목 해결 방법" |
| **시장 조사** | "경쟁사 기능 분석" |

## 호출 방법

```bash
# 기본 사용
/brainstorm 실시간 협업 기능 아이디어

# 특정 영역 지정
/brainstorm UX: 모바일 결제 플로우 개선

# 기술 비교
/brainstorm 기술: WebSocket vs SSE vs Long Polling
```

## 결과물

- 다각도 자료 수집 (웹, 코드베이스, 트렌드, Firecrawl/SearXNG)
- 체계적 아이디어 목록 (카테고리별)
- 실행 가능성 평가 (노력/영향도 매트릭스)
- 추천 방향 및 다음 단계

</when_to_use>

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"어떤 주제로 브레인스토밍을 진행할까요?

예시:
- 신규 기능: '사용자 참여를 높일 방법'
- 기술 선택: 'WebSocket vs SSE 비교'
- UX 개선: '온보딩 플로우 개선'
- 문제 해결: '성능 병목 해결'"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<sourcing_strategy>

## Smart Tier Fallback

```
Tier 1 (MCP, Phase 0에서 ToolSearch로 감지):
  Firecrawl MCP → 페이지→MD, 사이트맵 | SearXNG MCP → 메타검색 (246+ 엔진) | GitHub MCP → 코드/리포

Tier 2 (내장, 항상 가용):
  WebSearch → 웹 검색 | WebFetch → 페이지 읽기 | gh CLI → GitHub API (Bash)
```

**MCP는 main agent가 직접 실행** (subagent는 MCP 도구 사용 불가)

| MCP 도구 | 브레인스토밍 활용 | 미설치 시 폴백 |
|----------|-----------------|--------------|
| `firecrawl_search` | 주제별 심층 검색 (경쟁사, 트렌드) | WebSearch (내장) |
| `firecrawl_scrape` | 참고 사이트 컨텐츠 추출 | WebFetch (페이지별) |
| `firecrawl_map` | 경쟁사/참고 사이트 구조 파악 | WebFetch (수동) |
| `search_repositories/code` | GitHub 관련 프로젝트 검색 | `gh search` (Bash via explore) |

</sourcing_strategy>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 0. MCP 감지 | Firecrawl/SearXNG/GitHub MCP 가용 여부 확인 | ToolSearch × 3 |
| 1. 입력 확인 | ARGUMENT 검증 | - |
| 2. 주제 분석 | 브레인스토밍 범위 결정 + 채널 배분 | sequentialthinking (1-2단계) |
| 3. 자료 수집 | 병렬 정보 수집 (웹 + MCP + 코드베이스) | Task 병렬 + MCP 직접 실행 |
| 4. 아이디어 도출 | 수집 자료 기반 아이디어 생성 | sequentialthinking (3-5단계) |
| 5. 구조화 | 카테고리별 정리 + 실행 가능성 평가 | - |
| 6. 문서 저장 | `.claude/brainstorms/` 폴더에 결과 저장 | Write |
| 7. 결과 제시 | 아이디어 목록 + 추천 방향 + 파일 경로 안내 | - |

### Phase 0: MCP 환경 감지

```
1. MCP 감지 (병렬): ToolSearch("firecrawl"), ToolSearch("searxng"), ToolSearch("github")
2. 가용 채널 결정: MCP 있으면 Tier 1, 없으면 Tier 2 폴백
3. 기존 브레인스토밍: .claude/brainstorms/ 동일 주제 확인
```

### Phase 2: 주제 분석 시 채널 배분

```
Sequential Thinking (2단계):
  thought 1: 주제 유형 확정, 범위 결정, MCP 가용 여부 반영
  thought 2: 에이전트 역할 배분 + main agent MCP 직접 실행 계획
```

### 복잡도별 사고 패턴

| 복잡도 | 사고 횟수 | 판단 기준 |
|--------|----------|----------|
| **간단** | 3 | 단일 영역, 명확한 범위 |
| **보통** | 5 | 다중 영역, 기술 + 비즈니스 고려 |
| **복잡** | 7+ | 아키텍처 결정, 다중 이해관계자 |

</workflow>

---

<document_storage>

## 결과 저장

### 폴더 구조

브레인스토밍 결과는 `.claude/brainstorms/` 폴더에 저장:

```
.claude/brainstorms/
├── 00.사용자_참여_향상.md
├── 01.실시간_통신_기술_선택.md
├── 02.모바일_결제_UX_개선.md
└── ...
```

### 파일명 형식

`[넘버링].[주제_요약].md`

- **넘버링**: 기존 파일 목록 조회 → 다음 번호 자동 부여 (00, 01, 02...)
- **주제 요약**: 한글, 언더스코어로 구분, 간결하게

### 저장 워크플로우

```typescript
// 1. 넘버링 결정
Bash("ls .claude/brainstorms/ 2>/dev/null | grep -E '^[0-9]+' | wc -l")
const nextNumber = "00" // 결과 기반 계산

// 2. 폴더 생성 (없으면)
Bash("mkdir -p .claude/brainstorms")

// 3. 결과 저장
Write({
  file_path: `.claude/brainstorms/${nextNumber}.${주제_요약}.md`,
  content: 브레인스토밍_결과
})

// 4. 사용자에게 경로 안내
"브레인스토밍 결과가 저장되었습니다: .claude/brainstorms/00.사용자_참여_향상.md"
```

### 저장 내용

| 섹션 | 내용 |
|------|------|
| **메타데이터** | 주제, 생성일, 관련 컨텍스트 |
| **수집 자료 요약** | 외부 트렌드, 경쟁사/사례, 현재 시스템 |
| **아이디어 목록** | 카테고리별 아이디어 + 노력/영향도 |
| **우선순위 매트릭스** | Quick Wins, Big Bets 분류 |
| **추천 방향** | 최우선 추천, 다음 단계 |

</document_storage>

---

<parallel_agent_execution>

## 병렬 Agent 실행

### Recommended Agents

| Agent | Model | 용도 | 복잡도 |
|-------|-------|------|--------|
| **@researcher** | sonnet | 웹 조사, 외부 문서/API/트렌드 | MEDIUM |
| **@explore** | haiku | 코드베이스 탐색, 현재 구조 분석 | LOW |
| **@analyst** | sonnet | 요구사항 분석, 가정 검증 | MEDIUM |
| **@architect** | opus | 아키텍처 평가, 설계 방향 (READ-ONLY) | HIGH |
| **@designer** | sonnet | UI/UX 아이디어, 디자인 패턴 | MEDIUM |
| **@scientist** | sonnet | 데이터 분석 아이디어, 통계적 접근 | MEDIUM |

---

### 병렬 수집 패턴

**에이전트 도구 제약 (@.claude/agents/ 정의 준수):**

| Agent | Model | 도구 | 역할 |
|-------|-------|------|------|
| researcher | sonnet | WebSearch, WebFetch, Read | 웹 조사 + 출처 수집 |
| explore | haiku | Read, Glob, Grep, **Bash** | 코드베이스 + `gh` CLI |
| main agent | - | MCP 도구들 | Firecrawl/SearXNG/GitHub MCP 직접 실행 |

**패턴 1: 다각도 자료 수집 (기본 + MCP)**

```typescript
// 에이전트 병렬 수집 (subagent는 MCP 사용 불가)
Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: `
    [주제]에 대한 외부 자료 조사:
    - 최신 트렌드 및 베스트 프랙티스
    - 경쟁사/유사 서비스 사례
    - 기술 블로그, 문서, 아티클
  `
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: `
    현재 코드베이스에서 [주제] 관련 분석:
    - 기존 구현 패턴
    - 확장 가능한 포인트
    - 제약사항
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: `
    [주제] 요구사항 분석:
    - 사용자 니즈
    - 비즈니스 목표
    - 기술적 제약
  `
})

// ⬆ 위 에이전트들과 동시에, main agent가 MCP 직접 실행:
// firecrawl_search: 주제 관련 심층 검색
firecrawl_search({ query: "[주제] 트렌드 사례", limit: 5 })
// firecrawl_scrape: 핵심 참고 페이지 컨텐츠 추출
firecrawl_scrape({ url: "경쟁사/참고_URL", formats: ["markdown"], onlyMainContent: true })
```

**효과:** 3방향 에이전트 + MCP 동시 조사 → 포괄적 정보 수집

---

**패턴 2: 기술 비교 조사**

```typescript
// 여러 기술 옵션 동시 조사
Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: '기술 A (WebSocket) 장단점, 사례, 성능 특성'
})

Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: '기술 B (SSE) 장단점, 사례, 성능 특성'
})

Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: '기술 C (Long Polling) 장단점, 사례, 성능 특성'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '현재 프로젝트 통신 구조 및 요구사항 분석'
})

// main agent MCP 동시 실행 (가용 시):
firecrawl_search({ query: "WebSocket vs SSE benchmark 2025", limit: 5 })
// GitHub MCP: search_repositories({ query: "websocket sse comparison", sort: "stars" })
```

**효과:** 기술 옵션 병렬 조사 + MCP 심층 검색 → 공정한 비교

---

**패턴 3: UX 아이디어 수집**

```typescript
// UX 관점 다각도 수집
Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: `
    [UX 주제] 관련 외부 사례:
    - 유명 앱/서비스 UX 패턴
    - 최신 UX 트렌드 (2024-2025)
    - 사용자 리서치 결과
  `
})

Task({
  subagent_type: 'designer',
  model: 'sonnet',
  prompt: `
    [UX 주제] 디자인 아이디어:
    - 사용자 플로우 개선안
    - 마이크로인터랙션 제안
    - 접근성 고려사항
  `
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '현재 UI 컴포넌트 및 디자인 시스템 분석'
})
```

---

**패턴 4: 아키텍처 브레인스토밍**

```typescript
// 아키텍처 결정을 위한 심층 분석
Task({
  subagent_type: 'architect',
  model: 'opus',
  prompt: `
    [아키텍처 주제] 설계 방향 분석:
    - 현재 구조의 장단점
    - 확장성, 유지보수성 평가
    - 대안 아키텍처 제안
  `
})

Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: `
    [아키텍처 주제] 업계 사례:
    - 유사 규모 시스템 아키텍처
    - 마이그레이션 사례
    - 실패/성공 교훈
  `
})

Task({
  subagent_type: 'explore',
  model: 'sonnet',
  prompt: `
    현재 시스템 심층 분석:
    - 모듈 의존성
    - 데이터 흐름
    - 병목 구간
  `
})
```

---

**패턴 5: 문제 해결 아이디어**

```typescript
// 문제 해결을 위한 다각도 접근
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: `
    [문제] 근본 원인 분석:
    - 증상 vs 원인 구분
    - 영향 범위 파악
    - 가정 검증
  `
})

Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: `
    [문제] 유사 사례 및 해결책:
    - 동일 문제 해결 사례
    - 베스트 프랙티스
    - 피해야 할 안티패턴
  `
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: `
    [문제] 관련 코드 분석:
    - 문제 발생 지점
    - 관련 로직
    - 수정 영향 범위
  `
})
```

---

### Model Routing

| 조사 유형 | 모델 | Agent | 이유 |
|----------|------|-------|------|
| **트렌드/사례** | sonnet | researcher | 외부 정보 종합 |
| **코드 탐색** | haiku | explore | 빠른 구조 파악 |
| **요구사항** | sonnet | analyst | 분석 품질 |
| **아키텍처** | opus | architect | 설계 깊이 |
| **UI/UX** | sonnet | designer | 창의성 + 실용성 |

</parallel_agent_execution>

---

<ideation_framework>

## 아이디어 도출 프레임워크

> AI에 최적화된 8가지 브레인스토밍 기법

### 기법 선택 가이드

| 상황 | 추천 기법 |
|------|----------|
| **신규 기능 아이디어** | Tree of Thoughts, SCAMPER, Multi-Persona |
| **문제 해결** | Reverse Brainstorming, 5 Whys, Tree of Thoughts |
| **요구사항 발굴** | Starbursting (5W1H), How Might We |
| **아이디어 평가** | 6 Thinking Hats, Multi-Persona |
| **빠른 발상** | Crazy 8s, SCAMPER |
| **복잡한 의사결정** | Tree of Thoughts, 6 Thinking Hats |

---

### 1. Tree of Thoughts (ToT) ⭐ AI 핵심

> 여러 해결 경로를 동시에 탐색하고 평가하는 AI 특화 기법

**원리:** 선형적 사고 대신 트리 구조로 여러 아이디어 분기 → 평가 → 유망한 경로 확장

**AI 구현:**
```
단계 1: 문제를 3-5개 하위 문제로 분해
단계 2: 각 하위 문제에 3-5개 해결 경로 생성 (병렬)
단계 3: 각 경로 평가 (실현 가능성 1-5, 영향도 1-5)
단계 4: 상위 경로 선택 및 심화 탐색
단계 5: 최종 아이디어 종합
```

**병렬 에이전트 패턴:**
```typescript
// 여러 경로 동시 탐색
Task({ subagent_type: 'analyst', prompt: '경로 A: [접근법 1] 심층 분석' })
Task({ subagent_type: 'analyst', prompt: '경로 B: [접근법 2] 심층 분석' })
Task({ subagent_type: 'analyst', prompt: '경로 C: [접근법 3] 심층 분석' })
// → 결과 비교 후 유망 경로 선택
```

**적합한 상황:** 복잡한 문제, 여러 해결책 비교, 의사결정

---

### 2. Multi-Persona Simulation ⭐ AI 핵심

> 여러 전문가/이해관계자 관점을 시뮬레이션하여 다각도 아이디어 생성

**페르소나 예시:**

| 페르소나 | 관점 | 질문 |
|---------|------|------|
| **CEO** | 비즈니스 가치 | ROI는? 시장 기회는? |
| **개발자** | 기술적 실현 | 구현 가능? 복잡도는? |
| **UX 디자이너** | 사용자 경험 | 직관적인가? 접근성은? |
| **고객** | 실제 사용 | 내 문제를 해결하나? |
| **비평가** | 약점/리스크 | 실패 시나리오는? |

**병렬 에이전트 패턴:**
```typescript
// 여러 페르소나 동시 실행
Task({ subagent_type: 'analyst', prompt: 'CEO 관점: 비즈니스 가치 분석' })
Task({ subagent_type: 'architect', prompt: '개발자 관점: 기술적 실현 가능성' })
Task({ subagent_type: 'designer', prompt: 'UX 디자이너 관점: 사용자 경험' })
Task({ subagent_type: 'analyst', prompt: '고객 관점: 실제 사용 시나리오' })
Task({ subagent_type: 'analyst', prompt: '비평가 관점: 약점과 리스크' })
```

**적합한 상황:** 다각도 검토, 이해관계자 분석, 제품 기획

---

### 3. SCAMPER 기법

> 7가지 질문으로 체계적 발상

| 기법 | 질문 | 예시 |
|------|------|------|
| **S**ubstitute | 대체할 수 있는 것? | 이메일 → 푸시 알림 |
| **C**ombine | 결합할 수 있는 것? | 검색 + 추천 |
| **A**dapt | 적용할 수 있는 것? | 다른 앱의 UX 패턴 |
| **M**odify | 수정/확대/축소? | 단계 축소, 기능 확대 |
| **P**ut to other uses | 다른 용도? | 분석 도구 → 마케팅 도구 |
| **E**liminate | 제거할 것? | 불필요한 단계 제거 |
| **R**earrange | 재배열/역순? | 플로우 순서 변경 |

**AI 적용:** 각 질문에 대해 3개 이상 아이디어 생성

---

### 4. Starbursting (5W1H)

> 질문 중심 브레인스토밍으로 요구사항 발굴

| 질문 | 탐색 영역 | 예시 질문 |
|------|----------|----------|
| **Who** | 사용자/이해관계자 | 누가 사용하는가? 누가 영향받는가? |
| **What** | 기능/목적 | 무엇을 해결하는가? 무엇이 필요한가? |
| **Where** | 적용 범위 | 어디서 사용되는가? 어떤 환경에서? |
| **When** | 시점/조건 | 언제 필요한가? 어떤 상황에서? |
| **Why** | 목적/가치 | 왜 중요한가? 왜 지금인가? |
| **How** | 구현/방법 | 어떻게 구현하는가? 어떻게 측정하는가? |

**AI 적용:** 각 질문에 대해 5-10개 하위 질문 생성 → 요구사항 도출

---

### 5. Reverse Brainstorming

> 역발상으로 새로운 관점 획득

**워크플로우:**
```
단계 1: "어떻게 하면 [문제]를 악화시킬 수 있을까?"
단계 2: 악화 시나리오 5-10개 생성
단계 3: 각 시나리오를 역전환
단계 4: 실행 가능한 아이디어로 정제
```

**예시:**
```
문제: "사용자 이탈률을 낮추려면?"
↓ 역전환
"어떻게 하면 사용자를 더 빨리 이탈시킬까?"
- 복잡한 가입 절차 → 역전환: 원클릭 가입
- 느린 로딩 → 역전환: 스켈레톤 UI + 지연 로딩
- 혼란스러운 네비게이션 → 역전환: 명확한 정보 구조
```

**적합한 상황:** 막힌 상황 돌파, 새로운 관점, 문제 예방

---

### 6. 6 Thinking Hats (AI 버전)

> 6가지 관점으로 체계적 평가 - 병렬 에이전트 활용

| 모자 | 관점 | AI 에이전트 | 질문 |
|------|------|-----------|------|
| ⚪ 하얀 | 정보/데이터 | analyst | 현재 데이터가 말하는 것? |
| 🔴 빨간 | 감정/직관 | analyst | 사용자가 느끼는 감정? |
| ⚫ 검은 | 비판/리스크 | analyst | 잠재적 문제점? 실패 시나리오? |
| 🟡 노란 | 긍정/이점 | analyst | 기대 효과? 성공 시나리오? |
| 🟢 초록 | 창의/대안 | designer | 새로운 접근 방법? 대안? |
| 🔵 파란 | 프로세스/관리 | planner | 어떻게 진행? 우선순위? |

**병렬 에이전트 패턴:**
```typescript
// 6가지 관점 동시 분석
Task({ subagent_type: 'analyst', prompt: '⚪ White Hat: [주제] 관련 데이터/팩트 분석' })
Task({ subagent_type: 'analyst', prompt: '🔴 Red Hat: [주제] 사용자 감정/직관 분석' })
Task({ subagent_type: 'analyst', prompt: '⚫ Black Hat: [주제] 리스크/문제점 분석' })
Task({ subagent_type: 'analyst', prompt: '🟡 Yellow Hat: [주제] 이점/긍정적 효과 분석' })
Task({ subagent_type: 'designer', prompt: '🟢 Green Hat: [주제] 창의적 대안 제시' })
Task({ subagent_type: 'planner', prompt: '🔵 Blue Hat: [주제] 실행 프로세스 설계' })
```

---

### 7. Crazy 8s (AI 버전)

> 8가지 빠른 아이디어 생성

**원리:** 양(quantity) 우선, 질(quality)은 나중에

**AI 적용:**
```
[주제]에 대해 8가지 서로 다른 아이디어를 빠르게 생성:

1. 가장 단순한 해결책
2. 가장 기술적으로 진보된 해결책
3. 경쟁사라면 어떻게?
4. 예산이 무제한이라면?
5. 예산이 0이라면?
6. 10년 후라면?
7. 완전히 다른 분야에서 가져온다면?
8. 가장 미친 아이디어
```

**적합한 상황:** 빠른 발상, 초기 아이디어 탐색, 창의적 돌파

---

### 8. 5 Whys

> 근본 원인 분석으로 진짜 문제 발견

**워크플로우:**
```
문제: [현상]
Why 1: 왜 [현상]이 발생하는가? → [원인 1]
Why 2: 왜 [원인 1]이 발생하는가? → [원인 2]
Why 3: 왜 [원인 2]이 발생하는가? → [원인 3]
Why 4: 왜 [원인 3]이 발생하는가? → [원인 4]
Why 5: 왜 [원인 4]이 발생하는가? → [근본 원인]
```

**예시:**
```
문제: 사용자 이탈률이 높다
Why 1: 왜? → 회원가입 완료율이 낮다
Why 2: 왜? → 가입 폼이 너무 길다
Why 3: 왜? → 불필요한 정보를 수집한다
Why 4: 왜? → 요구사항 분석 없이 설계했다
Why 5: 왜? → 사용자 리서치가 없었다
→ 근본 원인: 사용자 리서치 부재
```

**적합한 상황:** 버그 분석, 문제 진단, 프로세스 개선

---

### 9. How Might We (HMW)

> 디자인 씽킹의 핵심 기법

**질문 생성 패턴:**
```
- How might we [사용자 문제]를 해결할 수 있을까?
- How might we [목표]를 더 쉽게 달성할 수 있을까?
- How might we [제약]을 기회로 바꿀 수 있을까?
```

**예시:**
- HMW 사용자가 3초 안에 원하는 정보를 찾게 할까?
- HMW 신규 사용자의 이탈률을 낮출까?
- HMW 모바일에서 복잡한 작업을 간단하게 만들까?

**적합한 상황:** 요구사항 발굴, 문제 재정의, 기회 발견

</ideation_framework>

---

<result_structure>

## 결과물 구조

### 브레인스토밍 결과 형식

```markdown
# 브레인스토밍 결과: [주제]

**생성일:** YYYY-MM-DD
**관련 컨텍스트:** [프로젝트명 또는 관련 파일]

---

## 📊 수집 자료 요약

### 외부 트렌드
- 트렌드 1: [설명]
- 트렌드 2: [설명]

### 경쟁사/사례
- 사례 1: [서비스명] - [특징]
- 사례 2: [서비스명] - [특징]

### 현재 시스템
- 강점: [목록]
- 개선점: [목록]
- 제약: [목록]

---

## 💡 아이디어 목록

### 카테고리 1: [예: 사용자 경험]

| ID | 아이디어 | 설명 | 노력 | 영향도 |
|----|---------|------|------|--------|
| 1-1 | [아이디어명] | [설명] | 낮음 | 높음 |
| 1-2 | [아이디어명] | [설명] | 중간 | 중간 |

### 카테고리 2: [예: 기술 개선]

| ID | 아이디어 | 설명 | 노력 | 영향도 |
|----|---------|------|------|--------|
| 2-1 | [아이디어명] | [설명] | 높음 | 높음 |

### 카테고리 3: [예: 비즈니스]

| ID | 아이디어 | 설명 | 노력 | 영향도 |
|----|---------|------|------|--------|
| 3-1 | [아이디어명] | [설명] | 낮음 | 중간 |

---

## 📈 우선순위 매트릭스

```
        높은 영향도
             │
    [Quick   │  [Big
     Wins]   │  Bets]
             │
─────────────┼─────────────
             │
    [Fill    │  [Money
     Ins]    │  Pit]
             │
        낮은 영향도

낮은 노력 ◄──────────► 높은 노력
```

### Quick Wins (낮은 노력 + 높은 영향도)
- 1-1: [아이디어명]

### Big Bets (높은 노력 + 높은 영향도)
- 2-1: [아이디어명]

### Fill Ins (낮은 노력 + 낮은 영향도)
- 3-1: [아이디어명]

---

## 🎯 추천 방향

**최우선 추천:** [아이디어 ID] - [이유]

**다음 단계:**
1. [구체적 액션 1]
2. [구체적 액션 2]
3. [구체적 액션 3]

**추가 탐색 필요:**
- [불확실한 영역]
- [추가 조사 필요 항목]
```

</result_structure>

---

<examples>

## 실전 예시

### 예시 1: 기능 아이디어 브레인스토밍

```bash
사용자: /brainstorm 사용자 참여를 높일 방법

1. Sequential Thinking (2단계):
   thought 1: "사용자 참여 - 넓은 주제, UX/기능/게이미피케이션 다각도 접근"
   thought 2: "외부 트렌드 + 경쟁사 + 현재 시스템 동시 조사"

2. 병렬 자료 수집:
   Task (researcher): "2024-2025 사용자 참여 트렌드, 게이미피케이션 사례"
   Task (researcher): "토스, 카카오, 배민 등 참여 유도 기능 분석"
   Task (explore): "현재 앱 사용자 플로우, 참여 포인트 분석"

3. Sequential Thinking (3-5단계):
   thought 3: "수집 결과 - 알림, 리워드, 소셜, 개인화 4가지 축"
   thought 4: "SCAMPER 적용: 기존 기능 결합, 새 기능 추가"
   thought 5: "우선순위: Quick Wins → Big Bets 순"

4. 결과 저장:
   → .claude/brainstorms/00.사용자_참여_향상.md

5. 결과 요약:
   ## 💡 아이디어 목록

   ### 사용자 경험
   - 1-1: 진행률 표시 (낮음/높음) - Quick Win
   - 1-2: 개인화 대시보드 (중간/높음)

   ### 게이미피케이션
   - 2-1: 연속 사용 보상 (낮음/높음) - Quick Win
   - 2-2: 레벨 시스템 (높음/중간)

   ### 소셜
   - 3-1: 친구 초대 리워드 (중간/높음)

   ## 🎯 추천: 1-1, 2-1 먼저 구현 (Quick Wins)

   📁 전체 결과: .claude/brainstorms/00.사용자_참여_향상.md
```

### 예시 2: 기술 선택 브레인스토밍

```bash
사용자: /brainstorm 기술: 실시간 통신 방식 선택

1. Sequential Thinking (2단계):
   thought 1: "기술 비교 - WebSocket, SSE, Polling 등 옵션"
   thought 2: "각 기술 병렬 조사 + 현재 요구사항 분석"

2. 병렬 자료 수집:
   Task (researcher): "WebSocket 장단점, 사용 사례, 스케일링"
   Task (researcher): "SSE 장단점, 브라우저 지원, 제약"
   Task (researcher): "Long Polling 장단점, 사용 시나리오"
   Task (explore): "현재 통신 구조, 요구사항 분석"

3. Sequential Thinking (3-5단계):
   thought 3: "요구사항: 양방향 통신, 모바일 지원, 중간 규모"
   thought 4: "WebSocket이 요구사항에 가장 적합"
   thought 5: "Socket.io vs ws 비교: Socket.io 추천 (재연결 자동화)"

4. 결과 저장:
   → .claude/brainstorms/01.실시간_통신_기술_선택.md

5. 결과 요약:
   ## 📊 기술 비교

   | 기준 | WebSocket | SSE | Polling |
   |------|-----------|-----|---------|
   | 양방향 | ✅ | ❌ | ⚠️ |
   | 실시간성 | ⭐⭐⭐ | ⭐⭐ | ⭐ |
   | 복잡도 | 중간 | 낮음 | 낮음 |
   | 스케일링 | 중간 | 높음 | 낮음 |

   ## 🎯 추천: WebSocket (Socket.io)
   - 이유: 양방향 필요, 재연결 자동화, 생태계 성숙

   📁 전체 결과: .claude/brainstorms/01.실시간_통신_기술_선택.md
```

### 예시 3: UX 개선 브레인스토밍

```bash
사용자: /brainstorm UX: 모바일 결제 플로우 개선

1. Sequential Thinking (2단계):
   thought 1: "모바일 결제 UX - 전환율 직결, 사용자 리서치 중요"
   thought 2: "경쟁사 UX + 베스트 프랙티스 + 현재 플로우 분석"

2. 병렬 자료 수집:
   Task (researcher): "토스, 카카오페이, Apple Pay UX 분석"
   Task (designer): "모바일 결제 UX 베스트 프랙티스, 마이크로인터랙션"
   Task (explore): "현재 결제 플로우, 이탈 포인트 분석"

3. Sequential Thinking (3-5단계):
   thought 3: "현재 이탈 포인트: 주소 입력, 카드 정보, 최종 확인"
   thought 4: "HMW: 어떻게 3단계 → 1단계로 줄일 수 있을까?"
   thought 5: "저장된 정보 활용, 원터치 결제, 생체인증"

4. 결과 저장:
   → .claude/brainstorms/02.모바일_결제_UX_개선.md

5. 결과 요약:
   ## 💡 아이디어 목록

   ### 단계 축소
   - 1-1: 기본 배송지 자동 선택 (낮음/높음)
   - 1-2: 원터치 결제 (중간/높음)

   ### 신뢰 구축
   - 2-1: 단계 인디케이터 (낮음/중간)
   - 2-2: 실시간 에러 안내 (낮음/중간)

   ## 🎯 추천: 1-1, 2-1 먼저 (Quick Wins)
   다음: 1-2 원터치 결제 (Big Bet)

   📁 전체 결과: .claude/brainstorms/02.모바일_결제_UX_개선.md
```

</examples>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ Phase 0: MCP 감지 (ToolSearch × 3: firecrawl, searxng, github)
✅ ARGUMENT 확인 (없으면 질문)
✅ Sequential Thinking 최소 3단계
✅ 병렬 자료 수집 (researcher + explore + analyst + MCP 직접 실행)
✅ MCP 가용 시 main agent가 firecrawl_search/scrape 병렬 실행
✅ 아이디어 최소 5개 이상
✅ 노력/영향도 평가
✅ 우선순위 매트릭스
✅ 명확한 추천 방향
✅ .claude/brainstorms/ 폴더에 결과 저장
✅ 파일 경로 사용자에게 안내
```

절대 금지:

```text
❌ ARGUMENT 없이 브레인스토밍 시작
❌ 자료 수집 없이 아이디어 제시
❌ 단일 관점만 고려
❌ 평가 기준 없이 나열
❌ 다음 단계 없이 종료
❌ 결과 저장 없이 종료
```

## 병렬 실행 체크리스트

```text
✅ 다각도 수집: 외부 + 내부 + 분석 + MCP
✅ researcher: 트렌드, 사례, 베스트 프랙티스
✅ explore: 코드베이스, 현재 구조
✅ analyst/designer: 요구사항, UX
✅ main agent: MCP 가용 시 firecrawl_search/scrape 직접 실행
✅ 모델 선택: 조사(sonnet), 탐색(haiku), 아키텍처(opus)
✅ 병렬 실행 3-5개 권장
```

</validation>
