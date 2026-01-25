# Design Tokens 추출 및 매핑

Figma Variables와 Styles를 Tailwind CSS v4 @theme 블록으로 정확히 변환하는 가이드.

**Tailwind v4 특징:**
- **No Config File**: tailwind.config.js 제거
- **@theme in CSS**: globals.css에 직접 토큰 정의
- **Auto Class Generation**: `@theme { --color-primary: #xxx; }` → `bg-primary` 자동

---

## Variables 추출

### Color Variables

**Figma 구조:**
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

**코드 변환:**

#### Tailwind v4 (@theme 블록)

**Vite** (src/index.css 또는 src/main.css):
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
  /* 동일한 구조 */
}
```

**자동 클래스 생성:**
```tsx
// @theme { --color-primary-500: #3182F6; } 정의 후
<div className="bg-primary-500">     {/* 배경색 */}
<div className="text-primary-500">   {/* 텍스트 */}
<div className="border-primary-500"> {/* 보더 */}
```

**병합:** 기존 globals.css 토큰과 Figma 추출 토큰을 @theme 블록에 함께 정의.

### Spacing Variables

**Figma 구조:**
```
spacing/
├─ xs  → 4px
├─ sm  → 8px
├─ md  → 16px
├─ lg  → 24px
├─ xl  → 32px
└─ 2xl → 48px
```

**코드 변환 (Tailwind v4):**

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

**사용:** `p-md` (16px), `gap-xs` (4px), `m-lg` (24px)

### Typography Variables

**Figma 구조:**
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

**코드 변환 (Tailwind v4):**

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

**사용:** `text-sm font-regular font-sans` (14px/400/Pretendard), `text-lg font-semibold` (18px/600)

---

## Styles 추출

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

**코드 변환:**

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
  제목
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

**RGB → HEX 변환:**
```
r: 0.133 × 255 = 34  → 22
g: 0.725 × 255 = 185 → B9
b: 0.478 × 255 = 122 → 7A

결과: #22B97A (정확히는 #22C55E)
```

**코드 사용:**
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

**코드 변환:**
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

## 변환 규칙

### 단위 변환

| Figma | CSS | 설명 |
|-------|-----|------|
| `16` | `16px` | 픽셀 그대로 |
| `{ unit: "PERCENT", value: 120 }` | `120%` 또는 `1.2` | line-height |
| `{ unit: "PERCENT", value: -2 }` | `-0.02em` | letter-spacing |
| `{ r: 0.5, g: 0.5, b: 0.5, a: 1 }` | `#808080` | RGB → HEX |
| `{ r: 0, g: 0, b: 0, a: 0.5 }` | `rgba(0,0,0,0.5)` | 투명도 있을 때 |

### 네이밍 규칙

| Figma | CSS Variable | Tailwind |
|-------|--------------|----------|
| `color/primary/500` | `--color-primary-500` | `primary-500` |
| `spacing/md` | `--spacing-md` | `md` (spacing) |
| `font/size/lg` | `--font-size-lg` | `text-lg` |

### 케이스 변환

```
Figma (PascalCase/slash): Heading/H1
CSS (kebab-case):         heading-h1
Tailwind (custom):        [28px] or heading-h1
```

---

## 워크플로우

| 단계 | 도구 | 출력 |
|------|------|------|
| Variables 추출 | get_variables | variables.json |
| CSS 변환 | Node 스크립트 | :root { --color-*: #...; } |
| Styles 추출 | get_styles | styles.json |
| @theme 생성 | 수동/스크립트 | @theme { --shadow-*: ...; } |
| 검증 | DevTools | className 값 일치 확인 |

---

## 베스트 프랙티스

### DO

| 원칙 | 예시 |
|------|------|
| **Variables 우선** | Figma Variables → CSS Variables → Tailwind |
| **정확한 값** | `#3182F6` (16진수 그대로) |
| **계층 유지** | `color/primary/500` → `--color-primary-500` |
| **코드 신택스 활용** | Figma codeSyntax 속성 참조 |

### DON'T

| 금지 사항 | 이유 |
|----------|------|
| **근사치 사용** | `#3182F6` → `bg-blue-500` (다름) |
| **임의 네이밍** | Figma 네이밍 구조 무시 |
| **하드코딩** | Variables 대신 직접 값 사용 |

---

## 도구

### Color 변환

```js
// RGB (0-1) → HEX
function rgbToHex(r, g, b) {
  const toHex = (n) => Math.round(n * 255).toString(16).padStart(2, '0')
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase()
}

// 사용
rgbToHex(0.192, 0.51, 0.965) // "#3182F6"
```

### Letter Spacing 변환

```js
// Figma PERCENT → em
function percentToEm(percent) {
  return (percent / 100).toFixed(3) + 'em'
}

// 사용
percentToEm(-2) // "-0.02em"
```

### Line Height 변환

```js
// Figma pixels → CSS
function lineHeight(fontSize, lineHeightPx) {
  const ratio = lineHeightPx / fontSize
  return `${lineHeightPx}px /* ${(ratio * 100).toFixed(1)}% */`
}

// 사용
lineHeight(28, 36) // "36px /* 128.6% */"
```

---

## 예제

Figma Variables → @theme 블록 → 자동 클래스 생성:

```css
@theme { --color-primary-500: #3182F6; }
```
```tsx
<button className="bg-primary-500">버튼</button>
```

---

---

## Tailwind v4 Migration

| v3 | v4 |
|-----|-----|
| `tailwind.config.js` | 없음 (CSS로 이동) |
| `theme.extend` in JS | `@theme` in CSS |
| `@tailwind base/...` | `@import "tailwindcss"` |

**globals.css 위치:** Vite(`src/index.css`), Next.js App(`app/globals.css`), Pages(`styles/globals.css`)

---

## 참조

- [Figma Variables API](https://www.figma.com/developers/api#variables)
- [Design Tokens with Figma](https://blog.prototypr.io/design-tokens-with-figma-aef25c42430f)
- [Tokens Studio Plugin](https://docs.tokens.studio)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs/v4-beta)
