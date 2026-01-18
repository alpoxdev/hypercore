# 상태 패턴

<empty>

```tsx
{/* 기본 빈 상태 */}
<div className="flex flex-col items-center py-12 gap-4">
  <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center">
    <svg className="w-10 h-10 text-gray-400" />
  </div>
  <div className="text-center">
    <h3 className="font-semibold text-gray-900">아직 내용이 없어요</h3>
    <p className="text-sm text-gray-600 mt-1">첫 번째 항목을 추가해보세요</p>
  </div>
  <button className="h-11 px-4 bg-primary-500 text-white rounded-lg">추가하기</button>
</div>

{/* 검색 결과 없음 */}
<div className="flex flex-col items-center py-12 gap-3">
  <svg className="w-16 h-16 text-gray-300" />
  <h3 className="font-semibold">검색 결과가 없어요</h3>
  <p className="text-sm text-gray-600">다른 검색어로 시도해보세요</p>
</div>

{/* 필터 결과 없음 */}
<div className="flex flex-col items-center py-12 gap-3">
  <svg className="w-16 h-16 text-gray-300" />
  <h3 className="font-semibold">조건에 맞는 항목이 없어요</h3>
  <p className="text-sm text-gray-600">필터를 조정해보세요</p>
  <button onClick={resetFilters} className="text-sm text-primary-500 font-medium">
    필터 초기화
  </button>
</div>
```

</empty>

---

<loading>

```tsx
{/* 스켈레톤 UI */}
<div className="space-y-4 animate-pulse">
  {[1, 2, 3].map(i => (
    <div key={i} className="p-4 border rounded-xl">
      <div className="flex gap-3">
        <div className="w-12 h-12 bg-gray-200 rounded-lg" />
        <div className="flex-1 space-y-2">
          <div className="h-4 bg-gray-200 rounded w-3/4" />
          <div className="h-4 bg-gray-200 rounded w-1/2" />
        </div>
      </div>
    </div>
  ))}
</div>

{/* 버튼 로딩 */}
<button disabled className="h-11 px-4 bg-primary-500 text-white rounded-lg flex items-center gap-2 opacity-70">
  <svg className="w-5 h-5 animate-spin" />처리 중...
</button>

{/* 인라인 스피너 */}
<div className="flex items-center gap-2 text-sm text-gray-600">
  <svg className="w-4 h-4 animate-spin" />
  <span>불러오는 중...</span>
</div>

{/* 풀페이지 로딩 */}
<div className="fixed inset-0 bg-white z-50 flex flex-col items-center justify-center gap-4">
  <img src="/logo.svg" className="w-16 h-16" />
  <svg className="w-8 h-8 animate-spin text-primary-500" />
  <p className="text-sm text-gray-600">잠시만 기다려주세요</p>
</div>
```

</loading>

---

<success>

```tsx
{/* 토스트 (하단) */}
<div className="fixed bottom-4 left-1/2 -translate-x-1/2 z-50">
  <div className="bg-gray-900 text-white px-4 py-3 rounded-lg shadow-lg flex items-center gap-2">
    <svg className="w-5 h-5 text-green-400" />
    <span className="text-sm">저장되었습니다</span>
  </div>
</div>

{/* 토스트 (우측 상단) */}
<div className="fixed top-4 right-4 z-50">
  <div className="bg-white border border-green-500 px-4 py-3 rounded-lg shadow-lg flex items-center gap-3">
    <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
      <svg className="w-5 h-5 text-green-600" />
    </div>
    <div>
      <div className="font-semibold">성공</div>
      <div className="text-sm text-gray-600">작업이 완료되었습니다</div>
    </div>
    <button className="text-gray-400 hover:text-gray-600">✕</button>
  </div>
</div>

{/* 인라인 성공 */}
<div className="p-3 bg-green-50 border border-green-200 rounded-lg flex items-start gap-2">
  <svg className="w-5 h-5 text-green-600 mt-0.5" />
  <p className="text-sm text-green-800">이메일이 성공적으로 전송되었습니다</p>
</div>

{/* 성공 페이지 */}
<div className="flex flex-col items-center py-16 gap-4">
  <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center">
    <svg className="w-10 h-10 text-green-600" />
  </div>
  <div className="text-center">
    <h2 className="text-2xl font-bold mb-2">결제 완료</h2>
    <p className="text-gray-600">주문이 성공적으로 처리되었습니다</p>
  </div>
  <div className="flex gap-2 mt-4">
    <button className="h-11 px-4 border rounded-lg">주문 내역</button>
    <button className="h-11 px-4 bg-primary-500 text-white rounded-lg">계속 쇼핑하기</button>
  </div>
</div>
```

</success>

---

<error>

```tsx
{/* 인풋 에러 */}
<div>
  <input className="w-full h-11 px-3 border-2 border-red-500 rounded-lg" aria-invalid="true" />
  <p className="text-sm text-red-600 mt-1 flex items-center gap-1">
    <svg className="w-4 h-4" />올바른 이메일을 입력해주세요
  </p>
</div>

{/* 알림 박스 */}
<div className="p-3 bg-red-50 border border-red-200 rounded-lg flex items-start gap-2">
  <svg className="w-5 h-5 text-red-600 mt-0.5" />
  <div>
    <h4 className="font-semibold text-red-900 text-sm mb-1">오류가 발생했습니다</h4>
    <p className="text-sm text-red-800">네트워크 연결을 확인하고 다시 시도해주세요</p>
  </div>
</div>

{/* 에러 페이지 */}
<div className="flex flex-col items-center min-h-screen px-4 gap-4 justify-center">
  <div className="w-20 h-20 rounded-full bg-red-100 flex items-center justify-center">
    <svg className="w-10 h-10 text-red-600" />
  </div>
  <div className="text-center">
    <h2 className="text-2xl font-bold mb-2">페이지를 불러올 수 없어요</h2>
    <p className="text-gray-600">일시적인 오류가 발생했습니다</p>
  </div>
  <button onClick={() => window.location.reload()} className="h-11 px-4 bg-primary-500 text-white rounded-lg">
    새로고침
  </button>
</div>

{/* 404 페이지 */}
<div className="flex flex-col items-center min-h-screen px-4 gap-4 justify-center">
  <h1 className="text-6xl font-bold text-gray-900">404</h1>
  <h2 className="text-2xl font-semibold">페이지를 찾을 수 없어요</h2>
  <p className="text-gray-600">요청하신 페이지가 존재하지 않거나 이동했을 수 있습니다</p>
  <button onClick={() => router.push('/')} className="h-11 px-4 bg-primary-500 text-white rounded-lg">
    홈으로 가기
  </button>
</div>
```

</error>

---

<warning>

```tsx
{/* 경고 알림 */}
<div className="p-3 bg-yellow-50 border border-yellow-200 rounded-lg flex items-start gap-2">
  <svg className="w-5 h-5 text-yellow-600 mt-0.5" />
  <div>
    <h4 className="font-semibold text-yellow-900 text-sm mb-1">주의하세요</h4>
    <p className="text-sm text-yellow-800">이 작업은 되돌릴 수 없습니다</p>
  </div>
</div>

{/* 확인 모달 */}
<div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
  <div className="bg-white rounded-2xl max-w-sm w-full p-6">
    <div className="w-12 h-12 rounded-full bg-yellow-100 flex items-center justify-center mx-auto mb-4">
      <svg className="w-6 h-6 text-yellow-600" />
    </div>
    <h2 className="text-lg font-semibold text-center mb-2">정말 삭제하시겠어요?</h2>
    <p className="text-sm text-gray-600 text-center mb-6">삭제한 항목은 복구할 수 없습니다</p>
    <div className="flex gap-2">
      <button onClick={onCancel} className="flex-1 h-11 border rounded-lg">취소</button>
      <button onClick={onConfirm} className="flex-1 h-11 bg-red-500 text-white rounded-lg">삭제</button>
    </div>
  </div>
</div>
```

</warning>

---

<info>

```tsx
{/* 정보 알림 */}
<div className="p-3 bg-blue-50 border border-blue-200 rounded-lg flex items-start gap-2">
  <svg className="w-5 h-5 text-blue-600 mt-0.5" />
  <p className="text-sm text-blue-900 flex-1">새로운 기능이 추가되었습니다. 확인해보세요!</p>
  <button className="text-blue-600 hover:text-blue-800 text-sm font-medium">자세히</button>
</div>

{/* 배너 알림 */}
<div className="w-full bg-primary-50 border-b border-primary-200 py-3 px-4">
  <div className="max-w-7xl mx-auto flex items-center justify-between gap-4">
    <div className="flex items-center gap-2 flex-1">
      <svg className="w-5 h-5 text-primary-600" />
      <p className="text-sm text-primary-900">현재 시스템 점검이 예정되어 있습니다</p>
    </div>
    <button className="text-primary-600 hover:text-primary-800">✕</button>
  </div>
</div>
```

</info>

---

<disabled>

```tsx
{/* 비활성 버튼 */}
<button disabled className="h-11 px-4 bg-gray-300 text-gray-500 rounded-lg cursor-not-allowed">
  버튼
</button>

{/* 툴팁 포함 */}
<div className="relative group">
  <button disabled className="h-11 px-4 bg-gray-300 text-gray-500 rounded-lg cursor-not-allowed">
    저장하기
  </button>
  <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-2 bg-gray-900 text-white text-xs rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
    모든 필드를 입력해주세요
  </div>
</div>

{/* 비활성 카드 */}
<div className="p-4 border rounded-xl opacity-50 cursor-not-allowed">
  <div className="relative">
    <div className="absolute inset-0 bg-white/50" />
    {/* 내용 */}
  </div>
</div>
```

</disabled>

---

<offline>

```tsx
{/* 오프라인 배너 */}
<div className="fixed top-0 inset-x-0 bg-gray-900 text-white py-2 px-4 z-50">
  <div className="max-w-7xl mx-auto flex items-center justify-center gap-2">
    <svg className="w-5 h-5" />
    <span className="text-sm">인터넷 연결이 끊어졌습니다</span>
  </div>
</div>
```

</offline>

---

<progress>

```tsx
{/* 단계 표시 */}
<div className="flex items-center justify-between">
  {steps.map((step, index) => (
    <div key={step.id} className="flex items-center">
      <div className={`w-10 h-10 rounded-full flex items-center justify-center font-semibold ${
        index < currentStep
          ? 'bg-primary-500 text-white'
          : index === currentStep
          ? 'bg-primary-100 text-primary-600 border-2 border-primary-500'
          : 'bg-gray-100 text-gray-400'
      }`}>
        {index < currentStep ? '✓' : index + 1}
      </div>
      {index < steps.length - 1 && (
        <div className={`h-1 w-16 ${index < currentStep ? 'bg-primary-500' : 'bg-gray-200'}`} />
      )}
    </div>
  ))}
</div>
```

</progress>

---

<sources>

- [디자인베이스 - Empty State](https://designbase.co.kr/dictionary/emptystate/)
- [토스 - UX 라이팅](https://toss.im/career/article/ux-writing)
- [KRDS](https://www.krds.go.kr/)

</sources>
