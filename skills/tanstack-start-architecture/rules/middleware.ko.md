# Middleware

> validation, context 전파, client-to-server 데이터 전달을 위한 middleware 규칙

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| function middleware는 `createMiddleware({ type: 'function' })` 사용 | Official | 잘못된 middleware type 차단 |
| `sendContext`는 명시적이며 자동 전송 아님 | Official | trust 전 validation |
| client-provided context를 server-side 검증 | Safety policy | unvalidated trust 차단 |
| shared auth/logging/tenant logic 중앙화 | Hypercore convention | touched code에서 warn/fix |

---

## 핵심 규칙

Middleware는 단순 auth 용도가 아닙니다. request context, validation, logging, server-safe 데이터 전파를 명시적으로 처리하는 경계입니다.

---

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| server function용 middleware를 `{ type: 'function' }` 없이 생성함? | 차단 |
| 클라이언트에서 `sendContext`로 보낸 동적 데이터를 서버에서 검증 없이 사용함? | 차단 |
| `next({ context: ... })` 대신 암묵적으로 context를 변형함? | 차단 |
| 공통 auth/logging/tenant 로직을 middleware 대신 각 handler에 중복함? | 경고. middleware 우선 |

---

## 허용 패턴

- middleware가 데이터 검증을 책임질 때 `.inputValidator()`를 사용합니다
- `next({ context: { ... } })`로 context를 확장합니다
- client middleware의 `sendContext`는 서버에 정말 필요한 데이터만 전송합니다
- 클라이언트가 보낸 `sendContext`는 서버에서 반드시 검증 후 신뢰합니다

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

- Middleware가 `{ type: 'function' }`를 사용함
- 공통 request 로직이 middleware에 중앙화됨
- `sendContext`가 최소화되어 있고 서버에서 검증됨
- Context 확장이 명시적이고 typed 되어 있음
