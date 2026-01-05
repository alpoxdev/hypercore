---
name: frontend-design
description: 프론트엔드 UI 구현 스킬. 컴포넌트, 페이지, 애플리케이션 구축 시 사용. 2026 트렌드 기반 고품질 디자인 생성.
license: Complete terms in LICENSE.txt
---

# Frontend Design Skill

프로덕션급 프론트엔드 인터페이스 구현. 독창적이고 기억에 남는 디자인.

## 사용 시점

| 트리거 | 예시 |
|--------|------|
| UI 컴포넌트 요청 | "버튼 컴포넌트 만들어줘" |
| 페이지 구현 | "랜딩 페이지 만들어줘" |
| 스타일링 작업 | "다크 테마 적용해줘" |
| 애니메이션 추가 | "hover 효과 넣어줘" |

## 디자인 프로세스

### 1단계: 컨텍스트 파악

```
- 목적: 무슨 문제 해결?
- 대상: 누가 사용?
- 제약: 프레임워크, 성능, 접근성 요구사항
```

### 2단계: 미적 방향 결정

**반드시 하나 선택하고 일관성 유지:**

| 방향 | 특징 | 적합한 상황 |
|------|------|-------------|
| Liquid Glass | 투명도, 깊이, 유동적 표면 | 모던 앱, 대시보드 |
| Calm Minimal | 여백, 선명한 타이포, 절제 | 콘텐츠 중심, 포트폴리오 |
| Bold Maximalist | 큰 타이포, 강렬한 색, 레이어 | 크리에이티브, 브랜드 |
| Organic Natural | 부드러운 곡선, 어시 톤, 텍스처 | 웰빙, 라이프스타일 |
| Editorial | 매거진 레이아웃, 그리드 플레이 | 미디어, 블로그 |
| Retro Futuristic | 네온, 그라디언트, 글리치 | 테크, 게임 |

### 3단계: 구현

```
1. CSS 변수로 디자인 토큰 정의
2. 타이포그래피 시스템 설정
3. 컬러 팔레트 적용
4. 레이아웃 구조화
5. 애니메이션/인터랙션 추가
6. 접근성 검증
```

## 핵심 규칙

### 타이포그래피

**DO:**
```css
/* Variable fonts 사용 */
@font-face {
  font-family: 'Display';
  src: url('font.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
}

/* 명확한 위계 */
--font-display: 'Playfair Display', serif;    /* 헤드라인 */
--font-body: 'Source Sans 3', sans-serif;     /* 본문 */
--font-mono: 'JetBrains Mono', monospace;     /* 코드 */
```

**DON'T:**
```css
/* ❌ 금지 - 일반적인 시스템 폰트 */
font-family: Arial, Helvetica, sans-serif;
font-family: -apple-system, BlinkMacSystemFont, sans-serif;

/* ❌ 금지 - AI 슬롭 폰트 */
font-family: 'Inter', sans-serif;
font-family: 'Roboto', sans-serif;
font-family: 'Space Grotesk', sans-serif;
```

**추천 폰트 페어링:**

| 헤드라인 | 본문 | 무드 |
|----------|------|------|
| Playfair Display | Source Sans 3 | 클래식, 에디토리얼 |
| Clash Display | Satoshi | 모던, 볼드 |
| Fraunces | Work Sans | 따뜻한, 친근한 |
| Space Mono | DM Sans | 테크, 미니멀 |
| Syne | Inter (예외적 허용) | 크리에이티브 |

**상세**: [references/typography-2026.md](references/typography-2026.md)

### 컬러

**DO:**
```css
/* OKLCH 컬러 시스템 (2026 표준) */
:root {
  /* 베이스 - 소프트 뉴트럴 (순백색 X) */
  --bg-primary: oklch(98% 0.005 90);      /* 웜 오프화이트 */
  --bg-secondary: oklch(95% 0.01 90);     /* 린넨 */

  /* 텍스트 */
  --text-primary: oklch(20% 0.01 90);     /* 소프트 블랙 */
  --text-secondary: oklch(45% 0.02 90);   /* 뮤트 그레이 */

  /* 액센트 - 하나만 강하게 */
  --accent: oklch(65% 0.25 180);          /* Transformative Teal */
  --accent-hover: oklch(60% 0.28 180);

  /* 상태 */
  --success: oklch(70% 0.2 145);
  --error: oklch(65% 0.25 25);
}

/* 다크 모드 */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: oklch(15% 0.01 90);
    --bg-secondary: oklch(20% 0.015 90);
    --text-primary: oklch(90% 0.01 90);
  }
}
```

**DON'T:**
```css
/* ❌ 금지 - 순백색 배경 */
background: #ffffff;
background: white;

/* ❌ 금지 - AI 슬롭 퍼플 그라디언트 */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
background: linear-gradient(to right, #8b5cf6, #a855f7);
```

**2026 트렌드 컬러:**

| 이름 | OKLCH | HEX (참고) | 용도 |
|------|-------|-----------|------|
| Cloud Dancer | oklch(97% 0.005 90) | #F5F5F5 | 배경, 여백 |
| Mocha Mousse | oklch(55% 0.08 55) | #A47764 | 어시, 따뜻함 |
| Transformative Teal | oklch(65% 0.15 180) | #2D9CCA | 액센트 |
| Neo Mint | oklch(85% 0.1 160) | #AAF0D1 | 프레시, 테크 |
| Soft Coral | oklch(75% 0.12 30) | #FFB5A7 | 따뜻한 액센트 |

**상세**: [references/colors-2026.md](references/colors-2026.md)

### 애니메이션

**원칙:**
1. **목적 있는 움직임만** - 장식적 애니메이션 금지
2. **300ms 이하** - 트랜지션은 빠르게
3. **GPU 가속** - transform, opacity만 애니메이트
4. **접근성** - prefers-reduced-motion 존중

**DO:**
```css
/* 기본 트랜지션 */
.button {
  transition: transform 200ms ease-out,
              background-color 150ms ease;
}
.button:hover {
  transform: translateY(-2px);
}

/* 스태거 애니메이션 */
.list-item {
  animation: fadeInUp 400ms ease-out backwards;
}
.list-item:nth-child(1) { animation-delay: 0ms; }
.list-item:nth-child(2) { animation-delay: 50ms; }
.list-item:nth-child(3) { animation-delay: 100ms; }

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

/* 접근성 */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

**DON'T:**
```css
/* ❌ 금지 - 레이아웃 속성 애니메이트 */
transition: width 300ms, height 300ms, margin 300ms;

/* ❌ 금지 - 너무 느린 트랜지션 */
transition: all 1s ease;

/* ❌ 금지 - 무한 회전 (목적 없는 장식) */
animation: spin 2s infinite linear;
```

**React (Motion 라이브러리):**
```tsx
import { motion } from 'motion/react';

// 페이지 진입
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3, ease: 'easeOut' }}
>
  {content}
</motion.div>

// 리스트 스태거
<motion.ul>
  {items.map((item, i) => (
    <motion.li
      key={item.id}
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: i * 0.05 }}
    >
      {item.name}
    </motion.li>
  ))}
</motion.ul>
```

**상세**: [references/animation-patterns.md](references/animation-patterns.md)

### 레이아웃

**DO:**
```css
/* 비대칭, 그리드 브레이킹 */
.hero {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: clamp(2rem, 5vw, 4rem);
}

/* 여백은 넉넉하게 */
section {
  padding: clamp(4rem, 10vh, 8rem) 0;
}

/* Container queries (2026 표준) */
@container (min-width: 400px) {
  .card { flex-direction: row; }
}
```

**DON'T:**
```css
/* ❌ 금지 - 완벽한 대칭 (지루함) */
grid-template-columns: 1fr 1fr;

/* ❌ 금지 - 빽빽한 레이아웃 */
padding: 10px;
gap: 8px;
```

## 접근성 체크리스트

| 항목 | 기준 | 확인 |
|------|------|------|
| 색상 대비 | WCAG AA (4.5:1 텍스트, 3:1 UI) | [ ] |
| 키보드 네비게이션 | 모든 인터랙티브 요소 접근 가능 | [ ] |
| 포커스 표시 | 명확한 포커스 링 | [ ] |
| 모션 감소 | prefers-reduced-motion 처리 | [ ] |
| 스크린 리더 | 시맨틱 HTML, aria-label | [ ] |
| 텍스트 크기 | 16px 이상 본문 | [ ] |
| 터치 타겟 | 44x44px 이상 | [ ] |

## 금지 사항 (Anti-patterns)

| 카테고리 | 금지 항목 |
|----------|----------|
| 폰트 | Inter, Roboto, Arial, system fonts 단독 사용 |
| 컬러 | 퍼플 그라디언트 on 화이트, 순백색 배경 |
| 레이아웃 | 완벽 대칭, 좁은 여백, 쿠키커터 카드 |
| 애니메이션 | 목적 없는 회전, 1초+ 트랜지션, layout 애니메이트 |
| 패턴 | 동일한 그림자, 동일한 border-radius, 복사된 UI |

## 참조 문서

- [references/typography-2026.md](references/typography-2026.md) - 폰트 선택, 스케일, 페어링
- [references/colors-2026.md](references/colors-2026.md) - OKLCH, 팔레트, 다크모드
- [references/animation-patterns.md](references/animation-patterns.md) - CSS/JS 패턴, 라이브러리

## Sources

- [UI Trends 2026 - UX Studio Team](https://www.uxstudioteam.com/ux-blog/ui-trends-2019)
- [12 UI/UX Design Trends - Index.dev](https://www.index.dev/blog/ui-ux-design-trends)
- [Typography Trends 2026 - Wannathis](https://wannathis.one/blog/top-typography-trends-2026-for-designers)
- [Color Trends 2026 - Lounge Lizard](https://www.loungelizard.com/blog/web-design-color-trends/)
- [Motion UI Trends 2026 - Loma Technology](https://lomatechnology.com/blog/motion-ui-trends-2026/2911)
- [Motion Library](https://motion.dev/)
