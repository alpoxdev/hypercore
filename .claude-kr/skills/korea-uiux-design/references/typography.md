# 타이포그래피

<fonts>

**기본:** Pretendard | Spoqa Han Sans | Noto Sans KR
**시스템:** `-apple-system, BlinkMacSystemFont, sans-serif`
**영문 숫자:** Inter, SF Pro

</fonts>

---

<size_system>

| 용도 | 크기 | Tailwind |
|------|------|----------|
| 캡션/뱃지 | 11-12px | text-xs |
| 부가 정보 | 13px | text-[13px] |
| 본문 | 14-15px | text-sm/text-base |
| 강조 본문 | 16-17px | text-base/text-lg |
| 소제목 | 18-20px | text-lg/text-xl |
| 섹션 제목 | 22-24px | text-xl/text-2xl |
| 페이지 제목 | 26-32px | text-2xl/text-3xl |

</size_system>

---

<weight_system>

| 용도 | 웨이트 | Tailwind |
|------|--------|----------|
| 본문, 설명 | Regular(400) | font-normal |
| 버튼, 강조 | Medium(500) | font-medium |
| 제목, 레이블 | Semibold(600) | font-semibold |
| 대제목, 숫자 | Bold(700) | font-bold |

</weight_system>

---

<korean_specifics>

**자간:** `tracking-tight (-0.01em)` | `tracking-tighter (-0.02em)`
**행간:** 제목 `leading-tight (1.3)` | 본문 `leading-relaxed (1.6)` | `leading-loose (1.7)`

</korean_specifics>

---

<examples>

```tsx
{/* 페이지 제목 */}
<h1 className="text-3xl font-bold tracking-tight leading-tight">대시보드</h1>

{/* 섹션 제목 */}
<h2 className="text-xl font-semibold tracking-tight">최근 활동</h2>

{/* 본문 */}
<p className="text-sm font-normal leading-relaxed text-gray-700">본문</p>

{/* 부가 정보 */}
<span className="text-[13px] text-gray-500">2시간 전</span>

{/* 캡션/뱃지 */}
<span className="text-xs font-medium text-gray-600">신규</span>
```

</examples>
