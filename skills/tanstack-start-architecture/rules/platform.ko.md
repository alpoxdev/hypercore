# Platform Setup

> Router, env, alias, 운영 인접 설정 규칙

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| `src/router.tsx`가 fresh-instance `getRouter()` export | Official | missing setup 차단 |
| server/client env boundary | Safety policy | secret leak 차단 |
| non-trivial app runtime env validation | Hypercore convention + Safety policy | warn 또는 scaffold 추가 |
| Vite version-aware path alias | Hypercore convention | touched code에서 수정 |

---

## Router 설정

- `src/router.tsx`는 반드시 `getRouter()`를 export해야 합니다
- `getRouter()`는 호출할 때마다 새로운 router instance를 생성해서 반환해야 합니다
- `scrollRestoration`, preload 기본값, cache 설정 같은 router-wide 동작은 여기서 설정합니다

---

## Environment 규칙

- 클라이언트에서 안전한 env는 public prefix 규칙에 맞춰 `import.meta.env`로 접근합니다
- 서버 전용 env는 `process.env`에 두고 서버 경계 뒤에 둡니다
- typed env 접근이 필요하면 `src/env.d.ts`를 추가합니다
- 필수 secret/URL은 runtime validation을 둡니다

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
