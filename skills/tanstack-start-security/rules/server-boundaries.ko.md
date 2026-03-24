# 서버 경계 규칙

> TanStack Start에서 secret, env, loader, privileged code를 다루는 실행 경계 규칙

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| secret이 클라이언트에서 도달 가능한 코드에 있음? | 차단 |
| `loader`가 privileged access를 직접 수행함? | 차단. `createServerFn` 또는 `createServerOnlyFn` 뒤로 이동 |
| 서버 전용 helper가 클라이언트에서 도달 가능한 코드에서 import됨? | 차단 |
| 브라우저 전용 helper가 서버 가능 코드 경로로 들어옴? | 차단 |
| request 입력이 privileged handler에서 검증 없이 사용됨? | 차단 |

## 실행 Primitive 선택

- 클라이언트에서 시작될 수 있는 서버 RPC는 `createServerFn`
- 클라이언트에서 실행되면 안 되는 helper는 `createServerOnlyFn`
- 브라우저 전용 helper는 `createClientOnlyFn`
- 양쪽 환경을 모두 명시적으로 지원할 때만 `createIsomorphicFn`
- 경계 리뷰를 흐리게 만드는 server function / privileged helper의 dynamic import는 피합니다

## Secret / Env 규칙

- 서버 secret은 `process.env`에 두고 서버 경계 뒤에 둡니다
- 브라우저로 나가는 public config는 실제로 노출 가능한 값만 둡니다
- 컴파일을 맞추려고 secret을 public env prefix로 옮기면 안 됩니다
- 필수 secret, URL, origin은 typed env 접근과 runtime validation을 권장합니다

## Loader 규칙

- 더 강한 경계가 증명되지 않으면 route `loader`를 client-reachable 코드로 취급합니다
- 데이터 로딩은 괜찮지만 privileged work는 안 됩니다
- privileged 데이터가 필요하면 loader 안에 secret 로직을 두지 말고 secure server function을 호출합니다
- loader 반환값, SSR context, hydrated state는 기본적으로 클라이언트에 보인다고 가정합니다

## Import / 파일 경계

- `*.server.*`, `*.client.*` 파일 의도를 지킵니다
- 추측에 의존하지 말고 TanStack Start import protection을 유지/확장합니다
- 파일명만으로 부족하면 explicit marker를 사용합니다
- public 코드와 privileged 코드가 한 파일에 섞여 있으면 분리합니다

## 검증

- 비신뢰 입력은 privileged work 전에 검증합니다
- handler 곳곳에 수동 검증을 흩뿌리기보다 typed validator로 앞단에서 막습니다
- validation 뒤에 normalize, 그 다음 authorize, 마지막에 side effect 순서를 지킵니다
- route가 받는 입력도 보안 경계입니다. `validateSearch`, `params.parse`, body parsing을 검증 대상으로 취급합니다

## 리뷰 체크리스트

- secret 값이 client bundle 또는 client-importable module에서 닿지 않음
- loader와 공용 유틸이 privileged work를 직접 수행하지 않음
- privileged code가 TanStack Start 서버 경계 뒤에 있음
- 파일/import 경계가 실제 runtime intent와 일치함
- 입력 검증이 privileged side effect보다 먼저 실행됨
- loader 결과와 hydrated state에 secret 또는 내부 전용 auth state가 직렬화되지 않음
