---
title: Preload Based on User Intent
impact: MEDIUM
impactDescription: reduces perceived latency
tags: bundle, preload, user-intent, hover
---

## 사용자 의도 기반 프리로드

필요하기 전에 무거운 번들을 미리 로드하여 체감 지연 시간을 줄이세요.

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

**예시 (피처 플래그가 활성화될 때 프리로드):**

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

`typeof window !== 'undefined'` 검사는 SSR을 위해 프리로드된 모듈을 번들링하는 것을 방지하여 서버 번들 크기와 빌드 속도를 최적화합니다.
