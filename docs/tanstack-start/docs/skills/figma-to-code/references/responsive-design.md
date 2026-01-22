# Responsive Design Implementation Guide

Guide for implementing Figma designs 100% accurately across all devices.

---

## Breakpoints

### Standard Breakpoints

| Device | Range | Tailwind Prefix |
|--------|-------|-----------------|
| **Mobile** | 320px ~ 767px | (default) |
| **Tablet** | 768px ~ 1023px | `md:` |
| **Desktop** | 1024px+ | `lg:` |

### Tailwind v4 Media Queries

```css
/* globals.css */
@import "tailwindcss";

@theme {
  /* Custom breakpoints (if needed) */
  --breakpoint-mobile: 320px;
  --breakpoint-tablet: 768px;
  --breakpoint-desktop: 1024px;
}

/* Or use CSS media queries */
@media (min-width: 768px) {
  /* Tablet */
}

@media (min-width: 1024px) {
  /* Desktop */
}
```

---

## Figma Constraints → CSS Mapping

### Horizontal Constraints

| Figma | CSS | Description |
|-------|-----|-------------|
| **Left** | `justify-self: start` | Fixed left |
| **Right** | `justify-self: end` | Fixed right |
| **Left + Right** | `width: 100%` | Fill parent width |
| **Center** | `margin: 0 auto` | Center alignment |
| **Scale** | `width: 50%` | Maintain ratio |

### Vertical Constraints

| Figma | CSS | Description |
|-------|-----|-------------|
| **Top** | `align-self: start` | Fixed top |
| **Bottom** | `align-self: end` | Fixed bottom |
| **Top + Bottom** | `height: 100%` | Fill parent height |
| **Center** | `margin: auto 0` | Vertical center |

---

## Layout Change Patterns

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

**Desktop: Horizontal alignment**
```tsx
<div className="flex flex-col lg:flex-row gap-4 lg:gap-8">
  <div className="flex-1">Left Content</div>
  <div className="flex-1">Right Content</div>
</div>
```

**Mobile: Vertical alignment**
- `flex-col` (default)
- `lg:flex-row` (Desktop)

### Hide/Show

```tsx
{/* Show on mobile only */}
<nav className="lg:hidden">
  Mobile Menu
</nav>

{/* Show on desktop only */}
<nav className="hidden lg:block">
  Desktop Menu
</nav>
```

---

## Responsive Font Sizes

### Method 1: Tailwind Responsive Classes

```tsx
<h1 className="text-[24px] md:text-[32px] lg:text-[40px]">
  Heading
</h1>
```

### Method 2: clamp() (Recommended)

```tsx
<h1 className="text-[clamp(24px,5vw,40px)]">
  Heading
</h1>
```

**clamp(minimum, preferred, maximum):**
- Minimum: Size at 320px
- Preferred: Viewport-based size
- Maximum: Size at 1920px

---

## Responsive Spacing

### Padding

```tsx
<div className="p-[16px] md:p-[24px] lg:p-[32px]">
  Content
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

## Responsive Images

### Method 1: <picture> Tag

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

### Method 2: srcSet

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

### Method 3: Tailwind Responsive Classes

```tsx
{/* Mobile: vertical, Desktop: horizontal */}
<img
  src="/images/hero/banner.webp"
  alt="Hero"
  className="w-full h-auto lg:w-1/2"
/>
```

---

## Container Responsive

### Max Width

```tsx
<div className="max-w-[375px] md:max-w-[768px] lg:max-w-[1200px] mx-auto px-4 md:px-6 lg:px-8">
  Content
</div>
```

### Full Width

```tsx
{/* Mobile: full, Desktop: limited */}
<div className="w-full lg:max-w-[1200px] lg:mx-auto">
  Content
</div>
```

---

## Responsive Navigation

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
          <li>Menu 1</li>
          <li>Menu 2</li>
        </ul>
      </nav>
    )}

    {/* Desktop Menu */}
    <nav className="hidden lg:flex gap-8">
      <a href="/">Menu 1</a>
      <a href="/">Menu 2</a>
    </nav>
  </header>
)
```

---

## Validation Checklist

### Mobile (320-767px)

```
□ Layout: Grid → List conversion verified
□ Font: Small size applied
□ Spacing: Reduced padding/gap verified
□ Images: Mobile images load verified
□ Navigation: Hamburger menu verified
□ Touch targets: Minimum 44x44px verified
□ Design matches Figma mobile design 100%
```

### Tablet (768-1023px)

```
□ Layout: 2-column grid verified
□ Font: Medium size applied
□ Spacing: Medium padding/gap verified
□ Images: Tablet images load verified
□ Design matches Figma tablet design 100%
```

### Desktop (1024px+)

```
□ Layout: 4-column grid verified
□ Font: Large size applied
□ Spacing: Wide padding/gap verified
□ Images: Desktop images load verified
□ Navigation: Full menu displayed
□ Design matches Figma desktop design 100%
```

---

## Debugging

### Chrome DevTools

```
1. Open DevTools (F12)
2. Toggle Device Toolbar (Ctrl+Shift+M)
3. Select device or enter custom size
4. Verify at each breakpoint:
   - Layout changes
   - Font sizes
   - Spacing
   - Image loading
```

### Media Query Verification

```js
// Check current media query in Console
window.matchMedia('(min-width: 768px)').matches // true/false
```

---

## Best Practices

### DO

| Principle | Description |
|-----------|-------------|
| **Mobile First** | Base styles → md: → lg: order |
| **Exact Breakpoints** | Match Figma breakpoints exactly |
| **Test All Devices** | Verify mobile/tablet/desktop |
| **Responsive Images** | Provide device-specific images |

### DON'T

| Forbidden | Reason |
|-----------|--------|
| **Desktop Only** | Ignoring mobile causes mismatch |
| **Fixed Sizes** | `width: 375px` breaks responsiveness |
| **Arbitrary Breakpoints** | Must match Figma |
| **Single Image** | Inefficient for all devices |

---

## References

- [Figma Constraints](https://help.figma.com/hc/en-us/articles/360039957734)
- [Tailwind Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [MDN Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images)
