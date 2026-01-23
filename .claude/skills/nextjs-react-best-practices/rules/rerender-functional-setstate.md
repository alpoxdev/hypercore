---
title: Use Functional setState Updates
impact: MEDIUM
impactDescription: prevents stale closures and unnecessary callback recreations
tags: react, hooks, useState, useCallback, callbacks, closures
---

## 함수형 setState 업데이트 사용

현재 상태 값을 기반으로 상태를 업데이트할 때, 상태 변수를 직접 참조하는 대신 setState의 함수형 업데이트 형태를 사용하세요. 이는 오래된 클로저를 방지하고, 불필요한 의존성을 제거하며, 안정적인 콜백 참조를 생성합니다.

**❌ 잘못된 예시 (상태를 의존성으로 요구):**

```tsx
function TodoList() {
  const [items, setItems] = useState(initialItems)

  // 콜백이 items에 의존해야 하며, items 변경마다 재생성됨
  const addItems = useCallback((newItems: Item[]) => {
    setItems([...items, ...newItems])
  }, [items])  // ❌ items 의존성이 재생성을 유발

  // 의존성을 잊으면 오래된 클로저 위험
  const removeItem = useCallback((id: string) => {
    setItems(items.filter(item => item.id !== id))
  }, [])  // ❌ items 의존성 누락 - 오래된 items를 사용!

  return <ItemsEditor items={items} onAdd={addItems} onRemove={removeItem} />
}
```

첫 번째 콜백은 `items`가 변경될 때마다 재생성되어 자식 컴포넌트의 불필요한 리렌더링을 유발할 수 있습니다. 두 번째 콜백은 오래된 클로저 버그가 있습니다—항상 초기 `items` 값을 참조합니다.

**✅ 올바른 예시 (안정적인 콜백, 오래된 클로저 없음):**

```tsx
function TodoList() {
  const [items, setItems] = useState(initialItems)

  // 안정적인 콜백, 재생성 안 됨
  const addItems = useCallback((newItems: Item[]) => {
    setItems(curr => [...curr, ...newItems])
  }, [])  // ✅ 의존성 불필요

  // 항상 최신 상태 사용, 오래된 클로저 위험 없음
  const removeItem = useCallback((id: string) => {
    setItems(curr => curr.filter(item => item.id !== id))
  }, [])  // ✅ 안전하고 안정적

  return <ItemsEditor items={items} onAdd={addItems} onRemove={removeItem} />
}
```

**장점:**

1. **안정적인 콜백 참조** - 상태 변경 시 콜백을 재생성할 필요가 없음
2. **오래된 클로저 없음** - 항상 최신 상태 값에서 작동
3. **더 적은 의존성** - 의존성 배열을 단순화하고 메모리 누수 감소
4. **버그 방지** - React 클로저 버그의 가장 일반적인 원인 제거

**함수형 업데이트를 사용해야 하는 경우:**

- 현재 상태 값에 의존하는 모든 setState
- 상태가 필요한 경우 useCallback/useMemo 내부
- 상태를 참조하는 이벤트 핸들러
- 상태를 업데이트하는 비동기 작업

**직접 업데이트가 괜찮은 경우:**

- 정적 값으로 상태 설정: `setCount(0)`
- props/인수로만 상태 설정: `setName(newName)`
- 상태가 이전 값에 의존하지 않음

**참고:** 프로젝트에 [React Compiler](https://react.dev/learn/react-compiler)가 활성화되어 있다면, 컴파일러가 일부 케이스를 자동으로 최적화할 수 있지만, 정확성을 위해 그리고 오래된 클로저 버그를 방지하기 위해 함수형 업데이트를 여전히 권장합니다.
