# Tailwind CSS 설정

> Tailwind CSS v4

## 설치

```bash
yarn add tailwindcss postcss autoprefixer
```

```css
/* src/styles/app.css */
@import "tailwindcss";
```

## 디자인 토큰 (@theme)

```css
@import "tailwindcss";

@theme {
  /* 색상 */
  --color-primary-500: oklch(0.55 0.2 250);
  --color-primary-600: oklch(0.48 0.22 250);
  --color-primary-700: oklch(0.42 0.2 250);

  --color-success: oklch(0.55 0.15 145);
  --color-error: oklch(0.55 0.2 25);
  --color-warning: oklch(0.75 0.15 85);

  /* 폰트 */
  --font-sans: "Pretendard", "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", monospace;

  /* 반경 */
  --radius-button: 0.5rem;
  --radius-card: 0.75rem;
  --radius-modal: 1rem;

  /* 그림자 */
  --shadow-card: 0 1px 3px rgba(0, 0, 0, 0.1);
  --shadow-modal: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}
```

## 사용법

```tsx
<button className="bg-primary-600 hover:bg-primary-700">버튼</button>
<div className="text-success">성공</div>
<div className="rounded-[--radius-card]">카드</div>
```

## 다크 모드

```css
@theme {
  --color-surface: white;
  --color-text-primary: oklch(0.15 0 0);
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: oklch(0.15 0 0);
    --color-text-primary: oklch(0.95 0 0);
  }
}
```

```tsx
// Tailwind dark: 접두사
<div className="bg-white dark:bg-gray-900">
  <h1 className="text-gray-900 dark:text-white">제목</h1>
</div>

// CSS 변수 (자동 대응)
<div className="bg-[--color-surface] text-[--color-text-primary]">
```

## CVA (class-variance-authority)

```bash
yarn add class-variance-authority clsx tailwind-merge
```

```tsx
// src/lib/utils.ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'
export const cn = (...inputs: ClassValue[]) => twMerge(clsx(inputs))

// src/components/ui/button.tsx
import { cva, type VariantProps } from 'class-variance-authority'

const buttonVariants = cva(
  'inline-flex items-center justify-center font-medium transition-colors focus:ring-2 disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-primary-600 text-white hover:bg-primary-700',
        secondary: 'border border-gray-300 hover:bg-gray-50',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
      },
      size: {
        sm: 'px-3 py-1.5 text-sm rounded-md',
        md: 'px-4 py-2 text-base rounded-lg',
        lg: 'px-6 py-3 text-lg rounded-lg',
      },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  }
)

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement>,
  VariantProps<typeof buttonVariants> {}

export const Button = ({ variant, size, className, ...props }: ButtonProps) => (
  <button className={buttonVariants({ variant, size, className })} {...props} />
)
```

## 반응형

```css
sm   640px   모바일 가로
md   768px   태블릿
lg   1024px  노트북
xl   1280px  데스크탑
```

```tsx
<div className="p-4 md:p-6 lg:p-8">
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
```

## 플러그인

```css
@import "tailwindcss";
@plugin "@tailwindcss/forms";
@plugin "@tailwindcss/typography";
```

```tsx
<article className="prose dark:prose-invert">
  {/* 마크다운 콘텐츠 */}
</article>
```

## 체크리스트

- [ ] @theme으로 디자인 토큰 정의
- [ ] 브랜드/의미론적 색상 설정
- [ ] 폰트 패밀리 설정
- [ ] 다크 모드 대응
- [ ] 모바일 퍼스트 반응형
