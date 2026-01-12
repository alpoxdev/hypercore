# UI/UX & Tailwind Guidelines

> TanStack Start + Tailwind CSS v4 + iOS Safe Area

---

<forbidden>

| Category | Forbidden |
|----------|-----------|
| **Spacing** | Arbitrary values (`mt-[13px]`), values outside theme |
| **Components** | Different style combinations for same element |
| **@apply** | Use in individual screens, outside base components |
| **Responsive** | Desktop-first approach |
| **Safe Area** | Apply inside components, direct `env(safe-area-inset-*)` use |
| **Shadows** | `shadow-lg` or larger (except special cases) |
| **Fonts** | 4+ fonts, `text-xs` overuse |
| **Colors** | Using Primary for regular text/background, dark borders |
| **Accessibility** | Color-only differentiation, `outline-none`, placeholder-only labels |
| **Errors** | Technical term messages ("code: 500") |
| **Buttons** | 2+ Primary buttons per screen |

</forbidden>

---

<required>

| Category | Required |
|----------|----------|
| **Spacing** | Tailwind default scale only (4px units) |
| **Responsive** | Mobile first → `sm:` → `md:` → `lg:` |
| **Safe Area** | Use `tailwindcss-safe-area`, apply at layout level |
| **Viewport** | Set `viewport-fit=cover` |
| **Accessibility** | 4.5:1+ contrast, labels required, keyboard access |
| **Button States** | Clearly distinguish Default/Hover/Active/Disabled/Loading |
| **Errors** | User action-oriented messages |
| **Focus** | Clear indication with `focus:ring-2` etc |
| **Loading** | Loading states for key actions, prevent duplicate clicks |
| **Class Order** | Layout → Box → Typography → Color → State |

</required>

---

<design_tokens>

## Design Tokens (Tailwind @theme)

```css
@import "tailwindcss";
@import "tailwindcss-safe-area";

@theme {
  /* 색상 (60-30-10 규칙) */
  --color-primary-500: oklch(0.55 0.2 250);
  --color-primary-600: oklch(0.48 0.22 250);
  --color-primary-700: oklch(0.42 0.2 250);

  /* 폰트 (최대 2-3개) */
  --font-sans: "Pretendard", "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", monospace;

  /* 반경 */
  --radius: 0.5rem;  /* 8px */

  /* 그림자 */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}
```

| Token | Value |
|-------|-------|
| Spacing | 4px grid (`gap-2`=8px, `p-4`=16px) |
| Colors | Primary (action), Neutral (background), Semantic (state) |
| Font Size | `text-2xl` (heading), `text-base` (body), `text-sm` (secondary) |
| Container | `max-w-md` (forms), `max-w-3xl` (blog), `max-w-7xl` (dashboard) |

</design_tokens>

---

<patterns>

## Tailwind Patterns

### Buttons

```tsx
// Primary
<button className="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-lg
                   hover:bg-primary-700 focus:ring-2 focus:ring-primary-500 focus:ring-offset-2
                   disabled:opacity-50 disabled:cursor-not-allowed">
  저장하기
</button>

// Secondary
<button className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg
                   hover:bg-gray-50 focus:ring-2 focus:ring-gray-300">
  취소
</button>

// Destructive
<button className="px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-lg hover:bg-red-700">
  삭제
</button>

// 로딩 상태
<button disabled={isLoading} className="flex items-center gap-2">
  {isLoading && <Spinner className="w-4 h-4 animate-spin" />}
  {isLoading ? '저장 중...' : '저장하기'}
</button>
```

| Size | Class |
|------|-------|
| Small | `px-3 py-1.5 text-sm` |
| Medium | `px-4 py-2 text-base` |
| Large | `px-6 py-3 text-lg` |

### Input Fields

```tsx
// 기본
<div>
  <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
    이메일
  </label>
  <input
    id="email"
    type="email"
    className="w-full px-3 py-2 text-base border border-gray-300 rounded-lg
               focus:ring-2 focus:ring-blue-500 focus:border-blue-500
               placeholder:text-gray-400"
    placeholder="example@email.com"
  />
</div>

// 에러 상태
<input
  className="w-full px-3 py-2 border border-red-500 rounded-lg
             focus:ring-2 focus:ring-red-500"
  aria-invalid="true"
  aria-describedby="email-error"
/>
<p id="email-error" className="mt-1 text-sm text-red-600" role="alert">
  올바른 이메일을 입력하세요
</p>

// 아이콘 포함
<div className="relative">
  <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
  <input className="pl-10 pr-3 py-2 w-full border border-gray-300 rounded-lg" />
</div>
```

### Cards

```tsx
<div className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden">
  <div className="px-6 py-4 border-b border-gray-200">
    <h3 className="text-lg font-semibold text-gray-900">Title</h3>
  </div>
  <div className="px-6 py-4">
    <p className="text-base text-gray-600">Body content</p>
  </div>
  <div className="px-6 py-4 bg-gray-50 border-t border-gray-200">
    <button>Footer button</button>
  </div>
</div>
```

### Modals

```tsx
<div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
  <div className="bg-white rounded-lg shadow-xl w-full max-w-md">
    <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
      <h2 className="text-lg font-semibold text-gray-900">Title</h2>
      <button><XIcon className="w-5 h-5" /></button>
    </div>
    <div className="px-6 py-4">Body</div>
    <div className="px-6 py-4 bg-gray-50 flex justify-end gap-3">
      <button className="px-4 py-2 border border-gray-300 rounded-lg">Cancel</button>
      <button className="px-4 py-2 bg-primary-600 text-white rounded-lg">Confirm</button>
    </div>
  </div>
</div>
```

### Alerts

```tsx
// Success
<div className="p-4 bg-green-50 border border-green-200 rounded-lg flex gap-3">
  <CheckCircleIcon className="w-5 h-5 text-green-600 flex-shrink-0" />
  <p className="text-sm text-green-800">Saved successfully</p>
</div>

// Error
<div className="p-4 bg-red-50 border border-red-200 rounded-lg flex gap-3">
  <XCircleIcon className="w-5 h-5 text-red-600 flex-shrink-0" />
  <p className="text-sm text-red-800">Server error occurred. Please try again later.</p>
</div>

// Warning
<div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg flex gap-3">
  <AlertIcon className="w-5 h-5 text-yellow-600 flex-shrink-0" />
  <p className="text-sm text-yellow-800">Confirmation needed</p>
</div>
```

### Empty States

```tsx
<div className="py-12 text-center">
  <InboxIcon className="mx-auto w-12 h-12 text-gray-400" />
  <h3 className="mt-4 text-lg font-medium text-gray-900">No items yet</h3>
  <p className="mt-2 text-sm text-gray-600">Add your first item</p>
  <button className="mt-6 px-4 py-2 bg-primary-600 text-white rounded-lg">
    Add
  </button>
</div>
```

</patterns>

---

<safe_area>

## iOS Safe Area

### Installation & Setup

```bash
yarn add tailwindcss-safe-area
```

```tsx
// __root.tsx
export const Route = createRootRoute({
  head: () => ({
    meta: [{
      name: 'viewport',
      content: 'width=device-width, initial-scale=1, viewport-fit=cover',
    }],
  }),
})
```

### Utility Classes

| Class | Purpose |
|-------|---------|
| `pt-safe` | Top safe area (notch) |
| `pb-safe` | Bottom safe area (home indicator) |
| `px-safe` | Left/right safe area |
| `h-screen-safe` | Height excluding safe area |
| `min-h-screen-safe` | Minimum height |
| `pt-safe-or-4` | Safe area or 1rem (larger value) |
| `pb-safe-offset-4` | Safe area + 1rem |

### Layout Patterns

```tsx
// Basic app layout
<div className="min-h-screen-safe flex flex-col">
  <header className="pt-safe-or-2 px-safe-or-4 bg-white border-b">
    <nav className="h-14 flex items-center">Header</nav>
  </header>

  <main className="flex-1 px-safe-or-4 py-6">
    {children}
  </main>

  <footer className="pb-safe-or-2 px-safe-or-4 bg-white border-t">
    <nav className="h-14 flex items-center justify-around">Tab bar</nav>
  </footer>
</div>

// Fixed bottom button
<div className="fixed bottom-0 left-0 right-0 pb-safe-or-4 px-safe-or-4 bg-white border-t">
  <button className="w-full h-12 bg-primary-600 text-white rounded-lg">
    Confirm
  </button>
</div>

// Full screen modal
<div className="fixed inset-0 bg-white z-50">
  <div className="h-screen-safe flex flex-col p-safe">
    {children}
  </div>
</div>
```

### ✅ / ❌ Safe Area

```tsx
// ❌ Hidden by notch
<header className="fixed top-0">

// ✅ Safe area applied
<header className="fixed top-0 pt-safe">

// ❌ Overlaps with home indicator
<button className="fixed bottom-4">

// ✅ Safe area applied
<div className="fixed bottom-0 pb-safe-or-4">
  <button>...</button>
</div>

// ❌ Applied inside component
<Button className="pb-safe">Button</Button>

// ✅ Applied in layout
<div className="pb-safe-or-4">
  <Button>Button</Button>
</div>
```

</safe_area>

---

<guidelines>

## Core Principles

| Principle | Description |
|-----------|-------------|
| **Consistency** | Same role = Same style |
| **Simplicity** | Remove unnecessary elements |
| **Responsive** | Mobile first |
| **Accessibility** | WCAG AA (4.5:1+ contrast) |

### Colors (60-30-10)

| Ratio | Purpose | Example |
|-------|---------|---------|
| 60% | Background | `bg-white`, `bg-gray-50` |
| 30% | Secondary | Cards, sections |
| 10% | Accent | Primary buttons, CTA |

### Typography

| Purpose | Class | Size |
|---------|-------|------|
| Heading | `text-2xl` | 24px |
| Subheading | `text-xl` | 20px |
| Body | `text-base` | 16px |
| Secondary | `text-sm` | 14px |

### Spacing

| Purpose | Class | Size |
|---------|-------|------|
| Icon-text | `gap-1` | 4px |
| Inline elements | `gap-2` | 8px |
| Card inner | `p-4` | 16px |
| Card spacing | `gap-6` | 24px |
| Section spacing | `py-12` | 48px |

### Responsive

```tsx
<div className="p-4 md:p-6 lg:p-8">
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
```

| Breakpoint | Size | Purpose |
|------------|------|---------|
| `sm` | 640px | Mobile landscape |
| `md` | 768px | Tablet |
| `lg` | 1024px | Laptop |
| `xl` | 1280px | Desktop |

</guidelines>

---

<accessibility>

## Accessibility Checklist

```tsx
// ✅ Clear label
<label htmlFor="email">Email</label>
<input id="email" />

// ✅ Error connection
<input aria-invalid={hasError} aria-describedby="error" />
{hasError && <p id="error" role="alert">Error</p>}

// ✅ Focus indication
<button className="focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">

// ✅ Color + Icon
<span className="text-red-600 flex items-center gap-1">
  <XCircleIcon className="w-4 h-4" />
  Error
</span>

// ✅ Keyboard access
<div tabIndex={0} onKeyDown={handleKeyDown}>

// ❌ Do not remove focus
<button className="outline-none focus:outline-none">
```

| Item | Standard |
|------|----------|
| Text contrast | 4.5:1+ |
| Large text (18px+) | 3:1+ |
| Touch area | 44px × 44px+ |
| Focus indication | Always visible |

</accessibility>

---

<examples>

## Real-World Examples

### Form Layout

```tsx
<form className="max-w-md mx-auto space-y-6">
  {/* Input field */}
  <div>
    <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
      Name
    </label>
    <input
      id="name"
      type="text"
      className="w-full px-3 py-2 border border-gray-300 rounded-lg
                 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
    />
  </div>

  {/* Input with error */}
  <div>
    <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
      Email
    </label>
    <input
      id="email"
      type="email"
      className="w-full px-3 py-2 border border-red-500 rounded-lg
                 focus:ring-2 focus:ring-red-500"
      aria-invalid="true"
      aria-describedby="email-error"
    />
    <p id="email-error" className="mt-1 text-sm text-red-600" role="alert">
      Enter a valid email
    </p>
  </div>

  {/* Button group */}
  <div className="flex gap-3">
    <button
      type="button"
      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
    >
      Cancel
    </button>
    <button
      type="submit"
      className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
    >
      Save
    </button>
  </div>
</form>
```

### Card List

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {items.map((item) => (
    <div key={item.id} className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden">
      <img src={item.image} className="w-full h-48 object-cover" />
      <div className="p-4">
        <h3 className="text-lg font-semibold text-gray-900">{item.title}</h3>
        <p className="mt-2 text-sm text-gray-600">{item.description}</p>
        <button className="mt-4 w-full px-4 py-2 bg-primary-600 text-white rounded-lg">
          Learn more
        </button>
      </div>
    </div>
  ))}
</div>
```

### Dashboard Layout

```tsx
<div className="min-h-screen-safe bg-gray-50">
  {/* Header */}
  <header className="pt-safe-or-2 px-safe-or-4 bg-white border-b border-gray-200">
    <div className="h-16 flex items-center justify-between">
      <h1 className="text-xl font-bold">Dashboard</h1>
      <button>Menu</button>
    </div>
  </header>

  {/* Main */}
  <main className="px-safe-or-4 py-6">
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Stats cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg border border-gray-200">
          <p className="text-sm text-gray-600">Total users</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">1,234</p>
        </div>
        {/* ... */}
      </div>

      {/* Chart */}
      <div className="bg-white p-6 rounded-lg border border-gray-200">
        <h2 className="text-lg font-semibold text-gray-900">Activity</h2>
        {/* Chart component */}
      </div>
    </div>
  </main>
</div>
```

</examples>

---

<claude_requirements>

## Claude Code Requirements

**When Creating New Screens/Components:**

1. **Use Tailwind scale only** - No arbitrary values
2. **Mobile first** - Base styles → `sm:` → `md:` → `lg:`
3. **Safe area at layout level** - Not inside components
4. **Accessibility required** - Labels, contrast, focus, keyboard
5. **Consistent patterns** - Same element = Same class combination
6. **Loading/Error states** - Required for key actions
7. **Microcopy** - Suggest button/error messages together

**When Exceptions Occur:**
- Explain reason in code comments

**When Theme Extension Needed:**
- Suggest `@theme` extension instead of arbitrary values

</claude_requirements>
