---
name: design
description: UI/UX 디자인 전문 스킬. 사용자 중심 디자인, 접근성, 반응형 레이아웃, 디자인 시스템 구축. Nielsen 휴리스틱 및 WCAG 2.2 기반.
user-invocable: true
ui-only: true
---

@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Design Skill - UI/UX 전문 스킬

<context>

**Purpose:** 사용자 중심의 UI/UX 디자인 구현. 접근성, 반응형 디자인, 디자인 시스템 구축.

**Trigger:** UI/UX 디자인 구현, 랜딩 페이지 제작, 대시보드 개발, 모바일 앱 디자인, 폼 디자인

**Key Features:**
- Nielsen 10가지 휴리스틱 기반 UX
- WCAG 2.2 AA 접근성 준수
- 반응형 디자인 (Mobile-First)
- 디자인 심리학 적용 (인지부하 최소화, Fitts/Hick/Miller 법칙)
- 2024-2026 트렌드 반영 (AI 통합, 마이크로인터랙션, 다크모드)

</context>

---

<quick_reference>

## 빠른 참조

### Core UX 원칙 (Nielsen)

| 원칙 | 적용 |
|------|------|
| **시스템 상태 가시성** | Loading, Progress, 피드백 |
| **일관성** | 패턴 재사용, 플랫폼 규칙 준수 |
| **오류 예방** | 확인 다이얼로그, 입력 제약 |
| **인지부하 최소화** | 7±2 항목, 단순 메뉴 |

### 접근성 (WCAG 2.2 AA)

| 요구사항 | 기준 |
|---------|------|
| **색상 대비** | 4.5:1 (일반), 3:1 (큰 텍스트) |
| **터치 타겟** | 44x44px 최소 |
| **키보드** | Tab, Enter, Esc 지원 |
| **ARIA** | role, label, live 속성 |

### 레이아웃 패턴

| 패턴 | 용도 |
|------|------|
| **F-패턴** | 콘텐츠 중심 (블로그, 기사) |
| **Z-패턴** | 랜딩 페이지 (히어로 → CTA) |
| **12열 그리드** | 반응형 레이아웃 |

</quick_reference>

---

<parallel_agent_execution>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "design-team", description: "UI/UX 디자인 프로젝트" })
Task(subagent_type="designer", team_name="design-team", name="designer", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

## 병렬 에이전트 실행

### 핵심 원칙

| 원칙 | 실행 방법 | 디자인 적용 |
|------|----------|------------|
| **PARALLEL** | 단일 메시지에서 여러 Tool 동시 호출 | 여러 페이지 동시 디자인 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | designer (UI), code-reviewer (접근성) |
| **SMART MODEL** | 복잡도별 모델 선택 | haiku (탐색), sonnet (구현), opus (디자인 시스템) |

### 패턴 1: 랜딩 페이지 섹션 병렬 디자인

```typescript
// ✅ 5개 섹션 동시 구현
Task(subagent_type="designer", model="sonnet",
     prompt="히어로 섹션: 헤드라인 + CTA + 이미지")
Task(subagent_type="designer", model="sonnet",
     prompt="소셜 프루프 섹션: 로고, 추천사, 통계")
Task(subagent_type="designer", model="sonnet",
     prompt="기능 섹션: 3열 그리드, 아이콘, 설명")
Task(subagent_type="designer", model="sonnet",
     prompt="가격 테이블: 3개 티어, 비교 기능")
Task(subagent_type="designer", model="sonnet",
     prompt="CTA 섹션: 최종 전환 유도")
```

**예상 시간:** 순차 300초 → 병렬 60초 (5배 향상)

### 패턴 2: 반응형 Breakpoint 병렬

```typescript
// ✅ Mobile/Tablet/Desktop 동시 구현
Task(subagent_type="designer", model="sonnet",
     prompt="Mobile (320-767px): 세로 스택, 44px 터치 타겟")
Task(subagent_type="designer", model="sonnet",
     prompt="Tablet (768-1023px): 2열 그리드")
Task(subagent_type="designer", model="sonnet",
     prompt="Desktop (1024px+): 3열 그리드, 호버 효과")
```

### 패턴 3: 접근성 검증 병렬

```typescript
// ✅ WCAG/ARIA/키보드 동시 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="WCAG 2.2 AA: 색상 대비, 포커스, 텍스트 크기")
Task(subagent_type="code-reviewer", model="opus",
     prompt="ARIA 속성: role, label, live")
Task(subagent_type="code-reviewer", model="opus",
     prompt="키보드 네비게이션: Tab, Enter, Esc")
```

</parallel_agent_execution>

---

<detailed_references>

## 상세 참고 문서

각 주제별 상세 가이드는 references 폴더를 참조하세요.

| 파일 | 내용 |
|------|------|
| **core-principles.md** | Nielsen 휴리스틱, Don Norman 원칙, Gestalt 원칙, 디자인 심리학 |
| **accessibility.md** | POUR 원칙, 색상 대비, 키보드, ARIA, 스크린 리더 |
| **patterns.md** | 랜딩 페이지, 대시보드, 폼, 모바일 앱 패턴 |
| **systems.md** | 타이포그래피, 컬러, 그리드, 반응형 디자인 |
| **responsive.md** | Container Queries, Fluid CSS, Modern CSS, 반응형 이미지 |
| **korea-uiux.md** | 한국형 UI/UX: 토스/카카오/배민/당근 디자인 시스템, 타이포(Pretendard), 결제 UX |
| **global-uiux.md** | 글로벌 UI/UX: Material 3, Apple HIG (Liquid Glass), Fluent 2, Carbon, SLDS |
| **safe-area.md** | Safe Area: iOS/Android Insets, Dynamic Island, Foldable, React Native, CSS env() |
| **checklist.md** | DO/DON'T 항목 |
| **trends.md** | 2024-2026 디자인 트렌드 |

**사용 방법:**
```bash
# 디자인 원칙 확인
Read references/core-principles.md

# 접근성 가이드 확인
Read references/accessibility.md

# 랜딩 페이지 패턴 확인
Read references/patterns.md
```

</detailed_references>

---

<references>

## 외부 참고 자료

| 분류 | 자료 |
|------|------|
| **UX 원칙** | Nielsen Norman Group, Don Norman "The Design of Everyday Things" |
| **접근성** | WCAG 2.2, W3C WAI, WebAIM |
| **글로벌 디자인 시스템** | Material Design 3 (Expressive), Apple HIG (Liquid Glass), Fluent 2, Carbon, SLDS |
| **한국 디자인 시스템** | 토스 TDS, 카카오 Krane, 쿠팡 RDS, 배민, 당근 |
| **심리학** | Laws of UX, Gestalt 원칙, 인지부하 이론 |
| **트렌드** | Awwwards, Dribbble, Behance, Smashing Magazine |

### 외부 링크

- [Nielsen 10 Usability Heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/)
- [WCAG 2.2 Guidelines](https://www.w3.org/WAI/standards-guidelines/wcag/)
- [Material Design 3](https://m3.material.io/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Laws of UX](https://lawsofux.com/)

</references>
