# 타이포그래피

> **상위 문서**: [UI/UX 디자인 가이드](./index.md)

타이포그래피(Typography)는 텍스트를 읽기 쉽고 시각적으로 매력적으로 만드는 기술입니다.

## 기본 원칙

### 1. 폰트는 2-3개만

> 폰트가 많을수록 디자인은 산만해집니다.

```
권장 구성:
- 제목용 폰트 1개
- 본문용 폰트 1개
- (선택) 코드용 폰트 1개
```

### 2. 크기로 계층 표현

> 제목과 본문의 크기 차이로 중요도를 표현합니다.

```
h1 (제목)     ━━━━━━━━━━━━━━━━━━━━━━━  가장 큼
h2 (부제목)   ━━━━━━━━━━━━━━━━━
h3 (소제목)   ━━━━━━━━━━━━
p  (본문)     ━━━━━━━━                 기준 크기
small         ━━━━━━                   가장 작음
```

### 3. 일관된 스타일

> 같은 역할의 텍스트는 항상 같은 스타일을 사용합니다.

## 폰트 선택 가이드

### Sans-serif (산세리프) - 본문에 권장

획의 끝에 장식이 없는 깔끔한 폰트입니다.

| 폰트 | 특징 | 추천 용도 |
|------|------|----------|
| **Inter** | 현대적, 가독성 뛰어남 | 웹 전반 |
| **Pretendard** | 한글 최적화, Inter 호환 | 한글 프로젝트 |
| **Noto Sans KR** | 한글/영문 균형 | 다국어 프로젝트 |
| **Roboto** | Google 스타일 | Material Design |
| **SF Pro** | Apple 스타일 | iOS/macOS 앱 |

### Serif (세리프) - 제목에 선택적

획의 끝에 장식(세리프)이 있는 전통적인 폰트입니다.

| 폰트 | 특징 | 추천 용도 |
|------|------|----------|
| **Georgia** | 클래식, 신뢰감 | 블로그, 뉴스 |
| **Merriweather** | 가독성 높음 | 긴 글 읽기 |
| **Noto Serif KR** | 한글 세리프 | 격식있는 제목 |

### Monospace (고정폭) - 코드용

모든 글자가 같은 너비를 가지는 폰트입니다.

| 폰트 | 특징 |
|------|------|
| **JetBrains Mono** | 개발자용, 리가처 지원 |
| **Fira Code** | 리가처 지원 |
| **SF Mono** | Apple 스타일 |

## 폰트 크기 시스템

### 기본 크기 체계

```css
/* Tailwind 기본 크기 */
text-xs     0.75rem   12px   작은 레이블, 캡션
text-sm     0.875rem  14px   보조 텍스트, 메타 정보
text-base   1rem      16px   본문 (기본)
text-lg     1.125rem  18px   강조 본문
text-xl     1.25rem   20px   소제목 (h4)
text-2xl    1.5rem    24px   섹션 제목 (h3)
text-3xl    1.875rem  30px   페이지 부제목 (h2)
text-4xl    2.25rem   36px   페이지 제목 (h1)
text-5xl    3rem      48px   히어로 제목
```

### 실제 적용 예시

```tsx
// 페이지 제목
<h1 className="text-4xl font-bold">대시보드</h1>

// 섹션 제목
<h2 className="text-2xl font-semibold">최근 활동</h2>

// 카드 제목
<h3 className="text-xl font-medium">사용자 통계</h3>

// 본문
<p className="text-base">오늘 방문자 수는 1,234명입니다.</p>

// 보조 텍스트
<span className="text-sm text-gray-500">5분 전 업데이트</span>
```

## 줄 간격 (Line Height)

### 왜 중요한가?

줄 간격이 좁으면 답답하고, 너무 넓으면 텍스트가 흩어져 보입니다.

```
줄 간격 너무 좁음 (1.2)          적절한 줄 간격 (1.5)
━━━━━━━━━━━━━━━━━              ━━━━━━━━━━━━━━━━━
이 텍스트는 줄 간격이            이 텍스트는 줄 간격이
너무 좁아서 읽기가               적절해서 읽기가
불편합니다.                      편합니다.
━━━━━━━━━━━━━━━━━              ━━━━━━━━━━━━━━━━━
```

### Tailwind 줄 간격

```css
leading-none      1      제목 (한 줄)
leading-tight     1.25   짧은 제목
leading-snug      1.375  부제목
leading-normal    1.5    본문 (기본, 권장)
leading-relaxed   1.625  긴 글
leading-loose     2      매우 여유로운 글
```

### 텍스트 길이별 권장 줄 간격

```tsx
// 짧은 제목 - 타이트하게
<h1 className="text-4xl leading-tight">한 줄 제목</h1>

// 긴 본문 - 여유롭게
<p className="text-base leading-relaxed">
  긴 본문 텍스트는 줄 간격이 넉넉해야
  읽기가 편합니다.
</p>
```

## 글자 굵기 (Font Weight)

### Tailwind 굵기 옵션

```css
font-thin        100   거의 사용 안함
font-extralight  200   거의 사용 안함
font-light       300   밝은 테마 대형 제목
font-normal      400   본문 (기본)
font-medium      500   약간 강조
font-semibold    600   부제목, 버튼
font-bold        700   제목, 강조
font-extrabold   800   히어로 제목
font-black       900   임팩트 제목
```

### 계층별 권장 굵기

```tsx
// 메인 제목 - 볼드
<h1 className="text-4xl font-bold">제목</h1>

// 부제목 - 세미볼드
<h2 className="text-2xl font-semibold">부제목</h2>

// 본문 - 일반
<p className="text-base font-normal">본문 텍스트</p>

// 강조 - 미디엄
<strong className="font-medium">중요한 내용</strong>
```

## 가독성 최적화

### 줄 길이 (Line Length)

> 한 줄에 너무 많은 글자는 읽기 어렵습니다.

```
권장: 45-75자 (영문 기준)
한글: 25-35자

Tailwind로 제한:
max-w-prose  → 65ch (약 65자)
max-w-xl     → 36rem
max-w-2xl    → 42rem
```

```tsx
// 본문 컨테이너
<article className="max-w-prose mx-auto">
  <p>이 텍스트는 적절한 줄 길이로 제한되어 읽기 편합니다.</p>
</article>
```

### 글자 간격 (Letter Spacing)

```css
tracking-tighter  -0.05em   대형 제목
tracking-tight    -0.025em  제목
tracking-normal   0         본문 (기본)
tracking-wide     0.025em   대문자, 작은 텍스트
tracking-wider    0.05em    레이블
tracking-widest   0.1em     버튼 텍스트
```

```tsx
// 대형 제목 - 약간 좁게
<h1 className="text-5xl tracking-tight">히어로 제목</h1>

// 작은 레이블 - 약간 넓게
<span className="text-xs tracking-wide uppercase">NEW</span>
```

## 실전 타이포그래피 시스템

### 완성된 텍스트 스타일 세트

```tsx
// app/components/ui/typography.tsx

// 페이지 제목
export const PageTitle = ({ children }) => (
  <h1 className="text-4xl font-bold tracking-tight text-gray-900 dark:text-white">
    {children}
  </h1>
)

// 섹션 제목
export const SectionTitle = ({ children }) => (
  <h2 className="text-2xl font-semibold text-gray-900 dark:text-white">
    {children}
  </h2>
)

// 카드 제목
export const CardTitle = ({ children }) => (
  <h3 className="text-lg font-medium text-gray-900 dark:text-white">
    {children}
  </h3>
)

// 본문
export const Body = ({ children }) => (
  <p className="text-base leading-relaxed text-gray-700 dark:text-gray-300">
    {children}
  </p>
)

// 보조 텍스트
export const Caption = ({ children }) => (
  <span className="text-sm text-gray-500 dark:text-gray-400">
    {children}
  </span>
)

// 레이블
export const Label = ({ children }) => (
  <span className="text-xs font-medium uppercase tracking-wide text-gray-500">
    {children}
  </span>
)
```

## 폰트 설정

### Tailwind CSS v4 폰트 설정

```css
/* app/styles/app.css */
@import "tailwindcss";

@theme {
  /* 폰트 패밀리 */
  --font-sans: "Pretendard", "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", "Fira Code", monospace;
}
```

### Next.js / TanStack Start 폰트 로딩

```tsx
// Google Fonts 사용 시
// app/routes/__root.tsx
import { Link } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: () => (
    <html>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="font-sans">
        <Outlet />
      </body>
    </html>
  ),
})
```

## 체크리스트

### 반드시 지켜야 할 것

- [ ] 폰트 종류 2-3개 이하
- [ ] 본문 크기 16px 이상
- [ ] 본문 줄 간격 1.5 이상
- [ ] 제목과 본문의 명확한 크기 차이

### 권장 사항

- [ ] 한글 최적화 폰트 사용 (Pretendard, Noto Sans KR)
- [ ] 텍스트 컨테이너 최대 너비 제한
- [ ] 일관된 텍스트 스타일 컴포넌트 사용
- [ ] 다크 모드 텍스트 색상 대응
