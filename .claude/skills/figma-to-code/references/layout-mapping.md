# Auto Layout → CSS 매핑

Figma Auto Layout을 Flexbox/Grid로 정확히 변환하는 가이드.

---

## Auto Layout 기본 개념

Figma Auto Layout은 CSS Flexbox와 1:1 대응됨.

### 핵심 속성

| Figma 속성 | CSS 속성 | 설명 |
|-----------|----------|------|
| **layoutMode** | `flex-direction` | Horizontal/Vertical |
| **primaryAxisAlignItems** | `justify-content` | 주축 정렬 |
| **counterAxisAlignItems** | `align-items` | 교차축 정렬 |
| **itemSpacing** | `gap` | 요소 간 간격 |
| **padding** | `padding` | 내부 여백 |

---

## Layout Mode

### Horizontal (가로)

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

### Vertical (세로)

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

## Primary Axis Alignment (주축 정렬)

### Horizontal Layout

| Figma | CSS | Tailwind | 설명 |
|-------|-----|----------|------|
| `MIN` | `justify-content: flex-start` | `justify-start` | 왼쪽 |
| `CENTER` | `justify-content: center` | `justify-center` | 중앙 |
| `MAX` | `justify-content: flex-end` | `justify-end` | 오른쪽 |
| `SPACE_BETWEEN` | `justify-content: space-between` | `justify-between` | 양끝 |

**예시:**

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
  <button>버튼 1</button>
  <button>버튼 2</button>
</div>
```

### Vertical Layout

| Figma | CSS | Tailwind | 설명 |
|-------|-----|----------|------|
| `MIN` | `justify-content: flex-start` | `justify-start` | 위 |
| `CENTER` | `justify-content: center` | `justify-center` | 중앙 |
| `MAX` | `justify-content: flex-end` | `justify-end` | 아래 |
| `SPACE_BETWEEN` | `justify-content: space-between` | `justify-between` | 양끝 |

---

## Counter Axis Alignment (교차축 정렬)

### Horizontal Layout

| Figma | CSS | Tailwind | 설명 |
|-------|-----|----------|------|
| `MIN` | `align-items: flex-start` | `items-start` | 위 |
| `CENTER` | `align-items: center` | `items-center` | 중앙 |
| `MAX` | `align-items: flex-end` | `items-end` | 아래 |
| `BASELINE` | `align-items: baseline` | `items-baseline` | 베이스라인 |

**예시:**

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
  <nav>메뉴</nav>
  <button>로그인</button>
</div>
```

### Vertical Layout

| Figma | CSS | Tailwind | 설명 |
|-------|-----|----------|------|
| `MIN` | `align-items: flex-start` | `items-start` | 왼쪽 |
| `CENTER` | `align-items: center` | `items-center` | 중앙 |
| `MAX` | `align-items: flex-end` | `items-end` | 오른쪽 |

---

## Item Spacing (간격)

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

## Padding (내부 여백)

### 균일한 Padding

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
  컨텐츠
</div>
```

### 비균일한 Padding

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
  컨텐츠
</div>
```

**개별 지정:**
```tsx
<div className="pl-[16px] pr-[16px] pt-[12px] pb-[12px]">
  컨텐츠
</div>
```

---

## Resizing (크기 조정)

### Fixed (고정)

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
  버튼
</button>
```

### Hug Contents (콘텐츠 맞춤)

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
  버튼 텍스트
</button>
```

### Fill Container (채우기)

**Figma:**
```json
{
  "layoutGrow": 1
}
```

**Tailwind:**
```tsx
<div className="flex-1">
  컨텐츠
</div>
```

---

## 복합 예제

### 버튼

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

**코드:**
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
  <span>버튼</span>
</button>
```

### 카드

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

**코드:**
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
  <h3 className="text-[18px] font-semibold">카드 제목</h3>
  <p className="text-[14px] text-gray-700">카드 내용</p>
  <button className="text-[14px] text-blue-500 font-medium">자세히</button>
</div>
```

### 헤더 (Horizontal + Space Between)

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

**코드:**
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
    <a href="/">홈</a>
    <a href="/about">소개</a>
  </nav>
  <button className="px-[16px] py-[8px] bg-blue-500 text-white rounded-lg">
    로그인
  </button>
</header>
```

---

## 중첩 Auto Layout

### 리스트 아이템

**Figma 구조:**
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

**코드:**
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
      <div className="text-[14px] font-semibold">제목</div>
      <div className="text-[13px] text-gray-600">설명</div>
    </div>
  </div>

  {/* Right */}
  <div className="flex flex-row items-center gap-[8px]">
    <span className="text-[14px] font-semibold">15,000원</span>
    <svg className="w-5 h-5 text-gray-400" />
  </div>
</div>
```

---

## Constraints (제약 조건)

Figma Constraints는 반응형 동작을 정의함.

| Figma Constraint | CSS 대응 |
|-----------------|----------|
| **Left + Right** | `width: 100%` (부모 너비 채움) |
| **Left** | `margin-right: auto` (왼쪽 고정) |
| **Right** | `margin-left: auto` (오른쪽 고정) |
| **Center** | `margin: 0 auto` (중앙 정렬) |
| **Scale** | `width: 50%` (비율 유지) |

**예시:**

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
// 반응형: 부모 너비 채움
<div className="w-full">
  컨텐츠
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

## 베스트 프랙티스

### DO

| 원칙 | 설명 |
|------|------|
| **Auto Layout 우선** | Absolute 대신 Flexbox 사용 |
| **정확한 gap** | `gap-4` 대신 `gap-[18px]` |
| **Hug → auto** | Hug Contents → `w-auto h-auto` |
| **Fill → flex-1** | Fill Container → `flex-1` |

### DON'T

| 금지 사항 | 이유 |
|----------|------|
| **임의 margin** | Auto Layout은 gap 사용 |
| **float 사용** | Flexbox로 충분 |
| **inline-block** | Flex item으로 처리 |

---

## 변환 체크리스트

```
□ layoutMode → flex-direction
□ primaryAxisAlignItems → justify-content
□ counterAxisAlignItems → align-items
□ itemSpacing → gap (정확한 px)
□ padding → p-[Npx] / px-[Npx] py-[Npx]
□ layoutGrow → flex-1 / flex-0
□ width/height → w-[Npx] h-[Npx]
□ cornerRadius → rounded-[Npx]
□ fills → bg-[#HEX]
□ strokes → border border-[#HEX]
```

---

## 참조

- [Figma Auto Layout](https://help.figma.com/hc/en-us/articles/360040451373)
- [CSS Flexbox Guide](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)
- [Tailwind Flexbox](https://tailwindcss.com/docs/flex)
