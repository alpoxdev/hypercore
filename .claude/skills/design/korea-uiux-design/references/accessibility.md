# 접근성

<legal_basis>

**법적 근거:** 지능정보화기본법 제47조, 시행규칙 제5조
**국가표준:** KWCAG 2.2 (한국형 웹 콘텐츠 접근성 지침)
**국제표준:** WCAG 2.1/2.2
**인증:** 한국디지털접근성진흥원

</legal_basis>

---

<contrast>

**WCAG AA (필수):** 일반 텍스트 4.5:1+ | 큰 텍스트 3:1+ (18pt/24px+ 또는 14pt/18.66px+ Bold)
**WCAG AAA (권장):** 일반 텍스트 7:1+ | 큰 텍스트 4.5:1+
**척도:** 1:1 (구분 불가) ~ 21:1 (최대 대비)

```tsx
{/* ✅ AA 충족 (4.5:1+) */}
<p className="text-gray-900 bg-white">일반 텍스트</p>

{/* ✅ 큰 텍스트 (3:1+) */}
<h1 className="text-2xl font-bold text-gray-700 bg-white">제목</h1>

{/* ❌ 대비 부족 (2:1) */}
<p className="text-gray-400 bg-white">읽기 어려움</p>
```

**도구:** [Contrast Finder](https://app.contrast-finder.org/), Chrome DevTools

</contrast>

---

<keyboard>

**Tab 순서:** 논리적 순서 유지, tabindex 명시 금지

| 키 | 동작 |
|------|------|
| Tab | 다음 요소 |
| Shift+Tab | 이전 요소 |
| Enter | 버튼/링크 활성화 |
| Space | 버튼 활성화, 체크박스 토글 |
| Esc | 모달/드롭다운 닫기 |
| Arrow | 라디오, 탭 이동 |

```tsx
{/* ✅ 명확한 포커스 */}
<button className="focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2">
  버튼
</button>

{/* ❌ 포커스 스타일 제거 금지 */}
<button className="focus:outline-none">버튼</button>
```

</keyboard>

---

<semantic_html>

```tsx
{/* ✅ Semantic HTML */}
<header>
  <nav><ul><li><a href="/">홈</a></li></ul></nav>
</header>
<main><article><h1>제목</h1><p>본문</p></article></main>
<footer><p>© 2026 회사명</p></footer>

{/* ❌ Div만 사용 */}
<div className="header"><div className="nav"><div>홈</div></div></div>
```

</semantic_html>

---

<aria>

```tsx
{/* aria-label */}
<button aria-label="메뉴 열기"><svg className="w-6 h-6" /></button>

{/* aria-labelledby */}
<div aria-labelledby="dialog-title">
  <h2 id="dialog-title">확인</h2>
</div>

{/* aria-describedby */}
<input aria-describedby="email-hint" />
<span id="email-hint">example@email.com 형식</span>

{/* aria-hidden */}
<svg aria-hidden="true" className="w-5 h-5" />

{/* 상태 표시 */}
<button aria-expanded={isOpen} aria-controls="menu">메뉴</button>
<div role="tab" aria-selected={isActive}>탭</div>
<div role="checkbox" aria-checked={isChecked}>옵션</div>

{/* Live Regions */}
<div role="status" aria-live="polite" aria-atomic="true" className="sr-only">
  {message}
</div>
```

**aria-live:** polite (사용자 작업 후) | assertive (즉시) | off (없음)

</aria>

---

<screen_reader>

```tsx
{/* 스크린 리더 전용 텍스트 */}
<span className="sr-only">현재 페이지: 홈</span>

/* Tailwind CSS */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}

{/* 의미있는 아이콘 */}
<button aria-label="검색"><svg aria-hidden="true" className="w-5 h-5" /></button>

{/* 장식용 아이콘 */}
<button><svg aria-hidden="true" className="w-5 h-5" /><span>검색</span></button>
```

</screen_reader>

---

<forms>

```tsx
{/* ✅ label + input 연결 */}
<div>
  <label htmlFor="email" className="block text-sm font-medium mb-2">이메일</label>
  <input id="email" type="email" className="w-full h-11 px-3 border rounded-lg" />
</div>

{/* 필수 필드 */}
<div>
  <label htmlFor="name">
    이름 <span className="text-red-500" aria-label="필수">*</span>
  </label>
  <input id="name" required aria-required="true" />
</div>

{/* 에러 메시지 */}
<div>
  <label htmlFor="password">비밀번호</label>
  <input
    id="password"
    aria-invalid={hasError}
    aria-describedby="password-error"
    className={hasError ? 'border-red-500' : 'border-gray-300'}
  />
  {hasError && (
    <p id="password-error" className="text-sm text-red-600 mt-1" role="alert">
      비밀번호는 8자 이상이어야 합니다
    </p>
  )}
</div>
```

</forms>

---

<color_independence>

```tsx
{/* ❌ 색상만 */}
<span className="text-red-500">오류</span>

{/* ✅ 아이콘 + 텍스트 */}
<div className="flex items-center gap-2 text-red-500">
  <svg className="w-5 h-5" aria-hidden="true" />
  <span>오류가 발생했습니다</span>
</div>

{/* ✅ 패턴/모양 추가 */}
<button className="border-2 border-dashed border-primary-500">선택됨</button>
```

</color_independence>

---

<images>

```tsx
{/* ✅ 의미있는 이미지 */}
<img src="/logo.png" alt="회사 로고" />

{/* ✅ 정보 전달 */}
<img src="/graph.png" alt="2026년 1월 매출 15% 증가를 보여주는 그래프" />

{/* ✅ 장식용 */}
<img src="/decoration.png" alt="" role="presentation" />

{/* ❌ 불명확 */}
<img src="/photo.png" alt="이미지" />
```

</images>

---

<modal>

```tsx
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  className="fixed inset-0 z-50"
>
  <div className="fixed inset-0 bg-black/50" onClick={onClose} aria-hidden="true" />
  <div className="fixed inset-0 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl max-w-md w-full p-6">
      <h2 id="modal-title" className="text-xl font-semibold">제목</h2>
      <div>{children}</div>
      <button onClick={onClose} aria-label="모달 닫기" className="absolute top-4 right-4">
        ✕
      </button>
    </div>
  </div>
</div>
```

</modal>

---

<responsive_text>

```tsx
{/* ✅ 상대 단위 (rem, em) */}
<p className="text-base">{/* 1rem = 16px */}본문</p>

{/* ❌ 고정 픽셀 */}
<p style={{ fontSize: '14px' }}>본문</p>
```

</responsive_text>

---

<checklist>

### 필수

- [ ] 명암 대비 4.5:1+ (AA)
- [ ] 키보드 모든 기능 접근
- [ ] 포커스 스타일 명확
- [ ] Semantic HTML
- [ ] 모든 이미지 alt
- [ ] 폼 레이블 + input 연결
- [ ] 색상만 정보 전달 금지
- [ ] 스크린 리더 테스트

### 권장

- [ ] 명암 대비 7:1+ (AAA)
- [ ] ARIA 적절 사용
- [ ] Skip to content 링크
- [ ] 반응형 텍스트 (rem)
- [ ] 키보드 단축키

</checklist>

---

<sources>

- [WCAG 2.2 한국어](https://a11ykr.github.io/wcag22/)
- [한국디지털접근성진흥원](http://www.kwacc.or.kr/)
- [WCAG 2.1 Korean Translation](http://www.kwacc.or.kr/WAI/wcag21/)
- [MDN - 웹 접근성](https://developer.mozilla.org/ko/docs/Web/Accessibility/Guides/Understanding_WCAG)
- [Contrast Finder](https://app.contrast-finder.org/)

</sources>
