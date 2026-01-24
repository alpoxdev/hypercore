# Design Standards

**목적**: UI/UX 및 접근성 표준

## 접근성 (Accessibility)

### WCAG 2.2 AA 준수

**필수 기준:**

| 기준 | 요구사항 | 예시 |
|------|----------|------|
| **색상 대비** | 4.5:1 이상 | 텍스트-배경 대비 |
| **키보드 네비게이션** | 모든 기능 접근 가능 | Tab, Enter, Space |
| **ARIA 속성** | 적절한 레이블 | aria-label, aria-describedby |
| **포커스 표시** | 시각적 표시 필수 | outline, ring |

### ARIA 속성

```tsx
// ✅ 올바른 ARIA 사용
<button
  aria-label="사용자 삭제"
  aria-describedby="delete-description"
  onClick={handleDelete}
>
  <TrashIcon />
</button>
<span id="delete-description" className="sr-only">
  이 작업은 되돌릴 수 없습니다
</span>

// ❌ 잘못된 예
<button onClick={handleDelete}>
  <TrashIcon />  {/* 스크린 리더가 읽을 수 없음 */}
</button>
```

### 키보드 네비게이션

```tsx
// ✅ 키보드 지원
function Modal({ isOpen, onClose }) {
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }

    if (isOpen) {
      document.addEventListener('keydown', handleEscape)
      return () => document.removeEventListener('keydown', handleEscape)
    }
  }, [isOpen, onClose])

  return (
    <div role="dialog" aria-modal="true">
      {/* 모달 내용 */}
    </div>
  )
}
```

### 스크린 리더

```tsx
// ✅ 스크린 리더 전용 텍스트
<span className="sr-only">Loading...</span>

// Tailwind CSS
<span className="absolute inset-0 -z-10">
  시각적으로 숨김
</span>
```

## 색상 시스템

### 60-30-10 규칙

| 비율 | 용도 | 예시 |
|------|------|------|
| **60%** | 배경 | bg-gray-50 |
| **30%** | 보조 | bg-gray-200 |
| **10%** | 강조 | bg-blue-500 |

### Tailwind CSS v4 @theme

```css
@theme {
  /* 색상 팔레트 */
  --color-primary-50: #eff6ff;
  --color-primary-500: #3b82f6;
  --color-primary-900: #1e3a8a;

  /* 간격 */
  --spacing-4: 1rem;
  --spacing-8: 2rem;

  /* 폰트 */
  --font-sans: 'Inter', sans-serif;
}
```

### 색상 대비 검증

```typescript
// 대비율 계산 도구 사용
// https://webaim.org/resources/contrastchecker/

// 예시:
// 텍스트: #333333 (어두운 회색)
// 배경: #FFFFFF (흰색)
// 대비율: 12.63:1 ✅ (4.5:1 이상)
```

## 레이아웃

### 간격 시스템 (8px Grid)

```tsx
// ✅ 8의 배수 사용
<div className="p-4">   {/* 16px */}
  <div className="mb-8"> {/* 32px */}
    <h1 className="text-2xl">Title</h1>
  </div>
</div>

// ❌ 임의의 값
<div className="p-[13px]">  {/* 비권장 */}
</div>
```

### 반응형 디자인

```tsx
// ✅ Mobile-first
<div className="
  w-full            {/* 모바일 */}
  md:w-1/2          {/* 태블릿 */}
  lg:w-1/3          {/* 데스크톱 */}
">
  Content
</div>
```

### Safe Area (iOS/Android)

```tsx
// tailwindcss-safe-area 플러그인 사용
<div className="
  pb-4
  pb-[calc(1rem+env(safe-area-inset-bottom))]
">
  하단 버튼
</div>
```

## 타이포그래피

### 폰트 시스템 (2-3개)

```css
@theme {
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}
```

### 크기 및 행간

```tsx
// ✅ 적절한 행간
<p className="text-base leading-relaxed">  {/* 1.625 */}
  긴 텍스트는 행간을 넓게
</p>

<h1 className="text-4xl leading-tight">  {/* 1.25 */}
  제목은 행간을 좁게
</h1>
```

## 인터랙션

### 호버/포커스 상태

```tsx
// ✅ 명확한 상태 표시
<button className="
  bg-blue-500
  hover:bg-blue-600
  focus:ring-4 focus:ring-blue-300
  transition-colors
">
  버튼
</button>
```

### 로딩 상태

```tsx
// ✅ 로딩 인디케이터
{isLoading ? (
  <div className="flex items-center gap-2">
    <Spinner className="w-4 h-4" />
    <span>Loading...</span>
  </div>
) : (
  <button>Submit</button>
)}
```

### 에러 상태

```tsx
// ✅ 명확한 에러 메시지
{error && (
  <div
    role="alert"
    className="bg-red-50 border border-red-200 p-4 rounded"
  >
    <p className="text-red-800">{error.message}</p>
  </div>
)}
```

## 성능

### 이미지 최적화

```tsx
// ✅ Next.js Image 또는 적절한 최적화
<img
  src="/image.jpg"
  alt="설명"
  loading="lazy"
  width={800}
  height={600}
/>
```

### 코드 스플리팅

```typescript
// ✅ 동적 import
const HeavyComponent = lazy(() => import('./HeavyComponent'))

<Suspense fallback={<Spinner />}>
  <HeavyComponent />
</Suspense>
```

## 체크리스트

### 접근성

- [ ] 색상 대비 4.5:1 이상
- [ ] 모든 interactive 요소 키보드 접근 가능
- [ ] ARIA 속성 적절히 사용
- [ ] 포커스 표시 명확
- [ ] 스크린 리더 지원

### 디자인

- [ ] 60-30-10 색상 규칙
- [ ] 8px 그리드 간격
- [ ] 2-3개 폰트 사용
- [ ] 반응형 디자인 (mobile-first)
- [ ] Safe Area 고려

### 인터랙션

- [ ] 호버/포커스 상태 명확
- [ ] 로딩 상태 표시
- [ ] 에러 메시지 명확
- [ ] 전환 애니메이션 자연스러움

### 성능

- [ ] 이미지 lazy loading
- [ ] 코드 스플리팅
- [ ] 불필요한 리렌더 방지

**디자인 표준 준수 → 접근성 + 사용성 향상**
