---
name: prd
description: Product Requirements Document 생성
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

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

### Recommended Agents & Model Routing

| Agent | 권장 모델 | 용도 | 복잡도별 모델 |
|-------|----------|------|--------------|
| **analyst** | sonnet/opus | 요구사항 분석, 문제 정의, 가정 검증 | LOW: sonnet, HIGH: opus |
| **planner** | opus | PRD 구조 설계, 아키텍처 검증 | 항상 opus |
| **document-writer** | haiku/sonnet | PRD 작성, 문서화 | 단순 문서: haiku, 복잡 PRD: sonnet |
| **explore** | haiku | 기존 문서/코드 조사 | 항상 haiku |
| **architect** | sonnet/opus | 기술 아키텍처 검토, 설계 분석 | MEDIUM: sonnet, HIGH: opus |
| **designer** | sonnet/opus | UI/UX 요구사항 설계 | 일반: sonnet, 복잡: opus |

### Smart Model Routing

| 복잡도 | 모델 | PRD 유형 | 기준 |
|--------|------|----------|------|
| **LOW** | haiku/sonnet | 단순 기능 PRD | CRUD, 단일 화면, 명확한 요구사항 |
| **MEDIUM** | sonnet | 일반 기능 PRD | 다중 화면, API 통합, 2-3개 의존성 |
| **HIGH** | opus | 복잡한 시스템 PRD | 신규 아키텍처, 다중 의존성, 불확실성 높음 |

**에이전트 호출 시 항상 `model` 파라미터 명시:**

```typescript
Task(subagent_type="analyst", model="sonnet", ...)
Task(subagent_type="planner", model="opus", ...)
Task(subagent_type="document-writer", model="haiku", ...)
```

---

### Parallel Execution Patterns

PRD 작성 시 병렬 실행 가능한 8가지 패턴:

#### 패턴 1: 사용자 스토리 병렬 작성 (Persona별)

**시나리오:** 여러 Persona의 User Stories를 동시에 도출

```typescript
// Persona별로 독립적으로 분석
Task(subagent_type="analyst", model="sonnet",
     prompt="Persona 1 (관리자) 사용자 스토리 도출: 권한 관리, 대시보드")
Task(subagent_type="analyst", model="sonnet",
     prompt="Persona 2 (일반 사용자) 사용자 스토리 도출: 프로필, 콘텐츠 소비")
Task(subagent_type="analyst", model="sonnet",
     prompt="Persona 3 (크리에이터) 사용자 스토리 도출: 콘텐츠 생성, 분석")
```

**효과:** 3개 Persona 분석을 순차 대신 병렬로 처리 → 시간 단축

---

#### 패턴 2: 기술 요구사항 동시 분석 (영역별)

**시나리오:** Frontend, Backend, Infrastructure, Security 요구사항 동시 도출

```typescript
// 각 영역을 독립적으로 분석
Task(subagent_type="analyst", model="sonnet",
     prompt="Frontend 요구사항 분석: UI 컴포넌트, 상태 관리, 라우팅")
Task(subagent_type="analyst", model="sonnet",
     prompt="Backend 요구사항 분석: API 엔드포인트, 데이터 모델, 비즈니스 로직")
Task(subagent_type="architect", model="sonnet",
     prompt="Infrastructure 요구사항 분석: 배포, 스케일링, 모니터링")
Task(subagent_type="analyst", model="opus",
     prompt="Security 요구사항 분석: 인증/인가, 데이터 암호화, 취약점 대응")
```

**효과:** 4개 영역을 동시에 분석 → 종합적 요구사항 빠르게 파악

---

#### 패턴 3: 다중 관점 검증 병렬 (PM/Engineer/Designer/QA)

**시나리오:** PRD 초안 작성 후 여러 관점에서 동시 검토

```typescript
// 역할별로 독립적으로 검증
Task(subagent_type="analyst", model="sonnet",
     prompt="PM 관점 검증: 비즈니스 목표와 정렬, KPI 타당성, 우선순위")
Task(subagent_type="architect", model="opus",
     prompt="Engineer 관점 검증: 기술적 실현 가능성, 복잡도, 리스크")
Task(subagent_type="designer", model="sonnet",
     prompt="Designer 관점 검증: UX 플로우, 접근성, 디자인 시스템 일관성")
Task(subagent_type="analyst", model="sonnet",
     prompt="QA 관점 검증: 테스트 용이성, 엣지 케이스, 회귀 리스크")
```

**효과:** 4개 관점 동시 검토 → 누락 위험 감소

---

#### 패턴 4: 경쟁사 분석 + 시장 조사 병렬

**시나리오:** 신규 제품/기능 기획 시 경쟁사 및 시장 동시 분석

```typescript
// 경쟁사별, 시장별 동시 조사
Task(subagent_type="explore", model="haiku",
     prompt="경쟁사 A 기능 조사: 핵심 기능, 가격 정책, 차별화 포인트")
Task(subagent_type="explore", model="haiku",
     prompt="경쟁사 B 기능 조사: 사용자 리뷰, 주요 불만, 강점")
Task(subagent_type="analyst", model="sonnet",
     prompt="시장 트렌드 분석: 최근 1년 동향, 신기술 도입 사례")
Task(subagent_type="analyst", model="sonnet",
     prompt="사용자 니즈 분석: 설문조사 결과, 커뮤니티 피드백 요약")
```

**효과:** 경쟁사 2개 + 시장 조사를 병렬 처리 → 빠른 인사이트 도출

---

#### 패턴 5: Acceptance Criteria + Test Scenario 병렬 작성

**시나리오:** 기능별 AC와 테스트 시나리오를 동시에 작성

```typescript
// 기능별로 AC와 테스트 시나리오 병렬 작성
Task(subagent_type="document-writer", model="haiku",
     prompt="기능 1: 사용자 로그인 - Acceptance Criteria 작성")
Task(subagent_type="document-writer", model="haiku",
     prompt="기능 1: 사용자 로그인 - Test Scenario 작성 (Happy Path, Edge Cases)")

Task(subagent_type="document-writer", model="haiku",
     prompt="기능 2: 결제 처리 - Acceptance Criteria 작성")
Task(subagent_type="document-writer", model="haiku",
     prompt="기능 2: 결제 처리 - Test Scenario 작성")
```

**효과:** AC와 테스트 시나리오를 동시 작성 → 문서 완성도 향상

---

#### 패턴 6: 다중 기능 PRD 병렬 작성

**시나리오:** 독립적인 기능마다 별도 PRD 또는 섹션 병렬 작성

```typescript
// 독립적인 기능마다 PRD 작성
Task(subagent_type="document-writer", model="sonnet",
     prompt="User 관리 PRD 작성 (프로필 편집, 권한 관리)")
Task(subagent_type="document-writer", model="sonnet",
     prompt="Payment 연동 PRD 작성 (결제 플로우, 환불 처리)")
Task(subagent_type="document-writer", model="sonnet",
     prompt="Analytics 대시보드 PRD 작성 (지표 시각화, 리포팅)")
```

**효과:** 3개 기능을 병렬 작성 → 시간 대폭 단축

---

#### 패턴 7: 조사 + 분석 + 아키텍처 병렬

**시나리오:** 기존 시스템 조사 + 요구사항 분석 + 아키텍처 검토 동시 진행

```typescript
// 1단계: 조사 (병렬)
Task(subagent_type="explore", model="haiku",
     prompt="기존 인증 구조 조사 (Better Auth, 미들웨어, 세션 관리)")
Task(subagent_type="explore", model="haiku",
     prompt="기존 데이터 구조 조사 (Prisma 스키마, 관계)")

// 2단계: 분석 + 아키텍처 (병렬)
Task(subagent_type="analyst", model="opus",
     prompt="신규 소셜 로그인 요구사항 분석 (Google, GitHub)")
Task(subagent_type="architect", model="sonnet",
     prompt="소셜 로그인 아키텍처 검토 (OAuth 플로우, 토큰 관리)")
```

**효과:** 조사와 분석을 순차가 아닌 병렬로 → 빠른 의사결정

---

#### 패턴 8: 복잡한 시스템 PRD (3단계 병렬)

**시나리오:** 대규모 프로젝트에서 조사 → 분석 → 작성 단계마다 병렬 실행

```typescript
// 1단계: 다중 영역 조사 (병렬)
Task(subagent_type="explore", model="haiku", prompt="현재 데이터 구조 조사")
Task(subagent_type="explore", model="haiku", prompt="기존 통합 API 조사")
Task(subagent_type="explore", model="haiku", prompt="인프라 및 배포 환경 조사")

// 2단계: 다중 관점 분석 + 아키텍처 (병렬)
Task(subagent_type="analyst", model="opus", prompt="비즈니스 요구사항 분석")
Task(subagent_type="analyst", model="sonnet", prompt="사용자 요구사항 분석")
Task(subagent_type="architect", model="opus", prompt="기술 스택 및 아키텍처 검토")

// 3단계: 다중 섹션 PRD 작성 (병렬)
Task(subagent_type="document-writer", model="sonnet", prompt="PRD 섹션 1-5 작성")
Task(subagent_type="document-writer", model="sonnet", prompt="PRD 섹션 6-10 작성")
Task(subagent_type="document-writer", model="haiku", prompt="PRD 섹션 11-15 작성")
```

**효과:** 3단계 각각에서 병렬 처리 → 대규모 PRD도 빠르게 완성

---

### 실전 시나리오 (Model Routing 포함)

#### 시나리오 1: B2B SaaS - 팀 협업 도구 신규 기능

**요구사항:** "슬랙 연동 기능 추가 - 프로젝트 업데이트 자동 알림"

**복잡도:** MEDIUM (기존 시스템 + 외부 API 연동)

```typescript
// 1단계: 조사 (병렬, haiku)
Task(subagent_type="explore", model="haiku",
     prompt="현재 알림 시스템 구조 조사 (DB, 트리거, 이벤트)")
Task(subagent_type="explore", model="haiku",
     prompt="Slack API 문서 조사 (Webhook, OAuth, 메시지 포맷)")

// 2단계: 분석 (병렬, sonnet)
Task(subagent_type="analyst", model="sonnet",
     prompt="요구사항 분석: Slack 연동 시나리오, 가정 검증, 엣지 케이스")
Task(subagent_type="architect", model="sonnet",
     prompt="아키텍처 분석: Slack API 연동 패턴, 에러 핸들링, 재시도 로직")

// 3단계: PRD 작성 (sonnet)
Task(subagent_type="document-writer", model="sonnet",
     prompt=`Slack 연동 PRD 작성 (15개 섹션):
- 비전: 팀 커뮤니케이션 통합
- 문제: 수동으로 Slack에 업데이트 공유
- 목표: 알림 자동화율 90%+
- 기능 요구사항: Slack 연동 설정, 자동 알림, 메시지 템플릿
- 기술 요구사항: Slack API, OAuth, Webhook
- 리스크: API Rate Limit, 네트워크 오류`)
```

**Model Routing 이유:**
- explore (haiku): 단순 조사 작업
- analyst/architect (sonnet): 일반적인 API 연동 분석
- document-writer (sonnet): MEDIUM 복잡도 PRD

---

#### 시나리오 2: 모바일 앱 - 소셜 피드 기능

**요구사항:** "Instagram 스타일 피드 + 댓글 + 좋아요 기능"

**복잡도:** HIGH (복잡한 UI/UX + 실시간 업데이트 + 성능 최적화)

```typescript
// 1단계: 조사 + 경쟁사 분석 (병렬)
Task(subagent_type="explore", model="haiku",
     prompt="기존 콘텐츠 구조 조사 (Post, User, Media 모델)")
Task(subagent_type="explore", model="haiku",
     prompt="Instagram 피드 UX 조사: 무한 스크롤, 이미지 로딩, 캐싱")
Task(subagent_type="explore", model="haiku",
     prompt="Twitter 피드 UX 조사: 실시간 업데이트, 최적화 패턴")

// 2단계: 다중 관점 분석 (병렬, opus)
Task(subagent_type="analyst", model="opus",
     prompt="사용자 요구사항 분석: Persona별 시나리오, 엣지 케이스")
Task(subagent_type="architect", model="opus",
     prompt="아키텍처 분석: 피드 알고리즘, 실시간 업데이트, 캐싱 전략")
Task(subagent_type="designer", model="opus",
     prompt="UX 요구사항 분석: 플로우, 접근성, 모바일 최적화")

// 3단계: 다중 섹션 PRD 작성 (병렬, sonnet)
Task(subagent_type="document-writer", model="sonnet",
     prompt="소셜 피드 PRD 작성 - 비전, 문제, 목표, 범위 섹션 (1-4)")
Task(subagent_type="document-writer", model="sonnet",
     prompt="소셜 피드 PRD 작성 - 페르소나, 사용자 여정 섹션 (5-6)")
Task(subagent_type="document-writer", model="sonnet",
     prompt="소셜 피드 PRD 작성 - 기능 요구사항 섹션 (7)")
Task(subagent_type="document-writer", model="sonnet",
     prompt="소셜 피드 PRD 작성 - 기술/성능/리스크 섹션 (8-12)")
```

**Model Routing 이유:**
- explore (haiku): 조사 작업
- analyst/architect/designer (opus): 복잡한 UX/아키텍처 분석
- document-writer (sonnet): 섹션별 병렬 작성 (opus는 과도)

---

#### 시나리오 3: 내부 도구 - 관리자 대시보드

**요구사항:** "사용자 관리 + 지표 모니터링 + 로그 분석 대시보드"

**복잡도:** MEDIUM (내부 도구, 요구사항 명확)

```typescript
// 1단계: 요구사항 분석 (병렬, sonnet)
Task(subagent_type="analyst", model="sonnet",
     prompt="사용자 관리 요구사항 분석: CRUD, 권한, 검색/필터")
Task(subagent_type="analyst", model="sonnet",
     prompt="지표 모니터링 요구사항 분석: 차트, 기간 필터, 실시간 업데이트")
Task(subagent_type="analyst", model="sonnet",
     prompt="로그 분석 요구사항 분석: 검색, 필터, 내보내기")

// 2단계: 다중 기능 PRD 병렬 작성 (haiku/sonnet)
Task(subagent_type="document-writer", model="haiku",
     prompt="사용자 관리 PRD 작성 (간단한 CRUD)")
Task(subagent_type="document-writer", model="sonnet",
     prompt="지표 모니터링 PRD 작성 (차트, 쿼리 최적화 포함)")
Task(subagent_type="document-writer", model="haiku",
     prompt="로그 분석 PRD 작성 (검색/필터)")
```

**Model Routing 이유:**
- analyst (sonnet): 일반적인 내부 도구 요구사항
- document-writer (haiku): 단순 CRUD PRD
- document-writer (sonnet): 복잡한 지표 PRD

---

#### 시나리오 4: 데이터 대시보드 - 실시간 분석 플랫폼

**요구사항:** "실시간 데이터 수집 + 대시보드 + 알림 시스템"

**복잡도:** HIGH (실시간 처리 + 대용량 데이터 + 복잡한 아키텍처)

```typescript
// 1단계: 기술 영역별 분석 (병렬, opus)
Task(subagent_type="analyst", model="opus",
     prompt="실시간 데이터 파이프라인 요구사항 분석: 수집, 처리, 저장")
Task(subagent_type="architect", model="opus",
     prompt="아키텍처 분석: Kafka vs RabbitMQ, ClickHouse vs TimescaleDB")
Task(subagent_type="analyst", model="sonnet",
     prompt="대시보드 요구사항 분석: 차트, 필터, 사용자 커스터마이징")
Task(subagent_type="analyst", model="sonnet",
     prompt="알림 요구사항 분석: 트리거 조건, 채널 (이메일/슬랙/SMS)")

// 2단계: 다중 관점 검증 (병렬)
Task(subagent_type="analyst", model="sonnet",
     prompt="PM 관점 검증: 비즈니스 가치, 우선순위, ROI")
Task(subagent_type="architect", model="opus",
     prompt="Engineer 관점 검증: 기술적 리스크, 복잡도, 타임라인")
Task(subagent_type="designer", model="sonnet",
     prompt="Designer 관점 검증: 대시보드 UX, 정보 계층")

// 3단계: PRD 작성 (planner + document-writer)
Task(subagent_type="planner", model="opus",
     prompt="PRD 구조 설계: 15개 섹션 우선순위, 핵심 리스크 식별")
Task(subagent_type="document-writer", model="sonnet",
     prompt="실시간 분석 플랫폼 PRD 작성 (Planner 구조 기반)")
```

**Model Routing 이유:**
- analyst/architect (opus): 복잡한 실시간 시스템 분석
- planner (opus): PRD 구조 설계 (HIGH 복잡도)
- document-writer (sonnet): 최종 PRD 작성

---

### 에이전트 활용 체크리스트

PRD 작성 시작 전 확인:

**복잡도 판단**
- [ ] 단순 기능 (CRUD, 단일 화면) → LOW → haiku/sonnet
- [ ] 일반 기능 (다중 화면, API 연동) → MEDIUM → sonnet
- [ ] 복잡한 시스템 (신규 아키텍처, 높은 불확실성) → HIGH → opus

**병렬 실행 가능 확인**
- [ ] 여러 Persona의 사용자 스토리 → 패턴 1 (analyst x N)
- [ ] 기술 영역별 요구사항 (Frontend/Backend/Security) → 패턴 2
- [ ] 다중 관점 검증 (PM/Engineer/Designer/QA) → 패턴 3
- [ ] 경쟁사 분석 + 시장 조사 → 패턴 4
- [ ] 기능별 AC + 테스트 시나리오 → 패턴 5
- [ ] 독립적인 기능 여러 개 → 패턴 6

**에이전트 선택**
- [ ] 요구사항 분석 → analyst (sonnet/opus)
- [ ] 아키텍처 검토 → architect (sonnet/opus)
- [ ] PRD 구조 설계 → planner (opus)
- [ ] PRD 작성 → document-writer (haiku/sonnet)
- [ ] 기존 시스템 조사 → explore (haiku)
- [ ] UI/UX 요구사항 → designer (sonnet/opus)

**Model 선택**
- [ ] haiku: 조사, 단순 문서, 명확한 요구사항
- [ ] sonnet: 일반적인 분석/작성, 균형 잡힌 품질
- [ ] opus: 복잡한 분석, 아키텍처 설계, 불확실성 높은 작업

**실행 순서**
- [ ] 1단계: 조사 (explore) + 경쟁사 분석 (병렬)
- [ ] 2단계: 요구사항 분석 (analyst) + 아키텍처 검토 (architect) (병렬)
- [ ] 3단계: PRD 작성 (document-writer) 또는 섹션별 병렬 작성

**적극적으로 에이전트 활용. 혼자 하지 말 것.**

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1 | 복잡도 판단 및 PRD 구조 계획 | Sequential Thinking (3-5단계) |
| 2 | 코드베이스/문서 조사 (필요시) | Task (Explore) |
| 3 | 병렬 Agent 실행 (복잡한 경우) | Task (analyst, architect, document-writer) |
| 4 | 15개 섹션 구조로 PRD 작성 | Write → `.claude/plan/` 또는 `docs/prd/` |

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
   → .claude/plan/profile-edit-prd.md

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
