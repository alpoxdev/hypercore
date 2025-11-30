# 컴포넌트 가이드라인

> **상위 문서**: [UI/UX 디자인 가이드](./index.md)

일관된 UI 컴포넌트 사용은 사용자 경험을 향상시키고 개발 효율성을 높입니다.

## 버튼 (Button)

### 버튼 계층

```
Primary (주요)     사용자가 해야 할 주된 행동
Secondary (보조)   대안적 행동
Tertiary (3차)     덜 중요한 행동
Destructive (삭제) 위험한/되돌릴 수 없는 행동
```

### 버튼 스타일

```tsx
// Primary - 눈에 띄는 배경색
<button className="px-4 py-2 bg-blue-600 text-white rounded-lg
                   hover:bg-blue-700 active:bg-blue-800
                   disabled:bg-gray-300 disabled:cursor-not-allowed">
  저장하기
</button>

// Secondary - 테두리만
<button className="px-4 py-2 border border-gray-300 rounded-lg
                   hover:bg-gray-50 active:bg-gray-100
                   dark:border-gray-600 dark:hover:bg-gray-800">
  취소
</button>

// Tertiary - 텍스트만
<button className="px-4 py-2 text-blue-600
                   hover:text-blue-700 hover:underline">
  더 보기
</button>

// Destructive - 빨간색
<button className="px-4 py-2 bg-red-600 text-white rounded-lg
                   hover:bg-red-700">
  삭제
</button>
```

### 버튼 크기

```tsx
// Small
<button className="px-3 py-1.5 text-sm">작은 버튼</button>

// Medium (기본)
<button className="px-4 py-2 text-base">기본 버튼</button>

// Large
<button className="px-6 py-3 text-lg">큰 버튼</button>
```

### 버튼 상태

| 상태 | 설명 | 시각적 처리 |
|------|------|------------|
| Default | 기본 상태 | 기본 색상 |
| Hover | 마우스 오버 | 약간 어둡게 |
| Active | 클릭 중 | 더 어둡게 |
| Focus | 키보드 포커스 | 아웃라인 표시 |
| Disabled | 비활성화 | 회색, 클릭 불가 |
| Loading | 로딩 중 | 스피너, 클릭 불가 |

```tsx
// 로딩 상태 버튼
<button
  disabled={isLoading}
  className="px-4 py-2 bg-blue-600 text-white rounded-lg
             disabled:opacity-50 flex items-center gap-2"
>
  {isLoading && <Spinner className="w-4 h-4 animate-spin" />}
  {isLoading ? '저장 중...' : '저장하기'}
</button>
```

## 입력 필드 (Input)

### 기본 구조

```tsx
<div>
  {/* 레이블 */}
  <label className="block text-sm font-medium text-gray-700 mb-1">
    이메일
  </label>

  {/* 입력 필드 */}
  <input
    type="email"
    className="w-full px-3 py-2 border border-gray-300 rounded-lg
               focus:ring-2 focus:ring-blue-500 focus:border-blue-500
               placeholder:text-gray-400"
    placeholder="example@email.com"
  />

  {/* 도움말/에러 메시지 */}
  <p className="mt-1 text-sm text-gray-500">
    업무용 이메일을 입력하세요.
  </p>
</div>
```

### 입력 상태

```tsx
// 기본 상태
<input className="border border-gray-300 focus:ring-2 focus:ring-blue-500" />

// 에러 상태
<input className="border border-red-500 focus:ring-2 focus:ring-red-500" />
<p className="mt-1 text-sm text-red-600">올바른 이메일을 입력하세요.</p>

// 성공 상태
<input className="border border-green-500 focus:ring-2 focus:ring-green-500" />

// 비활성화 상태
<input disabled className="border border-gray-200 bg-gray-50 cursor-not-allowed" />
```

### 입력 변형

```tsx
// 아이콘 포함 (왼쪽)
<div className="relative">
  <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
  <input className="pl-10 pr-3 py-2 ..." />
</div>

// 아이콘 포함 (오른쪽)
<div className="relative">
  <input className="pl-3 pr-10 py-2 ..." type="password" />
  <button className="absolute right-3 top-1/2 -translate-y-1/2">
    <EyeIcon className="w-5 h-5 text-gray-400" />
  </button>
</div>

// 접두사/접미사
<div className="flex">
  <span className="px-3 py-2 bg-gray-100 border border-r-0 rounded-l-lg">
    https://
  </span>
  <input className="flex-1 px-3 py-2 border rounded-r-lg" />
</div>
```

## 카드 (Card)

### 기본 카드

```tsx
<div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200
               dark:border-gray-700 shadow-sm overflow-hidden">
  {/* 카드 헤더 (선택) */}
  <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
    <h3 className="text-lg font-semibold">카드 제목</h3>
  </div>

  {/* 카드 본문 */}
  <div className="px-6 py-4">
    <p>카드 내용이 여기에 들어갑니다.</p>
  </div>

  {/* 카드 푸터 (선택) */}
  <div className="px-6 py-4 bg-gray-50 dark:bg-gray-900">
    <button>액션</button>
  </div>
</div>
```

### 카드 변형

```tsx
// 클릭 가능한 카드
<div className="... cursor-pointer hover:shadow-md transition-shadow">

// 선택된 카드
<div className="... ring-2 ring-blue-500">

// 이미지 카드
<div className="... overflow-hidden">
  <img src="..." className="w-full h-48 object-cover" />
  <div className="p-4">...</div>
</div>
```

## 모달/다이얼로그 (Modal)

### 기본 구조

```tsx
// 오버레이
<div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">

  {/* 모달 컨테이너 */}
  <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl
                  w-full max-w-md mx-4 overflow-hidden">

    {/* 헤더 */}
    <div className="px-6 py-4 border-b flex items-center justify-between">
      <h2 className="text-lg font-semibold">모달 제목</h2>
      <button className="p-1 hover:bg-gray-100 rounded">
        <XIcon className="w-5 h-5" />
      </button>
    </div>

    {/* 본문 */}
    <div className="px-6 py-4">
      <p>모달 내용</p>
    </div>

    {/* 푸터 */}
    <div className="px-6 py-4 bg-gray-50 flex justify-end gap-3">
      <button className="px-4 py-2 border rounded-lg">취소</button>
      <button className="px-4 py-2 bg-blue-600 text-white rounded-lg">
        확인
      </button>
    </div>
  </div>
</div>
```

### 모달 크기

```tsx
// Small - 간단한 확인
<div className="max-w-sm">

// Medium - 기본 (폼 등)
<div className="max-w-md">

// Large - 복잡한 내용
<div className="max-w-lg">

// Extra Large - 테이블, 대시보드
<div className="max-w-2xl">
```

## 알림/토스트 (Alert/Toast)

### 알림 유형

```tsx
// 정보 (파란색)
<div className="p-4 bg-blue-50 border border-blue-200 rounded-lg flex gap-3">
  <InfoIcon className="w-5 h-5 text-blue-600 shrink-0" />
  <p className="text-blue-800">안내 메시지입니다.</p>
</div>

// 성공 (초록색)
<div className="p-4 bg-green-50 border border-green-200 rounded-lg flex gap-3">
  <CheckIcon className="w-5 h-5 text-green-600 shrink-0" />
  <p className="text-green-800">성공적으로 저장되었습니다.</p>
</div>

// 경고 (노란색)
<div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg flex gap-3">
  <WarningIcon className="w-5 h-5 text-yellow-600 shrink-0" />
  <p className="text-yellow-800">주의가 필요합니다.</p>
</div>

// 오류 (빨간색)
<div className="p-4 bg-red-50 border border-red-200 rounded-lg flex gap-3">
  <ErrorIcon className="w-5 h-5 text-red-600 shrink-0" />
  <p className="text-red-800">오류가 발생했습니다.</p>
</div>
```

### 토스트 위치

```tsx
// 우측 하단 (기본)
<div className="fixed bottom-4 right-4 z-50">
  <div className="bg-gray-900 text-white px-4 py-3 rounded-lg shadow-lg">
    저장되었습니다
  </div>
</div>

// 상단 중앙
<div className="fixed top-4 left-1/2 -translate-x-1/2 z-50">
```

## 배지/태그 (Badge)

```tsx
// 상태 배지
<span className="px-2 py-0.5 text-xs font-medium rounded-full
               bg-green-100 text-green-800">
  활성
</span>

<span className="px-2 py-0.5 text-xs font-medium rounded-full
               bg-yellow-100 text-yellow-800">
  대기중
</span>

<span className="px-2 py-0.5 text-xs font-medium rounded-full
               bg-red-100 text-red-800">
  오류
</span>

// 숫자 배지 (알림)
<div className="relative">
  <BellIcon className="w-6 h-6" />
  <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500
                   text-white text-xs rounded-full flex items-center justify-center">
    3
  </span>
</div>
```

## 테이블 (Table)

```tsx
<div className="overflow-x-auto">
  <table className="w-full">
    {/* 헤더 */}
    <thead className="bg-gray-50 dark:bg-gray-800">
      <tr>
        <th className="px-6 py-3 text-left text-xs font-medium
                       text-gray-500 uppercase tracking-wider">
          이름
        </th>
        <th className="px-6 py-3 text-left text-xs font-medium
                       text-gray-500 uppercase tracking-wider">
          이메일
        </th>
        <th className="px-6 py-3 text-left text-xs font-medium
                       text-gray-500 uppercase tracking-wider">
          상태
        </th>
      </tr>
    </thead>

    {/* 본문 */}
    <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
      <tr className="hover:bg-gray-50 dark:hover:bg-gray-800">
        <td className="px-6 py-4 whitespace-nowrap">홍길동</td>
        <td className="px-6 py-4 whitespace-nowrap">hong@email.com</td>
        <td className="px-6 py-4 whitespace-nowrap">
          <span className="px-2 py-0.5 text-xs bg-green-100 text-green-800 rounded-full">
            활성
          </span>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

## 컴포넌트 조합 원칙

### 1. 일관된 크기 체계

```
컴포넌트 크기는 서로 어울려야 합니다:

Small 버튼  + Small 입력  + text-sm
Medium 버튼 + Medium 입력 + text-base
Large 버튼  + Large 입력  + text-lg
```

### 2. 시각적 무게 균형

```tsx
// ✅ 좋은 예 - Primary가 하나만
<div className="flex gap-2">
  <button className="border">취소</button>
  <button className="bg-blue-600 text-white">저장</button>
</div>

// ❌ 나쁜 예 - Primary가 여러 개
<div className="flex gap-2">
  <button className="bg-blue-600 text-white">취소</button>
  <button className="bg-green-600 text-white">저장</button>
</div>
```

### 3. 예측 가능한 위치

```
확인/저장 버튼: 오른쪽
취소/닫기 버튼: 왼쪽
주요 액션: 눈에 잘 띄는 위치
파괴적 액션: 분리 또는 경고 표시
```

## 체크리스트

### 반드시 지켜야 할 것

- [ ] 버튼 계층 구분 (Primary는 화면당 1개)
- [ ] 입력 필드에 레이블 필수
- [ ] 에러 상태 시각적 표시
- [ ] 로딩 상태 표시

### 권장 사항

- [ ] 일관된 컴포넌트 크기 사용
- [ ] 포커스 스타일 명확히
- [ ] 비활성화 상태 구분
- [ ] 반응형 대응
