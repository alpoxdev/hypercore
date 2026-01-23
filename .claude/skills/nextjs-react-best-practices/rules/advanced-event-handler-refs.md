---
title: Store Event Handlers in Refs
impact: LOW
impactDescription: stable subscriptions
tags: advanced, hooks, refs, event-handlers, optimization
---

## 이벤트 핸들러를 Ref에 저장

콜백 변경 시 재구독하지 않아야 하는 이펙트에서 사용되는 콜백은 ref에 저장하세요.

**❌ 잘못된 예 (매 렌더마다 재구독):**

```tsx
function useWindowEvent(event: string, handler: () => void) {
  useEffect(() => {
    window.addEventListener(event, handler)
    return () => window.removeEventListener(event, handler)
  }, [event, handler])
}
```

**✅ 올바른 예 (안정적인 구독):**

```tsx
function useWindowEvent(event: string, handler: () => void) {
  const handlerRef = useRef(handler)
  useEffect(() => {
    handlerRef.current = handler
  }, [handler])

  useEffect(() => {
    const listener = () => handlerRef.current()
    window.addEventListener(event, listener)
    return () => window.removeEventListener(event, listener)
  }, [event])
}
```

**대안: 최신 React를 사용하는 경우 `useEffectEvent` 사용:**

```tsx
import { useEffectEvent } from 'react'

function useWindowEvent(event: string, handler: () => void) {
  const onEvent = useEffectEvent(handler)

  useEffect(() => {
    window.addEventListener(event, onEvent)
    return () => window.removeEventListener(event, onEvent)
  }, [event])
}
```

`useEffectEvent`는 동일한 패턴에 대해 더 깨끗한 API를 제공합니다: 항상 최신 버전의 핸들러를 호출하는 안정적인 함수 참조를 생성합니다.
