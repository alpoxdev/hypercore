# 아키텍처 규칙 참조

> App Router를 기본 모드로 하는 Next.js 프로젝트용 공식 우선 통합 규칙 세트입니다.

Brownfield 적용 규칙: 손대지 않은 레거시 `pages/` 코드는 자동 실패가 아닙니다. 안전, 경계, 데이터 누출 문제는 특히 변경한 코드에서 즉시 차단합니다.

---

## 프로젝트 모드

| 모드 | 지표 | 적용 |
|------|------------|-------------|
| App Router | `app/` 또는 `src/app/` | 전체 skill 적용 |
| Shared Next.js | `pages/`만 있음 | shared platform, env, boundary, safety rules만 적용 |
| Mixed | `app/`와 `pages/`가 모두 있음 | 변경한 `app/` 코드에는 App Router rules 적용, 요청 없이는 broad migration 회피 |

---

## 핵심 원칙

- 로컬 취향보다 공식 Next.js 문서를 우선합니다.
- 기본은 Server Components로 두고 실제 interaction leaf에만 `'use client'`를 추가합니다.
- Internal UI mutation과 form에는 Server Actions를 선호합니다.
- Privileged data access는 server-only modules 또는 DAL에 둡니다.
- Cache behavior는 우연이 아니라 의도적으로 만듭니다.
- 모든 Server Action은 외부에서 도달 가능하다고 보고 내부에서 다시 auth/authz를 수행합니다.
- Route Handlers는 HTTP-native concerns에 사용하고 기본 internal mutation surface로 쓰지 않습니다.
- Redirects, rewrites, headers, render-time logic으로 부족할 때만 Proxy를 사용합니다.

---

## 금지

| 범주 | 금지 사항 |
|----------|-----------|
| Routing | 같은 route segment에 `page.tsx`와 `route.ts`를 함께 둠 |
| Client Boundary | 실제 interaction 필요 없이 넓은 top-level `'use client'` 사용 |
| Secrets | Private env, DB clients, server-only modules를 Client Components로 import |
| Data Safety | Server Components에서 broad raw records를 Client Components로 전달 |
| Cache Intent | 이유를 이해하지 못한 채 implicit caching 또는 dynamic rendering에 의존 |
| Server Actions | Client input 신뢰, auth/authz 생략, raw internal objects 반환 |
| Side Effects | Server Action 또는 explicit event path 대신 render 중 mutation |
| Route Handlers | Server Action 또는 Server Component가 맞는 surface인데 `route.ts`를 기본 internal RPC로 사용 |
| Route Handlers | Route Handler 안에서 `NextResponse.next()` 사용 |
| Proxy | `next.config.*` 또는 render-time logic으로 충분한데 `proxy.ts` 추가 |
| Env Setup | `.env*` files가 `src/`에서 load된다고 기대 |

---

## 필수

| 범주 | 필수 사항 |
|----------|----------|
| Validation | 편집 전 Next.js mode 확인 |
| Routing | Special files를 valid route segments에 배치 |
| Boundaries | Client Components를 좁게 유지하고 props를 serializable하게 유지 |
| Safety | Privileged modules에 `server-only` 또는 동등하게 명확한 server boundary 사용 |
| Freshness | Mutation 후 revalidate하거나 다른 방식으로 data refresh |
| Auth | 각 Server Action 안에서 authentication과 authorization 재확인 |
| Platform | Env handling과 config를 명시적으로 유지 |
| Reporting | Repo-local conventions를 framework law가 아니라 conventions로 label |

---

## 결정 순서

1. App Router surface인가, legacy Pages Router surface인가?
2. 이 코드는 server-only, client-interactive, shared 중 무엇인가?
3. HTML/UI rendering, internal UI mutation, HTTP-native endpoint 중 무엇이 필요한가?
4. Read는 cached, dynamic, explicitly revalidated 중 무엇이어야 하는가?
5. Env, Proxy, Server Action origins 같은 deployment-sensitive config에 영향을 주는가?

기본 surface 순서:

1. Initial reads와 server-rendered UI에는 Server Components
2. Internal UI writes와 forms에는 Server Actions
3. HTTP-native endpoints에는 Route Handlers
4. Pre-render interception이 정말 필요할 때만 Proxy

---

## Rule Files

- `rules/routes.md`
- `rules/execution-model.md`
- `rules/data-fetching.md`
- `rules/server-actions.md`
- `rules/route-handlers.md`
- `rules/platform.md`
- `references/official/nextjs-docs.md`

Active change를 다루는 가장 작은 set을 읽되 항상 여기서 시작합니다.
