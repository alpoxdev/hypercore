# Auto Layout → CSS Mapping

Guide for precisely converting Figma Auto Layout to Flexbox/Grid.

---

## Auto Layout Fundamentals

Figma Auto Layout maps 1:1 to CSS Flexbox.

### Core Properties

| Figma Property | CSS Property | Description |
|---------------|----------|-------------|
| **layoutMode** | `flex-direction` | Horizontal/Vertical |
| **primaryAxisAlignItems** | `justify-content` | Main axis alignment |
| **counterAxisAlignItems** | `align-items` | Cross axis alignment |
| **itemSpacing** | `gap` | Element spacing |
| **padding** | `padding` | Internal padding |

---

## Layout Mode

### Horizontal (Row)

**Figma:**
```json
{
  "layoutMode": "HORIZONTAL"
}
```

**CSS:**
```css
.container {
  display: flex;
  flex-direction: row;
}
```

**Tailwind:**
```tsx
<div className="flex flex-row">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

### Vertical (Column)

**Figma:**
```json
{
  "layoutMode": "VERTICAL"
}
```

**CSS:**
```css
.container {
  display: flex;
  flex-direction: column;
}
```

**Tailwind:**
```tsx
<div className="flex flex-col">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

---

## Primary Axis Alignment (Main Axis)

### Horizontal Layout

| Figma | CSS | Tailwind | Description |
|-------|-----|----------|-------------|
| `MIN` | `justify-content: flex-start` | `justify-start` | Left |
| `CENTER` | `justify-content: center` | `justify-center` | Center |
| `MAX` | `justify-content: flex-end` | `justify-end` | Right |
| `SPACE_BETWEEN` | `justify-content: space-between` | `justify-between` | Both ends |

**Example:**

```json
// Figma
{
  "layoutMode": "HORIZONTAL",
  "primaryAxisAlignItems": "CENTER"
}
```

```tsx
// React
<div className="flex flex-row justify-center">
  <button>Button 1</button>
  <button>Button 2</button>
</div>
```

### Vertical Layout

| Figma | CSS | Tailwind | Description |
|-------|-----|----------|-------------|
| `MIN` | `justify-content: flex-start` | `justify-start` | Top |
| `CENTER` | `justify-content: center` | `justify-center` | Center |
| `MAX` | `justify-content: flex-end` | `justify-end` | Bottom |
| `SPACE_BETWEEN` | `justify-content: space-between` | `justify-between` | Both ends |

---

## Counter Axis Alignment (Cross Axis)

### Horizontal Layout

| Figma | CSS | Tailwind | Description |
|-------|-----|----------|-------------|
| `MIN` | `align-items: flex-start` | `items-start` | Top |
| `CENTER` | `align-items: center` | `items-center` | Center |
| `MAX` | `align-items: flex-end` | `items-end` | Bottom |
| `BASELINE` | `align-items: baseline` | `items-baseline` | Baseline |

**Example:**

```json
// Figma
{
  "layoutMode": "HORIZONTAL",
  "primaryAxisAlignItems": "SPACE_BETWEEN",
  "counterAxisAlignItems": "CENTER"
}
```

```tsx
// React
<div className="flex flex-row justify-between items-center">
  <img src="/logo.png" alt="Logo" />
  <nav>Menu</nav>
  <button>Login</button>
</div>
```

### Vertical Layout

| Figma | CSS | Tailwind | Description |
|-------|-----|----------|-------------|
| `MIN` | `align-items: flex-start` | `items-start` | Left |
| `CENTER` | `align-items: center` | `items-center` | Center |
| `MAX` | `align-items: flex-end` | `items-end` | Right |

---

## Item Spacing (Gap)

**Figma:**
```json
{
  "itemSpacing": 16
}
```

**CSS:**
```css
.container {
  gap: 16px;
}
```

**Tailwind:**
```tsx
<div className="flex gap-[16px]">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

---

## Padding (Internal Spacing)

### Uniform Padding

**Figma:**
```json
{
  "paddingLeft": 24,
  "paddingRight": 24,
  "paddingTop": 24,
  "paddingBottom": 24
}
```

**Tailwind:**
```tsx
<div className="p-[24px]">
  Content
</div>
```

### Non-uniform Padding

**Figma:**
```json
{
  "paddingLeft": 16,
  "paddingRight": 16,
  "paddingTop": 12,
  "paddingBottom": 12
}
```

**Tailwind:**
```tsx
<div className="px-[16px] py-[12px]">
  Content
</div>
```

**Individual specification:**
```tsx
<div className="pl-[16px] pr-[16px] pt-[12px] pb-[12px]">
  Content
</div>
```

---

## Resizing (Size Adjustment)

### Fixed (Set Size)

**Figma:**
```json
{
  "layoutGrow": 0,
  "width": 120,
  "height": 44
}
```

**Tailwind:**
```tsx
<button className="w-[120px] h-[44px]">
  Button
</button>
```

### Hug Contents (Fit Content)

**Figma:**
```json
{
  "layoutGrow": 0,
  "layoutSizingHorizontal": "HUG",
  "layoutSizingVertical": "HUG"
}
```

**Tailwind:**
```tsx
<button className="w-auto h-auto">
  Button text
</button>
```

### Fill Container (Expand)

**Figma:**
```json
{
  "layoutGrow": 1
}
```

**Tailwind:**
```tsx
<div className="flex-1">
  Content
</div>
```

---

## Complex Examples

### Button

**Figma:**
```json
{
  "name": "Button/Primary",
  "type": "FRAME",
  "layoutMode": "HORIZONTAL",
  "primaryAxisAlignItems": "CENTER",
  "counterAxisAlignItems": "CENTER",
  "itemSpacing": 8,
  "paddingLeft": 16,
  "paddingRight": 16,
  "paddingTop": 12,
  "paddingBottom": 12,
  "width": 120,
  "height": 44,
  "fills": [{ "color": { "r": 0.192, "g": 0.51, "b": 0.965 } }],
  "cornerRadius": 8
}
```

**Code:**
```tsx
<button className="
  flex flex-row items-center justify-center
  gap-[8px]
  px-[16px] py-[12px]
  w-[120px] h-[44px]
  bg-[#3182F6]
  rounded-[8px]
  text-white font-semibold text-[14px]
">
  <svg className="w-5 h-5" />
  <span>Button</span>
</button>
```

### Card

**Figma:**
```json
{
  "name": "Card",
  "type": "FRAME",
  "layoutMode": "VERTICAL",
  "primaryAxisAlignItems": "MIN",
  "counterAxisAlignItems": "MIN",
  "itemSpacing": 16,
  "paddingLeft": 24,
  "paddingRight": 24,
  "paddingTop": 24,
  "paddingBottom": 24,
  "layoutSizingHorizontal": "FILL",
  "layoutSizingVertical": "HUG",
  "fills": [{ "color": { "r": 1, "g": 1, "b": 1 } }],
  "strokes": [{ "color": { "r": 0.9, "g": 0.9, "b": 0.9 } }],
  "cornerRadius": 12
}
```

**Code:**
```tsx
<div className="
  flex flex-col items-start justify-start
  gap-[16px]
  p-[24px]
  w-full
  bg-white
  border border-gray-200
  rounded-[12px]
">
  <h3 className="text-[18px] font-semibold">Card Title</h3>
  <p className="text-[14px] text-gray-700">Card content</p>
  <button className="text-[14px] text-blue-500 font-medium">Details</button>
</div>
```

### Header (Horizontal + Space Between)

**Figma:**
```json
{
  "name": "Header",
  "layoutMode": "HORIZONTAL",
  "primaryAxisAlignItems": "SPACE_BETWEEN",
  "counterAxisAlignItems": "CENTER",
  "itemSpacing": 24,
  "paddingLeft": 32,
  "paddingRight": 32,
  "paddingTop": 16,
  "paddingBottom": 16,
  "layoutSizingHorizontal": "FILL",
  "height": 64
}
```

**Code:**
```tsx
<header className="
  flex flex-row justify-between items-center
  gap-[24px]
  px-[32px] py-[16px]
  w-full h-[64px]
  bg-white border-b
">
  <img src="/logo.svg" alt="Logo" className="h-8" />
  <nav className="flex gap-[24px]">
    <a href="/">Home</a>
    <a href="/about">About</a>
  </nav>
  <button className="px-[16px] py-[8px] bg-blue-500 text-white rounded-lg">
    Login
  </button>
</header>
```

---

## Nested Auto Layout

### List Item

**Figma Structure:**
```
Frame "ListItem" (Horizontal, Space Between, Center)
├─ Frame "Left" (Horizontal, Center, gap: 12px)
│  ├─ Image "Thumbnail"
│  └─ Frame "Text" (Vertical, gap: 4px)
│     ├─ Text "Title"
│     └─ Text "Description"
└─ Frame "Right" (Horizontal, Center, gap: 8px)
   ├─ Text "Price"
   └─ Icon "Arrow"
```

**Code:**
```tsx
<div className="
  flex flex-row justify-between items-center
  p-[16px]
  hover:bg-gray-50 transition-colors
">
  {/* Left */}
  <div className="flex flex-row items-center gap-[12px]">
    <img src="/thumb.jpg" className="w-[48px] h-[48px] rounded-lg" />
    <div className="flex flex-col gap-[4px]">
      <div className="text-[14px] font-semibold">Title</div>
      <div className="text-[13px] text-gray-600">Description</div>
    </div>
  </div>

  {/* Right */}
  <div className="flex flex-row items-center gap-[8px]">
    <span className="text-[14px] font-semibold">$15.00</span>
    <svg className="w-5 h-5 text-gray-400" />
  </div>
</div>
```

---

## Constraints (Constraints)

Figma Constraints define responsive behavior.

| Figma Constraint | CSS Equivalent |
|-----------------|----------|
| **Left + Right** | `width: 100%` (fill parent width) |
| **Left** | `margin-right: auto` (fixed left) |
| **Right** | `margin-left: auto` (fixed right) |
| **Center** | `margin: 0 auto` (center alignment) |
| **Scale** | `width: 50%` (maintain ratio) |

**Example:**

```json
// Figma: Left + Right Constraint
{
  "constraints": {
    "horizontal": "LEFT_RIGHT",
    "vertical": "TOP"
  }
}
```

```tsx
// Responsive: fill parent width
<div className="w-full">
  Content
</div>
```

---

## Absolute Positioning

**Figma:**
```json
{
  "layoutPositioning": "ABSOLUTE",
  "x": 20,
  "y": 20
}
```

**CSS:**
```css
.element {
  position: absolute;
  left: 20px;
  top: 20px;
}
```

**Tailwind:**
```tsx
<div className="absolute left-[20px] top-[20px]">
  Floating Element
</div>
```

---

## Best Practices

### DO

| Principle | Description |
|-----------|-------------|
| **Auto Layout First** | Use Flexbox instead of Absolute positioning |
| **Exact gap** | Use `gap-[18px]` not `gap-4` |
| **Hug → auto** | Hug Contents → `w-auto h-auto` |
| **Fill → flex-1** | Fill Container → `flex-1` |

### DON'T

| Forbidden | Reason |
|-----------|--------|
| **Arbitrary margin** | Auto Layout uses gap |
| **Use float** | Flexbox is sufficient |
| **Use inline-block** | Handle as flex item |

---

## Conversion Checklist

```
□ layoutMode → flex-direction
□ primaryAxisAlignItems → justify-content
□ counterAxisAlignItems → align-items
□ itemSpacing → gap (exact px)
□ padding → p-[Npx] / px-[Npx] py-[Npx]
□ layoutGrow → flex-1 / flex-0
□ width/height → w-[Npx] h-[Npx]
□ cornerRadius → rounded-[Npx]
□ fills → bg-[#HEX]
□ strokes → border border-[#HEX]
```

---

## References

- [Figma Auto Layout](https://help.figma.com/hc/en-us/articles/360040451373)
- [CSS Flexbox Guide](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)
- [Tailwind Flexbox](https://tailwindcss.com/docs/flex)
