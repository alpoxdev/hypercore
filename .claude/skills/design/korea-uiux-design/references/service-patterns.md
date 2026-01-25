# 주요 서비스 패턴

<toss>

**산업:** 핀테크 | **키워드:** 신뢰, 명확성, 미니멀리즘

| 요소 | 내용 |
|------|------|
| **Primary** | Blue #3182F6 (신뢰감, 안정감) |
| **Secondary** | Gray (정보 위계 명확) |
| **폰트** | Pretendard, Spoqa Han Sans |
| **특징** | 단순 명확, 강한 파란색, 카드 중심, 흰색/밝은 회색 배경 |
| **UX 라이팅** | "어떤 이름으로 불러드릴까요?", "잠깐, 문제가 생겼어요" |

```tsx
{/* 금액 강조 */}
<div className="text-4xl font-bold">15,000원</div>
<div className="text-sm text-gray-600 mt-1">이번 달 총 지출</div>

{/* 카드 */}
<div className="p-6 bg-white rounded-2xl border">
  <h2 className="text-lg font-semibold mb-4">내 자산</h2>
  <div className="text-3xl font-bold">1,250,000원</div>
</div>

{/* 버튼 */}
<button className="w-full h-14 bg-primary-500 text-white rounded-xl">다음</button>
```

</toss>

---

<kakao>

**산업:** 메신저 | **키워드:** 친근함, 노란색, 말풍선

| 요소 | 내용 |
|------|------|
| **Primary** | Yellow #FEE500 (친근, 밝음) |
| **Secondary** | Brown #3C1E1E (안정감) |
| **특징** | 말풍선 모티브, 노란색 브랜드, radius 12px |

```tsx
{/* 로그인 버튼 (디자인 가이드) */}
<button className="w-full h-12 bg-[#FEE500] rounded-xl flex items-center justify-center gap-2">
  <img src="/kakao-symbol.svg" className="w-5 h-5" />
  <span className="text-[#000000]/85 text-[15px] font-medium">카카오 로그인</span>
</button>

{/* 말풍선 */}
<div className="relative p-4 bg-yellow-400 rounded-2xl rounded-tl-none">
  <div className="absolute -top-2 left-0 w-4 h-4 bg-yellow-400 rounded-br-full" />
  <p>메시지</p>
</div>
```

**규칙:** 말풍선 심볼 필수 (형태/비율/색상 변경 불가), radius 12px, 폰트 15pt

</kakao>

---

<baemin>

**산업:** 음식 배달 | **키워드:** 감성, 손글씨, 일러스트

| 요소 | 내용 |
|------|------|
| **Primary** | Teal #2AC1BC (신선, 활기) |
| **Secondary** | Coral/Pink (따뜻함) |
| **폰트** | 배민 주아체, 도현체, 연성체, 기랑해랑체, 글림체, WORK (앱 전용, 2025) |
| **특징** | 손글씨, 다채로운 일러스트, 유쾌한 톤 |

```tsx
{/* 음식점 카드 */}
<div className="rounded-2xl overflow-hidden bg-white border">
  <img className="w-full aspect-[4/3] object-cover" src="/food.jpg" />
  <div className="p-4">
    <h3 className="font-bold text-base">식당 이름</h3>
    <div className="flex items-center gap-1 text-sm text-gray-600">
      <span>⭐ 4.8</span><span>•</span><span>리뷰 1,234</span>
    </div>
    <div className="flex items-center justify-between mt-2">
      <span className="text-sm text-gray-600">배달 30분</span>
      <span className="text-sm font-semibold text-primary-500">최소 15,000원</span>
    </div>
  </div>
</div>

{/* 빈 상태 */}
<div className="flex flex-col items-center py-12 gap-4">
  <img src="/empty-illustration.svg" className="w-32 h-32" />
  <h3 className="font-bold text-lg">주문 내역이 없어요</h3>
  <p className="text-sm text-gray-600">배민에서 맛있는 음식을 주문해보세요!</p>
</div>
```

</baemin>

---

<flex>

**산업:** 기업 금융 | **키워드:** 프로페셔널, 효율성, B2B

| 요소 | 내용 |
|------|------|
| **Primary** | Purple #8B5CF6 (프로페셔널) |
| **Secondary** | Gray #6B7280 (차분, 신뢰) |
| **특징** | 정보 밀도 높은 대시보드, 데이터 시각화, 효율적 워크플로우 |

```tsx
{/* 통계 카드 그리드 */}
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
  <div className="p-6 bg-white rounded-xl border">
    <div className="text-sm text-gray-600">라벨</div>
    <div className="text-2xl font-bold text-gray-900">값</div>
    <div className="text-xs text-green-600 mt-1">↑ +12%</div>
  </div>
</div>

{/* 테이블 */}
<table className="w-full">
  <thead className="bg-gray-50 border-b">
    <tr>
      <th className="px-6 py-3 text-left text-xs font-medium text-gray-600">항목</th>
    </tr>
  </thead>
</table>
```

</flex>

---

<karrot>

**산업:** 중고거래 | **키워드:** 동네, 따뜻함, 신뢰

| 요소 | 내용 |
|------|------|
| **Primary** | Orange #FF6F0F (당근색, 따뜻함, 친근) |
| **특징** | 지역 기반 UI, 당근 모티브, 신뢰 중심 거래 |

```tsx
{/* 상품 카드 */}
<div className="flex gap-3 p-4 border-b">
  <img className="w-24 h-24 rounded-lg object-cover" src="/product.jpg" />
  <div className="flex-1 min-w-0">
    <h3 className="font-semibold truncate">상품 이름</h3>
    <div className="text-sm text-gray-600 truncate">우리동네 • 1시간 전</div>
    <div className="text-base font-bold">15,000원</div>
  </div>
  <div className="flex items-end">
    <div className="flex items-center gap-1 text-sm text-gray-500">
      <svg className="w-4 h-4" /><span>3</span>
    </div>
  </div>
</div>

{/* 동네 선택 */}
<button className="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-gray-100">
  <svg className="w-5 h-5 text-gray-700" />
  <span className="font-semibold">우리동네</span>
  <svg className="w-4 h-4 text-gray-400" />
</button>
```

</karrot>

---

<common_patterns>

| 패턴 | 적용 |
|------|------|
| **모바일 우선** | 모바일 앱 우선 설계 |
| **카드 기반** | 정보를 카드로 그룹화 |
| **큰 터치 타겟** | 최소 44-48px |
| **명확한 CTA** | 주요 액션 명확 |

```tsx
{/* 모바일 우선 + 반응형 */}
<div className="px-4 md:px-6 lg:px-8 max-w-7xl mx-auto" />

{/* 카드 */}
<div className="p-4 md:p-6 bg-white rounded-xl md:rounded-2xl border" />

{/* CTA */}
<button className="w-full h-14 bg-primary-500 text-white rounded-xl">주요 액션</button>
```

</common_patterns>

---

<sources>

- [토스 디자인 시스템 가이드](https://toss.tech/article/toss-design-system-guide)
- [토스 TDS 개발자센터](https://developers-apps-in-toss.toss.im/design/components.html)
- [카카오 로그인 디자인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide)
- [배민 디자인 스토리](https://story.baemin.com/)
- [우아한형제들 기술블로그](https://techblog.woowahan.com/6305/)

</sources>
