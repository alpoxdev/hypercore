---
name: nextjs-architecture
description: "[Hyper] Next.js 프로젝트, 특히 App Router 또는 App Router 마이그레이션 작업에 사용합니다. 현재 공식 Next.js 아키텍처 규칙에 따라 project/folder structure, nested shared `src/lib` / `src/services` organization, 라우트/파일 규칙, Server/Client Component 경계, Cache Components와 데이터 freshness, 내부 UI 쓰기용 Server Actions, HTTP-native 엔드포인트용 Route Handlers, 최후 수단으로서 Proxy, 플랫폼/env 안전성을 강제합니다."
compatibility: Next.js 애플리케이션에서 저장소 검사, 공식 Next.js 문서 확인, 직접 코드 편집과 함께 사용할 때 가장 적합합니다.
---

@architecture-rules.ko.md
@rules/project-structure.ko.md
@rules/routes.ko.md
@rules/execution-model.ko.md
@rules/data-fetching.ko.md
@rules/server-actions.ko.md
@rules/route-handlers.ko.md
@rules/platform.ko.md
@rules/validation.ko.md
@references/official/nextjs-docs.ko.md
@references/official/current-docs-2026-06-02.ko.md

# Next.js Architecture Enforcement

<output_language>

사용자-facing 결과물, 저장 아티팩트, 보고서, 계획, 생성 문서, 요약, 핸드오프 노트, 커밋/메시지 초안, 검증 노트는 기본적으로 한국어로 작성합니다. canonical skill 파일이 영어로 작성되어 있어도 동일합니다.

소스 코드 식별자, CLI 명령, 파일 경로, schema key, JSON/YAML field, API 이름, package 이름, 고유명사, 인용된 원문은 필요한 언어 또는 원래 언어를 보존합니다.

사용자가 명시적으로 다른 언어를 요청하거나, 기존 대상 산출물이 일관성을 위해 다른 언어를 유지해야 하거나, machine-readable contract가 정확한 영어 token을 요구하는 경우에만 다른 언어를 사용합니다. localized template 또는 reference가 있으면(예: `*.ko.md`, `*.ko.json`) 사용자-facing 산출물에 우선 사용합니다.

</output_language>

<purpose>

- repository가 Next.js project인지 확인하고 App Router, Pages Router, mixed mode를 식별한 뒤 architecture rules를 적용합니다.
- file conventions, Server/Client Component boundaries, data/cache behavior, Server Actions, Route Handlers, Proxy, env/platform safety에 대한 official Next.js behavior를 강제합니다.
- `src/lib/<domain>/`, `src/services/<domain-or-provider>/` 같은 nested shared folders에 대한 Hypercore/repo-local convention을 적용하되 official Next.js law처럼 표현하지 않습니다.
- version-sensitive official facts는 `references/official/`에 보관해 core skill을 lean하게 유지하고 current docs를 독립적으로 refresh할 수 있게 합니다.

</purpose>

<routing_rule>

existing Next.js project의 architecture enforcement, implementation guidance, review에 사용합니다. 특히 App Router work, App Router migration, Server/Client boundaries, cache/freshness, Server Actions, Route Handlers, Proxy, env/platform safety, nested shared-folder organization이 포함됩니다.

generic React architecture, Remix/TanStack Start project, docs-only summary, architecture boundary를 건드리지 않는 copy-only edit에는 quick safety check 이상으로 사용하지 않습니다. Pages Router-only project에서는 shared Next.js safety/platform checks를 적용하되 migration 요청이 없으면 App Router-only file conventions를 강제하지 않습니다.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Next.js project를 official docs와 labelled Hypercore/repo-local conventions에 맞춰 architecturally safe하게 유지. |
| Trigger | App Router, Pages Router, Server/Client boundaries, data/cache behavior, Server Actions, Route Handlers, Proxy, platform/env, shared folder layout이 포함된 Next.js project work. |
| Scope | touched project architecture, topic rule files, official references, validation notes, small reversible architecture fixes를 review/guide. |
| Authority | user/project instructions가 이 skill보다 우선. Current official Next.js docs가 framework behavior에서 local convention보다 우선. Safety policy는 risky runtime/auth/secret/import-boundary change를 차단. |
| Evidence | local package/config/router indicators, touched source paths, topic rules, official references, validation scripts, project check output. |
| Tools | local search/read/edit/validation commands 사용; API drift가 중요하면 current official docs 사용; destructive migrations, credentials, production side effects, broad codemods는 gate. |
| Output | rule classification, changed files, validation evidence, remaining risks, dated official-doc ambiguity notes를 포함한 Korean architecture decision/review. |
| Verification | touched surface 관련 `rules/validation.ko.md` checks와 이 skill folder 변경 시 `scripts/validate-nextjs-architecture-skill.mjs` 실행. |
| Stop condition | project mode 확인, applicable safety gates 통과, local conventions 적용 또는 defer, validation evidence 기록, unresolved API drift가 dated/source된 상태. |

</instruction_contract>

## 개요

코드 변경 전후에 공식 Next.js 아키텍처 규칙을 적용합니다. 먼저 대상이 Next.js 프로젝트인지 증명하고 App Router, Pages Router, 혼합 모드 중 무엇인지 식별합니다. 그다음 라우팅, Server/Client Component 경계, 데이터/캐시 동작, Server Actions, Route Handlers, Proxy, 플랫폼 설정에 필요한 최소 규칙만 적용합니다.

**official-first 규칙:** 프레임워크 동작은 현재 Next.js 문서가 기준입니다. 저장소 로컬 규칙이 Next.js보다 엄격하면 프레임워크 법칙이 아니라 로컬 규칙이라고 표시합니다.

**App Router 기본값:** `app/` 및 `src/app/` 작업에는 전체 규칙을 적용합니다. Pages Router-only 프로젝트에서는 사용자가 마이그레이션을 요청하지 않는 한 App Router 전용 파일 규칙을 강요하지 않고 공유 Next.js 플랫폼, env, 경계 검사를 적용합니다.

**mutation 기본값:** App Router UI에서 시작되는 쓰기는 Server Actions를 우선합니다. webhook, feed, CORS endpoint, public machine-readable endpoint, non-UI response처럼 HTTP-native 계약이 있는 경우 Route Handlers를 사용합니다.

**보안 기본값:** 모든 Server Action을 도달 가능한 POST entry point처럼 취급합니다. 입력 검증, 인증, 권한 확인, 최소 반환값 shaping을 action 또는 위임된 server-only layer 안에서 수행합니다.

## 빠른 Surface 선택기

| 작업이 이런 형태라면... | 기본 surface | 기본으로 피할 것 |
|---|---|---|
| App Router에서 form 또는 internal UI mutation 추가 | Server Action | `route.ts` RPC |
| webhook, feed, CORS endpoint, public API, XML, JSON, stream 추가 | Route Handler | Server Action |
| UI 초기 페이지 데이터 가져오기 | Server Component | client-first fetching |
| interactivity, browser API, client hook 추가 | 좁은 Client Component | root-level `'use client'` |
| Next.js 16+에서 반복 데이터/UI 캐시 | `cacheComponents` + `use cache` / `cacheTag` / `cacheLife` | 오래된 `fetch` 기본값 가정 |
| mutation 후 UI 갱신 | `updateTag`, `revalidateTag`, `revalidatePath`, `refresh`, redirect flow | 문서화되지 않은 freshness |
| 많은 request에서 render 전 redirect/rewrite | 먼저 `next.config.*`, 필요하면 Proxy | generic middleware로서 Proxy |
| Pages Router only이고 migration 요청 없음 | 공유 Next.js 검사 | App Router-only 파일 규칙 |

<activation_examples>

Positive:

- "Audit this Next.js App Router feature for Server/Client boundaries and cache correctness."
- "Refactor this form to use Server Actions instead of an internal route handler."
- "Add a Route Handler for a webhook and verify it follows the current Next.js docs."
- "Next.js 16 cacheComponents 기준으로 data fetching 규칙을 점검해줘."
- "Next.js App Router에서 src/lib/auth/session.ts와 src/services/billing/mutations.ts처럼 nested shared folders로 정리해줘."

Negative:

- "Create a generic React architecture guide."
- "Review a Remix or TanStack Start app."
- "Write marketing copy for a Next.js landing page without touching architecture."

Boundary:

- "Make a tiny copy-only text change in a Next.js page."
  아키텍처 경계가 영향받지 않으면 직접 편집으로 충분할 수 있지만, touched files는 빠른 boundary check를 거쳐야 합니다.
- "This repo is Pages Router only and I am not migrating to App Router."
  공유 Next.js platform, env, server/client safety checks를 적용하고 App Router-only file conventions는 완화합니다.

</activation_examples>

## Step 1: Project Validation

아키텍처 작업 전에 프로젝트와 router mode를 확인합니다:

```bash
rg -n '"next"' package.json
find . -maxdepth 3 \( -path './app' -o -path './src/app' -o -path './pages' -o -path './src/pages' \)
test -f next.config.ts -o -f next.config.mjs -o -f next.config.js
```

해석:

- `next` dependency 없음: 중지. 이 skill은 적용되지 않습니다.
- `app/` 또는 `src/app/`: App Router mode.
- App Router 없이 `pages/` 또는 `src/pages/`: shared Next.js mode.
- `app/`와 `pages/` 혼합: touched `app/` code에는 App Router 규칙을 적용하고, 요청 없이는 legacy migration을 피합니다.

## Step 2: 필요한 최소 Rule Set 읽기

**필수 첫 읽기:** `architecture-rules.md`.

그다음 touched surface에 필요한 rule file만 읽습니다:

- `rules/routes.md` — file conventions, segment rules, route groups, private folders, parallel/intercepted route 주의점
- `rules/project-structure.md` — top-level project shape, `src/`, shared code placement, nested `src/lib`, repo-local organization conventions
- `rules/execution-model.md` — Server/Client Components, `'use client'`, providers, serializable props, `server-only` / `client-only`
- `rules/data-fetching.md` — server-first reads, streaming, Cache Components, `use cache` / `use cache: remote` / `use cache: private`, cache tags, revalidation, dynamic rendering
- `rules/server-actions.md` — `use server`, forms, validation, auth/authz, DAL delegation, `updateTag` / revalidation / redirect ordering
- `rules/route-handlers.md` — `route.ts`, HTTP methods, caching intent, params, non-UI responses, CORS/webhooks
- `rules/platform.md` — env, `next.config.*`, `typedRoutes`, Proxy, route segment config, deployment-sensitive settings

drift-sensitive behavior는 먼저 `references/official/current-docs-2026-06-02.ko.md`, 그다음 `references/official/nextjs-docs.ko.md`도 확인합니다. browser-readable markdown이 필요하면 official pages를 `https://r.jina.ai/https://nextjs.org/docs/...`로 가져옵니다.

## Step 3: Pre-Change Gates

### Brownfield Adoption

- untouched legacy deviation을 기본 실패로 보지 않습니다.
- touched files의 safety, secret, auth, boundary issue는 즉시 차단합니다.
- broad migration이 필요하지 않다면 touched files를 규칙에 맞춥니다.

### Gate 1: Routing, File Conventions, and Project Structure

| 확인 | 규칙 |
|---|---|
| `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, `route.ts`가 유효한 segment 구조 밖에 있음 | 차단 |
| 같은 route segment에 `route.ts`와 `page.tsx`를 생성 | 차단 |
| route group을 URL 변경 수단처럼 사용 | 차단 |
| private implementation file을 `_folder` 대신 routable segment로 노출 | 차단 |
| nested domain/provider grouping이 touched code를 더 명확하게 하는데 shared `src/lib` / `src/services` organization을 flat/direct-leaf로 강제 | 경고. nested grouping 권장 |
| repo-local folder preference를 official Next.js law처럼 보고 | 차단 |
| parallel/intercepted routes를 layout slot 또는 hard-navigation 동작 검토 없이 추가 | 위험도에 따라 경고/차단 |

### Gate 2: Server and Client Boundaries

| 확인 | 규칙 |
|---|---|
| interactive component에 `'use client'` 없음 | 차단 |
| 필요 없이 tree 상단에 `'use client'` 추가 | 차단 |
| Client Component가 DB code, private env, `cookies()`, `headers()`, server-only helper import | 차단 |
| Server→Client props가 넓거나 secret-bearing 또는 non-serializable | 차단 |
| Provider가 필요한 범위보다 넓게 감쌈 | 경고 |

### Gate 3: Data Fetching, Cache, and Freshness

| 확인 | 규칙 |
|---|---|
| client-only 필요 없이 Client Component에서 초기 UI data fetch | 차단 |
| 캐시 동작이 우발적이거나 문서화되지 않았거나 오래된 기본값 기반 | 차단 |
| `cacheComponents` 활성 상태에서 uncached runtime data에 `use cache`, `connection()`, `loading.tsx`, `<Suspense>` 의도가 없음 | 차단 |
| `use cache` scope 안에서 `cookies()` / `headers()`를 읽고 serializable argument로 전달하지 않음 | 정당화된 experimental `use cache: private`를 명시적으로 쓰는 경우가 아니면 차단 |
| 새 App Router 작업에 `connection()` 대신 `unstable_noStore` 추가 | legacy code 유지보수가 아니면 차단 |
| mutation에 `updateTag`, `revalidateTag`, `revalidatePath`, `refresh`, redirect freshness 또는 문서화된 대안이 없음 | 차단 |

### Gate 4: Server Actions

| 확인 | 규칙 |
|---|---|
| Server Action이 맞는 internal UI mutation을 `route.ts`로 구현 | HTTP semantics가 필요하지 않으면 차단 |
| Action이 `FormData`, params, headers, search params를 검증/재확인 없이 신뢰 | 차단 |
| Action이 page-level auth check에만 의존 | 차단 |
| Action이 raw DB row 또는 broad internal object 반환 | 차단 |
| 필요한 revalidation/tag update 전 `redirect()` 실행 | 차단 |

### Gate 5: Route Handlers and Proxy

| 확인 | 규칙 |
|---|---|
| UI-only flow에 Route Handler를 기본 internal RPC로 사용 | 차단 |
| Route Handler 안에서 `NextResponse.next()` 사용 | 차단 |
| correctness가 중요한데 Route Handler caching을 명시하지 않고 가정 | 차단 |
| Route Handler body 안에 `use cache`를 직접 두고 helper function으로 분리하지 않음 | 차단 |
| 새 `middleware.ts`를 추가하고 `proxy.ts`를 쓰지 않음 | 차단 |
| `next.config.*`, headers, redirects, rewrites, render-time logic으로 충분한데 Proxy 추가 | 차단 |
| Proxy matcher가 없거나 너무 넓거나 metadata/static surface 제외가 필요할 때 누락 | 차단 |

### Gate 6: Platform and Environment

| 확인 | 규칙 |
|---|---|
| `.env*` files가 `src/`에서 load된다고 가정 | 차단 |
| Client code가 non-`NEXT_PUBLIC_` env vars 읽음 | 차단 |
| runtime client env를 build-time public env처럼 취급 | 차단 |
| `cacheComponents` 활성 상태에서 v16에서 제거된 route segment config options(`dynamic`, `revalidate`, `fetchCache`) 사용 | 차단 |
| `runtime: 'edge'` 또는 Proxy runtime 가정을 platform compatibility 확인 없이 변경 | 차단 |
| deployment-sensitive Server Action origin/config 변경이 문서화되지 않음 | 위험도에 따라 경고/차단 |

## Step 4: Implementation Policy

local, reversible issue는 자동 수정합니다: client boundary 좁히기, server-only code를 DAL/helper 뒤로 이동, `server-only` 추가, freshness 누락 보완, 작은 UI-only `route.ts` mutation을 Server Action으로 대체, Proxy matcher 축소, cache intent 명확화.

broad migration은 자동 적용하지 않습니다: Pages→App Router 대규모 rewrite, sweeping cache model change, 대량 Route Handler→Server Action conversion, deployment-sensitive origin/encryption 변경.

## Step 5: Post-Change Verification

claim을 증명하는 가장 작은 프로젝트별 검사를 실행하고 evidence를 보고합니다:

1. project mode가 edited surface와 일치
2. special files가 유효한 segment에 있고 `page`/`route` 충돌 없음
3. shared 및 segment-local folders가 project-structure rules를 따르고, new touched shared code는 explicit exception이 없으면 nested `src/lib` / `src/services` grouping을 사용
4. `'use client'` boundary가 좁고 안전함
5. client code가 server-only modules 또는 private env를 import하지 않음
6. data/cache strategy가 명시적이고 현재 docs와 호환
7. mutation freshness가 `updateTag`, `revalidateTag`, `revalidatePath`, `refresh`, redirect flow 또는 문서화된 대안을 사용
8. Route Handler와 Proxy 사용이 여전히 정당함
9. `next.config.*`, env loading, route segment config, deployment settings가 일관됨

이 skill folder 자체는 다음을 실행합니다:

```bash
node skills/nextjs-architecture/scripts/validate-nextjs-architecture-skill.mjs
```

## Stop Condition

Next.js mode가 확인되고, touched surface가 관련 gate를 통과하며, fresh verification output이 있고, 남은 repo-local convention 또는 risk가 명시적으로 보고되면 완료합니다.
