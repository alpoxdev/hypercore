# Execution Model

> TanStack Start의 서버/클라이언트/공용 실행 경계 규칙

---

## 핵심 규칙

코드가 어디서 실행되는지 추측으로 판단하면 안 됩니다. TanStack Start에서는:

- route `loader`는 기본적으로 isomorphic입니다
- `beforeLoad`와 컴포넌트 렌더링은 SSR 모드에 따라 서버/클라이언트/양쪽에서 실행될 수 있습니다
- 브라우저 API가 route 코드에서 자동으로 안전한 것이 아닙니다
- secret은 클라이언트에서 도달 가능한 코드에 두면 안 됩니다

---

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| `loader`가 secret, DB, filesystem, privileged SDK를 직접 읽음? | 차단. `createServerFn` 또는 `createServerOnlyFn`으로 이동 |
| 클라이언트에서 도달 가능한 코드가 secret 값을 `process.env`에서 직접 읽음? | 차단 |
| 서버에서도 실행될 수 있는 코드에서 `window`, `localStorage`, `document`를 경계 없이 사용함? | 차단 |
| `typeof window` 분기 대신 `createClientOnlyFn` / `createServerOnlyFn` / `createIsomorphicFn`이 더 명확한데 수동 분기함? | 경고. 프레임워크 primitive 선호 |
| 하나의 공용 유틸이 서버 전용 로직과 클라이언트 전용 로직을 함께 섞고 있음? | 차단. 분리하거나 환경 함수 사용 |

---

## 올바른 Primitive 선택

| 목적 | 사용 API |
|------|-----|
| routes/components에서 호출하는 서버 RPC | `createServerFn` |
| 클라이언트에서 호출되면 바로 실패해야 하는 서버 전용 헬퍼 | `createServerOnlyFn` |
| 서버에서 실행되면 바로 실패해야 하는 클라이언트 전용 헬퍼 | `createClientOnlyFn` |
| 서버/클라이언트 구현이 다른 같은 API | `createIsomorphicFn` |

---

## Loader 규칙

`loader` 자체는 secret을 안전하게 숨겨주는 경계가 아닙니다.

잘못된 예:

```ts
export const Route = createFileRoute('/users')({
  loader: () => {
    return fetch(`/api/users?key=${process.env.SECRET_KEY}`)
  },
})
```

올바른 예:

```ts
const getUsersSecurely = createServerFn().handler(async () => {
  return fetch(`/api/users?key=${process.env.SECRET_KEY}`)
})

export const Route = createFileRoute('/users')({
  loader: () => getUsersSecurely(),
})
```

---

## 보안 규칙

- secret, DB client, filesystem 접근, privileged SDK는 반드시 `createServerFn` 또는 `createServerOnlyFn` 뒤에 둡니다
- 브라우저 API는 `createClientOnlyFn`, `ClientOnly`, client-only component/hook 뒤에 둡니다
- 클라이언트가 import할 수 있는 코드라면, import protection과 실행 경계로 증명되지 않는 한 공개 코드라고 가정합니다

---

## 리뷰 체크리스트

- `loader` 내부에 secret/privileged access가 직접 없음
- 환경 전용 헬퍼는 TanStack Start primitive를 사용함
- 서버 전용 코드가 클라이언트에서 도달되지 않음
- 브라우저 전용 코드가 서버 렌더에서 실행되지 않음
