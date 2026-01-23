---
title: Conditional Module Loading
impact: HIGH
impactDescription: loads large data only when needed
tags: bundle, conditional-loading, lazy-loading
---

## 조건부 모듈 로딩

기능이 활성화될 때만 대용량 데이터나 모듈을 로드하세요.

**예시 (애니메이션 프레임 지연 로드):**

```tsx
function AnimationPlayer({ enabled }: { enabled: boolean }) {
  const [frames, setFrames] = useState<Frame[] | null>(null)

  useEffect(() => {
    if (enabled && !frames && typeof window !== 'undefined') {
      import('./animation-frames.js')
        .then(mod => setFrames(mod.frames))
        .catch(() => setEnabled(false))
    }
  }, [enabled, frames])

  if (!frames) return <Skeleton />
  return <Canvas frames={frames} />
}
```

`typeof window !== 'undefined'` 검사는 SSR을 위해 이 모듈을 번들링하는 것을 방지하여 서버 번들 크기와 빌드 속도를 최적화합니다.
