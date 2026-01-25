---
name: stitch:design
description: 프로젝트 디자인 시스템 분석 후 DESIGN.md 생성
---

<purpose>
프로젝트의 디자인 자산(UI 컴포넌트, 스타일)을 분석하여 디자인 시스템 문서(DESIGN.md) 생성
</purpose>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| "디자인 시스템 문서화" | 즉시 실행 |
| "DESIGN.md 생성" | 즉시 실행 |
| "디자인 가이드 작성" | 즉시 실행 |

</trigger_conditions>

---

<workflow>

<step number="1">
<action>프로젝트 구조 탐색</action>
<tools>Glob, Grep</tools>
<details>
- UI 컴포넌트 파일 찾기 (`components/**/*.tsx`)
- 스타일 파일 찾기 (`**/*.css`, `tailwind.config.*`)
- 디자인 토큰 파일 찾기
</details>
</step>

<step number="2">
<action>디자인 자산 분석</action>
<tools>Read</tools>
<details>
- Tailwind 설정에서 색상/타이포/간격 추출
- 컴포넌트에서 공통 스타일 패턴 파악
- CSS 변수에서 테마 정보 수집
</details>
</step>

<step number="3">
<action>디자인 언어로 변환</action>
<tools>-</tools>
<details>
| 기술적 표현 | 디자인 언어 |
|------------|------------|
| `rounded-full` | "완전한 원형" |
| `border-radius: 12px` | "부드러운 모서리" |
| `shadow-lg` | "깊은 그림자" |
| `#3B82F6` | "생동감 있는 파란색" |
</details>
</step>

<step number="4">
<action>DESIGN.md 작성</action>
<tools>Write</tools>
<details>
구조:
1. 비주얼 테마 (분위기, 느낌)
2. 색상 팔레트 (hex + 기능)
3. 타이포그래피 (폰트, 크기, 용도)
4. 컴포넌트 스타일링
5. 레이아웃/간격 원칙
</details>
</step>

</workflow>

---

<output_format>

```markdown
# Design System

## Visual Theme
[프로젝트의 전반적인 분위기와 느낌 서술]

## Color Palette

| 색상 | Hex | 기능 |
|------|-----|------|
| Primary | #3B82F6 | 주요 액션, CTA 버튼 |
| Secondary | #64748B | 보조 텍스트, 아이콘 |
| Background | #FFFFFF | 배경 |

## Typography

| 용도 | 폰트 | 크기 | 무게 |
|------|------|------|------|
| Heading | Inter | 32px | 700 |
| Body | Inter | 16px | 400 |

## Component Patterns

### 버튼
- 기본: 부드러운 모서리(8px), 생동감 있는 파란색
- Hover: 약간 어두운 파란색
- 패딩: 상하 12px, 좌우 24px

### 카드
- 배경: 흰색
- 테두리: 연한 회색(1px)
- 그림자: 부드러운 그림자
- 모서리: 부드러운(12px)

## Layout & Spacing

- 기본 그리드: 8px
- 컨테이너 최대 너비: 1280px
- 섹션 간격: 64px
```

</output_format>

---

<examples>

## Tailwind 프로젝트

**입력:**
```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: '#3B82F6',
        secondary: '#64748B',
      },
      borderRadius: {
        card: '12px',
      },
    },
  },
}
```

**출력:**
```markdown
## Color Palette

| 색상 | Hex | 기능 |
|------|-----|------|
| Primary Blue | #3B82F6 | 주요 액션 버튼, 링크, 강조 |
| Secondary Gray | #64748B | 보조 텍스트, 비활성 요소 |

## Component Patterns

### 카드
- 모서리: 부드러운 곡선(12px)
- 느낌: 현대적이고 깔끔한 외관
```

---

## CSS Variables 프로젝트

**입력:**
```css
:root {
  --color-brand: hsl(221, 83%, 53%);
  --font-heading: 'Poppins', sans-serif;
  --spacing-unit: 8px;
}
```

**출력:**
```markdown
## Visual Theme
밝고 신뢰감 있는 파란색 브랜드 컬러를 중심으로 한 현대적 디자인

## Typography
- Heading: Poppins (기하학적이고 친근한 느낌)

## Layout & Spacing
- 8px 그리드 시스템 사용
- 요소 간 일관된 간격 유지
```

</examples>

---

<validation>

**체크리스트:**
- [ ] 모든 색상에 hex 코드 포함
- [ ] 기술 용어 → 디자인 언어 변환
- [ ] 각 요소의 기능적 목적 설명
- [ ] 일관된 용어 사용
- [ ] 실제 사용 예시 포함

</validation>

---

<best_practices>

| 원칙 | 방법 |
|------|------|
| **서술적 표현** | "rounded-lg" → "부드럽게 둥근 모서리" |
| **기능 명시** | 색상 설명 시 "주요 액션 버튼에 사용" 추가 |
| **일관성** | 동일 개념은 동일 용어 사용 |
| **구체성** | "큰 그림자" < "깊이감 있는 그림자(16px blur)" |

</best_practices>
