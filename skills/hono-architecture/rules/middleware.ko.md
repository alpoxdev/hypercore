# 미들웨어

> 요청 경계와 공통 관심사에 대한 미들웨어 규칙

---

## 핵심 규칙

미들웨어는 auth, request ID, CORS, logging, context enrichment처럼 요청 전반의 관심사를 명시하는 경계입니다.

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| 미들웨어 순서를 잘못 가정 | 차단 |
| 공통 요청 관심사를 handler마다 복붙 | 경고 |
| `c.set()` 값을 typed `Variables` 없이 사용 | 차단 |
| `Context`로 요청 간 상태를 유지한다고 가정 | 차단 |

## 리뷰 체크리스트

- 등록 순서가 의도적임
- 공통 관심사가 중앙화됨
- context variable이 타입화됨
- middleware가 숨은 business-logic layer가 되지 않음

