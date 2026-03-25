# Route Handlers

> `route.ts`가 맞는 표면인지, 아닌지 판단하는 규칙.

---

## Route Handler를 써야 하는 경우

- webhook
- feed
- CORS 민감 엔드포인트
- machine-readable public endpoint
- XML/JSON 같은 non-UI 응답
- 메서드 단위 처리와 헤더 제어가 필요한 HTTP-native 통합

## Route Handler를 기본값으로 쓰면 안 되는 경우

- Server Action으로 충분한 일반 내부 form mutation
- Server Component에서 해결 가능한 내부 UI 데이터 읽기
- Proxy가 맡아야 할 forward/edge-style 처리

mutation이 앱 UI에서 시작된다면 우선 Server Action을 가정하고, 실제 요구가 HTTP semantics일 때만 `route.ts`를 정당화하세요.

## 강한 규칙

| 확인 항목 | 규칙 |
|-----------|------|
| 같은 세그먼트에 `route.ts`와 `page.tsx` 공존 | 차단 |
| UI-only 흐름인데 internal RPC 기본값처럼 Route Handler를 사용 | 실제 HTTP semantics가 필요하지 않으면 차단 |
| Route Handler 안에서 `NextResponse.next()` 사용 | 차단 |
| 최신 기본 동작을 확인하지 않고 예전 GET handler 캐시 기본값을 가정 | 차단 |

## 중요한 메모

- Route Handler는 App Router에서만 사용할 수 있습니다
- Route Handler도 다른 App Router 파일처럼 route segment config를 공유합니다
- `GET` handler의 기본 캐싱은 최신 Next.js에서 바뀐 적이 있으므로, 중요한 경우 명시적으로 의도를 표현해야 합니다
- `sitemap.xml`, `robots.txt`, icon, metadata는 빌트인 파일 규칙이 있으니 필요 없으면 커스텀 handler를 만들지 마세요

## 판단 순서

선택 우선순위:

1. 서버 렌더링 UI 읽기면 Server Component
2. 내부 UI mutation과 form이면 Server Action
3. 진짜 HTTP-native 표면일 때만 Route Handler

## 리뷰 체크리스트

- 엔드포인트가 실제로 HTTP semantics를 필요로 하는지
- `page.tsx`와 충돌이 없는지
- 현재 캐시 동작을 이해하고 있는지
- Proxy 전용 동작이 Route Handler로 새고 있지 않은지
