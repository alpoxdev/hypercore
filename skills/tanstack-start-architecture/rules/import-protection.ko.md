# Import Protection

> TanStack Start의 클라이언트/서버 경계 보호 규칙

---

## 왜 필요한가

TanStack Start는 클라이언트 번들과 서버 번들을 따로 빌드합니다. Import protection은 다음을 막습니다.

- 서버 전용 코드가 클라이언트 번들로 새는 것
- 클라이언트 전용 코드가 서버 번들로 새는 것
- 환경 경계 밖에서 살아남는 잘못된 헬퍼 import

이 기능은 TanStack Start Vite 플러그인의 기본 보호 장치이며, 선택 옵션이 아니라 아키텍처 필수 가드레일로 취급해야 합니다.

---

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| 클라이언트에서 도달 가능한 코드가 `*.server.*`를 import함? | 차단 |
| 서버 실행 경로가 `*.client.*`를 import함? | 차단 |
| 서버 전용 코드인데 `.server.*` 접미사나 marker import가 없음? | 차단. 이름 변경 또는 marker 추가 |
| 클라이언트 전용 코드인데 `.client.*` 접미사나 marker import가 없음? | 차단. 이름 변경 또는 marker 추가 |
| 같은 파일에 `@tanstack/react-start/server-only`와 `@tanstack/react-start/client-only`를 함께 import함? | 차단 |
| `vite.config.ts`에서 import protection을 꺼둠? | 사용자가 명시적으로 요청한 경우가 아니면 차단 |
| 프로젝트 규칙상 디렉터리 deny가 필요한데 `vite.config.ts`에 명시적 `importProtection` 설정이 없음? | 진행 전에 수정 |
| 서버 전용 import가 `createServerFn`, `createServerOnlyFn` 같은 컴파일러 경계 밖에서 살아남음? | 차단. 즉시 리팩터링 |

---

## TanStack Start 기본 동작

TanStack Start는 기본적으로 import protection을 활성화합니다.

### 클라이언트 환경 차단 대상

- `**/*.server.*`
- `@tanstack/react-start/server`

### 서버 환경 차단 대상

- `**/*.client.*`

### 기본 동작값

- dev: `mock`
- build: `error`
- 반복 로그: `once`

즉, dev에서는 경고 후 mock으로 계속 진행될 수 있지만, 최종 판단 기준은 build입니다. 애매하면 반드시 production build로 확인해야 합니다.

---

## 필수 네이밍과 Marker

우선 파일명으로 경계를 표현하세요.

- 서버 전용 모듈: `*.server.ts`, `*.server.tsx`
- 클라이언트 전용 모듈: `*.client.ts`, `*.client.tsx`

파일명을 바꾸기 어렵다면 파일 최상단에 marker import를 추가합니다.

```ts
import '@tanstack/react-start/server-only'
```

```ts
import '@tanstack/react-start/client-only'
```

파일명이 경계를 충분히 표현하지 못하지만 실제로는 특정 환경 전용일 때 marker를 사용합니다. 두 marker를 같은 파일에 함께 두면 안 됩니다.

---

## `vite.config.ts` 필수 점검/설정

프로젝트에 이미 `tanstackStart()`가 있으면 기존 옵션을 덮어쓰지 말고 `importProtection`만 확장하세요.

`vite.config.ts`에 `importProtection` 명시 설정이 없다면, 최소한 아래 기준으로 추가할 수 있어야 합니다.

```ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [
    tanstackStart({
      importProtection: {
        behavior: {
          dev: 'mock',
          build: 'error',
        },
        client: {
          files: [
            '**/*.server.*',
            '**/server/**',
            '**/database/**',
            '**/db/**',
          ],
        },
        server: {
          files: ['**/*.client.*', '**/client/**'],
        },
      },
    }),
  ],
})
```

### 적용 원칙

- `importProtection`이 없으면 추가
- 이미 있으면 기존 `client.files`, `server.files`를 무작정 덮어쓰지 말고 확장
- 사용자가 명시적으로 요청하지 않는 한 `enabled: false` 금지
- TanStack 기본 보호 규칙은 특별한 이유가 없으면 유지

---

## Leaky Import 패턴

가장 조심해야 하는 실패 패턴은 이것입니다.

```ts
import { getUsers } from './db/queries.server'
import { createServerFn } from '@tanstack/react-start'

export const fetchUsers = createServerFn().handler(async () => {
  return getUsers()
})

export const leakyHelper = () => {
  return getUsers()
}
```

`fetchUsers`는 서버 함수 경계 안에 있어서 안전합니다. 하지만 `leakyHelper`는 클라이언트 빌드에도 살아남을 수 있는 코드이므로 안전하지 않습니다.

### 수정 방법

1. 새는 헬퍼를 별도의 `*.server.*` 파일로 분리
2. `createServerOnlyFn`으로 감싸기
3. 클라이언트에서 도달 가능한 코드에서 서버 전용 import 제거

예시:

```ts
import { createServerOnlyFn } from '@tanstack/react-start'
import { getUsers } from './db/queries.server'

export const leakyHelper = createServerOnlyFn(() => {
  return getUsers()
})
```

---

## 리뷰 체크리스트

TanStack Start 변경을 승인하기 전에 아래를 확인하세요.

- 클라이언트에서 도달 가능한 모듈이 `*.server.*`를 import하지 않음
- 서버 실행 경로가 `*.client.*`를 import하지 않음
- 환경 전용 모듈은 파일명 suffix 또는 marker import로 표시됨
- 필요 시 `vite.config.ts`에 `importProtection`이 설정되거나 확장됨
- import protection이 몰래 비활성화되지 않음
- 서버 전용 헬퍼가 컴파일러 인식 경계를 벗어나지 않음
- dev 경고가 애매하면 실제 build로 다시 확인함
