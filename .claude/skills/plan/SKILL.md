---
name: plan
description: 개발 진행 방법 검토 및 옵션 제시
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/sourcing/reliable-search.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Plan Skill

> 개발 진행 방법 검토 및 옵션 제시

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **새 기능 추가** | 인증 시스템, 실시간 알림, 결제 모듈 |
| **아키텍처 변경** | 상태 관리 전환, DB 마이그레이션, 모노레포 전환 |
| **리팩토링** | 코드 구조 개선, 타입 전환, 모듈 분리 |
| **기술 선택** | 라이브러리 비교, 프레임워크 선정 |
| **문제 해결** | 성능 개선, 버그 수정 전략 |

## 호출 방법

```bash
# 직접 처리 (명확한 범위)
/plan 사용자 프로필 편집 기능 추가

# planner agent 위임 (복잡한 경우)
Task({
  subagent_type: 'planner',
  model: 'opus',
  description: '인증 시스템 재설계 계획',
  prompt: 'JWT를 세션 기반으로 전환'
})
```

## 결과물

- 2-3개 옵션 제시 (장단점, 영향 범위)
- 추천안 및 근거
- 선택 후 `.claude/plan/00.[기능명]/` 폴더에 여러 문서 자동 생성
  - OVERVIEW.md, OPTIONS.md, IMPLEMENTATION.md, RISKS.md, REFERENCES.md

</when_to_use>

---

<parallel_agent_execution>

## 병렬 Agent 실행

### Recommended Agents

| Agent | Model | 용도 | 복잡도 |
|-------|-------|------|--------|
| **@planner** | opus | 계획 수립, 체계적 분석 | HIGH |
| **@explore** | haiku/sonnet | 코드베이스 탐색, 구조 파악 | LOW-MEDIUM |
| **@architect** | sonnet/opus | 아키텍처 분석, 설계 검토 (READ-ONLY) | MEDIUM-HIGH |
| **@analyst** | sonnet | 요구사항 분석, 기술 조사, 가정 검증 | MEDIUM |
| **@critic** | opus | 계획 리뷰, OKAY/REJECT 판정 | HIGH |
| **@researcher** | sonnet | 외부 문서/API/라이브러리 조사 | MEDIUM |
| **@scientist** | sonnet | 데이터 분석 프로젝트 계획, 통계 연구 | MEDIUM |

---

### Parallel Execution Patterns

### Read 도구 병렬화

**프로젝트 분석 시 파일 병렬 읽기:**

```typescript
// ❌ 순차 읽기 (느림)
Read({ file_path: "src/file1.ts" })
// 대기...
Read({ file_path: "src/file2.ts" })

// ✅ 병렬 읽기 (빠름)
Read({ file_path: "src/file1.ts" })
Read({ file_path: "src/file2.ts" })
Read({ file_path: "src/file3.ts" })
Read({ file_path: "docs/api.md" })
```

**복잡한 탐색은 explore 에이전트 활용:**

```typescript
// 여러 영역 동시 탐색
Task(subagent_type="explore", model="haiku",
     prompt="영역 1 파일 구조 및 패턴 분석")
Task(subagent_type="explore", model="haiku",
     prompt="영역 2 의존성 및 관계 분석")
```

---

**1. 탐색 + 분석 병렬**

복잡한 시스템에서 여러 영역을 동시에 조사할 때 사용:

```typescript
// 프론트엔드 + 백엔드 동시 탐색
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '프론트엔드 인증 UI 및 상태 관리 구조 분석'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '백엔드 인증 API 엔드포인트 및 미들웨어 분석'
})

Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '현재 인증 아키텍처 평가 및 개선점 도출'
})
```

**2. 여러 영역 계획 병렬**

독립적인 모듈/시스템을 각각 계획할 때:

```typescript
// 여러 모듈 리팩토링 계획 동시 수립
Task({
  subagent_type: 'planner',
  model: 'opus',
  prompt: 'User 모듈 리팩토링 상세 계획 수립'
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  prompt: 'Payment 모듈 리팩토링 상세 계획 수립'
})

Task({
  subagent_type: 'planner',
  model: 'sonnet',
  prompt: 'Notification 모듈 리팩토링 상세 계획 수립'
})
```

**3. 조사 병렬화**

기술 스택 선정, 라이브러리 비교 시:

```typescript
// 여러 솔루션 동시 조사
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: 'WebSocket 라이브러리 조사 (Socket.io, ws, uWebSockets)'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: 'SSE 구현 방식 조사 (EventSource, fetch streams)'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: '폴링 방식 조사 (short/long polling 패턴)'
})
```

**4. 다중 대안 병렬 분석**

여러 옵션을 동시에 평가하여 비교:

```typescript
// Option A, B, C를 각각 다른 analyst에게 동시 분석
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'Option A 분석',
  prompt: `
    상태 관리 옵션 A (Zustand) 분석:
    - 학습 곡선, 번들 크기, 성능
    - TanStack Router 통합
    - 장단점, 리스크
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'Option B 분석',
  prompt: `
    상태 관리 옵션 B (Jotai) 분석:
    - 원자적 상태, 리렌더 최적화
    - TanStack Router 통합
    - 장단점, 리스크
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'Option C 분석',
  prompt: `
    상태 관리 옵션 C (Context API) 분석:
    - 빌트인, 별도 의존성 없음
    - 성능 이슈, 최적화 방법
    - 장단점, 리스크
  `
})

// → 결과 비교 후 최적 옵션 추천
```

**5. 기술 스택 조사 동시 실행**

프레임워크, 라이브러리, 인프라를 병렬 조사:

```typescript
// 신규 프로젝트 기술 스택 조사
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '프레임워크 조사',
  prompt: `
    프론트엔드 프레임워크 비교:
    - Next.js, Remix, TanStack Start
    - SSR/SSG 지원, 라우팅, 성능
    - 생태계, 유지보수성
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '데이터베이스 조사',
  prompt: `
    데이터베이스 옵션 비교:
    - PostgreSQL, MySQL, Prisma (ORM)
    - 스키마 설계, 마이그레이션
    - 스케일링, 백업 전략
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '인프라 조사',
  prompt: `
    배포 인프라 비교:
    - Vercel, Cloudflare, AWS
    - CI/CD, 모니터링, 비용
    - 제약사항, 확장성
  `
})

// → 통합 기술 스택 제안
```

**6. 리스크 평가 병렬화**

기술적, 일정, 비용, 인력 리스크를 동시 평가:

```typescript
// 마이그레이션 프로젝트 리스크 평가
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '기술적 리스크',
  prompt: `
    레거시 → 현대 스택 마이그레이션 기술 리스크:
    - 호환성 문제
    - 데이터 마이그레이션
    - 의존성 충돌
  `
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  description: '일정 리스크',
  prompt: `
    마이그레이션 일정 리스크:
    - 병목 구간 예측
    - 불확실성 요소
    - 완충 시간 필요성
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '비용 리스크',
  prompt: `
    마이그레이션 비용 리스크:
    - 인프라 전환 비용
    - 예상 외 비용 요소
    - ROI 분석
  `
})

Task({
  subagent_type: 'planner',
  model: 'sonnet',
  description: '인력 리스크',
  prompt: `
    마이그레이션 인력 리스크:
    - 기술 스택 학습 시간
    - 외부 전문가 필요성
    - 팀 역량 갭
  `
})

// → 종합 리스크 보고서 생성
```

**7. 아키텍처 다이어그램 + 기술 문서 동시 생성**

설계와 문서화를 병렬 처리:

```typescript
// 계획 수립 중 문서화 동시 진행
Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '아키텍처 설계',
  prompt: `
    마이크로서비스 아키텍처 설계:
    - 서비스 분리 전략
    - API Gateway, 인증, DB
    - Mermaid 다이어그램 작성
  `
})

Task({
  subagent_type: 'planner',
  model: 'sonnet',
  description: '기술 문서 초안',
  prompt: `
    기술 문서 초안 작성:
    - 서비스 책임 정의
    - 통신 프로토콜
    - 배포 전략
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '보안 요구사항',
  prompt: `
    보안 요구사항 분석:
    - 인증/인가 방식
    - 데이터 암호화
    - 감사 로그
  `
})

// → 아키텍처 문서 + 다이어그램 + 보안 가이드
```

**8. 다중 관점 검증 (병렬 평가)**

보안, 성능, 확장성, 유지보수성을 동시 검토:

```typescript
// 계획된 접근 방식을 여러 관점에서 평가
Task({
  subagent_type: 'analyst',
  model: 'opus',
  description: '보안 관점 검증',
  prompt: `
    계획된 접근 방식 보안 검증:
    - 인증/인가 취약점
    - 데이터 노출 위험
    - 보안 베스트 프랙티스 준수
  `
})

Task({
  subagent_type: 'analyst',
  model: 'opus',
  description: '성능 관점 검증',
  prompt: `
    계획된 접근 방식 성능 검증:
    - 병목 구간 예측
    - 스케일링 전략
    - 캐싱, 최적화 방안
  `
})

Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '확장성 검증',
  prompt: `
    계획된 접근 방식 확장성 검증:
    - 수평/수직 확장 가능성
    - 모듈화, 느슨한 결합
    - 향후 변경 용이성
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '유지보수성 검증',
  prompt: `
    계획된 접근 방식 유지보수성 검증:
    - 코드 복잡도
    - 테스트 가능성
    - 문서화 전략
  `
})

// → 통합 검증 보고서 생성
```

**패턴 9: 계획 문서 병렬 작성 (Plan 특화)**

옵션 선택 후 여러 문서를 동시에 작성:

```typescript
// 옵션 선택 후 5개 문서 동시 작성
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'OVERVIEW.md 작성',
  prompt: `
    OVERVIEW.md 작성:
    - 개요 (목표, 범위)
    - 현재 상태 분석
    - 선택된 옵션 및 이유
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'OPTIONS.md 작성',
  prompt: `
    OPTIONS.md 작성:
    - 모든 옵션 비교표 (1, 2, 3)
    - 장단점, 영향 범위
    - 추천 옵션 및 근거
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'sonnet',
  description: 'IMPLEMENTATION.md 작성',
  prompt: `
    IMPLEMENTATION.md 작성:
    - 구현 단계 (1단계, 2단계, ...)
    - 각 단계별 작업 체크리스트
    - 변경 파일 목록
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'RISKS.md 작성',
  prompt: `
    RISKS.md 작성:
    - 기술적 리스크
    - 일정 리스크
    - 완화 방안
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'REFERENCES.md 작성',
  prompt: `
    REFERENCES.md 작성:
    - 코드베이스 분석 결과
    - 관련 문서 링크
    - 참고 자료
  `
})

// → 5개 문서 병렬 생성으로 빠르게 계획 문서화
```

**모델 선택:**
- IMPLEMENTATION.md는 복잡하므로 sonnet
- 나머지는 haiku로 충분

---

**패턴 10: 계획 수립 후 검증 (critic)**

계획 완료 후 별도 에이전트로 검증:

```typescript
// ✅ 계획 수립 후 검증
Task({
  subagent_type: 'planner',
  model: 'opus',
  prompt: '인증 시스템 재설계 계획 수립'
})
// 계획 완료 후
Task({
  subagent_type: 'critic',
  model: 'opus',
  prompt: '.claude/plan/00.인증_시스템/IMPLEMENTATION.md 계획 검증 - OKAY/REJECT 판정'
})
```

**패턴 11: 기술 조사 병렬 (researcher, @reliable-search.md 적용)**

외부 문서 조사와 내부 분석을 병렬 실행:

```typescript
// ✅ 기술 조사 + 내부 분석 병렬 (현재 연도 포함, 출처 등급 분류)
Task({
  subagent_type: 'researcher',
  model: 'sonnet',
  prompt: 'WebSocket vs SSE 공식 문서 및 성능 비교 2026. 검색 시 현재 연도 포함. 출처: URL + 발행일 + 소스유형(공식/블로그/커뮤니티). 핵심 주장 2개+ 소스 교차 검증.'
})
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: '현재 프로젝트에서 실시간 통신 요구사항 분석'
})
```

---

### Model Routing

| 복잡도 | 조건 | 권장 Model | Agent | 예시 |
|--------|------|-----------|-------|------|
| **LOW** | 단순 탐색, 파일 목록 | haiku | explore | 파일 구조 파악, 간단한 조사 |
| **MEDIUM** | 일반 분석, 기술 조사 | sonnet | analyst, planner | 요구사항 분석, 옵션 비교 |
| **HIGH** | 복잡한 설계, 아키텍처 | opus | planner, architect | 시스템 재설계, 아키텍처 결정 |

**Model 선택 가이드:**

```text
✅ haiku:
   - 빠른 탐색, 파일 목록, 구조 파악
   - 간단한 조사, 문서 초안
   - 병렬 실행 시 비용 최적화

✅ sonnet:
   - 일반 분석, 코드 리뷰, 패턴 도출
   - 요구사항 분석, 기술 조사
   - 옵션 비교, 리스크 평가
   - 균형잡힌 품질/비용

✅ opus:
   - 복잡한 설계, 아키텍처 결정
   - 체계적 계획, 전략 수립
   - 다중 관점 검증 (보안, 성능)
   - 최고 품질 필요 시
```

**Agent별 모델 추천:**

| Agent | 기본 모델 | 복잡한 경우 | 이유 |
|-------|----------|------------|------|
| **explore** | haiku | sonnet | 탐색은 빠르게, 복잡한 분석은 sonnet |
| **analyst** | sonnet | opus | 일반 조사는 sonnet, 전략적 결정은 opus |
| **planner** | opus | opus | 계획은 항상 고품질 |
| **architect** | sonnet | opus | 일반 분석은 sonnet, 설계는 opus |
| **critic** | opus | opus | 계획 검증은 높은 품질 필요 |
| **researcher** | sonnet | sonnet | 외부 조사는 sonnet으로 충분 |

---

### Practical Examples

**예시 1: 인증 시스템 재설계 (탐색 + 아키텍처 병렬)**

```typescript
// 1단계: 현재 상태 탐색 (병렬)
Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: '인증 UI 분석',
  prompt: '로그인/회원가입 UI, 폼 검증, 에러 처리 분석'
})

Task({
  subagent_type: 'explore',
  model: 'sonnet',
  description: '인증 API 분석',
  prompt: 'API 엔드포인트, 미들웨어, 토큰 관리 방식 분석'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: 'DB 스키마 분석',
  prompt: 'User 테이블, 세션 테이블, 관계 분석'
})

// 2단계: 요구사항 및 아키텍처 분석 (병렬)
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '요구사항 분석',
  prompt: `
    인증 시스템 요구사항 분석:
    - 가정 검증 (소셜 로그인, 2FA, 비밀번호 재설정)
    - 엣지 케이스 (세션 만료, 동시 로그인)
    - 보안 요구사항
  `
})

Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '인증 아키텍처 평가',
  prompt: `
    탐색 결과 기반으로:
    1. 현재 아키텍처 문제점 도출
    2. 개선 방향 제시
    3. 마이그레이션 전략 수립
  `
})

// → 결과 취합 후 옵션 제시
```

**예시 2: 여러 모듈 리팩토링 계획 (계획 병렬)**

```typescript
// 독립적인 모듈들을 동시에 계획
Task({
  subagent_type: 'planner',
  model: 'opus',
  description: 'User 모듈 계획',
  prompt: `
    User 모듈 리팩토링:
    - 복잡도 감소
    - 타입 안정성 향상
    - 테스트 커버리지 증대
  `
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  description: 'Payment 모듈 계획',
  prompt: `
    Payment 모듈 리팩토링:
    - 트랜잭션 안정성
    - 에러 핸들링 개선
    - 로깅 강화
  `
})

Task({
  subagent_type: 'planner',
  model: 'sonnet',
  description: 'Notification 모듈 계획',
  prompt: `
    Notification 모듈 리팩토링:
    - 템플릿 구조화
    - 다국어 지원
    - 전송 실패 재시도
  `
})

// → 각 모듈별 .claude/plan/00.User_모듈/, 01.Payment_모듈/ 문서 생성
```

**예시 3: 실시간 기능 기술 조사 (조사 병렬)**

```typescript
// 여러 기술 스택 동시 조사
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'WebSocket 조사',
  prompt: `
    WebSocket 구현 조사:
    - Socket.io vs ws vs uWebSockets
    - 스케일링 방안
    - 장단점 분석
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'SSE 조사',
  prompt: `
    Server-Sent Events 조사:
    - 브라우저 호환성
    - 재연결 처리
    - 제약사항
  `
})

Task({
  subagent_type: 'analyst',
  model: 'haiku',
  description: '폴링 조사',
  prompt: `
    폴링 방식 조사:
    - Short vs Long polling
    - 리소스 사용량
    - 적용 시나리오
  `
})

// → 결과 비교 후 기술 스택 추천
```

**예시 4: 신규 프로젝트 계획 (기술 스택 + 아키텍처 병렬)**

```typescript
// 신규 프로젝트 초기 계획 수립
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '요구사항 분석',
  prompt: `
    신규 프로젝트 요구사항 분석:
    - 핵심 기능 정의
    - 비기능 요구사항 (성능, 보안, 확장성)
    - 제약사항 및 우선순위
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '기술 스택 조사',
  prompt: `
    기술 스택 비교 분석:
    - 프론트엔드 (React 기반 프레임워크)
    - 백엔드 (Node.js vs Python)
    - 데이터베이스 (SQL vs NoSQL)
    - 인프라 (클라우드 옵션)
  `
})

Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '아키텍처 설계',
  prompt: `
    시스템 아키텍처 초안:
    - 레이어 분리 전략
    - API 설계 원칙
    - 데이터 흐름
    - Mermaid 다이어그램
  `
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  description: '프로젝트 일정 수립',
  prompt: `
    프로젝트 일정 계획:
    - MVP 범위 정의
    - 단계별 마일스톤
    - 리스크 및 완충 시간
  `
})

// → 종합 프로젝트 계획서 생성
```

**예시 5: 레거시 마이그레이션 (리스크 평가 + 전략 수립)**

```typescript
// 레거시 시스템 → 현대 스택 마이그레이션 계획
Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: '레거시 구조 분석',
  prompt: '레거시 시스템 구조, 의존성, 기술 스택 파악'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '기술적 리스크',
  prompt: `
    마이그레이션 기술 리스크:
    - 호환성 문제
    - 데이터 무결성
    - 의존성 충돌
  `
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  description: '일정 리스크',
  prompt: `
    마이그레이션 일정 리스크:
    - 병목 구간
    - 예상 외 지연 요인
    - 완충 시간 확보
  `
})

Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '마이그레이션 전략',
  prompt: `
    단계적 마이그레이션 전략:
    - Strangler Fig 패턴
    - 점진적 전환 계획
    - 롤백 시나리오
  `
})

// → 마이그레이션 로드맵 생성
```

**예시 6: 성능 최적화 계획 (다중 관점 분석)**

```typescript
// 성능 문제 분석 및 개선 계획
Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: '성능 병목 탐색',
  prompt: '느린 페이지, API 엔드포인트, DB 쿼리 식별'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '프론트엔드 성능',
  prompt: `
    프론트엔드 성능 분석:
    - 번들 크기, 불필요한 리렌더
    - 이미지 최적화, 코드 스플리팅
    - 개선 방안
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '백엔드 성능',
  prompt: `
    백엔드 성능 분석:
    - DB 쿼리 최적화 (N+1 문제)
    - 캐싱 전략
    - API 응답 시간 개선
  `
})

Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '인프라 최적화',
  prompt: `
    인프라 최적화 전략:
    - CDN, 로드 밸런싱
    - 스케일링 전략
    - 모니터링 및 알림
  `
})

// → 통합 성능 최적화 계획
```

**예시 7: 보안 강화 계획 (다중 관점 검증)**

```typescript
// 보안 취약점 분석 및 강화 계획
Task({
  subagent_type: 'analyst',
  model: 'opus',
  description: '인증/인가 보안',
  prompt: `
    인증/인가 보안 검토:
    - 세션 관리 취약점
    - 권한 상승 위험
    - 개선 방안
  `
})

Task({
  subagent_type: 'analyst',
  model: 'opus',
  description: 'API 보안',
  prompt: `
    API 보안 검토:
    - SQL Injection, XSS, CSRF
    - 입력 검증, 출력 인코딩
    - Rate Limiting
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: '데이터 보안',
  prompt: `
    데이터 보안 검토:
    - 민감 정보 암호화
    - 접근 제어, 감사 로그
    - GDPR 준수
  `
})

Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '인프라 보안',
  prompt: `
    인프라 보안 검토:
    - 네트워크 분리, 방화벽
    - 의존성 취약점 스캔
    - 모니터링 및 경고
  `
})

// → 보안 강화 로드맵 생성
```

**예시 8: 대규모 리팩토링 (모듈별 병렬 계획)**

```typescript
// 여러 모듈을 동시에 분석하고 계획 수립
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'User 모듈 분석',
  prompt: `
    User 모듈 현황 분석:
    - 복잡도, 의존성
    - 테스트 커버리지
    - 리팩토링 우선순위
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'Payment 모듈 분석',
  prompt: `
    Payment 모듈 현황 분석:
    - 트랜잭션 안정성
    - 에러 핸들링 품질
    - 개선 필요 항목
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'Notification 모듈 분석',
  prompt: `
    Notification 모듈 현황 분석:
    - 템플릿 구조
    - 다국어 지원 현황
    - 개선 필요 항목
  `
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  description: '통합 리팩토링 계획',
  prompt: `
    모듈별 분석 결과 기반 통합 계획:
    - 우선순위 및 일정
    - 의존성 관리
    - 단계별 마일스톤
  `
})

// → 모듈별 리팩토링 계획 + 통합 로드맵
```

---

### 병렬 실행 시 고려사항

```text
✅ DO:
   - 독립적인 작업만 병렬 실행 (의존성 없는 경우)
   - 결과 취합 후 통합 분석 수행
   - 모델 선택 시 복잡도 고려 (haiku/sonnet/opus)
   - 병렬 실행 수는 3-5개 권장 (너무 많으면 복잡)
   - 각 에이전트에게 명확한 범위 전달
   - 다중 관점 검증 시 병렬 활용 (보안/성능/확장성)
   - 기술 스택 조사 시 병렬 조사 후 비교

❌ DON'T:
   - 순차 의존성이 있는 작업 병렬화 금지
   - 결과 취합 없이 개별 결과만 사용
   - 모든 작업에 opus 사용 (비용/시간 낭비)
   - 병렬 실행 수 너무 많음 (5개 초과)
   - 같은 영역을 중복 분석
```

---

### 병렬 에이전트 체크리스트

계획 수립 전 확인:

```text
✅ 탐색 단계
   [ ] 여러 영역 동시 탐색 가능? → explore (haiku) 병렬 실행
   [ ] 요구사항 불명확? → analyst (sonnet) 병렬 분석

✅ 분석 단계
   [ ] 다중 옵션 비교 필요? → analyst (sonnet) 병렬 평가
   [ ] 기술 스택 조사 필요? → analyst (sonnet) 병렬 조사
   [ ] 리스크 평가 필요? → analyst + planner 병렬 평가

✅ 설계 단계
   [ ] 아키텍처 + 문서화? → architect + planner 병렬
   [ ] 여러 모듈 설계? → planner (opus) 병렬 수립

✅ 검증 단계
   [ ] 다중 관점 검증? → analyst/architect (opus) 병렬 검토
   [ ] 보안/성능/확장성 검토? → 각 관점별 병렬 실행

✅ 모델 선택
   [ ] 복잡도 LOW → haiku
   [ ] 복잡도 MEDIUM → sonnet
   [ ] 복잡도 HIGH → opus

✅ 병렬 실행 수
   [ ] 3-5개 권장
   [ ] 독립성 확인
   [ ] 결과 통합 계획
```

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 2. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore/planner) |
| 3. 옵션 도출 | 가능한 접근 4-5개 → 주요 2-3개 선정 | sequentialthinking (2-6단계) |
| 4. 옵션 제시 | 장단점, 영향 범위, 추천안 제시 | - |
| 5. 문서 생성 | 옵션 선택 대기 후 계획 문서 병렬 생성 | Task (document-writer) 병렬 |
| 6. 구현 시작 | 문서 완료 즉시 구현 진행 (확인 불필요) | Skill (execute) |

### Agent 선택 기준

| 복잡도 | 조건 | 사용 Agent |
|--------|------|-----------|
| **매우 복잡** | 다중 시스템, 아키텍처 변경, 불확실성 높음 | Task (planner) 위임 |
| **복잡/보통** | 명확한 범위, 3-10 파일 | 직접 처리 (Task Explore 활용) |
| **간단** | 1-2 파일, 명확한 변경 | 직접 처리 |

### Sequential Thinking 가이드

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 3 | 1-2 파일, 명확한 변경 | 복잡도 판단 → 현재 상태 → 옵션 도출 |
| **보통** | 5 | 3-5 파일, 로직 변경 | 복잡도 판단 → 현재 상태 → 접근 방식 탐색 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 다중 모듈, 아키텍처 변경 | 복잡도 판단 → 심층 분석 → 제약사항 → 접근 방식 → 비교 → 상세 분석 → 추천안 |

</workflow>

---

<state_management>

## 상태 관리 및 문서화

### 폴더 구조

옵션 선택 후 `.claude/plan/00.[기능명]/` 폴더 생성:

```
.claude/plan/00.실시간_알림/
├── OVERVIEW.md        # 개요, 현재 상태, 선택된 옵션
├── OPTIONS.md         # 모든 옵션 비교 분석 (장단점, 영향 범위)
├── IMPLEMENTATION.md  # 구현 단계 상세 계획
├── RISKS.md           # 리스크 및 완화 방안
└── REFERENCES.md      # 참조 자료, 코드베이스 분석 결과
```

**폴더명 형식:** `00.[기능명]` (넘버링 + 한글 설명, 언더스코어로 구분)
**넘버링:** 기존 plans 폴더 목록 조회 → 다음 번호 자동 부여 (00, 01, 02...)

### 문서 역할

| 파일 | 내용 | 담당 에이전트 |
|------|------|--------------|
| **OVERVIEW.md** | 개요 (목표, 범위), 현재 상태 분석, 선택된 옵션 및 이유 | document-writer (haiku) |
| **OPTIONS.md** | 모든 옵션 비교표, 장단점/영향 범위, 추천 옵션 및 근거 | document-writer (haiku) |
| **IMPLEMENTATION.md** | 구현 단계 (1단계, 2단계, ...), 작업 체크리스트, 변경 파일 목록 | document-writer (sonnet) |
| **RISKS.md** | 기술적 리스크, 일정 리스크, 완화 방안 | document-writer (haiku) |
| **REFERENCES.md** | 코드베이스 분석 결과, 관련 문서 링크, 참고 자료 | document-writer (haiku) |

### 문서 작성

**우선순위: document-writer 에이전트 병렬 실행**

| 작업 | 방법 | 모델 |
|------|------|------|
| 5개 문서 동시 생성 | `Task(subagent_type="document-writer", ...)` 병렬 호출 | haiku (4개), sonnet (1개) |
| 복잡한 IMPLEMENTATION.md | `Task(subagent_type="document-writer", model="sonnet", ...)` | sonnet |

**병렬 실행 패턴:**

```typescript
// ✅ 5개 문서 동시 작성 (빠름)
Task(subagent_type="document-writer", model="haiku",
     prompt="OVERVIEW.md 생성: 개요, 현재 상태, 선택된 옵션")
Task(subagent_type="document-writer", model="haiku",
     prompt="OPTIONS.md 생성: 옵션 비교 분석")
Task(subagent_type="document-writer", model="sonnet",
     prompt="IMPLEMENTATION.md 생성: 구현 단계 상세 계획")
Task(subagent_type="document-writer", model="haiku",
     prompt="RISKS.md 생성: 리스크 및 완화 방안")
Task(subagent_type="document-writer", model="haiku",
     prompt="REFERENCES.md 생성: 코드베이스 분석 결과")

// ❌ 순차 실행 (느림)
Write({ file_path: "OVERVIEW.md", ... })  // 대기...
Write({ file_path: "OPTIONS.md", ... })   // 대기...
```

### 문서 템플릿

#### OVERVIEW.md

```markdown
# [기능명] 계획 개요

생성: {{TIMESTAMP}}

## 목표

[무엇을 달성할 것인가]

## 범위

- 포함: [범위 1, 2, 3]
- 제외: [범위 외 항목]

## 현재 상태 분석

### 코드베이스

- 관련 파일: `src/`, `lib/`
- 현재 구조: [설명]

### 제약사항

- 제약 1
- 제약 2

## 선택된 옵션

**옵션 [N]: [옵션 이름]**

**선택 이유:**
1. 이유 1
2. 이유 2
3. 이유 3
```

#### OPTIONS.md

```markdown
# 옵션 비교 분석

## 옵션 1: [옵션 이름] (추천)

**접근 방식:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/auth/`, `src/api/`
- 예상 변경 규모: 중간
- 리스크: 낮음

---

## 옵션 2: [옵션 이름]

[동일 형식]

---

## 옵션 3: [옵션 이름]

[동일 형식]

---

## 추천 및 근거

옵션 [N]을 추천합니다.

**근거:**
1. 근거 1
2. 근거 2
3. 근거 3
```

#### IMPLEMENTATION.md

```markdown
# 구현 단계

## 1단계: [단계 이름]

**작업:**
- [ ] 작업 1
- [ ] 작업 2
- [ ] 작업 3

**변경 파일:**
- `src/file1.ts`: [변경 내용]
- `src/file2.ts`: [변경 내용]

**예상 소요 시간:** [시간]

---

## 2단계: [단계 이름]

**작업:**
- [ ] 작업 4
- [ ] 작업 5

**변경 파일:**
- `src/file3.ts`: [변경 내용]

**예상 소요 시간:** [시간]

---

## 3단계: [단계 이름]

[동일 형식]

---

## 검증 방법

- [ ] 테스트 항목 1
- [ ] 테스트 항목 2
- [ ] 통합 테스트
```

#### RISKS.md

```markdown
# 리스크 및 완화 방안

## 기술적 리스크

| 리스크 | 영향도 | 완화 방안 |
|--------|--------|----------|
| 리스크 1 | 높음 | 방안 1 |
| 리스크 2 | 중간 | 방안 2 |
| 리스크 3 | 낮음 | 방안 3 |

## 일정 리스크

| 리스크 | 영향도 | 완화 방안 |
|--------|--------|----------|
| 병목 구간 1 | 높음 | 완충 시간 확보 |
| 불확실성 1 | 중간 | 프로토타입 검증 |

## 의존성

- 외부 라이브러리: [목록]
- 다른 시스템: [목록]
- 팀 역량: [필요 기술]

## 롤백 계획

문제 발생 시 롤백 방법:
1. 단계 1
2. 단계 2
3. 단계 3
```

#### REFERENCES.md

```markdown
# 참조 자료

## 코드베이스 분석 결과

### 현재 구조

- 파일 1: [분석 내용]
- 파일 2: [분석 내용]

### 패턴 및 규칙

- 패턴 1: [설명]
- 패턴 2: [설명]

## 관련 문서

- [문서 1](링크)
- [문서 2](링크)

## 참고 자료

- 라이브러리 문서: [링크]
- 베스트 프랙티스: [링크]
- 관련 아티클: [링크]

## 탐색 결과

### Explore Agent 1

[탐색 내용 요약]

### Explore Agent 2

[탐색 내용 요약]
```

</state_management>

---

<option_presentation>

## 옵션 제시 형식

### 옵션 3개 제시 (표준)

```markdown
## 분석 결과

### 옵션 1: [옵션 이름] (추천)

**접근 방식:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/auth/`, `src/api/`
- 예상 변경 규모: 중간
- 리스크: 낮음

---

### 옵션 2: [옵션 이름]

**접근 방식:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**영향 범위:**
...

---

### 옵션 3: [옵션 이름]

**접근 방식:**
...

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션을 선택하시겠습니까? (1/2/3)
```

</option_presentation>

---

<document_generation>

## 계획 문서 병렬 생성

사용자가 옵션을 선택하면 `.claude/plan/[기능명]-{timestamp}/` 폴더에 여러 문서를 **병렬로** 생성합니다.

### 병렬 생성 워크플로우

```text
1. 넘버링 결정: ls .claude/plan/ → 다음 번호 자동 부여
2. 폴더 생성: .claude/plan/00.[기능명]/
3. document-writer 에이전트 5개 병렬 호출
   - OVERVIEW.md (haiku)
   - OPTIONS.md (haiku)
   - IMPLEMENTATION.md (sonnet)
   - RISKS.md (haiku)
   - REFERENCES.md (haiku)
4. 모든 에이전트 완료 대기
5. 사용자에게 폴더 경로 안내
6. /execute 스킬 즉시 호출 (확인 불필요)
   - IMPLEMENTATION.md 기반 자동 구현 시작
```

### 에이전트 호출 예시

```typescript
// 옵션 선택 후 실행
// 1. 넘버링 결정
Bash("ls .claude/plan/ | grep -E '^[0-9]+' | wc -l")
const nextNumber = "00" // 결과 기반 계산
const projectName = "실시간_알림"
const basePath = `.claude/plan/${nextNumber}.${projectName}`

// 2. 폴더 생성
Bash(`mkdir -p ${basePath}`)

// 3. 5개 문서 병렬 생성
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'OVERVIEW.md 작성',
  prompt: `
    ${basePath}/OVERVIEW.md 생성:
    - 개요: ${목표}, ${범위}
    - 현재 상태: ${코드베이스_분석}
    - 선택된 옵션: 옵션 ${선택번호}
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'OPTIONS.md 작성',
  prompt: `
    ${basePath}/OPTIONS.md 생성:
    - 옵션 1, 2, 3 비교표
    - 장단점, 영향 범위
    - 추천 근거
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'sonnet',
  description: 'IMPLEMENTATION.md 작성',
  prompt: `
    ${basePath}/IMPLEMENTATION.md 생성:
    - 구현 단계 (1, 2, 3, ...)
    - 작업 체크리스트
    - 변경 파일 목록
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'RISKS.md 작성',
  prompt: `
    ${basePath}/RISKS.md 생성:
    - 기술적 리스크
    - 일정 리스크
    - 완화 방안
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'REFERENCES.md 작성',
  prompt: `
    ${basePath}/REFERENCES.md 생성:
    - 코드베이스 분석 결과
    - 관련 문서 링크
    - Explore 에이전트 결과 요약
  `
})

// → 모든 문서 동시 생성 완료 후 사용자 안내
```

### 문서 템플릿

문서 템플릿은 `<state_management>` 섹션 참조.

</document_generation>

---

<auto_implementation>

## 자동 구현 시작

계획 문서 생성 완료 후 **사용자 확인 없이** 즉시 구현을 시작합니다.

### 워크플로우

```text
1. 계획 문서 병렬 생성 완료
2. IMPLEMENTATION.md 존재 확인
3. /execute 스킬 즉시 호출
4. 1단계부터 순차 구현
```

### 구현 시작 패턴

```typescript
// 문서 생성 완료 후 즉시 실행
Skill({
  skill: 'execute',
  args: `@.claude/plan/${nextNumber}.${projectName}/IMPLEMENTATION.md 1단계부터 구현`
})
```

### 금지 사항

```text
❌ "구현을 시작할까요?" 물어보기
❌ "어떤 방식으로 진행할까요?" 선택지 제시
❌ 사용자 확인 대기
```

### 허용 사항

```text
✅ 문서 생성 완료 즉시 /execute 호출
✅ IMPLEMENTATION.md 1단계부터 자동 시작
✅ 구현 중 문제 발생 시에만 사용자 확인
```

</auto_implementation>

---

<examples>

## 실전 예시

### 예시 1: 인증 시스템 변경 (매우 복잡 - planner agent 위임)

```bash
사용자: /plan 사용자 인증을 JWT에서 세션 기반으로 변경

1. Sequential Thinking (1단계):
   thought 1: "인증 시스템 변경 - 매우 복잡함, 다중 시스템 영향,
              아키텍처 변경. planner agent로 위임하는 것이 적합"

2. planner agent 위임:
   Task({
     subagent_type: 'planner',
     description: '인증 시스템 재설계 계획',
     prompt: 'JWT 기반 인증을 세션 기반으로 전환하는 체계적 계획 수립',
     model: 'opus'
   })

3. planner agent 프로세스:
   - 인터뷰: 요구사항, 제약사항, 리스크 허용도 파악
   - 코드베이스 조사: Explore agent로 현재 구조 분석
   - 계획 생성: .claude/plan/00.세션_인증/
   - 5개 문서 병렬 생성 (OVERVIEW, OPTIONS, IMPLEMENTATION, RISKS, REFERENCES)
   - 사용자 확인 후 핸드오프

→ 복잡한 작업은 planner에게 위임하여 체계적으로 처리
```

### 예시 2: 실시간 알림 기능 (보통)

```bash
사용자: /plan 실시간 알림 기능 추가

1. Sequential Thinking (5단계):
   thought 1: "실시간 알림 - 보통 복잡도, 새 기능 추가"
   thought 2: "현재 통신 구조: REST API, 폴링 없음"
   thought 3: "접근 방식: WebSocket, SSE, Long Polling, Firebase"
   thought 4: "WebSocket이 양방향, SSE는 단방향이지만 간단"
   thought 5: "WebSocket 추천, 폴링은 비효율적"

2. Task 탐색:
   Task (Explore): "현재 API 구조 및 클라이언트 통신 방식"

3. 옵션 제시:
   옵션 1: WebSocket (추천)
   - 장점: 양방향 통신, 실시간성 우수
   - 단점: 복잡도 증가, 인프라 고려

   옵션 2: Server-Sent Events
   - 장점: 구현 단순, HTTP 기반
   - 단점: 단방향만, 브라우저 제한

   옵션 3: Short Polling
   - 장점: 구현 매우 간단
   - 단점: 비효율적, 지연 발생

4. 사용자 선택: 1

5. document-writer 에이전트 5개 병렬 호출로 문서 생성
   - .claude/plan/00.실시간_알림/
     ├── OVERVIEW.md
     ├── OPTIONS.md
     ├── IMPLEMENTATION.md
     ├── RISKS.md
     └── REFERENCES.md

6. 구현 자동 시작:
   Skill({ skill: 'execute' })
   - IMPLEMENTATION.md 읽고 1단계부터 구현
   - 확인 절차 없이 즉시 진행
```

### 예시 3: 간단한 리팩토링

```bash
사용자: /plan utils 함수를 TypeScript로 전환

1. Sequential Thinking (3단계):
   thought 1: "단순 리팩토링 - 간단, 1-2 파일"
   thought 2: "현재 utils.js 분석 필요"
   thought 3: "타입 정의 → 전환 → 테스트 검증"

2. Task 탐색:
   Read: src/utils.js
   Grep: utils 사용처 검색

3. 옵션 제시:
   옵션 A: 점진적 전환 (파일별)
   - 장점: 리스크 낮음
   - 단점: 시간 소요

   옵션 B: 일괄 전환
   - 장점: 깔끔함
   - 단점: 테스트 필요

4. 사용자 선택 → document-writer 에이전트 병렬 호출로 계획 문서 생성
   - .claude/plan/00.타입스크립트_전환/

5. 구현 자동 시작:
   Skill({ skill: 'execute' })
   - 계획 문서 기반 즉시 구현
```

</examples>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드베이스 탐색
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 영향 범위 및 예상 작업량 제시
✅ 넘버링 자동 결정 (ls .claude/plan/)
✅ document-writer 에이전트 병렬 호출로 문서 생성
✅ .claude/plan/00.[기능명]/ 폴더 구조 사용 (한글 설명)
```

절대 금지:

```text
❌ Edit/Write 도구 직접 사용 (문서 작성은 document-writer 에이전트)
❌ Sequential Thinking 3단계 미만
❌ 옵션 1개만 제시
❌ 코드 탐색 없이 추측으로 옵션 제시
❌ 장단점 없이 옵션만 나열
❌ 단일 파일로 문서 생성 (여러 파일로 분리 필수)
❌ 문서 생성 후 "구현을 시작할까요?" 물어보기 (즉시 진행)
```

</validation>
