---
name: startup-validator
description: Peter Thiel 7질문 + Y Combinator PMF 지표 + Mom Test 원칙으로 사업 아이디어를 냉정하게 검증. 점수화 + 약점 분석 + 개선 방향 제시.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Startup Validator Skill

> 검증된 프레임워크로 아이디어를 냉정하게 평가

---

<when_to_use>

| 상황 | 예시 |
|------|------|
| **아이디어 검증** | 새로운 사업 아이디어 평가 |
| **투자 유치 전** | 피칭 전 약점 파악 |
| **Pivot 결정** | 현재 방향 계속 vs 전환 |
| **경쟁 분석** | 우리 vs 경쟁사 비교 |
| **PMF 체크** | Product-Market Fit 달성 여부 |

```bash
/startup-validator AI 기반 교육 서비스
/startup-validator 구독형 헬스케어 앱
/startup-validator 크롤링 기반 구매대행 자동화
```

**결과물**: 종합 점수(100점) + 7가지 질문 분석 + 약점 진단 + 개선 로드맵

</when_to_use>

---

<argument_validation>

```
$ARGUMENTS 없음 → 즉시 질문:

"어떤 사업 아이디어를 검증할까요?

예시:
- 'AI 기반 교육 서비스'
- '구독형 헬스케어 앱'
- 'B2B SaaS 마케팅 자동화'"
```

</argument_validation>

---

<validation_frameworks>

## 핵심 검증 프레임워크

### 1. Peter Thiel의 7가지 질문 (Zero to One)

> "이 질문들에 좋은 답이 없으면, '불운'을 만나 실패할 것이다."

| # | 질문 | 평가 기준 | 배점 |
|---|------|----------|------|
| **1. Engineering** | 점진적 개선이 아닌 **10배 좋은 기술**을 만들 수 있는가? | 획기적 vs 점진적 | 15점 |
| **2. Timing** | 지금이 이 사업을 시작하기에 **적절한 시기**인가? | 시장 성숙도, 규제, 기술 준비도 | 10점 |
| **3. Monopoly** | **작은 시장에서 큰 점유율**로 시작하는가? | 니치 집중 vs 분산 | 15점 |
| **4. People** | **적절한 팀**이 있는가? | 창업자-시장 적합성 | 10점 |
| **5. Distribution** | 제품을 **전달할 방법**이 있는가? | 채널, GTM 전략 | 15점 |
| **6. Durability** | 10-20년 후에도 **방어 가능**한가? | 해자(Moat) 존재 | 15점 |
| **7. Secret** | 다른 사람들이 보지 못하는 **독특한 기회**를 발견했는가? | 비밀/인사이트 보유 | 20점 |

> 출처: [Zero to One](https://grahammann.net/book-notes/zero-to-one-peter-thiel), Peter Thiel

---

### 2. Y Combinator PMF 지표 (Michael Seibel)

> "PMF에 도달하면 수요 감당이 안 되어 정신없다."

| 지표 | 설명 | 체크 |
|------|------|------|
| **수요 폭발** | 만드는 속도 < 구매/사용 속도 | ☐ |
| **유기적 성장** | 40-60%가 입소문 | ☐ |
| **지원 폭주** | 고객 요청 감당 불가 | ☐ |
| **사용자 불만** | 다운타임에 격렬한 반응 | ☐ |
| **재방문** | 핵심 지표 반복 사용 | ☐ |

**PMF 이전 체크리스트**:
- [ ] "머리에 불이 난" 문제인가? (Hair on Fire)
- [ ] 2인 스타트업의 조잡한 v1도 사용할 고객이 있는가?
- [ ] 고객이 돈을 내고 있는가? (또는 내겠다고 약속했는가?)

> 출처: [Y Combinator Library](https://www.ycombinator.com/library/5z-the-real-product-market-fit)

---

### 3. The Mom Test (Rob Fitzpatrick)

> "당신의 아이디어가 좋은지 묻지 마라. 모두가 거짓말할 것이다."

**3가지 핵심 규칙**:

| 규칙 | 올바른 질문 | 잘못된 질문 |
|------|------------|------------|
| **고객 삶에 집중** | "지난번 이 문제를 어떻게 해결했나요?" | "우리 서비스 쓸 건가요?" |
| **과거 구체적 사례** | "마지막으로 X를 한 게 언제였나요?" | "보통 얼마나 자주 X 하나요?" |
| **듣기 > 말하기** | (침묵, 경청) | (우리 제품 설명 5분) |

**피해야 할 나쁜 데이터**:
- ❌ **칭찬**: "좋은 아이디어네요!"
- ❌ **가정적 표현**: "아마 사용할 것 같아요..."
- ❌ **위시리스트**: "X, Y, Z도 있으면 좋겠어요..."

> 출처: [The Mom Test Summary](https://www.ricklindquist.com/notes/the-mom-test-by-rob-fitzpatrick)

---

### 4. Customer Development 검증 (Steve Blank)

**4단계 검증**:

| 단계 | 질문 | 증거 |
|------|------|------|
| **Customer Discovery** | 문제가 실재하는가? | 인터뷰 10+ |
| **Customer Validation** | 반복/확장 가능한가? | 유료 고객 5+ |
| **Customer Creation** | 수요 창출 가능한가? | 유기적 성장 |
| **Company Building** | 조직화 가능한가? | 프로세스 존재 |

> 출처: [Steve Blank Customer Development](https://steveblank.com/tag/customer-development/)

---

### 5. JTBD 검증 (Clayton Christensen)

**Forces of Progress 분석**:

```
변화를 향한 힘:
├── PUSH (현재 상황의 문제) ──┐
│                            ├──→ 새로운 솔루션
└── PULL (새 솔루션의 매력) ──┘

변화를 막는 힘:
├── HABIT (현재 상황의 관성) ─┐
│                            ├──→ 현상 유지
└── ANXIETY (새 솔루션 불안) ─┘
```

**전환 조건**: Push + Pull > Habit + Anxiety

> 출처: [Christensen Institute JTBD](https://www.christenseninstitute.org/theory/jobs-to-be-done/)

---

### 6. Lean Canvas 핵심 검증

| 블록 | 검증 질문 | 위험 수준 |
|------|----------|----------|
| **Problem** | 상위 3개 문제가 실재하는가? | 높음 |
| **Customer Segments** | 얼리어답터를 명확히 정의했는가? | 높음 |
| **Unique Value Proposition** | 한 문장으로 차별화 설명 가능한가? | 높음 |
| **Solution** | MVP로 검증 가능한가? | 중간 |
| **Channels** | 고객 도달 경로가 있는가? | 중간 |
| **Revenue Streams** | 고객이 돈을 낼 의향이 있는가? | 높음 |
| **Cost Structure** | 단위 경제학이 성립하는가? | 중간 |
| **Key Metrics** | 핵심 지표 1개를 정했는가? | 중간 |
| **Unfair Advantage** | 쉽게 복제 불가능한 것이 있는가? | 높음 |

> 출처: [Lean Canvas - Ash Maurya](https://leanstack.com/about)

</validation_frameworks>

---

<scoring_system>

## 점수 체계

### 종합 점수 (100점 만점)

| 영역 | 배점 | 평가 기준 |
|------|------|----------|
| **Thiel 7질문** | 100점 | 위 표 참조 |
| **PMF 준비도** | 가산점 | +10점 (5개 중 3개 이상 체크) |
| **위험 요소** | 감점 | -10점 (치명적 약점당) |

### 등급 체계

| 등급 | 점수 | 판정 | 다음 단계 |
|------|------|------|----------|
| **S** | 90+ | 즉시 실행 | 풀타임 전환, 투자 유치 |
| **A** | 80-89 | 유망함 | 약점 보완 후 진행 |
| **B** | 70-79 | 가능성 있음 | 추가 검증 필요 |
| **C** | 60-69 | 재검토 필요 | Pivot 고려 |
| **D** | 50-59 | 위험함 | 근본적 재설계 |
| **F** | <50 | 중단 권고 | 다른 아이디어 탐색 |

### 약점 심각도

| 수준 | 설명 | 조치 |
|------|------|------|
| **치명적 (Critical)** | 이 약점이 해결 안 되면 실패 | 즉시 해결 필수 |
| **중대 (Major)** | 성장 병목이 될 것 | 6개월 내 해결 |
| **경미 (Minor)** | 개선하면 좋음 | 우선순위 낮음 |

</scoring_system>

---

<workflow>

| Phase | 작업 | 도구 | 필수 체크 |
|-------|------|------|----------|
| **0** | 입력 확인 | - | ARGUMENT 검증 |
| **1** | 아이디어 이해 | ST 3단계 | 핵심 가설 3개 추출 |
| **2** | 7질문 분석 | Task 병렬 x3 | 각 질문별 점수 + 근거 |
| **3** | PMF/JTBD 검증 | ST 5단계 | Forces 분석, PMF 체크리스트 |
| **4** | 종합 평가 | ST 3단계 | 점수화 + 등급 + 약점 |
| **5** | 개선 로드맵 | ST 3단계 | 우선순위별 액션 |
| **6** | 저장 | Write | .claude/validation-results/ |

### Phase 1: 핵심 가설 추출

```
Sequential Thinking:
  thought 1: 아이디어 핵심 정의 (한 문장)
  thought 2: 가치 가설 (Value Hypothesis) - 고객이 원하는가?
  thought 3: 성장 가설 (Growth Hypothesis) - 확장 가능한가?
```

### Phase 2: 7질문 병렬 분석

```typescript
// 3그룹 병렬 분석 (ToT 구조)
Task({ subagent_type: 'analyst', model: 'sonnet',
       prompt: 'Thiel 질문 1-2-3 (Engineering, Timing, Monopoly) 분석, 각 점수/근거' })
Task({ subagent_type: 'analyst', model: 'sonnet',
       prompt: 'Thiel 질문 4-5 (People, Distribution) 분석, 각 점수/근거' })
Task({ subagent_type: 'analyst', model: 'sonnet',
       prompt: 'Thiel 질문 6-7 (Durability, Secret) 분석, 각 점수/근거' })
```

### Phase 3: Forces of Progress

```
Sequential Thinking:
  thought 1: PUSH - 현재 상황의 고통/불편
  thought 2: PULL - 새 솔루션의 매력
  thought 3: HABIT - 현재 방식의 관성
  thought 4: ANXIETY - 전환 불안 요소
  thought 5: 전환 확률 = (Push + Pull) vs (Habit + Anxiety)
```

### Phase 4: 종합 평가

```
Sequential Thinking:
  thought 1: 7질문 총점 계산
  thought 2: PMF 가산점 판정
  thought 3: 치명적 약점 식별 → 감점
  thought 4: 최종 등급 결정
```

</workflow>

---

<result_structure>

| 섹션 | 내용 |
|------|------|
| **헤더** | 생성일, 아이디어명, 종합 등급/점수 |
| **1. Executive Summary** | 한 문장 판정 + 핵심 강점/약점 |
| **2. Thiel 7질문 분석** | 질문별 점수 + 상세 분석 |
| **3. PMF 준비도** | 체크리스트 + Forces 분석 |
| **4. 약점 진단** | 심각도별 분류 + 근거 |
| **5. 개선 로드맵** | 우선순위별 액션 (즉시/30일/90일) |
| **6. Go/No-Go 판정** | 최종 권고 |

### 7질문 분석 형식

```markdown
### Q1. Engineering (10배 기술) - [X]/15점

**현황**: [현재 기술/제품 설명]
**10배 기준**: [비교 대상 vs 우리]
**점수 근거**: [구체적 이유]
**개선 방향**: [있다면]
```

### 약점 진단 형식

```markdown
### [치명적] 약점 1: [제목]

**현황**: [문제 설명]
**위험**: [해결 안 하면 발생할 일]
**해결책**: [구체적 방안]
**필요 리소스**: [시간/비용/인력]
```

### 개선 로드맵 형식

```markdown
## 즉시 (This Week)
1. [액션] - [목표] - [담당]

## 30일 내
1. [액션] - [목표] - [담당]

## 90일 내
1. [액션] - [목표] - [담당]
```

</result_structure>

---

<examples>

```bash
/startup-validator 크롤링 기반 구매대행 자동화

Phase 1: 핵심 가설 추출
  - 핵심: "AI로 이커머스 상품 크롤링 → 자동 구매대행"
  - 가치 가설: 구매대행 업자들이 수동 작업에 지쳐있다
  - 성장 가설: 자동화로 처리량 10배 → 매출 10배

Phase 2: 7질문 분석 (병렬)
  Q1. Engineering: 8/15 (크롤링은 10배 기술 아님, AI 분석이 차별점)
  Q2. Timing: 9/10 (AI 기술 성숙, 이커머스 성장)
  Q3. Monopoly: 12/15 (특정 카테고리 집중 가능)
  Q4. People: 7/10 (이커머스 경험 필요)
  Q5. Distribution: 10/15 (구매대행 커뮤니티 접근 가능)
  Q6. Durability: 8/15 (플랫폼 정책 리스크)
  Q7. Secret: 12/20 (AI 가격 예측 인사이트)

Phase 3: Forces 분석
  PUSH: 수동 작업 고통 (높음)
  PULL: 자동화 매력 (높음)
  HABIT: 기존 툴 익숙함 (중간)
  ANXIETY: 새 시스템 학습 비용 (낮음)
  → 전환 확률: 높음

Phase 4: 종합 평가
  총점: 66/100 → 등급: C
  치명적 약점: 플랫폼 정책 의존성
  중대 약점: 10배 기술 부재

저장: .claude/validation-results/00.구매대행_자동화.md
```

</examples>

---

<validation>

| 항목 | 필수 |
|------|------|
| ARGUMENT | 없으면 즉시 질문 |
| Phase 1 | 핵심 가설 3개 (한 문장, 가치, 성장) |
| Phase 2 | **7질문 모두** 점수 + 근거 |
| Phase 3 | **Forces 4가지** 분석 + PMF 체크 |
| Phase 4 | 총점 + 등급 + **약점 심각도 분류** |
| Phase 5 | 즉시/30일/90일 로드맵 |
| 저장 | .claude/validation-results/ |

| 금지 |
|------|
| ❌ ARGUMENT 없이 시작 |
| ❌ 7질문 중 일부만 분석 |
| ❌ 점수 없이 정성적 평가만 |
| ❌ 약점 없이 긍정적 평가만 |
| ❌ 개선 방향 없이 비판만 |
| ❌ 저장 없이 종료 |

</validation>

---

<synergy_with_genius_thinking>

## genius-thinking과 연계

| 단계 | 스킬 | 목적 |
|------|------|------|
| **1. 발상** | `/genius-thinking` | 10개+ 아이디어 생성 |
| **2. 검증** | `/startup-validator` | 상위 3개 엄격 검증 |
| **3. 선택** | 종합 판단 | 최고 점수 아이디어 선택 |

```bash
# 워크플로우 예시
/genius-thinking AI 헬스케어 사업 아이디어
→ 10개 아이디어 생성

/startup-validator [아이디어 1: AI 건강검진 예측]
/startup-validator [아이디어 2: 맞춤형 영양제 구독]
/startup-validator [아이디어 3: 원격 진료 매칭]
→ 각각 점수화

→ 최고 점수 아이디어로 진행
```

</synergy_with_genius_thinking>

---

<references>

**핵심 프레임워크**:
- Zero to One: [Peter Thiel Book Notes](https://grahammann.net/book-notes/zero-to-one-peter-thiel)
- 7 Questions: [Startup Must Answer](https://fjbookclub.substack.com/p/zero-to-one-7-questions-every-business)
- PMF: [Y Combinator Library](https://www.ycombinator.com/library/5z-the-real-product-market-fit)
- Michael Seibel: [Real Product-Market Fit](https://blog.ycombinator.com/the-real-product-market-fit/)

**검증 방법론**:
- The Mom Test: [Summary](https://www.ricklindquist.com/notes/the-mom-test-by-rob-fitzpatrick)
- Customer Development: [Steve Blank](https://steveblank.com/tag/customer-development/)
- Lean Canvas: [Ash Maurya](https://leanstack.com/about)
- JTBD: [Christensen Institute](https://www.christenseninstitute.org/theory/jobs-to-be-done/)

**추가 자료**:
- Paul Graham: [How to Get Startup Ideas](https://paulgraham.com/startupideas.html)
- Lean Startup: [Eric Ries](https://theleanstartup.com/principles)
- Pretotyping: [Alberto Savoia](https://www.pretotyping.org/)

</references>
