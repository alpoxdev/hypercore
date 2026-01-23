# Figma → Code - Agent Coordination

Figma 디자인을 코드로 변환할 때 에이전트 활용 가이드.

---

<agents_reference>

전체 에이전트 조정 가이드: @../../PARALLEL_AGENTS.md

</agents_reference>

---

<recommended_agents>

## 추천 에이전트

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **designer** | sonnet/opus | Figma → React/Vue 코드 변환, UI 구현 |
| **implementation-executor** | sonnet | 로직 구현, API 연동, 상태 관리 |
| **explore** | haiku | Figma MCP 도구 확인, 프로젝트 구조 파악 |
| **code-reviewer** | opus | 픽셀 정확도 검증, 반응형 품질 검토 |

</recommended_agents>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1: 환경 탐색 → 디자인 추출 → 병렬 구현

**용도:** Figma 컴포넌트를 정확하게 코드로 변환

```typescript
// Phase 0: 환경 탐색
Task(
  subagent_type="explore",
  model="haiku",
  prompt="프로젝트 환경 파악: Vite/Next.js, globals.css 위치, 기존 @theme 토큰"
)

// Phase 1: Figma 데이터 추출 (designer가 Figma MCP 사용)
Task(
  subagent_type="designer",
  model="opus",
  prompt=`Figma MCP로 디자인 데이터 추출:
  - Variables (색상, 간격, 폰트)
  - Auto Layout 구조
  - 에셋 다운로드 링크
  - 반응형 브레이크포인트`
)

// Phase 2: 병렬 구현 (컴포넌트 + 스타일 + 에셋)
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="React 컴포넌트 구현: 정확한 px 값, Auto Layout → Flexbox"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="globals.css @theme 블록 업데이트: Figma Variables → Tailwind v4 토큰"
)

Task(
  subagent_type="implementation-executor",
  model="haiku",
  prompt="에셋 WebP 압축 및 public/ 구조화"
)
```

**효과:** 순차 실행 대비 3배 빠름

---

### 패턴 2: 반응형 병렬 구현

**용도:** Mobile/Tablet/Desktop 동시 작업

```typescript
// 각 브레이크포인트 병렬 구현
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="모바일 레이아웃 (320-767px): 세로 스택, 폰트 크기 조정"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="태블릿 레이아웃 (768-1023px): 2열 그리드"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="데스크톱 레이아웃 (1024px+): 3-4열 그리드"
)
```

---

### 패턴 3: 다중 컴포넌트 병렬 변환

**용도:** 여러 Figma 컴포넌트 동시 구현

```typescript
// Header, Footer, Sidebar 동시 변환
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="Header 컴포넌트 구현: Figma Auto Layout → Flexbox"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="Footer 컴포넌트 구현: 정확한 간격, 색상"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="Sidebar 컴포넌트 구현: 네비게이션 아이템"
)
```

---

### 패턴 4: 구현 → 검증

**용도:** 픽셀 정확도 보장

```typescript
// Step 1: 구현
Task(
  subagent_type="designer",
  model="sonnet",
  prompt="Figma 디자인 → React 컴포넌트 (정확한 px 값)"
)

// Step 2: 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt=`픽셀 정확도 검증:
  - 색상: Figma HEX vs 코드
  - 간격: margin/padding/gap 일치
  - 폰트: size/weight/line-height
  - 에셋: WebP 압축 확인
  - 반응형: 모든 브레이크포인트 Figma 일치`
)
```

</coordination_patterns>

---

<model_routing>

## 모델 라우팅

| 작업 | 모델 | 이유 |
|------|------|------|
| **환경 탐색** | haiku | 빠른 구조 파악 |
| **Figma 데이터 추출** | opus | 정확한 토큰/레이아웃 분석 |
| **컴포넌트 구현** | sonnet | UI 코드 변환 |
| **에셋 처리** | haiku | WebP 압축, 폴더 구조화 |
| **픽셀 정확도 검증** | opus | 세밀한 비교 |

</model_routing>

---

<practical_examples>

## 실전 예시

### 예시 1: 랜딩 페이지 구현

```typescript
// Phase 0: 환경 파악
Task(subagent_type="explore", model="haiku",
     prompt="Vite/Next.js 확인, globals.css 위치, 기존 @theme")

// Phase 1: Figma 추출
Task(subagent_type="designer", model="opus",
     prompt="Figma MCP: Variables, Auto Layout, 에셋, 브레이크포인트")

// Phase 2: 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt="Hero 섹션: 정확한 px 값, 반응형")
Task(subagent_type="designer", model="sonnet",
     prompt="Features 섹션: 3열 그리드")
Task(subagent_type="designer", model="sonnet",
     prompt="CTA 섹션: 버튼 스타일")
Task(subagent_type="implementation-executor", model="haiku",
     prompt="에셋 WebP 압축 및 public/images/ 구조화")

// Phase 3: 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="픽셀 정확도, 반응형 품질 검증")
```

---

### 예시 2: 디자인 시스템 구축

```typescript
// Phase 1: Figma Variables 추출
Task(subagent_type="designer", model="opus",
     prompt="Figma Variables → @theme 토큰 매핑")

// Phase 2: 병렬 컴포넌트 구현
Task(subagent_type="designer", model="sonnet",
     prompt="Button 컴포넌트: Primary/Secondary/Ghost")
Task(subagent_type="designer", model="sonnet",
     prompt="Card 컴포넌트: 정확한 border-radius, shadow")
Task(subagent_type="designer", model="sonnet",
     prompt="Input 컴포넌트: focus 상태, validation")

// Phase 3: 문서화
Task(subagent_type="document-writer", model="haiku",
     prompt="컴포넌트 문서 작성: 사용법, props")
```

---

### 예시 3: 반응형 대시보드

```typescript
// 각 브레이크포인트 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt="모바일 (320-767px): 1열 스택")
Task(subagent_type="designer", model="sonnet",
     prompt="태블릿 (768-1023px): 2열 그리드")
Task(subagent_type="designer", model="sonnet",
     prompt="데스크톱 (1024px+): 사이드바 + 3열 그리드")
```

</practical_examples>

---

<best_practices>

## 모범 사례

### 작업 시작 전 체크

- [ ] Figma MCP 연결 확인? → explore agent
- [ ] 여러 컴포넌트 구현? → 병렬 designer
- [ ] 반응형 필수? → 브레이크포인트별 병렬
- [ ] 픽셀 정확도 중요? → code-reviewer 검증

### Critical Rules

**DO:**
- 환경 탐색 우선 (Vite/Next.js, globals.css)
- Figma MCP로 정확한 값 추출
- @theme 블록에 토큰 병합 (기존 유지)
- 반응형 모든 브레이크포인트 구현
- 에셋 WebP 압축 (PNG/JPG 금지)
- 픽셀 정확도 검증 필수

**DON'T:**
- 근사치 사용 (`gap-4` 대신 `gap-[18px]`)
- AI 생성 에셋 (Figma 실제 파일만)
- 반응형 생략
- tailwind.config.js 사용 (v4는 @theme)
- 기존 토큰 덮어쓰기

### 병렬 실행 전략

| 단계 | 병렬 작업 |
|------|----------|
| Phase 0 | 환경 탐색 (단일) |
| Phase 1 | Figma 추출 (단일) |
| Phase 2 | 컴포넌트 + 스타일 + 에셋 (병렬) |
| Phase 3 | 검증 (단일/병렬) |

</best_practices>
