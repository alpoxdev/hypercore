# 한국형 앱 UI/UX 디자인

<context>

**Purpose:** 한국 사용자 대상 앱/웹 UI/UX 디자인 구현. shadcn/ui 기본 스타일 대신 토스/카카오/배민/플렉스 등 국내 앱 스타일 적용.

**Trigger:** 프론트엔드 UI/UX 구현, React/Vue 컴포넌트 디자인, 반응형 웹/앱 개발, 한국 사용자 대상 서비스

**Key Features:**
- 정보 밀도와 가독성 균형
- 절제된 미니멀리즘
- 대화하는 듯한 UX 라이팅
- WCAG AA 접근성 기준

</context>

---

<core_principles>

## 디자인 철학

| 원칙 | 적용 |
|------|------|
| **정보 밀도** | 한 화면에 핵심만, 상세는 펼침/모달 |
| **미니멀리즘** | 불필요한 장식 제거, 미세한 보더로 구분 |
| **부드러운 곡선** | border-radius 8-16px |
| **UX 라이팅** | "입력하세요" → "어떤 이름으로 불러드릴까요?" |

**상세:** [references/design-philosophy.md](references/design-philosophy.md)

</core_principles>

---

<layout_patterns>

## 레이아웃

### 컨테이너 너비

```tsx
{/* 대시보드 - 1200px */}
<div className="max-w-7xl mx-auto px-4 md:px-6 lg:px-8">

{/* 콘텐츠 - 800px */}
<div className="max-w-3xl mx-auto px-4 md:px-6">

{/* 폼/설정 - 480px */}
<div className="max-w-md mx-auto px-4">
```

### 여백

```tsx
{/* 섹션 간 */}
<div className="space-y-8 md:space-y-12">

{/* 카드 내부 */}
<div className="p-4 md:p-6">
```

</layout_patterns>

---

<component_patterns>

## 컴포넌트

### 버튼

```tsx
{/* Primary */}
<button className="h-11 px-4 rounded-lg bg-blue-500 hover:bg-blue-600 text-white font-medium transition-colors">
  저장하기
</button>

{/* Secondary */}
<button className="h-11 px-4 rounded-lg border border-gray-300 hover:bg-gray-50 font-medium transition-colors">
  취소
</button>

{/* Ghost */}
<button className="h-11 px-4 rounded-lg hover:bg-gray-100 font-medium transition-colors">
  더보기
</button>
```

**크기:** Small h-8 px-3 | Medium h-11 px-4 | Large h-12 px-5

### 카드

```tsx
<div className="p-4 md:p-6 border border-gray-200 rounded-xl bg-white">
  {/* 헤더 */}
  <div className="flex items-center justify-between mb-4">
    <h3 className="text-lg font-semibold">제목</h3>
    <button className="text-gray-500">•••</button>
  </div>

  {/* 바디 */}
  <div className="space-y-3">
    <p className="text-sm text-gray-700 leading-relaxed">콘텐츠</p>
  </div>

  {/* 푸터 */}
  <div className="flex items-center justify-between mt-4 pt-4 border-t">
    <span className="text-sm text-gray-500">2시간 전</span>
    <button className="text-sm text-blue-500 font-medium">자세히</button>
  </div>
</div>
```

### 리스트 아이템

```tsx
<div className="flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors cursor-pointer">
  {/* 좌측: 썸네일 */}
  <div className="w-12 h-12 rounded-lg bg-gray-100 flex-shrink-0" />

  {/* 중앙: 제목+설명 */}
  <div className="flex-1 min-w-0">
    <div className="font-semibold text-sm truncate">제목</div>
    <div className="text-[13px] text-gray-600 truncate">설명</div>
  </div>

  {/* 우측: 숫자/상태 */}
  <div className="flex items-center gap-2 flex-shrink-0">
    <span className="text-sm font-semibold">15,000원</span>
    <svg className="w-5 h-5 text-gray-400" />
  </div>
</div>
```

### 입력 필드

```tsx
<div className="space-y-2">
  <label className="text-sm font-medium text-gray-900">
    이메일 <span className="text-red-500">*</span>
  </label>
  <input
    type="email"
    className="w-full h-11 px-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-shadow"
    placeholder="example@email.com"
  />
</div>
```

### 모달

```tsx
<div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
  <div className="bg-white rounded-2xl max-w-md w-full max-h-[90vh] overflow-auto">
    <div className="flex items-center justify-between p-6 border-b">
      <h2 className="text-xl font-semibold">모달 제목</h2>
      <button className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-gray-100">✕</button>
    </div>
    <div className="p-6"><p className="text-sm text-gray-700 leading-relaxed">내용</p></div>
    <div className="flex gap-2 justify-end p-6 border-t">
      <button className="h-11 px-4 rounded-lg border">취소</button>
      <button className="h-11 px-4 rounded-lg bg-blue-500 text-white">확인</button>
    </div>
  </div>
</div>
```

### 탭

```tsx
{/* 밑줄 스타일 */}
<div className="border-b border-gray-200">
  <div className="flex gap-8">
    <button className="py-3 text-sm font-medium text-blue-500 border-b-2 border-blue-500">전체</button>
    <button className="py-3 text-sm font-medium text-gray-600 hover:text-gray-900">진행중</button>
  </div>
</div>

{/* 세그먼트 */}
<div className="inline-flex p-1 bg-gray-100 rounded-lg gap-1">
  <button className="px-4 py-2 rounded-md bg-white shadow-sm text-sm font-medium">전체</button>
  <button className="px-4 py-2 rounded-md text-sm font-medium text-gray-600">진행중</button>
</div>
```

</component_patterns>

---

<color_system>

## 색상 시스템

| 색상 | 용도 | 비율 |
|------|------|------|
| **Primary** | 버튼, 링크, 활성 상태 | 10% |
| **Secondary** | 필터, 칩, 보조 버튼 | 30% |
| **Background** | 배경 | 60% |
| **Semantic** | Success/Error/Warning/Info | 필요시 |

```tsx
{/* 60-30-10 규칙 적용 */}
<button className="bg-primary-500 hover:bg-primary-600 text-white">주요 액션</button>
<button className="bg-secondary-200 text-secondary-900">보조 액션</button>
```

**WCAG AA:** 일반 텍스트 4.5:1 | 큰 텍스트 3:1

**상세:** [references/color-system.md](references/color-system.md)

</color_system>

---

<icon_system>

## 아이콘

| 크기 | 용도 | 터치 영역 |
|------|------|----------|
| 16px, 20px | 텍스트와 함께 | - |
| 24px | 기본 시스템 아이콘 | 44-48px |
| 32-48px | 강조 | 그대로 |

```tsx
{/* 충분한 터치 타겟 */}
<button className="w-12 h-12 flex items-center justify-center rounded-lg">
  <svg className="w-6 h-6" />
</button>

{/* 비활성: Outline | 활성: Filled */}
<svg className="w-6 h-6 stroke-current text-gray-600" fill="none" />
<svg className="w-6 h-6 fill-current text-primary-500" />
```

**상세:** [references/icon-guide.md](references/icon-guide.md)

</icon_system>

---

<typography>

## 타이포그래피

```tsx
{/* 페이지 제목 */}
<h1 className="text-3xl font-bold tracking-tight leading-tight">대시보드</h1>

{/* 섹션 제목 */}
<h2 className="text-xl font-semibold tracking-tight">최근 활동</h2>

{/* 본문 */}
<p className="text-sm font-normal leading-relaxed text-gray-700">본문</p>

{/* 부가 정보 */}
<span className="text-[13px] text-gray-500">2시간 전</span>
```

**상세:** [references/typography.md](references/typography.md)

</typography>

---

<responsive_patterns>

## 반응형

### 그리드

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

### 네비게이션

```tsx
{/* 데스크톱: 사이드바 */}
<aside className="hidden lg:block w-60" />

{/* 모바일: 하단 탭바 */}
<nav className="lg:hidden fixed bottom-0 w-full h-14 border-t bg-white" />
```

**상세:** [references/responsive-patterns.md](references/responsive-patterns.md)

</responsive_patterns>

---

<service_patterns>

## 주요 서비스 패턴

| 서비스 | 색상 | 특징 |
|--------|------|------|
| **토스** | Blue #3182F6 | 신뢰감, 카드 중심, "어떤 이름으로 불러드릴까요?" |
| **카카오** | Yellow #FEE500 | 친근함, 말풍선 모티브, radius 12px |
| **배민** | Teal #2AC1BC | 감성, 손글씨, 일러스트 |

**상세:** [references/service-patterns.md](references/service-patterns.md)

</service_patterns>

---

<accessibility_and_states>

## 접근성 & 상태

### 접근성 필수

- 명암 대비 4.5:1 (WCAG AA)
- 키보드 네비게이션
- 색상만으로 정보 전달 금지
- 스크린 리더 호환

### 상태 패턴

```tsx
{/* 로딩 */}
<div className="animate-pulse space-y-3">
  <div className="h-4 bg-gray-200 rounded w-3/4" />
</div>

{/* 에러 */}
<div className="text-red-600 flex items-center gap-2">
  <svg className="w-5 h-5" />
  <span>오류가 발생했습니다</span>
</div>

{/* 빈 상태 */}
<div className="py-12 text-center">
  <div className="w-20 h-20 mx-auto mb-4 rounded-full bg-gray-100 flex items-center justify-center">
    <svg className="w-10 h-10 text-gray-400" />
  </div>
  <h3 className="font-semibold mb-1">아직 내용이 없어요</h3>
  <p className="text-sm text-gray-600">첫 번째 항목을 추가해보세요</p>
</div>
```

**상세:**
- [references/accessibility.md](references/accessibility.md)
- [references/micro-interactions.md](references/micro-interactions.md)
- [references/state-patterns.md](references/state-patterns.md)

</accessibility_and_states>

---

<references>

## 상세 문서

| 문서 | 내용 |
|------|------|
| [design-philosophy.md](references/design-philosophy.md) | 디자인 철학, 피해야 할 것 |
| [color-system.md](references/color-system.md) | Primary/Secondary/Semantic, WCAG, 서비스별 색상 |
| [icon-guide.md](references/icon-guide.md) | 크기, 터치 타겟, 스타일, 접근성 |
| [typography.md](references/typography.md) | 폰트, 크기, 웨이트, 한글 특징 |
| [service-patterns.md](references/service-patterns.md) | 토스/카카오/배민/플렉스/당근 분석 |
| [responsive-patterns.md](references/responsive-patterns.md) | 브레이크포인트, 그리드, 네비게이션 변환 |
| [accessibility.md](references/accessibility.md) | WCAG/KWCAG, 명암 대비, ARIA |
| [micro-interactions.md](references/micro-interactions.md) | 버튼/인풋/카드 인터랙션, 애니메이션 |
| [state-patterns.md](references/state-patterns.md) | 로딩/에러/빈 상태/성공 패턴 |
| [checklist.md](references/checklist.md) | 화면별 체크리스트 |

</references>

---

<prompt_examples>

## 프롬프트 예시

### 대시보드

```
대시보드 페이지 만들어줘.

레이아웃:
- 데스크톱: 좌측 사이드바(240px) + 메인(max-w-7xl)
- 모바일: 하단 탭바로 전환
- 반응형 패딩 (px-4 md:px-6 lg:px-8)

구성:
- 상단 인사말 + 날짜
- 통계 카드 4개 (grid-cols-1 md:grid-cols-2 lg:grid-cols-4)
- 최근 활동 리스트
- 빠른 액션 버튼

스타일:
- 한국형 SaaS (토스/플렉스)
- 카드: border + rounded-xl, 그림자 최소
- 숫자: font-bold + text-2xl
```

### 설정 화면

```
설정 페이지 만들어줘.

레이아웃:
- max-w-md mx-auto
- 섹션별 space-y-8

구성:
- 프로필: 아바타 + 이름 + 이메일
- 알림: 토글 스위치 (h-11 터치 영역)
- 계정: 비밀번호 변경, 로그아웃
- 위험: 계정 삭제 (빨간색)

스타일:
- 각 항목: flex justify-between items-center
- 레이블: text-sm font-medium
- 섹션 제목: text-xs text-gray-500 uppercase
```

### 리스트 화면

```
사용자 목록 만들어줘.

레이아웃:
- 데스크톱: 테이블
- 모바일: 카드 리스트

구성:
- 상단: 검색바 + 필터 + 추가 버튼
- 테이블: 이름, 이메일, 가입일, 상태
- 페이지네이션

스타일:
- 헤더: bg-gray-50
- 행 호버: hover:bg-gray-50
- 세로 구분선 없음
- 액션: 더보기 메뉴
```

</prompt_examples>
