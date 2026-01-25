---
title: Prevent Hydration Mismatch Without Flickering
impact: MEDIUM
impactDescription: avoids visual flicker and hydration errors
tags: rendering, ssr, hydration, localStorage, flicker
---

## 깜박임 없이 하이드레이션 불일치 방지

클라이언트 측 저장소(localStorage, 쿠키)에 의존하는 콘텐츠를 렌더링할 때, 동기 스크립트를 주입하여 React가 하이드레이션하기 전에 DOM을 업데이트함으로써 SSR 오류와 하이드레이션 후 깜박임을 모두 방지하세요.

**❌ 잘못된 예시 (SSR 오류 발생):**

```tsx
function ThemeWrapper({ children }: { children: ReactNode }) {
  // localStorage는 서버에서 사용 불가 - 오류 발생
  const theme = localStorage.getItem('theme') || 'light'

  return (
    <div className={theme}>
      {children}
    </div>
  )
}
```

`localStorage`가 undefined이기 때문에 서버 사이드 렌더링이 실패합니다.

**❌ 잘못된 예시 (시각적 깜박임):**

```tsx
function ThemeWrapper({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState('light')

  useEffect(() => {
    // 하이드레이션 후 실행 - 눈에 보이는 깜박임 발생
    const stored = localStorage.getItem('theme')
    if (stored) {
      setTheme(stored)
    }
  }, [])

  return (
    <div className={theme}>
      {children}
    </div>
  )
}
```

컴포넌트가 먼저 기본값(`light`)으로 렌더링된 다음 하이드레이션 후 업데이트되어, 잘못된 콘텐츠가 눈에 보이게 깜박입니다.

**✅ 올바른 예시 (깜박임 없음, 하이드레이션 불일치 없음):**

```tsx
function ThemeWrapper({ children }: { children: ReactNode }) {
  return (
    <>
      <div id="theme-wrapper">
        {children}
      </div>
      <script
        dangerouslySetInnerHTML={{
          __html: `
            (function() {
              try {
                var theme = localStorage.getItem('theme') || 'light';
                var el = document.getElementById('theme-wrapper');
                if (el) el.className = theme;
              } catch (e) {}
            })();
          `,
        }}
      />
    </>
  )
}
```

인라인 스크립트가 요소를 표시하기 전에 동기적으로 실행되어, DOM이 이미 올바른 값을 가지도록 보장합니다. 깜박임도 없고, 하이드레이션 불일치도 없습니다.

이 패턴은 테마 토글, 사용자 선호도, 인증 상태 및 기본값을 깜박이지 않고 즉시 렌더링해야 하는 모든 클라이언트 전용 데이터에 특히 유용합니다.
