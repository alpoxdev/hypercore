# 플랫폼 설정

> adapter와 runtime 관심사는 edge에 격리

---

## Stable runtime 기준

2026-08-04 확인 기준 Hono는 4.13.0입니다. `@hono/node-server` 2.1.0은 Node `>=20`과 Hono `^4`를 요구하며 package manifest가 오래된 Hono Node guide 문구보다 엄격합니다. Installed package metadata와 선택한 runtime의 최신 공식 guide가 우선합니다.

- Cloudflare/Deno/Bun runtime은 일반적으로 Fetch-compatible app entry를 제공하고 Node는 공식 adapter를 사용합니다.
- `app.fetch` 또는 reusable Hono app을 process startup, listener, WebSocket server, static-file root, shutdown hook과 분리합니다.
- Node raw request/response API, Cloudflare `executionCtx`/binding, provider-specific wait-until behavior를 adapter capability로 취급합니다.
- 가능하면 startup에서 environment configuration을 검증합니다. Secret을 client-visible config, log, generated OpenAPI example에 넣지 않습니다.
- Streaming, WebSocket, static file, raw API, execution context, provider binding을 사용하면 runtime adapter를 test합니다. `app.request()`만으로 충분하지 않습니다.
- 명시적 scope와 provider-specific verification 없이 adapter, deployment manifest, compatibility date, runtime version을 바꾸지 않습니다.
## 규칙

- runtime adapter 코드는 `src/index.ts`, `src/server.ts`, `src/worker.ts` 같은 entry 파일에 둡니다
- route module은 가능하면 adapter에 독립적으로 유지합니다
- 환경 bindings/config는 명시적으로 타입화합니다
- Database binding과 connection string은 feature handler가 아니라 platform/config boundary를 통해 읽습니다
- Runtime에 맞는 database client를 사용합니다. D1 같은 Workers binding은 Hono `Bindings` / `c.env`, Node/Bun server runtime은 validated config를 사용합니다
- `showRoutes()` 같은 helper는 dev-only
- `basePath()` 또는 API version prefix는 composition boundary에서 의도적으로 정의합니다

## 리뷰 체크리스트

- adapter import가 route module에 섞이지 않음
- runtime 전용 관심사가 격리됨
- config와 bindings가 타입화됨
- Database client setup이 runtime과 일치하고 route module 밖에 있음
- debug helper가 실수로 켜져 있지 않음

## Sources

> 이 파일에는 외부 출처를 사용하지 않았습니다. 공식 Hono 동작은 `references/official/hono-docs.ko.md`에 위임합니다(last verified 2026-08-04). 저장소 로컬 링크 확인 2026-09-21.
