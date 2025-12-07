# 간격과 레이아웃

## 8px 그리드

```css
1    → 4px    아주 작은 간격
2    → 8px    작은 간격
4    → 16px   기본 간격
6    → 24px   중간 간격
8    → 32px   큰 간격
12   → 48px   섹션 간격
16   → 64px   페이지 섹션
```

| 용도 | Tailwind | 크기 |
|------|----------|------|
| 아이콘-텍스트 | gap-1 | 4px |
| 인라인 요소 | gap-2 | 8px |
| 카드 내부 | p-4 | 16px |
| 카드 간격 | gap-6 | 24px |
| 섹션 간격 | py-12 | 48px |

## Padding vs Margin vs Gap

```tsx
// Padding (내부 여백)
<div className="p-4">     {/* 전체 16px */}
<div className="px-4 py-2"> {/* 좌우 16px, 상하 8px */}

// Margin (외부 여백)
<div className="mb-4">    {/* 아래 16px */}
<div className="mx-auto"> {/* 좌우 중앙 */}

// Gap (Flex/Grid 간격)
<div className="flex gap-4">
<div className="grid gap-6">
```

## 레이아웃 패턴

### 카드
```tsx
<div className="p-6 rounded-lg border">
  <h3 className="text-lg font-semibold mb-2">제목</h3>
  <p className="text-gray-600 mb-4">본문</p>
  <div className="flex gap-2">
    <button>취소</button>
    <button>확인</button>
  </div>
</div>
```

### 폼
```tsx
<form className="space-y-6">
  <div className="space-y-4">
    <div>
      <label className="block text-sm font-medium mb-1">이름</label>
      <input className="w-full px-3 py-2 border rounded" />
    </div>
  </div>
  <div className="flex justify-end gap-3">
    <button>취소</button>
    <button className="bg-blue-600 text-white">저장</button>
  </div>
</form>
```

### 네비게이션
```tsx
<nav className="px-4 py-3 border-b">
  <div className="max-w-6xl mx-auto flex items-center justify-between">
    <div>Logo</div>
    <div className="flex items-center gap-6">{/* 메뉴 */}</div>
    <div className="flex items-center gap-3">{/* 액션 */}</div>
  </div>
</nav>
```

## 반응형 간격

```tsx
<section className="py-8 md:py-12 lg:py-16">
  <div className="px-4 md:px-6 lg:px-8">
<div className="grid gap-4 md:gap-6 lg:gap-8">
```

## 시각적 그룹핑

```tsx
// ✅ 관련 요소 가깝게, 다른 그룹 멀리
<div className="mb-6">
  <h3 className="mb-2">제목</h3>   {/* 밀접: 8px */}
  <p>설명</p>
</div>                              {/* 분리: 24px */}
<div className="mb-6">
  <h3 className="mb-2">다른 제목</h3>
  <p>다른 설명</p>
</div>
```

## 컨테이너

```tsx
<div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"> {/* 기본 */}
<div className="max-w-3xl mx-auto px-4"> {/* 좁은 (블로그) */}
```

```css
max-w-md   448px   폼
max-w-lg   512px   모달
max-w-3xl  768px   블로그
max-w-5xl  1024px  표준
max-w-7xl  1280px  대시보드
```

## 체크리스트

- [ ] 8px 배수 사용
- [ ] 관련 요소 가깝게, 다른 그룹 멀리
- [ ] 반응형 간격 적용
- [ ] 터치 영역 최소 44px
