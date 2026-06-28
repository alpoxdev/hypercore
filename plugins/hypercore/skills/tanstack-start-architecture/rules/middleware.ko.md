# Middleware

> validation, context 전파, client-to-server 데이터 전달을 위한 middleware 규칙

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Request middleware는 default로 `createMiddleware()` 사용 | Official | request middleware에 function-only syntax를 강제하지 않음 |
| Server function middleware는 `createMiddleware({ type: 'function' })` 사용 | Official | `.client(...)`, `.inputValidator(...)`, server-function-only behavior가 쓰이면 잘못된 middleware type 차단 |
| Server function middleware validation은 `.inputValidator(...)` 사용 | Official | middleware와 server-function validation chain을 개념적으로 분리 |
| `sendContext`는 명시적이며 자동 전송 아님 | Official | trust 전 validation |
| client-provided context를 server-side 검증 | Safety policy | unvalidated trust 차단 |
| shared auth/logging/tenant logic 중앙화 | Hypercore convention | touched code에서 warn/fix |

---

## 핵심 규칙

Middleware는 단순 auth 용도가 아닙니다. request context, validation, logging, server-safe 데이터 전파를 명시적으로 처리하는 경계입니다.

TanStack Start에는 두 middleware type이 있습니다:

- Request middleware: `createMiddleware()` 또는 `createMiddleware({ type: 'request' })`. Server requests, server routes, SSR, server functions에 적용되며 `.server(...)`만 가집니다.
- Server function middleware: `createMiddleware({ type: 'function' })`. `createServerFn` middleware chain용이며 `.client(...)`, `.server(...)`, `.inputValidator(...)`를 사용할 수 있습니다.

---

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| Request middleware가 function-only behavior를 사용함? | 차단. `createMiddleware({ type: 'function' })` 사용 |
| Server function middleware validation을 `.validator(...)`로 작성함? | 차단. Middleware는 `.inputValidator(...)`를 사용하고 server functions도 별도 chain에서 `.inputValidator(...)`를 사용 |
| 클라이언트에서 `sendContext`로 보낸 동적 데이터를 서버에서 검증 없이 사용함? | 차단 |
| `next({ context: ... })` 대신 암묵적으로 context를 변형함? | 차단 |
| 공통 auth/logging/tenant 로직을 middleware 대신 각 handler에 중복함? | 경고. middleware 우선 |

---

## 허용 패턴

- server function middleware가 데이터 변환 또는 검증을 책임질 때 `.inputValidator(...)`를 사용합니다
- Middleware `.inputValidator(...)`와 server-function `.inputValidator(...)`를 혼동하지 않습니다. method name은 같지만 서로 다른 API입니다.
- `next({ context: { ... } })`로 context를 확장합니다
- client middleware의 `sendContext`는 서버에 정말 필요한 데이터만 전송합니다
- 클라이언트가 보낸 `sendContext`는 서버에서 반드시 검증 후 신뢰합니다
- global request middleware는 `src/start.ts`에서 `createStart(() => ({ requestMiddleware: [...] }))`로 설정합니다

---

## `sendContext` 보안 규칙

클라이언트 context는 자동으로 신뢰할 수 없습니다.

잘못된 예:

```ts
const requestLogger = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    return next({
      sendContext: {
        workspaceId: context.workspaceId,
      },
    })
  })
  .server(async ({ next, context }) => {
    useWorkspace(context.workspaceId)
    return next()
  })
```

올바른 예:

```ts
const requestLogger = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    return next({
      sendContext: {
        workspaceId: context.workspaceId,
      },
    })
  })
  .server(async ({ next, context }) => {
    const workspaceId = zodValidator(z.string()).parse(context.workspaceId)
    useWorkspace(workspaceId)
    return next()
  })
```

---

## 리뷰 체크리스트

- Request middleware는 function-only feature가 필요하지 않으면 `createMiddleware()`를 사용
- Server function middleware는 `createMiddleware({ type: 'function' })`를 사용
- Server function middleware는 middleware-owned data validation에 `.inputValidator(...)`를 사용
- 공통 request 로직이 middleware에 중앙화됨
- `sendContext`가 최소화되어 있고 서버에서 검증됨
- Context 확장이 명시적이고 typed 되어 있음
