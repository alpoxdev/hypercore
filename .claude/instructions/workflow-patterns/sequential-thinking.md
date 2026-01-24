# Sequential Thinking Pattern

**목적**: 복잡한 문제를 구조화된 단계로 분해하여 해결

## 핵심 원칙

**작업 시작 전 Sequential Thinking으로 사고 과정을 거칠 것**

## 복잡도별 사고 단계

| 복잡도 | 단계 수 | 예시 |
|--------|---------|------|
| **LOW** | 1-2 | 단순 질문, 파일 읽기, 간단한 검색 |
| **MEDIUM** | 3-5 | 기능 구현, 버그 수정, 문서 작성 |
| **HIGH** | 7-10+ | 아키텍처 설계, 대규모 리팩토링, 복잡한 디버깅 |

## 사용 시점

| 상황 | 필수 여부 |
|------|----------|
| 새 기능 구현 | ✅ 필수 (3-5단계) |
| 버그 수정 | ✅ 필수 (3-5단계) |
| 리팩토링 | ✅ 필수 (5-7단계) |
| 아키텍처 설계 | ✅ 필수 (7-10단계) |
| 파일 읽기 | ❌ 선택 (1단계) |
| 간단한 검색 | ❌ 선택 (1단계) |

## 파라미터

| 필수 | 설명 |
|------|------|
| `thought` | 현재 사고 내용 |
| `nextThoughtNeeded` | 추가 사고 필요 여부 (true/false) |
| `thoughtNumber` | 현재 번호 (1부터 시작) |
| `totalThoughts` | 예상 총 단계 (동적 조정 가능) |

| 선택 | 설명 |
|------|------|
| `isRevision` | 이전 사고 수정 여부 |
| `revisesThought` | 수정 대상 번호 |
| `branchFromThought` | 분기 시작점 |
| `branchId` | 분기 식별자 |

## 코드 예시

### 예시 1: 간단한 작업 (2단계)

```typescript
// Thought 1: 파일 탐색 계획
mcp__sequential-thinking__sequentialthinking({
  thought: "User 관련 파일을 찾기 위해 src/functions/ 디렉토리를 탐색해야 함",
  thoughtNumber: 1,
  totalThoughts: 2,
  nextThoughtNeeded: true
})

// Thought 2: 실행 결정
mcp__sequential-thinking__sequentialthinking({
  thought: "Glob 도구로 **/*user*.ts 패턴 검색 실행",
  thoughtNumber: 2,
  totalThoughts: 2,
  nextThoughtNeeded: false
})
```

### 예시 2: 중간 복잡도 (5단계)

```typescript
// Thought 1: 문제 정의
mcp__sequential-thinking__sequentialthinking({
  thought: "로그인 API에서 타입 에러 발생. src/functions/auth.ts 확인 필요",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 2: 탐색 계획
mcp__sequential-thinking__sequentialthinking({
  thought: "auth.ts와 관련 타입 파일 (src/types/auth.ts) 병렬로 읽기",
  thoughtNumber: 2,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 3: 원인 분석
mcp__sequential-thinking__sequentialthinking({
  thought: "LoginInput 타입에 email 필드가 없음. Zod 스키마와 TypeScript 타입 불일치",
  thoughtNumber: 3,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 4: 해결 방안
mcp__sequential-thinking__sequentialthinking({
  thought: "LoginInput 인터페이스에 email: string 추가. Zod 스키마는 이미 올바름",
  thoughtNumber: 4,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 5: 실행 결정
mcp__sequential-thinking__sequentialthinking({
  thought: "Edit 도구로 src/types/auth.ts 수정 후 tsc 재실행",
  thoughtNumber: 5,
  totalThoughts: 5,
  nextThoughtNeeded: false
})
```

### 예시 3: 동적 조정 (3→5단계)

```typescript
// Thought 1
mcp__sequential-thinking__sequentialthinking({
  thought: "API 엔드포인트 구현 시작. 3단계 예상",
  thoughtNumber: 1,
  totalThoughts: 3,
  nextThoughtNeeded: true
})

// Thought 2
mcp__sequential-thinking__sequentialthinking({
  thought: "기존 패턴 확인 중 인증 미들웨어가 필요함을 발견. 단계 조정",
  thoughtNumber: 2,
  totalThoughts: 5,  // 3→5로 증가
  nextThoughtNeeded: true
})

// Thought 3-5 계속...
```

## 주요 기능

### 1. 동적 조정

**totalThoughts는 고정이 아님:**
- 작업 중 복잡도 재평가 가능
- 필요 시 단계 추가/감소

### 2. 수정 (Revision)

**이전 사고를 재검토:**

```typescript
mcp__sequential-thinking__sequentialthinking({
  thought: "Thought 3의 원인 분석이 잘못됨. 실제 문제는 DB 스키마 불일치",
  thoughtNumber: 6,
  totalThoughts: 7,
  isRevision: true,
  revisesThought: 3,
  nextThoughtNeeded: true
})
```

### 3. 분기 (Branching)

**여러 접근 방식 탐색:**

```typescript
mcp__sequential-thinking__sequentialthinking({
  thought: "방법 A: REST API 사용",
  thoughtNumber: 4,
  totalThoughts: 8,
  branchFromThought: 3,
  branchId: "approach-a",
  nextThoughtNeeded: true
})

mcp__sequential-thinking__sequentialthinking({
  thought: "방법 B: GraphQL 사용",
  thoughtNumber: 4,
  totalThoughts: 8,
  branchFromThought: 3,
  branchId: "approach-b",
  nextThoughtNeeded: true
})
```

## 금지 패턴

**다음 표현 사용 금지:**

| 금지 표현 | 이유 | 대체 표현 |
|----------|------|----------|
| "~해야 한다" | 추측성 | "~한다" (단정) |
| "probably" | 불확실 | "확인 후 결정" |
| "seems to" | 모호함 | "분석 결과 ~임" |
| "아마도" | 추측 | "검증 필요" |
| "~것 같다" | 불확실 | "~이다" |

**올바른 표현:**

```typescript
// ❌ 잘못된 표현
thought: "이 파일을 수정하면 아마도 해결될 것 같다"

// ✅ 올바른 표현
thought: "타입 정의 누락 확인. src/types/user.ts 수정으로 해결"
```

## 체크리스트

작업 시작 전:

- [ ] 복잡도 판단 (LOW/MEDIUM/HIGH)
- [ ] 최소 단계 수 결정
- [ ] 첫 번째 thought 작성 (문제 정의)
- [ ] 마지막 thought에서만 nextThoughtNeeded=false

작업 중:

- [ ] 각 단계마다 명확한 결론
- [ ] 추측성 표현 금지
- [ ] 필요 시 totalThoughts 조정
- [ ] 불확실하면 분기 또는 수정

**모든 복잡한 작업은 Sequential Thinking으로 시작**
