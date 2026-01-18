# 색상 시스템

<color_structure>

| 색상 | 용도 | 비율 |
|------|------|------|
| **Primary** | 버튼, 링크, 활성 상태 | 10% |
| **Secondary** | 필터, 칩, 보조 버튼 | 30% |
| **Background** | 배경 | 60% |
| **Semantic** | Success/Error/Warning/Info | 필요시 |

**60-30-10 규칙:** Background 60% | Secondary 30% | Primary 10%

</color_structure>

---

<semantic_colors>

| 용도 | 색상 | 용례 |
|------|------|------|
| Success | Green | 성공 메시지, 완료 상태 |
| Error | Red | 에러 메시지, 위험 경고 |
| Warning | Yellow/Orange | 주의 알림, 중요 정보 |
| Info | Blue | 일반 정보, 도움말 |

</semantic_colors>

---

<krds>

**한국 정부 표준 (KRDS):** 240개 색상 (24개 × 10단계), 50이 기본, WCAG AA

```css
/* Primary Blue */
--primary-50: #2196F3;  /* 기본 */
--primary-500: #2196F3;
--primary-600: #1E88E5;

/* Grayscale */
--gray-50: #9E9E9E;
--gray-600: #757575;
--gray-900: #212121;
```

</krds>

---

<service_colors>

| 서비스 | Primary | Secondary | 특징 |
|--------|---------|-----------|------|
| **토스** | Blue #3182F6 | Gray | 신뢰감, 단순 명확, 강한 파란색 |
| **카카오** | Yellow #FEE500 | Brown #3C1E1E | 친근함, 말풍선, radius 12px |
| **배민** | Teal #2AC1BC | Coral/Pink | 신선함, 손글씨 폰트, 일러스트 |

</service_colors>

---

<tailwind_config>

```js
// tailwind.config.js
colors: {
  primary: {
    DEFAULT: '#2196F3',
    50: '#E3F2FD',
    500: '#2196F3',
    600: '#1E88E5',
  },
  success: { DEFAULT: '#4CAF50', light: '#81C784', dark: '#388E3C' },
  error: { DEFAULT: '#F44336', light: '#E57373', dark: '#D32F2F' },
  warning: { DEFAULT: '#FF9800', light: '#FFB74D', dark: '#F57C00' },
  info: { DEFAULT: '#2196F3', light: '#64B5F6', dark: '#1976D2' },
}
```

</tailwind_config>

---

<dark_mode>

| 모드 | 배경 | 텍스트 |
|------|------|--------|
| **Light** | #FFFFFF, #F5F5F5 | #212121, #757575 |
| **Dark** | #121212, #1E1E1E | #FFFFFF, #B0B0B0 |

**특징:** 순수 검정(#000) 지양 → #121212, Primary 약간 밝게

</dark_mode>

---

<accessibility>

**WCAG AA:** 일반 텍스트 4.5:1+ | 큰 텍스트 3:1+
**WCAG AAA:** 일반 텍스트 7:1+ | 큰 텍스트 4.5:1+

```tsx
{/* ❌ 색상만 */}
<span className="text-red-500">오류</span>

{/* ✅ 아이콘 + 텍스트 */}
<div className="flex items-center gap-2 text-red-500">
  <svg className="w-5 h-5" />
  <span>오류가 발생했습니다</span>
</div>
```

**색약 고려:** 빨강-초록 색맹, 파랑-노랑 구분, 형태/아이콘 추가

</accessibility>

---

<examples>

```tsx
{/* Primary Button */}
<button className="bg-primary-500 hover:bg-primary-600 text-white">저장하기</button>

{/* Secondary Button */}
<button className="bg-secondary-200 hover:bg-secondary-300 text-secondary-900">취소</button>

{/* Success State */}
<div className="bg-success-light/10 border border-success text-success-dark p-3 rounded-lg">
  <div className="flex items-center gap-2">
    <svg className="w-5 h-5" />
    <span>성공적으로 저장되었습니다</span>
  </div>
</div>

{/* Error State */}
<div className="bg-error-light/10 border border-error text-error-dark p-3 rounded-lg">
  <div className="flex items-center gap-2">
    <svg className="w-5 h-5" />
    <span>오류가 발생했습니다</span>
  </div>
</div>
```

</examples>

---

<sources>

- [KRDS 색상 가이드](https://www.krds.go.kr/html/site/style/style_02.html)
- [Gmarket Design System - Colors](https://gds.gmarket.co.kr/foundation/color)
- [리메인 - 브랜드 컬러](https://www.remain.co.kr/page/designsystem/brand-color.php)

</sources>
