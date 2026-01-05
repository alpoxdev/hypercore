# Colors 2026 Guide

## OKLCH 컬러 시스템

2026년 표준. 인간 지각에 맞춰 설계된 컬러 모델.

### 구조

```
oklch(L% C H)
L = Lightness (0-100%)
C = Chroma (0-0.4, 채도)
H = Hue (0-360, 색상)
```

### 장점

| 기존 방식 | OKLCH |
|-----------|-------|
| 밝기 변경 시 채도 왜곡 | 일관된 밝기 조절 |
| 다크모드 팔레트 별도 제작 | L값만 변경 |
| 접근성 대비 계산 복잡 | L값으로 직관적 대비 |

## 팔레트 구성

### 기본 구조

```css
:root {
  /* === Base === */
  --bg-primary: oklch(98% 0.005 90);    /* 웜 오프화이트 */
  --bg-secondary: oklch(95% 0.01 90);   /* 린넨 */
  --bg-tertiary: oklch(92% 0.015 90);   /* 샌드 */
  --bg-elevated: oklch(100% 0 0);       /* 카드, 모달 */

  /* === Text === */
  --text-primary: oklch(20% 0.01 90);   /* 헤드라인 */
  --text-secondary: oklch(40% 0.02 90); /* 본문 */
  --text-tertiary: oklch(55% 0.02 90);  /* 보조 텍스트 */
  --text-muted: oklch(65% 0.01 90);     /* 플레이스홀더 */

  /* === Accent === */
  --accent: oklch(65% 0.2 180);         /* 프라이머리 */
  --accent-hover: oklch(60% 0.22 180);
  --accent-active: oklch(55% 0.24 180);
  --accent-subtle: oklch(95% 0.05 180); /* 배경용 */

  /* === Semantic === */
  --success: oklch(70% 0.18 145);
  --success-bg: oklch(95% 0.05 145);
  --warning: oklch(75% 0.15 85);
  --warning-bg: oklch(95% 0.05 85);
  --error: oklch(60% 0.22 25);
  --error-bg: oklch(95% 0.05 25);
  --info: oklch(65% 0.15 240);
  --info-bg: oklch(95% 0.04 240);

  /* === Border === */
  --border-default: oklch(88% 0.01 90);
  --border-subtle: oklch(92% 0.005 90);
  --border-strong: oklch(75% 0.02 90);
}
```

### 다크 모드

```css
@media (prefers-color-scheme: dark) {
  :root {
    /* L값 반전 패턴 */
    --bg-primary: oklch(12% 0.01 90);
    --bg-secondary: oklch(16% 0.015 90);
    --bg-tertiary: oklch(20% 0.02 90);
    --bg-elevated: oklch(18% 0.015 90);

    --text-primary: oklch(92% 0.01 90);
    --text-secondary: oklch(75% 0.02 90);
    --text-tertiary: oklch(60% 0.02 90);
    --text-muted: oklch(50% 0.01 90);

    /* 액센트는 밝기만 조절 */
    --accent: oklch(70% 0.18 180);
    --accent-hover: oklch(75% 0.16 180);
    --accent-subtle: oklch(25% 0.08 180);

    --border-default: oklch(25% 0.02 90);
    --border-subtle: oklch(20% 0.01 90);
    --border-strong: oklch(35% 0.02 90);
  }
}
```

## 2026 트렌드 컬러

### Pantone 2026

| 이름 | OKLCH | HEX | 용도 |
|------|-------|-----|------|
| Cloud Dancer | oklch(97% 0.005 90) | #F5F5F5 | 배경 베이스 |
| Mocha Mousse | oklch(55% 0.08 55) | #A47764 | 어시 액센트 |

### 주요 액센트

| 이름 | OKLCH | HEX | 무드 |
|------|-------|-----|------|
| Transformative Teal | oklch(65% 0.15 180) | #2D9CCA | 신뢰, 성장 |
| Neo Mint | oklch(85% 0.1 160) | #AAF0D1 | 프레시, 테크 |
| Soft Coral | oklch(75% 0.12 30) | #FFB5A7 | 따뜻함 |
| Electric Blue | oklch(60% 0.2 250) | #3366FF | 에너지 |
| Muted Purple | oklch(55% 0.12 300) | #8B7BA5 | 크리에이티브 |
| Pastel Orange | oklch(80% 0.1 60) | #FFD4A3 | 친근함 |

## 테마별 팔레트

### Calm Minimal

```css
:root {
  --bg-primary: oklch(98% 0.003 60);    /* 아이보리 */
  --text-primary: oklch(25% 0.01 60);
  --accent: oklch(45% 0.08 180);        /* 딥 틸 */
}
```

### Bold Maximalist

```css
:root {
  --bg-primary: oklch(15% 0.02 280);    /* 딥 네이비 */
  --text-primary: oklch(95% 0.01 60);
  --accent: oklch(70% 0.25 30);         /* 비비드 오렌지 */
  --accent-secondary: oklch(75% 0.2 320); /* 핑크 */
}
```

### Organic Natural

```css
:root {
  --bg-primary: oklch(95% 0.02 80);     /* 크림 */
  --text-primary: oklch(30% 0.04 80);   /* 브라운 */
  --accent: oklch(50% 0.12 140);        /* 포레스트 */
}
```

### Liquid Glass

```css
:root {
  --bg-primary: oklch(98% 0.01 240 / 0.9);  /* 반투명 */
  --glass: oklch(100% 0 0 / 0.6);
  --glass-border: oklch(100% 0 0 / 0.2);
  --accent: oklch(65% 0.18 200);
}

.glass-card {
  background: var(--glass);
  backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid var(--glass-border);
}
```

## 접근성

### 대비 계산

```
WCAG AA 기준:
- 일반 텍스트: 4.5:1
- 큰 텍스트 (18px+): 3:1
- UI 컴포넌트: 3:1

OKLCH에서 대비 확보:
- L값 차이 최소 50% 권장 (텍스트 vs 배경)
```

### 안전한 조합

| 배경 L값 | 텍스트 L값 | 대비 |
|----------|-----------|------|
| 95%+ | 30% 이하 | AA 충족 |
| 15% 이하 | 85%+ | AA 충족 |

## 금지 패턴

```css
/* ❌ 순백색 배경 */
background: #ffffff;
background: oklch(100% 0 0);

/* ❌ AI 슬롭 퍼플 그라디언트 */
background: linear-gradient(135deg, #667eea, #764ba2);

/* ❌ 너무 채도 높은 배경 */
background: oklch(50% 0.3 180);  /* C값 0.2 이하 권장 */

/* ❌ 대비 부족 */
color: oklch(60% 0.1 90);       /* on 80% 배경 = 실패 */
```

## 실용 팁

### 그라디언트

```css
/* OKLCH 그라디언트 (더 자연스러운 중간색) */
background: linear-gradient(
  135deg,
  oklch(65% 0.15 180),
  oklch(55% 0.18 220)
);

/* 색상 공간 명시 */
background: linear-gradient(
  in oklch,
  oklch(70% 0.2 30),
  oklch(65% 0.18 60)
);
```

### 투명도

```css
/* 알파 채널 */
background: oklch(65% 0.15 180 / 0.8);
border: 1px solid oklch(65% 0.15 180 / 0.3);
```

### 동적 밝기

```css
/* CSS 변수로 밝기 조절 */
:root {
  --accent-h: 180;
  --accent-c: 0.15;
}

.accent {
  background: oklch(65% var(--accent-c) var(--accent-h));
}
.accent:hover {
  background: oklch(60% var(--accent-c) var(--accent-h));
}
```
