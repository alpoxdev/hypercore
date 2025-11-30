# iOS Safe Area

> **Framework**: TanStack Start + Tailwind CSS v4
> **Library**: [tailwindcss-safe-area](https://github.com/mvllow/tailwindcss-safe-area)

iOS 기기의 노치, 홈 인디케이터, 다이나믹 아일랜드 등을 고려한 Safe Area 처리 가이드입니다.

## 설치

```bash
yarn add tailwindcss-safe-area
```

## 설정

### 1. Tailwind CSS 플러그인 등록

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'
import safeArea from 'tailwindcss-safe-area'

export default {
  content: ['./app/**/*.{ts,tsx}'],
  plugins: [safeArea],
} satisfies Config
```

### 2. Viewport 메타 태그 설정 (필수)

Safe Area 유틸리티가 작동하려면 `viewport-fit=cover`가 **반드시** 필요합니다.

```html
<!-- app.html 또는 root layout -->
<meta
  name="viewport"
  content="width=device-width, initial-scale=1, viewport-fit=cover"
/>
```

TanStack Start에서:

```typescript
// app/routes/__root.tsx
export const Route = createRootRoute({
  head: () => ({
    meta: [
      {
        name: 'viewport',
        content: 'width=device-width, initial-scale=1, viewport-fit=cover',
      },
    ],
  }),
})
```

## 유틸리티 클래스

### Padding 유틸리티

```tsx
// 전체 방향 safe area padding
<div className="p-safe">...</div>

// 개별 방향
<header className="pt-safe">상단 노치/다이나믹 아일랜드 영역</header>
<footer className="pb-safe">하단 홈 인디케이터 영역</footer>
<div className="pl-safe pr-safe">좌우 safe area</div>

// X축, Y축
<div className="px-safe">좌우 safe area</div>
<div className="py-safe">상하 safe area</div>
```

### Margin 유틸리티

```tsx
// 전체 방향 safe area margin
<div className="m-safe">...</div>

// 개별 방향
<div className="mt-safe mb-safe">상하 margin</div>
<div className="ml-safe mr-safe">좌우 margin</div>

// X축, Y축
<div className="mx-safe">좌우 safe area margin</div>
<div className="my-safe">상하 safe area margin</div>
```

### Height 유틸리티

```tsx
// Safe area를 제외한 화면 높이
<main className="h-screen-safe">
  전체 화면에서 safe area를 뺀 높이
</main>

// 최소 높이
<div className="min-h-screen-safe">
  최소 높이로 safe area 적용
</div>
```

## Fallback 유틸리티

Safe Area가 0일 때 대체 값을 지정할 수 있습니다.

```tsx
// safe area가 0이면 1rem(4) 적용
<div className="p-safe-or-4">...</div>

// 상단: safe area 또는 0.5rem(2)
<header className="pt-safe-or-2">...</header>

// 하단: safe area 또는 1rem(4)
<footer className="pb-safe-or-4">...</footer>

// 좌우: safe area 또는 1.5rem(6)
<div className="px-safe-or-6">...</div>
```

### Fallback 패턴

| 클래스 | Safe Area 있을 때 | Safe Area 없을 때 |
|--------|-------------------|-------------------|
| `p-safe-or-4` | `env(safe-area-inset-*)` | `1rem` |
| `pt-safe-or-2` | `env(safe-area-inset-top)` | `0.5rem` |
| `pb-safe-or-4` | `env(safe-area-inset-bottom)` | `1rem` |
| `px-safe-or-6` | `env(safe-area-inset-left/right)` | `1.5rem` |

## 실전 패턴

### 기본 앱 레이아웃

```tsx
// app/components/app-layout.tsx
export function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen-safe flex flex-col">
      {/* 상단 헤더 - 노치/다이나믹 아일랜드 대응 */}
      <header className="pt-safe-or-2 px-safe-or-4 bg-white border-b">
        <nav className="h-14 flex items-center">
          <h1>앱 타이틀</h1>
        </nav>
      </header>

      {/* 메인 콘텐츠 */}
      <main className="flex-1 px-safe-or-4">
        {children}
      </main>

      {/* 하단 탭바 - 홈 인디케이터 대응 */}
      <footer className="pb-safe-or-2 px-safe-or-4 bg-white border-t">
        <nav className="h-14 flex items-center justify-around">
          {/* 탭 아이템들 */}
        </nav>
      </footer>
    </div>
  )
}
```

### 전체 화면 모달

```tsx
// app/components/fullscreen-modal.tsx
export function FullscreenModal({ children }: { children: React.ReactNode }) {
  return (
    <div className="fixed inset-0 bg-white z-50">
      <div className="h-screen-safe flex flex-col p-safe">
        {children}
      </div>
    </div>
  )
}
```

### 고정 하단 버튼

```tsx
// app/components/fixed-bottom-button.tsx
export function FixedBottomButton({ children }: { children: React.ReactNode }) {
  return (
    <div className="fixed bottom-0 left-0 right-0 pb-safe-or-4 px-safe-or-4 bg-white border-t">
      <button className="w-full h-12 bg-primary-600 text-white rounded-lg">
        {children}
      </button>
    </div>
  )
}
```

### 스크롤 콘텐츠 with 고정 헤더/푸터

```tsx
export function ScrollableContent() {
  return (
    <div className="h-screen-safe flex flex-col">
      {/* 고정 헤더 */}
      <header className="pt-safe px-safe-or-4 shrink-0">
        <div className="h-14">헤더</div>
      </header>

      {/* 스크롤 영역 */}
      <main className="flex-1 overflow-y-auto px-safe-or-4">
        {/* 스크롤 콘텐츠 */}
      </main>

      {/* 고정 푸터 */}
      <footer className="pb-safe px-safe-or-4 shrink-0">
        <div className="h-14">푸터</div>
      </footer>
    </div>
  )
}
```

## CSS 직접 사용

Tailwind 유틸리티 외에 CSS에서 직접 사용할 수도 있습니다.

```css
.custom-container {
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

/* fallback 포함 */
.custom-header {
  padding-top: max(env(safe-area-inset-top), 1rem);
}
```

## 높이 문제 해결

모바일 브라우저에서 `100vh`가 실제 뷰포트보다 클 수 있습니다.

### 해결 방법 1: h-screen-safe 사용

```tsx
<div className="h-screen-safe">
  {/* safe area를 고려한 정확한 높이 */}
</div>
```

### 해결 방법 2: -webkit-fill-available

```css
.full-height {
  height: 100vh;
  height: -webkit-fill-available;
}
```

### 해결 방법 3: dvh 단위 (권장)

```css
.full-height {
  height: 100dvh; /* dynamic viewport height */
}
```

Tailwind에서:

```tsx
<div className="h-dvh">
  {/* 동적 뷰포트 높이 */}
</div>
```

## 디바이스별 Safe Area

| 디바이스 | 상단 | 하단 | 좌우 |
|----------|------|------|------|
| iPhone 14 Pro/15 Pro | 59px (다이나믹 아일랜드) | 34px | 0px |
| iPhone 14/15 | 47px (노치) | 34px | 0px |
| iPhone SE | 20px (상태바) | 0px | 0px |
| iPad Pro | 24px | 20px | 0px |
| Android (일반) | 24px (상태바) | 0px | 0px |

## 트러블슈팅

### Safe Area가 적용되지 않음

1. `viewport-fit=cover` 메타 태그 확인
2. 플러그인이 올바르게 등록되었는지 확인
3. 실제 iOS 기기 또는 시뮬레이터에서 테스트 (데스크톱 브라우저는 safe area가 0)

### 콘텐츠가 노치에 가려짐

```tsx
// ❌ 잘못된 예
<header className="fixed top-0">...</header>

// ✅ 올바른 예
<header className="fixed top-0 pt-safe">...</header>
```

### 하단 버튼이 홈 인디케이터와 겹침

```tsx
// ❌ 잘못된 예
<button className="fixed bottom-4">...</button>

// ✅ 올바른 예
<div className="fixed bottom-0 pb-safe-or-4">
  <button>...</button>
</div>
```

## 참고 자료

- [tailwindcss-safe-area GitHub](https://github.com/mvllow/tailwindcss-safe-area)
- [Apple Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [CSS env() function](https://developer.mozilla.org/en-US/docs/Web/CSS/env)
