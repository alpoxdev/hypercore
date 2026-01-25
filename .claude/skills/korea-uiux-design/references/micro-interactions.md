# 마이크로 인터랙션

<principles>

**시간:** 150-250ms 적절 | <100ms 너무 빠름 | >300ms 너무 느림
**이징:** ease-out, cubic-bezier(0.4, 0, 0.2, 1)
**목적:** 피드백 제공, 상태 변화 명확, 주의 집중

✅ 피드백/상태/집중 | ❌ 장식/과도한 움직임/불필요한 딜레이

</principles>

---

<button>

```tsx
{/* 호버: 배경색 */}
<button className="bg-primary-500 hover:bg-primary-600 transition-colors duration-200">버튼</button>

{/* 호버: 그림자 */}
<button className="shadow-sm hover:shadow-md transition-shadow duration-200">버튼</button>

{/* 호버: 크기 */}
<button className="hover:scale-105 transition-transform duration-200">버튼</button>

{/* 클릭: Scale down */}
<button className="active:scale-95 transition-transform duration-150">버튼</button>

{/* 로딩 */}
<button disabled className="bg-primary-500 text-white flex items-center gap-2">
  <svg className="w-5 h-5 animate-spin" />{isLoading ? '처리 중...' : '저장하기'}
</button>
```

</button>

---

<input>

```tsx
{/* 포커스: 링 */}
<input className="border focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200" />

{/* 플로팅 레이블 */}
<div className="relative">
  <input
    id="email"
    className="peer w-full h-12 px-3 pt-5 pb-1 border rounded-lg focus:border-primary-500 transition-colors"
    placeholder=" "
  />
  <label
    htmlFor="email"
    className="absolute left-3 top-1/2 -translate-y-1/2 transition-all duration-200 peer-focus:top-2 peer-focus:text-xs peer-focus:text-primary-500 peer-[:not(:placeholder-shown)]:top-2 peer-[:not(:placeholder-shown)]:text-xs"
  >
    이메일
  </label>
</div>

{/* 에러 Shake */}
<input className={hasError ? 'animate-shake border-red-500' : 'border-gray-300'} />

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-8px); }
  75% { transform: translateX(8px); }
}
```

</input>

---

<card>

```tsx
{/* 미세한 그림자 */}
<div className="border rounded-xl hover:shadow-md transition-shadow duration-300" />

{/* 들어올리기 */}
<div className="border rounded-xl hover:-translate-y-1 hover:shadow-lg transition-all duration-300" />

{/* 테두리 색상 */}
<div className="border border-gray-200 rounded-xl hover:border-primary-500 transition-colors duration-300" />

{/* 클릭 가능 */}
<button className="w-full text-left p-4 border rounded-xl hover:border-primary-500 hover:shadow-md active:scale-[0.98] transition-all duration-200" />
```

</card>

---

<toggle>

```tsx
{/* 스위치 */}
<button
  onClick={() => setEnabled(!enabled)}
  className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors duration-200 ${
    enabled ? 'bg-primary-500' : 'bg-gray-300'
  }`}
>
  <span
    className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-200 ${
      enabled ? 'translate-x-6' : 'translate-x-1'
    }`}
  />
</button>

{/* 체크박스 */}
<label className="flex items-center gap-2 cursor-pointer">
  <input type="checkbox" className="peer sr-only" />
  <div className="w-5 h-5 border-2 border-gray-300 rounded peer-checked:bg-primary-500 peer-checked:border-primary-500 transition-all duration-200 flex items-center justify-center">
    <svg className="w-3 h-3 text-white scale-0 peer-checked:scale-100 transition-transform duration-200" />
  </div>
  <span>옵션</span>
</label>
```

</toggle>

---

<modal>

```tsx
{/* 페이드 인 */}
<div className={`fixed inset-0 bg-black/50 transition-opacity duration-300 ${
  isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
}`}>
  <div className={`fixed inset-0 flex items-center justify-center transition-transform duration-300 ${
    isOpen ? 'scale-100' : 'scale-95'
  }`}>
    <div className="bg-white rounded-2xl p-6 max-w-md" />
  </div>
</div>

{/* 슬라이드 업 (바텀시트) */}
<div className={`fixed bottom-0 inset-x-0 bg-white rounded-t-2xl transition-transform duration-300 ${
  isOpen ? 'translate-y-0' : 'translate-y-full'
}`} />
```

</modal>

---

<loading>

```tsx
{/* 스켈레톤 */}
<div className="space-y-3 animate-pulse">
  <div className="h-4 bg-gray-200 rounded w-3/4" />
  <div className="h-4 bg-gray-200 rounded w-1/2" />
</div>

{/* 스피너 */}
<svg className="w-6 h-6 animate-spin text-primary-500">
  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
</svg>

{/* 프로그레스 바 */}
<div className="fixed top-0 left-0 right-0 h-1 bg-gray-200">
  <div className="h-full bg-primary-500 transition-all duration-300" style={{ width: `${progress}%` }} />
</div>
```

</loading>

---

<toast>

```tsx
{/* 하단 슬라이드 업 */}
<div className={`fixed bottom-4 left-1/2 -translate-x-1/2 transition-all duration-300 ${
  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0 pointer-events-none'
}`}>
  <div className="bg-gray-900 text-white px-4 py-3 rounded-lg shadow-lg">
    저장되었습니다
  </div>
</div>

{/* 우측 슬라이드 인 */}
<div className={`fixed top-4 right-4 transition-all duration-300 ${
  isVisible ? 'translate-x-0 opacity-100' : 'translate-x-4 opacity-0 pointer-events-none'
}`}>
  <div className="bg-white border px-4 py-3 rounded-lg shadow-lg">
    작업이 완료되었습니다
  </div>
</div>
```

</toast>

---

<page_transition>

```tsx
{/* Fade */}
<div className="animate-fadeIn" />

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

{/* Slide Up */}
<div className="animate-slideUp" />

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
```

</page_transition>

---

<avoid>

❌ 모든 요소에 애니메이션
❌ 300ms+ 느린 전환
❌ 복잡한 3D 효과
❌ 자동 재생 애니메이션 (접근성)

**Reduced Motion:**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

```tsx
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
<button className={prefersReducedMotion ? '' : 'hover:scale-105 transition-transform'}>버튼</button>
```

</avoid>

---

<sources>

- [디자인베이스 - 마이크로인터랙션](https://designbase.co.kr/dictionary/microinteractions/)
- [디자인키트 - Micro Interactions](https://www.designkits.co.kr/blog/web-terminology/Micro-Interactions)
- [Micron.js](https://webkul.github.io/micron/)
- [CSS 애니메이션으로 UX 향상](https://velog.io/@jiheon788/Micro-Interactions의-도입-CSS-애니메이션으로-사용자-경험UX-향상하기)

</sources>
