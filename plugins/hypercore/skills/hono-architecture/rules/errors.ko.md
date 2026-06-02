# 에러와 응답

> HTTP 실패 처리 중앙화와 응답 의도 보존

---

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
- `c.notFound()` 사용 전 typed RPC 영향 검토

