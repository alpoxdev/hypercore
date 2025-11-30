# Sequential Thinking MCP

> 복잡한 문제를 체계적으로 분해하고 해결하는 사고 도구

---

## 🚀 Quick Reference

```
✅ 사용 필수 상황:
- 버그 원인 분석
- 아키텍처 설계
- 복잡한 로직 구현
- 리팩토링 계획
- 성능 최적화
- 다단계 작업 계획

❌ 불필요한 상황:
- 단순 코드 수정
- 명확한 API 호출
- 복사/붙여넣기 작업
```

---

## 핵심 개념

Sequential Thinking은 복잡한 문제를 **단계별로 분해**하여 체계적으로 해결하는 사고 방식입니다.

### 작동 방식

1. **문제 정의**: 해결해야 할 문제 명확화
2. **분해**: 작은 단계로 나누기
3. **순차 분석**: 각 단계 순서대로 분석
4. **검증**: 각 단계 결과 검증
5. **종합**: 최종 결론 도출

---

## 사용 시점

### ✅ 반드시 사용

| 상황 | 이유 |
|------|------|
| 버그 디버깅 | 원인 추적에 체계적 접근 필요 |
| 시스템 설계 | 구성 요소 간 관계 분석 |
| 복잡한 로직 | 단계별 흐름 파악 |
| 리팩토링 | 영향 범위 분석 |
| 성능 분석 | 병목 지점 식별 |

### ❌ 사용 불필요

| 상황 | 이유 |
|------|------|
| 단순 CRUD | 패턴이 명확함 |
| 스타일 수정 | 분석 불필요 |
| 오타 수정 | 즉시 수정 가능 |
| 문서 확인 | Context7 사용 |

---

## 실전 예시

### 예시 1: 버그 디버깅

```
문제: "로그인 후 세션이 유지되지 않음"

Step 1: 증상 파악
- 로그인 성공 후 페이지 이동 시 로그아웃됨
- 새로고침 시 세션 사라짐

Step 2: 가설 수립
- 쿠키 설정 문제?
- 세션 저장소 문제?
- 미들웨어 문제?

Step 3: 검증
- 쿠키 확인 → httpOnly, secure 설정 확인
- 세션 저장소 확인 → Redis 연결 상태 확인
- 미들웨어 확인 → 세션 검증 로직 확인

Step 4: 원인 특정
- 쿠키 sameSite 설정이 'strict'로 되어 있어
  cross-origin 요청 시 쿠키 미전송

Step 5: 해결
- sameSite: 'lax'로 변경
```

### 예시 2: 아키텍처 설계

```
문제: "사용자 알림 시스템 설계"

Step 1: 요구사항 정리
- 실시간 알림 (WebSocket)
- 이메일 알림
- 푸시 알림
- 알림 히스토리

Step 2: 구성 요소 식별
- NotificationService (핵심 로직)
- WebSocketHandler (실시간)
- EmailProvider (이메일)
- PushProvider (푸시)
- NotificationRepository (저장)

Step 3: 데이터 흐름 설계
- 이벤트 발생 → NotificationService
- NotificationService → 채널별 분배
- 각 Provider → 전송
- Repository → 저장

Step 4: 인터페이스 정의
- INotificationProvider
- INotificationRepository
- NotificationEvent 타입

Step 5: 구현 순서 결정
1. 타입/인터페이스 정의
2. Repository 구현
3. Service 핵심 로직
4. Provider 구현
5. WebSocket 통합
```

### 예시 3: 성능 최적화

```
문제: "목록 페이지 로딩 3초 이상"

Step 1: 현재 상태 측정
- API 응답: 2.5초
- 렌더링: 0.5초

Step 2: API 분석
- 쿼리 확인: N+1 문제 발견
- 데이터 양: 1000개 전체 로딩

Step 3: 최적화 방안
- N+1 해결: include로 조인
- 페이지네이션: 20개씩 로딩
- 인덱스: 자주 조회하는 컬럼

Step 4: 구현
- Prisma include 추가
- 커서 기반 페이지네이션
- DB 인덱스 생성

Step 5: 결과 측정
- API 응답: 0.3초 (88% 개선)
```

---

## Context7과 함께 사용

```
복잡한 문제 해결 시:

1. Sequential Thinking으로 문제 분석
   ↓
2. 필요한 라이브러리 API 파악
   ↓
3. Context7로 공식 문서 확인
   ↓
4. Sequential Thinking으로 구현 계획
   ↓
5. 구현
```

---

## 참고

- 복잡한 문제일수록 단계를 더 세분화
- 각 단계에서 가정과 검증을 명확히
- 필요시 이전 단계로 돌아가 재분석
