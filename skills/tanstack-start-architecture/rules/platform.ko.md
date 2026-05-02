# Platform Setup

> Router, env, alias, 운영 인접 설정 규칙

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| `src/router.tsx`가 fresh-instance `getRouter()` export | Official | missing setup 차단 |
| server/client env boundary | Safety policy | secret leak 차단 |
| non-trivial app runtime env validation | Hypercore convention + Safety policy | warn 또는 `src/config/env.ts` scaffold 추가 |
| Vite version-aware path alias | Hypercore convention | touched code에서 수정 |

---

## Router 설정

- `src/router.tsx`는 반드시 `getRouter()`를 export해야 합니다
- `getRouter()`는 호출할 때마다 새로운 router instance를 생성해서 반환해야 합니다
- `scrollRestoration`, preload 기본값, cache 설정 같은 router-wide 동작은 여기서 설정합니다

---

## Environment 규칙

- 새 TanStack Start env scaffold에서는 `src/env/`, `src/env.ts`, `src/env.d.ts`를 만들지 않습니다.
- env 코드는 `src/config/` 아래에 유지하고, canonical validation module은 `src/config/env.ts`입니다.
- TanStack Start/Vite 프로젝트에서는 `@t3-oss/env-core`와 `zod`를 사용하고 `createEnv`로 scaffold합니다.
- 프로젝트가 Vite `envPrefix`를 명시적으로 바꾸지 않았다면 client 변수는 `clientPrefix: "VITE_"`로 설정합니다.
- `VITE_*` 변수는 client에 노출되므로 secret, token, private API key, password, database URL을 담으면 안 됩니다.
- 서버 전용 env는 `process.env`에 두고 server boundary 뒤에서 접근하며 `server`에 나열합니다.
- client-safe env는 `import.meta.env`에서 가져오고 `client`에 나열하며 public prefix를 사용합니다.
- 명시적인 build-time coverage가 필요하면 `runtimeEnvStrict`를 우선 사용하고, framework/runtime이 전체 env object를 안정적으로 제공할 때만 `runtimeEnv`를 사용합니다.
- shared config file이 server/client 양쪽에서 import될 수 있으면 `isServer: typeof window === "undefined"`를 포함합니다.
- 프로젝트에 문서화된 예외가 없으면 새 validation module에는 `emptyStringAsUndefined: true`를 설정합니다.
- 서버 변수 이름 자체가 client bundle에 노출되면 안 되는 경우에도 schema split은 `src/config/` 아래(예: `env.server.ts`, `env.client.ts`)에서 수행하고 `src/env/` 아래에는 만들지 않습니다.

Canonical starter shape:

```ts
// src/config/env.ts
import { createEnv } from "@t3-oss/env-core"
import * as z from "zod"

export const env = createEnv({
  server: {
    DATABASE_URL: z.url(),
  },
  clientPrefix: "VITE_",
  client: {
    VITE_PUBLIC_APP_URL: z.url(),
  },
  runtimeEnvStrict: {
    DATABASE_URL: process.env.DATABASE_URL,
    VITE_PUBLIC_APP_URL: import.meta.env.VITE_PUBLIC_APP_URL,
  },
  isServer: typeof window === "undefined",
  emptyStringAsUndefined: true,
})
```

---

## Path Alias 규칙

- path alias는 암묵적으로 가정하지 말고 명시적으로 설정합니다
- Vite 8+: `resolve.tsconfigPaths: true` 우선
- Vite 7 이하: `vite-tsconfig-paths` 사용
- 저장소 전체에서 하나의 canonical alias 규칙을 유지합니다

---

## 운영 인접 패턴

- health/readiness endpoint는 server route로 허용됩니다
- sitemap/robots 생성은 prerender 설정 또는 server route를 사용할 수 있습니다
- integration/LLMO용 machine-readable endpoint는 명시적으로 필요할 때 허용됩니다
- observability hook, metrics, Sentry류 연동은 페이지 로직이 아니라 operations/platform 문서에 둡니다

---

## 리뷰 체크리스트

- `getRouter()`가 존재하고 새 instance를 반환함
- env 사용이 typed이고 경계가 안전함
- alias 설정이 사용 중인 Vite 버전과 맞음
- 운영 endpoint가 내부 앱 RPC와 섞이지 않음
