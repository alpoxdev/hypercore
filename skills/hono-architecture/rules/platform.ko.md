# 플랫폼 설정

> adapter와 runtime 관심사는 edge에 격리

---

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
