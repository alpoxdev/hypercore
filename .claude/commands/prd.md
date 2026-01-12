---
description: PRD(Product Requirements Document) 생성
allowed-tools: Read, Write, Glob, Grep, Task, mcp__sequential-thinking__sequentialthinking
argument-hint: <feature/product description>
---

<critical_instruction>

**CRITICAL: 사용자와의 모든 커뮤니케이션은 반드시 한국어로 작성하세요.**

- 내부 사고와 분석은 영어로 해도 됨
- 설명, 요약, 보고서, 피드백 등 사용자에게 전달하는 모든 내용은 반드시 한국어
- 사용자가 영어로 말하더라도 답변은 한국어로
- 진행 상황 업데이트와 상태 보고는 반드시 한국어

이 규칙은 절대적이며 예외가 없습니다.

</critical_instruction>

---


@../instructions/sequential-thinking-guide.md

# PRD Command

Write Product Requirements Document (PRD) for feature/product.

**Target**: $ARGUMENTS

---

<workflow>

## Execution Flow

| Step | Task | Tool |
|------|------|------|
| 1. Validate input | Verify ARGUMENT, ask if missing | - |
| 2. Sequential Thinking | Analyze PRD structure in 3-5 steps | sequentialthinking |
| 3. Check codebase | Explore related code/documents (if needed) | Task (Explore) |
| 4. Write PRD | Write in 15-section structure | Write |
| 5. Save | Save to `.claude/plans/` or `docs/prd/` | - |

</workflow>

---

<forbidden>

| Category | Forbidden |
|----------|-----------|
| **Problem definition** | Include solutions/feature list |
| **Scope** | List without In/Out distinction |
| **Expression** | Vague expressions ("good UX", "fast") |
| **Style** | Marketing language, excessive adjectives |

</forbidden>

---

<required>

| Category | Required |
|----------|----------|
| **Structure** | 15 sections (metadata ~ template) |
| **Feature requirements** | User Stories + Functional + Non-functional |
| **Metrics** | Current value → target value format |
| **Assumptions/Risks** | Specify in separate section |
| **Style** | Short clear sentences, concrete examples |

</required>

---

<prd_structure>

## PRD 15개 섹션 구조

### 1. 메타데이터

| 항목 | 내용 |
|------|------|
| **제목** | 제품명 + 버전/설명 |
| **작성자** | PM/오너 |
| **버전** | v0.1 (초안), v1.0 (확정) 등 |
| **날짜** | 최초 작성일, 마지막 수정일 |
| **관련 문서** | 전략 문서, 디자인, 기술 설계 링크 |

### 2. 비전 & 배경

```text
✅ 3-5문장 이내
✅ "어떤 사용자, 어떤 문제, 어떤 임팩트"

포함 내용:
- 제품 비전 (1-2문장)
- 배경/컨텍스트 (왜 지금 하는지)
- 이전 시도/기존 제품 한계 (간단히)
```

### 3. 문제 정의 & 목표

| 섹션 | 내용 | 포함 요소 |
|------|------|----------|
| **문제 정의** | 어떤 문제/기회가 있는지 | 유저 피드백, 지표 (전환율, 이탈률) |
| **목표** | 비즈니스/사용자 목표 | 측정 가능한 KPI (예: 결제율 +5%) |

```text
❌ 솔루션/기능 목록 넣지 않기
✅ "무엇이 문제이고 무엇을 달성하려 하는지"만
```

### 4. 범위 (Scope)

| 구분 | 내용 |
|------|------|
| **In Scope** | 이번 릴리즈 포함 기능 (P0/P1 표시) |
| **Out of Scope** | 하지 않는 것 (후속 릴리즈 메모) |

### 5. 타깃 유저 & 페르소나

```markdown
## 주요 타깃 유저
- 세그먼트 1
- 세그먼트 2

## 페르소나 (1-3개)
**이름(가명)**:
**역할**:
**목표**:
**Pain Point**:

**Primary Persona**: [가장 우선 해결]
```

```text
✅ 행동/맥락/목표 중심
❌ 기능 설명 아님
```

### 6. 사용자 여정 & 시나리오

```markdown
## 주요 여정 단계
랜딩 → 가입 → 첫 세팅 → 핵심 기능 → 반복 → 업그레이드

## 이번 PRD 구간
[해당 구간 표시]

## 대표 시나리오
사용자 A는 X를 하기 위해 앱을 연다.
...
그래서 Y를 할 수 있게 된다.
```

```text
✅ 사용자 목적과 단계만 요약
❌ 상세한 UI 단계 나열 금지
```

### 7. 기능 요구사항 (핵심)

#### 기능 구조

각 기능마다 포함:

| 필드 | 내용 |
|------|------|
| **기능 이름** | - |
| **설명** | 1-2문장 |
| **목표/가치** | 어떤 문제 해결, 어떤 지표 영향 |
| **우선순위** | P0/P1 또는 Must/Should/Could |
| **관련 시나리오** | 사용자 시나리오/페르소나 |

#### 기능 상세

```markdown
### [기능 1]

#### User Stories
- As a [유저 타입], I want to [행동] so that [가치]
- ...

#### 기능 설명
동작, 상태, 변형 설명.
- Happy Path
- Alternative Flow
- Edge Case

#### Functional Requirements
- 시스템은 X 버튼 클릭 시 Y API 호출해야 함
- 성공 시 Z 화면 이동해야 함

#### Non-functional Requirements
- 퍼포먼스: 응답 시간 < 200ms
- 보안: JWT 인증 필수
- 사용성: 키보드 네비게이션 지원
```

### 8. UX/UI 요구사항

| 항목 | 내용 |
|------|------|
| **핵심 원칙** | "간편함 우선", "모바일 우선" 등 |
| **UI 제약** | 필수 정보, 숨기면 안 되는 액션 |
| **접근성** | 다국어, 키보드, 대비, 폰트 제한 |

```text
✅ 디자인이 꼭 지켜야 하는 제약/원칙
❌ 상세 디자인 아님
```

### 9. 기술/데이터 요구사항

| 항목 | 내용 |
|------|------|
| **기술 제약** | 스택, 호환성, 아키텍처 연결 |
| **통합/의존성** | 외부 서비스 API, 내부 시스템 |
| **데이터** | 저장/조회/집계 데이터, 엔티티 |
| **보안/규제** | 인증/인가, 개인정보, 감사 로그 |

```text
✅ 개발 설계 시작 전 꼭 알아야 할 제약
❌ 구현 세부 코드 수준 금지
```

### 10. 성공 지표 & KPI

```markdown
| 지표 | 현재값 | 목표값 | 측정 방법 |
|------|--------|--------|----------|
| 활성 사용자 | 1,000 | 1,500 | GA 이벤트 |
| 전환율 | 20% | 25% | 결제 완료 / 방문 |
| 이탈률 | 40% | 25% 이하 | 가입 플로우 |
```

```text
✅ 현재값 → 목표값 형태
✅ 측정 방법 명시
```

### 11. 리스크, 가정, 의존성

| 분류 | 내용 |
|------|------|
| **가정** | "유저는 이메일 인증 완료 상태", "마케팅 캠페인 진행" |
| **리스크** | 기술/비즈니스/UX 리스크, 심각도/가능성 |
| **의존성** | 다른 팀/프로젝트/벤더, 선행 작업 |

```text
✅ 별도 섹션으로 명확히
❌ 기능 설명에 섞지 않기
```

### 12. 릴리즈 전략 & 마일스톤

```markdown
## 릴리즈 전략
- 전체 론칭 / 단계적 롤아웃 / A/B 테스트

## 마일스톤
- 설계 완료: 2025-02-15
- 개발 완료: 2025-03-01
- 베타 릴리즈: 2025-03-15
- GA: 2025-04-01

## 롤백 계획
- Feature Flag 사용
- 문제 발생 시 즉시 비활성화
```

```text
✅ 타임라인 + 큰 이벤트만
❌ 상세 스프린트 계획 금지
```

### 13. 오픈 이슈 & Todo

```markdown
## Open Questions

| 질문 | 결정자 | 기한 |
|------|--------|------|
| 가격 정책 | PM | 2025-02-10 |
| 온보딩 플로우 구성 | UX팀 | 2025-02-15 |
| 정책 문구 확정 | Legal | 2025-02-20 |
```

```text
✅ 불확실한 부분 명시
❌ 숨기지 않기
```

### 14. 작성 스타일 가이드 (Claude용)

| 원칙 | 적용 |
|------|------|
| **톤** | 짧고 명확한 문장, 수식어 제거 |
| **구조** | 1-13 섹션 순서 유지 |
| **구체성** | "좋은 UX" → 구체적 기준/예시 |
| **트레이드오프** | 선택 이유 한 줄 설명 |

### 15. Claude 최종 지시

```text
1. 15개 섹션 구조 기준으로 PRD 구성
2. 입력(아이디어, 회의 메모)을 다음으로 재구성:
   - 문제/목표
   - 범위
   - 기능 요구사항
   - 리스크/가정
   - 성공 지표

3. 기능/요구사항 작성 시 포함:
   - User Stories
   - 기능 설명
   - Functional Requirements
   - Non-functional Requirements

4. 불명확한 부분:
   - "Open Questions" 섹션에 질문 리스트

5. 기존 PRD 수정 시:
   - Change log (변경 요약)
```

</prd_structure>

---

<template>

## PRD 템플릿

```markdown
# [제품/기능명] PRD

## 메타데이터

| 항목 | 내용 |
|------|------|
| **작성자** | [이름] |
| **버전** | v0.1 |
| **작성일** | YYYY-MM-DD |
| **수정일** | YYYY-MM-DD |
| **관련 문서** | [링크] |

---

## 1. 비전 & 배경

**비전**: [1-2문장]

**배경**: [왜 지금 하는지]

**기존 한계**: [간단히]

---

## 2. 문제 정의 & 목표

### 문제
[어떤 문제/기회]

**인사이트**:
- 유저 피드백: [요약]
- 지표: 전환율 15%, 이탈률 50%

### 목표

| 분류 | 목표 |
|------|------|
| **비즈니스** | 결제 완료율 +5% |
| **사용자** | 작업 시간 30% 단축 |

---

## 3. 범위

### In Scope (P0/P1)
- [ ] 기능 1 (P0)
- [ ] 기능 2 (P1)

### Out of Scope
- 기능 X (후속 릴리즈)

---

## 4. 타깃 유저 & 페르소나

### 주요 세그먼트
- 세그먼트 1
- 세그먼트 2

### 페르소나

**이름**: 김OO
**역할**: 소규모 쇼핑몰 운영자
**목표**: 재고 관리 자동화
**Pain Point**: 수동 입력 시간 과다

**Primary Persona**: 김OO

---

## 5. 사용자 여정 & 시나리오

### 여정 단계
`랜딩 → [가입 → 첫 세팅] → 핵심 기능 → 반복 → 업그레이드`

### 대표 시나리오
사용자는 재고를 빠르게 등록하기 위해 앱을 연다.
...
5분 안에 100개 상품을 등록할 수 있다.

---

## 6. 기능 요구사항

### 기능 1: [이름]

**설명**: [1-2문장]

**목표**: [어떤 문제 해결]

**우선순위**: P0

#### User Stories
- As a 쇼핑몰 운영자, I want to 엑셀로 재고를 일괄 등록 so that 시간을 절약할 수 있다

#### 기능 설명
- 엑셀 파일 업로드 (최대 1,000행)
- 검증: 필수 필드, 중복 체크
- 성공/실패 피드백

#### Functional Requirements
- 시스템은 엑셀 업로드 시 필수 필드(상품명, 가격) 검증해야 함
- 중복 상품은 경고 표시 후 사용자 선택(덮어쓰기/건너뛰기)
- 성공 시 재고 목록 페이지로 이동

#### Non-functional Requirements
- 성능: 1,000행 처리 < 3초
- 보안: 파일 크기 제한 5MB
- 사용성: 진행률 표시

---

### 기능 2: [이름]
...

---

## 7. UX/UI 요구사항

| 항목 | 내용 |
|------|------|
| **핵심 원칙** | 간편함 우선, 3클릭 이내 완료 |
| **필수 정보** | 진행률 바, 에러 메시지 |
| **접근성** | 키보드 네비게이션, 한/영 지원 |

---

## 8. 기술/데이터 요구사항

| 항목 | 내용 |
|------|------|
| **기술 스택** | React, TanStack Query, Prisma |
| **통합** | Excel Parser (xlsx.js) |
| **데이터** | Product 테이블 (name, price, quantity) |
| **보안** | JWT 인증, File validation |

---

## 9. 성공 지표 & KPI

| 지표 | 현재값 | 목표값 | 측정 방법 |
|------|--------|--------|----------|
| 등록 시간 | 평균 15분 | 5분 이하 | 업로드 완료 이벤트 |
| 에러율 | 30% | 10% 이하 | 실패 업로드 / 전체 |
| 주간 활성 | 500명 | 800명 | GA 이벤트 |

---

## 10. 리스크, 가정, 의존성

| 분류 | 내용 |
|------|------|
| **가정** | 사용자는 엑셀 형식을 알고 있음 |
| **리스크** | 대용량 파일 처리 성능 (완화: 행 수 제한) |
| **의존성** | xlsx.js 라이브러리 |

---

## 11. 릴리즈 전략

**전략**: 단계적 롤아웃 (베타 → GA)

**마일스톤**:
- 설계 완료: 2025-02-20
- 베타 릴리즈: 2025-03-10 (100명)
- GA: 2025-03-25

**롤백**: Feature Flag 사용

---

## 12. 오픈 이슈

| 질문 | 결정자 | 기한 |
|------|--------|------|
| 엑셀 템플릿 제공 여부 | PM | 2025-02-15 |
| 에러 메시지 문구 확정 | UX | 2025-02-20 |
```

</template>

---

<examples>

## 실전 예시

### 예시 1: 사용자 프로필 편집

```bash
사용자: /prd 사용자 프로필 편집 기능

1. Sequential Thinking (5단계):
   thought 1: "프로필 편집 - 보통 복잡도, CRUD 기본 기능"
   thought 2: "현재 User 모델 확인 필요, 인증 방식 파악"
   thought 3: "편집 가능 필드: 이름, 이메일, 프로필 이미지"
   thought 4: "검증: 이메일 중복, 이미지 크기, 형식"
   thought 5: "API: PUT /api/user/:id, 클라이언트: useQuery + useMutation"

2. Task 탐색:
   Task (Explore): "User 모델 및 인증 구조 분석"

3. PRD 작성:
   → .claude/plans/profile-edit-prd.md

4. 주요 섹션:
   - 문제: 사용자가 정보를 수정할 방법이 없음
   - 목표: 프로필 편집 완료율 90% 이상
   - 기능: 이름/이메일/이미지 편집, 실시간 검증
   - KPI: 편집 완료율, 에러율
```

### 예시 2: 실시간 알림

```bash
사용자: /prd 실시간 알림 시스템 추가

1. Sequential Thinking (7단계):
   thought 1: "실시간 알림 - 복잡도 높음, 새 인프라 필요"
   thought 2: "현재 통신: REST만, 폴링 없음"
   thought 3: "제약: 서버 부하, 클라이언트 연결 관리"
   thought 4: "접근: WebSocket vs SSE vs Firebase"
   thought 5: "WebSocket - 양방향, 복잡. SSE - 단방향, 간단"
   thought 6: "옵션 3개: WebSocket(추천), SSE, Firebase"
   thought 7: "WebSocket 추천 - 확장성, 제어 가능"

2. PRD 작성:
   - 비전: "사용자가 즉시 중요한 업데이트를 받는다"
   - 범위:
     * In: 주문 상태, 메시지 알림
     * Out: 푸시 알림 (후속)
   - 기술: WebSocket (ws 라이브러리), Redis Pub/Sub
   - 리스크: 연결 안정성 (완화: 자동 재연결)
```

### 예시 3: 대시보드 분석 기능

```bash
사용자: /prd 대시보드 분석 기능 - 매출, 주문, 트래픽 차트

1. Sequential Thinking (5단계):
   thought 1: "대시보드 - 보통 복잡도, 데이터 집계 + 시각화"
   thought 2: "데이터: Order, Payment, Analytics 테이블"
   thought 3: "차트: 라인(트렌드), 바(비교), 파이(비율)"
   thought 4: "필터: 기간(일/주/월), 카테고리"
   thought 5: "성능: 집계 쿼리 최적화, 캐싱 필요"

2. PRD 핵심:
   - 문제: 매출 데이터를 확인하려면 여러 페이지 접근 필요
   - 목표: 대시보드 사용률 70% 이상
   - 기능 요구사항:
     * User Story: "As a 관리자, I want to 매출 트렌드를 한눈에 보고 싶다"
     * Functional: 기간별 매출 집계, 차트 렌더링
     * Non-functional: 쿼리 < 500ms, 캐싱 5분
   - 성공 지표:
     * 페이지뷰: 0 → 500/일
     * 로딩 시간: - → 500ms 이하
```

</examples>

---

<validation>

## 검증 체크리스트

실행 전:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ Sequential Thinking 3-5단계
✅ Task (Explore)로 코드베이스 확인 (필요시)
✅ 15개 섹션 구조 준수
✅ User Stories 형식 작성
✅ Functional/Non-functional 구분
✅ 현재값 → 목표값 지표
✅ Open Questions 명시 (불확실한 부분)
```

절대 금지:

```text
❌ ARGUMENT 없이 PRD 작성
❌ Sequential Thinking 3단계 미만
❌ 문제 정의에 솔루션 포함
❌ In/Out Scope 구분 없이 나열
❌ 모호한 표현만 사용 ("좋은 UX")
❌ User Stories 없이 기능만 나열
❌ 불확실한 부분 숨기기
```

</validation>
