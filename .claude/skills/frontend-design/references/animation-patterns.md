# Animation Patterns 2026

## 핵심 원칙

| 원칙 | 설명 |
|------|------|
| 목적 | 모든 애니메이션에 이유가 있어야 함 |
| 속도 | 트랜지션 300ms 이하 |
| 성능 | transform, opacity만 애니메이트 |
| 접근성 | prefers-reduced-motion 존중 |

## CSS 애니메이션

### 기본 Easing

```css
:root {
  /* 표준 이징 */
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);      /* 빠른 시작, 부드러운 끝 */
  --ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);  /* 균형잡힌 */
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1); /* 스프링 효과 */

  /* 기본 duration */
  --duration-fast: 150ms;
  --duration-normal: 200ms;
  --duration-slow: 300ms;
  --duration-enter: 400ms;   /* 진입 애니메이션 */
}
```

### 호버 효과

```css
/* 버튼 리프트 */
.button {
  transition:
    transform var(--duration-fast) var(--ease-out),
    box-shadow var(--duration-fast) var(--ease-out);
}
.button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px oklch(0% 0 0 / 0.15);
}
.button:active {
  transform: translateY(0);
}

/* 카드 틸트 */
.card {
  transition: transform var(--duration-normal) var(--ease-out);
}
.card:hover {
  transform: perspective(1000px) rotateX(-2deg) rotateY(2deg);
}

/* 링크 언더라인 */
.link {
  position: relative;
}
.link::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 2px;
  background: currentColor;
  transform: scaleX(0);
  transform-origin: right;
  transition: transform var(--duration-normal) var(--ease-out);
}
.link:hover::after {
  transform: scaleX(1);
  transform-origin: left;
}
```

### 진입 애니메이션

```css
/* Fade In Up */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in-up {
  animation: fadeInUp var(--duration-enter) var(--ease-out) backwards;
}

/* Fade In Scale */
@keyframes fadeInScale {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

/* Slide In */
@keyframes slideIn {
  from {
    transform: translateX(-100%);
  }
  to {
    transform: translateX(0);
  }
}
```

### 스태거 애니메이션

```css
/* CSS만으로 스태거 */
.stagger > * {
  animation: fadeInUp var(--duration-enter) var(--ease-out) backwards;
}
.stagger > *:nth-child(1) { animation-delay: 0ms; }
.stagger > *:nth-child(2) { animation-delay: 50ms; }
.stagger > *:nth-child(3) { animation-delay: 100ms; }
.stagger > *:nth-child(4) { animation-delay: 150ms; }
.stagger > *:nth-child(5) { animation-delay: 200ms; }
.stagger > *:nth-child(6) { animation-delay: 250ms; }

/* CSS 커스텀 프로퍼티 활용 */
.stagger-item {
  animation: fadeInUp var(--duration-enter) var(--ease-out) backwards;
  animation-delay: calc(var(--index, 0) * 50ms);
}
```

```html
<ul class="stagger">
  <li style="--index: 0">Item 1</li>
  <li style="--index: 1">Item 2</li>
  <li style="--index: 2">Item 3</li>
</ul>
```

### 스크롤 트리거

```css
/* Intersection Observer와 함께 사용 */
.reveal {
  opacity: 0;
  transform: translateY(30px);
  transition:
    opacity var(--duration-slow) var(--ease-out),
    transform var(--duration-slow) var(--ease-out);
}
.reveal.visible {
  opacity: 1;
  transform: translateY(0);
}
```

```js
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  },
  { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
);

document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
```

## 접근성

### 필수: Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

### 선택적 대체

```css
.animated-element {
  transition: transform 300ms ease;
}

@media (prefers-reduced-motion: reduce) {
  .animated-element {
    transition: opacity 150ms ease;  /* 움직임 대신 페이드 */
  }
}
```

### JS에서 확인

```js
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches;

if (!prefersReducedMotion) {
  // 애니메이션 실행
}
```

## React: Motion (Framer Motion)

### 설치

```bash
npm install motion
```

### 기본 패턴

```tsx
import { motion } from 'motion/react';

// 진입 애니메이션
const FadeIn = ({ children }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
  >
    {children}
  </motion.div>
);

// 호버 효과
const HoverCard = ({ children }) => (
  <motion.div
    whileHover={{ scale: 1.02, y: -4 }}
    whileTap={{ scale: 0.98 }}
    transition={{ duration: 0.15 }}
  >
    {children}
  </motion.div>
);
```

### 스태거 리스트

```tsx
import { motion, stagger, useAnimate } from 'motion/react';

const StaggerList = ({ items }) => (
  <motion.ul
    initial="hidden"
    animate="visible"
    variants={{
      visible: {
        transition: {
          staggerChildren: 0.05,
        },
      },
    }}
  >
    {items.map((item) => (
      <motion.li
        key={item.id}
        variants={{
          hidden: { opacity: 0, x: -20 },
          visible: { opacity: 1, x: 0 },
        }}
        transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
      >
        {item.name}
      </motion.li>
    ))}
  </motion.ul>
);
```

### 페이지 트랜지션

```tsx
import { AnimatePresence, motion } from 'motion/react';

const PageTransition = ({ children, key }) => (
  <AnimatePresence mode="wait">
    <motion.div
      key={key}
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ duration: 0.2 }}
    >
      {children}
    </motion.div>
  </AnimatePresence>
);
```

### 레이아웃 애니메이션

```tsx
// 자동 레이아웃 애니메이션
<motion.div layout>
  {isExpanded && <p>추가 콘텐츠</p>}
</motion.div>

// 공유 레이아웃
<motion.div layoutId="shared-element">
  {/* 같은 layoutId를 가진 요소 간 애니메이션 */}
</motion.div>
```

### Reduced Motion 지원

```tsx
import { useReducedMotion } from 'motion/react';

const AnimatedComponent = () => {
  const shouldReduceMotion = useReducedMotion();

  return (
    <motion.div
      initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: shouldReduceMotion ? 0 : 0.3 }}
    >
      Content
    </motion.div>
  );
};
```

## GSAP (복잡한 애니메이션)

### 설치

```bash
npm install gsap
```

### 기본 사용

```js
import gsap from 'gsap';

// 단일 애니메이션
gsap.to('.element', {
  x: 100,
  opacity: 1,
  duration: 0.3,
  ease: 'power3.out',
});

// 타임라인
const tl = gsap.timeline();
tl.from('.title', { y: 50, opacity: 0, duration: 0.5 })
  .from('.subtitle', { y: 30, opacity: 0, duration: 0.4 }, '-=0.3')
  .from('.cta', { scale: 0.9, opacity: 0, duration: 0.3 }, '-=0.2');
```

### ScrollTrigger

```js
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

gsap.from('.reveal', {
  scrollTrigger: {
    trigger: '.reveal',
    start: 'top 80%',
    toggleActions: 'play none none reverse',
  },
  y: 50,
  opacity: 0,
  duration: 0.6,
  ease: 'power3.out',
});
```

## 금지 패턴

| 패턴 | 이유 | 대안 |
|------|------|------|
| `transition: all` | 성능 저하, 예측 불가 | 개별 속성 명시 |
| `width/height` 애니메이트 | 레이아웃 리플로우 | transform: scale |
| `margin/padding` 애니메이트 | 레이아웃 리플로우 | transform: translate |
| 1초+ 트랜지션 | 느린 UX | 300ms 이하 |
| 무한 회전 | 주의 분산, 접근성 | 필요시만, 정지 옵션 |
| `animation-delay` 과다 | 느린 인지 | 50-100ms 간격 |

```css
/* ❌ 금지 */
transition: all 0.5s;
transition: width 0.3s, height 0.3s;
animation: spin 2s infinite linear;

/* ✅ 권장 */
transition: transform 0.2s ease-out, opacity 0.15s ease;
```

## 성능 체크리스트

| 항목 | 확인 |
|------|------|
| transform/opacity만 애니메이트 | [ ] |
| will-change 적절히 사용 | [ ] |
| 레이아웃 속성 애니메이트 안함 | [ ] |
| 60fps 유지 (DevTools 확인) | [ ] |
| 모바일에서 테스트 | [ ] |
| prefers-reduced-motion 처리 | [ ] |

### will-change 사용

```css
/* 애니메이션 시작 직전에만 */
.card {
  will-change: auto;
}
.card:hover {
  will-change: transform;
}

/* 또는 JS로 관리 */
element.addEventListener('mouseenter', () => {
  element.style.willChange = 'transform';
});
element.addEventListener('animationend', () => {
  element.style.willChange = 'auto';
});
```
