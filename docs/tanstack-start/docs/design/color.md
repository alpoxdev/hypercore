# 색상 시스템

## 60-30-10 규칙

```
60% 기본색 - 배경, 여백
30% 보조색 - 카드, 섹션
10% 강조색 - 버튼, 링크, CTA
```

## 색상 팔레트

### 기본색 (Neutral)
```
bg-white      가장 밝은 배경
bg-gray-50    섹션 배경
bg-gray-100   카드 배경, hover
bg-gray-200   테두리, 구분선
text-gray-500 보조 텍스트
text-gray-700 본문
text-gray-900 제목, 강조
```

### 의미론적 색상

| 색상 | 의미 | Tailwind |
|------|------|----------|
| 🟢 Green | 성공, 완료 | `text-green-600` |
| 🔴 Red | 오류, 위험 | `text-red-600` |
| 🟡 Yellow | 경고, 주의 | `text-yellow-600` |
| 🔵 Blue | 정보, 안내 | `text-blue-600` |

```tsx
// ✅ 올바른 사용
<span className="text-green-600">저장되었습니다</span>
<span className="text-red-600">필수 항목입니다</span>

// ❌ 잘못된 사용 - 빨간색을 장식용으로
<span className="text-red-600">새로운 기능!</span>
```

## 색상 대비 (WCAG)

| 기준 | 최소 대비 | 적용 대상 |
|------|----------|----------|
| AA | 4.5:1 | 일반 텍스트 |
| AA (큰 텍스트) | 3:1 | 18px 이상 |
| AAA | 7:1 | 최고 접근성 |

```tsx
// ✅ 좋은 대비
<p className="text-gray-900">대비 15.8:1</p>
<p className="text-gray-700">대비 8.6:1</p>

// ❌ 피해야 함
<p className="text-gray-400">대비 3.0:1</p>
```

## 다크 모드

```
라이트             다크
bg-white     ←→    bg-gray-900
bg-gray-50   ←→    bg-gray-800
text-gray-900 ←→   text-white
text-gray-600 ←→   text-gray-300
```

```tsx
<div className="bg-white dark:bg-gray-900">
  <h1 className="text-gray-900 dark:text-white">제목</h1>
  <p className="text-gray-600 dark:text-gray-300">본문</p>
</div>
```

## Tailwind 설정

```css
@theme {
  --color-primary-500: oklch(0.55 0.2 250);
  --color-primary-600: oklch(0.48 0.22 250);
  --color-success: oklch(0.55 0.15 145);
  --color-error: oklch(0.55 0.2 25);
  --color-warning: oklch(0.75 0.15 85);
}
```

## 체크리스트

- [ ] 브랜드 색상 1-2가지만
- [ ] 의미론적 색상은 해당 의미로만
- [ ] 대비 4.5:1 이상
- [ ] 색상만으로 정보 전달 금지 (아이콘/텍스트 병행)
