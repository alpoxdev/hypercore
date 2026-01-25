---
title: Preload Based on User Intent
impact: MEDIUM
impactDescription: reduces perceived latency
tags: bundle, preload, user-intent, hover
---

## 사용자 의도에 따른 프리로드

무거운 번들을 필요하기 전에 프리로드하여 체감 지연 시간을 줄입니다.

**예시 (호버/포커스 시 프리로드):**

```tsx
function EditorButton({ onClick }: { onClick: () => void }) {
  const preload = () => {
    if (typeof window !== 'undefined') {
      void import('./monaco-editor')
    }
  }

  return (
    <button
      onMouseEnter={preload}
      onFocus={preload}
      onClick={onClick}
    >
      Open Editor
    </button>
  )
}
```

**예시 (기능 플래그가 활성화될 때 프리로드):**

```tsx
function FlagsProvider({ children, flags }: Props) {
  useEffect(() => {
    if (flags.editorEnabled && typeof window !== 'undefined') {
      void import('./monaco-editor').then(mod => mod.init())
    }
  }, [flags.editorEnabled])

  return <FlagsContext.Provider value={flags}>
    {children}
  </FlagsContext.Provider>
}
```

`typeof window !== 'undefined'` 체크는 프리로드된 모듈이 SSR에서 번들링되는 것을 방지하여 서버 번들 크기와 빌드 속도를 최적화합니다.
