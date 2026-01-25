---
title: Batch DOM CSS Changes
impact: MEDIUM
impactDescription: reduces reflows/repaints
tags: javascript, dom, css, performance, reflow
---

## DOM CSS 변경 일괄 처리

스타일을 한 번에 하나씩 변경하지 마세요. 여러 CSS 변경 사항을 클래스 또는 `cssText`를 통해 그룹화하여 브라우저 리플로우를 최소화하세요.

**❌ 잘못된 예시 (여러 번의 리플로우):**

```typescript
function updateElementStyles(element: HTMLElement) {
  // 각 줄이 리플로우를 트리거함
  element.style.width = '100px'
  element.style.height = '200px'
  element.style.backgroundColor = 'blue'
  element.style.border = '1px solid black'
}
```

**✅ 올바른 예시 (클래스 추가 - 단일 리플로우):**

```typescript
// CSS 파일
.highlighted-box {
  width: 100px;
  height: 200px;
  background-color: blue;
  border: 1px solid black;
}

// JavaScript
function updateElementStyles(element: HTMLElement) {
  element.classList.add('highlighted-box')
}
```

**✅ 올바른 예시 (cssText 변경 - 단일 리플로우):**

```typescript
function updateElementStyles(element: HTMLElement) {
  element.style.cssText = `
    width: 100px;
    height: 200px;
    background-color: blue;
    border: 1px solid black;
  `
}
```

**React 예시:**

```tsx
// ❌ 잘못된 예시: 스타일을 하나씩 변경
function Box({ isHighlighted }: { isHighlighted: boolean }) {
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (ref.current && isHighlighted) {
      ref.current.style.width = '100px'
      ref.current.style.height = '200px'
      ref.current.style.backgroundColor = 'blue'
    }
  }, [isHighlighted])

  return <div ref={ref}>Content</div>
}

// ✅ 올바른 예시: 클래스 토글
function Box({ isHighlighted }: { isHighlighted: boolean }) {
  return (
    <div className={isHighlighted ? 'highlighted-box' : ''}>
      Content
    </div>
  )
}
```

가능하면 인라인 스타일보다 CSS 클래스를 선호하세요. 클래스는 브라우저에 캐시되며 관심사의 분리를 더 잘 제공합니다.
