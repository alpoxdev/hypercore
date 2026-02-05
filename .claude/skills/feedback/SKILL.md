---
name: feedback
description: QA 피드백 기반 전반적 수정. 수정 범위 분석, 옵션 제시, 일괄 구현.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Feedback Skill

> QA 피드백 기반 전반적 수정. 수정 범위 분석, 옵션 제시, 일괄 구현.

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **QA 피드백** | "전체적으로 버튼 크기가 너무 작음" |
| **디자인 일괄 수정** | "모든 카드 컴포넌트에 그림자 추가" |
| **UX 개선** | "폼 제출 후 로딩 상태 표시 필요" |
| **일관성 수정** | "에러 메시지 스타일 통일" |
| **반복 패턴 수정** | "모든 테이블에 페이지네이션 추가" |

## 호출 방법

```bash
# 직접 처리
Skill: feedback <QA 피드백 내용>

# 예시
/feedback 버튼이 전체적으로 너무 작아서 모바일에서 터치하기 어려움
/feedback 에러 발생 시 사용자에게 피드백이 없음
/feedback 로딩 상태가 표시되지 않아 사용자가 혼란스러워함
```

## 결과물

- 수정 범위 분석 (영향받는 파일/컴포넌트)
- 2-3개 수정 옵션 제시 (장단점, 영향 범위)
- 추천안 및 근거
- 선택 후 일괄 수정 + 검증

</when_to_use>

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"어떤 피드백을 반영해야 하나요? 구체적으로 알려주세요.

예시:
- QA 피드백 내용
- 문제가 되는 화면/컴포넌트
- 기대하는 수정 방향
- 스크린샷 또는 참고 이미지"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 입력 확인 | ARGUMENT 검증, 없으면 질문 | - |
| 2. 범위 분석 | Sequential Thinking으로 수정 범위 결정 | sequentialthinking (1-2단계) |
| 3. 영향 파악 | Task (Explore)로 관련 파일 탐색 | Task (Explore) 병렬 |
| 4. 옵션 도출 | 수정 방법 2-3개 도출 | sequentialthinking (3-4단계) |
| 5. 옵션 제시 | 장단점, 영향 범위, 작업량 제시 | - |
| 6. 사용자 선택 | 수정 방법 선택 대기 | - |
| 7. 일괄 구현 | 선택된 방법으로 병렬 수정 | Task (implementation-executor) 병렬 |
| 8. 검증 | 빌드/린트 확인 | Bash |

</workflow>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도 판단 (thought 1)

```
thought 1: 범위 분석
- 피드백 유형: UI/UX/기능/성능
- 영향 범위: 특정 페이지 vs 전역 컴포넌트
- 수정 파일 수: 1-3 (간단) / 4-10 (보통) / 10+ (복잡)
- 일관성 요구: 기존 패턴 유지 vs 새 패턴 도입
```

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 3 | 1-3 파일, 단순 스타일 | 범위 분석 → 수정 방법 → 구현 |
| **보통** | 4 | 4-10 파일, 컴포넌트 수정 | 범위 분석 → 영향 파악 → 옵션 비교 → 추천안 |
| **복잡** | 5+ | 10+ 파일, 패턴 변경 | 범위 분석 → 심층 탐색 → 옵션 분석 → 병렬 전략 → 추천안 |

### 보통 복잡도 패턴 (4단계)

```
thought 1: 범위 분석 - 피드백 유형, 영향 범위
thought 2: 관련 파일 탐색 결과 분석
thought 3: 수정 방법 2-3개 비교
thought 4: 최종 추천안 및 근거
```

</thinking_strategy>

---

<exploration>

## Task (Explore) 활용

### 탐색 전략

| 피드백 유형 | 탐색 대상 | prompt 예시 |
|------------|----------|-------------|
| **UI 일괄 수정** | 컴포넌트 사용처 | "Button 컴포넌트 사용 파일 전체 탐색" |
| **스타일 통일** | 스타일 정의 | "에러 메시지 스타일 사용 패턴 분석" |
| **기능 추가** | 관련 컴포넌트 | "폼 컴포넌트 및 제출 핸들러 탐색" |
| **UX 개선** | 사용자 흐름 | "로딩 상태 처리 패턴 분석" |

### 병렬 탐색 패턴

```typescript
// ✅ 여러 영역 동시 탐색
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: 'Button 컴포넌트 정의 및 props 분석'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: 'Button 사용처 전체 목록 및 사용 패턴'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '기존 버튼 크기 관련 스타일 시스템'
})
```

</exploration>

---

<option_presentation>

## 옵션 제시 형식

```markdown
## 피드백 분석 결과

**피드백:** [원본 피드백]

**영향 범위:**
- 파일 수: X개
- 컴포넌트: [목록]

---

### 옵션 1: [수정 방법] (추천)

**수정 내용:**
- 변경 사항 1
- 변경 사항 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**수정 파일:** X개
- `src/components/Button.tsx`
- `src/routes/*/page.tsx` (5개)

**작업량:** 낮음/중간/높음

---

### 옵션 2: [수정 방법]

**수정 내용:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**수정 파일:** Y개
**작업량:** 중간

---

### 옵션 3: [수정 방법] (최소 수정)

**수정 내용:**
...

**작업량:** 낮음

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션으로 수정하시겠습니까? (1/2/3)
```

</option_presentation>

---

<implementation>

## 일괄 구현 가이드

### 병렬 수정 전략

| 수정 유형 | 병렬화 방법 | 예시 |
|----------|------------|------|
| **컴포넌트 수정** | 파일별 에이전트 | Button, Card, Modal 각각 |
| **스타일 통일** | 영역별 에이전트 | 헤더, 본문, 푸터 |
| **기능 추가** | 모듈별 에이전트 | 프론트엔드, 백엔드 |

### 병렬 구현 패턴

```typescript
// ✅ 독립 파일 동시 수정
Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/components/Button.tsx: 버튼 크기 lg → xl 변경'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/components/IconButton.tsx: 버튼 크기 lg → xl 변경'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/components/SubmitButton.tsx: 버튼 크기 lg → xl 변경'
})
```

### 검증 체크리스트

```text
✅ 모든 파일 수정 완료
✅ 빌드 성공 (npm run build)
✅ 타입 에러 없음 (tsc --noEmit)
✅ 린트 통과 (npm run lint)
✅ 시각적 확인 (개발 서버)
```

</implementation>

---

<parallel_agent_execution>

## Parallel Agent Execution

### Model Routing

| 복잡도 | 수정 유형 | 모델 | 예시 |
|--------|----------|------|------|
| **LOW** | 단순 스타일 | haiku | 크기, 색상, 간격 변경 |
| **MEDIUM** | 컴포넌트 수정 | sonnet | props 추가, 로직 변경 |
| **HIGH** | 패턴 변경 | opus | 새 시스템 도입, 아키텍처 |

### Recommended Agents

| Agent | Model | 용도 |
|-------|-------|------|
| **@implementation-executor** | haiku/sonnet | 파일별 수정 구현 |
| **@explore** | haiku | 영향 범위 탐색 |
| **@qa-tester** | sonnet | UI/UX 변경 후 테스트 검증 |
| **@vision** | sonnet | 스크린샷/목업 분석, 디자인 비교 |

### 병렬 실행 패턴

**패턴 1: 다중 파일 동시 수정**

```typescript
// 10개 파일 동시 수정 (3-5분)
Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/routes/home/page.tsx: 버튼 크기 수정'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/routes/profile/page.tsx: 버튼 크기 수정'
})
// ... 더 많은 파일
```

**패턴 2: 컴포넌트 + 사용처 동시 수정**

```typescript
// 컴포넌트 정의와 사용처 동시 수정
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Button 컴포넌트: size prop 기본값 변경 + 새 xl 사이즈 추가'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: '모든 Button 사용처: size="lg" → size="xl" 변경'
})
```

**패턴 3: 탐색 + 수정 동시**

```typescript
// 탐색과 수정 병렬 진행
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '추가로 수정 필요한 버튼 컴포넌트 탐색'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '이미 파악된 파일들 수정 시작'
})
```

**패턴 4: UI 수정 + 시각적 검증 병렬**

```typescript
// UI 수정과 동시에 목업/스크린샷 비교
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Button 컴포넌트 크기 수정'
})

Task({
  subagent_type: 'vision',
  model: 'sonnet',
  prompt: '제공된 목업과 현재 UI 비교 분석'
})
```

**패턴 5: 수정 후 기능 테스트**

```typescript
// 구현 완료 후 즉시 테스트 검증
Task({
  subagent_type: 'qa-tester',
  model: 'sonnet',
  prompt: 'tmux로 개발 서버 실행 후 수정된 UI 동작 테스트'
})
```

### Time Optimization

| 작업 유형 | 순차 실행 | 병렬 실행 | 시간 절감 |
|----------|----------|----------|----------|
| 5개 파일 스타일 수정 | 15분 | 3-5분 | **3배** |
| 10개 컴포넌트 수정 | 30분 | 5-7분 | **5배** |
| 전역 패턴 변경 | 60분 | 15-20분 | **3배** |

</parallel_agent_execution>

---

<examples>

## 실전 예시

### 예시 1: UI 일괄 수정 (버튼 크기)

```bash
사용자: /feedback 버튼이 전체적으로 너무 작아서 모바일에서 터치하기 어려움

1. Sequential Thinking (3단계):
   thought 1: "UI 수정 - 보통 복잡도, Button 컴포넌트 + 사용처"
   thought 2: "영향 범위: Button 컴포넌트 + 사용 파일 10개+"
   thought 3: "옵션: 컴포넌트 기본값 변경 vs 개별 수정 vs 새 variant"

2. Task 탐색 (병렬):
   Task (Explore): "Button 컴포넌트 구조 분석"
   Task (Explore): "Button 사용처 전체 목록"
   → 컴포넌트 1개, 사용처 12개 파악

3. 옵션 제시:
   옵션 1: Button 컴포넌트 기본 크기 변경 (추천)
   - 수정 파일: 1개
   - 장점: 일괄 적용, 유지보수 용이
   - 단점: 기존 작은 버튼도 커짐

   옵션 2: 새 size="xl" variant 추가 + 개별 적용
   - 수정 파일: 13개
   - 장점: 기존 호환성 유지
   - 단점: 작업량 많음

   옵션 3: 모바일만 반응형 크기 조정
   - 수정 파일: 1개
   - 장점: 데스크톱 영향 없음
   - 단점: 복잡한 스타일

4. 사용자 선택: 1

5. 구현:
   Edit: src/components/ui/Button.tsx
   → size 기본값 "md" → "lg" 변경

6. 검증:
   npm run build → 성공
   개발 서버 → 모바일 뷰 확인
```

### 예시 2: UX 개선 (로딩 상태)

```bash
사용자: /feedback 폼 제출 시 로딩 상태가 없어서 사용자가 중복 클릭함

1. Sequential Thinking (4단계):
   thought 1: "UX 개선 - 보통 복잡도, 폼 컴포넌트들"
   thought 2: "영향 범위: 모든 폼 제출 버튼 (예상 8개)"
   thought 3: "옵션: 글로벌 로딩 훅 vs 개별 isLoading vs UI 라이브러리"
   thought 4: "글로벌 훅 + 버튼 컴포넌트 통합 추천"

2. Task 탐색 (병렬):
   Task (Explore): "폼 제출 패턴 분석"
   Task (Explore): "mutation 사용 패턴 분석"
   → 폼 8개, mutation 훅 사용 중

3. 옵션 제시:
   옵션 1: Button에 isLoading prop + mutation 연동 (추천)
   - 수정: Button 컴포넌트 + 폼 8개
   - 장점: 일관된 UX, 재사용 가능

   옵션 2: 개별 폼에 로딩 상태 추가
   - 수정: 폼 8개
   - 장점: 빠른 구현
   - 단점: 중복 코드

4. 사용자 선택: 1

5. 병렬 구현:
   Task (sonnet): "Button 컴포넌트에 isLoading prop 추가"
   Task (haiku): "LoginForm 로딩 상태 연동"
   Task (haiku): "SignupForm 로딩 상태 연동"
   Task (haiku): "ProfileForm 로딩 상태 연동"
   // ... 나머지 폼

6. 검증:
   npm run build → 성공
   각 폼 제출 테스트 → 로딩 스피너 확인
```

### 예시 3: 전역 스타일 통일 (에러 메시지)

```bash
사용자: /feedback 에러 메시지 스타일이 페이지마다 다름

1. Sequential Thinking (4단계):
   thought 1: "스타일 통일 - 보통 복잡도, 에러 표시 컴포넌트들"
   thought 2: "영향 범위: 폼 에러, API 에러, 토스트 에러"
   thought 3: "옵션: 통합 ErrorMessage 컴포넌트 vs 스타일만 통일 vs 토스트 통합"
   thought 4: "ErrorMessage 컴포넌트 + 기존 사용처 교체 추천"

2. Task 탐색 (병렬):
   Task (Explore): "현재 에러 메시지 표시 패턴 분석"
   Task (Explore): "에러 관련 스타일 정의 탐색"
   → 3가지 다른 패턴 발견, 15개 파일

3. 옵션 제시:
   옵션 1: ErrorMessage 컴포넌트 생성 + 전체 교체 (추천)
   - 수정: 1개 생성 + 15개 교체
   - 장점: 완전한 일관성, 유지보수 용이

   옵션 2: CSS만 통일 (클래스명 표준화)
   - 수정: 스타일 1개 + 클래스명 15개
   - 장점: 빠른 구현
   - 단점: 마크업 불일치 유지

4. 사용자 선택: 1

5. 병렬 구현:
   Task (sonnet): "ErrorMessage 컴포넌트 생성"
   // 컴포넌트 완료 후
   Task (haiku): "LoginForm 에러 메시지 교체"
   Task (haiku): "SignupForm 에러 메시지 교체"
   // ... 나머지 파일

6. 검증:
   npm run build → 성공
   각 페이지 에러 상태 확인 → 스타일 일관성 확인
```

</examples>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 영향 범위 탐색
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 + 작업량 명시
✅ 수정 파일 목록 명시
```

절대 금지:

```text
❌ ARGUMENT 없이 수정 시작
❌ Sequential Thinking 3단계 미만
❌ 영향 범위 파악 없이 수정
❌ 옵션 1개만 제시
❌ 사용자 선택 없이 수정 시작
❌ 수정 후 검증 생략
❌ 같은 파일 여러 에이전트 동시 수정
```

## 병렬 실행 체크리스트

```text
✅ 독립적인 파일만 병렬 수정
✅ 컴포넌트 수정 → 사용처 수정 순서 유지
✅ 모델 선택: 스타일(haiku) / 로직(sonnet) / 패턴(opus)
✅ 병렬 실행 3-5개 권장
✅ 결과 통합 후 전체 검증
```

</validation>
