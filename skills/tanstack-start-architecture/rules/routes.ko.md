# Route Structure

> route 조직, file-route lifecycle, search validation, hypercore page folder convention.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| file route instance를 `Route`로 export | Official | 없으면 차단 |
| search params를 사용할 때 validation | Official + Safety policy | 사용자 입력이 동작에 영향 주면 차단 |
| `beforeLoad`가 `loader`보다 먼저 실행되는 lifecycle | Official | auth/context/redirect에 사용 |
| Router는 flat/directory 혼용 지원 | Official | flat route를 TanStack invalid라고 말하지 않음 |
| 앱 페이지 route-directory 선호 | Hypercore convention | official default 요청이 없으면 touched page에 적용 |
| logic/server integration이 있는 페이지의 `-hooks/`, `-components/`, `-functions/` | Hypercore convention | logic/integration이 있으면 적용 |

## Publishing-Only Exception

Publishing-only page는 interactive logic과 server integration이 없는 static display page입니다.
예: terms, privacy, about, 단순 marketing content.

- `-components/`, `-hooks/`, `-functions/`가 필요 없습니다.
- interactive logic을 추가하면 필요에 따라 `-hooks/`와 route-local component를 만듭니다.
- server integration을 추가하면 `-functions/`와 query/mutation orchestration용 route-local hook을 둡니다.

## Hypercore Route Folder Shape

```text
routes/<page>/
├── index.tsx
├── route.tsx
├── -components/
├── -hooks/
├── -functions/
└── -sections/
```

공식 TanStack Router는 flat route file도 지원합니다. 위 구조는 hypercore maintainability convention입니다.

## File Route Export

```typescript
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users/')({
  component: UsersPage,
})
```

- route instance는 `Route`로 export해야 합니다.
- `createFileRoute` path string은 router plugin 또는 CLI가 생성/갱신합니다.

## Route Lifecycle

| Step | Official behavior | Use for |
|---|---|---|
| `validateSearch` | matching/search validation 중 실행 | URL search state 파싱/검증 |
| `beforeLoad` | route loading 전 serial 실행 | Auth, redirects, context extension |
| `loader` | route loading phase에서 실행, cache/preload 가능 | Data loading; server-only로 취급 금지 |
| `pendingComponent` | threshold 기반 optional pending UI | 느린 critical loader UX |
| `errorComponent` | route lifecycle/render error 처리 | Recoverable route errors |

## Search Validation

search params를 사용하면 검증합니다.

Zod v4 official path:

```typescript
import { z } from 'zod'

const searchSchema = z.object({ page: z.number().default(1) })

export const Route = createFileRoute('/products/')({
  validateSearch: searchSchema,
  component: ProductsPage,
})
```

Zod v3 official path:

```typescript
import { zodValidator, fallback } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({ page: fallback(z.number(), 1).default(1) })

export const Route = createFileRoute('/products/')({
  validateSearch: zodValidator(searchSchema),
  component: ProductsPage,
})
```

프로젝트가 모든 버전에서 `zodValidator`를 표준화한다면 project note에 hypercore convention으로 표시합니다.

## Loader Boundary Rule

- TanStack Start loader는 isomorphic입니다.
- loader code에서 secret, database client, filesystem, privileged SDK에 직접 접근하지 않습니다.
- privileged work는 `createServerFn` 또는 `createServerOnlyFn` 뒤로 옮깁니다.

## Validation Checklist

- [ ] touched file route가 `Route`를 export함.
- [ ] search params가 설치된 Zod version에 맞게 검증됨.
- [ ] auth/context/redirect는 필요한 경우 `beforeLoad`에 있음.
- [ ] loader code에 direct secret/DB/filesystem access가 없음.
- [ ] publishing-only page에 빈 route-local folder를 강제하지 않음.
- [ ] logic/server integration이 있는 page는 route-local 구조를 갖거나 이유가 기록됨.
