# 간격과 레이아웃

> **상위 문서**: [UI/UX 디자인 가이드](./index.md)

간격(Spacing)은 요소들 사이의 여백을 말합니다. 적절한 간격은 콘텐츠를 읽기 쉽게 만들고 시각적 계층을 형성합니다.

## 왜 간격이 중요한가?

### 간격 없는 디자인 vs 적절한 간격

```
❌ 간격 없음                    ✅ 적절한 간격
┌──────────────────┐           ┌──────────────────┐
│제목본문텍스트버튼│           │                  │
│모든것이붙어있음  │           │    제목          │
│읽기가어려움      │           │                  │
└──────────────────┘           │    본문 텍스트   │
                               │                  │
                               │    [ 버튼 ]      │
                               │                  │
                               └──────────────────┘
```

## 8px 그리드 시스템

### 왜 8px인가?

- 대부분의 화면 해상도에서 깔끔하게 나눠짐
- 계산이 쉬움 (8, 16, 24, 32...)
- 반응형 디자인에 유리

### Tailwind 간격 스케일

```css
/* 기본 단위: 1 = 0.25rem = 4px */

/* 주로 사용하는 간격 */
1    → 4px   (0.25rem)   아주 작은 간격
2    → 8px   (0.5rem)    작은 간격
3    → 12px  (0.75rem)
4    → 16px  (1rem)      기본 간격
5    → 20px  (1.25rem)
6    → 24px  (1.5rem)    중간 간격
8    → 32px  (2rem)      큰 간격
10   → 40px  (2.5rem)
12   → 48px  (3rem)      섹션 간격
16   → 64px  (4rem)      페이지 섹션
20   → 80px  (5rem)
24   → 96px  (6rem)      대형 섹션
```

### 간격 사용 가이드

| 용도 | 간격 | Tailwind | 실제 크기 |
|------|------|----------|----------|
| 아이콘-텍스트 | xs | `gap-1` | 4px |
| 인라인 요소 | sm | `gap-2` | 8px |
| 폼 필드 내부 | md | `p-3` | 12px |
| 카드 내부 | lg | `p-4` | 16px |
| 카드 간격 | xl | `gap-6` | 24px |
| 섹션 내부 | 2xl | `py-8` | 32px |
| 섹션 간격 | 3xl | `py-12` | 48px |
| 페이지 섹션 | 4xl | `py-16` | 64px |

## 간격 유형

### 1. Padding (내부 여백)

요소 안쪽의 여백입니다.

```tsx
// 전체 방향
<div className="p-4">16px 전체</div>

// 개별 방향
<div className="pt-4">위 16px</div>
<div className="pr-4">오른쪽 16px</div>
<div className="pb-4">아래 16px</div>
<div className="pl-4">왼쪽 16px</div>

// 축 방향
<div className="px-4">좌우 16px</div>
<div className="py-4">상하 16px</div>
```

### 2. Margin (외부 여백)

요소 바깥쪽의 여백입니다.

```tsx
// 전체 방향
<div className="m-4">16px 전체</div>

// 개별 방향
<div className="mt-4">위 16px</div>
<div className="mr-4">오른쪽 16px</div>
<div className="mb-4">아래 16px</div>
<div className="ml-4">왼쪽 16px</div>

// 자동 마진 (중앙 정렬)
<div className="mx-auto">좌우 중앙</div>
```

### 3. Gap (그리드/플렉스 간격)

Flexbox나 Grid 아이템 간의 간격입니다.

```tsx
// Flexbox에서
<div className="flex gap-4">
  <div>아이템 1</div>
  <div>아이템 2</div>  {/* 16px 간격 */}
  <div>아이템 3</div>
</div>

// Grid에서
<div className="grid grid-cols-3 gap-6">
  <div>카드 1</div>
  <div>카드 2</div>  {/* 24px 간격 */}
  <div>카드 3</div>
</div>

// 축별 gap
<div className="flex gap-x-4 gap-y-2">
  {/* 가로 16px, 세로 8px */}
</div>
```

## 실전 레이아웃 패턴

### 1. 카드 컴포넌트

```tsx
<div className="p-6 rounded-lg border border-gray-200">
  {/* 제목 - 아래 간격 */}
  <h3 className="text-lg font-semibold mb-2">카드 제목</h3>

  {/* 본문 - 아래 간격 */}
  <p className="text-gray-600 mb-4">
    카드 설명 텍스트입니다.
  </p>

  {/* 버튼 그룹 */}
  <div className="flex gap-2">
    <button className="px-4 py-2">취소</button>
    <button className="px-4 py-2">확인</button>
  </div>
</div>
```

### 2. 폼 레이아웃

```tsx
<form className="space-y-6">
  {/* 필드 그룹 */}
  <div className="space-y-4">
    <div>
      <label className="block text-sm font-medium mb-1">이름</label>
      <input className="w-full px-3 py-2 border rounded" />
    </div>

    <div>
      <label className="block text-sm font-medium mb-1">이메일</label>
      <input className="w-full px-3 py-2 border rounded" />
    </div>
  </div>

  {/* 버튼 영역 */}
  <div className="flex justify-end gap-3">
    <button className="px-4 py-2">취소</button>
    <button className="px-4 py-2 bg-blue-600 text-white">저장</button>
  </div>
</form>
```

### 3. 페이지 섹션

```tsx
<main className="py-12">
  {/* 히어로 섹션 */}
  <section className="py-16 px-4">
    <div className="max-w-4xl mx-auto text-center">
      <h1 className="text-4xl font-bold mb-4">히어로 제목</h1>
      <p className="text-xl text-gray-600 mb-8">서브 타이틀</p>
      <button>시작하기</button>
    </div>
  </section>

  {/* 기능 섹션 */}
  <section className="py-16 px-4 bg-gray-50">
    <div className="max-w-6xl mx-auto">
      <h2 className="text-3xl font-bold text-center mb-12">주요 기능</h2>
      <div className="grid grid-cols-3 gap-8">
        {/* 카드들 */}
      </div>
    </div>
  </section>
</main>
```

### 4. 네비게이션 바

```tsx
<nav className="px-4 py-3 border-b">
  <div className="max-w-6xl mx-auto flex items-center justify-between">
    {/* 로고 */}
    <div className="font-bold text-xl">Logo</div>

    {/* 메뉴 */}
    <div className="flex items-center gap-6">
      <a href="#">메뉴 1</a>
      <a href="#">메뉴 2</a>
      <a href="#">메뉴 3</a>
    </div>

    {/* 액션 */}
    <div className="flex items-center gap-3">
      <button className="px-3 py-1.5">로그인</button>
      <button className="px-3 py-1.5 bg-blue-600 text-white rounded">
        시작하기
      </button>
    </div>
  </div>
</nav>
```

## 반응형 간격

### 화면 크기별 간격 조정

```tsx
// 모바일에서 작게, 데스크탑에서 크게
<section className="py-8 md:py-12 lg:py-16">
  <div className="px-4 md:px-6 lg:px-8">
    {/* 콘텐츠 */}
  </div>
</section>

// 그리드 간격 조정
<div className="grid gap-4 md:gap-6 lg:gap-8">
  {/* 아이템들 */}
</div>
```

### 브레이크포인트별 권장 간격

| 요소 | Mobile | Tablet (md) | Desktop (lg) |
|------|--------|-------------|--------------|
| 컨테이너 패딩 | 16px | 24px | 32px |
| 섹션 간격 | 32px | 48px | 64px |
| 카드 간격 | 16px | 24px | 32px |
| 그리드 gap | 16px | 24px | 32px |

## 시각적 그룹핑

### 근접성의 법칙

> 가까이 있는 요소는 관련있어 보입니다.

```tsx
// ✅ 좋은 예 - 관련 요소 그룹핑
<div>
  <div className="mb-6">
    <h3 className="mb-2">제목</h3>        {/* 밀접: 8px */}
    <p>설명 텍스트</p>                    {/* 같은 그룹 */}
  </div>
                                          {/* 분리: 24px */}
  <div className="mb-6">
    <h3 className="mb-2">다른 제목</h3>   {/* 새 그룹 */}
    <p>다른 설명</p>
  </div>
</div>

// ❌ 나쁜 예 - 같은 간격으로 그룹 불명확
<div>
  <h3 className="mb-4">제목</h3>          {/* 16px */}
  <p className="mb-4">설명 텍스트</p>      {/* 16px - 구분 안됨 */}
  <h3 className="mb-4">다른 제목</h3>      {/* 16px - 구분 안됨 */}
  <p className="mb-4">다른 설명</p>
</div>
```

### 간격 비율 권장

```
같은 그룹 내 요소: 8-12px (gap-2, gap-3)
그룹과 그룹 사이: 24-32px (gap-6, gap-8)
섹션과 섹션 사이: 48-64px (py-12, py-16)
```

## 컨테이너와 최대 너비

### 표준 컨테이너

```tsx
// 기본 컨테이너
<div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  {/* 콘텐츠 */}
</div>

// 좁은 콘텐츠 (블로그, 문서)
<div className="max-w-3xl mx-auto px-4">
  {/* 텍스트 콘텐츠 */}
</div>

// 넓은 콘텐츠 (대시보드)
<div className="max-w-full px-4 lg:px-8">
  {/* 전체 너비 콘텐츠 */}
</div>
```

### 최대 너비 옵션

```css
max-w-sm     384px    좁은 카드
max-w-md     448px    폼
max-w-lg     512px    모달
max-w-xl     576px    넓은 모달
max-w-2xl    672px    중간 콘텐츠
max-w-3xl    768px    블로그 글
max-w-4xl    896px    문서
max-w-5xl    1024px   표준 콘텐츠
max-w-6xl    1152px   넓은 콘텐츠
max-w-7xl    1280px   대시보드
```

## 체크리스트

### 반드시 지켜야 할 것

- [ ] 일관된 간격 단위 사용 (8px 배수)
- [ ] 관련 요소는 가깝게, 다른 그룹은 멀리
- [ ] 반응형 간격 적용
- [ ] 충분한 터치 영역 (최소 44px)

### 권장 사항

- [ ] `space-y-*`, `gap-*` 유틸리티 활용
- [ ] 섹션마다 일관된 패딩 적용
- [ ] 최대 너비로 가독성 확보
- [ ] 여백으로 시각적 계층 표현
