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
| 설치된 `@tanstack/*` 버전을 공식 공급망 권고의 영향·패치 범위와 대조 | Safety policy | install 또는 upgrade 전에 확인 |

---

## Dependency Safety

- **Safety policy.** install 또는 upgrade 전에 설치된 `@tanstack/*` 버전을 공식 권고의 영향·패치 범위와 대조합니다. 선례는 권고 [`GHSA-g7cv-rxg3-hmpx`](https://github.com/TanStack/router/security/advisories/GHSA-g7cv-rxg3-hmpx)(2026-05-11 게시, critical)입니다. `@tanstack/*` 패키지의 악성 버전이 배포되어 install 시점에 클라우드 자격증명, GitHub 토큰, SSH 키를 수집했습니다. 이 스냅샷들이 고정한 패키지 중 `@tanstack/cli`만 영향을 받지 않았습니다.
- **Official.** 권고가 기록한 영향 → 패치 범위입니다. 이 표는 provenance로만 쓰고, 권위 있는 범위 확인은 권고 원문에서 합니다.

| 패키지 | 악성 버전 | 패치 버전 |
|---|---|---|
| `@tanstack/react-router` | 1.169.5, 1.169.8 | 1.169.9 |
| `@tanstack/react-start` | 1.167.68, 1.167.71 | 1.167.72 |
| `@tanstack/router-cli` | 1.166.46, 1.166.49 | 1.166.50 |
| `@tanstack/router-plugin` | 1.167.38, 1.167.41 | 1.167.42 |
| `@tanstack/start-client-core` | 1.168.5, 1.168.8 | 1.168.9 |
| `@tanstack/start-plugin-core` | 1.169.23, 1.169.26 | 1.169.27 |
| `@tanstack/start-server-core` | 1.167.33, 1.167.36 | 1.167.37 |
| `@tanstack/zod-adapter` | 1.166.12, 1.166.15 | 1.166.16 |

- 특정 버전을 이 파일에서 "안전하다"고 적지 않습니다. 권고의 postmortem은 현재 배포된 모든 TanStack 패키지 버전이 설치해도 안전하다고 밝혔고, 권위 있는 범위 확인은 이 파일이 아니라 권고와 npm advisory database에 있습니다.
- 영향을 받은 버전을 설치한 호스트가 있으면 그 호스트를 침해 가능 상태로 보고, 호스트에서 접근 가능한 자격증명(AWS, GCP, Kubernetes, Vault, GitHub, npm, SSH)을 교체합니다. 페이로드가 install lifecycle script로 실행됐기 때문입니다.

## Release Status

- **Official.** Start는 v1 GA가 아니라 **Release Candidate** 단계입니다. 원문: "TanStack Start is currently in the **Release Candidate** stage! This means it is considered feature-complete and its API is considered stable." 같은 문단이 "**This does not mean it is bug-free or without issues**"라고 덧붙이므로, Start API를 확정된 것으로 다루지 말고 고정된 스냅샷을 다시 확인합니다.

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

## Sources

> Safety policy 사실은 공식 권고 <https://github.com/TanStack/router/security/advisories/GHSA-g7cv-rxg3-hmpx>와 그 postmortem <https://tanstack.com/blog/npm-supply-chain-compromise-postmortem>에서, Release Candidate 문구는 <https://tanstack.com/start/latest/docs/framework/react/overview.md>에서 왔습니다. 공식 사실 검증일 2026-09-22. 나머지는 이 패키지 자체의 snapshot(`references/official/tanstack-start-2026-09-22.md`, `references/official/tanstack-router-2026-09-22.md`, `references/official/current-docs-2026-09-22.md`)에 위임합니다. 저장소 로컬 링크 확인 2026-09-22.
