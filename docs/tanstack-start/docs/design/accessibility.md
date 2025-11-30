# 접근성 (Accessibility)

> **상위 문서**: [UI/UX 디자인 가이드](./index.md)

접근성(A11y)은 장애가 있는 사용자도 웹사이트를 사용할 수 있게 만드는 것입니다. 이는 윤리적 의무이자 법적 요구사항이기도 합니다.

## 왜 접근성이 중요한가?

### 접근성이 필요한 사용자

| 유형 | 예시 | 필요한 지원 |
|------|------|------------|
| **시각 장애** | 전맹, 저시력, 색맹 | 스크린 리더, 고대비, 큰 텍스트 |
| **청각 장애** | 난청, 전농 | 자막, 시각적 알림 |
| **운동 장애** | 손떨림, 마비 | 키보드 네비게이션, 큰 클릭 영역 |
| **인지 장애** | 읽기 장애, 집중력 장애 | 단순한 언어, 명확한 구조 |

### 접근성의 이점

- 법적 준수 (ADA, 장애인차별금지법)
- 더 넓은 사용자층
- SEO 개선 (검색 엔진도 접근성 기준 활용)
- 전반적인 UX 향상 (모든 사용자에게 도움)

## WCAG 기준

WCAG(Web Content Accessibility Guidelines)는 웹 접근성의 국제 표준입니다.

### 준수 수준

```
Level A   - 최소 기준 (필수)
Level AA  - 권장 기준 (일반적 목표)
Level AAA - 최고 기준 (특수한 경우)
```

### 4가지 원칙 (POUR)

```
P - Perceivable   (인식 가능)  모든 정보를 인식할 수 있어야 함
O - Operable      (조작 가능)  모든 기능을 조작할 수 있어야 함
U - Understandable (이해 가능)  내용을 이해할 수 있어야 함
R - Robust        (견고함)     다양한 기술에서 동작해야 함
```

## 색상 접근성

### 색상 대비 요구사항

| 텍스트 유형 | 최소 대비 (AA) | 권장 대비 (AAA) |
|------------|---------------|----------------|
| 일반 텍스트 (< 18px) | 4.5:1 | 7:1 |
| 큰 텍스트 (≥ 18px bold, ≥ 24px) | 3:1 | 4.5:1 |
| UI 컴포넌트, 그래픽 | 3:1 | - |

### 안전한 색상 조합

```tsx
// ✅ 좋은 대비
<p className="text-gray-900 bg-white">검정 on 흰색 (21:1)</p>
<p className="text-white bg-blue-700">흰색 on 진한 파랑 (8.6:1)</p>
<p className="text-gray-700 bg-gray-100">진한 회색 on 밝은 회색 (5.4:1)</p>

// ❌ 나쁜 대비
<p className="text-gray-400 bg-white">밝은 회색 on 흰색 (2.7:1)</p>
<p className="text-yellow-500 bg-white">노란색 on 흰색 (1.3:1)</p>
```

### 색상만으로 정보 전달 금지

```tsx
// ❌ 나쁜 예 - 색상만으로 구분
<span className="text-red-600">오류</span>
<span className="text-green-600">성공</span>

// ✅ 좋은 예 - 아이콘/텍스트 병행
<span className="text-red-600 flex items-center gap-1">
  <XCircleIcon className="w-4 h-4" />
  오류가 발생했습니다
</span>
<span className="text-green-600 flex items-center gap-1">
  <CheckCircleIcon className="w-4 h-4" />
  성공적으로 저장됨
</span>
```

## 키보드 접근성

### 모든 기능은 키보드로 가능해야 함

```
Tab       다음 요소로 이동
Shift+Tab 이전 요소로 이동
Enter     버튼 클릭, 링크 이동
Space     체크박스 토글, 버튼 클릭
Escape    모달 닫기, 취소
Arrow     드롭다운, 슬라이더 조작
```

### 포커스 표시

```tsx
// ✅ 명확한 포커스 스타일
<button className="focus:outline-none focus:ring-2 focus:ring-blue-500
                   focus:ring-offset-2">
  버튼
</button>

// 입력 필드
<input className="focus:outline-none focus:ring-2 focus:ring-blue-500
                  focus:border-blue-500" />

// ❌ 포커스 제거 금지
<button className="outline-none focus:outline-none">
  {/* 접근성 위반! */}
</button>
```

### 포커스 순서

```tsx
// 논리적인 탭 순서 유지
<form>
  <input tabIndex={0} /> {/* 1번째 */}
  <input tabIndex={0} /> {/* 2번째 */}
  <button tabIndex={0}>취소</button> {/* 3번째 */}
  <button tabIndex={0}>저장</button> {/* 4번째 */}
</form>

// ❌ tabIndex로 순서 강제 변경 피하기
<button tabIndex={2}>저장</button>
<button tabIndex={1}>취소</button>
```

### 포커스 트랩 (모달)

```tsx
// 모달이 열리면 포커스가 모달 안에만 머물러야 함
const Modal = ({ isOpen, onClose }) => {
  const modalRef = useRef(null)

  useEffect(() => {
    if (isOpen) {
      // 모달 열릴 때 첫 번째 요소에 포커스
      modalRef.current?.querySelector('button')?.focus()
    }
  }, [isOpen])

  const handleKeyDown = (e) => {
    if (e.key === 'Escape') onClose()
  }

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      onKeyDown={handleKeyDown}
    >
      {/* 모달 내용 */}
    </div>
  )
}
```

## 시맨틱 HTML

### 올바른 HTML 요소 사용

```tsx
// ✅ 시맨틱 HTML
<header>...</header>
<nav>...</nav>
<main>
  <article>
    <h1>제목</h1>
    <section>...</section>
  </article>
</main>
<footer>...</footer>

// ❌ div 남용
<div className="header">...</div>
<div className="nav">...</div>
<div className="main">...</div>
```

### 제목 계층

```tsx
// ✅ 올바른 제목 순서
<h1>페이지 제목</h1>
  <h2>섹션 1</h2>
    <h3>하위 섹션 1-1</h3>
  <h2>섹션 2</h2>

// ❌ 제목 레벨 건너뛰기
<h1>페이지 제목</h1>
  <h3>섹션</h3>  {/* h2를 건너뜀 */}
```

### 버튼 vs 링크

```tsx
// 버튼: 동작 수행
<button onClick={handleSave}>저장</button>

// 링크: 페이지 이동
<a href="/about">소개 페이지</a>

// ❌ 잘못된 사용
<div onClick={handleSave}>저장</div>  {/* div를 버튼처럼 */}
<a onClick={handleAction}>클릭</a>    {/* 링크를 버튼처럼 */}
```

## ARIA 속성

### 필수 ARIA 사용

```tsx
// 레이블 연결
<label htmlFor="email">이메일</label>
<input id="email" type="email" />

// 또는 aria-label 사용
<input aria-label="검색어 입력" type="search" />

// 설명 연결
<input aria-describedby="email-hint" />
<p id="email-hint">업무용 이메일을 입력하세요</p>

// 에러 상태
<input aria-invalid="true" aria-describedby="email-error" />
<p id="email-error" role="alert">올바른 이메일을 입력하세요</p>
```

### 상태 알림

```tsx
// 동적 콘텐츠 변경 알림
<div aria-live="polite">
  {/* 변경되면 스크린 리더가 읽어줌 */}
  {message}
</div>

// 긴급 알림
<div aria-live="assertive" role="alert">
  {errorMessage}
</div>
```

### 숨김 처리

```tsx
// 시각적으로만 숨김 (스크린 리더는 읽음)
<span className="sr-only">메뉴 열기</span>

// Tailwind의 sr-only 클래스
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  border: 0;
}

// 스크린 리더에서도 숨김
<div aria-hidden="true">장식용 아이콘</div>
```

## 폼 접근성

### 레이블 필수

```tsx
// ✅ 명시적 레이블
<label htmlFor="name">이름</label>
<input id="name" type="text" />

// ✅ 암묵적 레이블
<label>
  이름
  <input type="text" />
</label>

// ✅ aria-label (시각적 레이블 없을 때)
<input type="search" aria-label="사이트 검색" />
```

### 에러 처리

```tsx
<div>
  <label htmlFor="email">이메일</label>
  <input
    id="email"
    type="email"
    aria-invalid={hasError}
    aria-describedby={hasError ? "email-error" : undefined}
    className={hasError ? "border-red-500" : "border-gray-300"}
  />
  {hasError && (
    <p id="email-error" className="text-red-600 text-sm mt-1" role="alert">
      올바른 이메일 형식을 입력하세요
    </p>
  )}
</div>
```

### 필수 필드 표시

```tsx
<label htmlFor="email">
  이메일 <span className="text-red-600" aria-hidden="true">*</span>
  <span className="sr-only">(필수)</span>
</label>
<input id="email" required aria-required="true" />
```

## 이미지 접근성

### 대체 텍스트 (alt)

```tsx
// 정보 전달 이미지 - 설명 필요
<img src="chart.png" alt="2024년 매출 추이: 1월 100만원에서 12월 500만원으로 성장" />

// 장식용 이미지 - 빈 alt
<img src="decorative.png" alt="" />

// 아이콘 버튼 - 기능 설명
<button aria-label="닫기">
  <img src="close.svg" alt="" />
</button>
```

## 터치 접근성

### 최소 터치 영역

```tsx
// 최소 44x44px 터치 영역
<button className="min-w-[44px] min-h-[44px] p-2">
  <Icon className="w-6 h-6" />
</button>

// 작은 체크박스도 터치 영역 확보
<label className="flex items-center gap-2 p-2 -m-2 cursor-pointer">
  <input type="checkbox" className="w-4 h-4" />
  <span>동의합니다</span>
</label>
```

### 터치 타겟 간격

```tsx
// 터치 타겟 사이 최소 8px 간격
<div className="flex gap-2">
  <button className="p-3">버튼 1</button>
  <button className="p-3">버튼 2</button>
</div>
```

## 접근성 테스트

### 자동화 도구

| 도구 | 용도 |
|------|------|
| **axe DevTools** | 브라우저 확장, 자동 검사 |
| **Lighthouse** | Chrome 내장, 접근성 점수 |
| **WAVE** | 시각적 피드백 |
| **eslint-plugin-jsx-a11y** | 코드 레벨 검사 |

### 수동 테스트

```
1. 키보드만으로 모든 기능 사용 가능한가?
2. Tab 순서가 논리적인가?
3. 포커스 표시가 명확한가?
4. 스크린 리더로 내용을 이해할 수 있는가?
5. 200% 확대해도 사용 가능한가?
```

### ESLint 설정

```bash
yarn add -D eslint-plugin-jsx-a11y
```

```js
// eslint.config.js
import jsxA11y from 'eslint-plugin-jsx-a11y'

export default [
  {
    plugins: { 'jsx-a11y': jsxA11y },
    rules: {
      'jsx-a11y/alt-text': 'error',
      'jsx-a11y/anchor-has-content': 'error',
      'jsx-a11y/click-events-have-key-events': 'error',
      'jsx-a11y/no-noninteractive-element-interactions': 'error',
    },
  },
]
```

## 체크리스트

### 필수 (Level A)

- [ ] 모든 이미지에 alt 텍스트
- [ ] 모든 폼 요소에 레이블
- [ ] 키보드로 모든 기능 접근 가능
- [ ] 포커스 표시 유지
- [ ] 색상만으로 정보 전달하지 않음

### 권장 (Level AA)

- [ ] 텍스트 대비 4.5:1 이상
- [ ] 페이지 제목 명확
- [ ] 제목 계층 논리적
- [ ] 에러 메시지 명확
- [ ] 200% 확대 시 가로 스크롤 없음

### 최고 수준 (Level AAA)

- [ ] 텍스트 대비 7:1 이상
- [ ] 읽기 수준 고려
- [ ] 약어 설명 제공
