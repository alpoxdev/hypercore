---
title: Use toSorted() Instead of sort() for Immutability
impact: MEDIUM-HIGH
impactDescription: prevents mutation bugs in React state
tags: javascript, arrays, immutability, react, state, mutation
---

## 불변성을 위해 sort() 대신 toSorted() 사용

`.sort()`는 배열을 제자리에서 변형하여 React 상태 및 props에서 버그를 일으킬 수 있습니다. 변형 없이 새로운 정렬된 배열을 생성하려면 `.toSorted()`를 사용하세요.

**❌ 잘못된 예 (원본 배열 변형):**

```typescript
function UserList({ users }: { users: User[] }) {
  // users prop 배열을 변형합니다!
  const sorted = useMemo(
    () => users.sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
  return <div>{sorted.map(renderUser)}</div>
}
```

**✅ 올바른 예 (새 배열 생성):**

```typescript
function UserList({ users }: { users: User[] }) {
  // 새로운 정렬된 배열 생성, 원본은 변경되지 않음
  const sorted = useMemo(
    () => users.toSorted((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
  return <div>{sorted.map(renderUser)}</div>
}
```

**React에서 중요한 이유:**

1. Props/state 변형은 React의 불변성 모델을 깨뜨림 - React는 props와 state가 읽기 전용으로 취급되길 기대
2. 오래된 클로저 버그 발생 - 클로저(콜백, 이펙트) 내부에서 배열을 변형하면 예상치 못한 동작이 발생할 수 있음

**브라우저 지원 (구형 브라우저를 위한 폴백):**

`.toSorted()`는 모든 최신 브라우저(Chrome 110+, Safari 16+, Firefox 115+, Node.js 20+)에서 사용 가능합니다. 구형 환경의 경우 spread 연산자를 사용하세요:

```typescript
// 구형 브라우저를 위한 폴백
const sorted = [...items].sort((a, b) => a.value - b.value)
```

**다른 불변 배열 메서드:**

- `.toSorted()` - 불변 정렬
- `.toReversed()` - 불변 역순
- `.toSpliced()` - 불변 splice
- `.with()` - 불변 요소 교체
