# Typography 2026 Guide

## 핵심 원칙

1. **Variable Fonts 사용** - 단일 파일로 다양한 웨이트
2. **명확한 위계** - Display, Body, Mono 구분
3. **독창적 선택** - 일반적인 폰트 회피
4. **성능 최적화** - font-display: swap

## Variable Fonts

### 설정

```css
@font-face {
  font-family: 'Display';
  src: url('/fonts/display-variable.woff2') format('woff2');
  font-weight: 100 900;        /* 가변 범위 */
  font-style: normal;
  font-display: swap;          /* 필수 */
}

@font-face {
  font-family: 'Body';
  src: url('/fonts/body-variable.woff2') format('woff2');
  font-weight: 300 700;
  font-style: normal;
  font-display: swap;
}
```

### 사용

```css
:root {
  --font-display: 'Display', serif;
  --font-body: 'Body', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}

h1 {
  font-family: var(--font-display);
  font-weight: 800;            /* 가변 웨이트 */
  font-variation-settings: 'wght' 800;  /* 세밀 조절 */
}
```

## 타입 스케일

### Fluid Typography

```css
:root {
  /* Fluid scale - clamp(min, preferred, max) */
  --text-xs: clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem);
  --text-sm: clamp(0.875rem, 0.8rem + 0.35vw, 1rem);
  --text-base: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  --text-lg: clamp(1.125rem, 1rem + 0.6vw, 1.25rem);
  --text-xl: clamp(1.25rem, 1.1rem + 0.75vw, 1.5rem);
  --text-2xl: clamp(1.5rem, 1.2rem + 1.5vw, 2rem);
  --text-3xl: clamp(2rem, 1.5rem + 2.5vw, 3rem);
  --text-4xl: clamp(2.5rem, 1.8rem + 3.5vw, 4rem);
  --text-5xl: clamp(3rem, 2rem + 5vw, 6rem);
}
```

### Line Height

```css
:root {
  --leading-tight: 1.1;    /* 대형 헤드라인 */
  --leading-snug: 1.25;    /* 소형 헤드라인 */
  --leading-normal: 1.5;   /* 본문 */
  --leading-relaxed: 1.75; /* 긴 텍스트 */
}
```

### Letter Spacing

```css
:root {
  --tracking-tight: -0.02em;   /* 대형 타이틀 */
  --tracking-normal: 0;        /* 기본 */
  --tracking-wide: 0.05em;     /* 캡션, 라벨 */
  --tracking-wider: 0.1em;     /* 올캡스 */
}
```

## 폰트 페어링

### 클래식 에디토리얼

| 용도 | 폰트 | 웨이트 |
|------|------|--------|
| Display | Playfair Display | 400-800 |
| Body | Source Sans 3 | 300-600 |
| Mono | IBM Plex Mono | 400 |

```css
/* CDN */
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400..800&family=Source+Sans+3:wght@300..600&display=swap');
```

### 모던 볼드

| 용도 | 폰트 | 웨이트 |
|------|------|--------|
| Display | Clash Display | 500-700 |
| Body | Satoshi | 400-700 |
| Mono | Fira Code | 400-500 |

```css
/* Fontshare */
@import url('https://api.fontshare.com/v2/css?f[]=clash-display@500,600,700&f[]=satoshi@400,500,700&display=swap');
```

### 따뜻한 친근함

| 용도 | 폰트 | 웨이트 |
|------|------|--------|
| Display | Fraunces | 400-700 |
| Body | Work Sans | 300-600 |
| Mono | JetBrains Mono | 400 |

### 테크 미니멀

| 용도 | 폰트 | 웨이트 |
|------|------|--------|
| Display | Space Mono | 400-700 |
| Body | DM Sans | 400-600 |
| Mono | Space Mono | 400 |

### 럭셔리 정제

| 용도 | 폰트 | 웨이트 |
|------|------|--------|
| Display | Cormorant Garamond | 300-600 |
| Body | Lora | 400-600 |
| Mono | Victor Mono | 400 |

### 크리에이티브

| 용도 | 폰트 | 웨이트 |
|------|------|--------|
| Display | Syne | 400-800 |
| Body | General Sans | 400-600 |
| Mono | Monaspace | 400 |

## 금지 폰트

| 폰트 | 이유 |
|------|------|
| Inter | AI 슬롭의 대명사 |
| Roboto | 무개성, 과다 사용 |
| Arial | 시스템 기본, 무특징 |
| Helvetica | 지루함 |
| Space Grotesk | AI 생성물 단골 |
| Montserrat | 과다 사용 |
| Poppins | 과다 사용 |
| Open Sans | 무개성 |

**예외**: Inter는 독창적인 Display 폰트와 함께 Body로 사용 시 허용

## 실전 패턴

### 기본 설정

```css
html {
  font-family: var(--font-body);
  font-size: var(--text-base);
  line-height: var(--leading-normal);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-display);
  line-height: var(--leading-tight);
  letter-spacing: var(--tracking-tight);
  text-wrap: balance;           /* 2026 표준 */
}

p {
  text-wrap: pretty;            /* 고아 방지 */
  max-width: 65ch;              /* 가독성 */
}

code, pre {
  font-family: var(--font-mono);
  font-size: 0.9em;
}
```

### 대형 헤드라인

```css
.hero-title {
  font-family: var(--font-display);
  font-size: var(--text-5xl);
  font-weight: 800;
  line-height: var(--leading-tight);
  letter-spacing: var(--tracking-tight);

  /* 실험적 효과 */
  font-variation-settings: 'wght' 800, 'wdth' 110;
}
```

### 캡션/라벨

```css
.label {
  font-family: var(--font-body);
  font-size: var(--text-xs);
  font-weight: 500;
  letter-spacing: var(--tracking-wide);
  text-transform: uppercase;
}
```

### 인용문

```css
blockquote {
  font-family: var(--font-display);
  font-size: var(--text-xl);
  font-style: italic;
  font-weight: 400;
  line-height: var(--leading-snug);
}
```

## 성능 최적화

### 서브셋팅

```css
/* 한글 서브셋 */
@font-face {
  font-family: 'Korean';
  src: url('/fonts/korean-subset.woff2') format('woff2');
  unicode-range: U+AC00-D7AF;  /* 한글 음절 */
  font-display: swap;
}
```

### 프리로드

```html
<link rel="preload" href="/fonts/display.woff2" as="font" type="font/woff2" crossorigin>
```

### Font Loading API

```js
// 폰트 로드 후 클래스 추가
document.fonts.ready.then(() => {
  document.documentElement.classList.add('fonts-loaded');
});
```

```css
/* FOUT 방지 */
html:not(.fonts-loaded) body {
  opacity: 0;
}
html.fonts-loaded body {
  opacity: 1;
  transition: opacity 0.3s;
}
```

## 무료 폰트 소스

| 소스 | URL | 특징 |
|------|-----|------|
| Google Fonts | fonts.google.com | 최대 규모, Variable 지원 |
| Fontshare | fontshare.com | 고품질 무료 |
| Font Squirrel | fontsquirrel.com | 웹폰트 생성기 |
| Bunny Fonts | fonts.bunny.net | GDPR 준수 |

## 한글 폰트

| 폰트 | 스타일 | 용도 |
|------|--------|------|
| Pretendard | 고딕 | 본문, UI |
| SUIT | 고딕 | 모던 UI |
| Noto Sans KR | 고딕 | 범용 |
| Nanum Myeongjo | 명조 | 에디토리얼 |
| KoPub 바탕 | 명조 | 본문 |
| 마루 부리 | 명조 | 독특한 디스플레이 |

```css
/* Pretendard Variable */
@import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/variable/pretendardvariable.css');

:root {
  --font-korean: 'Pretendard Variable', 'Pretendard', sans-serif;
}
```
