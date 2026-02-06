# TodoWrite Pattern

> **레거시 안내**: 현재 API는 `TaskCreate`/`TaskUpdate`입니다. TodoWrite는 레거시 명칭이며 하위 호환성을 위해 문서가 유지됩니다. 새 작업은 `TaskCreate`를 사용하세요.

**목적**: 복잡한 작업을 단계별로 추적하고 진행 상황 관리

## 핵심 개념

TodoWrite는 작업을 작은 단위로 나누고 각 단계를 체크리스트로 관리하는 도구입니다.

## 사용 시점

| 상황 | 사용 여부 |
|------|----------|
| 3개 이상 단계 작업 | ✅ 권장 |
| 여러 파일 수정 | ✅ 권장 |
| 순차적 의존성 | ✅ 필수 |
| Plan 모드 | ✅ 필수 |
| 간단한 1-2단계 작업 | ❌ 불필요 |

## 기본 구조

```typescript
TodoWrite({
  todos: [
    { text: "1단계: 파일 탐색", done: false },
    { text: "2단계: 타입 수정", done: false },
    { text: "3단계: 테스트 실행", done: false }
  ]
})
```

## 워크플로우

### 1. 작업 시작 시

```typescript
// 모든 단계를 done: false로 초기화
TodoWrite({
  todos: [
    { text: "요구사항 분석", done: false },
    { text: "파일 탐색", done: false },
    { text: "코드 수정", done: false },
    { text: "테스트 검증", done: false }
  ]
})
```

### 2. 단계 완료 시

```typescript
// 완료된 항목을 done: true로 업데이트
TodoWrite({
  todos: [
    { text: "요구사항 분석", done: true },  // ✅
    { text: "파일 탐색", done: true },      // ✅
    { text: "코드 수정", done: false },     // 진행 중
    { text: "테스트 검증", done: false }
  ]
})
```

### 3. 작업 완료 시

```typescript
// 모든 항목 done: true
TodoWrite({
  todos: [
    { text: "요구사항 분석", done: true },
    { text: "파일 탐색", done: true },
    { text: "코드 수정", done: true },
    { text: "테스트 검증", done: true }
  ]
})
```

## 실전 예시

### 예시 1: 버그 수정

```typescript
// 초기 상태
TodoWrite({
  todos: [
    { text: "1. 버그 재현 및 원인 파악", done: false },
    { text: "2. 관련 파일 탐색 (src/functions/auth.ts)", done: false },
    { text: "3. 타입 에러 수정", done: false },
    { text: "4. tsc 검증", done: false },
    { text: "5. 테스트 실행", done: false }
  ]
})

// 1-2단계 완료 후
TodoWrite({
  todos: [
    { text: "1. 버그 재현 및 원인 파악", done: true },
    { text: "2. 관련 파일 탐색 (src/functions/auth.ts)", done: true },
    { text: "3. 타입 에러 수정", done: false },  // 현재 작업
    { text: "4. tsc 검증", done: false },
    { text: "5. 테스트 실행", done: false }
  ]
})
```

### 예시 2: 새 기능 구현

```typescript
TodoWrite({
  todos: [
    { text: "1. 요구사항 분석 및 Sequential Thinking (5단계)", done: false },
    { text: "2. DB 스키마 설계 (Prisma)", done: false },
    { text: "3. Server Function 구현 (inputValidator + middleware)", done: false },
    { text: "4. UI 컴포넌트 구현 (TanStack Query 연동)", done: false },
    { text: "5. 검증 (typecheck, lint, build)", done: false },
    { text: "6. 문서 작성 (API 문서, README)", done: false }
  ]
})
```

### 예시 3: 동적 항목 추가

```typescript
// 초기 계획
TodoWrite({
  todos: [
    { text: "1. 파일 읽기", done: true },
    { text: "2. 코드 수정", done: false }
  ]
})

// 작업 중 추가 단계 발견
TodoWrite({
  todos: [
    { text: "1. 파일 읽기", done: true },
    { text: "2. 코드 수정", done: false },
    { text: "3. 의존성 업데이트 (새로 발견)", done: false },  // 추가
    { text: "4. 테스트 수정 (새로 발견)", done: false }      // 추가
  ]
})
```

## Sequential Thinking과의 조합

**Sequential Thinking**: 사고 과정
**TodoWrite**: 실행 단계

```typescript
// 1. Sequential Thinking으로 계획 수립
mcp__sequential-thinking__sequentialthinking({
  thought: "User API 구현 계획: 스키마 → Server Function → UI → 검증",
  thoughtNumber: 1,
  totalThoughts: 3,
  nextThoughtNeeded: true
})

// 2. TodoWrite로 작업 목록 생성
TodoWrite({
  todos: [
    { text: "Prisma 스키마 정의", done: false },
    { text: "Server Function 구현", done: false },
    { text: "UI 컴포넌트 구현", done: false },
    { text: "/pre-deploy 검증", done: false }
  ]
})

// 3. 각 단계 실행 후 TodoWrite 업데이트
```

## 장점

| 장점 | 설명 |
|------|------|
| **진행 추적** | 어디까지 완료했는지 명확 |
| **우선순위** | 다음에 할 일이 명확 |
| **컨텍스트 복구** | Context compaction 후 재개 용이 |
| **투명성** | 사용자가 진행 상황 확인 가능 |

## 주의사항

### 금지 패턴

```typescript
// ❌ 너무 큰 단위
TodoWrite({
  todos: [
    { text: "전체 기능 구현", done: false }  // 너무 모호
  ]
})

// ✅ 적절한 단위
TodoWrite({
  todos: [
    { text: "DB 스키마 정의", done: false },
    { text: "API 구현", done: false },
    { text: "UI 구현", done: false },
    { text: "테스트", done: false }
  ]
})
```

### 권장 사항

- 각 항목은 30분 이내 완료 가능한 크기
- 5-10개 항목이 적절 (너무 많으면 분할)
- 구체적이고 측정 가능한 표현
- 순서가 중요하면 번호 부여

## 체크리스트

TodoWrite 사용 전:

- [ ] 작업이 3단계 이상인가?
- [ ] 각 단계가 명확한가?
- [ ] 순서가 논리적인가?
- [ ] 각 항목이 측정 가능한가?

**복잡한 작업은 TodoWrite로 체계적 관리**
