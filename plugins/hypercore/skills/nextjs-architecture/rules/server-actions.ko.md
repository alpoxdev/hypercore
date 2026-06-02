# Server Actions

> `use server` 기반 mutation, validation, freshness, security 규칙.

---

## Core Rule

모든 Server Action을 reachable POST entry point처럼 취급합니다.

App Router에서 앱 UI에서 시작된 mutation의 기본 surface는 Server Actions입니다.

즉:

- 입력 검증
- 호출자 인증
- resource access 권한 확인
- UI에 필요한 최소 반환값만 제공
- 영향을 받은 데이터를 의도적으로 refresh 또는 revalidate

page-level UI gating만 신뢰하지 않습니다.

## Placement

- 재사용 가능한 actions, 특히 Client Components로 import되는 actions는 top-level `'use server'` 전용 파일을 사용합니다.
- 특정 route에 강하게 묶여 있고 closure가 의도적이면 Server Component 내부 inline action도 허용됩니다.
- 반복되는 DB/auth logic은 server-only DAL 또는 helper로 이동합니다.
- internal app UI에서 시작된 쓰기이고 HTTP-native contract가 필요 없다면 `route.ts`보다 Server Action을 우선합니다.

## Forms and Client Calls

- Forms는 `action` attribute로 Server Actions를 호출하고 `FormData`를 받을 수 있습니다.
- authoritative checks에는 server-side validation을 사용합니다. client validation은 UX 보조일 뿐입니다.
- UI에 필요할 때만 좁은 Client Component wrapper에서 `useActionState`, pending state, optimistic updates, transitions를 사용합니다.

## Freshness APIs

- read-your-own-writes cache expiration에는 Server Actions 안에서 `updateTag`를 사용합니다.
- stale-while-revalidate 동작이 허용되면 `revalidateTag(tag, 'max')`를 사용합니다.
- path-based invalidation에는 `revalidatePath`를 사용합니다.
- tag invalidation 없이 current client router를 refresh해야 하면 Server Action 안에서 `next/cache`의 `refresh`를 사용합니다.
- 필요한 invalidation은 `redirect()` 전에 호출합니다.

## Hard Rules

| 확인 | 규칙 |
|---|---|
| Action이 `FormData`, params, headers, search params를 직접 신뢰 | 차단 |
| Action이 page-level auth redirect/gating에만 의존 | 차단 |
| Action이 raw DB records 또는 internal objects 반환 | 차단 |
| Action이 form/event/transition path가 아니라 render 중 mutation | 차단 |
| Action이 반복 domain authorization logic을 매번 inline 수행 | 경고. DAL로 이동 |
| 필요한 `updateTag`, `revalidatePath`, `revalidateTag` 전에 `redirect()` 사용 | 차단 |

## DAL Guidance

권장 분리:

- Action: input edge, auth re-check, mutation orchestration, freshness, redirect
- DAL/server-only module: DB access, authorization logic, DTO shaping, sensitive business rules

## Security Notes

- auth는 action에 넘겨진 trusted client token이 아니라 cookies 또는 headers에서 읽습니다.
- Server Action return values는 client로 serialize되어 돌아가므로 최소화합니다.
- 비용이 큰 actions에는 rate limiting과 abuse controls를 고려합니다.
- multi-proxy 또는 reverse-proxy setup에서는 `serverActions.allowedOrigins` 필요성을 확인합니다.

## Review Checklist

- input validation 존재
- auth/authz가 action 내부 또는 delegated server-only layer에서 재확인됨
- return values 최소화
- 필요할 때 redirect 전 freshness 수행
- 반복 domain logic이 여러 actions에 중복되지 않음
