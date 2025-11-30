# Context7

> 라이브러리 공식 문서 조회 도구

---

## 개요

Context7은 주요 라이브러리의 공식 문서를 조회하여 정확한 API 정보와 사용 패턴을 제공합니다.

---

## 사용 시점

### ✅ 사용 권장
- **API 확인**: 라이브러리 함수/메서드 사용법
- **공식 패턴**: 권장되는 코드 패턴
- **버전별 차이**: 특정 버전의 API 확인
- **최신 정보**: 최신 릴리즈 기능 확인

### ❌ 사용 불필요
- 이미 알고 있는 기본 API
- 프로젝트 내부 코드 관련 질문
- 일반적인 프로그래밍 개념

---

## 지원 라이브러리

### 주요 지원
- **Hono**: 라우팅, 미들웨어, RPC
- **Zod**: 스키마 정의, 검증
- **Prisma**: ORM, 쿼리, 마이그레이션
- **TypeScript**: 타입 시스템

### 기타 지원
- React, Vue, Angular
- Express, Fastify
- 기타 주요 npm 패키지

---

## 사용 예시

### Hono 문서 조회
```
"Hono의 zValidator 사용법 조회"
"Hono middleware 작성 패턴 조회"
"Hono RPC client 설정 방법 조회"
```

### Zod 문서 조회
```
"Zod v4의 z.email() 사용법 조회"
"Zod transform 패턴 조회"
"Zod discriminatedUnion 사용법 조회"
```

### Prisma 문서 조회
```
"Prisma v7 generator 설정 조회"
"Prisma transaction 패턴 조회"
"Prisma relation 쿼리 방법 조회"
```

---

## 장점

### 1. 정확한 정보
- 공식 문서 기반
- 검증된 코드 예시

### 2. 최신 정보
- 최신 버전 반영
- 업데이트된 API

### 3. 버전 특정
- 특정 버전 문서 조회
- 버전 간 차이 확인

---

## 워크플로우

```
1. 필요한 정보 파악
   └─ 어떤 라이브러리의 어떤 기능?

2. Context7 조회
   └─ 해당 라이브러리 문서 검색

3. 정보 확인
   └─ API 시그니처, 사용 예시

4. 코드 적용
   └─ 프로젝트에 맞게 적용
```

---

## 관련 문서

- [MCP 개요](./index.md)
- [sgrep](./sgrep.md)
- [Sequential Thinking](./sequential-thinking.md)
