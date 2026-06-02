# Project Structure and Shared Code Organization

> 공식 Next.js project structure 규칙과 `src/lib`, `src/services` 같은 nested shared folders를 위한 repo-local organization guidance.

---

## Top-Level Structure

| Folder | Meaning |
|---|---|
| `app/` 또는 `src/app/` | App Router route tree와 App Router special files |
| `pages/` 또는 `src/pages/` | legacy 또는 Pages-only surface용 Pages Router route tree |
| `public/` | site root에서 제공되는 static assets |
| `src/` | source code와 project configuration을 분리하는 optional application source root |
| `lib/`, `src/lib/`, `services/`, `src/services/` | repo-local shared code convention이며 Next.js routing convention은 아님 |

`next.config.*`, `package.json`, `tsconfig.json`, lockfiles, `.env*` files는 해당 tool docs가 다르게 말하지 않는 한 project root에 둡니다. `.env*` files가 `src/`에서 load된다고 가정하지 않습니다.

## Routing vs Organization

Next.js routing은 file-system 기반이지만 모든 folder가 같은 의미를 갖지는 않습니다:

- `app/` 또는 `src/app/`에서 folders는 route groups, private folders, special non-routing conventions가 아닌 한 route segments를 정의합니다.
- `(marketing)` 같은 folder는 route group입니다. URL을 바꾸지 않고 routes와 layouts를 organization합니다.
- `_components`, `_lib`, `_actions`, `_queries` 같은 folder는 private folder입니다. route로 처리되면 안 되는 segment-local implementation details에 private folders를 사용합니다.
- App Router segments 안에 files를 colocate할 수 있지만, private folders는 의도를 더 명확히 하고 future naming conflict를 줄입니다.

Implementation-only folder를 URL segment로 노출하지 않습니다. helper folder가 `app/` 아래에 있다면 그 folder가 route segment 또는 route group이어야 하는 경우가 아닌 한 `_folder` naming을 선호합니다.

## Shared Code Placement

여러 routes에서 공유되는 code는 repo의 기존 convention을 먼저 따르되 runtime/domain boundary가 드러나게 배치합니다. 흔한 valid shape는 다음과 같습니다:

```text
src/
├── app/
├── components/
├── lib/
│   ├── auth/
│   └── cache/
├── services/
│   ├── billing/
│   └── stripe/
├── server/
└── db/
```

root-based project 예시:

```text
app/
components/
lib/
services/
server/
db/
```

이 shared folders는 framework law가 아니라 repo-local convention으로 취급합니다. `src/lib/auth`, `src/services/billing` 같은 preference를 reporting/review할 때 official Next.js docs가 요구하지 않는 한 "repo-local convention"이라고 표시합니다. 이 nested shared-folder shape는 official Next.js requirement가 아닙니다.

## Nested Shared Folder Grouping Policy

touched shared code를 추가하거나 재구성할 때 explicit project exception이 없으면 `src/lib/foo.ts`, `src/services/foo.ts`, `lib/foo.ts`, `services/foo.ts` 같은 new direct leaf file을 만들지 않습니다. Ownership, runtime boundaries, provider integrations, domain logic이 드러나는 nested grouping을 선호합니다.

Project가 더 좁은 convention을 기록하지 않는 한 new touched shared code는 `src/lib/<domain>/...`, `src/services/<domain-or-provider>/...` 같은 ownership path를 사용합니다.

다음 경우 nested grouping을 선호합니다:

- new touched shared code가 otherwise `src/lib`, `src/services`, `lib`, `services`, `src/server`, `src/db` 바로 아래 direct file로 놓일 때
- folder에 서로 다른 responsibility의 file이 3개 이상 있을 때
- domain, provider, layer, external integration별 자연스러운 분리가 있을 때
- server-only modules, DAL code, schemas, DTOs, cache tags, permissions가 섞여 있을 때
- routes를 가로질러 action/query/helper pattern이 반복될 때
- unrelated helpers가 나란히 있어 imports가 모호할 때

예시 nested shared shape:

```text
src/
├── lib/
│   ├── auth/
│   │   ├── session.ts
│   │   ├── permissions.ts
│   │   └── dto.ts
│   └── cache/
│       ├── tags.ts
│       └── revalidate.ts
├── services/
│   ├── billing/
│   │   ├── actions.ts
│   │   ├── queries.ts
│   │   └── schema.ts
│   └── stripe/
│       └── client.server.ts
└── db/
    ├── client.server.ts
    └── repositories/
        └── user-repository.ts
```

작은 existing folders는 더 단순하면 flat하게 유지할 수 있지만, new touched shared files는 explicit exception이 없으면 여전히 grouped 되어야 합니다. unrelated one-off files만을 위해 deep hierarchy를 만들지 않습니다.

## Boundary Naming Guidance

Runtime과 architectural boundaries가 드러나는 이름을 사용합니다:

| Pattern | Use for |
|---|---|
| `_components/` | `app/` 아래 segment-local UI implementation |
| `_lib/` | `app/` 아래 segment-local helpers |
| `_actions/` | `app/` 아래 segment-local Server Actions |
| `actions.ts` | reusable 또는 domain-specific Server Actions |
| `queries.ts` | server-side read helpers |
| `schema.ts` | validation 또는 data shape definitions |
| `dto.ts` | client-safe view models와 return values |
| `permissions.ts` | authorization checks |
| `cache/tags.ts` | cache tag names와 invalidation helpers |

DB clients, DAL modules, secret-bearing SDK wrappers, authorization helpers처럼 client graph에 절대 들어가면 안 되는 modules에는 `import 'server-only'`를 추가합니다.

## Hard Rules

| 확인 | 규칙 |
|---|---|
| `app/` 아래 implementation-only folder가 route segment로 노출됨 | 의도적으로 routable하지 않으면 차단 |
| touched code에서 flat `lib` layout이 server/client, domain, security boundaries를 숨김 | 경고. nested grouping 권장 |
| shared code placement를 repo-local convention이 아니라 official Next.js law처럼 제시 | 차단 |
| 새 nested folders가 circular imports 또는 불명확한 public entry points를 만듦 | 위험도에 따라 경고/차단 |
| server-only shared code에 명확한 server boundary가 없음 | 경고, client import risk가 있으면 차단 |

## Review Checklist

- Top-level `app`, `pages`, `public`, optional `src` usage가 detected router mode와 일치함.
- `app` segment internals가 route segments가 아닐 때 private folders를 사용함.
- Route groups는 URL 변경이 아니라 organization 또는 layout sharing에 사용됨.
- Shared `lib` / `src/lib` code는 boundaries를 개선한다면 nested domain 또는 layer grouping을 사용할 수 있음.
- Nested grouping이 더 명확할 때 flat shared folders를 강요하지 않음.
- Framework-required rules와 repo-local conventions를 별도로 labeling함.
- Server-only shared modules에 `import 'server-only'` 또는 동등하게 명확한 boundary가 있음.
