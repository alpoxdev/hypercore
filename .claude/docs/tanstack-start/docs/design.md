# UI/UX & Tailwind 가이드라인

> TanStack Start + Tailwind CSS v4 + iOS Safe Area

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **Spacing** | 임의값 (`mt-[13px]`), theme 외 값 |
| **컴포넌트** | 동일 요소에 다른 스타일 조합 |
| **@apply** | 개별 화면에서 사용, base 컴포넌트 외 |
| **반응형** | 데스크탑 우선 작성 |
| **Safe Area** | 컴포넌트 내부 적용, `env(safe-area-inset-*)` 직접 사용 |
| **그림자** | `shadow-lg` 이상 (특별한 경우 제외) |
| **폰트** | 4개 이상, `text-xs` 남용 |
| **색상** | Primary를 일반 텍스트/배경에 사용, 진한 보더 |
| **접근성** | 색상만으로 구분, `outline-none`, placeholder만 레이블 |
| **에러** | 기술 용어 메시지 ("code: 500") |
| **버튼** | 화면당 Primary 2개 이상 |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **Spacing** | Tailwind 기본 스케일만 (4px 단위) |
| **반응형** | 모바일 퍼스트 → `sm:` → `md:` → `lg:` |
| **Safe Area** | `tailwindcss-safe-area` 사용, 레이아웃 단위 적용 |
| **Viewport** | `viewport-fit=cover` 설정 |
| **접근성** | 대비 4.5:1 이상, 레이블 필수, 키보드 접근 |
| **버튼 상태** | Default/Hover/Active/Disabled/Loading 명확히 구분 |
| **에러** | 사용자 행동 중심 메시지 |
| **포커스** | `focus:ring-2` 등 명확한 표시 |
| **로딩** | 주요 액션에 로딩 상태, 중복 클릭 방지 |
| **클래스 순서** | 레이아웃 → 박스 → 타이포 → 색상 → 상태 |

</required>

---

<design_tokens>

## 디자인 토큰 (Tailwind @theme)

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

| 토큰 | 값 |
|------|-----|
| Spacing | 4px 그리드 (`gap-2`=8px, `p-4`=16px) |
| 색상 | Primary(액션), Neutral(배경), Semantic(상태) |
| 폰트 크기 | `text-2xl`(제목), `text-base`(본문), `text-sm`(보조) |
| 컨테이너 | `max-w-md`(폼), `max-w-3xl`(블로그), `max-w-7xl`(대시보드) |

</design_tokens>

---

<patterns>

## Tailwind 패턴

### 버튼

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

| 크기 | 클래스 |
|------|--------|
| Small | `px-3 py-1.5 text-sm` |
| Medium | `px-4 py-2 text-base` |
| Large | `px-6 py-3 text-lg` |

### 입력 필드

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

### 카드

```tsx
<div className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden">
  <div className="px-6 py-4 border-b border-gray-200">
    <h3 className="text-lg font-semibold text-gray-900">제목</h3>
  </div>
  <div className="px-6 py-4">
    <p className="text-base text-gray-600">본문 내용</p>
  </div>
  <div className="px-6 py-4 bg-gray-50 border-t border-gray-200">
    <button>푸터 버튼</button>
  </div>
</div>
```

### 모달

```tsx
<div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
  <div className="bg-white rounded-lg shadow-xl w-full max-w-md">
    <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
      <h2 className="text-lg font-semibold text-gray-900">제목</h2>
      <button><XIcon className="w-5 h-5" /></button>
    </div>
    <div className="px-6 py-4">본문</div>
    <div className="px-6 py-4 bg-gray-50 flex justify-end gap-3">
      <button className="px-4 py-2 border border-gray-300 rounded-lg">취소</button>
      <button className="px-4 py-2 bg-primary-600 text-white rounded-lg">확인</button>
    </div>
  </div>
</div>
```

### 알림

```tsx
// 성공
<div className="p-4 bg-green-50 border border-green-200 rounded-lg flex gap-3">
  <CheckCircleIcon className="w-5 h-5 text-green-600 flex-shrink-0" />
  <p className="text-sm text-green-800">저장되었습니다</p>
</div>

// 에러
<div className="p-4 bg-red-50 border border-red-200 rounded-lg flex gap-3">
  <XCircleIcon className="w-5 h-5 text-red-600 flex-shrink-0" />
  <p className="text-sm text-red-800">서버에 문제가 발생했어요. 잠시 후 다시 시도해주세요.</p>
</div>

// 경고
<div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg flex gap-3">
  <AlertIcon className="w-5 h-5 text-yellow-600 flex-shrink-0" />
  <p className="text-sm text-yellow-800">확인이 필요합니다</p>
</div>
```

### 빈 상태

```tsx
<div className="py-12 text-center">
  <InboxIcon className="mx-auto w-12 h-12 text-gray-400" />
  <h3 className="mt-4 text-lg font-medium text-gray-900">아직 항목이 없어요</h3>
  <p className="mt-2 text-sm text-gray-600">첫 항목을 추가해보세요</p>
  <button className="mt-6 px-4 py-2 bg-primary-600 text-white rounded-lg">
    추가하기
  </button>
</div>
```

</patterns>

---

<safe_area>

## iOS Safe Area

### 설치 & 설정

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

### 유틸리티 클래스

| 클래스 | 용도 |
|--------|------|
| `pt-safe` | 상단 safe area (노치) |
| `pb-safe` | 하단 safe area (홈 인디케이터) |
| `px-safe` | 좌우 safe area |
| `h-screen-safe` | safe area 제외 높이 |
| `min-h-screen-safe` | 최소 높이 |
| `pt-safe-or-4` | safe area 또는 1rem (더 큰 값) |
| `pb-safe-offset-4` | safe area + 1rem |

### 레이아웃 패턴

```tsx
// 기본 앱 레이아웃
<div className="min-h-screen-safe flex flex-col">
  <header className="pt-safe-or-2 px-safe-or-4 bg-white border-b">
    <nav className="h-14 flex items-center">헤더</nav>
  </header>

  <main className="flex-1 px-safe-or-4 py-6">
    {children}
  </main>

  <footer className="pb-safe-or-2 px-safe-or-4 bg-white border-t">
    <nav className="h-14 flex items-center justify-around">탭바</nav>
  </footer>
</div>

// 고정 하단 버튼
<div className="fixed bottom-0 left-0 right-0 pb-safe-or-4 px-safe-or-4 bg-white border-t">
  <button className="w-full h-12 bg-primary-600 text-white rounded-lg">
    확인
  </button>
</div>

// 전체 화면 모달
<div className="fixed inset-0 bg-white z-50">
  <div className="h-screen-safe flex flex-col p-safe">
    {children}
  </div>
</div>
```

### ✅ / ❌ Safe Area

```tsx
// ❌ 노치에 가려짐
<header className="fixed top-0">

// ✅ Safe area 적용
<header className="fixed top-0 pt-safe">

// ❌ 홈 인디케이터와 겹침
<button className="fixed bottom-4">

// ✅ Safe area 적용
<div className="fixed bottom-0 pb-safe-or-4">
  <button>...</button>
</div>

// ❌ 컴포넌트 내부에 적용
<Button className="pb-safe">버튼</Button>

// ✅ 레이아웃에서 적용
<div className="pb-safe-or-4">
  <Button>버튼</Button>
</div>
```

</safe_area>

---

<guidelines>

## 핵심 원칙

| 원칙 | 설명 |
|------|------|
| **일관성** | 동일 역할 = 동일 스타일 |
| **단순함** | 불필요한 요소 제거 |
| **반응형** | 모바일 퍼스트 |
| **접근성** | WCAG AA (대비 4.5:1+) |

### 색상 (60-30-10)

| 비율 | 용도 | 예시 |
|------|------|------|
| 60% | 배경 | `bg-white`, `bg-gray-50` |
| 30% | 보조 | 카드, 섹션 |
| 10% | 강조 | Primary 버튼, CTA |

### 타이포그래피

| 용도 | 클래스 | 크기 |
|------|--------|------|
| 제목 | `text-2xl` | 24px |
| 부제목 | `text-xl` | 20px |
| 본문 | `text-base` | 16px |
| 보조 | `text-sm` | 14px |

### Spacing

| 용도 | 클래스 | 크기 |
|------|--------|------|
| 아이콘-텍스트 | `gap-1` | 4px |
| 인라인 요소 | `gap-2` | 8px |
| 카드 내부 | `p-4` | 16px |
| 카드 간격 | `gap-6` | 24px |
| 섹션 간격 | `py-12` | 48px |

### 반응형

```tsx
<div className="p-4 md:p-6 lg:p-8">
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
```

| 브레이크포인트 | 크기 | 용도 |
|--------------|------|------|
| `sm` | 640px | 모바일 가로 |
| `md` | 768px | 태블릿 |
| `lg` | 1024px | 노트북 |
| `xl` | 1280px | 데스크탑 |

</guidelines>

---

<accessibility>

## 접근성 체크리스트

```tsx
// ✅ 명확한 레이블
<label htmlFor="email">이메일</label>
<input id="email" />

// ✅ 에러 연결
<input aria-invalid={hasError} aria-describedby="error" />
{hasError && <p id="error" role="alert">오류</p>}

// ✅ 포커스 표시
<button className="focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">

// ✅ 색상 + 아이콘 병행
<span className="text-red-600 flex items-center gap-1">
  <XCircleIcon className="w-4 h-4" />
  오류
</span>

// ✅ 키보드 접근
<div tabIndex={0} onKeyDown={handleKeyDown}>

// ❌ 포커스 제거 금지
<button className="outline-none focus:outline-none">
```

| 항목 | 기준 |
|------|------|
| 텍스트 대비 | 4.5:1 이상 |
| 큰 텍스트 (18px+) | 3:1 이상 |
| 터치 영역 | 44px × 44px 이상 |
| 포커스 표시 | 항상 visible |

</accessibility>

---

<examples>

## 실전 예시

### 폼 레이아웃

```tsx
<form className="max-w-md mx-auto space-y-6">
  {/* 입력 필드 */}
  <div>
    <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
      이름
    </label>
    <input
      id="name"
      type="text"
      className="w-full px-3 py-2 border border-gray-300 rounded-lg
                 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
    />
  </div>

  {/* 에러가 있는 입력 */}
  <div>
    <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
      이메일
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
      올바른 이메일을 입력하세요
    </p>
  </div>

  {/* 버튼 그룹 */}
  <div className="flex gap-3">
    <button
      type="button"
      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
    >
      취소
    </button>
    <button
      type="submit"
      className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
    >
      저장
    </button>
  </div>
</form>
```

### 카드 리스트

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {items.map((item) => (
    <div key={item.id} className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden">
      <img src={item.image} className="w-full h-48 object-cover" />
      <div className="p-4">
        <h3 className="text-lg font-semibold text-gray-900">{item.title}</h3>
        <p className="mt-2 text-sm text-gray-600">{item.description}</p>
        <button className="mt-4 w-full px-4 py-2 bg-primary-600 text-white rounded-lg">
          자세히 보기
        </button>
      </div>
    </div>
  ))}
</div>
```

### 대시보드 레이아웃

```tsx
<div className="min-h-screen-safe bg-gray-50">
  {/* 헤더 */}
  <header className="pt-safe-or-2 px-safe-or-4 bg-white border-b border-gray-200">
    <div className="h-16 flex items-center justify-between">
      <h1 className="text-xl font-bold">대시보드</h1>
      <button>메뉴</button>
    </div>
  </header>

  {/* 메인 */}
  <main className="px-safe-or-4 py-6">
    <div className="max-w-7xl mx-auto space-y-6">
      {/* 통계 카드 */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg border border-gray-200">
          <p className="text-sm text-gray-600">총 사용자</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">1,234</p>
        </div>
        {/* ... */}
      </div>

      {/* 차트 */}
      <div className="bg-white p-6 rounded-lg border border-gray-200">
        <h2 className="text-lg font-semibold text-gray-900">활동</h2>
        {/* 차트 컴포넌트 */}
      </div>
    </div>
  </main>
</div>
```

</examples>

---

<claude_requirements>

## Claude Code 요구사항

**새 화면/컴포넌트 작성 시:**

1. **Tailwind 스케일만 사용** - 임의값 금지
2. **모바일 퍼스트** - 기본 스타일 → `sm:` → `md:` → `lg:`
3. **Safe area 레이아웃에서 처리** - 컴포넌트 내부 금지
4. **접근성 필수** - 레이블, 대비, 포커스, 키보드
5. **일관된 패턴** - 같은 요소는 항상 같은 클래스 조합
6. **로딩/에러 상태** - 주요 액션에 필수
7. **마이크로카피** - 버튼/에러 메시지 함께 제안

**예외 발생 시:**
- 코드 주석으로 이유 설명

**Theme 확장 필요 시:**
- 임의값 대신 `@theme` 확장 제안

</claude_requirements>
