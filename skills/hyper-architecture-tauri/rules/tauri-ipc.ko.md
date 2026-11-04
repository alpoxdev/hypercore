# Tauri IPC 경계

> 이 스킬에서 React/TanStack 프론트엔드와 Tauri Rust 사이 통신을 추가, 검토 또는 테스트할 때 읽습니다.

## 근거와 용어

**공식 사실.** Tauri command는 프런트엔드에서 호출하며 값 또는 오류를 반환할 수 있고, event는 단방향 알림을 전달하며, channel은 Rust에서 프런트엔드로 순서가 보장된 데이터를 전송합니다. [Tauri v2 근거 원장](../references/official/tauri-v2-2026-07-30.ko.md), [프런트엔드에서 Rust 호출](https://v2.tauri.app/develop/calling-rust/), [Rust에서 프런트엔드 호출](https://v2.tauri.app/develop/calling-frontend/)을 참조합니다. 링크된 페이지는 2026-07-30에 근거로 확인했으며 불변 API 계약이 아닙니다. 버전 의존 변경 전에는 원장과 최신 공식 문서를 다시 확인합니다.

**프로젝트 규약.** *native adapter*는 `invoke`, `listen`, `Channel` 또는 다른 `@tauri-apps/api/*` native API를 import할 수 있는 유일한 프론트엔드 모듈입니다. 이 모듈은 직렬화/역직렬화, 런타임 검증, 오류 정규화 및 취소 의미를 소유합니다. route, route loader, component 및 표현용 hook은 native API를 직접 호출하지 않고 domain/query helper를 호출합니다.

**안전 정책.** IPC는 내부 편의 함수가 아니라 권한 경계입니다. Rust command는 모든 프론트엔드 인자와 event 유래 값을 신뢰할 수 없는 입력으로 처리해야 합니다.

---

## 소유권과 타입 계약

native domain마다 명시적인 프론트엔드 adapter 하나를 둡니다. 요청/응답 DTO는 adapter 가까이에 두고 경계에서 같은 이름의 필드를 사용합니다. 애플리케이션 코드에 범용 `invoke<T>()` helper를 노출하지 않습니다.

```text
src/platform/tauri/settings/
  settings.dto.ts             # 입력/출력 schema와 TypeScript type
  settings.native.ts          # 유일한 invoke/listen 구현
src/modules/settings/
  queries/settings.queries.ts # TanStack Query option factory
  mutations/settings.ts       # write와 invalidation policy
src-tauri/src/
  commands/
    mod.rs
    settings.rs           # command handler와 경계 검증
  dto/
    settings.rs           # 직렬화 가능한 요청/응답/오류 DTO
```

기존 프로젝트 구조에 맞춰 경로를 조정하고 병렬 폴더는 만들지 않습니다. 핵심은 이 정확한 트리가 아니라 소유권입니다.

```ts
// src/platform/tauri/settings/settings.native.ts
import { invoke } from '@tauri-apps/api/core'
import { z } from 'zod'

export const readSettingsOutput = z.object({ theme: z.enum(['light', 'dark']) })
export type Settings = z.infer<typeof readSettingsOutput>

export async function readSettings(): Promise<Settings> {
  const output = await invoke<unknown>('settings_read')
  return readSettingsOutput.parse(output)
}
```

- **규약:** domain별로 그룹화한 서술적 command 이름(예: `settings_read`, `settings_update`)을 사용하고, 여러 필드 입력은 이름 있는 object로 전달합니다. 정확한 Rust/JS 이름 규칙을 명시하며 암묵적인 대소문자 변환에 의존하지 않습니다.
- **규약:** 형식이 잘못된 값이 애플리케이션 state에 도달할 수 있으면 프론트엔드 경계에서 신뢰할 수 없는 외부 payload를 parse합니다. 프론트엔드가 먼저 검증해도 Rust가 강제 측입니다.
- **규약:** Rust persistence, OS, plugin type이 아닌 안정적이고 직렬화 가능한 응답 DTO를 반환합니다. `any`, string 기반 오류 throw, `std::io::Error` text 누출을 사용하지 않습니다.
- **안전 정책:** frontend DTO에 token, 권한 확인이 필요한 filesystem path, capability 결정 또는 권한 있는 default를 두지 않습니다.

작은 공개 code 집합을 가진 구조화된 오류를 정의합니다. 내부 실패는 안전한 message로 매핑하고, correlation ID나 diagnostic cause는 제품의 승인된 관측 정책이 허용할 때만 붙입니다.

```rust
#[derive(serde::Serialize)]
#[serde(rename_all = "camelCase")]
pub struct NativeError {
    pub code: String,
    pub message: String,
}

type CommandResult<T> = Result<T, NativeError>;
```

**안전 정책:** `code`는 프로그램 흐름용이고 `message`는 사용자에게 안전해야 하며, 어느 필드에도 secret, raw SQL, local path, authorization state 또는 backend response body를 넣지 않습니다. 보호된 진단 로그는 프로젝트의 승인된 logging 정책 아래 native 측에만 남깁니다.

---

## Rust command module과 state

작은 domain module에서 command를 등록하고, 한 곳에서 조합이 보이게 합니다. handler는 요청 DTO로 역직렬화하고, 형식과 한도를 검증하며, 현재 app/session context에서 작업을 인가하고, domain service를 호출한 다음 public DTO로 오류를 매핑해야 합니다. OS, plugin, database 작업은 `#[tauri::command]` handler에 넣지 말고 service interface 뒤에 둡니다.

```rust
// src-tauri/src/commands/settings.rs
#[tauri::command]
pub async fn settings_update(
    input: UpdateSettingsInput,
    state: tauri::State<'_, AppState>,
) -> CommandResult<SettingsDto> {
    input.validate()?;
    state.authorize_settings_write()?;
    state.settings.update(input).await.map_err(NativeError::from)
}
```

**공식 사실.** Tauri managed state는 애플리케이션에 등록하고 command에서 `State`로 접근할 수 있습니다. [State Management](https://v2.tauri.app/develop/state-management/)을 참조하세요(2026-07-30 접근; 위 근거 원장 주의사항 적용).

- **규약:** `AppState` 소유권과 동기화를 의도적으로 정의합니다. 데이터와 platform API에 맞춰 `Mutex`, `RwLock`, atomic 또는 message passing을 사용하고 변경 가능한 global state를 사용하지 않습니다.
- **안전 정책:** blocking mutex, `std::sync` guard, database transaction 또는 기타 exclusive guard를 `.await` 동안 절대 유지하지 않습니다. lock 유지 시간은 최소화하고, 여러 lock은 순서를 정하며, blocking 작업은 프로젝트 runtime 설계에 따라 async executor 밖으로 옮깁니다.
- **안전 정책:** 변경 가능한 managed state에는 명시적인 동시성 불변식(single writer, keyed lock, actor, transaction 또는 동등한 방식)이 필요하며, command가 durable 또는 security-sensitive data를 변경하면 경합 작업 테스트가 필요합니다.
- **규약:** command handler는 domain error를 한 번만 변환합니다. 무한 retry, 잘못된 입력의 조용한 보정, frontend가 보낸 role에 따른 authorization 결정을 하지 않습니다.

---

## command, event, channel 선택

| 필요 | 사용 | 계약 |
|---|---|---|
| 하나의 최종 성공/오류 결과가 있는 요청 | adapter를 통한 command | 타입된 입력, 타입된 출력, 구조화된 오류; caller가 pending UI를 소유합니다. |
| best-effort 알림 또는 lifecycle signal | event | 이름 있는 payload schema, 명시적 producer/consumer, listener cleanup. authorization 결정이나 요청/응답 protocol로 사용하지 않습니다. |
| Rust에서 나오는 순서 있는 다중 값 progress/stream | `Channel<T>` | 타입된 item schema, completion/error 동작, bounded production, consumer lifecycle. |

**공식 사실.** Tauri event system은 프론트엔드와 Rust 사이 event를 통신하고, channel은 Rust에서 프론트엔드로 순서 있는 데이터를 전송하도록 설계되었습니다. [Events](https://v2.tauri.app/develop/calling-frontend/)와 [Channels](https://v2.tauri.app/develop/calling-rust/#channels)를 참조하세요(2026-07-30 접근; 위 근거 원장 주의사항 적용).

**규약:** mutation의 권위 있는 결과는 command를 선호하고, 이후 progress 또는 invalidation에만 event/channel을 사용합니다. subscription 전에 이미 발생했을 수 있는 event를 route가 기다리게 하지 않습니다. event를 secret-bearing transport로 사용하지 않습니다.

모든 event listener는 소유 lifecycle cleanup 중 unlisten 함수를 보관하고 호출합니다. 안정적인 owner마다 한 번 subscribe하며 render 중이나 query function에서 listener를 등록하지 않습니다.

```ts
useEffect(() => {
  let unlisten: (() => void) | undefined
  let disposed = false

  void listen<Progress>('export-progress', (event) => {
    if (!disposed) updateProgress(event.payload)
  }).then((stop) => {
    if (disposed) stop()
    else unlisten = stop
  })

  return () => {
    disposed = true
    unlisten?.()
  }
}, [updateProgress])
```

**안전 정책:** event/channel payload가 신뢰된 프론트엔드 state를 변경하기 전에 검증합니다. 완료, window close, route teardown 및 React Strict Mode 재마운트가 duplicate listener나 consumer 없는 producer를 남기지 않아야 합니다.

---

## TanStack Query와 취소

TanStack Query는 query function에 `AbortSignal`을 전달합니다. 이 signal을 abort하면 query의 client-side 소비는 취소하지만, Tauri가 이미 받은 Rust command를 자동 취소하지는 **않습니다**. query가 더 이상 observe되지 않는다는 이유만으로 cancellation support가 있다고 말하지 않습니다.

```ts
export function settingsQueryOptions() {
  return queryOptions({
    queryKey: ['settings'],
    queryFn: async ({ signal }) => {
      signal.throwIfAborted()
      const settings = await readSettings()
      signal.throwIfAborted()
      return settings
    },
  })
}
```

- **규약:** signal은 adapter 호출 전후 stale UI 작업을 막는 데 사용하고, Query가 cache invalidation을 관리하게 합니다.
- **안전 정책:** 비용이 크거나 destructive 또는 장기 실행 native 작업은 명시적인 job ID와 command/channel/event lifecycle, cooperative native cancellation command를 설계합니다. idempotency, ownership, cleanup 및 cancellation-completion race 결과를 정의합니다.
- **규약:** query function은 read입니다. route loader/component는 query options와 mutation을 사용하며 native command를 직접 호출하지 않습니다. mutation은 권위 있는 command 결과 뒤에만 관련 query key를 invalidate 또는 update합니다.

---

## IPC 검토 gate

적용되는 모든 gate를 충족할 때까지 변경을 막습니다.

1. **경계 gate:** route, component, loader 또는 shared UI utility가 Tauri native API를 직접 import하지 않으며, 타입된 domain adapter가 이를 소유합니다.
2. **계약 gate:** 각 command에는 이름 있는 input/output DTO, 필요한 frontend parsing, Rust validation, 구조화된 public error 및 명시적 serialization/naming rule이 있습니다.
3. **권한 gate:** Rust command는 UI 노출 여부, cached state 또는 frontend claim과 독립적으로 신뢰할 수 없는 input을 validate하고 authorize합니다.
4. **lifecycle gate:** 모든 event/channel에는 owner, payload schema, cleanup path, completion behavior가 있고 remount 시 duplicate subscription이 없습니다.
5. **동시성 gate:** 변경 가능한 managed state에는 문서화된 synchronization invariant가 있으며 `.await`를 넘는 lock 또는 transaction이 없습니다.
6. **취소 gate:** 명시적 cooperative native protocol이 구현되고 테스트되지 않은 native 작업을 abortable이라고 설명하지 않습니다.
7. **보안 gate:** adapter를 노출하기 전에 [security.md](security.md)가 요구하는 custom command capability/permission/scope 검토를 완료합니다.

실패한 gate를 type assertion, 넓은 catch, frontend-only check 또는 event 기반 우회로 통과시키지 않습니다.

## Sources

> 링크 확인 2026-07-30.

| 주장 | 출처 |
|---|---|
| Frontend-to-Rust IPC 표면의 command, event, channel, managed `State` | [tauri-v2-2026-07-30.ko.md](../references/official/tauri-v2-2026-07-30.ko.md); <https://v2.tauri.app/develop/calling-rust/>; <https://v2.tauri.app/develop/calling-frontend/>; <https://v2.tauri.app/develop/state-management/> |
| Query가 넘긴 `AbortSignal`은 Tauri가 이미 수락한 Rust command를 취소하지 않는다 | [tanstack-vite-react-2026-07-30.ko.md](../references/official/tanstack-vite-react-2026-07-30.ko.md); <https://tanstack.com/query/latest/docs/framework/react/guides/query-cancellation>; [tauri-v2-2026-07-30.ko.md](../references/official/tauri-v2-2026-07-30.ko.md) |
| DTO/error 형태, listener cleanup, managed state 동시성 요구 | 이 파일의 규약과 안전 정책; 외부 출처 없음 |
