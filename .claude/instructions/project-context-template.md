# Project Context Template

**목적**: CLAUDE.md 표준 섹션 정의 및 아키텍처 맵 작성 가이드

**배경**: Usage Report 분석 결과 "매 세션마다 코드베이스를 처음부터 재탐색"하는 문제 발견. 간결한 아키텍처 맵을 CLAUDE.md에 추가하면 컨텍스트 절약 및 멀티 Phase 리팩토링 지원 가능.

---

## CLAUDE.md 표준 섹션

**권장 순서 및 구조:**

| 섹션 | 설명 | 필수 여부 |
|------|------|----------|
| **Project Stack** | 기술 스택 명시 (프레임워크, 버전, 도구) | ✅ 필수 |
| **Architecture Map** | 디렉토리 구조 및 주요 모듈 역할 요약 | ✅ 필수 |
| **Code Conventions** | 코딩 스타일, 커밋 형식, 테스트 규칙 | ✅ 필수 |
| **Communication Style** | 응답 스타일, 자율성, 언어 선호도 | 선택 |
| **Data Fetching Patterns** | API 호출, 상태 관리, 캐시 규칙 | 선택 |
| **Forbidden** | 프로젝트별 금지 사항 | 선택 |
| **Required** | 프로젝트별 필수 규칙 | 선택 |

---

## 섹션별 작성 가이드

### 1. Project Stack

**형식**: 표 또는 목록

```markdown
<tech_stack>
| 기술 | 버전 | 주의사항 |
|------|------|----------|
| TanStack Start | 1.x | React 19 기반 |
| Tailwind CSS | v4 | 새 CSS 엔진 |
| Better Auth | 1.x | 세션 관리 |
| Drizzle | 0.x | Prisma 대체 |
| pnpm | 9.x | monorepo |
</tech_stack>
```

**체크리스트:**
- [ ] 프레임워크 버전 명시
- [ ] ORM/데이터베이스 도구
- [ ] 패키지 매니저 (pnpm/yarn/npm)
- [ ] 주요 라이브러리 (인증, 상태 관리, 스타일링)

---

### 2. Architecture Map

**형식**: 트리 구조 + 파일 수 + 역할 요약

```markdown
<architecture>
src/
├── routes/       (23 files) - 페이지 라우트
│   ├── trading/  - 트레이딩 관련 페이지
│   └── admin/    - 관리자 페이지
├── components/   (45 files) - 공유 컴포넌트
│   ├── ui/       - 기본 UI 컴포넌트
│   └── domain/   - 도메인 특화 컴포넌트
├── lib/          (12 files) - 유틸리티, API 클라이언트
│   ├── api/      - API 함수
│   └── utils/    - 헬퍼 함수
├── hooks/        (8 files) - 커스텀 훅
└── server/       (15 files) - 서버 함수, 미들웨어

prisma/
└── schema/       (6 files) - DB 스키마 (Multi-File)
</architecture>
```

**체크리스트:**
- [ ] 주요 디렉토리 역할 명시
- [ ] 파일 수 (대략적)
- [ ] 서브 디렉토리 구조 (중요한 것만)
- [ ] 특이 사항 (예: Multi-File Prisma, monorepo)

---

### 3. Code Conventions

**형식**: 목록 + 예시

```markdown
<code_conventions>
## 네이밍
- 파일: kebab-case (user-profile.tsx)
- 컴포넌트: PascalCase (UserProfile)
- 함수: camelCase (getUserData)
- Server Function: camelCase (createUser, getProfile)

## 커밋 메시지
- 형식: `<prefix>: <설명>` (한 줄)
- Prefix: feat, fix, refactor, style, docs, test, chore
- 예시: `feat: 로그인 API 구현`

## 테스트
- 단위 테스트: *.test.ts
- E2E: *.e2e.ts
- 커버리지: 80% 이상
</code_conventions>
```

**체크리스트:**
- [ ] 파일/함수/변수 네이밍 규칙
- [ ] 커밋 메시지 형식
- [ ] 테스트 규칙
- [ ] 주석 언어 (한글/영어)

---

### 4. Communication Style

**형식**: 목록

```markdown
<communication_style>
- 옵션 제시보다 자율 결정 우선 (너가 알아서 해)
- 커밋 메시지: 한글 Conventional Commit
- 간결한 응답 선호 (장황한 설명 지양)
- 코드 중심 답변 (설명 < 예시)
</communication_style>
```

**체크리스트:**
- [ ] 자율 vs 옵션 제시
- [ ] 응답 길이 선호도
- [ ] 언어 (한국어/영어)
- [ ] 코드 vs 설명 비율

---

### 5. Data Fetching Patterns

**형식**: 목록 + 예시

```markdown
<data_fetching>
## API 호출 패턴
- TanStack Query (useQuery/useMutation) 필수
- Server Function 직접 호출 금지

## 상태 관리
- Query: GET 요청 (자동 캐싱)
- Mutation: POST/PUT/DELETE (수동 무효화)

## 캐시 무효화
- 생성: invalidateQueries(['users'])
- 수정: invalidateQueries(['users', id])
- 삭제: removeQueries(['users', id])
</data_fetching>
```

**체크리스트:**
- [ ] API 호출 라이브러리
- [ ] 상태 관리 방식
- [ ] 캐시 무효화 규칙
- [ ] 낙관적 업데이트 여부

---

## 아키텍처 맵 작성 예시

### 예시 1: TanStack Start + Prisma Multi-File

```markdown
<architecture>
src/
├── routes/       (18 files) - 파일 기반 라우팅
│   ├── __root.tsx - 루트 레이아웃
│   ├── index.tsx - 홈 페이지
│   └── users/
│       ├── index.tsx - 사용자 목록
│       └── $id.tsx - 사용자 상세
├── components/   (32 files) - React 컴포넌트
│   ├── ui/       (15 files) - shadcn/ui 기반
│   └── domain/   (17 files) - 비즈니스 로직
├── lib/          (9 files) - 공통 유틸
│   ├── api.ts - Server Function 정의
│   └── utils.ts - 헬퍼 함수
└── hooks/        (5 files) - 커스텀 훅

prisma/
├── schema.prisma - 메인 스키마 (datasource + generator)
└── schema/       (4 files) - 모델 정의
    ├── user.prisma
    ├── post.prisma
    ├── comment.prisma
    └── _relations.prisma
</architecture>
```

### 예시 2: Next.js + App Router

```markdown
<architecture>
app/
├── (auth)/       - 인증 그룹 레이아웃
│   ├── login/
│   └── signup/
├── (dashboard)/  - 대시보드 그룹
│   ├── layout.tsx
│   └── page.tsx
├── api/          (12 files) - API 라우트
│   ├── users/
│   └── posts/
└── _components/  (20 files) - 앱 전역 컴포넌트

components/       (40 files) - 공유 컴포넌트
lib/              (8 files) - 유틸리티
</architecture>
```

---

## 아키텍처 맵 업데이트 시점

| 시점 | 업데이트 내용 |
|------|--------------|
| **새 모듈/패키지 추가** | 디렉토리 추가, 파일 수 업데이트 |
| **디렉토리 구조 변경** | 트리 구조 재작성 |
| **주요 의존성 추가/제거** | tech_stack 섹션 업데이트 |
| **파일 수 크게 변경** | (±10개 이상) 파일 수 재카운트 |
| **리팩토링 완료** | 변경된 구조 반영 |

**업데이트 방법:**
```bash
# 파일 수 카운트
find src/routes -type f | wc -l
find src/components -type f | wc -l

# 디렉토리 구조 출력
tree -L 2 src/
```

---

## 템플릿 생성 자동화

### 옵션 1: Claude 명령어로 생성

```bash
claude -p "Generate CLAUDE.md architecture map for this project"
```

**프롬프트 예시:**
```
현재 프로젝트의 CLAUDE.md 아키텍처 맵을 생성해줘.

요구사항:
1. src/ 디렉토리 구조 분석
2. 각 디렉토리별 파일 수 카운트
3. 주요 모듈 역할 요약
4. 기술 스택 명시 (package.json 기반)

출력 형식: Architecture Map 섹션만
```

### 옵션 2: Explore 에이전트로 구조 분석

```typescript
Task(subagent_type="explore", model="haiku",
     prompt="[very thorough] 프로젝트 디렉토리 구조 완전 분석. 파일 수, 역할, 주요 모듈 요약")
```

### 옵션 3: 수동 작성 (초기 설정)

```bash
# 1. 디렉토리 구조 출력
tree -L 3 src/ > architecture.txt

# 2. 파일 수 카운트
find src/ -type d -exec sh -c 'echo "$1: $(find "$1" -maxdepth 1 -type f | wc -l)"' _ {} \;

# 3. CLAUDE.md에 복사 후 수동 편집
```

---

## 실전 예시: 프로젝트별 CLAUDE.md

### 예시 1: TanStack Start + Drizzle

```markdown
# CLAUDE.md - Trading Platform

<instructions>
@.claude/instructions/validation/forbidden-patterns.md
@.claude/instructions/validation/required-behaviors.md
@.claude/docs/library/tanstack-start/index.md
</instructions>

<tech_stack>
| 기술 | 버전 | 주의사항 |
|------|------|----------|
| TanStack Start | 1.x | React 19 |
| Drizzle | 0.x | PostgreSQL |
| Better Auth | 1.x | 세션 인증 |
| Tailwind CSS | v4 | CSS 엔진 |
| pnpm | 9.x | monorepo |
</tech_stack>

<architecture>
src/
├── routes/       (23 files) - 파일 기반 라우팅
│   ├── trading/  (8 files) - 트레이딩 페이지
│   └── admin/    (5 files) - 관리자
├── components/   (45 files) - React 컴포넌트
│   ├── ui/       (20 files) - shadcn/ui
│   └── domain/   (25 files) - 비즈니스 로직
├── lib/          (12 files) - API, 유틸리티
└── hooks/        (8 files) - 커스텀 훅

drizzle/
└── schema/       (5 files) - DB 스키마
</architecture>

<code_conventions>
- 파일: kebab-case (user-profile.tsx)
- 커밋: `<prefix>: <설명>` (한 줄)
- 한글 주석 필수 (코드 블록 단위)
</code_conventions>

<communication_style>
- 자율 결정 우선
- 간결한 응답
- 한글 커밋 메시지
</communication_style>

<forbidden>
| 금지 | 이유 |
|------|------|
| `/api` 라우트 | TanStack Server Function 사용 |
| 클라이언트 직접 호출 | TanStack Query 필수 |
</forbidden>

<required>
| 필수 | 설명 |
|------|------|
| Server Function | POST/PUT → inputValidator + middleware |
| TanStack Query | useQuery/useMutation |
</required>
```

### 예시 2: Next.js + Prisma Multi-File

```markdown
# CLAUDE.md - Blog Platform

<instructions>
@.claude/instructions/validation/forbidden-patterns.md
@.claude/instructions/validation/required-behaviors.md
</instructions>

<tech_stack>
| 기술 | 버전 | 주의사항 |
|------|------|----------|
| Next.js | 15.x | App Router |
| Prisma | 7.x | Multi-File |
| Zod | 4.x | z.email(), z.url() |
| Tailwind CSS | v4 | CSS 엔진 |
| NextAuth.js | 5.x | 인증 |
</tech_stack>

<architecture>
app/
├── (auth)/       (4 files) - 인증 페이지
├── (dashboard)/  (12 files) - 대시보드
├── api/          (10 files) - API 라우트
└── _components/  (18 files) - 전역 컴포넌트

components/       (35 files) - 공유 컴포넌트
lib/              (7 files) - 유틸리티

prisma/
├── schema.prisma - 메인 스키마
└── schema/       (6 files) - 모델 정의
</architecture>

<code_conventions>
- 파일: kebab-case
- 커밋: `<prefix>: <설명>` (한 줄)
- API 라우트: camelCase (getUserData)
</code_conventions>

<communication_style>
- 옵션 제시 (2-3개)
- 상세 설명 선호
- 영어 커밋 메시지
</communication_style>

<forbidden>
| 금지 | 이유 |
|------|------|
| Prisma 자동 실행 | 승인 필요 |
| schema.prisma 직접 수정 | Multi-File 사용 |
</forbidden>

<required>
| 필수 | 설명 |
|------|------|
| API 라우트 | Zod 검증 필수 |
| Prisma Schema | 한글 주석 (///) |
</required>
```

---

## 체크리스트

### CLAUDE.md 작성 전

- [ ] 프로젝트 기술 스택 확인 (package.json)
- [ ] 디렉토리 구조 분석 (tree, find)
- [ ] 파일 수 카운트 (각 주요 디렉토리)
- [ ] 코딩 컨벤션 정리 (기존 파일 참고)
- [ ] 커밋 히스토리 확인 (git log)

### 작성 후

- [ ] tech_stack 섹션 버전 명시
- [ ] architecture 섹션 파일 수 포함
- [ ] code_conventions 섹션 예시 포함
- [ ] communication_style 섹션 명확한 지시
- [ ] forbidden/required 섹션 프로젝트별 규칙

### 유지보수

- [ ] 주요 변경 시 즉시 업데이트
- [ ] 월 1회 파일 수 재카운트
- [ ] 새 팀원 합류 시 리뷰

---

## 장점

| 항목 | 효과 |
|------|------|
| **탐색 시간 단축** | 매 세션마다 코드베이스 재탐색 불필요 |
| **컨텍스트 절약** | 아키텍처 맵으로 전체 구조 한눈에 파악 |
| **멀티 Phase 지원** | 큰 리팩토링 시 구조 참조 |
| **일관성** | 팀 전체가 동일한 구조 이해 |

---

## 참고

- Usage Report: "Consider adding a concise architecture map to your CLAUDE.md"
- Context Compaction: 200K 토큰 → 아키텍처 맵으로 구조 압축
- Ralph 세션: PROCESS.md에 아키텍처 변경 기록
