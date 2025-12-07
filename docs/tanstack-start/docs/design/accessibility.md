# 접근성 (Accessibility)

## WCAG 기준

| 레벨 | 설명 |
|------|------|
| A | 최소 기준 (필수) |
| AA | 권장 기준 (일반 목표) |
| AAA | 최고 기준 |

## 색상 대비

| 기준 | 대비 | 대상 |
|------|------|------|
| AA | 4.5:1 | 일반 텍스트 |
| AA (큰 텍스트) | 3:1 | 18px 이상 |
| AAA | 7:1 | 최고 접근성 |

```tsx
// ❌ 색상만으로 구분
<span className="text-red-600">오류</span>

// ✅ 아이콘/텍스트 병행
<span className="text-red-600 flex items-center gap-1">
  <XCircleIcon className="w-4 h-4" />
  오류가 발생했습니다
</span>
```

## 키보드 접근성

| 키 | 동작 |
|-----|------|
| Tab | 다음 요소 |
| Shift+Tab | 이전 요소 |
| Enter | 클릭, 링크 이동 |
| Space | 체크박스, 버튼 |
| Escape | 모달 닫기 |

```tsx
// ✅ 명확한 포커스 스타일
<button className="focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">

// ❌ 포커스 제거 금지
<button className="outline-none focus:outline-none">
```

## 시맨틱 HTML

```tsx
// ✅ 시맨틱 HTML
<header>...</header>
<nav>...</nav>
<main><article><section>...</section></article></main>
<footer>...</footer>

// ❌ div 남용
<div className="header">...</div>
```

### 제목 계층
```tsx
// ✅ 순서대로
<h1>페이지 제목</h1>
  <h2>섹션 1</h2>
    <h3>하위 섹션</h3>

// ❌ 건너뛰기 금지
<h1>제목</h1>
  <h3>섹션</h3>
```

## ARIA 속성

```tsx
// 레이블 연결
<label htmlFor="email">이메일</label>
<input id="email" type="email" />

// aria-label
<input aria-label="검색어 입력" type="search" />

// 에러 상태
<input aria-invalid="true" aria-describedby="email-error" />
<p id="email-error" role="alert">오류 메시지</p>

// 동적 알림
<div aria-live="polite">{message}</div>

// 숨김 처리 (스크린 리더만)
<span className="sr-only">메뉴 열기</span>

// 장식용 숨김
<div aria-hidden="true">장식용 아이콘</div>
```

## 폼 접근성

```tsx
<div>
  <label htmlFor="email">
    이메일 <span className="text-red-600" aria-hidden="true">*</span>
    <span className="sr-only">(필수)</span>
  </label>
  <input
    id="email"
    required
    aria-required="true"
    aria-invalid={hasError}
    aria-describedby={hasError ? "email-error" : undefined}
  />
  {hasError && <p id="email-error" role="alert">오류 메시지</p>}
</div>
```

## 이미지 대체 텍스트

```tsx
// 정보 전달 이미지
<img src="chart.png" alt="2024년 매출: 1월 100만원에서 12월 500만원으로 성장" />

// 장식용
<img src="decorative.png" alt="" />

// 아이콘 버튼
<button aria-label="닫기">
  <img src="close.svg" alt="" />
</button>
```

## 터치 접근성

```tsx
// 최소 44x44px
<button className="min-w-[44px] min-h-[44px] p-2">
  <Icon className="w-6 h-6" />
</button>

// 터치 타겟 간격 8px 이상
<div className="flex gap-2">
```

## 테스트 도구

| 도구 | 용도 |
|------|------|
| axe DevTools | 브라우저 확장 |
| Lighthouse | Chrome 내장 |
| eslint-plugin-jsx-a11y | 코드 레벨 검사 |

## 체크리스트

### 필수 (Level A)
- [ ] 모든 이미지에 alt
- [ ] 폼 요소에 레이블
- [ ] 키보드 접근 가능
- [ ] 포커스 표시 유지
- [ ] 색상만으로 정보 전달 금지

### 권장 (Level AA)
- [ ] 대비 4.5:1 이상
- [ ] 제목 계층 논리적
- [ ] 200% 확대 시 가로 스크롤 없음
