# 에러와 응답

> HTTP 실패 처리 중앙화와 응답 의도 보존

---

## Stable Hono 4.13 기준

`app.notFound()`는 top-level app에서만 실행됩니다. Child route의 `onError` handler는 parent handler보다 우선합니다. `HTTPException.getResponse()`는 `Context`에 이미 누적된 header를 알지 못합니다.

- Public error envelope 하나를 정의하고 expected domain failure를 literal HTTP status로 의도적으로 mapping합니다.
- Stack trace, SQL, provider payload, secret, raw validation internal을 노출하지 않습니다.
- Error response를 교체할 때 필요한 CORS, request ID, cache, authentication header를 보존합니다.
- RPC는 global middleware나 `onError()` response를 자동 infer하지 않습니다. Shared global response가 client contract에 포함되면 `ApplyGlobalResponse`를 사용합니다.
- Client가 infer해야 하는 RPC route의 typed 404 contract를 `c.notFound()`에만 맡기지 않습니다. Route-local typed JSON variant를 반환합니다.
- Thrown `HTTPException`, unknown error, route-local error handler precedence, top-level 404, required header를 test합니다.
## 핵심 규칙

- 예상 가능한 HTTP 실패는 `HTTPException` 또는 명시적 번역 레이어 사용
- 중간 이상 규모 앱은 `app.onError()` 정의
- 에러 응답을 다시 만들 때 `Context`에 세팅한 헤더 보존

## 예시

```ts
import { HTTPException } from 'hono/http-exception'

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    const response = err.getResponse()
    c.res.headers.forEach((value, key) => {
      response.headers.set(key, value)
    })
    return response
  }

  return c.json({ message: 'Internal Server Error' }, 500)
})
```

## 리뷰 체크리스트

- 필요 시 중앙 에러 번역이 존재
- 에러 응답이 의도한 헤더/상태를 보존
- 예상 가능한 HTTP 에러를 전부 generic throw로 던지지 않음
- Client가 의존하는 typed RPC/public-client 404 동작은 `app.notFound()` 또는 explicit JSON response contract로 검증

## Sources

> 이 파일에는 외부 출처를 사용하지 않았습니다. 공식 Hono 동작은 `references/official/hono-docs.ko.md`에 위임합니다(last verified 2026-08-04). 저장소 로컬 링크 확인 2026-09-21.
