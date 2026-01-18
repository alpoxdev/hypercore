# 반응형 패턴

<breakpoints>

```
sm: 640px   | md: 768px   | lg: 1024px  | xl: 1280px
모바일       | 태블릿      | 소형 데스크톱 | 데스크톱
```

</breakpoints>

---

<navigation>

**데스크톱:** 상단 헤더 + 좌측 사이드바
**태블릿:** 상단 헤더 + 햄버거 메뉴 (오버레이)
**모바일:** 상단 헤더 + 하단 탭바

```tsx
{/* 사이드바: 데스크톱만 */}
<aside className="hidden lg:block w-60" />

{/* 하단 탭바: 모바일만 */}
<nav className="lg:hidden fixed bottom-0 w-full" />
```

</navigation>

---

<grid>

**데스크톱:** 3-4 컬럼 | **태블릿:** 2 컬럼 | **모바일:** 1-2 컬럼

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

</grid>

---

<table_to_card>

```tsx
{/* 데스크톱: 테이블 */}
<table className="hidden md:table w-full">
  <thead><tr><th>이름</th><th>이메일</th></tr></thead>
  <tbody>
    {users.map(user => <tr key={user.id}><td>{user.name}</td></tr>)}
  </tbody>
</table>

{/* 모바일: 카드 */}
<div className="md:hidden space-y-3">
  {users.map(user => (
    <div key={user.id} className="p-4 border rounded-lg">
      <div className="font-semibold">{user.name}</div>
      <div className="text-sm text-gray-600">{user.email}</div>
    </div>
  ))}
</div>
```

</table_to_card>

---

<touch_optimization>

**최소 터치 타겟:** 44px × 44px
**버튼 간 간격:** 최소 8px

```tsx
{/* ✅ 충분한 터치 영역 */}
<button className="h-11 px-4">버튼</button>

{/* ❌ 너무 작음 */}
<button className="h-6 px-2 text-xs">버튼</button>
```

</touch_optimization>

---

<container_width>

| 용도 | max-w | 패딩 |
|------|-------|------|
| 대시보드 | max-w-7xl | px-4 md:px-6 lg:px-8 |
| 콘텐츠 | max-w-3xl | px-4 md:px-6 |
| 폼/설정 | max-w-md | px-4 |

</container_width>

---

<spacing>

**패딩:** 모바일 px-4 (16px) | 태블릿 px-6 (24px) | 데스크톱 px-8 (32px)
**섹션 간:** space-y-8 md:space-y-12 (32px → 48px)
**카드 내부:** p-4 md:p-6 (16px → 24px)

```tsx
<div className="px-4 md:px-6 lg:px-8">
  <div className="space-y-8 md:space-y-12">
    <section className="p-4 md:p-6 border rounded-lg" />
  </div>
</div>
```

</spacing>
