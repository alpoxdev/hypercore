# TanStack API Drift Notes

- last_verified_at: 2026-04-30
- purpose: Core skill rules가 stale examples에 과적합하지 않도록 official-doc conflicts와 source-priority decisions를 기록합니다.

## Source Priority

1. 정확한 API area에 대한 current canonical guide.
2. 정확한 symbol에 대한 current API/reference page.
3. Installed project의 package types/source.
4. Rename 또는 migration을 설명하는 recent release notes.
5. Examples, comparisons, migration guides, blog posts.

Sources가 충돌하면 편한 쪽을 조용히 선택하지 않습니다. Exact date와 source links로 conflict를 기록합니다.

## `.inputValidator()` vs `.validator()`

2026-04-30 기준 결정:

- Start server functions의 canonical 형태는 `.inputValidator()`로 취급합니다.
- 일부 current docs의 `.validator()` examples는 package types가 다르게 증명하기 전까지 stale 또는 lower-priority로 취급합니다.
- 실제 project를 편집할 때는 broad migration 전에 installed `@tanstack/react-start` version을 확인합니다.

Evidence:

- Canonical Server Functions guide는 `.inputValidator(...)`를 사용합니다: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>
- GitHub v1.145.1 release notes에는 “Rename validator to inputValidator in fetch functions”가 포함됩니다: <https://github.com/TanStack/router/releases/tag/v1.145.1>
- Server Components와 comparison/migration content를 포함한 일부 current pages에는 아직 `.validator(...)` snippets가 있습니다: <https://tanstack.com/start/latest/docs/framework/react/guide/server-components>

Skill implication:

- `rules/services.md`는 project-local type check가 installed version에서 필요함을 증명하지 않는 한 새 `.validator(...)` usage를 block해야 합니다.
- Core `SKILL.md`는 긴 API history를 반복하지 말고 여기로 안내합니다.

## Search validation and Zod adapters

2026-04-30 기준 결정:

- Zod v4는 `validateSearch`에서 schema를 직접 사용할 수 있습니다.
- Zod v3는 `@tanstack/zod-adapter`와 `zodValidator`/`fallback`을 사용해야 합니다.
- Project가 adapter를 hypercore convention으로 양쪽 version에 표준화할 수는 있지만, 공식 docs보다 엄격하다고 label해야 합니다.

Evidence:

- <https://tanstack.com/router/latest/docs/how-to/validate-search-params>
- <https://tanstack.com/router/latest/docs/how-to/setup-basic-search-params>

## Import protection defaults

2026-04-30 기준 결정:

- Import protection은 Start에서 기본 활성화됩니다.
- Database/server/client 같은 directories 또는 ORM clients 같은 packages에 additional deny rules가 필요하면 explicit config가 여전히 필요합니다.
- Import protection 비활성화는 명시 요청이 없는 한 blocking safety issue입니다.

Evidence: <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection>

## Official vs Hypercore routing structure

2026-04-30 기준 결정:

- Router는 flat, directory, mixed route file structures를 지원합니다.
- Hypercore의 route-directory preference는 maintainability를 위한 local convention이며 official TanStack behavior로 설명하면 안 됩니다.

Evidence: <https://tanstack.com/router/latest/docs/routing/file-based-routing>
