Stack guide inside `hyper-architecture` for Flutter. Read it when `rules/stack-detection.md` routes a target to Flutter; from then on this file owns that target's work.

- Scope: Use this skill when creating, reviewing, or refactoring scalable Android and iOS app architecture with Flutter and Dart, including project structure, routing and deep links, feature boundaries, data/state ownership, native configuration and platform seams, and validation. Do not use for bare Dart command-line tools or servers, standalone package or plugin development, React Native or Expo apps, web-only projects that are not Flutter, or docs-only summaries.
- Runtime needs: Requires a Flutter project or an explicit request to create one; current version and API claims may require the official Flutter, Dart, Android, Apple, and pub.dev documentation plus local `flutter --version` and `pubspec.yaml` inspection.

@architecture-rules.md
@../../rules/flutter/project-structure.md
@../../rules/flutter/routing-and-navigation.md
@../../rules/flutter/data-state-and-boundaries.md
@../../rules/flutter/native-platform-and-security.md
@../../references/official/flutter/flutter-dart-2026-11-04.md
@../../rules/flutter/testing-and-validation.md

# Flutter Architecture

> Create and enforce scalable Flutter + Dart architecture for Android and iOS while separating official framework behavior from Hypercore conventions.

<output_language>

Default user-facing deliverables, reports, plans, handoff notes, and validation notes to Korean. Preserve code identifiers, commands, paths, schema keys, package names, API names, and source excerpts in their required language.

</output_language>

<purpose>

- Bootstrap or refactor Flutter applications around the official MVVM layering, one router configuration, strict analyzer settings, and explicit feature boundaries.
- Keep views thin, screen state in the paired view model, and the data layer behind a one-way dependency direction that survives growth.
- Protect secrets, permissions, signing, native configuration, storage, and Android/iOS divergence with explicit gates instead of inherited assumptions.
- Validate architecture against the installed Flutter and Dart toolchain and project evidence before applying current official guidance, without imposing a state library.

</purpose>

<routing_rule>

Use this skill for architecture setup, implementation, review, or remediation in Flutter apps whose primary targets are Android and iOS, with web and desktop included only when the project declares them.

Do not use it for bare Dart command-line tools or servers, standalone package or plugin development, React Native or Expo apps, web-only projects that are not Flutter, a single visual change with no architecture impact, deployment-only work, or documentation-only summaries. For brownfield apps, preserve working project conventions unless the user requests migration or a safety/correctness issue requires change.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Produce a scalable, testable Flutter architecture whose view, view-model, data, native, and platform boundaries remain understandable as the app grows. |
| Trigger | Flutter/Dart work involving app setup, folder structure, routing and deep links, state/data flow, native configuration, platform divergence, testing, or architecture review. |
| Scope | Touched Dart source, route table, feature/shared modules, `pubspec.yaml`, analyzer configuration, tests, and architecture validation notes. Regenerating native directories, replacing dependencies, signing, and store actions require explicit scope. |
| Authority | User and project instructions outrank this skill. The installed toolchain and project configuration control project behavior. Official Flutter, Dart, and package documentation control API facts; Hypercore conventions are recommendations unless the project adopts them. |
| Evidence | Inspect `pubspec.yaml`, `analysis_options.yaml`, `lib/` entry points, the router configuration, `ios/` and `android/`, existing tests, the lockfile or pub workspace, and `flutter --version` first. Use the dated official reference when version drift decides the change. |
| Tools | Use capability-based inspect/read/search/edit/execute. Validate commands and paths. Gate network installs, credentials, signing, store publication, project-wide generators, and build hooks that download or execute binaries. |
| Loop | Use a bounded verify-repair loop: run the relevant checks, repair only observed failures, and stop after two repair passes. Keep changes only when the format check, analyzer, tests, and safety gates relevant to the change pass. |
| Output | A project-local architecture implementation or review, plus a concise Korean report of decisions, changed files, checks, source/version caveats, and residual risks. |
| Verification | Run project-defined commands plus format checking, `flutter analyze`, `flutter test`, per-platform integration runs, and artifact builds relevant to the touched surfaces; inspect resolved native configuration and route behavior when changed. |
| Stop condition | Finish when the toolchain, declared targets, router, and state ownership are identified, applicable critical gates pass, changes are verified, and residual risk is recorded; block on missing authority, unsafe native effects, unresolved version or package incompatibility, or unavailable required verification. |

</instruction_contract>

<activation_examples>

Positive:
- "Flutter와 Dart로 Android/iOS 앱 architecture를 세팅해줘. 화면은 feature 단위로 나누고 라우팅이랑 상태 소유권 경계도 같이 잡아줘."
- "Refactor this Flutter app so go_router setup stays in one place and features stop importing each other's internals."
- "우리 Flutter 앱의 Android productFlavors랑 iOS scheme별 권한 설정을 아키텍처 관점에서 검토해줘."
- "Set up deep links in this Flutter app with go_router and a bottom-tab shell, and tell me what breaks on Android and iOS."

Negative:
- "Our React Native app uses Expo Router with file routes under app/. Rework the navigation and native config so it scales."
- "Design the package structure for a Dart command-line tool that talks to a REST API. No Flutter, no mobile targets."
- "우리가 쓰는 Flutter 위젯 패키지에서 카드 위젯 하나만 복사해서 문구만 바꾼 변형 위젯을 만들어줘. 앱 구조는 상관없어."
- "Flutter로 만들 화면인데 피그마 시안처럼 로그인 화면 목업만 그려줘. 코드는 나중에."

Boundary:
- "Flutter 앱을 Play 스토어랑 App Store에 올릴 준비를 해줘. 서명 설정이랑 target SDK가 요구사항에 맞는지만 확인해줘." Review the build and release configuration and stop before creating signing material or uploading.
- "Flutter 로그인 화면 버튼 문구 한 줄만 '계속하기'로 바꿔줘." Apply only a quick boundary check; do not force architecture churn.

</activation_examples>

<trigger_conditions>

Activate when the request names a Flutter app, a `pubspec.yaml` that depends on `flutter`, the `lib/` structure, a router such as `go_router`, deep links, flavors, native configuration under `ios/` or `android/`, platform-specific code, or the layout of app data and state, and the work is setup, implementation, review, or remediation.

Activate also when a shipped or growing Flutter project needs its structure, routing, imports, platform seams, or validation order changed, including review requests that end in a change set.

The project test runs before the request test. When local files show a Dart project without a Flutter app dependency and the user did not ask to create a Flutter app, do not route here. The remaining exclusions are in `<routing_rule>`.

</trigger_conditions>

<skill_architecture>

| Part | Role | Load condition |
|---|---|---|
| `stacks/flutter/core.md` | Trigger, contract, workflow, gates, validation | Always |
| `stacks/flutter/architecture-rules.md` | Rule classes, authority order, blocking gates, default tree | Before classifying a finding |
| `rules/flutter/project-structure.md` | Scale profiles, ownership, imports, migration order, workspace layout | When changing folders, imports, or module ownership |
| `rules/flutter/routing-and-navigation.md` | Navigation model, single router, guards, deep links, back handling | When changing routes or links |
| `rules/flutter/data-state-and-boundaries.md` | State ownership, repositories, DTOs, persistence, dependency injection | When changing data flow or state |
| `rules/flutter/native-platform-and-security.md` | Native directories, flavors, permissions, secrets, trust, interop | When touching native config or platform code |
| `rules/flutter/testing-and-validation.md` | Check order, testing floors, required scenarios, completion record | Before claiming completion |
| `references/official/flutter/flutter-dart-2026-11-04.md` | Dated official version, API, and platform facts | When a current toolchain or API claim decides the change |

</skill_architecture>

<loop_policy>

One bounded loop per change set: run the checks, read the failures, repair only what failed, and re-run. One round is one repair and its re-run, and the loop ends after two rounds. A change stays only when the critical format, analyzer, test, native-config, and safety gates pass; otherwise the loop ends with the failing check named and nothing claimed as verified. There is no loop that keeps restructuring until the tree feels right and no self-scoring loop. Evidence is the recorded command output, the built artifact, and the resolved configuration, not a restatement of the plan.

</loop_policy>

<language_and_translation_default>

Deliver user-facing text in Korean by default: the report, decisions, caveats, and residual risks. Keep code identifiers, commands, paths, package and API names, and quoted source lines in their original form. This package is maintained as English/Korean pairs (`X.md` ↔ `X.ko.md`); read one language version per run and update both when a rule changes.

</language_and_translation_default>

<reference_routing>

- Before classifying any finding or enforcing a rule, read `stacks/flutter/architecture-rules.md`.
- When changing folders, imports, module ownership, scale profile, or migration order, read `rules/flutter/project-structure.md`.
- When changing the navigation model, the route table, guards, redirects, deep links, or back handling, read `rules/flutter/routing-and-navigation.md`.
- When changing state ownership, repositories, DTOs, serialization, persistence, or dependency wiring, read `rules/flutter/data-state-and-boundaries.md`.
- When touching flavors, permissions, secrets, storage, HTTP trust, native interop, build configuration, or release requirements, read `rules/flutter/native-platform-and-security.md`.
- Before claiming completion, read `rules/flutter/testing-and-validation.md`.
- When the installed toolchain, a package version, or an official API behavior decides the change, read `references/official/flutter/flutter-dart-2026-11-04.md` and compare its `last_verified_at` with `flutter --version` and the `environment` block.

</reference_routing>

<support_file_read_order>

Read one language version per run, in this order. Paths are relative to this skill directory.

1. Read `stacks/flutter/architecture-rules.md` for rule classes, the authority order, and blocking gates.
2. Read the rule files for the topics the change touches, choosing them with `<reference_routing>`.
3. Read `references/official/flutter/flutter-dart-2026-11-04.md` only when current toolchain behavior or an API lifecycle decides the change.
4. Read `rules/flutter/testing-and-validation.md` before implementation completion.

</support_file_read_order>

<workflow>

| Phase | Task | Output |
|---|---|---|
| 0 | Confirm the project facts from local files: Flutter and Dart versions from `flutter --version` and the `pubspec.yaml` `environment` block, which platform folders exist (`android/`, `ios/`, optional `web/`, `macos/`, `linux/`, `windows/`), flavors and entry points, the state library in use, the router, Swift Package Manager versus CocoaPods, pub workspace or single package layout, `material_ui` adoption, project commands, and whether the request needs installs, signing, or store effects | Scope decision |
| 1 | Inventory features, route table, shared modules, state and data flow, native configuration, tests, and dependency direction | Architecture map |
| 2 | Classify findings as Official, Safety, or Hypercore convention | Prioritized plan |
| 3 | Define target boundaries and the smallest vertical slice; preserve user work | Change set |
| 4 | Implement safe reversible changes and update affected callsites, tests, and configuration | Integrated architecture |
| 5 | Run focused then project-level checks and inspect resolved behavior on each declared platform | Verification evidence |
| 6 | Report decisions, versions and sources, results, and residual risks in Korean | Handoff |

</workflow>

<required>

- Choose the smallest structure profile that preserves clear ownership: the official hybrid tree for a small app, feature-first folders for a growing app, pub workspace packages when two apps, an independent release, a separate owner, or a rule that must fail the build requires them.
- Keep views thin: screen state lives in the paired view model, a repository is the single source of truth for its data type, and a service exists once per external source and holds no state.
- Keep one router configuration, thin route builders that parse parameters into domain types, and no named-route or mixed-router setup in new code.
- Keep dependencies pointing View to ViewModel to an optional use-case to Repository to Service, with no repository depending on another repository and no view importing the data layer.
- Keep widget-local, view-model, repository, persisted, and form state separated by owner and lifecycle, and keep the state library the project already runs instead of swapping it during unrelated work.
- Treat `--dart-define`, `--dart-define-from-file`, `appFlavor`, assets, and every compiled constant as public values that ship inside the app.
- Make platform divergence explicit behind a capability or adapter, and decide platform behavior with `defaultTargetPlatform` and `kIsWeb` in shared code.
- Keep `ios/` and `android/` as owned, reviewed source, and match every runtime permission to its declaration and user-facing purpose text.
- Use the installed toolchain and each package's declared `flutter:` and `sdk:` constraints rather than guessing versions.

</required>

<forbidden>

- Inventing project commands, packages, native capabilities, API contracts, or environment variables.
- A universal folder template applied without inspecting project scale and existing conventions.
- Forcing a state library, replacing it mid-task, or running two state mechanisms inside one screen.
- Views importing repositories, services, DTOs, or persistence adapters; repositories depending on each other; broad barrel files that create cycles.
- Secrets in source, assets, `--dart-define` values, `appFlavor`, logs, analytics, crash reports, `shared_preferences`, or unencrypted files.
- Running dependency install or upgrade, `flutter create` over an existing project, signing, store upload, or publish without explicit authorization.
- Claiming Android or iOS support from a host unit test, a widget test, or a web run alone.
- Treating a router redirect as authorization, or using deep-link, push, route `extra`, persisted, or API input without validation at the boundary.
- Unbounded restructuring without a verified incremental slice.

</forbidden>

<validation>

- [ ] Flutter and Dart versions, declared platform targets, router, state library, and native dependency manager are identified.
- [ ] At least 3 positive, 2 negative, and 1 boundary trigger examples remain present.
- [ ] Route builders are thin, one router configuration exists, and no feature imports routing internals.
- [ ] Dependency direction and feature/shared ownership are explicit; cycles and unsafe barrels are absent.
- [ ] Runtime input, configuration, persistence, permissions, and secure storage follow the boundary and safety rules.
- [ ] Android and iOS changes are checked independently where behavior or configuration differs.
- [ ] Relevant format check, `flutter analyze`, unit and widget tests, per-platform runs, and artifact builds ran or are explicitly reported as unavailable.
- [ ] English/Korean skill files retain equivalent trigger, authority, workflow, safety, and completion semantics.
- [ ] Current official claims cite the dated reference; the baseline is Flutter 3.47.9 / Dart 3.13.7 per `references/official/flutter/flutter-dart-2026-11-04.md`, and source dates are not in the future.
- [ ] Completion records `Claim -> Risk -> Evidence -> Verification -> Result -> Caveat` and decides ship, iterate, caveated ship, or block.

</validation>
