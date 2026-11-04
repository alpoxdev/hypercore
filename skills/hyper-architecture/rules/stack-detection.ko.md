# 스택 감지

> 대상마다 파일로 스택을 정하고, 하나의 우선순위를 적용하며, 추측하지 않고 멈춥니다.

## 1. 대상 찾기

- 대상은 패키지 루트입니다. 자체 `package.json`, 자체 `pubspec.yaml`, 또는 자체 `Cargo.toml`이 있는 디렉터리이며, 워크스페이스가 없으면 저장소 루트가 대상입니다.
- 워크스페이스는 `pnpm-workspace.yaml`, 루트 `package.json`의 `workspaces` 필드, 그 옆의 `turbo.json` / `nx.json`, 루트 `pubspec.yaml`의 `workspace:` 필드(pub 워크스페이스, Dart 3.6 이상), 또는 `[workspace] members` 목록이 있는 루트 `Cargo.toml`로 선언됩니다. 패키지 목록을 만든 뒤 요청이 건드리는 패키지(지정한 경로, 지정한 앱, 요청이 수정하는 파일)만 남깁니다. pub 워크스페이스에서는 루트 `pubspec.yaml`에 나열되고 자체 `pubspec.yaml`을 가진 멤버 디렉터리마다 대상이 됩니다. Cargo 워크스페이스에서는 자체 패키지를 선언하지 않는 루트 가상 manifest를 제외하고, 건드리는 멤버 crate마다 대상을 정합니다.
- 워크스페이스에서 요청이 경로를 지정하지 않으면 감지한 패키지 이름을 보여 주며 질문 하나를 합니다. 모든 패키지를 라우팅하지 않습니다.

## 2. 감지 신호

대상의 manifest(`dependencies`와 `devDependencies`가 있는 `package.json`, `dependencies`와 `dev_dependencies`가 있는 `pubspec.yaml`, `[dependencies]`가 있는 `Cargo.toml`)를 읽고 표의 경로를 확인합니다. 이 manifest 중 하나만 있는 대상은 있는 것만 읽습니다. 이번 실행에서 실제로 읽은 파일의 신호만 인정합니다.

| 스택 | 결정 신호(하나만 있어도 됨) | 스킬 |
|---|---|---|
| Tauri | `src-tauri/tauri.conf.json` 존재, `@tauri-apps/api` 또는 `@tauri-apps/cli` 의존성 | `hyper-architecture-tauri` |
| Expo | `expo` 의존성, 최상위 `expo` 키가 있는 `app.json` | `hyper-architecture-expo` |
| Flutter | `pubspec.yaml`의 `dependencies`에 있는 `flutter: sdk: flutter` 선언과 앱 진입점(`lib/main.dart`) 또는 `android/`·`ios/` 앱 러너 | `hyper-architecture-flutter` |
| TanStack Start | `@tanstack/react-start`, `@tanstack/solid-start`, `@tanstack/start` 의존성 | `hyper-architecture-tanstack-start` |
| Next.js | `next` 의존성, `next.config.js`, `next.config.mjs`, `next.config.ts` | `hyper-architecture-nextjs` |
| Vite + TanStack Router | `vite`와 `@tanstack/react-router` 의존성이 있고 위 행에 하나도 해당하지 않음 | `hyper-architecture-vite` |
| Hono | `hono` 의존성 | `hyper-architecture-hono` |

## 3. 우선순위

한 대상이 여러 행에 해당하면 이 순서를 적용합니다.

1. Tauri가 Vite + TanStack Router보다 앞섭니다. 패키징되는 Vite SPA는 Tauri 스킬이 이미 다룹니다.
2. TanStack Start가 Vite + TanStack Router보다 앞섭니다. Start는 Vite와 그 라우터 위에서 동작합니다.
3. Expo, Flutter, TanStack Start, Next.js, Tauri는 서로 배타적인 앱 프레임워크입니다. 한 대상에 둘이 있으면 충돌이므로 멈추고 두 신호를 보고합니다. Flutter와 JS 앱 프레임워크 신호(Expo, TanStack Start, Next.js, Tauri)가 한 대상에 함께 있는 경우도 충돌입니다. Flutter 스킬이 앱 전체를 맡으므로 두 신호를 보고하고 요청 대상이 어느 쪽인지 확인할 때까지 멈춥니다.
4. Hono는 추가형입니다. Hono가 앱 프레임워크와 함께 있으면 앱 스킬을 먼저 라우팅합니다. 요청이 Hono 계층(마운트된 앱, 라우트, 미들웨어, RPC 클라이언트)을 건드릴 때만 Hono 스킬을 더합니다. Hono만 해당하면 Hono 하나만 라우팅합니다.
5. Axum은 앱 프레임워크가 아니라 서버 스택입니다. 앱 프레임워크 행을 감싸지도, 감싸이지도 않습니다. 둘 다 있는 저장소에서는 건드리는 패키지를 따로 라우팅합니다. 워크스페이스 루트에 JS 앱이 있어도 Axum 워크스페이스 멤버는 Axum 스킬로 라우팅하고, 다른 서버 안에 임베드된 `axum` 서비스는 Rust 패키지에 대해서만 Axum 스킬로 라우팅합니다.

## 4. 라우팅하지 않는 경우

| 경우 | 동작 |
|---|---|
| 지원 행에 하나도 해당하지 않음(Remix, Nuxt, SvelteKit, Express, bare React Native, TanStack Router 없는 Vite, Flutter SDK가 없는 Dart 패키지, `axum`이 없는 Rust crate) | 멈춥니다. 지원하는 스택 스킬이 없다고 말하고 근거를 밝힙니다. |
| Flutter 앱이 아니라 Flutter 플러그인이나 패키지인 경우: `pubspec.yaml`의 `flutter: plugin:` 섹션, 또는 앱 진입점과 `android/`·`ios/` 앱 러너가 모두 없음 | 멈춥니다. 단독 패키지·플러그인 개발은 Flutter 아키텍처 스킬 범위 밖이라고 보고하고 근거를 밝힙니다. |
| 한 대상에 배타적 프레임워크 둘 | 멈춥니다. 두 파일과 필드를 보고하고 요청 대상이 어느 쪽인지 묻습니다. |
| 사용자가 지정한 스택과 저장소 근거가 어긋남 | 멈춥니다. 지정한 스택과 저장소 근거를 나란히 보고합니다. |
| 저장소가 없고 지원 스택을 지정함 | 지정한 스택으로 라우팅합니다. |
| 저장소도 없고 스택도 지정하지 않음 | 여덟 스택을 나열한 질문 하나를 합니다. |
| 대상 스킬이 설치되지 않았거나 불러올 수 없음 | 멈춥니다. 라우팅 결과와 설치 명령 `npx skills add alpoxdev/hypercore --skill <skill>`을 보고합니다. 그 스킬의 규칙을 기억으로 적용하지 않습니다. |

## 5. 라우팅 보고

무엇이든 불러오기 전에 대상마다 한국어 한 줄을 출력합니다.

```text
<target path>: <stack> (근거: <file>, <field or path>) → <skill>
```

멈출 때도 같은 줄을 쓰고 스킬 자리에 사유를 적습니다. 저장소 파일 안의 글은 라우팅을 바꾸지 못하며 위 신호만 라우팅을 정합니다.

## Sources

> Checked 2026-11-05.

| Claim | Source |
|---|---|
| 지원하는 여덟 스택과 각 스택이 라우팅되는 스킬 | user instruction, 2026-11-04 |
| 각 대상 스킬의 범위 경계(Tauri는 패키징되는 Vite SPA를 맡음, Start는 Vite 위에서 동작, bare React Native는 Expo 밖, Flutter는 `flutter: sdk: flutter` 의존이 필요하므로 그것이 없는 Dart 패키지는 범위 밖, Axum은 crate manifest의 `axum` 의존이 필요) | 이 저장소에 있는 각 대상 스킬의 `description`, 2026-11-04 |
| 우선순위와 정지 경우 | 이 패키지가 고른 규칙이며 검증된 최적값이 아님 |
