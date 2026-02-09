# 파생 boolean 구독

## 왜 중요한가

연속적인 값(윈도우 크기, 스크롤 위치 등)을 직접 구독하면 픽셀 단위로 리렌더링이 발생합니다. 파생된 boolean 값을 구독하면 리렌더링 빈도를 크게 줄일 수 있습니다. Tauri 앱에서는 윈도우 이벤트, 파일 워처 등에서 특히 중요합니다.

## ❌ 잘못된 패턴

```tsx
import { getCurrentWindow } from '@tauri-apps/api/window'
import { useEffect, useState } from 'react'

function Sidebar() {
  const [width, setWidth] = useState(0)

  useEffect(() => {
    const appWindow = getCurrentWindow()

    // ❌ 윈도우 크기 변경마다 리렌더링 (연속적)
    const unlisten = appWindow.listen('tauri://resize', async () => {
      const size = await appWindow.innerSize()
      setWidth(size.width)
    })

    return () => {
      unlisten.then(fn => fn())
    }
  }, [])

  // boolean 변환은 컴포넌트 내부 (매 렌더링마다 계산)
  const isMobile = width < 768

  return <nav className={isMobile ? 'mobile' : 'desktop'}>...</nav>
}
```

**문제점:**
- 윈도우 크기 변경마다 리렌더링 (픽셀 단위)
- 실제로는 boolean 값만 필요한데 연속 값 구독
- 불필요한 렌더링으로 성능 저하

## ✅ 올바른 패턴

```tsx
import { getCurrentWindow } from '@tauri-apps/api/window'
import { useEffect, useState } from 'react'

function Sidebar() {
  // ✅ boolean 값만 구독 (변경 시에만 리렌더링)
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const appWindow = getCurrentWindow()

    const checkMobile = async () => {
      const size = await appWindow.innerSize()
      const mobile = size.width < 768
      setIsMobile(prev => prev !== mobile ? mobile : prev)  // 값 변경 시에만 업데이트
    }

    checkMobile()

    const unlisten = appWindow.listen('tauri://resize', checkMobile)

    return () => {
      unlisten.then(fn => fn())
    }
  }, [])

  return <nav className={isMobile ? 'mobile' : 'desktop'}>...</nav>
}
```

**useMediaQuery 커스텀 hook (웹과 유사):**

```tsx
import { getCurrentWindow } from '@tauri-apps/api/window'
import { useEffect, useState } from 'react'

function useWindowWidth() {
  const [width, setWidth] = useState(0)

  useEffect(() => {
    const appWindow = getCurrentWindow()

    const updateWidth = async () => {
      const size = await appWindow.innerSize()
      setWidth(size.width)
    }

    updateWidth()
    const unlisten = appWindow.listen('tauri://resize', updateWidth)

    return () => {
      unlisten.then(fn => fn())
    }
  }, [])

  return width
}

function useMediaQuery(breakpoint: number) {
  const width = useWindowWidth()
  // ✅ boolean 반환 (리렌더링 빈도 감소)
  return width < breakpoint
}

// 사용 예시
function App() {
  const isMobile = useMediaQuery(768)

  return (
    <div>
      {isMobile ? <MobileView /> : <DesktopView />}
    </div>
  )
}
```

**파일 워처 예시:**

```tsx
import { listen } from '@tauri-apps/api/event'
import { useEffect, useState } from 'react'

type FileEvent = {
  path: string
  size: number
}

function FileMonitor() {
  // ❌ 파일 크기 연속 업데이트 (불필요)
  const [fileSize, setFileSize] = useState(0)

  useEffect(() => {
    let unlisten: UnlistenFn | undefined

    listen<FileEvent>('file-changed', event => {
      setFileSize(event.payload.size)  // ❌ 매번 리렌더링
    }).then(fn => unlisten = fn)

    return () => unlisten?.()
  }, [])

  const isLarge = fileSize > 10 * 1024 * 1024  // 10MB

  return <div>{isLarge ? 'Large file' : 'Normal file'}</div>
}

// ✅ 개선된 버전
function FileMonitor() {
  const [isLarge, setIsLarge] = useState(false)

  useEffect(() => {
    let unlisten: UnlistenFn | undefined

    listen<FileEvent>('file-changed', event => {
      const large = event.payload.size > 10 * 1024 * 1024
      setIsLarge(prev => prev !== large ? large : prev)  // ✅ 변경 시에만 업데이트
    }).then(fn => unlisten = fn)

    return () => unlisten?.()
  }, [])

  return <div>{isLarge ? 'Large file' : 'Normal file'}</div>
}
```

**스크롤 위치 → 버튼 표시:**

```tsx
import { useEffect, useState } from 'react'

function ScrollToTop() {
  // ❌ 스크롤 위치 직접 구독 (연속 업데이트)
  const [scrollY, setScrollY] = useState(0)

  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  const showButton = scrollY > 300

  return showButton ? <button>Top</button> : null
}

// ✅ 개선된 버전
function ScrollToTop() {
  const [showButton, setShowButton] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      const show = window.scrollY > 300
      setShowButton(prev => prev !== show ? show : prev)  // ✅ boolean만 업데이트
    }

    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return showButton ? <button>Top</button> : null
}
```

## 추가 컨텍스트

**파생 boolean 구독이 유용한 경우:**
- 윈도우 크기 → 모바일/데스크톱 구분
- 스크롤 위치 → 버튼 표시/숨김
- 파일 크기 → 경고 표시
- 타이머 → 만료 여부

**최적화 기법:**
- `prev !== current ? current : prev` 패턴으로 불필요한 업데이트 방지
- 연속 값을 구독해야 하는 경우 `useDeferredValue` 사용 (React 18+)

**Tauri 윈도우 이벤트:**
- `tauri://resize`: 윈도우 크기 변경
- `tauri://move`: 윈도우 이동
- `tauri://focus`: 포커스 상태 변경
- `tauri://blur`: 블러 상태 변경

**성능 비교:**
- 연속 값 구독: 수십~수백 리렌더링/초
- boolean 구독: 0~2 리렌더링/이벤트

**참고:** [React useDeferredValue](https://react.dev/reference/react/useDeferredValue)

영향도: MEDIUM - 리렌더링 빈도 감소, 성능 최적화
