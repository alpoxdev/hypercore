# UI/UX 디자인 가이드

> TanStack Start + Tailwind CSS v4

@components.md
@safe-area.md
@tailwind-setup.md

---

## 핵심 원칙

| 원칙 | 설명 |
|------|------|
| **일관성** | 같은 요소는 같은 스타일과 동작 |
| **계층 구조** | 중요한 것이 먼저 눈에 들어옴 |
| **단순함** | 색상 3-5개, 폰트 2-3개, 충분한 여백 |
| **접근성** | 충분한 대비, 읽기 쉬운 크기, 키보드 조작 |

---

## 색상 (60-30-10 규칙)

```
60% - 배경색 (중립색)
30% - 보조색 (카드, 섹션)
10% - 강조색 (버튼, CTA)
```

### 의미론적 색상

| 색상 | 의미 | Tailwind |
|------|------|----------|
| 🟢 Green | 성공 | `text-green-600` |
| 🔴 Red | 오류 | `text-red-600` |
| 🟡 Yellow | 경고 | `text-yellow-600` |
| 🔵 Blue | 정보 | `text-blue-600` |

### 다크 모드 매핑

```
라이트 ←→ 다크
bg-white     ←→ bg-gray-900
bg-gray-50   ←→ bg-gray-800
text-gray-900 ←→ text-white
text-gray-600 ←→ text-gray-300
```

---

## 폰트

| 폰트 | 용도 |
|------|------|
| Pretendard | 한글 (권장) |
| Inter | 영문 |
| JetBrains Mono | 코드 |

### 크기

```
text-4xl  36px  h1
text-2xl  24px  h2, h3
text-base 16px  본문
text-sm   14px  보조 텍스트
```

### Tailwind 설정

```css
@theme {
  --font-sans: "Pretendard", "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", monospace;
}
```

---

## 간격 (8px 그리드)

| 용도 | Tailwind | 크기 |
|------|----------|------|
| 아이콘-텍스트 | gap-1 | 4px |
| 인라인 요소 | gap-2 | 8px |
| 카드 내부 | p-4 | 16px |
| 카드 간격 | gap-6 | 24px |
| 섹션 간격 | py-12 | 48px |

### 컨테이너

```
max-w-md   448px   폼
max-w-lg   512px   모달
max-w-3xl  768px   블로그
max-w-7xl  1280px  대시보드
```

---

## 접근성 (WCAG AA)

### 색상 대비

| 기준 | 최소 대비 | 적용 대상 |
|------|----------|----------|
| AA | 4.5:1 | 일반 텍스트 |
| AA (큰 텍스트) | 3:1 | 18px 이상 |

```tsx
// ❌ 색상만으로 구분
<span className="text-red-600">오류</span>

// ✅ 아이콘/텍스트 병행
<span className="text-red-600 flex items-center gap-1">
  <XCircleIcon className="w-4 h-4" />
  오류가 발생했습니다
</span>
```

### 키보드

```tsx
// ✅ 명확한 포커스 스타일
<button className="focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">

// ❌ 포커스 제거 금지
<button className="outline-none focus:outline-none">
```

### 폼

```tsx
<label htmlFor="email">이메일</label>
<input
  id="email"
  required
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && <p id="email-error" role="alert">오류</p>}
```

### 체크리스트

- [ ] 모든 이미지에 alt
- [ ] 폼 요소에 레이블
- [ ] 키보드 접근 가능
- [ ] 포커스 표시 유지
- [ ] 대비 4.5:1 이상
- [ ] 색상만으로 정보 전달 금지
- [ ] 터치 영역 44px 이상
