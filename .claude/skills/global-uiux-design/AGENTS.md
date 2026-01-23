# Global UI/UX Design - Agent Coordination

글로벌 UI/UX 디자인 구현 시 에이전트 활용 가이드.

---

<agents_reference>

전체 에이전트 조정 가이드: @../../PARALLEL_AGENTS.md

</agents_reference>

---

<recommended_agents>

## 추천 에이전트

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **designer** | sonnet/opus | UI/UX 디자인 + 구현 (Material 3, Apple HIG, Fluent 2) |
| **explore** | haiku | 디자인 시스템 패턴 분석, 프로젝트 구조 파악 |
| **implementation-executor** | sonnet | API 연동, 상태 관리, 비즈니스 로직 |
| **code-reviewer** | opus | 접근성(WCAG 2.2), 성능, 크로스 플랫폼 검토 |

</recommended_agents>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1: 디자인 시스템 분석 → 방향 정의 → 병렬 구현

**용도:** 글로벌 표준 기반 디자인 시스템 구축

```typescript
// Phase 1: 병렬 탐색
Task(
  subagent_type="explore",
  model="haiku",
  prompt="Material 3, Apple HIG, Fluent 2 최신 패턴 분석"
)

Task(
  subagent_type="explore",
  model="haiku",
  prompt="프로젝트 기존 컴포넌트 및 다국어 지원 현황"
)

// Phase 2: 디자인 방향 정의
Task(
  subagent_type="designer",
  model="opus",
  prompt=`글로벌 서비스 디자인 방향 정의:
  - 미학적 톤 선택 (Material 3 기반)
  - 2026 트렌드 통합 (AI 기반, 적응형 테마)
  - 크로스 플랫폼 일관성`
)

// Phase 3: 병렬 구현
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="컬러 시스템 (다크 모드 포함, Material 3 Dynamic Color)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="타이포그래피 (다국어 지원, 시스템 폰트)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="컴포넌트 라이브러리 (웹 컴포넌트 기반)"
)
```

---

### 패턴 2: 크로스 플랫폼 병렬 구현

**용도:** 웹/iOS/Android 동시 개발

```typescript
// 각 플랫폼 병렬 구현
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="웹 인터페이스 (Material 3 기반, 반응형)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="iOS 인터페이스 (Apple HIG 준수, Swift UI)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="Android 인터페이스 (Material 3 네이티브)"
)

Task(
  subagent_type="implementation-executor",
  model="sonnet",
  prompt="공통 비즈니스 로직 및 상태 관리"
)
```

---

### 패턴 3: 공간 UI 프로젝트 (AR/VR)

**용도:** WebGPU/WebXR 기반 공간 UI

```typescript
// Phase 1: 탐색
Task(
  subagent_type="explore",
  model="haiku",
  prompt="WebGPU/WebXR 지원 현황 및 공간 UI 패턴"
)

// Phase 2: 디자인 + 구현 병렬
Task(
  subagent_type="designer",
  model="opus",
  prompt="3D 공간 UI 디자인 (Vision Pro 스타일)"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="2D 폴백 인터페이스 (점진적 향상)"
)

Task(
  subagent_type="implementation-executor",
  model="sonnet",
  prompt="WebXR 통합 및 센서 처리"
)

// Phase 3: 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="공간 UI 접근성 및 성능 검토"
)
```

---

### 패턴 4: 구현 → 다중 검증

**용도:** WCAG 2.2, 성능, 접근성 검증

```typescript
// 병렬 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="WCAG 2.2 AA 접근성 검토 (대비, 키보드, ARIA)"
)

Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="성능 검토 (60fps, 번들 크기, 로딩)"
)

Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="크로스 플랫폼 일관성 검토 (iOS/Android/Web)"
)
```

</coordination_patterns>

---

<model_routing>

## 모델 라우팅

| 작업 | 모델 | 이유 |
|------|------|------|
| **디자인 시스템 분석** | haiku | 빠른 패턴 조사 |
| **디자인 방향 정의** | opus | 전략적 결정, 트렌드 통합 |
| **컴포넌트 구현** | sonnet | UI 코드 작성 |
| **공간 UI 디자인** | opus | 복잡한 3D 인터랙션 |
| **접근성/성능 검증** | opus | 세밀한 검토 |

</model_routing>

---

<practical_examples>

## 실전 예시

### 예시 1: 글로벌 SaaS 디자인 시스템

```typescript
// Phase 1: 병렬 탐색
Task(subagent_type="explore", model="haiku",
     prompt="Material 3, Fluent 2 디자인 토큰 분석")
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 기존 컴포넌트 현황")

// Phase 2: 디자인 정의
Task(subagent_type="designer", model="opus",
     prompt="크로스 플랫폼 디자인 토큰 시스템 설계")

// Phase 3: 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt="컬러 시스템 (다크 모드 포함)")
Task(subagent_type="designer", model="sonnet",
     prompt="타이포그래피 (다국어)")
Task(subagent_type="designer", model="sonnet",
     prompt="컴포넌트 라이브러리")

// Phase 4: 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="WCAG 2.2, 크로스 플랫폼 검증")
```

---

### 예시 2: 크로스 플랫폼 애플리케이션

```typescript
// 병렬 실행 (플랫폼별)
Task(subagent_type="designer", model="sonnet",
     prompt="웹 인터페이스 (Material 3 기반)")
Task(subagent_type="designer", model="sonnet",
     prompt="iOS 인터페이스 (Apple HIG 준수)")
Task(subagent_type="designer", model="sonnet",
     prompt="Android 인터페이스 (Material 3 네이티브)")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="공통 비즈니스 로직 및 상태 관리")
```

---

### 예시 3: 2026 트렌드 적용 (AI 기반 UI)

```typescript
// Phase 1: 탐색
Task(subagent_type="explore", model="haiku",
     prompt="AI 기반 UI 패턴 조사 (개인화, 예측형 인터페이스)")

// Phase 2: 디자인 + 구현 병렬
Task(subagent_type="designer", model="opus",
     prompt="AI 기반 개인화 UI 디자인 (적응형 테마)")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="AI 모델 통합 및 개인화 로직")

// Phase 3: 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="AI 기반 UI 접근성 및 성능 검토")
```

</practical_examples>

---

<best_practices>

## 모범 사례

### 작업 시작 전 체크

- [ ] 글로벌 서비스인가? → Material 3/Apple HIG 참조
- [ ] 크로스 플랫폼? → 플랫폼별 병렬 구현
- [ ] 2026 트렌드 적용? → designer (opus) 사용
- [ ] 접근성 중요? → code-reviewer 검증 필수

### 디자인 시스템 참조

| 프로젝트 유형 | 참조 시스템 |
|--------------|------------|
| B2B/Enterprise | Carbon, Ant Design, Lightning |
| Consumer Apps | Material 3, Apple HIG |
| Creative Tools | Spectrum 2 |
| E-commerce | Polaris |

### 에이전트 활용 원칙

**DO:**
- 디자인 시스템 탐색 → explore (병렬)
- 플랫폼별 구현 → designer (병렬)
- 트렌드 통합 → designer (opus)
- WCAG/성능 → code-reviewer (병렬)

**DON'T:**
- 단일 에이전트로 모든 플랫폼 순차 구현
- 접근성 검증 생략
- 글로벌 표준 무시

### 2026 트렌드 활용

@designer 에이전트가 제공:
- AI 기반 개인화
- 공간 UI (AR/VR)
- 키네틱 타이포그래피
- 적응형 테마
- 마이크로 인터랙션

**참조:** `.claude/agents/designer.md`

</best_practices>
