---
name: global-uiux-design
description: Implement modern, accessible UI/UX design for global audiences. Apply industry-standard patterns from Material Design, Apple HIG, Fluent, and other leading design systems.
user-invocable: true
ui-only: true
---

@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Global UI/UX Design

<context>

**Purpose:** Implement modern, accessible UI/UX design for global audiences. Apply industry-standard patterns from Material Design, Apple HIG, Fluent, and other leading design systems.

**Trigger:** Frontend UI/UX implementation, React/Vue component design, responsive web/app development, international product design

**Key Features:**
- WCAG 2.2 AA accessibility compliance
- Cross-platform consistency
- Mobile-first responsive design
- Industry-standard design patterns

</context>

---

<parallel_agent_execution>

## 병렬 에이전트 실행 (Global UX 특화)

### 핵심 원칙

**Goal:** 독립적인 Global UX 작업을 동시에 처리하여 대기 시간 최소화, 다국어/반응형/접근성 병렬 구현.

**Performance:** 순차 실행 → 병렬 실행으로 5-15배 성능 향상.

| 원칙 | 실행 방법 | Global UX 적용 |
|------|----------|----------------|
| **PARALLEL** | 단일 메시지에서 여러 Tool 동시 호출 | 다국어 레이아웃 동시 구현 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | designer (UI), code-reviewer (접근성) |
| **SMART MODEL** | 복잡도별 모델 선택 | haiku (탐색), sonnet (구현), opus (디자인) |

**핵심 룰:**
```typescript
// ❌ 순차 실행 (느림)
Task(...) // 모바일 레이아웃 60초
Task(...) // 데스크톱 레이아웃 60초
Task(...) // 태블릿 레이아웃 60초
// 총 180초

// ✅ 병렬 실행 (빠름)
Task(...) // 모바일
Task(...) // 데스크톱  → 단일 메시지에서 동시 호출
Task(...) // 태블릿
// 총 60초 (가장 긴 작업 기준)
```

---

### Model Routing (Global UX 특화)

| 작업 유형 | 모델 | 에이전트 | 예시 |
|----------|------|---------|------|
| **디자인 시스템 탐색** | haiku | explore | Material 3/Apple HIG 패턴 분석 |
| **UI 구현** | sonnet | designer | 컴포넌트, 레이아웃, 반응형 |
| **복잡한 디자인** | opus | designer | 공간 UI, 크로스 플랫폼 일관성 |
| **접근성 검증** | opus | code-reviewer | WCAG 2.2, ARIA, 키보드 네비게이션 |
| **성능 검토** | opus | code-reviewer | 60fps 애니메이션, 번들 최적화 |
| **문서 작성** | haiku | document-writer | 디자인 가이드, 컴포넌트 문서 |

**모델 선택 기준:**
```typescript
// 간단한 탐색 → haiku
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 기존 다국어 지원 구조 분석")

// 일반 구현 → sonnet
Task(subagent_type="designer", model="sonnet",
     prompt="모바일 레이아웃 구현 (Material 3)")

// 복잡한 디자인 → opus
Task(subagent_type="designer", model="opus",
     prompt="4개 언어 동시 지원하는 통합 디자인 시스템 설계")
```

---

### 패턴 1: 다국어 디자인 병렬 처리

**목표:** EN/ES/ZH/AR 레이아웃을 동시에 구현하여 시간 단축, RTL/LTR 일관성 확보.

```typescript
// ✅ 4개 언어 레이아웃 동시 구현
Task(subagent_type="designer", model="sonnet",
     prompt=`영어(EN) 레이아웃 구현
     - LTR 기본
     - 짧은 단어 (compact)
     - Material 3 스타일
     - components/en/Header.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`스페인어(ES) 레이아웃 구현
     - LTR, 영어보다 20% 긴 텍스트
     - 동적 너비 조정
     - components/es/Header.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`중국어(ZH) 레이아웃 구현
     - 세로쓰기 옵션
     - CJK 폰트 (Noto Sans CJK)
     - 컴팩트 레이아웃
     - components/zh/Header.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`아랍어(AR) 레이아웃 구현
     - RTL (direction: rtl)
     - 미러링 (아이콘, 레이아웃)
     - 아랍어 폰트 (Noto Sans Arabic)
     - components/ar/Header.tsx`)

// 병렬 폰트 시스템
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`다국어 폰트 로딩 시스템 구현
     - Next.js Font Optimization
     - 언어별 폰트 스택
     - 폴백 처리`)
```

**예상 시간:**
- 순차 실행: 240초 (60초 × 4)
- 병렬 실행: 60초 (가장 긴 작업)
- 개선: 4배 향상

**RTL 처리 체크리스트:**
- [ ] `direction: rtl` CSS 적용
- [ ] 아이콘 미러링 (화살표, 햄버거 메뉴)
- [ ] Flexbox/Grid 자동 반전 (justify-content)
- [ ] margin/padding 논리 속성 (margin-inline-start)

---

### 패턴 2: 반응형 Breakpoint 병렬 구현

**목표:** Mobile/Tablet/Desktop/4K 레이아웃을 동시에 구현.

```typescript
// ✅ 4개 Breakpoint 동시 구현
Task(subagent_type="designer", model="sonnet",
     prompt=`Mobile 레이아웃 (< 640px)
     - 단일 컬럼
     - 하단 탭 바
     - Safe Area 고려
     - 44px 터치 타겟
     - components/mobile/Dashboard.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`Tablet 레이아웃 (640-1024px)
     - 2컬럼 그리드
     - 사이드바 토글
     - 제스처 지원 (스와이프)
     - components/tablet/Dashboard.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`Desktop 레이아웃 (1024-1920px)
     - 3컬럼 그리드
     - 고정 사이드바
     - 호버 인터랙션
     - components/desktop/Dashboard.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`4K/Ultra-Wide 레이아웃 (> 1920px)
     - 4컬럼 그리드
     - max-w-screen-2xl 컨테이너
     - 여백 최적화
     - 고해상도 이미지
     - components/4k/Dashboard.tsx`)
```

**통합 전략:**
```typescript
// 단일 컴포넌트로 통합
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`반응형 Dashboard 컴포넌트 통합
     - Breakpoint별 동적 import
     - Tailwind responsive classes
     - 성능 최적화 (code splitting)`)
```

---

### 패턴 3: A/B 테스트 변형 병렬 생성

**목표:** 디자인 변형을 동시에 구현하여 실험 속도 향상.

```typescript
// ✅ A/B 테스트 3개 변형 동시 구현
Task(subagent_type="designer", model="sonnet",
     prompt=`Variant A: 미니멀 디자인
     - 단색 배경
     - 작은 버튼 (h-10)
     - 텍스트 중심
     - components/ab-test/VariantA.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`Variant B: 대담한 디자인
     - 그라디언트 배경
     - 큰 버튼 (h-14)
     - 애니메이션 강조
     - components/ab-test/VariantB.tsx`)

Task(subagent_type="designer", model="sonnet",
     prompt=`Variant C: 하이브리드
     - A와 B의 중간
     - 조건부 애니메이션
     - 어댑티브 크기
     - components/ab-test/VariantC.tsx`)

// 병렬 성능 테스트
Task(subagent_type="code-reviewer", model="opus",
     prompt=`3개 변형 성능 비교
     - 번들 크기
     - First Contentful Paint
     - Interaction to Next Paint
     - 최적 변형 추천`)
```

**A/B 테스트 인프라:**
```typescript
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`A/B 테스트 라우팅 시스템
     - 사용자 그룹 분배 (33/33/33)
     - 쿠키 기반 고정
     - 분석 이벤트 전송`)
```

---

### 패턴 4: 접근성 검증 병렬

**목표:** WCAG/ARIA/키보드 네비게이션을 동시에 검증하여 접근성 품질 보장.

```typescript
// ✅ 3가지 접근성 검증 동시 실행
Task(subagent_type="code-reviewer", model="opus",
     prompt=`WCAG 2.2 AA 준수 검증
     - 색상 대비 (4.5:1 일반, 3:1 큰 텍스트)
     - 포커스 표시 (2px 아웃라인)
     - 텍스트 크기 조정 (200%)
     - 모든 interactive 요소 검토`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`ARIA 속성 검증
     - role, aria-label, aria-labelledby
     - aria-expanded, aria-controls (동적 UI)
     - aria-live (실시간 업데이트)
     - landmark 역할 (navigation, main, aside)`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`키보드 네비게이션 검증
     - Tab 순서 (tabindex)
     - Enter/Space (버튼 활성화)
     - Esc (모달 닫기)
     - 화살표 키 (드롭다운, 슬라이더)
     - 포커스 트랩 (모달 내부)`)

// 스크린 리더 테스트
Task(subagent_type="code-reviewer", model="opus",
     prompt=`스크린 리더 호환성
     - VoiceOver (Safari)
     - NVDA (Firefox)
     - JAWS (Chrome)
     - 의미적 HTML 구조 검증`)
```

**자동 수정 패턴:**
```typescript
// 검증 후 자동 수정
Task(subagent_type="lint-fixer", model="sonnet",
     prompt=`접근성 이슈 자동 수정
     - 대비 부족 색상 조정
     - 누락된 alt 추가
     - aria-label 보완
     - tabindex 최적화`)
```

---

### 패턴 5: 디자인 시스템 컴포넌트 병렬 구현

**목표:** 여러 컴포넌트를 동시에 구현하여 디자인 시스템 구축 가속화.

```typescript
// ✅ 10개 컴포넌트 동시 구현
Task(subagent_type="designer", model="sonnet",
     prompt="Button 컴포넌트 (Primary, Secondary, Ghost)")

Task(subagent_type="designer", model="sonnet",
     prompt="Input 컴포넌트 (Text, Email, Password, Search)")

Task(subagent_type="designer", model="sonnet",
     prompt="Card 컴포넌트 (Default, Interactive, Elevated)")

Task(subagent_type="designer", model="sonnet",
     prompt="Modal 컴포넌트 (Dialog, Drawer, Bottom Sheet)")

Task(subagent_type="designer", model="sonnet",
     prompt="Toast/Notification 컴포넌트")

Task(subagent_type="designer", model="sonnet",
     prompt="Dropdown/Select 컴포넌트")

Task(subagent_type="designer", model="sonnet",
     prompt="Tabs 컴포넌트 (Underline, Segment Control)")

Task(subagent_type="designer", model="sonnet",
     prompt="Avatar 컴포넌트 (User, Group, Fallback)")

Task(subagent_type="designer", model="sonnet",
     prompt="Badge/Chip 컴포넌트 (Status, Label, Removable)")

Task(subagent_type="designer", model="sonnet",
     prompt="Skeleton Loader 컴포넌트")

// 병렬 문서 작성
Task(subagent_type="document-writer", model="haiku",
     prompt=`Storybook 문서 생성
     - 10개 컴포넌트 스토리
     - Props 테이블
     - 사용 예시`)
```

**예상 시간:**
- 순차 실행: 600초 (60초 × 10)
- 병렬 실행: 60초
- 개선: 10배 향상

---

### 실전 시나리오

#### 시나리오 1: 글로벌 이커머스 플랫폼

**요구사항:** 10개 언어, 5개 통화, 3개 플랫폼 (Web/iOS/Android)

```typescript
// Phase 1: 병렬 탐색
Task(subagent_type="explore", model="haiku",
     prompt="Shopify Polaris 디자인 패턴 분석")
Task(subagent_type="explore", model="haiku",
     prompt="Amazon/Alibaba 다국어 UI 구조 분석")
Task(subagent_type="explore", model="haiku",
     prompt="결제 UI 접근성 모범 사례 (Stripe, PayPal)")

// Phase 2: 다국어 레이아웃 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt="영어/독일어/프랑스어 상품 페이지 (LTR)")
Task(subagent_type="designer", model="sonnet",
     prompt="아랍어/히브리어 상품 페이지 (RTL)")
Task(subagent_type="designer", model="sonnet",
     prompt="중국어/일본어/한국어 상품 페이지 (CJK)")
Task(subagent_type="designer", model="sonnet",
     prompt="통화별 가격 포매팅 컴포넌트 ($, €, ¥, ₩)")

// Phase 3: 반응형 병렬
Task(subagent_type="designer", model="sonnet",
     prompt="모바일 체크아웃 (1-step)")
Task(subagent_type="designer", model="sonnet",
     prompt="데스크톱 체크아웃 (Multi-step)")

// Phase 4: 접근성 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="결제 폼 접근성 (WCAG 2.2 AA, 스크린 리더)")
```

**예상 시간:**
- 순차: 540초 (60초 × 9)
- 병렬: 60초
- 개선: 9배 향상

---

#### 시나리오 2: 다국어 SaaS 대시보드

**요구사항:** 4개 언어, 실시간 데이터, 어댑티브 차트

```typescript
// Phase 1: 디자인 시스템
Task(subagent_type="designer", model="opus",
     prompt="SaaS 디자인 토큰 시스템 (Carbon Design 기반)")

// Phase 2: 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt="대시보드 레이아웃 (4개 언어 동시 지원)")
Task(subagent_type="designer", model="sonnet",
     prompt="데이터 테이블 (정렬, 필터, 페이지네이션)")
Task(subagent_type="designer", model="sonnet",
     prompt="차트 컴포넌트 (Recharts, 반응형)")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="실시간 WebSocket 연동")

// Phase 3: 접근성
Task(subagent_type="code-reviewer", model="opus",
     prompt="차트 접근성 (aria-label, 데이터 테이블 대체)")
Task(subagent_type="code-reviewer", model="opus",
     prompt="키보드 네비게이션 (테이블, 필터)")
```

---

#### 시나리오 3: 모바일 우선 소셜 앱

**요구사항:** iOS/Android 네이티브 느낌, 60fps 애니메이션

```typescript
// Phase 1: 플랫폼별 탐색
Task(subagent_type="explore", model="haiku",
     prompt="iOS Human Interface Guidelines 최신 패턴")
Task(subagent_type="explore", model="haiku",
     prompt="Material 3 모바일 컴포넌트")

// Phase 2: 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt="iOS 스타일 피드 (SF Symbols, 네이티브 제스처)")
Task(subagent_type="designer", model="sonnet",
     prompt="Android 스타일 피드 (Material 3, FAB)")
Task(subagent_type="designer", model="sonnet",
     prompt="공통 스토리 컴포넌트 (Instagram 스타일)")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="60fps 애니메이션 (Framer Motion)")

// Phase 3: 성능 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 검토 (FPS, 메모리, 배터리)")
```

---

#### 시나리오 4: 엔터프라이즈 디자인 시스템 구축

**요구사항:** 100+ 컴포넌트, Figma 동기화, 접근성 AAA

```typescript
// Phase 1: 탐색
Task(subagent_type="explore", model="haiku",
     prompt="IBM Carbon, Salesforce Lightning 분석")
Task(subagent_type="explore", model="haiku",
     prompt="Figma Design Tokens 플러그인 조사")

// Phase 2: 토큰 시스템
Task(subagent_type="designer", model="opus",
     prompt="디자인 토큰 시스템 (색상, 타이포, 간격, 그림자)")

// Phase 3: 컴포넌트 병렬 구현 (20개씩 배치)
// Batch 1
Task(subagent_type="designer", model="sonnet",
     prompt="Form 컴포넌트 (Input, Select, Checkbox, Radio, Switch)")
// Batch 2
Task(subagent_type="designer", model="sonnet",
     prompt="Navigation 컴포넌트 (Navbar, Sidebar, Tabs, Breadcrumb)")
// Batch 3
Task(subagent_type="designer", model="sonnet",
     prompt="Feedback 컴포넌트 (Toast, Modal, Alert, Progress)")
// Batch 4
Task(subagent_type="designer", model="sonnet",
     prompt="Data Display 컴포넌트 (Table, Card, List, Badge)")

// Phase 4: 접근성 AAA
Task(subagent_type="code-reviewer", model="opus",
     prompt="WCAG 2.2 AAA 검증 (7:1 대비, 모든 인터랙션)")

// Phase 5: 문서
Task(subagent_type="document-writer", model="sonnet",
     prompt="Storybook + 디자인 가이드라인 생성")
```

**예상 시간:**
- 순차: 1200초 (20분)
- 병렬: 240초 (4분)
- 개선: 5배 향상

---

### 체크리스트

#### 병렬 실행 전 확인

- [ ] 독립적인 작업인가? (의존성 없음)
- [ ] 같은 파일을 동시 수정하지 않는가?
- [ ] 컨텍스트 분리 가능한가?

#### Global UX 특화 확인

- [ ] 다국어 작업 → 언어별 병렬 실행
- [ ] 반응형 작업 → Breakpoint별 병렬 실행
- [ ] A/B 테스트 → 변형별 병렬 실행
- [ ] 접근성 검증 → WCAG/ARIA/키보드 병렬
- [ ] 디자인 시스템 → 컴포넌트별 병렬 실행

#### 모델 선택 확인

- [ ] 탐색 작업 → haiku
- [ ] 일반 구현 → sonnet
- [ ] 복잡한 디자인 → opus
- [ ] 접근성 검증 → opus
- [ ] 문서 작성 → haiku

#### 성능 최적화

- [ ] 3-10개 작업 동시 실행
- [ ] 병렬 실행 시간 예상 (순차 대비 5-15배 향상)
- [ ] 컨텍스트 크기 모니터링
- [ ] 실패 시 재시도 전략 (3회 제한)

#### 완료 후 검증

- [ ] 모든 언어 레이아웃 정상 작동
- [ ] 모든 Breakpoint 반응형 동작
- [ ] 접근성 WCAG 2.2 AA 통과
- [ ] 성능 목표 달성 (60fps, LCP < 2.5s)

**적극적으로 병렬 실행 활용. 순차 실행은 의존성이 명확할 때만.**

</parallel_agent_execution>

---

<core_principles>

## Design Philosophy

| Principle | Application |
|-----------|-------------|
| **Clarity** | Interface should not compete with content. Use subtle hierarchy and whitespace. |
| **Consistency** | Follow platform conventions. iOS apps feel like iOS, web apps follow web standards. |
| **Accessibility** | Design for everyone. WCAG 2.2 AA minimum, aim for AAA where possible. |
| **Performance** | Fast, responsive interactions. 60fps animations, instant feedback. |

**Details:** [references/design-philosophy.md](references/design-philosophy.md)

</core_principles>

---

<layout_patterns>

## Layout

### Container Widths

```tsx
{/* Dashboard - 1280px */}
<div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">

{/* Content - 768px */}
<div className="max-w-3xl mx-auto px-4 sm:px-6">

{/* Forms - 560px */}
<div className="max-w-xl mx-auto px-4">
```

### Spacing Scale

```tsx
{/* 8px base grid */}
<div className="space-y-8">  {/* 32px */}
  <section className="space-y-4">  {/* 16px */}
    <div className="p-6">  {/* 24px */}
```

**Mobile tap targets:** Minimum 44x44px (iOS) or 48x48px (Material)

</layout_patterns>

---

<component_patterns>

## Components

### Buttons

```tsx
{/* Primary - Material 3 style */}
<button className="h-10 px-6 rounded-full bg-primary-600 hover:bg-primary-700 text-white font-medium shadow-sm transition-all">
  Save changes
</button>

{/* Secondary - iOS style */}
<button className="h-10 px-6 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-900 font-semibold transition-colors">
  Cancel
</button>

{/* Ghost */}
<button className="h-10 px-4 rounded-lg hover:bg-gray-100 font-medium transition-colors">
  Learn more
</button>
```

**Sizes:** Small h-8 px-3 | Medium h-10 px-6 | Large h-12 px-8

### Cards

```tsx
<div className="p-6 rounded-2xl border border-gray-200 bg-white shadow-sm hover:shadow-md transition-shadow">
  {/* Header */}
  <div className="flex items-center justify-between mb-4">
    <h3 className="text-lg font-semibold">Card Title</h3>
    <button className="p-2 rounded-lg hover:bg-gray-100">
      <svg className="w-5 h-5 text-gray-500" />
    </button>
  </div>

  {/* Body */}
  <div className="space-y-3">
    <p className="text-sm text-gray-600 leading-relaxed">Content goes here</p>
  </div>

  {/* Footer */}
  <div className="flex items-center justify-between mt-4 pt-4 border-t">
    <span className="text-sm text-gray-500">2 hours ago</span>
    <button className="text-sm text-primary-600 font-medium">Details</button>
  </div>
</div>
```

### List Items

```tsx
<div className="flex items-center gap-4 p-4 hover:bg-gray-50 rounded-lg transition-colors cursor-pointer">
  {/* Avatar/Icon */}
  <div className="w-12 h-12 rounded-full bg-primary-100 flex items-center justify-center flex-shrink-0">
    <svg className="w-6 h-6 text-primary-600" />
  </div>

  {/* Content */}
  <div className="flex-1 min-w-0">
    <div className="font-semibold text-sm truncate">Item Title</div>
    <div className="text-sm text-gray-600 truncate">Description text</div>
  </div>

  {/* Meta */}
  <div className="flex items-center gap-2 flex-shrink-0">
    <span className="text-sm font-medium text-gray-900">$99</span>
    <svg className="w-5 h-5 text-gray-400" />
  </div>
</div>
```

### Input Fields

```tsx
<div className="space-y-2">
  <label className="block text-sm font-medium text-gray-900">
    Email address <span className="text-red-500">*</span>
  </label>
  <input
    type="email"
    className="w-full h-11 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-shadow"
    placeholder="name@example.com"
  />
  <p className="text-sm text-gray-500">We'll never share your email.</p>
</div>
```

### Modals

```tsx
<div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50 backdrop-blur-sm">
  <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-auto shadow-xl">
    <div className="flex items-center justify-between p-6 border-b">
      <h2 className="text-xl font-semibold">Modal Title</h2>
      <button className="w-10 h-10 flex items-center justify-center rounded-lg hover:bg-gray-100 transition-colors">
        <svg className="w-5 h-5" />
      </button>
    </div>
    <div className="p-6">
      <p className="text-sm text-gray-700 leading-relaxed">Modal content</p>
    </div>
    <div className="flex gap-3 justify-end p-6 border-t">
      <button className="h-10 px-6 rounded-lg border border-gray-300 hover:bg-gray-50">
        Cancel
      </button>
      <button className="h-10 px-6 rounded-lg bg-primary-600 text-white hover:bg-primary-700">
        Confirm
      </button>
    </div>
  </div>
</div>
```

### Tabs

```tsx
{/* Underline style - iOS/Material */}
<div className="border-b border-gray-200">
  <div className="flex gap-8">
    <button className="py-3 text-sm font-medium text-primary-600 border-b-2 border-primary-600">
      All
    </button>
    <button className="py-3 text-sm font-medium text-gray-600 hover:text-gray-900">
      Active
    </button>
  </div>
</div>

{/* Segment control - iOS style */}
<div className="inline-flex p-1 bg-gray-100 rounded-lg gap-1">
  <button className="px-4 py-2 rounded-md bg-white shadow-sm text-sm font-medium">
    All
  </button>
  <button className="px-4 py-2 rounded-md text-sm font-medium text-gray-600">
    Active
  </button>
</div>
```

</component_patterns>

---

<color_system>

## Color System

| Color | Usage | Ratio |
|-------|-------|-------|
| **Primary** | CTA buttons, links, active states | 10% |
| **Neutral** | Text, borders, backgrounds | 60% |
| **Secondary** | Filters, chips, supporting actions | 30% |
| **Semantic** | Success/Error/Warning/Info | As needed |

```tsx
{/* 60-30-10 rule */}
<button className="bg-primary-600 hover:bg-primary-700 text-white">Primary action</button>
<button className="bg-secondary-100 text-secondary-900 hover:bg-secondary-200">Secondary</button>
```

**WCAG 2.2 AA:** Normal text 4.5:1 | Large text 3:1 | Interactive controls 3:1

**Details:** [references/color-system.md](references/color-system.md)

</color_system>

---

<icon_system>

## Icons

| Size | Usage | Touch Target |
|------|-------|--------------|
| 16px, 20px | Inline with text | - |
| 24px | Standard system icons | 44-48px |
| 32-48px | Feature icons | Use as-is |

```tsx
{/* Sufficient touch target */}
<button className="w-12 h-12 flex items-center justify-center rounded-lg hover:bg-gray-100">
  <svg className="w-6 h-6" />
</button>

{/* States: Outline (inactive) | Filled (active) */}
<svg className="w-6 h-6 stroke-current text-gray-600" fill="none" strokeWidth={2} />
<svg className="w-6 h-6 fill-current text-primary-600" />
```

**Icon libraries:** Heroicons, Lucide, Material Symbols, SF Symbols

**Details:** [references/icon-guide.md](references/icon-guide.md)

</icon_system>

---

<typography>

## Typography

```tsx
{/* Display - Landing pages */}
<h1 className="text-5xl sm:text-6xl font-bold tracking-tight leading-tight">
  Welcome to our platform
</h1>

{/* Page title */}
<h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>

{/* Section title */}
<h2 className="text-xl font-semibold tracking-tight">Recent Activity</h2>

{/* Body text */}
<p className="text-base leading-relaxed text-gray-700">
  Body content with comfortable reading line-height
</p>

{/* Caption */}
<span className="text-sm text-gray-500">2 hours ago</span>
```

**Font stack:**
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
```

**Details:** [references/typography.md](references/typography.md)

</typography>

---

<responsive_patterns>

## Responsive Design

### Grid Layouts

```tsx
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

### Navigation

```tsx
{/* Desktop: Sidebar */}
<aside className="hidden lg:block w-64 border-r" />

{/* Mobile: Bottom tab bar */}
<nav className="lg:hidden fixed bottom-0 inset-x-0 h-16 border-t bg-white safe-area-inset-bottom" />
```

### Breakpoints (Tailwind defaults)

| Breakpoint | Width |
|------------|-------|
| sm | 640px |
| md | 768px |
| lg | 1024px |
| xl | 1280px |
| 2xl | 1536px |

**Details:** [references/responsive-patterns.md](references/responsive-patterns.md)

</responsive_patterns>

---

<design_systems>

## Leading Design Systems

| System | Organization | Characteristics |
|--------|--------------|-----------------|
| **[Material Design 3](https://m3.material.io/)** | Google | Dynamic color, expressive motion, adaptive components |
| **[Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)** | Apple | Clarity, deference, depth. Liquid Glass aesthetic (2026) |
| **[Fluent 2](https://fluent2.microsoft.design/)** | Microsoft | Token-based, cross-platform, Figma-native |
| **[Carbon](https://carbondesignsystem.com/)** | IBM | Enterprise-grade, accessibility-first, open source |
| **[Ant Design](https://ant.design/)** | Ant Group | Enterprise UI, comprehensive components, i18n |
| **[Polaris](https://polaris.shopify.com/)** | Shopify | E-commerce optimized, web components (2026) |
| **[Lightning](https://www.lightningdesignsystem.com/)** | Salesforce | SLDS 2 with agentic design patterns |
| **[Spectrum 2](https://spectrum.adobe.com/)** | Adobe | Creative tools focus, cross-app consistency |
| **[Atlassian DS](https://atlassian.design/)** | Atlassian | Collaboration tools, strict 4px grid |
| **[Chakra UI](https://chakra-ui.com/)** | Community | Accessible, modular, style props |

**When to reference:**
- B2B/Enterprise → Carbon, Ant Design, Lightning
- Consumer apps → Material 3, Apple HIG
- Creative tools → Spectrum 2
- E-commerce → Polaris
- Developer tools → Atlassian

**Details:** [references/design-systems.md](references/design-systems.md)

</design_systems>

---

<accessibility_and_states>

## Accessibility & States

### WCAG 2.2 AA Requirements

- **Contrast:** 4.5:1 normal text, 3:1 large text (18pt+)
- **Keyboard:** All interactive elements accessible via keyboard
- **Screen readers:** Semantic HTML, ARIA labels where needed
- **Focus visible:** Clear focus indicators (2px outline minimum)
- **No color alone:** Never convey information with color only

### State Patterns

```tsx
{/* Loading skeleton */}
<div className="animate-pulse space-y-3">
  <div className="h-4 bg-gray-200 rounded w-3/4" />
  <div className="h-4 bg-gray-200 rounded w-1/2" />
</div>

{/* Error state */}
<div className="flex items-center gap-2 text-red-600 text-sm">
  <svg className="w-5 h-5" />
  <span>An error occurred. Please try again.</span>
</div>

{/* Empty state */}
<div className="py-16 text-center">
  <div className="w-20 h-20 mx-auto mb-4 rounded-full bg-gray-100 flex items-center justify-center">
    <svg className="w-10 h-10 text-gray-400" />
  </div>
  <h3 className="text-lg font-semibold mb-2">No items yet</h3>
  <p className="text-sm text-gray-600 mb-4">Get started by creating your first item</p>
  <button className="h-10 px-6 rounded-lg bg-primary-600 text-white">
    Create item
  </button>
</div>

{/* Success toast */}
<div className="flex items-center gap-3 px-4 py-3 rounded-lg bg-green-50 border border-green-200">
  <svg className="w-5 h-5 text-green-600" />
  <span className="text-sm font-medium text-green-900">Changes saved successfully</span>
</div>
```

**Details:**
- [references/accessibility.md](references/accessibility.md)
- [references/micro-interactions.md](references/micro-interactions.md)
- [references/state-patterns.md](references/state-patterns.md)

</accessibility_and_states>

---

<references>

## Detailed Documentation

| Document | Content |
|----------|---------|
| [design-philosophy.md](references/design-philosophy.md) | Core principles, anti-patterns |
| [color-system.md](references/color-system.md) | Palette generation, semantic colors, dark mode |
| [icon-guide.md](references/icon-guide.md) | Icon libraries, sizing, accessibility |
| [typography.md](references/typography.md) | Scale, font stacks, i18n considerations |
| [design-systems.md](references/design-systems.md) | Deep dive into Material, HIG, Fluent, etc. |
| [responsive-patterns.md](references/responsive-patterns.md) | Breakpoints, layouts, mobile-first |
| [accessibility.md](references/accessibility.md) | WCAG 2.2, ARIA, testing tools |
| [micro-interactions.md](references/micro-interactions.md) | Hover, focus, transitions, animations |
| [state-patterns.md](references/state-patterns.md) | Loading, error, empty, success states |
| [checklist.md](references/checklist.md) | Pre-deployment UI/UX audit |

### External Resources

| Resource | URL | Focus |
|----------|-----|-------|
| Material Design 3 | https://m3.material.io/ | Google's design system |
| Apple HIG | https://developer.apple.com/design/human-interface-guidelines/ | iOS/macOS guidelines |
| Fluent 2 | https://fluent2.microsoft.design/ | Microsoft design system |
| IBM Carbon | https://carbondesignsystem.com/ | Enterprise design system |
| Nielsen Norman Group | https://www.nngroup.com/ | UX research & guidelines |
| WCAG 2.2 | https://www.w3.org/WAI/standards-guidelines/wcag/ | Accessibility standard |
| Laws of UX | https://lawsofux.com/ | Psychology-based design principles |
| Ant Design | https://ant.design/ | Enterprise component library |
| Atlassian DS | https://atlassian.design/ | Collaboration tool patterns |
| Shopify Polaris | https://polaris.shopify.com/ | E-commerce design system |
| Salesforce Lightning | https://www.lightningdesignsystem.com/ | SLDS 2 (agentic design) |
| Adobe Spectrum | https://spectrum.adobe.com/ | Creative tool design |
| Chakra UI | https://chakra-ui.com/ | Accessible component library |
| Smashing Magazine | https://www.smashingmagazine.com/ | UX best practices |

</references>

---

<prompt_examples>

## Prompt Examples

### Dashboard

```
Create a dashboard page.

Layout:
- Desktop: Left sidebar (256px) + main content (max-w-7xl)
- Mobile: Bottom tab bar
- Responsive padding (px-4 sm:px-6 lg:px-8)

Components:
- Header with greeting + date
- 4 stat cards (grid-cols-1 sm:grid-cols-2 lg:grid-cols-4)
- Recent activity list
- Quick action buttons

Style:
- Material Design 3 aesthetic
- Cards: rounded-2xl, subtle shadow
- Primary color: blue-600
- Numbers: font-bold text-3xl
```

### Settings Screen

```
Create a settings page.

Layout:
- max-w-2xl mx-auto
- Sections with space-y-8

Components:
- Profile: Avatar + name + email
- Notifications: Toggle switches (h-11 touch target)
- Account: Password change, sign out
- Danger zone: Delete account (red)

Style:
- Each row: flex justify-between items-center
- Label: text-sm font-medium
- Section headers: text-xs text-gray-500 uppercase tracking-wide
```

### Data Table

```
Create a users table.

Layout:
- Desktop: Traditional table
- Mobile: Card list

Components:
- Header: Search bar + filters + add button
- Columns: Avatar, name, email, joined date, status
- Pagination

Style:
- Table header: bg-gray-50
- Row hover: hover:bg-gray-50
- No vertical borders
- Actions: Three-dot menu
- Sticky header on scroll
```

### Form

```
Create a multi-step form.

Layout:
- max-w-xl mx-auto
- Progress indicator at top
- Step transitions with slide animation

Components:
- Step 1: Personal info (name, email, phone)
- Step 2: Address
- Step 3: Review + submit

Style:
- Labels: text-sm font-medium mb-2
- Inputs: h-11 rounded-lg border focus:ring-2
- Validation: Inline errors below fields
- Buttons: Back (secondary) + Continue (primary)
```

</prompt_examples>
