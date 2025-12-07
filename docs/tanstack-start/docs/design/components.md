# 컴포넌트 가이드라인

## 버튼 (Button)

### 계층

| 유형 | 용도 | 스타일 |
|------|------|--------|
| Primary | 주된 행동 | `bg-blue-600 text-white` |
| Secondary | 대안적 행동 | `border border-gray-300` |
| Tertiary | 덜 중요한 행동 | `text-blue-600` |
| Destructive | 위험한 행동 | `bg-red-600 text-white` |

```tsx
// Primary
<button className="px-4 py-2 bg-blue-600 text-white rounded-lg
                   hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed">
  저장하기
</button>

// Secondary
<button className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
  취소
</button>

// 로딩 상태
<button disabled={isLoading} className="flex items-center gap-2">
  {isLoading && <Spinner className="w-4 h-4 animate-spin" />}
  {isLoading ? '저장 중...' : '저장하기'}
</button>
```

### 크기
```tsx
<button className="px-3 py-1.5 text-sm">Small</button>
<button className="px-4 py-2 text-base">Medium</button>
<button className="px-6 py-3 text-lg">Large</button>
```

## 입력 필드 (Input)

```tsx
<div>
  <label className="block text-sm font-medium text-gray-700 mb-1">이메일</label>
  <input
    type="email"
    className="w-full px-3 py-2 border border-gray-300 rounded-lg
               focus:ring-2 focus:ring-blue-500 focus:border-blue-500
               placeholder:text-gray-400"
    placeholder="example@email.com"
  />
  <p className="mt-1 text-sm text-gray-500">도움말</p>
</div>

// 에러 상태
<input className="border border-red-500 focus:ring-red-500" />
<p className="mt-1 text-sm text-red-600">오류 메시지</p>
```

### 아이콘 포함
```tsx
<div className="relative">
  <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
  <input className="pl-10 pr-3 py-2 ..." />
</div>
```

## 카드 (Card)

```tsx
<div className="bg-white dark:bg-gray-800 rounded-lg border shadow-sm overflow-hidden">
  <div className="px-6 py-4 border-b">
    <h3 className="text-lg font-semibold">제목</h3>
  </div>
  <div className="px-6 py-4">본문</div>
  <div className="px-6 py-4 bg-gray-50">푸터</div>
</div>
```

## 모달 (Modal)

```tsx
<div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
  <div className="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
    <div className="px-6 py-4 border-b flex items-center justify-between">
      <h2 className="text-lg font-semibold">제목</h2>
      <button><XIcon /></button>
    </div>
    <div className="px-6 py-4">본문</div>
    <div className="px-6 py-4 bg-gray-50 flex justify-end gap-3">
      <button>취소</button>
      <button className="bg-blue-600 text-white">확인</button>
    </div>
  </div>
</div>
```

### 크기
```tsx
max-w-sm   // 간단한 확인
max-w-md   // 기본 (폼)
max-w-lg   // 복잡한 내용
max-w-2xl  // 테이블, 대시보드
```

## 알림/토스트 (Alert)

```tsx
// 정보
<div className="p-4 bg-blue-50 border border-blue-200 rounded-lg flex gap-3">
  <InfoIcon className="w-5 h-5 text-blue-600" />
  <p className="text-blue-800">안내 메시지</p>
</div>

// 성공: bg-green-50, border-green-200, text-green-800
// 경고: bg-yellow-50, border-yellow-200, text-yellow-800
// 오류: bg-red-50, border-red-200, text-red-800
```

## 배지 (Badge)

```tsx
<span className="px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-800">
  활성
</span>

// 숫자 배지
<div className="relative">
  <BellIcon />
  <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-xs
                   rounded-full flex items-center justify-center">3</span>
</div>
```

## 테이블 (Table)

```tsx
<table className="w-full">
  <thead className="bg-gray-50">
    <tr>
      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
        이름
      </th>
    </tr>
  </thead>
  <tbody className="divide-y divide-gray-200">
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4 whitespace-nowrap">홍길동</td>
    </tr>
  </tbody>
</table>
```

## 조합 원칙

```tsx
// ✅ Primary 하나만
<div className="flex gap-2">
  <button className="border">취소</button>
  <button className="bg-blue-600 text-white">저장</button>
</div>

// ❌ Primary 여러 개
<div className="flex gap-2">
  <button className="bg-blue-600">취소</button>
  <button className="bg-green-600">저장</button>
</div>
```

## 체크리스트

- [ ] 버튼 계층 구분 (Primary 화면당 1개)
- [ ] 입력 필드에 레이블 필수
- [ ] 에러/로딩 상태 시각적 표시
- [ ] 포커스 스타일 명확히
