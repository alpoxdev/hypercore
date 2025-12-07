# iOS Safe Area

> **Library**: [tailwindcss-safe-area](https://github.com/mvllow/tailwindcss-safe-area)

iOS 노치, 홈 인디케이터, 다이나믹 아일랜드 대응.

## 설치

```bash
yarn add tailwindcss-safe-area
```

```typescript
// tailwind.config.ts
import safeArea from 'tailwindcss-safe-area'
export default { plugins: [safeArea] }
```

## Viewport 설정 (필수)

```typescript
// src/routes/__root.tsx
export const Route = createRootRoute({
  head: () => ({
    meta: [{
      name: 'viewport',
      content: 'width=device-width, initial-scale=1, viewport-fit=cover',
    }],
  }),
})
```

## 유틸리티 클래스

### Padding
```tsx
<div className="p-safe">          {/* 전체 */}
<header className="pt-safe">      {/* 상단 (노치) */}
<footer className="pb-safe">      {/* 하단 (홈 인디케이터) */}
<div className="px-safe py-safe"> {/* X축, Y축 */}
```

### Margin
```tsx
<div className="m-safe mt-safe mb-safe mx-safe my-safe">
```

### Height
```tsx
<main className="h-screen-safe">     {/* safe area 제외 높이 */}
<div className="min-h-screen-safe">  {/* 최소 높이 */}
```

### Fallback (safe area 없을 때 대체값)
```tsx
<div className="p-safe-or-4">    {/* safe area 또는 1rem */}
<header className="pt-safe-or-2"> {/* 상단 또는 0.5rem */}
<footer className="pb-safe-or-4"> {/* 하단 또는 1rem */}
```

## 레이아웃 패턴

### 기본 앱 레이아웃
```tsx
<div className="min-h-screen-safe flex flex-col">
  <header className="pt-safe-or-2 px-safe-or-4 bg-white border-b">
    <nav className="h-14 flex items-center">헤더</nav>
  </header>
  <main className="flex-1 px-safe-or-4">{children}</main>
  <footer className="pb-safe-or-2 px-safe-or-4 bg-white border-t">
    <nav className="h-14 flex items-center justify-around">탭바</nav>
  </footer>
</div>
```

### 고정 하단 버튼
```tsx
<div className="fixed bottom-0 left-0 right-0 pb-safe-or-4 px-safe-or-4 bg-white border-t">
  <button className="w-full h-12 bg-primary-600 text-white rounded-lg">
    버튼
  </button>
</div>
```

### 전체 화면 모달
```tsx
<div className="fixed inset-0 bg-white z-50">
  <div className="h-screen-safe flex flex-col p-safe">{children}</div>
</div>
```

## 높이 문제 해결

```tsx
// 동적 뷰포트 높이 (권장)
<div className="h-dvh">

// 또는
<div className="h-screen-safe">
```

## 트러블슈팅

```tsx
// ❌ 노치에 가려짐
<header className="fixed top-0">

// ✅ safe area 적용
<header className="fixed top-0 pt-safe">

// ❌ 홈 인디케이터와 겹침
<button className="fixed bottom-4">

// ✅ safe area 적용
<div className="fixed bottom-0 pb-safe-or-4">
  <button>...</button>
</div>
```
