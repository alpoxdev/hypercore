# 아이콘 가이드

<size_system>

| 크기 | 용도 | 터치 영역 |
|------|------|----------|
| 16px, 20px | 텍스트와 함께 | - |
| 24px | 기본 시스템 아이콘 | 44-48px |
| 32-48px | 강조 | 그대로 |

**규칙:** 4px/8px 배수 | ✅ 16, 20, 24, 32, 48 | ❌ 홀수, 소수점

</size_system>

---

<touch_target>

**최소 터치 영역:** Apple 44px | Google 48px | 한국 44-48px

```tsx
{/* ✅ 충분한 터치 영역 */}
<button className="w-12 h-12 flex items-center justify-center">
  <svg className="w-6 h-6" />
</button>

{/* ❌ 부족 */}
<button className="w-8 h-8"><svg className="w-4 h-4" /></button>
```

</touch_target>

---

<styles>

**Outline (기본):** 깔끔, 미니멀, 비활성 상태
**Filled (활성):** 선택/활성 상태, 강조

**선 두께 (KRDS):**
- 16px: 1.2-1.5px
- 20px: 1.5-1.8px
- 24px: 1.6-2px
- 32px: 2-2.5px
- 48px: 3px

```tsx
{/* Outline */}
<svg className="w-6 h-6 stroke-current text-gray-600" fill="none" />

{/* Filled */}
<svg className="w-6 h-6 fill-current text-primary-500" />
```

</styles>

---

<libraries>

| 라이브러리 | 특징 | 적합성 |
|-----------|------|--------|
| **Heroicons** | Tailwind, 라인/채움 | ⭐⭐⭐⭐⭐ |
| **Lucide** | Feather 후속, 깔끔 | ⭐⭐⭐⭐⭐ |
| **Phosphor** | 다양한 웨이트 | ⭐⭐⭐⭐ |
| **Material Icons** | Google, 다양 스타일 | ⭐⭐⭐⭐ |
| **Tabler Icons** | 미니멀 라인 | ⭐⭐⭐⭐ |

```tsx
import { HomeIcon } from '@heroicons/react/24/outline';
import { HomeIcon as HomeSolid } from '@heroicons/react/24/solid';
```

</libraries>

---

<colors>

```tsx
{/* 비활성 */}
<svg className="w-6 h-6 text-gray-600" />

{/* 활성 */}
<svg className="w-6 h-6 text-primary-500" />

{/* 호버 */}
<svg className="w-6 h-6 text-gray-600 hover:text-gray-900 transition-colors" />

{/* Semantic */}
<svg className="w-5 h-5 text-green-500" />  {/* Success */}
<svg className="w-5 h-5 text-red-500" />    {/* Error */}
```

</colors>

---

<component_sizes>

```tsx
{/* Small Button: 아이콘 16px */}
<button className="h-8 px-3 flex items-center gap-1.5">
  <svg className="w-4 h-4" /><span>버튼</span>
</button>

{/* Medium Button: 아이콘 20px */}
<button className="h-11 px-4 flex items-center gap-2">
  <svg className="w-5 h-5" /><span>버튼</span>
</button>

{/* Icon Only: 터치 영역 44px + 아이콘 24px */}
<button className="w-11 h-11 flex items-center justify-center">
  <svg className="w-6 h-6" />
</button>

{/* 인풋 좌측 */}
<div className="relative">
  <div className="absolute left-3 top-1/2 -translate-y-1/2">
    <svg className="w-5 h-5 text-gray-400" />
  </div>
  <input className="w-full h-11 pl-10 pr-3" />
</div>

{/* 빈 상태 */}
<div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center">
  <svg className="w-10 h-10 text-gray-400" />
</div>
```

</component_sizes>

---

<accessibility>

```tsx
{/* ✅ aria-label */}
<button aria-label="알림">
  <svg className="w-6 h-6" aria-hidden="true" />
</button>

{/* ✅ 텍스트와 함께 */}
<button>
  <svg className="w-5 h-5" aria-hidden="true" />
  <span>검색</span>
</button>

{/* ❌ 레이블 없음 */}
<button><svg className="w-6 h-6" /></button>
```

</accessibility>

---

<animation>

```tsx
{/* 호버 */}
<svg className="w-6 h-6 text-gray-600 hover:text-gray-900 transition-colors" />
<svg className="w-6 h-6 hover:scale-110 transition-transform" />

{/* 로딩 */}
<svg className="w-6 h-6 animate-spin text-primary-500" />
<svg className="w-6 h-6 animate-pulse text-gray-400" />
```

</animation>

---

<sources>

- [KRDS 아이콘 가이드](https://www.krds.go.kr/html/site/style/style_06.html)
- [Gmarket Design System - Iconography](https://gds.gmarket.co.kr/foundation/iconography)
- [Heroicons](https://heroicons.com)
- [Lucide Icons](https://lucide.dev)

</sources>
