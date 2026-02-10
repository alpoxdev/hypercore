---
name: elon-musk
description: 제1원칙 사고법(First Principles Thinking)으로 문제의 본질을 파악하고 혁신적 해결책 도출. 도메인 자동 검색 + 가정 해체 + 재설계 + Inversion 기반 실행 계획.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/sourcing/reliable-search.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Elon Musk Skill

> 제1원칙 사고법: 유추(analogy)가 아닌 기본 진리에서 추론하여 문제를 해결

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **뻔한 답만 나올 때** | "매출 올리려면 광고?" → 본질 재설계 |
| **비용/구조 혁신** | "서버비 절감 방법" → 원자재 수준 분해 |
| **고정관념 타파** | "원래 이렇게 해왔는데..." → 관행 vs 물리법칙 분리 |
| **전략적 의사결정** | "A vs B 선택" → 본질에서 재출발 |
| **시장 진입 전략** | "경쟁사 따라가기?" → 제1원칙에서 새 구조 |

## 호출 방법

```bash
# 기본 사용
/elon-musk SaaS 가격 책정이 레드오션이라 차별화가 안됨

# 기술 문제
/elon-musk 서버 인프라 비용이 매출의 40%를 차지함

# 비즈니스 문제
/elon-musk 고객 이탈률이 높은데 기존 리텐션 전략이 안 먹힘
```

## 결과물

- **가정 해체 매트릭스**: 당연시하던 가정들을 물리적 제약/관행/검증 필요로 분류
- **기존 vs 제1원칙 비교 테이블**: 유추적 접근 vs 본질에서 재설계한 접근
- **혁신적 해결책**: 본질만 남긴 상태에서 도출한 새로운 구조
- **실행 계획 + 리스크 매트릭스**: Inversion(역전 사고) 기반 실패 시나리오 대비

</when_to_use>

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"어떤 문제를 제1원칙으로 해체할까요?

예시:
- 비용 혁신: 'SaaS 인프라 비용이 매출의 40%'
- 전략 수립: '시장 진입인데 뻔한 전략밖에 안 보임'
- 고정관념 타파: '원래 이렇게 해왔는데 근본적으로 맞는지 모르겠음'
- 기술 선택: '모든 선택지가 비슷해 보이는데 본질적 차이를 알고 싶음'"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<core_philosophy>

## 제1원칙 사고법 (First Principles Thinking)

### 핵심 원리

> "유추(analogy)로 삶을 살아간다. 본질적으로 다른 사람들이 하는 것을 약간 변형해서 복사하는 것이다.
> 새로운 것을 하고 싶을 때는 제1원칙 접근법을 적용해야 한다."
> — Elon Musk, TED 2013

| 구분 | 유추적 사고 (Analogy) | 제1원칙 사고 (First Principles) |
|------|---------------------|------------------------------|
| **방식** | 남들 따라하기 + 약간 변형 | 기본 진리로 분해 → 재구성 |
| **질문** | "다른 곳에서는 어떻게?" | "무엇이 확실히 사실인가?" |
| **결과** | 점진적 개선 | 파괴적 혁신 가능 |
| **비용** | 정신적 에너지 낮음 | 정신적 에너지 높음 |
| **적합** | 일상적 결정, 빠른 실행 | 혁신 필요, 막힌 상황 돌파 |

### 사례

| 사례 | 기존 가정 (유추) | 제1원칙 분해 | 결과 |
|------|-----------------|-------------|------|
| **SpaceX** | "로켓은 비싸다" (6,500만$) | 원자재 = 가격의 2% | 90% 비용 절감 |
| **Tesla** | "배터리팩 600$/kWh" | LME 원자재 = 80$/kWh | 80%+ 절감 예측 |

### 보조 사고법 통합

| 사고법 | 역할 | 적용 Phase |
|--------|------|-----------|
| **소크라테스 질문법** | 가정 해체의 도구 (6가지 질문) | Phase 2 |
| **Inversion** (Munger) | "어떻게 실패할까?" 역전 사고 | Phase 4 |
| **Pre-mortem** | "6개월 후 실패했다면 왜?" | Phase 4 |

</core_philosophy>

---

<workflow>

## 실행 흐름

| Phase | 작업 | 도구 | 핵심 |
|-------|------|------|------|
| **0** | 입력 확인 + 환경 감지 | ToolSearch | MCP 가용성 확인 |
| **1** | 도메인 조사 (업계 통념 + 팩트 + 혁신 사례) | Task 병렬 (researcher x3) | 3방향 동시 수집 |
| **2** | 가정 해체 (소크라테스 질문 → A/B/C 분류) | Sequential Thinking (5-7단계) | 물리적 제약 vs 관행 분리 |
| **3** | 본질 재설계 (기본 진리에서 새 구조) | Task 병렬 (analyst x3) | 3-5개 대안 경로 탐색 |
| **4** | 실행 + 리스크 (Inversion + Pre-mortem) | Sequential Thinking (3-5단계) | 실패 시나리오 대비 |
| **5** | 저장 + 제시 | Write | .claude/first-principles/ |

### 복잡도별 사고 패턴

| 복잡도 | Phase 2 사고 | Phase 4 사고 | 판단 기준 |
|--------|-------------|-------------|----------|
| **간단** | 3단계 | 2단계 | 단일 도메인, 가정 3개 이하 |
| **보통** | 5단계 | 3단계 | 다중 도메인, 가정 5-7개 |
| **복잡** | 7+단계 | 5단계 | 산업 전체, 가정 10개+ |

</workflow>

---

<sourcing_strategy>

## 검색 채널

@reliable-search.md 참조 (Tier 1 MCP 우선, Tier 2 내장 도구 폴백)

### Phase 0: MCP 감지

```
ToolSearch("firecrawl") → Firecrawl 활성화
ToolSearch("searxng")   → SearXNG 활성화
ToolSearch("github")    → GitHub MCP 활성화

MCP 가용 시 → researcher 에이전트 프롬프트에 MCP 결과 전달
MCP 미가용 시 → researcher가 WebSearch + WebFetch로 수행
```

</sourcing_strategy>

---

<parallel_agent_execution>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "first-principles-team", description: "제1원칙 분석" })
Task(subagent_type="researcher", team_name="first-principles-team", name="researcher", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

## 병렬 Agent 실행

### Phase 1: 도메인 조사 (3방향 동시)

| 에이전트 | 타입 | 목표 | 출처 요구사항 |
|----------|------|------|-------------|
| 1-A | researcher | 업계 통념/관행: "원래 이렇게", 기존 접근법, 비용 구조 | URL + 발행일 + 소스유형 필수, 현재 연도 포함 |
| 1-B | researcher | 실제 팩트/데이터: 원가, 벤치마크, 물리적 제약 | URL + 발행일 필수, 최신 데이터 우선 (12개월 이내) |
| 1-C | researcher | 혁신 사례: 가정을 깨뜨린 기업/프로젝트 | URL + 발행일 필수 |

**효과:** 통념 + 팩트 + 사례 3방향 → Phase 2에서 가정 vs 진실 대조 가능

---

### Phase 3: 대안 경로 탐색 (3방향 동시)

Phase 2에서 도출된 기본 진리를 바탕으로 3개 대안 경로를 병렬 분석

| 에이전트 | 타입 | 평가 기준 |
|----------|------|----------|
| 3-A | analyst | 경로 A: 실현 가능성(1-5), 영향도(1-5), 필요 자원, 리스크 |
| 3-B | analyst | 경로 B: 실현 가능성(1-5), 영향도(1-5), 필요 자원, 리스크 |
| 3-C | analyst | 경로 C: 실현 가능성(1-5), 영향도(1-5), 필요 자원, 리스크 |

---

### Model Routing

| Phase | 에이전트 | 모델 | 이유 |
|-------|---------|------|------|
| 1 | @researcher x3 | sonnet | 웹 검색 + 팩트 수집 |
| 2 | Sequential Thinking | (main) | 소크라테스 질문 적용 |
| 3 | @analyst x3 | sonnet | 대안 경로 실현 가능성 분석 |
| 4 | Sequential Thinking | (main) | Inversion + Pre-mortem |

</parallel_agent_execution>

---

<phase_details>

## Phase 2: 가정 해체 (핵심)

### 소크라테스 6가지 질문 적용

Phase 1에서 수집된 "업계 통념"에 대해:

| 질문 유형 | 질문 | 목적 |
|----------|------|------|
| **명확화** | "정확히 무엇을 의미하는가?" | 모호한 가정 구체화 |
| **가정 탐색** | "무엇을 가정하고 있는가?" | 숨겨진 전제 노출 |
| **증거 검증** | "이것이 사실이라는 증거는?" | 팩트 vs 믿음 구분 |
| **관점 전환** | "다른 방식으로 볼 수 있는가?" | 고정관념 탈피 |
| **함의 탐구** | "이것이 거짓이라면 어떻게 되는가?" | 가정 제거 시 영향 분석 |
| **메타 질문** | "왜 이것을 당연시했는가?" | 관성 vs 논리 구분 |

### 3분류 체계

각 가정을 반드시 다음 중 하나로 분류:

| 분류 | 기호 | 정의 | 처리 |
|------|------|------|------|
| **물리적/기술적 제약** | A | 자연법칙, 수학적 한계, 기술적 불가능 | 존중 (기본 진리) |
| **관성적 관행** | B | "원래 그래왔으니까", 남들 따라하기 | 제거 대상 |
| **검증 필요** | C | 데이터로 확인 가능하지만 아직 미검증 | 추가 WebSearch |

### Phase 2 Sequential Thinking 패턴

```
thought 1: Phase 1 수집 자료에서 가정 목록 추출 (5-10개)
thought 2: 각 가정에 소크라테스 질문 적용 → A/B/C 초기 분류
thought 3: C 항목에 대해 Phase 1 팩트 데이터로 교차 검증
thought 4: 검증 불가능한 C → 추가 WebSearch 실행
thought 5: 최종 분류 확정 → 가정 해체 매트릭스 완성
```

---

## Phase 3: 본질 재설계

### 입력

Phase 2에서 확정된:
- **A 항목** (기본 진리): 존중해야 할 진짜 제약
- **B 항목** (제거됨): 관행이었음이 확인된 것들

### 프로세스

```
1. A(기본 진리)만 남기고 B(관행) 전부 제거
2. "이 기본 진리로부터, 제약 없이 설계한다면?"
3. 3-5개 대안 경로를 병렬 analyst로 탐색
4. "기존 방식 vs 제1원칙 방식" 비교 테이블 생성
5. 최적 경로 선택 + 근거 제시
```

---

## Phase 4: 실행 + 리스크

| 사고법 | 핵심 질문 | 프로세스 |
|--------|----------|----------|
| **Inversion** | "어떻게 확실히 실패할까?" | 실패 시나리오 5-7개 → 예방 전략 매핑 |
| **Pre-mortem** | "6개월 후 실패했다면 왜?" | 실패 원인 3개 → 사전 대응 + "내가 실수할 순간" 구체화 |

</phase_details>

---

<document_storage>

## 결과 저장

| 항목 | 규칙 |
|------|------|
| **경로** | `.claude/first-principles/[넘버링].[문제_요약].md` |
| **넘버링** | `ls .claude/first-principles/ \| wc -l` 결과 |
| **워크플로우** | 폴더 생성 → Write → 사용자 경로 안내 |

</document_storage>

---

<result_structure>

## 결과물 구조

| 섹션 | 내용 |
|------|------|
| **헤더** | 생성일, 문제 설명 |
| **1. 도메인 현황** | 업계 통념, 실제 팩트, 혁신 사례 (출처 URL 필수) |
| **2. 가정 해체 매트릭스** | 가정 목록 + 소크라테스 질문 + A/B/C 분류 + 근거 |
| **3. 본질 재설계** | 기존 vs 제1원칙 비교, 대안 경로 평가, 최종 해결책 |
| **4. 실행 + 리스크** | 단계별 액션, Inversion 실패 시나리오, Pre-mortem, 실수 가능 순간 |
| **출처** | 모든 참조 URL 목록 |

</result_structure>

---

<examples>

## 핵심 예시: 비용 혁신

```bash
사용자: /elon-musk SaaS 인프라 비용이 매출의 40%

Phase 0: MCP 감지 (ToolSearch)
Phase 1: 병렬 researcher x3:
  1-A: "SaaS 인프라 업계 통념 — 클라우드 비용 구조, 표준 접근법"
  1-B: "실제 컴퓨팅 원가 — 전력, 하드웨어, 네트워크 단가 팩트 (12개월 이내)"
  1-C: "인프라 비용을 파괴적으로 절감한 사례 — Cloudflare Workers, Fly.io"

Phase 2: Sequential Thinking (가정 해체):
  가정 1: "AWS가 최선이다" → B (관행) — 실제 원가 대비 마진 확인
  가정 2: "서버리스가 저렴하다" → C→B — 요청당 단가 vs 예약 인스턴스
  가정 3: "지연시간에는 CDN이 필수" → A (제약) — 물리: 빛의 속도

Phase 3: 병렬 analyst x3:
  경로 A: "베어메탈 + 자체 오케스트레이션"
  경로 B: "하이브리드 (핫 경로=예약, 콜드 경로=서버리스)"
  경로 C: "엣지 컴퓨팅 전환 (Cloudflare Workers)"

Phase 4: Inversion + Pre-mortem
  실패: "마이그레이션 중 다운타임" → 블루-그린 배포
  실패: "운영 복잡도 증가" → 자동화 파이프라인 선행

저장: .claude/first-principles/00.SaaS_인프라_비용_혁신.md
```

## 기타 사례

- **전략적 의사결정**: 고객 이탈 → 가격 vs 습관 형성 vs 커뮤니티 네트워크 효과 분석
- **기술 문제**: 모바일 성능 → 번들 최적화 vs 오프라인 퍼스트 vs SSR

</examples>

---

<validation>

## 검증 체크리스트

| 항목 | 필수 |
|------|------|
| **ARGUMENT** | 없으면 즉시 질문 |
| **Phase 0** | MCP 가용성 감지 |
| **Phase 1** | researcher x3 (통념 + 팩트 + 사례), 출처 등급(S/A/B/C) 표기 |
| **Phase 2** | Sequential Thinking 3단계+, A/B/C 분류 5개+, 핵심 팩트 교차검증 2개+ |
| **Phase 3** | analyst x3, "기존 vs 제1원칙" 비교 테이블 |
| **Phase 4** | Inversion 3개+, Pre-mortem, "실수 가능 순간" |
| **저장** | .claude/first-principles/ |
| **출처** | 모든 팩트 URL + 발행일 + 소스유형 |

| 금지 | |
|------|------|
| ❌ | ARGUMENT 없이 분석 시작 |
| ❌ | 도메인 조사 없이 가정 해체 |
| ❌ | A/B/C 분류 없이 재설계 |
| ❌ | Inversion 없이 실행 계획 |
| ❌ | 출처 없는 팩트 주장 |
| ❌ | 유추적 사고 (남들 사례 복사) |
| ❌ | 결과 저장 없이 종료 |

</validation>
