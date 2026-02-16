# Design Systems

<typography>

## 타이포그래피

### Type Scale

| 용도 | 크기 | 클래스 | 사용처 |
|------|------|--------|--------|
| **Display** | 48-60px | `text-5xl sm:text-6xl` | 랜딩 페이지 히어로 |
| **H1** | 36px | `text-3xl` | 페이지 제목 |
| **H2** | 24px | `text-xl` | 섹션 제목 |
| **H3** | 18px | `text-lg` | 카드 제목 |
| **Body** | 16px | `text-base` | 본문 |
| **Small** | 14px | `text-sm` | 캡션, 레이블 |

### Font Stack

```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
```

</typography>

---

<color_system>

## 컬러 시스템

### 60-30-10 규칙

| 비율 | 색상 | 용도 |
|------|------|------|
| **60%** | Neutral | 배경, 텍스트 |
| **30%** | Secondary | 보조 요소 |
| **10%** | Primary | CTA, 강조 |

### 시맨틱 컬러

```tsx
{/* Success */}
<div className="bg-green-50 border-green-200 text-green-900" />

{/* Error */}
<div className="bg-red-50 border-red-200 text-red-900" />

{/* Warning */}
<div className="bg-yellow-50 border-yellow-200 text-yellow-900" />

{/* Info */}
<div className="bg-blue-50 border-blue-200 text-blue-900" />
```

</color_system>

---

<grid_system>

## 그리드 시스템

### 12열 그리드

```tsx
<div className="grid grid-cols-12 gap-6">
  <div className="col-span-12 md:col-span-8">Main content</div>
  <div className="col-span-12 md:col-span-4">Sidebar</div>
</div>
```

### 간격 (8px 기본 단위)

| 크기 | px | 클래스 | 용도 |
|------|---|--------|------|
| **xs** | 4px | `gap-1` | 아이콘-텍스트 |
| **sm** | 8px | `gap-2` | 폼 레이블-입력 |
| **md** | 16px | `gap-4` | 카드 내부 |
| **lg** | 24px | `gap-6` | 섹션 간 |
| **xl** | 32px | `gap-8` | 페이지 여백 |

</grid_system>

---

<responsive_design>

## 반응형 디자인

### Breakpoints

| 이름 | 최소 너비 | 디바이스 |
|------|----------|---------|
| **sm** | 640px | 모바일 가로 |
| **md** | 768px | 태블릿 세로 |
| **lg** | 1024px | 태블릿 가로 |
| **xl** | 1280px | 데스크톱 |
| **2xl** | 1536px | 대형 데스크톱 |

### Mobile-First 패턴

```tsx
{/* 모바일: 1열, 태블릿: 2열, 데스크톱: 3열 */}
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>

{/* 모바일: 숨김, 데스크톱: 표시 */}
<aside className="hidden lg:block w-64 border-r" />

{/* 모바일: 표시, 데스크톱: 숨김 */}
<nav className="lg:hidden fixed bottom-0 inset-x-0 h-16 border-t" />
```

</responsive_design>
