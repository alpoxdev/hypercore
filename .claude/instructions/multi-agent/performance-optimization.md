# Multi-Agent Performance Optimization

병렬 에이전트 실행을 통한 성능 최적화 가이드.

---

<purpose>

**Goal:** 독립적인 작업을 동시에 처리하여 대기 시간 최소화, 처리량 극대화, 비용 절감.

**Core Principle:** 순차 실행 → 병렬 실행으로 5-15배 성능 향상.

</purpose>

---

<optimization_checklist>

## 최적화 체크리스트

성능 개선을 위한 필수 확인 사항.

- [ ] **독립 작업 식별** - 병렬 실행 가능한 작업 찾기
- [ ] **유사 작업 그룹화** - 10개 이상 유사 작업 배치 처리
- [ ] **장시간 작업 백그라운드 실행** - 10분 이상 작업 비동기 처리
- [ ] **모델 선택 최적화** - 복잡도별 haiku/sonnet/opus 선택
- [ ] **컨텍스트 크기 모니터링** - 토큰 한계 도달 시 컴팩션
- [ ] **재시도 전략 수립** - 실패 시 3회 제한 및 에스컬레이션
- [ ] **상태 문서화** - 컨텍스트 복구 및 핸드오프 준비

### 패턴별 체크

| 패턴 | 확인 항목 |
|------|---------|
| **병렬 실행** | 작업 간 의존성 없음? / 서로 다른 파일? / 결과 독립적? |
| **배치 처리** | 10개 이상 작업? / 공통 컨텍스트? / 순서 무관? |
| **백그라운드** | 10분 이상 소요? / npm install/test/build? |

</optimization_checklist>

---

<performance_metrics>

## 성능 지표 및 타겟

### 핵심 지표

| 지표 | 현황 | 목표 | 측정 방법 |
|------|------|------|----------|
| **대기 시간** | 순차 N * t | 80% 감소 | 시작~완료 시간 |
| **토큰 사용** | 개별 합산 | 70-90% 절감 (배치) | API 로그 분석 |
| **병렬도** | 1 (순차) | 3-10개 | 활성 에이전트 수 |
| **성공률** | 측정 필요 | 95% 이상 | 완료/시도 비율 |
| **비용** | baseline | 30-50% 절감 | 모델별 비용 계산 |

### 성능 계산 예시

**예제 1: 풀스택 기능 (API + UI + 테스트)**

```
순차 실행:
- API 구현: 60초
- UI 구현: 60초
- 테스트: 60초
총 시간: 180초

병렬 실행:
- 동시 진행: 60초 (가장 긴 작업)
개선: 3배 향상 (180초 → 60초)
```

**예제 2: 배치 리팩토링 (10개 파일)**

```
순차 처리:
- 파일별 Edit: 10 * 50초 = 500초
- 컨텍스트 재전송: 10회

배치 처리:
- 단일 Task: 60초
- 컨텍스트 1회: 10개 파일 적용
토큰 절감: 70-90%
```

### 모니터링 지점

| 지점 | 확인 | 목표 |
|------|------|------|
| **시작** | 병렬도 계획 | 3-10개 |
| **진행 중** | 활성 에이전트 수 | 3-10개 유지 |
| **완료** | 총 시간 vs 목표 | 80% 이상 개선 |
| **토큰** | 사용량 추이 | 배치 적용 시 70-90% 절감 |

</performance_metrics>

---

<anti_patterns>

## 안티패턴 (Anti-Patterns)

성능을 해치는 잘못된 패턴 및 올바른 대안.

### 안티패턴 테이블

| 안티패턴 | 문제점 | 영향 | 올바른 방법 |
|---------|-------|------|----------|
| **순차 실행** | 불필요한 대기 시간 발생 | 성능 80% 하락 | 독립 작업 병렬 실행 |
| **과도한 병렬** | 컨텍스트 혼란, 리소스 고갈 | 에러 증가, 비용 상승 | 3-10개 제한, 배치 사용 |
| **모델 미스매치** | 과도한 비용, 느린 응답 | 비용 2-3배 상승 | haiku(간단), sonnet(일반), opus(복잡) |
| **컨텍스트 미보존** | 병렬 실행 시 상태 손실 | 작업 중복, 에러 | 상태 문서화, 핸드오프 |
| **무한 재시도** | 리소스 낭비, 무한 루프 | 대기 시간 증가 | 3회 제한 + 에스컬레이션 |
| **배치 미사용** | 토큰 낭비 (10개+ 유사 작업) | 비용 10배 | 배치 처리로 70-90% 절감 |
| **백그라운드 미활용** | 오래 걸리는 작업 대기 | 불필요한 대기 | npm install/test는 백그라운드 |

### 예시: 안티패턴 vs 올바른 방법

#### ❌ 안티패턴 1: 순차 실행

```typescript
// 총 시간: 180초
Task(subagent_type="implementation-executor", prompt="기능 A")
// 대기 60초...
Task(subagent_type="implementation-executor", prompt="기능 B")
// 대기 60초...
Task(subagent_type="implementation-executor", prompt="기능 C")
// 대기 60초...
```

#### ✅ 올바른 방법: 병렬 실행

```typescript
// 총 시간: 60초 (3배 향상)
Task(subagent_type="implementation-executor", prompt="기능 A")
Task(subagent_type="implementation-executor", prompt="기능 B")
Task(subagent_type="implementation-executor", prompt="기능 C")
```

---

#### ❌ 안티패턴 2: 과도한 병렬

```typescript
// 50개 동시 실행 → 컨텍스트 혼란, 에러 증가
for (let i = 0; i < 50; i++) {
  Task(subagent_type="implementation-executor", prompt=`작업 ${i}`)
}
```

#### ✅ 올바른 방법: 배치 제한

```typescript
// 방법 1: 3-10개 제한
Task(subagent_type="implementation-executor", prompt="작업 1")
Task(subagent_type="implementation-executor", prompt="작업 2")
Task(subagent_type="implementation-executor", prompt="작업 3")

// 방법 2: 배치 처리 (50개)
Task(subagent_type="implementation-executor",
     prompt="다음 50개 작업 일괄 처리: [작업 목록]")
```

---

#### ❌ 안티패턴 3: 모델 미스매치

```typescript
// 비용 낭비: 간단한 작업에 opus 사용
Task(subagent_type="explore", model="opus",  // 비용 많음
     prompt="파일 구조 탐색")

Task(subagent_type="code-reviewer", model="haiku",  // 품질 낮음
     prompt="복잡한 아키텍처 리뷰")
```

#### ✅ 올바른 방법: 복잡도별 선택

```typescript
// 복잡도 낮음 → haiku
Task(subagent_type="explore", model="haiku",
     prompt="파일 구조 탐색")

// 복잡도 높음 → opus
Task(subagent_type="code-reviewer", model="opus",
     prompt="복잡한 아키텍처 리뷰")
```

---

#### ❌ 안티패턴 4: 컨텍스트 미보존

```typescript
// 병렬 실행 시 상태 손실
Task(subagent_type="implementation-executor",
     prompt="모듈 A 구현")
Task(subagent_type="implementation-executor",
     prompt="모듈 B 구현")
// → B가 A 존재 모르고 중복 작업
```

#### ✅ 올바른 방법: 상태 문서화

```typescript
// 공유 상태 명시
Task(subagent_type="implementation-executor",
     prompt=`모듈 A 구현

     공유 상태:
     - 프로젝트 구조: [설명]
     - 공통 인터페이스: [경로]`)

Task(subagent_type="implementation-executor",
     prompt=`모듈 B 구현 (모듈 A 통합)

     공유 상태:
     - 모듈 A 위치: src/modules/a.ts
     - 인터페이스: [경로]`)
```

</anti_patterns>

---

<monitoring_strategies>

## 모니터링 전략

병렬 실행 및 배치 처리 효과를 실시간 추적.

### 모니터링 지표

| 지표 | 수집 방법 | 분석 방법 | 액션 트리거 |
|------|---------|---------|----------|
| **병렬도** | 활성 에이전트 수 | 최대/평균 계산 | < 3개: 병렬 부족 / > 10개: 과도 |
| **응답 시간** | 작업 시작~종료 | 분포 분석 | > 5분: 백그라운드 고려 |
| **토큰 사용** | API 로그 | 배치vs개별 비교 | 10배 차이: 배치 적용 |
| **성공률** | 완료/시도 비율 | 에이전트별/패턴별 | < 90%: 재시도 전략 검토 |
| **에러 패턴** | 로그 파일 분석 | 빈도/유형 분류 | > 3회 반복: 에스컬레이션 |

### 모니터링 구현

#### 1. 실시간 대시보드 (간단)

```markdown
# 작업 모니터링

## 현재 상태
- 활성 에이전트: 5/10
- 평균 응답 시간: 45초
- 토큰 사용: 150K/200K
- 성공률: 94%

## 최근 작업
| 작업 | 상태 | 시간 | 토큰 |
|------|------|------|------|
| API 구현 | DONE | 60s | 25K |
| UI 구현 | IN_PROGRESS | 40s | 20K |

## 경고
- ⚠️ 토큰 사용 75% 도달
- ✅ 병렬도 정상 범위
```

#### 2. 로그 기반 모니터링

```typescript
// 작업 로그 기록
Write(".claude/logs/performance.md", `
## Performance Log - ${timestamp}

### 배치 작업
- 파일 수: 10
- 전체 시간: 60초
- 예상 순차 시간: 500초
- 개선율: 89%
- 토큰 절감: 75%

### 병렬 작업
- 동시 작업: 5개
- 완료 시간: 60초 (최대)
- 병렬도: 우수

### 에러
- 재시도: 1회 (성공)
- 실패율: 0%
`)
```

#### 3. 성능 추적 메트릭

```typescript
// 성능 추적 구조
const performanceMetrics = {
  parallel: {
    activeAgents: 5,
    avgResponseTime: 45,
    totalTime: 180,
    sequential_equivalent: 300,
    improvement_percent: 40,
  },
  batch: {
    itemsProcessed: 10,
    batchTime: 60,
    individual_equivalent: 500,
    tokenSavings: 75, // %
  },
  errors: {
    totalAttempts: 50,
    failures: 3,
    retries: 2,
    successRate: 94,
  }
}
```

### 모니터링 체크포인트

#### 작업 시작 전

```text
1. 작업 분석
   ✓ 독립성 확인
   ✓ 의존성 맵핑
   ✓ 예상 시간 계산

2. 리소스 계획
   ✓ 모델 선택 (haiku/sonnet/opus)
   ✓ 병렬도 목표 설정
   ✓ 토큰 예산 확인
```

#### 작업 진행 중

```text
1. 실시간 모니터링
   ✓ TaskList(): 진행 상태 확인
   ✓ 활성 에이전트 수: 3-10개 범위
   ✓ 응답 시간: 이상 감지

2. 적응형 조정
   ✓ 병렬도 부족 → 추가 태스크
   ✓ 과도한 병렬 → 배치 통합
   ✓ 에러 증가 → 모델 업그레이드
```

#### 작업 완료 후

```text
1. 성능 분석
   ✓ 총 시간 vs 목표
   ✓ 토큰 사용 vs 예산
   ✓ 성공률 분석

2. 개선 계획
   ✓ 더 나은 패턴 찾기
   ✓ 교훈 문서화
   ✓ 다음 작업 최적화
```

### 모니터링 도구

| 도구 | 용도 | 구현 |
|------|------|------|
| **TaskList()** | 실시간 작업 상태 | 정기적 호출 |
| **로그 파일** | 성능 히스토리 | `.claude/logs/` |
| **git log** | 커밋 추이 | 속도 트렌드 |
| **API 대시보드** | 토큰 사용 추적 | 외부 모니터링 |

</monitoring_strategies>

---

<references>

## 참고 자료

### Anthropic Official

1. [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - 컨텍스트 엔지니어링 원칙

2. [Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) - 멀티 에이전트 시스템 사례

3. [Batch processing](https://platform.claude.com/docs/en/build-with-claude/batch-processing) - 배치 처리 API 문서

### 아키텍처 패턴

4. [Multi-Agent Design Patterns (Azure)](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns) - 에이전트 오케스트레이션 패턴

5. [Multi-Agent Systems (Google ADK)](https://google.github.io/adk-docs/agents/multi-agents/) - 병렬 에이전트 구현

6. [Multi-Agent Patterns (LangChain)](https://docs.langchain.com/oss/python/langchain/multi-agent) - 서브에이전트, 라우터 패턴

7. [Agentic AI Patterns (AWS)](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-patterns/introduction.html) - 워크플로우 및 협조 패턴

### 성능 최적화

8. [Batch Query Processing (arXiv)](https://arxiv.org/html/2509.02121v1) - 배치 최적화 연구

9. [Parallel Processing with Claude](https://codesignal.com/learn/courses/exploring-workflows-with-claude-in-typescript/lessons/parallel-processing-with-claude) - 병렬 처리 실습 자료

10. [AI Agent Performance Optimization](https://www.talktoagent.com/blog/ways-to-optimize-ai-agent-performance) - 9가지 최적화 전략

### 에러 처리 및 복구

11. [Multi-Agent AI Failure Recovery](https://galileo.ai/blog/multi-agent-ai-system-failure-recovery) - 실패 복구 전략

12. [Exception Handling for AI Agents](https://datagrid.com/blog/exception-handling-frameworks-ai-agents) - 예외 처리 프레임워크

13. [Multi-Agent Systems Fault Tolerance](https://milvus.io/ai-quick-reference/how-do-multiagent-systems-ensure-fault-tolerance) - 결함 허용 기법

### 고급 패턴

14. [Fan-Out Fan-In Pattern](https://systemdesignschool.io/fundamentals/fan-out-fan-in) - 분산 처리 패턴

15. [Context Preservation in Multi-Agent](https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/) - 컨텍스트 보존 기법

</references>

---

<summary>

## 핵심 요약

### 3가지 최적화 전략

| 전략 | 적용 | 효과 |
|------|------|------|
| **병렬 실행** | 독립 작업 → 단일 메시지 다중 Tool | 5-15배 속도 향상 |
| **배치 처리** | 10개+ 유사 작업 → 단일 Task | 토큰 70-90% 절감 |
| **모델 라우팅** | 복잡도별 선택 (haiku/sonnet/opus) | 비용 30-50% 절감 |

### 성능 목표

- **대기 시간:** 순차 대비 80% 감소
- **병렬도:** 3-10개 동시 실행
- **성공률:** 95% 이상
- **토큰 절감:** 배치 시 70-90%

### 빠른 시작

1. 작업 분석: 독립/의존/유사 구분
2. 패턴 선택: 병렬/순차/배치
3. 모델 선택: 복잡도 기반
4. 모니터링: TaskList, 로그 추적
5. 최적화: 성능 메트릭 개선

### 피해야 할 패턴

- ❌ 순차 실행 (대기 시간 낭비)
- ❌ 과도한 병렬 (컨텍스트 혼란)
- ❌ 모델 미스매치 (비용 낭비)
- ❌ 배치 미사용 (토큰 낭비)

</summary>
