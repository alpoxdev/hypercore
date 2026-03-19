# Sequential Thinking 패턴

**목적**: 문서 작성과 하네스 설계 문제를 구조화된 단계로 분해해 해결합니다.

## 핵심 원칙

중요한 생성 또는 리팩토링 작업 전에는 `sequential-thinking`을 실행합니다.

## 복잡도별 사고 단계

| 복잡도 | 단계 수 | 대표 작업 |
|------|------|------|
| LOW | 1-2 | 짧은 문구 수정, 한 파일 정리 |
| MEDIUM | 3-5 | 문서 리팩토링, 규칙 통합 |
| HIGH | 5-8+ | 다중 파일 스킬 재설계, 하네스 구조 개편 |

## 사용 시점

| 상황 | 필수 여부 |
|------|------|
| 새 문서 스켈레톤 작성 | 필수 |
| 길고 반복적인 스킬 리팩토링 | 필수 |
| 공급자 민감 가이드 재구성 | 필수 |
| 이미 안정적인 문서에 짧은 메모 추가 | 선택 |

## 파라미터

| 필수 | 설명 |
|------|------|
| `thought` | 현재 사고 내용 |
| `nextThoughtNeeded` | 추가 사고 필요 여부 |
| `thoughtNumber` | 현재 사고 번호 |
| `totalThoughts` | 예상 총 단계 |

| 선택 | 설명 |
|------|------|
| `isRevision` | 이전 사고 수정 여부 |
| `revisesThought` | 수정 대상 사고 |
| `branchFromThought` | 분기 시작점 |
| `branchId` | 분기 식별자 |

## 예시: 오래된 스킬 리팩토링

```typescript
mcp__sequential_thinking__sequentialthinking({
  thought: "docs-maker를 공급자 중립 코어로 정리하고 혼합 구현 관심사를 제거해야 한다.",
  thoughtNumber: 1,
  totalThoughts: 4,
  nextThoughtNeeded: true
})

mcp__sequential_thinking__sequentialthinking({
  thought: "스킬 본문과 규칙 파일을 읽고 코어, 하네스, 공급자 전용, 프로젝트 전용으로 분류한다.",
  thoughtNumber: 2,
  totalThoughts: 4,
  nextThoughtNeeded: true
})

mcp__sequential_thinking__sequentialthinking({
  thought: "표준 파일은 문서와 하네스 규칙만 남기고, 공급자 민감한 내용은 참조 파일로 이동한다.",
  thoughtNumber: 3,
  totalThoughts: 4,
  nextThoughtNeeded: true
})

mcp__sequential_thinking__sequentialthinking({
  thought: "오래된 모델명 grep과 재독으로 최종 일관성과 검증 범위를 확인한다.",
  thoughtNumber: 4,
  totalThoughts: 4,
  nextThoughtNeeded: false
})
```

## 주요 기능

### 1. 동적 조정

`totalThoughts`는 고정이 아닙니다. 문서 범위가 바뀌면 단계 수를 늘리거나 줄입니다.

### 2. 수정

출처 확인 결과 기존 가정이 틀렸다면 이전 사고를 수정합니다.

### 3. 분기

문서 구조안이나 규칙 팩 분할안을 비교할 때 분기를 사용합니다.

## 사고 문장 작성 규칙

- 각 사고 단계는 구체적 결론이나 다음 행동으로 끝냅니다.
- 다음 단계가 검증을 요구할 때는 추측성 표현을 피합니다.
- 파일 읽기나 출처 근거에 기대는 문장을 우선합니다.

## 체크리스트

- [ ] 복잡도 판단
- [ ] 초기 단계 수 결정
- [ ] 첫 사고 단계를 문제 정의로 작성
- [ ] 범위가 바뀌면 수정 또는 분기 사용
- [ ] 마지막 thought에서만 `nextThoughtNeeded=false`
