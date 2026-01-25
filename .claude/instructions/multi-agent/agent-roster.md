# 에이전트 로스터 (Agent Roster)

전문화된 AI 에이전트 목록 및 활용 가이드.

---

## 개요

이 문서는 claude-code 프로젝트에서 사용 가능한 모든 에이전트와 각각의:
- 최적 모델 추천
- 상세한 사용 사례
- 병렬 실행 호환성
- 조정 패턴

를 정리한 것입니다.

**핵심 원칙:**
- 작업의 특성에 맞는 전문 에이전트 선택
- 독립적인 작업은 병렬 실행
- 복잡도에 따른 모델 라우팅

---

## 에이전트 카테고리

### 1. 계획 및 분석 (Planning & Analysis)

#### planner (계획자)

| 속성 | 값 |
|------|-----|
| **모델** | `opus` (의사결정 모델) |
| **병렬 가능** | ❌ (조정자 역할, 단일 스레드) |
| **실행 시간** | 60-120초 |
| **토큰 비용** | 💰💰💰 |

**용도:**
- 대규모 작업 계획 수립 및 분해
- 아키텍처 결정 전 전략 수립
- 복잡한 요구사항 분석 및 인터뷰 진행
- `.claude/plans/` 디렉토리에 계획 문서 생성
- 프로젝트 로드맵 정의

**사용 예시:**
```
planner: "신규 인증 시스템 전환 계획 수립"
→ 출력: .claude/plans/auth-migration.md
```

**특징:**
- 가장 비용이 높음 (opus 모델)
- 한 번에 하나씩만 실행 (조정자 역할)
- 나머지 에이전트 실행을 위한 가이드 생성

---

#### analyst (분석자)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` |
| **병렬 가능** | ✅ (독립적 분석) |
| **실행 시간** | 30-60초 |
| **토큰 비용** | 💰💰 |

**용도:**
- 코드 분석 및 패턴 발견
- 성능 분석 및 병목 지점 식별
- 데이터 분석
- 기존 구현 리뷰 및 개선점 제안

**사용 예시:**
```
Task(subagent_type="analyst", model="sonnet",
     prompt="현재 API 성능 병목 분석")
```

**병렬 실행 예시:**
```
// 병렬 실행 가능
Task(subagent_type="analyst", ...) # API 성능 분석
Task(subagent_type="analyst", ...) # DB 쿼리 분석
Task(subagent_type="analyst", ...) # 번들 크기 분석
```

---

#### architect (아키텍트)

| 속성 | 값 |
|------|-----|
| **모델** | `opus` (설계 모델) |
| **병렬 가능** | ❌ (의사결정 기반) |
| **실행 시간** | 60-120초 |
| **토큰 비용** | 💰💰💰 |

**용도:**
- 시스템 아키텍처 설계
- 기술 스택 선택 및 비교
- 마이그레이션 전략 수립
- 확장성/성능 설계

**사용 예시:**
```
architect: "마이크로서비스 아키텍처 설계"
→ 출력: 시스템 다이어그램, 컴포넌트 정의
```

**특징:**
- 여러 설계안 제시 후 최종 선택 필요
- planner와 유사하게 조정 역할

---

### 2. 탐색 및 조사 (Exploration & Investigation)

#### explore (탐색자)

| 속성 | 값 |
|------|-----|
| **모델** | `haiku` (빠른 탐색) |
| **병렬 가능** | ✅ (독립적 검색) |
| **실행 시간** | 10-30초 |
| **토큰 비용** | 💰 |

**용도:**
- 코드베이스 구조 빠른 파악
- 특정 함수/컴포넌트 위치 찾기
- 패턴/정의 검색
- 의존성 관계 파악
- 파일 구조 분석

**사용 예시:**
```
Task(subagent_type="explore", model="haiku",
     prompt="현재 프로젝트의 인증 로직 위치 찾기")
```

**병렬 실행 예시:**
```
// Phase 1: 병렬 탐색 (모두 동시 실행)
Task(subagent_type="explore", ...) # 프로젝트 구조 분석
Task(subagent_type="explore", ...) # 기존 인증 로직 위치
Task(subagent_type="explore", ...) # 테스트 구조 파악
Task(subagent_type="explore", ...) # API 라우터 위치

// Phase 2: 구현 (Phase 1 결과 기반)
Task(subagent_type="implementation-executor", ...) # 새 기능 구현
```

**특징:**
- 가장 저렴하고 빠름 (haiku 모델)
- 다른 작업의 전제 조건으로 사용 가능
- 3-10개까지 안전하게 병렬 실행 가능

---

### 3. 구현 (Implementation)

#### implementation-executor (구현 전문가)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` (기본) / `opus` (복잡도 높음) |
| **병렬 가능** | ✅ (독립적 모듈/기능) |
| **실행 시간** | 30-120초 |
| **토큰 비용** | 💰💰 (sonnet) / 💰💰💰 (opus) |

**용도:**
- 기능 즉시 구현 (옵션 제시 없음)
- Server Function/API 엔드포인트 구현
- 로직 작성 및 비즈니스 기능
- 테스트 코드 작성
- 버그 수정

**사용 예시:**
```
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`User API 엔드포인트 구현
     - POST /users: 사용자 생성 (Zod 검증)
     - GET /users: 사용자 목록
     - 인증: authMiddleware 사용`)
```

**병렬 실행 예시:**
```
// 풀스택 기능: API + UI + 테스트 동시 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User API 엔드포인트 구현")

Task(subagent_type="designer", model="sonnet",
     prompt="User 프로필 UI 구현")

Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User API 통합 테스트 작성")
```

**배치 처리 예시:**
```
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`다음 10개 파일에 동일한 리팩토링 적용:
     - file1.ts ~ file10.ts

     공통 규칙:
     1. function fn() → const fn = ()
     2. any → unknown
     3. 명시적 return type 추가`)
```

**특징:**
- "최적 방법으로 즉시 구현" (옵션 제시 금지)
- 복잡도 높은 작업은 opus 사용 권장
- 10개 이상 유사 작업은 배치 처리로 토큰 70-90% 절감

---

#### designer (디자이너)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` (기본) / `opus` (복잡한 UI 시스템) |
| **병렬 가능** | ✅ (독립적 컴포넌트) |
| **실행 시간** | 30-120초 |
| **토큰 비용** | 💰💰 (sonnet) / 💰💰💰 (opus) |

**용도:**
- React/TanStack Start 컴포넌트 구현
- UI/UX 구현 (Tailwind CSS)
- 접근성(A11y) 및 반응형 디자인
- 디자인 시스템 컴포넌트
- 폼 구성 및 유효성 검사 UI

**사용 예시:**
```
Task(subagent_type="designer", model="sonnet",
     prompt=`User Profile 페이지 UI 구현
     - 프로필 표시 (읽기 전용)
     - 편집 모드 토글
     - 폼 검증 표시
     - 로딩/에러 상태`)
```

**병렬 실행 예시:**
```
// Layout 구성: 여러 컴포넌트 동시 구현
Task(subagent_type="designer", ...) # Header 컴포넌트
Task(subagent_type="designer", ...) # Sidebar 컴포넌트
Task(subagent_type="designer", ...) # Footer 컴포넌트
Task(subagent_type="designer", ...) # Modal 컴포넌트

// → 다음 단계: 모든 컴포넌트를 Layout에 통합
```

**특징:**
- 여러 컴포넌트는 병렬 구현 가능
- 복잡한 UI 시스템은 opus 권장
- designer와 implementation-executor 동시 실행 가능 (풀스택)

---

### 4. 검증 및 수정 (Validation & Fixing)

#### deployment-validator (배포 검증자)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` |
| **병렬 가능** | ❌ (순차, 의존성 있음) |
| **실행 시간** | 30-60초 |
| **토큰 비용** | 💰💰 |

**용도:**
- TypeScript 타입 검증 (tsc)
- ESLint 검증
- 빌드 검증
- 전체 프로젝트 통합 테스트
- 의존성 충돌 검사

**사용 예시:**
```
Task(subagent_type="deployment-validator", model="sonnet",
     prompt="typecheck/lint/build 전체 검증")
```

**특징:**
- **반드시 순차 실행** (이전 단계 모두 완료 후)
- 여러 검증을 동시에 수행
- 모든 에러 리포트 및 수정 권고

**워크플로우 예시:**
```
Phase 1: 구현 (병렬)
  - API 구현
  - UI 구현
  - 테스트 작성

Phase 2: 검증 (순차)
  - typecheck/lint/build 검증
  - 모든 에러 확인

Phase 3: 수정 (필요 시)
  - lint-fixer로 자동 수정
```

---

#### lint-fixer (린트 수정자)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` |
| **병렬 가능** | ✅ (도메인별 독립 수정) |
| **실행 시간** | 20-40초 |
| **토큰 비용** | 💰💰 |

**용도:**
- ESLint 에러 자동 수정
- TypeScript 타입 에러 수정
- 코드 포맷팅 문제 해결
- 임포트 정렬 및 정리
- 린트 규칙 위반 해결

**사용 예시:**
```
Task(subagent_type="lint-fixer", model="sonnet",
     prompt="src/ 디렉토리의 모든 ESLint/tsc 에러 수정")
```

**병렬 실행 예시:**
```
// 도메인별 독립 수정
Task(subagent_type="lint-fixer", ...) # src/routes/ 수정
Task(subagent_type="lint-fixer", ...) # src/components/ 수정
Task(subagent_type="lint-fixer", ...) # src/functions/ 수정
```

**특징:**
- deployment-validator 후 사용
- 도메인별 병렬 실행 가능
- 실제 에러만 수정 (린트 규칙 변경 안 함)

---

#### code-reviewer (코드 리뷰어)

| 속성 | 값 |
|------|-----|
| **모델** | `opus` (상세 리뷰) |
| **병렬 가능** | ✅ (관점별 독립 리뷰) |
| **실행 시간** | 30-60초 |
| **토큰 비용** | 💰💰💰 |

**용도:**
- 보안 검토 (injection, CORS, auth 등)
- 성능 검토 (최적화, 병목)
- 코드 품질 리뷰 (가독성, 패턴)
- 아키텍처 검토
- 모범 사례 준수 검증

**사용 예시:**
```
Task(subagent_type="code-reviewer", model="opus",
     prompt="새 인증 로직의 보안 취약점 검토")
```

**병렬 실행 예시:**
```
// 관점별 독립 리뷰 (3개 이상 파일 수정 시 필수)
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 관점 검토")

Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 관점 검토")

Task(subagent_type="code-reviewer", model="opus",
     prompt="코드 품질 관점 검토")
```

**특징:**
- 가장 비용이 높음 (opus)
- 3개 이상 파일 수정 시 권장
- 여러 관점으로 병렬 리뷰 가능

---

### 5. 문서 및 유틸 (Documentation & Utilities)

#### document-writer (문서 작성자)

| 속성 | 값 |
|------|-----|
| **모델** | `haiku` (간단) / `sonnet` (복잡) |
| **병렬 가능** | ✅ (독립적 섹션) |
| **실행 시간** | 15-45초 |
| **토큰 비용** | 💰 (haiku) / 💰💰 (sonnet) |

**용도:**
- README 작성 및 업데이트
- API 문서 생성
- 코드 주석 작성
- 아키텍처 문서
- 마이그레이션 가이드
- 사용자 가이드

**사용 예시:**
```
Task(subagent_type="document-writer", model="sonnet",
     prompt="User API 문서 작성 (마크다운)")
```

**병렬 실행 예시:**
```
// 여러 섹션 동시 작성
Task(subagent_type="document-writer", model="haiku",
     prompt="설치 가이드 섹션 작성")

Task(subagent_type="document-writer", model="haiku",
     prompt="API 엔드포인트 문서 작성")

Task(subagent_type="document-writer", model="haiku",
     prompt="트러블슈팅 가이드 작성")
```

**특징:**
- haiku로도 충분한 경우 많음 (비용 절감)
- 여러 섹션은 병렬 작성 가능
- 상태 문서화에도 활용 가능

---

#### ko-to-en-translator (한글-영문 번역자)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` |
| **병렬 가능** | ✅ (독립적 문장/섹션) |
| **실행 시간** | 10-20초 |
| **토큰 비용** | 💰💰 |

**용도:**
- Git 커밋 메시지 번역 (한글 → 영문)
- 코드 주석 번역
- 문서 번역
- PR 설명 번역

**사용 예시:**
```
Task(subagent_type="ko-to-en-translator", model="sonnet",
     prompt="다음 커밋 메시지를 영문으로 번역:
     '사용자 프로필 편집 기능 추가'")
→ "feat: add user profile edit feature"
```

**병렬 실행 예시:**
```
// 여러 커밋 메시지 동시 번역
Task(subagent_type="ko-to-en-translator", ...)
Task(subagent_type="ko-to-en-translator", ...)
Task(subagent_type="ko-to-en-translator", ...)
```

**특징:**
- Git 커밋 메시지 번역에 특화
- 많은 메시지는 배치로 처리 가능

---

### 6. Git 및 배포 (Git & Deployment)

#### git-operator (Git 운영자)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` |
| **병렬 가능** | ❌ (순차, Git 충돌 방지) |
| **실행 시간** | 10-30초 |
| **토큰 비용** | 💰💰 |

**용도:**
- 브랜치 생성/삭제
- 커밋 작성 및 푸시
- Merge 및 충돌 해결
- 태그 관리
- 히스토리 정리

**사용 예시:**
```
Task(subagent_type="git-operator", model="sonnet",
     prompt="현재 변경사항 커밋: 'feat: add user profile edit'")
```

**특징:**
- **반드시 순차 실행** (Git 충돌 방지)
- 모든 변경사항이 완료된 후 사용
- deployment-validator 검증 후 실행 권장

**워크플로우 예시:**
```
1. 구현 및 테스트 완료
2. deployment-validator로 검증
3. code-reviewer로 리뷰
4. git-operator로 커밋 및 푸시
```

---

#### dependency-manager (의존성 관리자)

| 속성 | 값 |
|------|-----|
| **모델** | `sonnet` |
| **병렬 가능** | ❌ (순차, 의존성 해결) |
| **실행 시간** | 20-60초 |
| **토큰 비용** | 💰💰 |

**용도:**
- package.json 의존성 추가/제거
- 의존성 버전 업데이트
- 충돌 해결
- 보안 업데이트
- 의존성 최적화

**사용 예시:**
```
Task(subagent_type="dependency-manager", model="sonnet",
     prompt="Prisma 7.x로 업데이트하고 필요한 타입 정의 추가")
```

**특징:**
- **반드시 순차 실행** (의존성 충돌 방지)
- 대규모 의존성 변경은 전문 검토 필요
- 업데이트 후 deployment-validator 필수

**워크플로우:**
```
1. 의존성 추가/업데이트 (dependency-manager)
2. 필요한 파일 수정 (implementation-executor)
3. 전체 검증 (deployment-validator)
```

---

### 7. 고급 (Advanced)

#### refactor-advisor (리팩토링 조언자)

| 속성 | 값 |
|------|-----|
| **모델** | `opus` (아키텍처 결정) |
| **병렬 가능** | ❌ (의사결정) |
| **실행 시간** | 30-60초 |
| **토큰 비용** | 💰💰💰 |

**용도:**
- 대규모 리팩토링 전략 수립
- 코드 구조 개선 방안 제안
- 디자인 패턴 개선
- 기술 부채 제거 계획
- 성능 최적화 전략

**사용 예시:**
```
refactor-advisor: "서버 함수 구조 리팩토링 전략"
→ 출력: 상세 전략 및 단계별 계획
```

**특징:**
- planner, architect와 유사하게 의사결정 기반
- 구체적인 리팩토링 계획 제공
- 나머지 에이전트 실행 지침 포함

---

## 에이전트 조정 패턴

> **참고:** 상세한 조정 패턴은 `@.claude/PARALLEL_AGENTS.md`의 `<coordination_patterns>` 섹션 참조.

### 주요 패턴

| 패턴 | 설명 | 사용 시기 |
|------|------|----------|
| **병렬 실행** | 독립적인 작업 동시 실행 | 3-10개 독립 작업 |
| **순차 파이프라인** | 단계별 의존성 처리 | 단계 간 결과 의존성 |
| **라우터** | 중앙 에이전트가 분배 | 복잡한 요청 자동 분해 |
| **Fan-Out/Fan-In** | 작업 분산 → 결과 수집 | 여러 컴포넌트 구현 |
| **계층적 위임** | 메인 에이전트가 계획, 서브가 실행 | 대규모 프로젝트 |
| **배치 처리** | 유사 작업 묶음 처리 | 10개 이상 유사 작업 |

### 빠른 참조

**병렬 실행 가능 (독립적):**
- explore, analyst, lint-fixer, code-reviewer, document-writer, ko-to-en-translator
- implementation-executor (모듈별), designer (컴포넌트별)

**순차 실행 필수 (의존성):**
- planner (조정자), architect (의사결정), deployment-validator (최종 검증)
- git-operator (충돌 방지), dependency-manager (버전 해결)

---

## 실전 워크플로우

### 워크플로우 1: 풀스택 기능 구현

```
Phase 1: 탐색 (병렬, 10-30초)
  Task(explore): 프로젝트 구조 분석
  Task(explore): 기존 API 패턴 찾기
  Task(explore): 기존 UI 컴포넌트 분석

Phase 2: 구현 (병렬, 60-120초)
  Task(implementation-executor): API 엔드포인트 구현
  Task(designer): UI 컴포넌트 구현
  Task(implementation-executor): 테스트 코드 작성

Phase 3: 검증 (순차, 30-60초)
  Task(deployment-validator): 전체 검증

Phase 4: 수정 (필요 시)
  Task(lint-fixer): 린트 에러 수정

Phase 5: 리뷰 (병렬, 30-60초)
  Task(code-reviewer): 보안 검토
  Task(code-reviewer): 성능 검토

Phase 6: 커밋 (순차, 10-30초)
  Task(git-operator): 커밋 및 푸시
```

**예상 시간:** 순차(300초) → 병렬(150초) = **2배 향상**

---

### 워크플로우 2: 대규모 리팩토링

```
Phase 1: 계획 (30-60초)
  Task(planner): 리팩토링 계획 수립
  또는
  Task(refactor-advisor): 리팩토링 전략 수립

Phase 2: 배치 구현 (60초)
  Task(implementation-executor): 10개+ 파일 동일 패턴으로 리팩토링

Phase 3: 검증 및 수정 (병렬, 30-60초)
  Task(deployment-validator): 전체 검증
  Task(lint-fixer): 린트 에러 수정

Phase 4: 리뷰 (병렬, 30-60초)
  Task(code-reviewer): 코드 품질 리뷰

Phase 5: 커밋 (10-30초)
  Task(git-operator): 커밋
```

**토큰 절감:** 배치 처리로 70-90% 절감 (개별 처리 대비)

---

### 워크플로우 3: 시스템 아키텍처 변경

```
Phase 1: 아키텍처 결정 (60-120초)
  Task(architect): 마이크로서비스 아키텍처 설계
  또는
  Task(planner): 아키텍처 변경 계획

Phase 2: 병렬 모듈 구현 (120-180초)
  Task(implementation-executor): Module A 구현
  Task(implementation-executor): Module B 구현
  Task(implementation-executor): Module C 구현

Phase 3: 통합 테스트 (30-60초)
  Task(implementation-executor): 통합 테스트 작성

Phase 4: 전체 검증 (30-60초)
  Task(deployment-validator): 검증

Phase 5: 복합 리뷰 (병렬, 60초)
  Task(code-reviewer): 아키텍처 검토
  Task(code-reviewer): 보안 검토
  Task(code-reviewer): 성능 검토

Phase 6: 문서 작성 (병렬, 30-45초)
  Task(document-writer): 아키텍처 문서
  Task(document-writer): 마이그레이션 가이드

Phase 7: 커밋 (10-30초)
  Task(git-operator): 커밋
```

---

## 모델 라우팅 결정 트리

```
작업 분석
├─ 간단 (파일 읽기, 정의 조회)
│  └─ haiku 사용 (빠르고 저렴)
│     • explore
│     • document-writer (간단 주석)
│     • ko-to-en-translator (짧은 문장)
│
├─ 보통 (기능 구현, 버그 수정, 리팩토링)
│  └─ sonnet 사용 (균형잡힌 선택)
│     • implementation-executor
│     • designer (일반 UI)
│     • analyst
│     • lint-fixer
│     • deployment-validator
│     • git-operator
│     • dependency-manager
│
└─ 복잡 (아키텍처 설계, 보안 검토, 성능 최적화)
   └─ opus 사용 (높은 품질 필요)
      • planner
      • architect
      • code-reviewer
      • refactor-advisor
      • designer (복잡한 UI 시스템)
```

---

## 에이전트 선택 체크리스트

작업 진행 전 다음을 확인하세요:

### 1. 작업 특성 파악

- [ ] 작업이 **독립적**인가? (병렬 가능)
- [ ] 이전 작업의 **결과 필요**한가? (순차)
- [ ] **유사한 작업 10개+**인가? (배치)

### 2. 에이전트 선택

- [ ] 적절한 에이전트 찾기 (위 카테고리 참조)
- [ ] 모델 확인 (haiku/sonnet/opus)
- [ ] 병렬 호환성 확인 (✅/❌)

### 3. 실행 계획

- [ ] 독립 작업 → 병렬 실행 (단일 메시지)
- [ ] 의존 작업 → 순차 실행
- [ ] 유사 작업 → 배치 처리
- [ ] 컨텍스트 공유 계획 (필요시)

### 4. 검증 계획

- [ ] deployment-validator 필수 여부 확인
- [ ] code-reviewer 필수 여부 확인 (3개+ 파일)
- [ ] git-operator로 최종 커밋 계획

---

## 참고 자료

**관련 문서:**
- `.claude/PARALLEL_AGENTS.md` - 병렬 실행 상세 가이드
- `.claude/instructions/parallel-agent-execution.md` - 병렬 실행 상세 지침
- `.claude/agents/*.md` - 개별 에이전트 스펙 (20개 참고 자료)

**각 에이전트별 상세 문서:**
- `.claude/agents/planning/planner.md`
- `.claude/agents/planning/analyst.md`
- `.claude/agents/planning/architect.md`
- `.claude/agents/implementation/explore.md`
- `.claude/agents/implementation/implementation-executor.md`
- `.claude/agents/implementation/designer.md`
- `.claude/agents/quality/deployment-validator.md`
- `.claude/agents/quality/lint-fixer.md`
- `.claude/agents/quality/code-reviewer.md`
- `.claude/agents/documentation/document-writer.md`
- `.claude/agents/documentation/ko-to-en-translator.md`
- `.claude/agents/operations/git-operator.md`
- `.claude/agents/operations/dependency-manager.md`
- `.claude/agents/quality/refactor-advisor.md`

---

## 요약

**전문가의 선택:**

| 상황 | 에이전트 | 모델 |
|------|----------|------|
| 코드 탐색 필요 | explore | haiku |
| 기능 구현 | implementation-executor | sonnet |
| UI/UX 구현 | designer | sonnet |
| 데이터 분석 | analyst | sonnet |
| 문서 작성 | document-writer | haiku/sonnet |
| 검증 필요 | deployment-validator | sonnet |
| 에러 수정 | lint-fixer | sonnet |
| 코드 리뷰 | code-reviewer | opus |
| 계획 수립 | planner | opus |
| 아키텍처 설계 | architect | opus |
| 리팩토링 전략 | refactor-advisor | opus |
| 번역 필요 | ko-to-en-translator | sonnet |
| Git 작업 | git-operator | sonnet |
| 의존성 관리 | dependency-manager | sonnet |

**핵심 원칙:**
1. **작업 분석** → 특성 파악 (독립/의존/유사)
2. **에이전트 선택** → 전문 에이전트 위임
3. **병렬 실행** → 독립 작업 동시 처리
4. **모델 라우팅** → 복잡도별 선택
5. **검증 완료** → 배포 전 필수

---

**Last Updated:** 2026-01-24
