---
name: korea-uiux-design
description: 한국 사용자 대상 앱/웹 UI/UX 디자인 구현. shadcn/ui 기본 스타일 대신 토스/카카오/배민/플렉스 등 국내 앱 스타일 적용.
user-invocable: true
ui-only: true
---

@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

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

<parallel_agent_execution>

## 한국형 UI/UX 병렬 에이전트 실행

### 핵심 원칙

| 원칙 | 한국 서비스 적용 | 기대 효과 |
|------|----------------|----------|
| **PARALLEL** | 본인인증 + 결제 + 주소입력 동시 구현 | 5-10배 속도 향상 |
| **LOCALIZED** | 날짜/통화/전화번호 형식 병렬 처리 | 지역화 품질 극대화 |
| **COMPLIANT** | 법규 검증 병렬 실행 (개인정보보호법/전자금융거래법/웹접근성) | 법적 리스크 사전 차단 |

**한국 서비스 특화 병렬 패턴:**
```typescript
// ❌ 순차 실행 (느림)
Task("본인인증 구현")  // 60초
Task("결제 구현")      // 60초
Task("주소입력 구현")  // 60초
// 총 180초

// ✅ 병렬 실행 (빠름)
Task("본인인증 구현")  // 단일 메시지에서
Task("결제 구현")      // 동시 호출
Task("주소입력 구현")  // 동시 실행
// 총 60초 (가장 긴 작업 기준)
```

---

### 한국형 UI 병렬 패턴

**패턴 1: 본인인증 + KYC 동시 구현**

```typescript
// 이커머스/핀테크 필수 컴포넌트
Task(subagent_type="designer", model="sonnet",
     prompt=`휴대폰 본인인증 컴포넌트 구현
     - NICE/KCB 인증 모듈 연동
     - 인증번호 입력 UI
     - 타이머 (3분 제한)
     - 한국형 전화번호 형식 (010-XXXX-XXXX)`)

Task(subagent_type="designer", model="sonnet",
     prompt=`신분증 인증 컴포넌트 구현
     - 주민등록증/운전면허증 촬영
     - OCR 연동 UI
     - 개인정보 마스킹 (주민등록번호 뒷자리)`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`본인인증 Server Functions
     - NICE/KCB API 연동
     - 세션 관리 (인증 상태 저장)
     - 개인정보 암호화 (AES-256)`)
```

**패턴 2: 결제 시스템 병렬 구현**

```typescript
// 한국 주요 PG사 통합
Task(subagent_type="designer", model="sonnet",
     prompt=`결제 수단 선택 UI
     - 카드/계좌이체/간편결제 (토스/카카오페이/네이버페이)
     - 할인/포인트 적용
     - 최종 금액 표시 (원화 3자리 콤마)`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`PG 연동 Server Functions
     - 토스페이먼츠/KG이니시스 API
     - 결제 승인/취소/환불
     - 전자금융거래법 준수 (거래 로그 7년 보관)`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`결제 보안 검토
     - PCI-DSS 준수
     - 카드번호 비저장 (토큰 방식)
     - 개인정보 처리방침 확인`)
```

**패턴 3: 주소/배송 병렬 구현**

```typescript
// 한국 주소 시스템
Task(subagent_type="designer", model="sonnet",
     prompt=`주소 입력 컴포넌트
     - Daum 우편번호 API 연동
     - 도로명주소 + 지번주소
     - 상세주소 입력 (필수)`)

Task(subagent_type="designer", model="sonnet",
     prompt=`배송 추적 UI
     - 택배사 연동 (CJ대한통운/우체국/로젠)
     - 실시간 위치 표시
     - 배송 상태 (배송준비/배송중/배송완료)`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`배송 Server Functions
     - Daum Postcode API
     - 택배사 API 연동
     - 배송지 변경/반품 로직`)
```

---

### 지역화 요소 병렬 처리

**패턴: 한국 형식 동시 구현**

```typescript
// 날짜/통화/전화번호/주민등록번호
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`날짜 형식 한국화
     - YYYY년 MM월 DD일 (일, 월, 화)
     - 24시간 형식 (HH:mm)
     - day.js 한국어 로케일`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`통화 형식 한국화
     - 원화 표시: 15,000원
     - 3자리 콤마 (toLocaleString)
     - 소수점 제거 (정수만)`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`전화번호 형식 한국화
     - 010-XXXX-XXXX
     - 02-XXX-XXXX (서울 지역번호)
     - 입력 시 자동 하이픈`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`주민등록번호/사업자등록번호 처리
     - 형식: XXXXXX-XXXXXXX / XXX-XX-XXXXX
     - 마스킹: XXXXXX-*******
     - 암호화 저장 (AES-256)`)
```

---

### 타이포그래피 병렬 최적화

**패턴: 한글 + 영문 폴백 동시 설정**

```typescript
// Pretendard + 영문 폴백
Task(subagent_type="designer", model="sonnet",
     prompt=`한글 타이포그래피 설정
     - 주 폰트: Pretendard (가변 폰트)
     - 크기: 14px/16px (모바일/데스크톱)
     - 행간: 1.5-1.7 (한글 최적)
     - 자간: -0.02em (밀도 조절)`)

Task(subagent_type="designer", model="sonnet",
     prompt=`영문 폴백 설정
     - Inter/SF Pro (영문 전용)
     - font-family: Pretendard, -apple-system, Roboto, sans-serif
     - 숫자: tabular-nums (정렬)`)

Task(subagent_type="designer", model="sonnet",
     prompt=`웹폰트 최적화
     - woff2 포맷
     - font-display: swap
     - subset: 한글 2,350자 + 영문/숫자`)
```

---

### 법규 준수 병렬 검증

**패턴: 개인정보보호법 + 전자금융거래법 + 웹접근성 동시 검증**

```typescript
// 3가지 법규 병렬 검토
Task(subagent_type="analyst", model="sonnet",
     prompt=`개인정보보호법 요구사항 분석
     - 수집 항목 명시 (최소 수집 원칙)
     - 동의 절차 (필수/선택 구분)
     - 개인정보 처리방침 필수 표시
     - 제3자 제공 동의 별도`)

Task(subagent_type="analyst", model="sonnet",
     prompt=`전자금융거래법 요구사항 분석
     - 거래 내역 7년 보관
     - 오류 정정 요구권 안내
     - 이용약관 명시
     - 전자서명/공인인증서`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`웹접근성 (KWCAG 2.2) 검증
     - 키보드 접근성 (Tab 순서)
     - ARIA 레이블 (스크린 리더)
     - 색상 대비 4.5:1 (WCAG AA)
     - 대체 텍스트 (이미지)`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`보안 검증
     - XSS/CSRF 방어
     - SQL Injection 방지 (Prisma)
     - 비밀번호 암호화 (bcrypt)
     - HTTPS 강제`)
```

---

### 반응형 병렬 구현

**패턴: 모바일 우선 + 데스크톱 동시 구현**

```typescript
// 한국 모바일 사용률 80%+ 고려
Task(subagent_type="designer", model="sonnet",
     prompt=`모바일 UI 구현 (우선)
     - 화면: 375px (iPhone SE 기준)
     - 터치 타겟: 44-48px (접근성)
     - 하단 네비게이션 (엄지 영역)
     - Safe Area (iOS 노치)`)

Task(subagent_type="designer", model="sonnet",
     prompt=`데스크톱 UI 구현
     - 화면: 1440px
     - 사이드바 네비게이션
     - 마우스 호버 상태
     - 키보드 단축키`)

Task(subagent_type="designer", model="sonnet",
     prompt=`반응형 테스트
     - 브레이크포인트: 375/768/1024/1440
     - 크로스 브라우징 (Chrome/Safari/Samsung Internet)
     - 다크모드 대응`)
```

---

### Model Routing (한국 서비스 특화)

| 작업 유형 | 에이전트 | 모델 | 이유 |
|----------|---------|------|------|
| **UI 컴포넌트** | designer | sonnet | 일반적인 UI 구현 |
| **복잡한 디자인 시스템** | designer | opus | 브랜드 아이덴티티 반영 |
| **법규 요구사항 분석** | analyst | sonnet | 개인정보보호법/전자금융거래법 |
| **보안 검토** | code-reviewer | opus | XSS/CSRF/SQL Injection |
| **API 구현** | implementation-executor | sonnet | Server Functions, Prisma |
| **배포 검증** | deployment-validator | sonnet | typecheck/lint/build |

**모델 선택 예시:**

```typescript
// 간단한 UI → sonnet
Task(subagent_type="designer", model="sonnet",
     prompt="버튼 컴포넌트 구현")

// 복잡한 디자인 시스템 → opus
Task(subagent_type="designer", model="opus",
     prompt="토스 스타일 디자인 시스템 전체 설계")

// 법규 분석 → analyst (sonnet)
Task(subagent_type="analyst", model="sonnet",
     prompt="개인정보보호법 요구사항 분석")

// 보안 검토 → code-reviewer (opus)
Task(subagent_type="code-reviewer", model="opus",
     prompt="결제 시스템 보안 검증 (PCI-DSS)")
```

---

### 실전 시나리오

#### 시나리오 1: 이커머스 (쿠팡/네이버쇼핑 스타일)

**목표:** 상품 구매 플로우 전체 구현 (상품 목록 → 상세 → 결제 → 배송)

```typescript
// Phase 1: UI 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt=`상품 목록 페이지
     - 그리드 레이아웃 (2열/3열)
     - 상품 카드 (이미지/가격/할인율)
     - 필터/정렬 (가격순/인기순)`)

Task(subagent_type="designer", model="sonnet",
     prompt=`상품 상세 페이지
     - 이미지 갤러리 (슬라이드)
     - 옵션 선택 (색상/사이즈)
     - 가격 표시 (할인가/원가)
     - 구매/장바구니 버튼`)

Task(subagent_type="designer", model="sonnet",
     prompt=`결제 페이지
     - 주문 정보 (상품/수량)
     - 주소 입력 (Daum Postcode)
     - 결제 수단 (카드/간편결제)
     - 최종 금액 (배송비 포함)`)

// Phase 2: API 병렬 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`상품 API Server Functions
     - GET /products: 목록 조회
     - GET /products/:id: 상세 조회
     - Prisma Product 모델 사용`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`주문 API Server Functions
     - POST /orders: 주문 생성
     - inputValidator로 Zod 검증
     - 재고 확인 로직`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`결제 API Server Functions
     - POST /payments: 토스페이먼츠 연동
     - 결제 승인/취소/환불
     - 거래 로그 저장 (전자금융거래법)`)

// Phase 3: 법규 병렬 검증
Task(subagent_type="analyst", model="sonnet",
     prompt=`전자상거래법 요구사항 검증
     - 청약철회권 안내 (7일)
     - 환불 정책 명시
     - 사업자 정보 표시`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`개인정보 보안 검토
     - 결제 정보 암호화
     - 주소 정보 접근 제어
     - XSS/CSRF 방어`)
```

---

#### 시나리오 2: 핀테크 (토스/뱅크샐러드 스타일)

**목표:** 금융 계좌 연동 + 자산 관리 대시보드

```typescript
// Phase 1: KYC + 계좌 인증 병렬
Task(subagent_type="designer", model="sonnet",
     prompt=`본인인증 플로우
     - 휴대폰 인증 (NICE/KCB)
     - 신분증 촬영 (OCR)
     - 주민등록번호 마스킹`)

Task(subagent_type="designer", model="sonnet",
     prompt=`계좌 연동 UI
     - 은행 선택 (KB/신한/우리/하나)
     - 1원 인증
     - 연동 완료 확인`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`금융 API 연동
     - 오픈뱅킹 API
     - 계좌 조회/거래내역
     - 이체 실행`)

// Phase 2: 대시보드 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt=`자산 대시보드
     - 총 자산 (원화 표시)
     - 계좌별 잔액
     - 지출 분석 차트`)

Task(subagent_type="designer", model="sonnet",
     prompt=`거래 내역 리스트
     - 날짜별 그룹화
     - 입금/출금 구분
     - 카테고리 태그`)

// Phase 3: 법규 병렬 검증
Task(subagent_type="analyst", model="sonnet",
     prompt=`전자금융거래법 요구사항
     - 거래 내역 7년 보관
     - 오류 정정 요구권
     - 전자서명/공인인증서`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`금융 보안 검증
     - 계좌번호 암호화
     - 이체 한도 설정
     - 이상 거래 탐지`)
```

---

#### 시나리오 3: 공공 서비스 (정부24 스타일)

**목표:** 민원 신청 시스템

```typescript
// Phase 1: UI 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt=`민원 신청 폼
     - 다단계 폼 (개인정보 → 신청내용 → 첨부파일)
     - 필수/선택 항목 표시
     - 진행률 표시`)

Task(subagent_type="designer", model="sonnet",
     prompt=`파일 업로드
     - 드래그 앤 드롭
     - 파일 타입 제한 (pdf/hwp/jpg)
     - 용량 제한 (10MB)`)

// Phase 2: 웹접근성 병렬 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt=`KWCAG 2.2 준수 검증
     - 키보드 접근성 (Tab/Enter)
     - ARIA 레이블 (스크린 리더)
     - 색상 대비 4.5:1
     - 폼 레이블 필수`)

Task(subagent_type="analyst", model="sonnet",
     prompt=`공공데이터 API 연동 분석
     - 행정안전부 API
     - 데이터 형식 (JSON/XML)
     - 인증 방식 (API 키)`)

// Phase 3: 법규 검증
Task(subagent_type="analyst", model="sonnet",
     prompt=`개인정보보호법 검증
     - 수집 항목 최소화
     - 동의 절차 명시
     - 개인정보 처리방침`)
```

---

#### 시나리오 4: 커뮤니티 (네이버 카페/디시인사이드 스타일)

**목표:** 게시판 + 댓글 시스템

```typescript
// Phase 1: UI 병렬 구현
Task(subagent_type="designer", model="sonnet",
     prompt=`게시판 리스트
     - 말머리 (공지/일반/질문)
     - 제목/작성자/날짜/조회수
     - 페이지네이션`)

Task(subagent_type="designer", model="sonnet",
     prompt=`게시글 상세
     - 제목/작성자/날짜
     - 본문 (Markdown 지원)
     - 좋아요/신고 버튼`)

Task(subagent_type="designer", model="sonnet",
     prompt=`댓글 시스템
     - 대댓글 (nested)
     - 좋아요/신고
     - 실시간 업데이트`)

// Phase 2: API 병렬 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`게시글 CRUD API
     - GET /posts: 목록
     - POST /posts: 작성 (인증 필수)
     - PUT /posts/:id: 수정
     - DELETE /posts/:id: 삭제`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`댓글 CRUD API
     - GET /comments: 조회
     - POST /comments: 작성
     - nested 구조 (parent_id)`)

// Phase 3: 컨텐츠 정책 검증
Task(subagent_type="analyst", model="sonnet",
     prompt=`정보통신망법 요구사항
     - 불법 정보 신고 절차
     - 임시조치 (게시 중단)
     - 명예훼손 대응`)
```

---

### 체크리스트

#### 작업 전 확인

**병렬 실행 가능:**
- [ ] 본인인증 + 결제 + 주소입력 (독립 컴포넌트)
- [ ] 모바일 UI + 데스크톱 UI (독립 화면)
- [ ] 개인정보보호법 + 전자금융거래법 + 웹접근성 (독립 검증)
- [ ] 여러 페이지/컴포넌트 동시 작업

**순차 실행 필요:**
- [ ] API 구현 → 검증 (의존성)
- [ ] 디자인 시스템 설계 → 컴포넌트 구현 (순서)

**한국 서비스 필수 체크:**
- [ ] 날짜 형식 (YYYY년 MM월 DD일)
- [ ] 통화 형식 (15,000원)
- [ ] 전화번호 형식 (010-XXXX-XXXX)
- [ ] 주소 입력 (Daum Postcode API)
- [ ] 본인인증 (NICE/KCB)
- [ ] 결제 (토스페이먼츠/KG이니시스)
- [ ] 법규 준수 (개인정보보호법/전자금융거래법/웹접근성)

**모델 선택:**
- [ ] 간단한 UI → designer (sonnet)
- [ ] 복잡한 디자인 시스템 → designer (opus)
- [ ] 법규 분석 → analyst (sonnet)
- [ ] 보안 검토 → code-reviewer (opus)
- [ ] API 구현 → implementation-executor (sonnet)

**적극적으로 병렬 에이전트 활용. 한국 서비스 특화 패턴 적용.**

</parallel_agent_execution>

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
