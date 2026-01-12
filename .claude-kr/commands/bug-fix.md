---
description: 버그 원인 분석 및 수정. sequential thinking 3-5 + Task (Explore) 필수.
allowed-tools: Read, Grep, Glob, Task, Edit, Bash(npm:*, yarn:*), mcp__sequential-thinking__sequentialthinking
argument-hint: <버그 설명 또는 에러 메시지>
---

# Bug Fix Command

> 버그 원인 분석, 수정 옵션 제시, 구현까지 처리하는 커맨드.

**버그 대상**: $ARGUMENTS

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"어떤 버그를 수정해야 하나요? 구체적으로 알려주세요.

예시:
- 에러 메시지 및 발생 위치
- 예상 동작 vs 실제 동작
- 재현 방법
- 관련 파일 경로"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 입력 확인 | ARGUMENT 검증, 없으면 질문 | - |
| 2. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 3. 버그 재현 | 에러 재현, 관련 파일 파악 | Read/Grep/Glob |
| 4. 원인 분석 | Task (Explore)로 관련 코드 탐색 | Task (Explore) |
| 5. 옵션 도출 | 수정 방법 2-3개 도출 | sequentialthinking (2-4단계) |
| 6. 옵션 제시 | 장단점, 영향 범위 제시 | - |
| 7. 사용자 선택 | 수정 방법 선택 대기 | - |
| 8. 구현 | 선택된 방법으로 코드 수정 | Edit |
| 9. 검증 | 테스트 실행, 빌드 확인 | Bash |

</workflow>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도 판단 (thought 1)

```
thought 1: 복잡도 판단
- 에러 유형: syntax/runtime/logic/type
- 영향 범위: 단일 파일 vs 다중 파일
- 의존성: 외부 라이브러리, API 연동
- 재현 가능성: 항상 발생 vs 간헐적
```

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|------------|
| **간단** | 3 | 명확한 에러, 1-2 파일 | 복잡도 판단 → 원인 분석 → 수정 방법 |
| **보통** | 5 | 논리 오류, 3-5 파일 | 복잡도 판단 → 재현 → 원인 분석 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 간헐적 오류, 다중 모듈 | 복잡도 판단 → 재현 시도 → 심층 분석 → 옵션 탐색 → 비교 → 추천안 |

### 보통 복잡도 패턴 (5단계)

```
thought 1: 복잡도 판단 및 분석 범위
thought 2: 버그 재현 및 에러 메시지 분석
thought 3: 관련 코드 탐색 및 원인 파악
thought 4: 수정 방법 2-3개 비교 분석
thought 5: 최종 추천안 및 근거
```

### 핵심 원칙

```text
✅ 사고 과정을 출력해야 실제로 생각이 일어남
✅ 복잡도가 불확실하면 높게 책정 (3→5로 확장 가능)
✅ 각 thought에서 구체적 분석 필요 (추상적 설명 금지)
✅ 필요 시 isRevision으로 이전 사고 수정
```

</thinking_strategy>

---

<exploration>

## Task (Explore) 활용

### 탐색 전략

| 버그 유형 | 탐색 대상 | prompt 예시 |
|----------|----------|-------------|
| **타입 에러** | 타입 정의, 사용처 | "타입 X 정의 위치 및 사용 파일 탐색" |
| **런타임 에러** | 함수 호출 체인 | "함수 Y 호출 경로 및 관련 파일" |
| **논리 오류** | 상태 관리, 데이터 흐름 | "상태 Z 변경 위치 및 영향 범위" |
| **API 에러** | 엔드포인트, 요청/응답 | "API /path 관련 코드 구조" |

### Task 호출 패턴

**단일 탐색:**

```typescript
Task({
  subagent_type: 'Explore',
  description: '에러 관련 코드 탐색',
  prompt: `
    에러 발생 관련 코드 구조 파악:
    - 에러가 발생하는 정확한 위치
    - 관련 함수/컴포넌트
    - 의존하는 모듈/라이브러리
    - 최근 수정 이력 (git blame)
  `
})
```

**병렬 탐색 (복잡한 경우):**

```typescript
// 단일 메시지에 다중 Task 호출
Task({
  subagent_type: 'Explore',
  prompt: '프론트엔드 에러 발생 컴포넌트 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '백엔드 API 엔드포인트 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '타입 정의 및 인터페이스 분석'
})

// → 결과 취합 후 원인 파악
```

### 탐색 체크리스트

```text
✅ 에러 발생 정확한 위치
✅ 관련 함수/클래스/컴포넌트
✅ 데이터 흐름 및 상태 변경
✅ 외부 의존성 (라이브러리, API)
✅ 최근 변경 사항 (git log/blame)
```

</exploration>

---

<option_presentation>

## 옵션 제시 형식

### 옵션 2-3개 제시

```markdown
## 버그 분석 결과

**원인:** [원인 설명]

**영향 범위:** [파일 및 모듈 목록]

---

### 옵션 1: [수정 방법] (추천)

**수정 내용:**
- 변경 사항 1
- 변경 사항 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**수정 파일:**
- `src/file1.ts:line`
- `src/file2.ts:line`

**리스크:** 낮음

---

### 옵션 2: [수정 방법]

**수정 내용:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**수정 파일:**
...

**리스크:** 중간

---

### 옵션 3: [수정 방법] (임시 해결)

**수정 내용:**
...

**리스크:** 높음 (근본 해결 아님)

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

## 구현 가이드

### 수정 단계

```
1. 사용자 옵션 선택 대기
2. Edit 도구로 코드 수정
3. 수정 내용 설명
4. 테스트/빌드 실행 (선택)
5. 결과 확인
```

### 수정 후 검증

```bash
# 타입 체크
npm run typecheck
# 또는
tsc --noEmit

# 테스트 실행
npm test
# 또는
npm test -- <관련 테스트 파일>

# 빌드 확인
npm run build
```

### 검증 체크리스트

```text
✅ 에러 해결 확인
✅ 기존 기능 영향 없음
✅ 타입 에러 없음
✅ 테스트 통과
✅ 빌드 성공
```

</implementation>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드 탐색
✅ 원인 분석 명확히
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 수정 파일 위치 명시 (line 포함)
```

절대 금지:

```text
❌ ARGUMENT 없이 분석 시작
❌ Sequential Thinking 3단계 미만
❌ 코드 탐색 없이 추측으로 수정
❌ 옵션 1개만 제시
❌ 사용자 선택 없이 수정 시작
❌ 수정 후 검증 생략
❌ 장단점 없이 수정 방법만 나열
```

</validation>

---

<examples>

## 실전 예시

### 예시 1: 타입 에러

```bash
사용자: /bug-fix Property 'name' does not exist on type 'User'

1. Sequential Thinking (3단계):
   thought 1: "타입 에러 - 간단, User 타입 정의 확인"
   thought 2: "User 타입 및 사용처 탐색 필요"
   thought 3: "옵션 2개: 타입 정의 수정 vs 사용처 수정"

2. Task 탐색:
   Task (Explore): "User 타입 정의 위치 및 사용 파일 탐색"
   → src/types/user.ts, src/components/UserProfile.tsx 파악

3. 원인 분석:
   User 타입에 name 속성 누락

4. 옵션 제시:
   옵션 1: User 타입에 name 속성 추가 (추천)
   - 장점: 근본 해결
   - 단점: 없음

   옵션 2: 사용처에서 name 제거
   - 장점: 빠른 수정
   - 단점: 기능 손실

5. 사용자 선택: 1

6. Edit:
   src/types/user.ts:3
   + name: string;

7. 검증:
   npm run typecheck → 성공
```

### 예시 2: 런타임 에러

```bash
사용자: /bug-fix Cannot read property 'data' of undefined

1. Sequential Thinking (5단계):
   thought 1: "런타임 에러 - 보통 복잡도, null/undefined 체크 누락"
   thought 2: "에러 발생 위치 파악 필요, 스택 트레이스 확인"
   thought 3: "관련 코드 탐색: API 호출, 데이터 접근 패턴"
   thought 4: "수정 방법: optional chaining, null 체크, 초기화"
   thought 5: "optional chaining 추천 - 간결하고 안전"

2. Task 탐색:
   Task (Explore): "undefined 에러 발생 코드 및 데이터 흐름 분석"
   → src/hooks/useUserData.ts:15, API 응답 체크 누락

3. 원인 분석:
   API 응답 실패 시 response가 undefined

4. 옵션:
   옵션 1: optional chaining 사용 (추천)
   옵션 2: if 문으로 null 체크
   옵션 3: try-catch로 감싸기

5. 선택 후 구현 → 검증
```

### 예시 3: 논리 오류

```bash
사용자: /bug-fix 사용자 목록이 중복으로 표시됨

1. Sequential Thinking (5단계):
   thought 1: "논리 오류 - 보통 복잡도, 상태 관리 이슈"
   thought 2: "리렌더링 또는 데이터 fetch 중복 추측"
   thought 3: "관련 컴포넌트 및 상태 관리 코드 탐색"
   thought 4: "옵션: useEffect 의존성 수정, 중복 제거 로직 추가"
   thought 5: "useEffect 의존성 수정 추천"

2. Task 탐색:
   Task (Explore): "사용자 목록 렌더링 컴포넌트 및 상태 관리"
   → UserList.tsx, useEffect 의존성 배열 문제 발견

3. 원인: useEffect 의존성 배열 누락으로 매번 fetch

4. 옵션 제시 → 선택 → 구현 → 검증
```

</examples>
