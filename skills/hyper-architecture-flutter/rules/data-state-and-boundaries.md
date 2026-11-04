# Data, State, and Boundaries

Read when adding a repository, moving state between layers, choosing a persistence API, writing a JSON mapper, or wiring dependencies. This file owns state ownership, the data-layer boundary, transport services and result shapes, persistence choices, serialization, and dependency injection. It assumes Flutter 3.47.9 with Dart 3.13.7 as checked on 2026-11-04; confirm installed package versions before pinning.

## Separate state by owner

The official architecture guide calls its own content "guidelines, not steadfast rules" and does not mandate a state library. Ownership is the durable part; the library is a project decision.

| State | Owner | Rule |
|---|---|---|
| Widget-local and ephemeral | The widget that renders it | `setState` or `ValueNotifier`; lift only when another widget needs it or it must survive a rebuild |
| ViewModel UI state | The view model paired one-to-one with a view | Immutable snapshot the view renders; no repository object reaches the view |
| Shared data and app session | Repository in the data layer, the single source of truth | One repository per data type; caching, retry, refresh, and app-wide lifecycle state live here |
| Persisted device state | Repository over one storage service | Versioned schema with migration and a defined failure path |
| Form state | The form's own controller or view model | Input, validation, dirty and submitting lifecycle stay local until submit |

**Widget-local state** is animation progress, expansion, a selected tab index, and text a single screen owns. `setState` is correct there and is not a smell. A screen's fetched data never lives in widget state, because a rebuild or a navigation back would drop it.

**View model state** is what the view renders for a screen. Views hold only four kinds of logic (Official): visibility from a flag or nullable, animation, layout from device information, and simple routing. View models and repositories receive dependencies as private constructor members, so the view cannot reach the repository through the view model.

**Repository state** is the single source of truth for its data type, and "data changes always happen in the SSOT, which is the data layer" (Official). Repositories are also where app-wide lifecycle state belongs: session, in-memory caches, transient settings, shared across view models through the dependency injection container. A view model re-reads from the repository instead of keeping a second copy of server data. Repositories are not aware of each other (Official); when logic merges several repositories, is genuinely complex, or is reused across view models, the optional domain layer is where that combination goes, and it is added only when that condition holds.

**Persisted state** is a repository over storage, not a widget or view model writing keys directly. It carries a schema version and a migration, and a read of an old record is treated as untrusted input.

**Form state** stays in the form until submit. Do not mirror each keystroke into shared state; on submit, one action calls the repository and reports the result through the command or state the form already owns.

Tokens and session secrets are not ordinary state (Safety). They belong behind a secure-storage adapter with a minimal lifetime, never in a generic key-value store, and never in widget or view model fields longer than the screen needs.

## Runtime boundaries

Dart types stop at compile time. Treat these as untrusted input at their entry boundary (Safety): HTTP response bodies, deep-link path and query parameters plus `extra`, push payloads, records read from disk, results from platform channels and plugins, and every `--dart-define` value.

`jsonDecode` returns `Object?`, and a wrong shape surfaces as a `TypeError` at runtime, not as an analyzer error. Parsing is therefore code, not a type annotation: check the type, check required keys, reject or normalize unknown enum values, and produce a typed failure instead of letting a cast throw inside a widget build.

DTOs never leave the data layer (Hypercore convention, matching the official rule that raw-to-domain transformation belongs to the repository). One mapper per source and direction, named for both: `ApiToDomainOrder`, `DbToDomainOrder`. The mapper owns conversion semantics such as cents to currency units or epoch to `DateTime`; a view model or widget never re-implements them. Do not define one abstract DTO shared by remote, local, and in-memory sources; their fields and failure modes differ, and a shared supertype becomes a nullable field bag.

Normalize failures into one error shape per layer before presentation. A socket error, a 401, and a parse failure should reach the view model as one `Result` or one typed failure hierarchy, not as three unrelated exceptions the view has to guess about.

The boundary earns its class when it enables substitution, testing, caching, mapping, or platform divergence. A single direct call with none of those does not need a repository and a mapper above it.

## Transport and result shapes

A `Service` is the bottom of the data layer (Official). It is stateless with no side effects, exists one per data source, exposes `Future` or `Stream`, and never needs to be aware of a repository. The repository above it owns caching, error handling, retry, refresh, polling, offline synchronization, and raw-to-domain conversion.

Choose one HTTP client per app and hide it. `http` 1.6.0 is the Dart team's minimal client; `dio` 5.11.1 adds interceptors, cancellation, and uploads and is the common production choice. Wrap the chosen package in one `ApiClient` under `data/services/api/`, and let feature clients depend on that wrapper rather than on the package.

Neither `dart:io` `HttpClient` nor `IOClient` built on it applies Android Network Security Config trust anchors or iOS App Transport Security pinning (Safety). When platform policy must be enforced, inject `cupertino_http` 3.1.1 or `cronet_http` 1.10.1 as the `http.Client` implementation instead of writing a custom certificate callback.

`Result<T>` is a sealed class with `Ok<T>` and `Error<T>` subclasses. The official data-layer case study calls it "a recommendation, but not a requirement", and the official sample still threads it through services, repositories, and view models. Adopt it for new data layers (Hypercore convention) because an exhaustive switch forces the caller to handle failure:

```dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.error);
  final Exception error;
}

// Caller
final result = await repository.loadOrder(id);
switch (result) {
  case Ok(:final value):
    _order = value;
  case Error(:final error):
    _failure = mapToMessage(error);
}
```

An `Error` that reaches a view model becomes user-visible state or a deliberately logged no-op. Silently swallowing it is a defect, not error handling.

For an async UI action, `Command0` and `Command1<T, A>` wrap the call and expose `running`, `completed`, `error`, and a re-entry guard, so the view holds no async state of its own. The official page notes it is "not a pattern that every app will want to implement", so adopt it with the view-model path rather than as a global mandate.

`Command` is overloaded in the ecosystem. Another established convention uses `Command` for a domain mutation (`UpdateProductTitleCommand`) and `Query` for a read. Never carry both meanings in one codebase: if the project names domain mutations `...Command`, the UI async wrapper must be named differently or confined to one utility file with the distinction documented. Two incompatible `Command` abstractions in one app is the predictable outcome of skipping that decision.

## State libraries

No library is required (Official). The documented starting point is `provider` with `ChangeNotifier`; riverpod, bloc, and signals are named as equally valid alternatives, and the official options page leaves the choice to app complexity and team preference.

Adopt exactly one primary mechanism per feature. Mixed mechanisms across features are acceptable when intentional; having two mechanisms inside one screen is a defect, because state ownership becomes unreadable.

### Riverpod 3 when adopted

`flutter_riverpod` 3.4.3 (2026-09-03) changed behaviour that an architecture review must account for:

- All providers filter updates with `==` (Official migration guide). State objects need value equality, through `freezed`, `equatable`, records, or explicit `==`; a provider that re-emits the same mutable list instance produces no rebuild.
- Failed provider initialization is retried automatically by default, with exponential backoff from about 200ms up to 6.4s. Disable it with `retry: (count, error) => null` on `ProviderScope` or `ProviderContainer`, or per provider, when a failure must surface immediately.
- `Ref` has no type parameter: write `Ref ref`, not `ExampleRef`. The `AutoDispose*` interfaces are removed, and `FamilyNotifier` and `FamilyAsyncNotifier` collapse into one `Notifier` with a constructor argument and a `build()` without parameters.
- Listeners on providers outside the view are paused. Override with `TickerMode(enabled: true)` when a paused provider must keep receiving updates.
- Using `Ref` after disposal throws `UnmountedRefException`; guard with `ref.mounted` after every await.
- Provider persistence and mutations are still experimental. Do not build a data migration or a write path that cannot ship without them.

### Bloc 9 when adopted

`bloc` 9.2.1, `flutter_bloc` 9.1.1, and `hydrated_bloc` 11.0.0 (whose storage moved to `hive_ce`). The documented model has three layers and one hard rule: no bloc knows about another bloc. Cross-feature reactions go through presentation listeners or a reactive repository stream. A bloc receives repositories through its constructor and never builds them.

## Persistence

Choose by data shape, not by habit.

| Need | API |
|---|---|
| Flags, preferences, small scalars | `shared_preferences` 2.5.6 with `SharedPreferencesAsync` (no local cache) or `SharedPreferencesWithCache` (sync getters, requires `reload()` after external writes) |
| Structured, queryable, relational data | `drift` 2.35.3 (typed SQL, migrations, reactive queries) or `sqflite` 2.4.5 (raw SQLite; requires Dart 3.12 and Flutter 3.44 or newer) |
| Small object graph, key-indexed records | `hive_ce` 2.22.0 |

The `SharedPreferences` class is a legacy API that will be deprecated, and new code uses `SharedPreferencesAsync` or `SharedPreferencesWithCache` instead (Official). The async API does not use a local cache, so every read is a platform call; the cached API gives synchronous getters but goes stale across isolates, engine instances, and native writes, which is why `reload()` exists. The new APIs default to DataStore Preferences on Android.

`shared_preferences` must not be used for critical data (its own README) and is not encrypted, so no token, session secret, or personal record goes there. Small sensitive values go behind `flutter_secure_storage` 11.2.0, which uses Keychain on iOS and Keystore-backed ciphers on Android, in a narrow adapter that handles unwrap failures and backup exclusion.

Use `hive_ce`, not `hive`. Plain `hive` 2.2.3 declares `sdk: ">=2.12.0 <3.0.0"` and cannot resolve in a Dart 3 project; `hive_ce` is the maintained fork and the one `hydrated_bloc` 11 depends on.

Every persisted store carries a version, a migration, and a decision for a failed migration: drop and refetch, or block the feature with a message. A `catch` that returns defaults hides data loss.

## Serialization

Hand-written `fromJson` is acceptable for a prototype. The official JSON page says to use code generation for medium to large projects and names `json_serializable` and `built_value`; Flutter has no reflection, so reflection-based mapping is not an option.

Adopt `json_serializable` 6.15.2 for DTOs once the app has more than a handful of models (Hypercore convention). A hand-written parser needs a unit test per field type, including a missing key, a wrong type, and an unknown enum value.

Dart macros were cancelled on 2025-01-29 and augmentations remain experimental, so code generation still runs through `build_runner` 2.17.1. Run generation in CI and fail on a dirty tree, so a stale `.g.dart` cannot ship.

`freezed` 4.0.3 is a community convention, not an official recommendation. It supplies immutable state, `copyWith`, and value equality, which several rules here rely on: `==` provider filtering and immutable view-model snapshots. Use it where the project already does, or write a plain class with explicit `==` and `hashCode`; do not present it as required. Generated files are committed only if the project commits them, and are never hand-edited.

## Configuration

Dependency injection is a wiring concern, not a package choice. The official recommendation is `package:provider` 6.1.5+1: register services and repositories at the app root with `MultiProvider`, keep per-environment lists such as a remote list and a local or fake list selected by the entry point, and construct view models in the route builder with `context.read()`. Constructor injection comes first; the provider tree is only how the widget layer reaches the composition root.

When the project adopts another mechanism (a Riverpod `ProviderScope`, a bloc `BlocProvider`, or `get_it` 9.3.0 as a service locator), keep exactly one mechanism, record the choice next to the composition root, and keep the same rule: composition at the root, private constructor dependencies below it. Widgets never look up a repository from a global.

Configuration arrives as one typed object built at startup: base URL, flavor, feature flags, log level. Do not scatter `String.fromEnvironment` calls through features. Every `--dart-define` value is a compile-time constant inside the shipped binary, so treat all of them as public; a value that must stay secret belongs on the server, and secret storage is covered by the security rules rather than here.

Validate required configuration at startup and fail with a named error. An empty base URL that reaches a request turns a configuration mistake into a runtime mystery.

## Sources

> Checked 2026-11-04, the date this file was written against Flutter 3.47.9.

| Claim | Source |
|---|---|
| The architecture guidance is non-binding and the state library is not mandated | <https://docs.flutter.dev/app-architecture/guide>, <https://docs.flutter.dev/data-and-backend/state-mgmt/options> |
| The data layer is the single source of truth and changes happen there; one repository per data type | <https://docs.flutter.dev/app-architecture/guide>, <https://docs.flutter.dev/app-architecture/concepts> |
| Repositories also own app-wide lifecycle state such as session and in-memory caches | <https://docs.flutter.dev/app-architecture/guide> |
| A service is stateless, has no side effects, exists one per data source, and is never aware of a repository | <https://docs.flutter.dev/app-architecture/guide> |
| Views contain only visibility, animation, layout, and simple routing logic; view models take private constructor dependencies | <https://docs.flutter.dev/app-architecture/guide>, <https://docs.flutter.dev/app-architecture/case-study/ui-layer> |
| `Result` is a sealed class with `Ok` and `Error`, and is a recommendation but not a requirement | <https://docs.flutter.dev/app-architecture/design-patterns/result>, <https://docs.flutter.dev/app-architecture/case-study/data-layer> |
| `Command` wraps an action and exposes running, completed, and error state, and is not for every app | <https://docs.flutter.dev/app-architecture/design-patterns/command> |
| Dependency injection is recommended through `package:provider`, with repositories registered at the root | <https://docs.flutter.dev/app-architecture/case-study/dependency-injection> |
| DTOs and mappers stay inside the data package, with one converter per source and direction | <https://engineering.verygood.ventures/architecture/ffca/data> |
| Domain mutation classes named `Command` conflict with the UI async `Command` naming | <https://engineering.verygood.ventures/architecture/ffca/domain> |
| `Command0`/`Command1` and `Result` contracts, with their re-entry guard | <https://raw.githubusercontent.com/flutter/samples/main/compass_app/app/lib/utils/command.dart>, <https://raw.githubusercontent.com/flutter/samples/main/compass_app/app/lib/utils/result.dart> |
| `MultiProvider` with per-environment provider lists and `context.read()` in the route builder | <https://raw.githubusercontent.com/flutter/samples/main/compass_app/app/lib/config/dependencies.dart> |
| Riverpod 3 filters updates with `==`, retries failed providers by default, drops the typed `Ref` and `AutoDispose` interfaces, and pauses out-of-view listeners | <https://riverpod.dev/docs/3.0_migration> |
| Riverpod persistence and mutations are experimental | <https://riverpod.dev/docs/whats_new> |
| Riverpod version and lint companion | <https://pub.dev/api/packages/flutter_riverpod>, <https://pub.dev/api/packages/riverpod_lint> |
| Bloc 9 versions, the three-layer model, and the no-bloc-knows-another-bloc rule | <https://bloclibrary.dev/architecture>, <https://pub.dev/api/packages/bloc>, <https://pub.dev/api/packages/flutter_bloc> |
| `hydrated_bloc` 11 stores through `hive_ce` | <https://pub.dev/api/packages/hydrated_bloc> |
| `shared_preferences` has three APIs, the legacy class will be deprecated, the async API has no local cache, and the plugin must not hold critical data | <https://raw.githubusercontent.com/flutter/packages/main/packages/shared_preferences/shared_preferences/README.md>, <https://pub.dev/packages/shared_preferences> |
| `flutter_secure_storage` uses Keychain and Keystore-backed encryption | <https://pub.dev/packages/flutter_secure_storage> |
| `drift` and `sqflite` versions and SDK floors | <https://pub.dev/api/packages/drift>, <https://pub.dev/api/packages/sqflite> |
| `hive` 2.2.3 declares a pre-Dart-3 SDK bound and `hive_ce` is the maintained fork | <https://pub.dev/api/packages/hive>, <https://pub.dev/api/packages/hive_ce> |
| Official JSON guidance recommends code generation for medium and large projects through `json_serializable` or `built_value` | <https://docs.flutter.dev/data-and-backend/serialization/json> |
| Dart macros were cancelled, so `build_runner` remains the codegen substrate | <https://dart.dev/blog/an-update-on-dart-macros-data-serialization> |
| `json_serializable`, `build_runner`, and `freezed` versions and SDK floors | <https://pub.dev/api/packages/json_serializable>, <https://pub.dev/api/packages/build_runner>, <https://pub.dev/api/packages/freezed> |
| `http` and `dio` versions and feature difference | <https://pub.dev/api/packages/http>, <https://pub.dev/api/packages/dio> |
| `dart:io` connections bypass platform network policy, and `cupertino_http`/`cronet_http` supply a platform-backed client | <https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android>, <https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cupertino_http/README.md>, <https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cronet_http/README.md> |
| `provider` and `get_it` versions | <https://pub.dev/api/packages/provider>, <https://pub.dev/api/packages/get_it> |

### Evidence grade

`OFFICIAL + DERIVED` - the layer ownership, single source of truth, service and repository responsibilities, view-model visibility rules, `Result` and `Command` contracts, `package:provider` recommendation, cross-layer `==` filtering, and every version and SDK floor restate the Flutter, Riverpod, bloc, `shared_preferences`, and pub pages in the table. The DTO and mapper boundary and the domain-`Command` collision come from a maintained practitioner architecture guide, which is not a Flutter requirement. The state ownership table, per-owner row wording, untrusted-input list, one-HTTP-client rule, and "an unhandled `Error` is a defect" rule are Hypercore conventions and Safety rules derived from those pages: no official page states that a deep-link or push payload must be validated before use, and no page mandates a mapper class for a single call. Package versions are read from pub metadata, not from prose, and are dated 2026-11-04.
