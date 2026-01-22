# Design Tokens Extraction and Mapping

Guide for precisely converting Figma Variables and Styles to Tailwind CSS v4 @theme blocks.

**Tailwind v4 Characteristics:**
- **No Config File**: Remove tailwind.config.js
- **@theme in CSS**: Define tokens directly in globals.css
- **Auto Class Generation**: `@theme { --color-primary: #xxx; }` → `bg-primary` generated automatically

---

## Variables Extraction

### Color Variables

**Figma Structure:**
```
color/
├─ primary/
│  ├─ 50  → #EFF6FF
│  ├─ 500 → #3182F6
│  └─ 900 → #1E3A8A
├─ secondary/
│  ├─ 50  → #F8FAFC
│  └─ 500 → #64748B
└─ semantic/
   ├─ success → #22C55E
   ├─ error   → #EF4444
   └─ warning → #F59E0B
```

**Code Conversion:**

#### Tailwind v4 (@theme block)

**Vite** (src/index.css or src/main.css):
```css
@import "tailwindcss";

@theme {
  /* Primary */
  --color-primary-50: #EFF6FF;
  --color-primary-500: #3182F6;
  --color-primary-900: #1E3A8A;

  /* Secondary */
  --color-secondary-50: #F8FAFC;
  --color-secondary-500: #64748B;

  /* Semantic */
  --color-success: #22C55E;
  --color-error: #EF4444;
  --color-warning: #F59E0B;
}
```

**Next.js** (app/globals.css):
```css
@import "tailwindcss";

@theme {
  /* Same structure */
}
```

**Auto Class Generation:**
```tsx
// After @theme { --color-primary-500: #3182F6; }
<div className="bg-primary-500">     {/* Background color */}
<div className="text-primary-500">   {/* Text color */}
<div className="border-primary-500"> {/* Border color */}
```

**Merge:** Define both existing globals.css tokens and Figma-extracted tokens in @theme block together.

### Spacing Variables

**Figma Structure:**
```
spacing/
├─ xs  → 4px
├─ sm  → 8px
├─ md  → 16px
├─ lg  → 24px
├─ xl  → 32px
└─ 2xl → 48px
```

**Code Conversion (Tailwind v4):**

```css
@import "tailwindcss";

@theme {
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-2xl: 48px;
}
```

**Usage:** `p-md` (16px), `gap-xs` (4px), `m-lg` (24px)

### Typography Variables

**Figma Structure:**
```
font/
├─ size/
│  ├─ xs  → 12px
│  ├─ sm  → 14px
│  ├─ md  → 16px
│  └─ lg  → 18px
├─ family/
│  ├─ sans → Pretendard
│  └─ mono → JetBrains Mono
└─ weight/
   ├─ regular  → 400
   ├─ medium   → 500
   ├─ semibold → 600
   └─ bold     → 700
```

**Code Conversion (Tailwind v4):**

```css
@import "tailwindcss";

@theme {
  /* Size */
  --font-size-xs: 12px;
  --font-size-sm: 14px;
  --font-size-md: 16px;
  --font-size-lg: 18px;

  /* Family */
  --font-sans: Pretendard, -apple-system, sans-serif;
  --font-mono: "JetBrains Mono", monospace;

  /* Weight */
  --font-weight-regular: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
}
```

**Usage:** `text-sm font-regular font-sans` (14px/400/Pretendard), `text-lg font-semibold` (18px/600)

---

## Styles Extraction

### Text Styles

**Figma Text Style:**
```json
{
  "name": "Heading/H1",
  "fontSize": 28,
  "fontFamily": "Pretendard",
  "fontWeight": 600,
  "lineHeight": { "unit": "PIXELS", "value": 36 },
  "letterSpacing": { "unit": "PERCENT", "value": -2 },
  "textCase": "ORIGINAL",
  "textDecoration": "NONE"
}
```

**Code Conversion:**

#### CSS Class

```css
.heading-h1 {
  font-family: 'Pretendard', sans-serif;
  font-size: 28px;
  font-weight: 600;
  line-height: 36px; /* 128.6% */
  letter-spacing: -0.02em; /* -2% → -0.02em */
}
```

#### Tailwind

```tsx
<h1 className="font-sans text-[28px] font-semibold leading-[36px] tracking-[-0.02em]">
  Heading
</h1>
```

#### React Component

```tsx
const H1 = ({ children }: { children: React.ReactNode }) => (
  <h1 className="font-sans text-[28px] font-semibold leading-[36px] tracking-[-0.02em]">
    {children}
  </h1>
)
```

### Color Styles

**Figma Color Style:**
```json
{
  "name": "Semantic/Success",
  "type": "FILL",
  "color": { "r": 0.133, "g": 0.725, "b": 0.478, "a": 1 }
}
```

**RGB → HEX Conversion:**
```
r: 0.133 × 255 = 34  → 22
g: 0.725 × 255 = 185 → B9
b: 0.478 × 255 = 122 → 7A

Result: #22B97A (more accurately: #22C55E)
```

**Code Usage:**
```css
.text-success {
  color: #22C55E;
}

.bg-success {
  background-color: #22C55E;
}
```

### Effect Styles

**Shadow:**
```json
{
  "name": "Shadow/Medium",
  "type": "DROP_SHADOW",
  "color": { "r": 0, "g": 0, "b": 0, "a": 0.1 },
  "offset": { "x": 0, "y": 4 },
  "radius": 8,
  "spread": 0
}
```

**Code Conversion:**
```css
.shadow-medium {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
```

```css
/* Tailwind v4 @theme */
@theme {
  --shadow-medium: 0 4px 8px rgba(0, 0, 0, 0.1);
}
```

---

## Conversion Rules

### Unit Conversion

| Figma | CSS | Description |
|-------|-----|-------------|
| `16` | `16px` | Pixels as-is |
| `{ unit: "PERCENT", value: 120 }` | `120%` or `1.2` | line-height |
| `{ unit: "PERCENT", value: -2 }` | `-0.02em` | letter-spacing |
| `{ r: 0.5, g: 0.5, b: 0.5, a: 1 }` | `#808080` | RGB → HEX |
| `{ r: 0, g: 0, b: 0, a: 0.5 }` | `rgba(0,0,0,0.5)` | When transparency present |

### Naming Rules

| Figma | CSS Variable | Tailwind |
|-------|--------------|----------|
| `color/primary/500` | `--color-primary-500` | `primary-500` |
| `spacing/md` | `--spacing-md` | `md` (spacing) |
| `font/size/lg` | `--font-size-lg` | `text-lg` |

### Case Conversion

```
Figma (PascalCase/slash): Heading/H1
CSS (kebab-case):         heading-h1
Tailwind (custom):        [28px] or heading-h1
```

---

## Workflow

| Step | Tool | Output |
|------|------|--------|
| Extract Variables | get_variables | variables.json |
| Convert CSS | Node script | :root { --color-*: #...; } |
| Extract Styles | get_styles | styles.json |
| Generate @theme | Manual/script | @theme { --shadow-*: ...; } |
| Validate | DevTools | className values match |

---

## Best Practices

### DO

| Principle | Example |
|-----------|---------|
| **Variables First** | Figma Variables → CSS Variables → Tailwind |
| **Exact Values** | `#3182F6` (hex as-is) |
| **Maintain Hierarchy** | `color/primary/500` → `--color-primary-500` |
| **Use Code Syntax** | Reference Figma codeSyntax attribute |

### DON'T

| Forbidden | Reason |
|-----------|--------|
| **Use Approximations** | `#3182F6` → `bg-blue-500` (different) |
| **Arbitrary Naming** | Ignore Figma naming structure |
| **Hardcode Values** | Use Variables instead of direct values |

---

## Tools

### Color Conversion

```js
// RGB (0-1) → HEX
function rgbToHex(r, g, b) {
  const toHex = (n) => Math.round(n * 255).toString(16).padStart(2, '0')
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase()
}

// Usage
rgbToHex(0.192, 0.51, 0.965) // "#3182F6"
```

### Letter Spacing Conversion

```js
// Figma PERCENT → em
function percentToEm(percent) {
  return (percent / 100).toFixed(3) + 'em'
}

// Usage
percentToEm(-2) // "-0.02em"
```

### Line Height Conversion

```js
// Figma pixels → CSS
function lineHeight(fontSize, lineHeightPx) {
  const ratio = lineHeightPx / fontSize
  return `${lineHeightPx}px /* ${(ratio * 100).toFixed(1)}% */`
}

// Usage
lineHeight(28, 36) // "36px /* 128.6% */"
```

---

## Example

Figma Variables → @theme block → Auto class generation:

```css
@theme { --color-primary-500: #3182F6; }
```
```tsx
<button className="bg-primary-500">Button</button>
```

---

## Tailwind v4 Migration

| v3 | v4 |
|-----|-----|
| `tailwind.config.js` | None (moved to CSS) |
| `theme.extend` in JS | `@theme` in CSS |
| `@tailwind base/...` | `@import "tailwindcss"` |

**globals.css location:** Vite(`src/index.css`), Next.js App(`app/globals.css`), Pages(`styles/globals.css`)

---

## References

- [Figma Variables API](https://www.figma.com/developers/api#variables)
- [Design Tokens with Figma](https://blog.prototypr.io/design-tokens-with-figma-aef25c42430f)
- [Tokens Studio Plugin](https://docs.tokens.studio)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs/v4-beta)
