---
title: CSS content-visibility for Long Lists
impact: HIGH
impactDescription: faster initial render
tags: rendering, css, content-visibility, long-lists
---

## 긴 목록을 위한 CSS content-visibility

`content-visibility: auto`를 적용하여 화면 밖 렌더링을 연기하세요.

**CSS:**

```css
.message-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 80px;
}
```

**예시:**

```tsx
function MessageList({ messages }: { messages: Message[] }) {
  return (
    <div className="overflow-y-auto h-screen">
      {messages.map(msg => (
        <div key={msg.id} className="message-item">
          <Avatar user={msg.author} />
          <div>{msg.content}</div>
        </div>
      ))}
    </div>
  )
}
```

1000개의 메시지가 있을 때, 브라우저는 ~990개의 화면 밖 항목에 대한 레이아웃/페인트를 건너뜁니다 (초기 렌더링 10배 빠름).
