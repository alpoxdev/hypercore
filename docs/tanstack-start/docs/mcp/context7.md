# Context7 MCP

> 라이브러리 공식 문서를 실시간으로 조회하는 도구

---

## 🚀 Quick Reference

```
✅ 사용 필수 상황:
- 라이브러리 API 사용법 확인
- 최신 버전 문법 확인
- 공식 문서 기반 구현
- 버전 마이그레이션

❌ 불필요한 상황:
- 이미 알고 있는 기본 문법
- 프로젝트 내부 코드 분석
- 비즈니스 로직 구현
```

---

## 사용 방법

### Step 1: 라이브러리 ID 조회

```
resolve-library-id 사용
→ 라이브러리 이름으로 Context7 ID 획득
```

### Step 2: 문서 조회

```
get-library-docs 사용
→ 특정 토픽의 문서 가져오기

파라미터:
- context7CompatibleLibraryID: 라이브러리 ID
- topic: 조회할 주제 (예: "hooks", "routing")
```

---

## 프로젝트 라이브러리별 사용 예시

### TanStack Start

```
토픽 예시:
- "server functions" - createServerFn 사용법
- "routing" - 파일 기반 라우팅
- "loader" - 데이터 로딩
- "middleware" - 미들웨어 설정
```

### TanStack Query

```
토픽 예시:
- "useQuery" - 쿼리 훅
- "useMutation" - 뮤테이션 훅
- "invalidation" - 캐시 무효화
- "optimistic updates" - 낙관적 업데이트
```

### Prisma

```
토픽 예시:
- "findMany" - 다중 조회
- "create" - 생성
- "relations" - 관계 쿼리
- "transactions" - 트랜잭션
```

### Zod

```
토픽 예시:
- "object" - 객체 스키마
- "email" - 이메일 검증 (v4)
- "transform" - 변환
- "refinement" - 커스텀 검증
```

### Tailwind CSS

```
토픽 예시:
- "configuration" - 설정
- "theme" - 테마 커스터마이징
- "responsive" - 반응형
- "dark mode" - 다크 모드
```

### Better Auth

```
토픽 예시:
- "setup" - 초기 설정
- "session" - 세션 관리
- "providers" - OAuth 설정
- "2fa" - 이중 인증
```

---

## 사용 시점

### ✅ 반드시 사용

| 상황 | 이유 |
|------|------|
| 새 API 사용 | 정확한 시그니처 확인 |
| 버전 업그레이드 | 변경사항 확인 |
| 에러 해결 | 올바른 사용법 확인 |
| 고급 기능 | 옵션/설정 확인 |

### ❌ 사용 불필요

| 상황 | 이유 |
|------|------|
| 기본 문법 | 이미 문서화됨 |
| 내부 코드 | Context7 범위 외 |
| 비즈니스 로직 | 라이브러리 무관 |

---

## 실전 예시

### 예시 1: TanStack Query 캐시 무효화

```
상황: mutation 후 목록 갱신이 안됨

1. Context7로 "invalidation" 토픽 조회
2. queryClient.invalidateQueries 사용법 확인
3. 올바른 queryKey 패턴 적용

결과:
queryClient.invalidateQueries({ queryKey: ['users'] })
```

### 예시 2: Prisma 관계 쿼리

```
상황: User와 Post를 함께 조회하고 싶음

1. Context7로 "relations" 토픽 조회
2. include 옵션 사용법 확인

결과:
prisma.user.findUnique({
  where: { id },
  include: { posts: true }
})
```

### 예시 3: Zod v4 마이그레이션

```
상황: Zod v3 → v4 업그레이드

1. Context7로 "migration" 또는 "email" 토픽 조회
2. v4 새 API 확인

결과:
// v3: z.string().email()
// v4: z.email()
```

---

## Sequential Thinking과 함께 사용

```
복잡한 구현 시:

1. Sequential Thinking으로 구현 계획
   ↓
2. 필요한 라이브러리 기능 파악
   ↓
3. Context7로 각 기능 문서 조회
   ↓
4. 문서 기반 구현
```

---

## 주의사항

- **최신 문서**: Context7은 최신 공식 문서 제공
- **버전 확인**: 프로젝트 버전과 문서 버전 일치 확인
- **토픽 선택**: 구체적인 토픽으로 조회 시 더 정확한 결과

---

## 참고

- 문서가 충분하지 않으면 다른 토픽으로 재조회
- 여러 라이브러리 문서를 연속으로 조회 가능
- Sequential Thinking과 조합하여 체계적 구현
