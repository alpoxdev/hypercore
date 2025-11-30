# sgrep - Semantic Grep

> AST 기반 시맨틱 코드 검색 도구

---

## ⛔ 필수 규칙

```
❌ grep, rg 등 기본 검색 도구 사용 금지
❌ find 명령어로 코드 검색 금지
✅ 코드베이스 검색 시 sgrep 사용 필수
```

---

## 개요

sgrep는 단순 텍스트 매칭이 아닌 AST(Abstract Syntax Tree) 기반의 시맨틱 검색을 수행합니다.

### grep vs sgrep

| 기능 | grep | sgrep |
|------|------|-------|
| 검색 방식 | 텍스트 매칭 | AST 기반 |
| 코드 구조 인식 | ❌ | ✅ |
| 언어별 최적화 | ❌ | ✅ |
| False positive | 많음 | 적음 |

---

## 사용 시점

### ✅ sgrep 사용
- 함수 정의 찾기
- 클래스 사용처 검색
- 특정 패턴의 코드 찾기
- import 문 검색
- API 엔드포인트 검색

### 예시 상황
```
"prisma.user.create 사용처를 찾아줘" → sgrep 사용
"authMiddleware가 어디서 쓰이는지 찾아줘" → sgrep 사용
"HTTPException을 throw하는 곳을 찾아줘" → sgrep 사용
```

---

## 장점

### 1. 정확한 코드 구조 인식
```typescript
// 주석 안의 function은 무시
// function test() {}

// 실제 함수만 찾음
function test() {}
```

### 2. 언어별 최적화
- TypeScript/JavaScript
- Python
- Go
- 기타 주요 언어

### 3. 패턴 매칭
- 함수 호출 패턴
- 클래스 정의 패턴
- import/export 패턴

---

## 관련 문서

- [MCP 개요](./index.md)
- [Sequential Thinking](./sequential-thinking.md)
- [Context7](./context7.md)
