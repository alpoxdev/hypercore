# PRD Skill

> Product Requirements Document 생성

<when_to_use>

| 시나리오 | 설명 |
|---------|------|
| **신규 기능** | 3개 이상 파일 수정이 예상되는 기능 |
| **아키텍처 변경** | 새로운 시스템/모듈 추가 |
| **복잡한 요구사항** | 다중 의존성, 여러 팀 협업 |
| **기획 문서화** | 아이디어/회의 메모를 구조화된 문서로 변환 |

**호출 시점**: 구현 전 요구사항 정리, 팀 커뮤니케이션, 의사결정 기록

</when_to_use>

---

<parallel_agent_execution>

## 병렬 Agent 실행

PRD 작성 시 여러 Agent를 병렬로 실행하여 효율성 향상.

### Recommended Agents

| Agent | Model | 용도 |
|-------|-------|------|
| **@analyst** | sonnet/opus | 요구사항 분석, 문제 정의 |
| **@document-writer** | sonnet | PRD 작성, 문서화 |
| **@explore** | haiku | 기존 문서/코드 조사 |
| **@architect** | sonnet | 기술 아키텍처 검토 |

### Parallel Execution Patterns

| 패턴 | 조합 | 시나리오 |
|------|------|----------|
| **조사 + 분석** | explore + analyst | 기존 구조 파악 + 요구사항 분석 |
| **다중 기능 PRD** | document-writer x N | 독립적인 기능마다 병렬 작성 |
| **분석 + 아키텍처** | analyst + architect | 요구사항 분석 + 기술 검토 동시 진행 |

### Model Routing

| 복잡도 | Model | 기준 |
|--------|-------|------|
| **LOW** | haiku/sonnet | 단순 기능 PRD (CRUD, 단일 화면) |
| **MEDIUM** | sonnet | 일반 기능 PRD (다중 화면, API 통합) |
| **HIGH** | opus | 복잡한 시스템 PRD (신규 아키텍처, 다중 의존성) |

### Practical Examples

#### 조사 + 분석 병렬

```typescript
// ✅ 기존 인증 구조 조사 + 신규 요구사항 분석
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '기존 인증 구조 조사 (Better Auth, 미들웨어, 세션 관리)'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: '소셜 로그인 추가 요구사항 분석 (Google, GitHub)'
})
```

#### 다중 기능 PRD 병렬

```typescript
// ✅ 독립적인 기능마다 PRD 작성
Task({
  subagent_type: 'document-writer',
  model: 'sonnet',
  prompt: 'User 관리 PRD 작성 (프로필 편집, 권한 관리)'
})

Task({
  subagent_type: 'document-writer',
  model: 'sonnet',
  prompt: 'Payment 연동 PRD 작성 (결제 플로우, 환불 처리)'
})
```

#### 분석 + 아키텍처 병렬

```typescript
// ✅ 요구사항 분석 + 기술 아키텍처 검토
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: '실시간 알림 요구사항 분석 (사용자 니즈, 우선순위)'
})

Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '실시간 알림 기술 아키텍처 검토 (WebSocket vs SSE vs Firebase)'
})
```

#### 복잡한 시스템 PRD

```typescript
// ✅ 조사 → 분석 → PRD 작성 (순차 + 병렬)
// 1단계: 조사 (병렬)
Task({ subagent_type: 'explore', model: 'haiku', prompt: '현재 데이터 구조 조사' })
Task({ subagent_type: 'explore', model: 'haiku', prompt: '기존 통합 API 조사' })

// 2단계: 분석 + 아키텍처 (병렬)
Task({ subagent_type: 'analyst', model: 'opus', prompt: '신규 시스템 요구사항 분석' })
Task({ subagent_type: 'architect', model: 'sonnet', prompt: '기술 스택 및 아키텍처 검토' })

// 3단계: PRD 작성
Task({ subagent_type: 'document-writer', model: 'sonnet', prompt: '통합 PRD 작성' })
```

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1 | 복잡도 판단 및 PRD 구조 계획 | Sequential Thinking (3-5단계) |
| 2 | 코드베이스/문서 조사 (필요시) | Task (Explore) |
| 3 | 병렬 Agent 실행 (복잡한 경우) | Task (analyst, architect, document-writer) |
| 4 | 15개 섹션 구조로 PRD 작성 | Write → `.claude/plans/` 또는 `docs/prd/` |

**핵심 원칙**:
- 짧고 명확한 문장, 구체적 예시
- User Stories + Functional + Non-functional 구분
- 현재값 → 목표값 형태 지표
- 불확실한 부분은 Open Questions에 명시

</workflow>

---

<prd_structure>

## PRD 15개 섹션 구조

### 1. 메타데이터
제목, 작성자, 버전, 날짜, 관련 문서 링크

### 2. 비전 & 배경
- 제품 비전 (1-2문장)
- 배경/컨텍스트 (왜 지금?)
- 기존 한계 (간단히)

### 3. 문제 정의 & 목표
- **문제**: 어떤 문제/기회 (유저 피드백, 지표)
- **목표**: 측정 가능한 KPI (비즈니스/사용자)

### 4. 범위 (Scope)
- **In Scope**: P0/P1 기능
- **Out of Scope**: 후속 릴리즈

### 5. 타깃 유저 & 페르소나
- 주요 세그먼트
- 페르소나 (이름, 역할, 목표, Pain Point)
- Primary Persona

### 6. 사용자 여정 & 시나리오
- 여정 단계 (해당 구간 표시)
- 대표 시나리오 (사용자 목적과 단계)

### 7. 기능 요구사항
각 기능마다:
- **User Stories**: As a [유저], I want to [행동] so that [가치]
- **기능 설명**: Happy Path, Alternative Flow, Edge Case
- **Functional Requirements**: 시스템 동작 명세
- **Non-functional Requirements**: 성능, 보안, 사용성

### 8. UX/UI 요구사항
- 핵심 원칙 (디자인 제약)
- 필수 정보/액션
- 접근성 (다국어, 키보드, 대비)

### 9. 기술/데이터 요구사항
- 기술 스택, 통합/의존성
- 데이터 구조 (엔티티)
- 보안/규제 (인증, 개인정보)

### 10. 성공 지표 & KPI

| 지표 | 현재값 | 목표값 | 측정 방법 |
|------|--------|--------|----------|
| ... | ... | ... | ... |

### 11. 리스크, 가정, 의존성
- 가정 (전제 조건)
- 리스크 (기술/비즈니스/UX, 완화 방안)
- 의존성 (다른 팀/프로젝트)

### 12. 릴리즈 전략 & 마일스톤
- 릴리즈 전략 (전체/단계적/A/B)
- 마일스톤 (타임라인)
- 롤백 계획 (Feature Flag)

### 13. 오픈 이슈 & Todo

| 질문 | 결정자 | 기한 |
|------|--------|------|
| ... | ... | ... |

### 14. 작성 스타일 가이드
- 짧고 명확한 문장, 수식어 제거
- "좋은 UX" → 구체적 기준/예시
- 트레이드오프 선택 이유 명시

### 15. Claude 최종 지시
- 15개 섹션 구조 준수
- 기능/요구사항: User Stories + Functional + Non-functional
- 불명확한 부분 → Open Questions
- 기존 PRD 수정 시 → Change log

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
사용자: 사용자 프로필 편집 기능 PRD 작성

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
사용자: 실시간 알림 시스템 PRD 작성

1. Sequential Thinking (7단계):
   thought 1: "실시간 알림 - 복잡도 높음, 새 인프라 필요"
   thought 2: "현재 통신: REST만, 폴링 없음"
   thought 3: "제약: 서버 부하, 클라이언트 연결 관리"
   thought 4: "접근: WebSocket vs SSE vs Firebase"
   thought 5: "WebSocket - 양방향, 복잡. SSE - 단방향, 간단"
   thought 6: "옵션 3개: WebSocket(추천), SSE, Firebase"
   thought 7: "WebSocket 추천 - 확장성, 제어 가능"

2. 병렬 실행:
   Task({ subagent_type: 'analyst', prompt: '알림 요구사항 분석' })
   Task({ subagent_type: 'architect', prompt: 'WebSocket 아키텍처 검토' })

3. PRD 작성:
   - 비전: "사용자가 즉시 중요한 업데이트를 받는다"
   - 범위:
     * In: 주문 상태, 메시지 알림
     * Out: 푸시 알림 (후속)
   - 기술: WebSocket (ws 라이브러리), Redis Pub/Sub
   - 리스크: 연결 안정성 (완화: 자동 재연결)
```

### 예시 3: 대시보드 분석 기능

```bash
사용자: 대시보드 분석 기능 PRD - 매출, 주문, 트래픽 차트

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
