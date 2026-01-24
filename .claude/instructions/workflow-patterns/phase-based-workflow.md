# Phase-Based Workflow

**목적**: 복잡한 작업을 명확한 단계로 구조화하여 완료 보장

## 4-Phase 구조

모든 복잡한 구현 작업은 다음 4단계를 거칩니다:

| Phase | 이름 | 목적 | 완료 조건 |
|-------|------|------|----------|
| **1** | 작업 실행 | 요구사항 구현 | 모든 체크리스트 완료 |
| **2** | 자동 검증 | 코드 품질 확인 | /pre-deploy 통과 + TODO 0개 |
| **3** | 플래너 검증 | 아키텍처 승인 | Planner "승인" 응답 |
| **4** | 완료 | 최종 확인 | 문서 업데이트 완료 |

## Phase 1: 작업 실행

### 목표
모든 요구사항을 100% 구현

### 주요 활동

1. **요구사항 분석**
   - Sequential Thinking (3-5단계)
   - 체크리스트 작성 (TASKS.md)

2. **병렬 구현**
   - 독립적인 작업 동시 실행
   - 에이전트 적극 활용
   - 백그라운드 실행

3. **진행 추적**
   - TodoWrite로 단계 관리
   - TASKS.md 체크박스 업데이트
   - PROCESS.md 의사결정 기록

### 완료 조건

```markdown
- [ ] 모든 요구사항 구현 완료
- [ ] TASKS.md 체크리스트 100% 완료
- [ ] PROCESS.md 업데이트 (Phase 1 완료)
```

### 예시

```typescript
// 1. 요구사항 분석
mcp__sequential-thinking__sequentialthinking({
  thought: "User 인증 API 구현: login, signup, logout 필요",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// 2. 병렬 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Login/Signup Server Functions 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="Login/Signup UI 컴포넌트 구현")
Task(subagent_type="document-writer", model="haiku",
     prompt="API 문서 작성")

// 3. TASKS.md 업데이트
Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md: 인증 API 구현 완료 체크")
```

## Phase 2: 자동 검증

### 목표
코드 품질 및 빌드 안정성 확보

### 주요 활동

1. **/pre-deploy 실행**
   ```typescript
   Skill("pre-deploy")
   ```
   - typecheck (tsc --noEmit)
   - lint (eslint)
   - build (프로젝트 빌드)

2. **TODO 확인**
   ```typescript
   TaskList()  // pending/in_progress 작업 확인
   ```

3. **에러 수정**
   - lint-fixer 에이전트 활용
   - 하나씩 수정 (Sequential Thinking 필수)

4. **검증 결과 기록**
   - VERIFICATION.md 업데이트

### 완료 조건

```markdown
- [ ] /pre-deploy 전체 통과
  - [ ] typecheck: ✅
  - [ ] lint: ✅
  - [ ] build: ✅
- [ ] TODO 리스트: pending/in_progress = 0
- [ ] VERIFICATION.md 업데이트 완료
- [ ] PROCESS.md 업데이트 (Phase 2 완료)
```

### 예시

```typescript
// 1. /pre-deploy 실행
Skill("pre-deploy")

// 2. 결과 확인 및 기록
Task(subagent_type="document-writer", model="haiku",
     prompt=`VERIFICATION.md 업데이트:
- typecheck: ✅ 통과
- lint: ✅ 0 에러
- build: ✅ 성공`)

// 3. TODO 확인
TaskList()

// 4. Phase 2 완료 기록
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md: Phase 2 완료 → Phase 3 시작")
```

## Phase 3: 플래너 검증

### 목표
아키텍처 및 구현 품질 검증

### 주요 활동

1. **Planner 에이전트 호출**
   ```typescript
   Task(
     subagent_type="planner",
     model="opus",
     prompt=`구현 완료 검증 요청

【원본 작업】
${PROMPT}

【수행 내용】
- 요구사항 1: 완료 (구체적 설명)
- 요구사항 2: 완료 (구체적 설명)

【검증 결과】
- /pre-deploy: ✅ 통과
- TODO: ✅ 0개

완료 여부를 판단하고, 미흡한 점이 있다면 구체적으로 지적해주세요.`
   )
   ```

2. **응답 처리**
   - "승인" → Phase 4 진행
   - "수정 필요" → Phase 2로 복귀

3. **결과 기록**
   - VERIFICATION.md에 Planner 응답 기록

### 완료 조건

```markdown
- [ ] Planner 에이전트 호출 완료
- [ ] Planner 응답: "승인" 또는 "완료"
- [ ] VERIFICATION.md에 응답 기록
- [ ] PROCESS.md 업데이트 (Phase 3 완료)
```

### 예시

```typescript
// Planner 호출
Task(subagent_type="planner", model="opus", prompt="...")

// 응답 처리
if (planner_response.includes("승인")) {
  // Phase 4 진행
  Task(subagent_type="document-writer", model="haiku",
       prompt="VERIFICATION.md: Planner 승인 기록")
} else {
  // Phase 2로 복귀
  // 피드백 반영 후 재검증
}
```

## Phase 4: 완료

### 목표
작업 완료 및 최종 문서화

### 주요 활동

1. **최종 문서 업데이트**
   - PROCESS.md: 완료 시각, 총 소요 시간
   - TASKS.md: 최종 확인 (모든 체크박스 체크)

2. **완료 출력**
   ```
   <promise>{{PROMISE}}</promise>
   ```

### 완료 조건

```markdown
- [ ] TASKS.md: 모든 항목 체크 완료
- [ ] PROCESS.md: 완료 시각 기록
- [ ] VERIFICATION.md: 모든 검증 통과
- [ ] <promise> 태그 출력
```

## 실패 처리

| 실패 Phase | 조치 |
|-----------|------|
| **Phase 1** | 미완료 항목 계속 구현 |
| **Phase 2** | 에러 수정 후 재검증 |
| **Phase 3** | Planner 피드백 반영 → Phase 2부터 재실행 |

**절대 건너뛰지 않음. 실패 시 수정 → 재검증 반복**

## 금지 사항

| 금지 패턴 | 설명 |
|----------|------|
| ❌ Phase 스킵 | 2→4 직행 금지 |
| ❌ 부분 검증 | /pre-deploy 일부만 실행 금지 |
| ❌ Planner 우회 | Phase 3 생략 금지 |
| ❌ 추측 완료 | "아마 완료" 금지 |

## 체크리스트

작업 시작 전:

- [ ] Phase 1-4 구조 이해
- [ ] 각 Phase 완료 조건 숙지
- [ ] 문서화 폴더 생성 (.claude/ralph/{timestamp}/)
- [ ] TASKS.md, PROCESS.md, VERIFICATION.md 초기화

작업 중:

- [ ] 현재 Phase 명확히 인식
- [ ] Phase 전환 시 문서 업데이트
- [ ] 실패 시 조기 탈출하지 않고 수정

**4단계 순차 진행으로 작업 완료 보장**
