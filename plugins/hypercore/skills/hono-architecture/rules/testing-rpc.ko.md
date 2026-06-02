# Testing과 RPC

> typed client와 테스트를 route-shape 회귀로부터 보호

---

## 핵심 규칙

- 앱이 `testClient()` 또는 `hc`를 쓰면 route type inference를 보호
- typed client나 공유 contract가 앱에 의존하면 `AppType` export
- 큰 앱에서는 sub-app composition 타입이 exported surface까지 유지되어야 함

## 예시

```ts
export const app = new Hono()
  .get('/search', (c) => {
    const query = c.req.query('q')
    return c.json({ query })
  })

export type AppType = typeof app
```

## 리뷰 체크리스트

- route type이 exported app까지 흐름
- 리팩터링 후에도 `testClient()`가 계속 유용함
- `hc<typeof app>` 또는 sub-app client 추론이 유지됨
- detached registration이 조용히 타입을 지우지 않음

