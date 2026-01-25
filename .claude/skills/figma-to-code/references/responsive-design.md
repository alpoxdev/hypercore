# 반응형 디자인 구현 가이드

Figma 디자인을 모든 디바이스에서 100% 정확하게 구현하는 가이드.

---

## 브레이크포인트

### 표준 브레이크포인트

| 디바이스 | 범위 | Tailwind 접두사 |
|---------|------|----------------|
| **Mobile** | 320px ~ 767px | (기본) |
| **Tablet** | 768px ~ 1023px | `md:` |
| **Desktop** | 1024px+ | `lg:` |

### Tailwind v4 미디어 쿼리

```css
/* globals.css */
@import "tailwindcss";

@theme {
  /* 커스텀 브레이크포인트 (필요시) */
  --breakpoint-mobile: 320px;
  --breakpoint-tablet: 768px;
  --breakpoint-desktop: 1024px;
}

/* 또는 CSS 미디어 쿼리 */
@media (min-width: 768px) {
  /* Tablet */
}

@media (min-width: 1024px) {
  /* Desktop */
}
```

---

## Figma Constraints → CSS 매핑

### Horizontal Constraints

| Figma | CSS | 설명 |
|-------|-----|------|
| **Left** | `justify-self: start` | 왼쪽 고정 |
| **Right** | `justify-self: end` | 오른쪽 고정 |
| **Left + Right** | `width: 100%` | 부모 너비 채움 |
| **Center** | `margin: 0 auto` | 중앙 정렬 |
| **Scale** | `width: 50%` | 비율 유지 |

### Vertical Constraints

| Figma | CSS | 설명 |
|-------|-----|------|
| **Top** | `align-self: start` | 위 고정 |
| **Bottom** | `align-self: end` | 아래 고정 |
| **Top + Bottom** | `height: 100%` | 부모 높이 채움 |
| **Center** | `margin: auto 0` | 세로 중앙 |

---

## 레이아웃 변화 패턴

### Grid → List (Desktop → Mobile)

**Desktop (1024px+):**
```tsx
<div className="grid grid-cols-4 gap-6">
  <Card />
  <Card />
  <Card />
  <Card />
</div>
```

**Mobile (320-767px):**
```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6">
  <Card />
  <Card />
  <Card />
  <Card />
</div>
```

### Horizontal → Vertical (Desktop → Mobile)

**Desktop: 가로 정렬**
```tsx
<div className="flex flex-col lg:flex-row gap-4 lg:gap-8">
  <div className="flex-1">Left Content</div>
  <div className="flex-1">Right Content</div>
</div>
```

**Mobile: 세로 정렬**
- `flex-col` (기본)
- `lg:flex-row` (Desktop)

### 숨김/표시

```tsx
{/* Mobile만 표시 */}
<nav className="lg:hidden">
  Mobile Menu
</nav>

{/* Desktop만 표시 */}
<nav className="hidden lg:block">
  Desktop Menu
</nav>
```

---

## 폰트 크기 반응형

### 방법 1: Tailwind 반응형 클래스

```tsx
<h1 className="text-[24px] md:text-[32px] lg:text-[40px]">
  제목
</h1>
```

### 방법 2: clamp() (권장)

```tsx
<h1 className="text-[clamp(24px,5vw,40px)]">
  제목
</h1>
```

**clamp(최소, 선호, 최대):**
- 최소: 320px에서 크기
- 선호: 뷰포트 기반 크기
- 최대: 1920px에서 크기

---

## 간격 반응형

### Padding

```tsx
<div className="p-[16px] md:p-[24px] lg:p-[32px]">
  콘텐츠
</div>
```

### Gap

```tsx
<div className="flex gap-[12px] md:gap-[16px] lg:gap-[24px]">
  <Item />
  <Item />
</div>
```

---

## 반응형 이미지

### 방법 1: <picture> 태그

```tsx
<picture>
  {/* Desktop */}
  <source
    media="(min-width: 1024px)"
    srcSet="/images/hero/banner-desktop.webp"
  />
  {/* Tablet */}
  <source
    media="(min-width: 768px)"
    srcSet="/images/hero/banner-tablet.webp"
  />
  {/* Mobile (fallback) */}
  <img
    src="/images/hero/banner-mobile.webp"
    alt="Hero Banner"
    className="w-full h-auto"
  />
</picture>
```

### 방법 2: srcSet

```tsx
<img
  src="/images/hero/banner-mobile.webp"
  srcSet="
    /images/hero/banner-mobile.webp 768w,
    /images/hero/banner-tablet.webp 1024w,
    /images/hero/banner-desktop.webp 1920w
  "
  sizes="(max-width: 767px) 100vw, (max-width: 1023px) 100vw, 1920px"
  alt="Hero Banner"
/>
```

### 방법 3: Tailwind 반응형 클래스

```tsx
{/* Mobile: 세로, Desktop: 가로 */}
<img
  src="/images/hero/banner.webp"
  alt="Hero"
  className="w-full h-auto lg:w-1/2"
/>
```

---

## 컨테이너 반응형

### Max Width

```tsx
<div className="max-w-[375px] md:max-w-[768px] lg:max-w-[1200px] mx-auto px-4 md:px-6 lg:px-8">
  콘텐츠
</div>
```

### Full Width

```tsx
{/* Mobile: full, Desktop: 제한 */}
<div className="w-full lg:max-w-[1200px] lg:mx-auto">
  콘텐츠
</div>
```

---

## 반응형 네비게이션

### Hamburger Menu (Mobile)

```tsx
const [isOpen, setIsOpen] = useState(false)

return (
  <header>
    {/* Mobile Hamburger */}
    <button
      className="lg:hidden"
      onClick={() => setIsOpen(!isOpen)}
    >
      <svg className="w-6 h-6" />
    </button>

    {/* Mobile Menu */}
    {isOpen && (
      <nav className="lg:hidden fixed inset-0 bg-white z-50">
        <ul>
          <li>메뉴 1</li>
          <li>메뉴 2</li>
        </ul>
      </nav>
    )}

    {/* Desktop Menu */}
    <nav className="hidden lg:flex gap-8">
      <a href="/">메뉴 1</a>
      <a href="/">메뉴 2</a>
    </nav>
  </header>
)
```

---

## 검증 체크리스트

### Mobile (320-767px)

```
□ 레이아웃: Grid → List 변환 확인
□ 폰트: 작은 크기 적용 확인
□ 간격: 축소된 padding/gap 확인
□ 이미지: Mobile용 이미지 로드 확인
□ 네비게이션: Hamburger 메뉴 확인
□ 터치 타겟: 최소 44x44px 확인
□ Figma Mobile 디자인과 100% 일치
```

### Tablet (768-1023px)

```
□ 레이아웃: 2단 그리드 확인
□ 폰트: 중간 크기 적용 확인
□ 간격: 중간 padding/gap 확인
□ 이미지: Tablet용 이미지 로드 확인
□ Figma Tablet 디자인과 100% 일치
```

### Desktop (1024px+)

```
□ 레이아웃: 4단 그리드 확인
□ 폰트: 큰 크기 적용 확인
□ 간격: 넓은 padding/gap 확인
□ 이미지: Desktop용 이미지 로드 확인
□ 네비게이션: 전체 메뉴 표시 확인
□ Figma Desktop 디자인과 100% 일치
```

---

## 디버깅

### Chrome DevTools

```
1. DevTools 열기 (F12)
2. Toggle Device Toolbar (Ctrl+Shift+M)
3. 디바이스 선택 또는 커스텀 크기 입력
4. 각 브레이크포인트에서 확인:
   - 레이아웃 변화
   - 폰트 크기
   - 간격
   - 이미지 로드
```

### 미디어 쿼리 확인

```js
// Console에서 현재 미디어 쿼리 확인
window.matchMedia('(min-width: 768px)').matches // true/false
```

---

## 베스트 프랙티스

### DO

| 원칙 | 설명 |
|------|------|
| **Mobile First** | 기본 스타일 → md: → lg: 순서 |
| **Exact Breakpoints** | Figma 브레이크포인트 정확히 일치 |
| **Test All Devices** | Mobile/Tablet/Desktop 모두 테스트 |
| **Responsive Images** | 디바이스별 이미지 제공 |

### DON'T

| 금지 사항 | 이유 |
|----------|------|
| **Desktop Only** | Mobile 무시하면 디자인 불일치 |
| **고정 크기** | `width: 375px` → 반응형 깨짐 |
| **브레이크포인트 임의 변경** | Figma와 불일치 |
| **하나의 이미지** | 모든 디바이스에 동일 이미지 비효율 |

---

## 참조

- [Figma Constraints](https://help.figma.com/hc/en-us/articles/360039957734)
- [Tailwind Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [MDN Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images)
