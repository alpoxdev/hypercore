# Project Structure and Shared Folder Organization

> TanStack Start project shape, route-root discovery, generated route tree handling, Hypercore shared-folder grouping 규칙.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Start source와 route root는 `tanstackStart({ srcDirectory, router: { routesDirectory } })` 또는 defaults에서 도출 | Official | config가 다르면 `src/routes`를 hard-code하지 않음 |
| `src/router.tsx`가 `getRouter()`를 export하고 generated `routeTree.gen.ts`를 import | Official | `rules/platform.md`와 함께 확인 |
| `routeTree.gen.ts`는 Start/Router tooling이 생성 | Official + Safety policy | 일반 architecture work에서 수동 편집 금지 |
| `public/`, root `vite.config.ts`, `package.json`, `tsconfig.json`는 project-level surface로 유지 | Official/docs-derived | source folder 안의 app code처럼 이동하지 않음 |
| `src/lib`, `src/services`, `src/db`, `src/server`, `src/config` 같은 shared folders | Hypercore convention | ownership과 boundaries를 명확히 할 때 touched code에 적용 |
| server-only shared code는 compiler-recognized boundaries 뒤에 둠 | Safety policy | client-reachable secret/DB/privileged import 차단 |

## Official Start Project Shape

기본 Start project shape는 source-rooted이며 route tree가 generated됩니다:

```text
src/
├── routes/
│   ├── __root.tsx
│   ├── index.tsx
│   └── example.tsx
├── router.tsx
├── routeTree.gen.ts
├── styles.css
└── types/
public/
vite.config.ts
package.json
tsconfig.json
```

해석:

- `src/routes`는 default route directory이며, config가 override하면 무조건적인 path가 아닙니다.
- `src/router.tsx`는 router creation을 담당하고 `getRouter()`를 export해야 합니다.
- `src/routeTree.gen.ts`는 generated file입니다. route 변경을 위해 수동 rewrite하지 않습니다.
- `public/`은 static assets용입니다.
- `vite.config.ts`에는 Start plugin과 route/source directory customization이 있습니다.

## Route Root Discovery

Folder structure를 강제하기 전에 Start plugin config를 확인합니다:

```ts
// vite.config.ts
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [
    tanstackStart({
      srcDirectory: 'src',
      router: {
        routesDirectory: 'routes',
      },
    }),
  ],
})
```

Default route root는 `src/routes`입니다. `srcDirectory` 또는 `router.routesDirectory`가 custom이면 config에서 실제 route root를 도출하고 review에 보고합니다.

## Route-Local Organization

특정 route에만 존재하는 route-local organization은 route 근처에 둡니다:

```text
<route-root>/<page>/
├── index.tsx
├── route.tsx
├── -components/
├── -hooks/
├── -functions/
└── -sections/
```

이 shape는 Hypercore convention입니다. TanStack Router는 flat, directory, mixed route structures를 공식 지원하므로 flat route files를 official TanStack usage로 invalid라고 말하지 않습니다.

Page logic, UI composition, server integration이 route-specific일 때 route-local folders를 사용합니다. Publishing-only static pages에 empty folders를 강제하지 않습니다.

## Shared Nested Folder Grouping

Routes를 가로질러 공유되는 code는 route root 밖에 두고, touched shared code를 추가하거나 재구성할 때는 nested logical grouping을 사용해야 합니다. 명시적 project exception을 기록하지 않는 한 `src/lib/foo.ts`, `src/services/foo.ts`, `src/config/foo.ts` 같은 새 direct leaf file을 만들지 않습니다. Domain ownership, runtime boundary, dependency direction을 보여주는 `src/lib/<domain>/foo.ts`, `src/services/<domain-or-provider>/foo.ts` 같은 ownership folder를 선호합니다.

이 shared-folder shape는 Hypercore 또는 repo-local convention으로 label합니다(official TanStack requirement 아님). TanStack 공식 문서가 특정 `src/lib` 또는 `src/services` grouping을 요구하지 않기 때문입니다.

권장 Hypercore shape 예시:

```text
src/
├── lib/
│   ├── auth/
│   │   ├── session.ts
│   │   └── permissions.ts
│   └── cache/
│       └── query-keys.ts
├── services/
│   ├── billing/
│   │   ├── queries.ts
│   │   └── mutations.ts
│   └── stripe/
│       └── client.server.ts
├── db/
│   ├── client.server.ts
│   └── repositories/
│       └── user-repository.ts
└── config/
    └── env.ts
```

다음 상황에서는 nested grouping을 선호합니다:

- 새 touched shared code가 그대로라면 `src/lib`, `src/services`, `src/db`, `src/server`, `src/config` 아래 direct file로 놓이게 됨
- shared folder에 서로 다른 책임의 files가 세 개 이상 있음
- domain logic, provider integration, schemas, DTOs, query keys, permissions가 섞여 있음
- server-only helper와 client-safe helper가 혼동되기 쉬움
- route-local `-functions/`가 reusable domain logic으로 커지고 있음
- 관련 없는 helpers가 나란히 있어 imports가 모호해짐

작은 project는 더 단순하다면 기존 shared folder를 flat하게 유지할 수 있지만, shared root 아래 새 touched file은 explicit project exception이 없으면 grouping합니다. 이 선택은 official TanStack requirement가 아니라 Hypercore 또는 repo-local convention으로 label합니다.

## Boundary and Import Protection Notes

Folder name 자체는 runtime boundary를 강제하지 않습니다.

Privileged shared code에는 다음 중 하나 이상의 명시적 보호를 사용합니다:

- 적절한 경우 `.server.` file suffix
- `@tanstack/react-start/server-only` marker import
- server-only execution boundary용 `createServerOnlyFn`
- client-callable server RPC용 `createServerFn`
- 프로젝트가 더 강한 folder/package protection을 필요로 할 때 custom `importProtection` deny rules

Route loader 또는 client-reachable module이 DB clients, secret env, filesystem access, privileged SDK wrappers를 직접 import하지 않게 합니다.

## Hard Rules

| 확인 | 규칙 |
|---|---|
| `tanstackStart()` config가 `srcDirectory` 또는 `routesDirectory`를 customize했는데 review가 `src/routes`를 가정 | 실제 route root를 도출할 때까지 차단 |
| 일반 architecture change에서 `routeTree.gen.ts`를 수동 편집 | 차단 |
| Shared `src/lib` / `src/services` layout을 official TanStack law처럼 제시 | 차단 |
| touched shared root가 exception 없이 `src/lib/foo.ts` 또는 `src/services/foo.ts` 같은 direct leaf file을 추가하려 함 | 경고. logical nested folder로 이동 |
| touched shared folder가 mixed server/client 또는 domain boundaries를 flat layout에 숨김 | 경고. nested grouping 권장 |
| server-only shared code가 client-reachable이거나 import protection이 없음 | 차단 |

## Review Checklist

- [ ] 실제 source root와 route root를 Start config 또는 documented defaults에서 도출함.
- [ ] `src/router.tsx`와 generated `routeTree.gen.ts`의 역할을 유지함.
- [ ] Route-local folders는 route-specific logic/UI/server integration이 있을 때만 사용함.
- [ ] Publishing-only pages에 empty route-local folders를 강제하지 않음.
- [ ] 새 touched shared code는 explicit exception이 없는 한 `src/lib`, `src/services`, `src/db`, `src/server`, `src/config` 바로 아래 direct leaf file을 만들지 않음.
- [ ] Shared folders는 boundaries를 명확히 할 때 nested `src/lib`, `src/services`, `src/db`, `src/server`, `src/config` grouping을 사용함.
- [ ] Official Start facts, Safety policy, Hypercore conventions를 별도로 label함.
- [ ] Server-only shared modules에 명시적 import/runtime protection이 있음.
