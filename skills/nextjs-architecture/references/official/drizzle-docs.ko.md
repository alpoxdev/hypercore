# Official Drizzle Docs Summary

> Next.js architecture decision에 필요한 version-sensitive Drizzle facts입니다. package-specific import paths 또는 migration commands를 변경하기 전 official docs를 다시 확인합니다.

last_verified_at: 2026-07-04

## Source URLs

- `https://orm.drizzle.team/docs/sql-schema-declaration`
- `https://orm.drizzle.team/docs/drizzle-config-file`
- `https://orm.drizzle.team/docs/migrations`
- `https://orm.drizzle.team/docs/drizzle-kit-generate`
- `https://orm.drizzle.team/docs/drizzle-kit-migrate`
- `https://orm.drizzle.team/docs/drizzle-kit-push`
- `https://orm.drizzle.team/docs/drizzle-kit-pull`
- `https://orm.drizzle.team/docs/relations`
- `https://orm.drizzle.team/docs/rqb`
- `https://orm.drizzle.team/docs/perf-serverless`
- `https://orm.drizzle.team/docs/zod`
- `https://orm.drizzle.team/docs/valibot`
- `https://orm.drizzle.team/docs/typebox`
- `https://orm.drizzle.team/docs/arktype`
- `https://orm.drizzle.team/docs/effect-schema`

## Official Facts

1. Drizzle schema는 TypeScript로 선언되며 queries와 migrations의 source of truth 역할을 합니다.
2. Schema는 single-file 또는 multi-file일 수 있습니다. Tables, enums, relations, other models는 Drizzle Kit이 import할 수 있도록 export되어야 합니다.
3. `drizzle.config.ts`는 `schema`로 schema file/folder/glob/array를, `out`으로 migration output folder를 지정합니다.
4. `out` 기본값은 `drizzle`입니다.
5. codebase-first committed SQL flow는 `drizzle-kit generate` 이후 `drizzle-kit migrate`입니다.
6. `drizzle-kit push`와 `drizzle-kit pull`은 schema push 및 database-first/introspection workflows를 위한 documented alternatives입니다.
7. Drizzle serverless performance guidance는 runtime이 module scope를 재사용할 수 있을 때 connection 및 prepared statement objects를 handler scope 밖에 선언하라고 권장합니다.
8. Drizzle relations와 RQB는 relational queries를 사용할 때 관련 schema/tables/relations가 `drizzle()` initialization에서 사용 가능해야 합니다.
9. Drizzle validation integrations에는 zod, valibot, typebox, arktype, typebox-legacy, effect-schema가 포함됩니다.

## Next.js Architecture Implications

- `src/db/schema`, `src/db/repositories`, `src/db/client.server.ts`는 Hypercore local conventions이며 Drizzle 또는 official Next.js requirements가 아닙니다.
- project는 discoverable schema path 하나를 선택하고 `drizzle.config.ts`가 그 경로를 가리키게 해야 합니다.
- DB client creation과 repository helpers는 server-only modules에 둡니다. Client Components와 client hooks는 import하면 안 됩니다.
- Server Components는 server-only DAL/repository functions를 직접 호출할 수 있습니다. Route Handlers는 internal data bridge가 아니라 HTTP-native endpoints에 사용합니다.
- Drizzle validation integrations로 insert/update schemas를 derive하더라도 Server Actions는 Drizzle writes 전에 input validation과 auth/authz 재확인을 계속 수행해야 합니다.
- migration folders 또는 scripts를 변경하기 전에 repo가 `generate` + `migrate`, `push`, `pull`, 다른 migration policy 중 무엇을 쓰는지 기록합니다.

## Drift Watchlist

- 정확한 Drizzle Kit CLI command names와 config properties는 installed `drizzle-kit` version에 맞춰 다시 확인합니다.
- serverless, Edge, Neon, D1, Turso/libSQL, Postgres connection code 변경 전 dialect-specific driver imports와 runtime support를 다시 확인합니다.
- 새 generated schemas를 추가하기 전 validation integration package names와 generation APIs를 다시 확인합니다.

## Sources

> 링크 확인 2026-07-04, 이 파일 자체의 `last_verified_at` 표기가 가진 날짜입니다. 이 snapshot에는 별도의 page 검증 날짜가 없어 그 표기를 이 파일의 최종 검토 날짜로 사용합니다. 이번 pass에서 페이지를 다시 가져오지 않았고, 위에 나열한 URL 밖의 출처는 주장하지 않습니다.

| 주장 | 출처 |
|---|---|
| 위 "Official Facts"에 기록한 Drizzle 동작 | "Source URLs"에 나열한 `orm.drizzle.team` 문서 페이지 |
| 위 "Next.js Architecture Implications"의 배치·경계 지침 | 같은 Drizzle 페이지와 Next.js server-boundary 규칙을 담은 `references/official/nextjs-docs.md`. `src/db/...` 명명은 Hypercore local convention이며 official requirement가 아닙니다 |
