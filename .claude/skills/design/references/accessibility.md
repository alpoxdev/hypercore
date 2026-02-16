# Accessibility (WCAG 2.2 AA)

<pour_principles>

## POUR 원칙

| 원칙 | 설명 | 구현 |
|------|------|------|
| **Perceivable** | 인지 가능 | 대체 텍스트, 자막, 색상 대비 |
| **Operable** | 조작 가능 | 키보드, 충분한 시간 |
| **Understandable** | 이해 가능 | 명확한 언어, 일관된 UI |
| **Robust** | 견고성 | 시맨틱 HTML, ARIA |

</pour_principles>

---

<color_contrast>

## 색상 대비 (WCAG 2.2)

| 유형 | 최소 비율 | 예시 |
|------|----------|------|
| **일반 텍스트** | 4.5:1 | 14px body text |
| **큰 텍스트** | 3:1 | 18pt+ 또는 14pt bold+ |
| **Interactive 요소** | 3:1 | 버튼, 아이콘 |

```tsx
// ✅ 충분한 대비
<button className="bg-blue-600 text-white">Save</button>

// ❌ 불충분한 대비
<button className="bg-gray-100 text-gray-300">Save</button>
```

</color_contrast>

---

<keyboard_navigation>

## 키보드 네비게이션

| 키 | 동작 | 적용 |
|---|------|------|
| **Tab** | 다음 요소 | tabindex 순서 |
| **Enter/Space** | 활성화 | 버튼, 링크 |
| **Esc** | 취소/닫기 | 모달, 드롭다운 |
| **↑↓** | 선택 이동 | 드롭다운, 슬라이더 |

```tsx
// ✅ 키보드 접근 가능
<button
  tabIndex={0}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick()
    }
  }}
>
  Click me
</button>
```

</keyboard_navigation>

---

<aria_attributes>

## ARIA 속성

| 속성 | 용도 | 예시 |
|------|------|------|
| **role** | 역할 명시 | `role="navigation"` |
| **aria-label** | 레이블 제공 | `aria-label="Close menu"` |
| **aria-labelledby** | 레이블 ID 참조 | `aria-labelledby="title-id"` |
| **aria-expanded** | 확장 상태 | `aria-expanded={isOpen}` |
| **aria-live** | 동적 업데이트 | `aria-live="polite"` |

```tsx
// ✅ ARIA 속성 사용
<button
  aria-label="Close menu"
  aria-expanded={isOpen}
  aria-controls="menu-id"
>
  <svg className="w-6 h-6" aria-hidden="true" />
</button>
```

</aria_attributes>

---

<screen_readers>

## 스크린 리더 테스트

| 도구 | 플랫폼 | 용도 |
|------|--------|------|
| **VoiceOver** | macOS/iOS | Safari |
| **NVDA** | Windows | Firefox |
| **JAWS** | Windows | Chrome |

</screen_readers>
