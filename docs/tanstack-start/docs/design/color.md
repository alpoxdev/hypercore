# 색상 시스템

> **상위 문서**: [UI/UX 디자인 가이드](./index.md)

색상은 UI에서 가장 강력한 시각적 요소입니다. 일관된 색상 사용은 브랜드 인지도를 높이고 사용자 경험을 개선합니다.

## 60-30-10 규칙

디자이너들이 가장 많이 사용하는 색상 배분 규칙입니다.

```
┌─────────────────────────────────────────────────┐
│                                                 │
│              60% 기본색 (Primary)               │
│              배경, 여백, 기본 영역               │
│                                                 │
├───────────────────────────────────┬─────────────┤
│                                   │             │
│       30% 보조색 (Secondary)      │    10%      │
│       카드, 섹션, 구분 영역        │   강조색    │
│                                   │   (Accent)  │
│                                   │   버튼,     │
│                                   │   링크,     │
│                                   │   CTA       │
└───────────────────────────────────┴─────────────┘
```

### 실제 적용 예시

```tsx
// 60% - 배경
<div className="bg-white">              {/* 흰색 배경 */}

  // 30% - 보조 영역
  <section className="bg-gray-50">      {/* 밝은 회색 섹션 */}
    <div className="bg-white">          {/* 카드 배경 */}

      // 10% - 강조
      <button className="bg-blue-600">  {/* 주요 버튼 */}
        시작하기
      </button>
    </div>
  </section>
</div>
```

## 색상 팔레트 구성

### 1. 기본 색상 (Neutral Colors)

배경, 텍스트, 테두리에 사용하는 중립적인 색상입니다.

```
White       #FFFFFF   bg-white        가장 밝은 배경
Gray 50     #F9FAFB   bg-gray-50      섹션 배경
Gray 100    #F3F4F6   bg-gray-100     카드 배경, hover
Gray 200    #E5E7EB   bg-gray-200     테두리, 구분선
Gray 300    #D1D5DB   bg-gray-300     비활성 테두리
Gray 400    #9CA3AF   text-gray-400   비활성 텍스트
Gray 500    #6B7280   text-gray-500   보조 텍스트
Gray 600    #4B5563   text-gray-600   부제목
Gray 700    #374151   text-gray-700   본문
Gray 800    #1F2937   text-gray-800   제목
Gray 900    #111827   text-gray-900   강조 텍스트
```

### 2. 브랜드 색상 (Brand Colors)

서비스를 대표하는 주요 색상입니다. **1-2가지**만 선택하세요.

```tsx
// 예시: 파란색 브랜드
const brandColors = {
  primary: {
    50:  '#EFF6FF',  // 매우 밝은 배경
    100: '#DBEAFE',  // 밝은 배경
    200: '#BFDBFE',  // hover 배경
    300: '#93C5FD',  // 테두리
    400: '#60A5FA',  // 비활성 버튼
    500: '#3B82F6',  // 기본 버튼
    600: '#2563EB',  // hover 버튼
    700: '#1D4ED8',  // active 버튼
    800: '#1E40AF',  // 어두운 버튼
    900: '#1E3A8A',  // 매우 어두운
  }
}
```

### 3. 의미론적 색상 (Semantic Colors)

특정 의미를 가진 색상입니다. **절대 다른 용도로 사용하지 마세요.**

| 색상 | 의미 | 사용처 | Tailwind |
|------|------|--------|----------|
| 🟢 Green | 성공, 완료 | 성공 메시지, 체크 | `text-green-600` |
| 🔴 Red | 오류, 위험 | 에러 메시지, 삭제 | `text-red-600` |
| 🟡 Yellow | 경고, 주의 | 경고 메시지 | `text-yellow-600` |
| 🔵 Blue | 정보, 안내 | 안내 메시지, 링크 | `text-blue-600` |

```tsx
// ✅ 올바른 사용
<span className="text-green-600">저장되었습니다</span>
<span className="text-red-600">필수 항목입니다</span>

// ❌ 잘못된 사용 - 빨간색을 장식용으로
<span className="text-red-600">새로운 기능!</span>
```

## 색상 대비 (Contrast)

### WCAG 접근성 기준

텍스트가 잘 읽히려면 배경과 충분한 대비가 필요합니다.

| 기준 | 최소 대비 | 적용 대상 |
|------|----------|----------|
| AA (일반) | 4.5:1 | 일반 텍스트 (16px 미만) |
| AA (큰 텍스트) | 3:1 | 큰 텍스트 (18px 이상) |
| AAA (강화) | 7:1 | 최고 수준 접근성 |

### 안전한 조합

```tsx
// ✅ 좋은 대비 (흰 배경)
<p className="text-gray-900">진한 텍스트 - 대비 15.8:1</p>
<p className="text-gray-700">본문 텍스트 - 대비 8.6:1</p>
<p className="text-gray-600">보조 텍스트 - 대비 5.7:1</p>

// ⚠️ 주의 필요
<p className="text-gray-500">밝은 텍스트 - 대비 4.6:1 (경계)</p>

// ❌ 피해야 함
<p className="text-gray-400">너무 밝음 - 대비 3.0:1</p>
```

### 버튼 색상 대비

```tsx
// ✅ 좋은 버튼 대비
<button className="bg-blue-600 text-white">    {/* 흰색 on 파란색 */}
<button className="bg-gray-900 text-white">    {/* 흰색 on 검정색 */}
<button className="bg-white text-gray-900 border"> {/* 검정색 on 흰색 */}

// ❌ 나쁜 버튼 대비
<button className="bg-yellow-300 text-white">  {/* 대비 부족 */}
<button className="bg-gray-200 text-gray-400"> {/* 대비 부족 */}
```

## 다크 모드

다크 모드는 선택이 아닌 필수가 되어가고 있습니다.

### 색상 반전 원칙

```
라이트 모드              다크 모드
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bg-white         ←→     bg-gray-900
bg-gray-50       ←→     bg-gray-800
bg-gray-100      ←→     bg-gray-700
text-gray-900    ←→     text-white
text-gray-700    ←→     text-gray-200
text-gray-500    ←→     text-gray-400
```

### Tailwind 다크 모드 적용

```tsx
// 기본 패턴
<div className="bg-white dark:bg-gray-900">
  <h1 className="text-gray-900 dark:text-white">제목</h1>
  <p className="text-gray-600 dark:text-gray-300">본문</p>
</div>

// 카드 컴포넌트
<div className="bg-white dark:bg-gray-800
               border border-gray-200 dark:border-gray-700
               shadow-sm">
  <h3 className="text-gray-900 dark:text-white">카드 제목</h3>
</div>
```

## 색상 사용 체크리스트

### 반드시 지켜야 할 것

- [ ] 브랜드 색상은 1-2가지만 사용
- [ ] 의미론적 색상(빨강, 초록 등)은 해당 의미로만 사용
- [ ] 텍스트-배경 대비 4.5:1 이상 유지
- [ ] 색상만으로 정보 전달하지 않기 (아이콘/텍스트 병행)

### 권장 사항

- [ ] 60-30-10 규칙 따르기
- [ ] 다크 모드 지원
- [ ] 색상 변수(토큰) 사용
- [ ] 일관된 색상 네이밍

## Tailwind 설정

```css
/* app/styles/app.css */
@import "tailwindcss";

@theme {
  /* 브랜드 색상 */
  --color-primary-50: oklch(0.97 0.01 250);
  --color-primary-100: oklch(0.93 0.03 250);
  --color-primary-500: oklch(0.55 0.2 250);
  --color-primary-600: oklch(0.48 0.22 250);
  --color-primary-700: oklch(0.42 0.2 250);

  /* 의미론적 색상 */
  --color-success: oklch(0.55 0.15 145);
  --color-error: oklch(0.55 0.2 25);
  --color-warning: oklch(0.75 0.15 85);
  --color-info: oklch(0.55 0.2 250);
}
```

```tsx
// 사용 예시
<button className="bg-primary-600 hover:bg-primary-700">
  주요 버튼
</button>

<span className="text-success">성공!</span>
<span className="text-error">오류 발생</span>
```

## 참고 자료

- [Tailwind CSS Colors](https://tailwindcss.com/docs/colors)
- [WCAG Color Contrast](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [Coolors - 색상 팔레트 생성](https://coolors.co/)
