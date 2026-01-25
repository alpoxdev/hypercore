# 한국형 UI/UX Design - Agent Coordination

한국형 UI/UX 디자인 구현 시 에이전트 활용 가이드.

---

<agents_reference>

다중 에이전트 구조:
- 에이전트 목록: @../../instructions/multi-agent/agent-roster.md
- 조정 가이드: @../../instructions/multi-agent/coordination-guide.md
- 실행 패턴: @../../instructions/multi-agent/execution-patterns.md

</agents_reference>

---

<recommended_agents>

## 추천 에이전트

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **designer** | sonnet/opus | UI/UX 디자인 + 구현 (토스/카카오/배민 스타일) |
| **explore** | haiku | 한국형 앱 패턴 분석, 프로젝트 구조 파악 |
| **implementation-executor** | sonnet | Server Functions, 데이터 페칭, 비즈니스 로직 |
| **code-reviewer** | opus | 접근성(WCAG/KWCAG), 성능, 2026 트렌드 검토 |

</recommended_agents>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1: 한국형 패턴 분석 → 디자인 정의 → 병렬 구현

**용도:** 토스/카카오/배민 스타일 디자인 시스템 구축

```typescript
// Phase 1: 병렬 탐색
Task(
  subagent_type="explore",
  model="haiku",
  prompt="토스/카카오/배민 디자인 패턴 분석 (색상, 간격, 타이포)"
)

Task(
  subagent_type="explore",
  model="haiku",
  prompt="프로젝트 기존 컴포넌트 구조 분석"
)

// Phase 2: 디자인 방향 정의
Task(
  subagent_type="designer",
  model="opus",
  prompt=`한국형 서비스 디자인 방향 정의:
  - 미학적 톤: 테크 미니멀리즘 (토스/플렉스)
  - 2026 트렌드: 키네틱 타이포, 적응형 테마
  - 정보 밀도와 가독성 균형`
)

// Phase 3: 병렬 구현
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="컬러 시스템 (Primary Blue #3182F6, 60-30-10 규칙)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="타이포그래피 (한글 최적화, Pretendard/SUIT)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="컴포넌트 라이브러리 (버튼, 카드, 입력 필드)"
)
```

---

### 패턴 2: 대시보드 병렬 구현

**용도:** 통계 카드, 차트, 리스트 동시 작업

```typescript
// 여러 섹션 병렬 구현
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="대시보드 레이아웃 + 통계 카드 (벤토 그리드)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="차트 컴포넌트 + 마이크로 인터랙션"
)

Task(
  subagent_type="implementation-executor",
  model="sonnet",
  prompt="대시보드 데이터 페칭 + Server Functions"
)
```

---

### 패턴 3: 리뉴얼 프로젝트

**용도:** 기존 UI를 2026 트렌드로 리뉴얼

```typescript
// Phase 1: 현황 파악
Task(
  subagent_type="explore",
  model="haiku",
  prompt="기존 UI 컴포넌트 및 스타일 분석"
)

// Phase 2: 디자인 + 구현 병렬
Task(
  subagent_type="designer",
  model="opus",
  prompt="2026 트렌드 기반 리뉴얼 디자인 (키네틱/적응형)"
)

Task(
  subagent_type="implementation-executor",
  model="sonnet",
  prompt="기존 로직 유지하며 마이그레이션 계획"
)

// Phase 3: 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="리뉴얼 품질 검토 (접근성, 성능)"
)
```

---

### 패턴 4: 구현 → 다중 검증

**용도:** KWCAG, 성능, UX 라이팅 검증

```typescript
// 병렬 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="KWCAG 접근성 검토 (명암 대비 4.5:1, 키보드)"
)

Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="성능 검토 (60fps, 로딩 시간, 모바일 최적화)"
)

Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="UX 라이팅 검토 (대화하는 듯한 톤, 친근함)"
)
```

</coordination_patterns>

---

<model_routing>

## 모델 라우팅

| 작업 | 모델 | 이유 |
|------|------|------|
| **한국형 패턴 분석** | haiku | 빠른 조사 |
| **디자인 방향 정의** | opus | 트렌드 통합, 전략적 결정 |
| **컴포넌트 구현** | sonnet | UI 코드 작성 |
| **2026 트렌드 적용** | opus | 키네틱 타이포, 적응형 테마 |
| **접근성/성능 검증** | opus | 세밀한 검토 |

</model_routing>

---

<practical_examples>

## 실전 예시

### 예시 1: 새 서비스 디자인 시스템 구축

```typescript
// Phase 1: 병렬 탐색
Task(subagent_type="explore", model="haiku",
     prompt="토스/카카오/배민 디자인 패턴 분석")
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 기존 컴포넌트 구조 분석")

// Phase 2: 디자인 정의
Task(subagent_type="designer", model="opus",
     prompt="브랜드 아이덴티티 반영한 디자인 시스템 설계")

// Phase 3: 병렬 구현
Task(subagent_type="designer", model="sonnet", prompt="컬러 시스템")
Task(subagent_type="designer", model="sonnet", prompt="타이포그래피")
Task(subagent_type="designer", model="sonnet", prompt="컴포넌트 라이브러리")
```

---

### 예시 2: 대시보드 구현

```typescript
// 병렬 실행
Task(subagent_type="designer", model="sonnet",
     prompt="대시보드 레이아웃 + 통계 카드 (벤토 그리드)")
Task(subagent_type="designer", model="sonnet",
     prompt="차트 컴포넌트 + 마이크로 인터랙션")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="대시보드 데이터 페칭 + Server Functions")
```

---

### 예시 3: 2026 트렌드 리뉴얼

```typescript
// Phase 1: 현황 파악
Task(subagent_type="explore", model="haiku",
     prompt="기존 UI 컴포넌트 및 스타일 분석")

// Phase 2: 디자인 + 구현 병렬
Task(subagent_type="designer", model="opus",
     prompt="2026 트렌드 기반 리뉴얼 디자인 (키네틱/적응형)")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="기존 로직 유지하며 마이그레이션")

// Phase 3: 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="리뉴얼 품질 검토 (접근성, 성능)")
```

</practical_examples>

---

<best_practices>

## 모범 사례

### 작업 시작 전 체크

- [ ] 한국 사용자 대상? → 토스/카카오 패턴 참조
- [ ] 여러 컴포넌트 동시? → 병렬 designer
- [ ] 2026 트렌드 적용? → designer (opus) 사용
- [ ] 접근성 중요? → code-reviewer 검증 필수

### 한국형 서비스 패턴

| 서비스 | 색상 | 특징 |
|--------|------|------|
| 토스 | Blue #3182F6 | 신뢰감, 카드 중심 |
| 카카오 | Yellow #FEE500 | 친근함, 말풍선 |
| 배민 | Teal #2AC1BC | 감성, 일러스트 |

### 에이전트 활용 원칙

**DO:**
- 한국형 패턴 탐색 → explore (병렬)
- 디자인 + 구현 → designer + executor (병렬)
- 2026 트렌드 → designer (opus)
- KWCAG/성능 → code-reviewer (병렬)

**DON'T:**
- shadcn/ui 기본 스타일 그대로 사용
- 영문 위주 타이포그래피
- 접근성 검증 생략

### 2026 트렌드 활용

@designer 에이전트가 제공:
- AI 기반 개인화
- 키네틱 타이포그래피
- 적응형 테마 (라이트/다크)
- 마이크로 인터랙션
- 한국형 패턴과 조화

**참조:** `.claude/agents/designer.md`

### UX 라이팅

**DO:**
- "어떤 이름으로 불러드릴까요?"
- "조금만 기다려주세요"
- "확인했어요"

**DON'T:**
- "Please enter your name"
- "Loading..."
- "OK"

</best_practices>
