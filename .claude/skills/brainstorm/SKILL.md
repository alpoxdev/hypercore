---
name: brainstorm
description: 자료 수집 + 웹 검색 + 코드베이스 분석 기반 체계적 브레인스토밍. 아이디어 도출 및 구조화.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/sourcing/reliable-search.md
@../../instructions/context-optimization/redundant-exploration-prevention.md
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

## Brainstorm 전용 MCP 활용

@../../instructions/sourcing/reliable-search.md 참조

**브레인스토밍 특화 활용:**

| MCP 도구 | 활용 | 폴백 |
|----------|------|------|
| `firecrawl_search` | 주제별 심층 검색 (경쟁사, 트렌드) | WebSearch |
| `firecrawl_scrape` | 참고 사이트 컨텐츠 추출 | WebFetch |
| `firecrawl_map` | 경쟁사/참고 사이트 구조 파악 | WebFetch 수동 |
| `search_repositories/code` | GitHub 관련 프로젝트 검색 | `gh search` |

**MCP는 main agent가 직접 실행** (subagent는 MCP 도구 사용 불가)

</sourcing_strategy>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 0. MCP 감지 | Firecrawl/SearXNG/GitHub MCP 가용 여부 확인 | ToolSearch × 3 |
| 1. 입력 확인 | ARGUMENT 검증 | - |
| 2. 주제 분석 | 브레인스토밍 범위 결정 + 채널 배분 | sequentialthinking (1-2단계) |
| 3. 자료 수집 | 병렬 정보 수집 (웹 + MCP + 코드베이스, **현재 연도 포함 필수, 출처 신뢰도 확인**) | Task 병렬 + MCP 직접 실행 |
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

### 저장 규칙

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

## 병렬 에이전트 실행

@../../instructions/agent-patterns/delegation-patterns.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md

### Brainstorm 스킬 고유 패턴

- **다채널 수집**: WebSearch + SearXNG + Firecrawl을 병렬로 실행하여 아이디어 소스 수집
- **멀티 페르소나**: 여러 관점(사용자, 개발자, 비즈니스)에서 동시에 아이디어 평가
- **검색 신뢰성**: 검색 쿼리에 현재 연도(2026) 포함 필수, 수집 자료별 발행일+소스유형 기재

</parallel_agent_execution>

---

<ideation_framework>

## 아이디어 도출 프레임워크

### 기법 선택

| 상황 | 추천 기법 |
|------|----------|
| **신규 기능** | Tree of Thoughts, SCAMPER, Multi-Persona |
| **문제 해결** | Reverse Brainstorming, 5 Whys, ToT |
| **요구사항** | Starbursting (5W1H), How Might We |
| **평가** | 6 Thinking Hats, Multi-Persona |
| **빠른 발상** | Crazy 8s, SCAMPER |

### AI 핵심 기법

| 기법 | 원리 | 적합 상황 | AI 구현 |
|------|------|----------|--------|
| **Tree of Thoughts** | 트리 구조로 여러 경로 탐색 → 평가 → 확장 | 복잡한 문제, 의사결정 | 문제 분해 → 각 경로 병렬 생성 → 평가 (1-5) → 유망 경로 심화 |
| **Multi-Persona** | 여러 관점 시뮬레이션 | 다각도 검토, 제품 기획 | CEO/개발자/UX/고객/비평가 관점 병렬 실행 |
| **SCAMPER** | 7가지 질문 (대체/결합/적용/수정/전용/제거/재배열) | 체계적 발상 | 각 질문당 3+ 아이디어 |
| **Starbursting** | 5W1H 질문 중심 | 요구사항 발굴 | 각 질문당 5-10개 하위 질문 |
| **Reverse** | 역발상 (악화 → 역전환) | 막힌 상황, 예방 | 악화 시나리오 → 역전환 → 정제 |
| **6 Thinking Hats** | 6가지 관점 (정보/감정/비판/긍정/창의/프로세스) | 체계적 평가 | 6개 에이전트 병렬 분석 |
| **Crazy 8s** | 8가지 빠른 아이디어 | 초기 탐색 | 단순/진보/경쟁사/무제한/제로/미래/타분야/미친 |
| **5 Whys** | 5번 Why → 근본 원인 | 버그 분석, 진단 | 현상 → Why 1-5 → 근본 원인 |
| **How Might We** | HMW 질문 생성 | 문제 재정의, 기회 | "어떻게 [목표] 달성?" |

### Tree of Thoughts 병렬 패턴

```typescript
// 여러 경로 동시 탐색
Task({ subagent_type: 'analyst', prompt: '경로 A: [접근법 1] 심층 분석' })
Task({ subagent_type: 'analyst', prompt: '경로 B: [접근법 2] 심층 분석' })
Task({ subagent_type: 'analyst', prompt: '경로 C: [접근법 3] 심층 분석' })
// → 결과 비교 후 유망 경로 선택
```

### Multi-Persona 병렬 패턴

```typescript
// 여러 페르소나 동시 실행
Task({ subagent_type: 'analyst', prompt: 'CEO 관점: 비즈니스 가치 분석' })
Task({ subagent_type: 'architect', prompt: '개발자 관점: 기술적 실현 가능성' })
Task({ subagent_type: 'designer', prompt: 'UX 디자이너 관점: 사용자 경험' })
Task({ subagent_type: 'analyst', prompt: '고객 관점: 실제 사용 시나리오' })
Task({ subagent_type: 'analyst', prompt: '비평가 관점: 약점과 리스크' })
```

</ideation_framework>

---

<result_structure>

## 결과물 구조

| 섹션 | 내용 |
|------|------|
| **메타데이터** | 주제, 생성일, 관련 컨텍스트 |
| **📊 수집 자료 요약** | 외부 트렌드, 경쟁사/사례, 현재 시스템 (강점/개선/제약) |
| **💡 아이디어 목록** | 카테고리별 표 (ID, 아이디어, 설명, 노력, 영향도) |
| **📈 우선순위 매트릭스** | Quick Wins/Big Bets/Fill Ins/Money Pit 분류 |
| **🎯 추천 방향** | 최우선 추천, 다음 단계 (구체적 액션), 추가 탐색 필요 항목 |

</result_structure>

---

<examples>

## 실전 예시

### 핵심 예시: 기능 아이디어 브레인스토밍

```bash
사용자: /brainstorm 사용자 참여를 높일 방법

1. Sequential Thinking (2단계): 주제 분석 → 채널 배분
2. 병렬 자료 수집: researcher (트렌드+경쟁사) + explore (현재 플로우) + MCP
3. Sequential Thinking (3-5단계): 수집 결과 → SCAMPER 적용 → 우선순위
4. 결과 저장: .claude/brainstorms/00.사용자_참여_향상.md

결과 요약:
  ## 💡 아이디어 목록
  - 1-1: 진행률 표시 (낮음/높음) - Quick Win
  - 2-1: 연속 사용 보상 (낮음/높음) - Quick Win
  - 3-1: 친구 초대 리워드 (중간/높음)

  ## 🎯 추천: 1-1, 2-1 먼저 구현 (Quick Wins)
```

### 기타 예시

| 예시 | 프로세스 | 결과 |
|------|----------|------|
| **기술 선택** | 각 기술 병렬 조사 + 요구사항 분석 → 비교표 | WebSocket (Socket.io) 추천 |
| **UX 개선** | 경쟁사 UX + 베스트 프랙티스 + 현재 플로우 → HMW | Quick Wins (자동 선택, 인디케이터) 우선 |

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

신뢰도 검증:

```text
✅ 검색 쿼리에 현재 연도 포함 (2026)
✅ 수집 자료별 발행일/출처 확인
✅ 오래된 정보 (3년 이상) 제외 또는 명시
✅ 출처 신뢰도 평가 (공식 문서 > 기술 블로그 > 커뮤니티)
```

절대 금지:

```text
❌ ARGUMENT 없이 브레인스토밍 시작
❌ 자료 수집 없이 아이디어 제시
❌ 단일 관점만 고려
❌ 평가 기준 없이 나열
❌ 다음 단계 없이 종료
❌ 결과 저장 없이 종료
❌ 발행일 미확인 정보 기반 추천
```

## 병렬 실행 체크리스트

```text
✅ 다각도 수집: 외부 + 내부 + 분석 + MCP
✅ researcher: 트렌드, 사례, 베스트 프랙티스 (검색 쿼리에 현재 연도)
✅ explore: 코드베이스, 현재 구조
✅ analyst/designer: 요구사항, UX
✅ main agent: MCP 가용 시 firecrawl_search/scrape 직접 실행
✅ 모델 선택: 조사(sonnet), 탐색(haiku), 아키텍처(opus)
✅ 병렬 실행 3-5개 권장
```

</validation>
