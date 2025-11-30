# Tailwind CSS 설정

> **상위 문서**: [UI/UX 디자인 가이드](./index.md)

Tailwind CSS v4를 사용한 디자인 시스템 구현 가이드입니다.

## 기본 설정

### 설치

```bash
yarn add tailwindcss postcss autoprefixer
```

### CSS 파일 설정

```css
/* src/styles/app.css */
@import "tailwindcss";
```

### PostCSS 설정

```js
// postcss.config.js
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

## 디자인 토큰 정의

### @theme 디렉티브

Tailwind CSS v4에서는 `@theme` 디렉티브로 디자인 토큰을 정의합니다.

```css
/* src/styles/app.css */
@import "tailwindcss";

@theme {
  /* ========================================
   * 색상 시스템
   * ======================================== */

  /* 브랜드 기본색 */
  --color-primary-50: oklch(0.97 0.01 250);
  --color-primary-100: oklch(0.93 0.03 250);
  --color-primary-200: oklch(0.88 0.06 250);
  --color-primary-300: oklch(0.78 0.1 250);
  --color-primary-400: oklch(0.68 0.15 250);
  --color-primary-500: oklch(0.55 0.2 250);   /* 기본 */
  --color-primary-600: oklch(0.48 0.22 250);  /* hover */
  --color-primary-700: oklch(0.42 0.2 250);   /* active */
  --color-primary-800: oklch(0.35 0.17 250);
  --color-primary-900: oklch(0.28 0.12 250);

  /* 의미론적 색상 */
  --color-success: oklch(0.55 0.15 145);
  --color-success-light: oklch(0.92 0.05 145);
  --color-error: oklch(0.55 0.2 25);
  --color-error-light: oklch(0.92 0.05 25);
  --color-warning: oklch(0.75 0.15 85);
  --color-warning-light: oklch(0.95 0.05 85);
  --color-info: oklch(0.55 0.2 250);
  --color-info-light: oklch(0.92 0.05 250);

  /* ========================================
   * 타이포그래피
   * ======================================== */

  /* 폰트 패밀리 */
  --font-sans: "Pretendard", "Inter", system-ui, -apple-system, sans-serif;
  --font-mono: "JetBrains Mono", "Fira Code", Consolas, monospace;

  /* 폰트 크기 (선택적 커스텀) */
  --font-size-hero: 3.5rem;

  /* ========================================
   * 간격 (선택적 커스텀)
   * ======================================== */

  --spacing-section: 4rem;
  --spacing-page: 6rem;

  /* ========================================
   * 테두리 반경
   * ======================================== */

  --radius-button: 0.5rem;
  --radius-card: 0.75rem;
  --radius-modal: 1rem;

  /* ========================================
   * 그림자
   * ======================================== */

  --shadow-card: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
  --shadow-dropdown: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  --shadow-modal: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);

  /* ========================================
   * 애니메이션
   * ======================================== */

  --transition-fast: 150ms ease;
  --transition-normal: 200ms ease;
  --transition-slow: 300ms ease;
}
```

## 사용 예시

### 색상 토큰 사용

```tsx
// 브랜드 색상
<button className="bg-primary-600 hover:bg-primary-700 text-white">
  주요 버튼
</button>

// 의미론적 색상
<div className="bg-success-light border border-success text-success">
  성공 메시지
</div>

<div className="bg-error-light border border-error text-error">
  오류 메시지
</div>
```

### 폰트 토큰 사용

```tsx
// 본문 (기본)
<p className="font-sans">Pretendard 폰트 적용</p>

// 코드
<code className="font-mono">JetBrains Mono 적용</code>
```

### 커스텀 간격/반경 사용

```tsx
// 섹션 간격
<section className="py-[--spacing-section]">

// 카드 반경
<div className="rounded-[--radius-card]">

// 모달 반경
<div className="rounded-[--radius-modal]">
```

## 다크 모드 설정

### 다크 모드 토큰

```css
@theme {
  /* 라이트 모드 배경 */
  --color-surface: white;
  --color-surface-secondary: oklch(0.98 0 0);

  /* 라이트 모드 텍스트 */
  --color-text-primary: oklch(0.15 0 0);
  --color-text-secondary: oklch(0.4 0 0);
  --color-text-muted: oklch(0.6 0 0);

  /* 라이트 모드 테두리 */
  --color-border: oklch(0.9 0 0);
  --color-border-strong: oklch(0.8 0 0);
}

/* 다크 모드 오버라이드 */
@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: oklch(0.15 0 0);
    --color-surface-secondary: oklch(0.2 0 0);

    --color-text-primary: oklch(0.95 0 0);
    --color-text-secondary: oklch(0.7 0 0);
    --color-text-muted: oklch(0.5 0 0);

    --color-border: oklch(0.3 0 0);
    --color-border-strong: oklch(0.4 0 0);
  }
}
```

### 다크 모드 클래스 사용

```tsx
// Tailwind의 dark: 접두사 사용
<div className="bg-white dark:bg-gray-900">
  <h1 className="text-gray-900 dark:text-white">제목</h1>
  <p className="text-gray-600 dark:text-gray-300">본문</p>
</div>

// 또는 CSS 변수 사용
<div className="bg-[--color-surface] text-[--color-text-primary]">
  자동으로 다크 모드 대응
</div>
```

### 다크 모드 토글

```tsx
// src/components/theme-toggle.tsx
import { useEffect, useState } from 'react'

export const ThemeToggle = () => {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  useEffect(() => {
    // 시스템 설정 확인
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      setTheme('dark')
    }

    // localStorage 확인
    const saved = localStorage.getItem('theme')
    if (saved) setTheme(saved as 'light' | 'dark')
  }, [])

  useEffect(() => {
    document.documentElement.classList.toggle('dark', theme === 'dark')
    localStorage.setItem('theme', theme)
  }, [theme])

  return (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
      {theme === 'light' ? '🌙' : '☀️'}
    </button>
  )
}
```

## 컴포넌트 스타일 패턴

### 버튼 컴포넌트

```tsx
// src/components/ui/button.tsx
import { cva, type VariantProps } from 'class-variance-authority'

const buttonVariants = cva(
  // 기본 스타일
  'inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed',
  {
    variants: {
      variant: {
        primary: 'bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500',
        secondary: 'border border-gray-300 bg-white hover:bg-gray-50 focus:ring-gray-500',
        ghost: 'hover:bg-gray-100 focus:ring-gray-500',
        destructive: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500',
      },
      size: {
        sm: 'px-3 py-1.5 text-sm rounded-md',
        md: 'px-4 py-2 text-base rounded-lg',
        lg: 'px-6 py-3 text-lg rounded-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
)

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export const Button = ({ variant, size, className, ...props }: ButtonProps) => {
  return (
    <button
      className={buttonVariants({ variant, size, className })}
      {...props}
    />
  )
}
```

### 입력 필드 컴포넌트

```tsx
// src/components/ui/input.tsx
import { forwardRef } from 'react'

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
  hint?: string
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, hint, className, id, ...props }, ref) => {
    const inputId = id || label?.toLowerCase().replace(/\s/g, '-')

    return (
      <div>
        {label && (
          <label
            htmlFor={inputId}
            className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1"
          >
            {label}
          </label>
        )}
        <input
          ref={ref}
          id={inputId}
          className={`
            w-full px-3 py-2 border rounded-lg transition-colors
            placeholder:text-gray-400
            focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500
            ${error
              ? 'border-red-500 focus:ring-red-500 focus:border-red-500'
              : 'border-gray-300 dark:border-gray-600'
            }
            ${className}
          `}
          aria-invalid={!!error}
          aria-describedby={error ? `${inputId}-error` : hint ? `${inputId}-hint` : undefined}
          {...props}
        />
        {error && (
          <p id={`${inputId}-error`} className="mt-1 text-sm text-red-600" role="alert">
            {error}
          </p>
        )}
        {hint && !error && (
          <p id={`${inputId}-hint`} className="mt-1 text-sm text-gray-500">
            {hint}
          </p>
        )}
      </div>
    )
  }
)

Input.displayName = 'Input'
```

## 유용한 유틸리티

### cn() 함수 (클래스 병합)

```bash
yarn add clsx tailwind-merge
```

```ts
// src/lib/utils.ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export const cn = (...inputs: ClassValue[]) => {
  return twMerge(clsx(inputs))
}
```

```tsx
// 사용 예시
import { cn } from '@/lib/utils'

<button
  className={cn(
    'px-4 py-2 rounded-lg',
    isActive && 'bg-blue-600 text-white',
    isDisabled && 'opacity-50 cursor-not-allowed',
    className
  )}
>
```

### class-variance-authority (CVA)

```bash
yarn add class-variance-authority
```

위의 버튼 컴포넌트 예시 참고.

## 반응형 디자인

### 브레이크포인트

```css
sm   640px   모바일 가로
md   768px   태블릿
lg   1024px  노트북
xl   1280px  데스크탑
2xl  1536px  대형 모니터
```

### 모바일 퍼스트

```tsx
// 모바일 → 태블릿 → 데스크탑 순서
<div className="
  p-4           /* 기본: 모바일 */
  md:p-6        /* 768px 이상 */
  lg:p-8        /* 1024px 이상 */
">

// 그리드 반응형
<div className="
  grid
  grid-cols-1   /* 모바일: 1열 */
  md:grid-cols-2 /* 태블릿: 2열 */
  lg:grid-cols-3 /* 데스크탑: 3열 */
  gap-4 md:gap-6
">
```

## 플러그인 추가

### @tailwindcss/forms

폼 요소 기본 스타일링:

```bash
yarn add @tailwindcss/forms
```

```css
@import "tailwindcss";
@plugin "@tailwindcss/forms";
```

### @tailwindcss/typography

마크다운/리치 텍스트 스타일링:

```bash
yarn add @tailwindcss/typography
```

```css
@import "tailwindcss";
@plugin "@tailwindcss/typography";
```

```tsx
<article className="prose dark:prose-invert">
  {/* 마크다운 렌더링 콘텐츠 */}
</article>
```

## 체크리스트

### 설정 시

- [ ] @theme으로 디자인 토큰 정의
- [ ] 브랜드 색상 설정
- [ ] 의미론적 색상 정의
- [ ] 폰트 패밀리 설정
- [ ] 다크 모드 대응

### 개발 시

- [ ] 일관된 토큰 사용
- [ ] 모바일 퍼스트 반응형
- [ ] cn() 함수로 클래스 병합
- [ ] 접근성 고려 (포커스, 대비)
