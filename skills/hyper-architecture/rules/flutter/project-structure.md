# Project Structure

Read when choosing or changing folders, module ownership, imports, or a migration order. This file owns the scale profiles, the layer boundaries, the import direction, and the workspace layout.

## 1. Choose structure from evidence

Inspect app size and feature count, team boundaries, entry points and flavors, the routing root, `analysis_options.yaml`, workspace layout, generated files, `ios/`/`android/` ownership, tests, and current imports. Do not replace a coherent brownfield structure merely to match this rule.

Use the smallest profile that preserves clear ownership:

| Profile | Use when | Start with |
|---|---|---|
| Small | One app, one team, fewer than three independent features | The official hybrid tree: `lib/ui/`, `lib/data/`, `lib/domain/`, `lib/routing/`, `lib/config/`, `lib/utils/`, plus `test/` and `testing/` |
| Growing | Several product capabilities with separate data flows, or several contributors | `lib/features/<domain>/{data,domain,presentation}` plus `lib/shared/` |
| Multi-team | Multiple apps, independently released capabilities, or a boundary that must fail the build | Pub workspace packages `{feature}_domain`, `{feature}_data`, `{feature}_presentation`, plus shared packages |

The small and growing profiles are conventions assembled from the four official components (View, ViewModel, Repository, Service); only the multi-team profile turns a wrong import into a compile error. VGV's decision rule points the same way: a single app with fewer than three features is simpler as a layered tree. Promote a folder when it has a distinct owner or dependency rule, not when it looks tidy. Empty directories and one-file abstraction layers are not scalability.

## 2. Recommended structure

The three trees below are destination maps, not a requirement to create every directory. A normal app omits `domain/`, `shared/`, and package splits until they own real code.

### Small app: official hybrid layout

`ui/` is organized by feature, `data/` and `domain/` by type, because repositories and services are not tied to a single feature. This is the layout the official sample ships.

```text
.
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── main_development.dart        # one entry point per flavor when flavors exist
│   ├── ui/
│   │   ├── core/                    # shared widgets, theme, localization
│   │   │   ├── ui/                  # primitive widgets; not a top-level "widgets/"
│   │   │   ├── themes/
│   │   │   └── localization/
│   │   └── activities/              # one folder per feature, named for what the user does
│   │       ├── view_models/
│   │       └── widgets/
│   ├── data/
│   │   ├── repositories/
│   │   │   └── activities/
│   │   │       ├── activities_repository.dart
│   │   │       ├── activities_repository_remote.dart
│   │   │       └── activities_repository_dev.dart
│   │   └── services/
│   │       ├── api/
│   │       │   ├── api_client.dart
│   │       │   └── model/           # transport DTOs stay here
│   │       └── local/
│   ├── domain/
│   │   ├── models/
│   │   └── use_cases/               # add only when needed
│   ├── routing/
│   │   ├── router.dart
│   │   └── routes.dart
│   ├── config/
│   │   ├── assets.dart
│   │   └── dependencies.dart        # provider wiring and environment selection
│   └── utils/                       # pure helpers shared by several features
├── test/                            # mirrors lib/: data/, domain/, ui/, utils/
└── testing/                         # unshipped package: harness, fakes, mocks
    ├── app.dart                     # testApp() wrapper with size, theme, delegates
    ├── mocks.dart
    ├── fakes/
    │   ├── repositories/
    │   └── services/
    └── models/
```

Name a feature for the capability the user performs, not for the screen the user sees. A screen-named folder attracts its models and repositories back into top-level buckets and unbalances the tree.

### Growing app: feature-first with layers

Past a handful of features, keep the layers inside each feature so one capability can be changed, tested, and deleted as a unit.

```text
.
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                 # root widget, theme, localization delegates
│   │   └── bootstrap.dart           # wiring: repositories, router, providers
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── data_sources/    # remote and local access
│   │   │   │   ├── dtos/            # transport models, never exported
│   │   │   │   ├── mappers/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/          # entities the UI may hold
│   │   │   │   ├── repositories/    # abstract repository contract
│   │   │   │   └── use_cases/
│   │   │   └── presentation/
│   │   │       ├── sign_in/
│   │   │       │   ├── sign_in_screen.dart
│   │   │       │   ├── sign_in_view_model.dart
│   │   │       │   └── widgets/
│   │   │       └── widgets/         # shared inside this feature only
│   │   └── checkout/
│   ├── shared/
│   │   ├── ui/                      # design primitives used by two or more features
│   │   ├── network/                 # client, interceptors, error mapping
│   │   ├── storage/                 # key-value and secure-storage adapters
│   │   ├── config/                  # compile-time and runtime configuration
│   │   ├── utils/                   # pure helpers
│   │   └── testing/                 # fakes and harnesses used by several features
│   └── routing/
│       └── app_router.dart
├── test/                            # mirrors lib/
└── testing/                         # optional shared harness package
```

Each feature exposes one public entry (`auth.dart` under `lib/features/auth/`) that re-exports its screens, models, and repository contract. Everything else stays private to the feature.

### Multi-team app: pub workspace packages

When a boundary must be enforced by the compiler, split each feature into layer packages and let `pubspec.yaml` state the dependency rule.

```text
.
├── pubspec.yaml                     # workspace root: sdk ^3.6.0 and the workspace list
├── analysis_options.yaml            # one shared lint set and plugin list
├── pubspec.lock                     # single lockfile for the whole workspace
├── apps/
│   └── shop_app/
│       ├── pubspec.yaml             # resolution: workspace
│       └── lib/
│           ├── main.dart
│           └── bootstrap.dart       # binds feature modules to routes and DI
├── packages/
│   ├── auth_domain/                 # entities, repository contract, use-cases
│   ├── auth_data/                   # implements auth_domain against a backend
│   ├── auth_presentation/           # screens, view models, module widget
│   ├── checkout_domain/
│   ├── checkout_data/
│   ├── checkout_presentation/
│   ├── app_ui/                      # design primitives usable unchanged by any app
│   ├── core_network/
│   ├── core_storage/
│   └── shared_testing/              # fakes and harnesses; never shipped
└── tool/                            # optional scripts; a melos.yaml can replace it
```

Two variants are legitimate and need no special casing: a headless feature (`auth_domain` and `auth_data` with no presentation package) and a presentation-only feature that composes other features' domains. A backend-specific implementation becomes its own package (`auth_data_firebase`) rather than a conditional inside `auth_data`.

## 3. Layer ownership

### `lib/ui/<feature>` and `presentation/`

A View renders an immutable snapshot of state and forwards user intents. A ViewModel holds that state: loading flags, filtered projections, selected tabs, form submission status. The relationship is one view to one view model. Allowed view logic is short: conditional display, animation, layout decisions based on device information, and simple navigation. Anything else belongs to the ViewModel or below it.

Views never reach the data layer. ViewModels may take repositories in their constructor, and use-cases when a domain layer exists; that is the documented MVVM wiring, not a violation.

### `lib/data` and `data/`

A repository is the single source of truth for a type of data and owns caching, error mapping, retry, and refresh policy. A service talks to exactly one data source (HTTP API, database, platform channel), holds no state, and there is one service class per data source. Repositories are never aware of each other; when two are needed together, orchestrate in a use-case or a ViewModel. Repositories and view models have a many-to-many relationship.

Transport DTOs, JSON mapping, and data sources live here and never cross the layer boundary. Map a DTO to a domain model when the semantics differ; passing the API shape to widgets couples the UI to a backend.

### `lib/domain` and `domain/`

The domain layer is conditional. It holds entities, abstract repository contracts, and use-cases. Add a use-case when several view models perform the same flow, or when the logic needs tests that do not construct a ViewModel. Skipping the layer for a direct repository call is the documented default for a simple app.

### `lib/shared` and shared packages

Shared means domain-agnostic and used by at least two owners. Two questions test it: is this a business capability that apps compose (then it is a feature), and could a stranger use it unchanged if you published it (then it is shared). `PrimaryButton` is shared, `LoginButton` is not; an HTTP client is shared, a product API client is not; `formatCurrency()` is shared, `calculateTax()` is not.

Shared code must not import a feature. Inside `shared/`, group by concern (`network`, `storage`, `ui`, `config`) instead of dropping unrelated files at the root.

### `lib/routing`, `lib/config`, `lib/utils`

Routing owns router construction and the route table; a route builder reads validated parameters and returns a screen. Configuration owns asset paths, environment selection, and the provider wiring that decides which repository implementation runs. Utilities hold pure functions with no imports from features or data.

None of these three may become a second `shared/`: if a helper only one feature uses, it belongs in that feature.

### `testing/` and `test/`

`testing/` is a version of the app you do not ship: a `testApp()` wrapper that sets surface size, theme, localization delegates, device pixel ratio, and a router, plus fakes for repositories and services and the shared mocks. `test/` mirrors `lib/` (`data/`, `domain/`, `ui/`, `utils/`) for the actual test files.

Production code never imports `testing/`. A fake belongs here only when more than one test file uses it; a single-use fake stays beside its test.

### `ios/` and `android/`

These are owned source directories in a Flutter project, committed and reviewed like Dart code, not regenerated by a tool. Folder changes that affect signing, entitlements, permissions, or build settings belong in the same review as the Dart change that needs them. Per-platform configuration details live in the native platform rule.

## 4. Dependency rule

```text
View -> ViewModel -> (use-case) -> Repository -> Service
feature presentation -> own domain -> shared
feature data -> own domain, other features' domain, shared
app -> every feature package, every shared package
```

A layer may import only along that direction. Same-layer cross-imports need a public entry point and must not form a cycle.

- A View imports widgets, theme, and its ViewModel. It does not import `data/`.
- A ViewModel imports its feature's domain, or repositories directly when there is no domain layer.
- Repositories never import another repository.
- In the growing profile, a feature imports another feature only through that feature's public entry, and preferably only its domain. In the workspace profile the rule is stricter and mechanical: no presentation package depends on any `_data` package, its own included.
- Shared packages never depend on feature packages.
- Nothing depends on the app package. Features depend on shared libraries; the app depends on features.

Cross-feature navigation is injected, not imported. A feature exposes typed callbacks through a module widget or constructor, and the app layer binds them to routes. That keeps two features from depending on each other just to push a screen.

Barrels stay narrow. A data barrel may export the repository and its data sources but never DTOs or mappers. Internal files import directly rather than routing back through their own barrel.

## 5. Cross-cutting placement

| Concern | Preferred location | Avoid |
|---|---|---|
| Router construction, route table | `lib/routing/` or the app package | route strings scattered through widgets |
| Dependency wiring, environment selection | `lib/config/dependencies.dart`, app bootstrap | service-locator lookups inside widgets |
| HTTP client, interceptors, auth header | `shared/network` | one client instance per feature with duplicated retry |
| DTOs, JSON mapping | `data/dtos`, `data/mappers` | DTOs passed to widgets or exported from a barrel |
| Entities, repository contracts | `domain/models`, `domain/repositories` | an API model reused as a domain model when semantics differ |
| Design primitives | `lib/ui/core/ui` or `app_ui` package | promoting a feature-specific card before a second consumer |
| Theme, localization | `lib/ui/core/themes`, `localization` | theme values repeated in each screen |
| Analytics, logging | typed port in shared code, call sites near the owner | vendor SDK imports spread across features |
| Storage adapters, secure values | `shared/storage`; secrets behind a secure-storage adapter | preferences storage used for secrets |
| Test harness, fakes | `testing/` package | fakes copied into individual test files |
| Generated code (`*.g.dart`, `*.freezed.dart`) | beside the source file, never hand-edited | editing or duplicating generated files |
| Platform differences | capability or policy object injected at bootstrap | `Platform.is*` or `kIsWeb` checks spread through widgets |

## 6. Monorepo and workspace profile

Pub workspaces need Dart 3.6 or later. The root declares the members, each member opts in, and resolution happens once for the whole repository.

```yaml
name: shop_workspace              # root pubspec.yaml
environment:
  sdk: ^3.6.0
workspace:
  - apps/shop_app
  - packages/*
```

```yaml
name: auth_domain                 # packages/auth_domain/pubspec.yaml
environment:
  sdk: ^3.6.0
resolution: workspace
```

Consequences to design around:

- One `pubspec.lock` and one `.dart_tool/package_config.json` exist for the workspace. A per-package lockfile is a bug, and `pub get` deletes stray ones.
- `pub get` errors when a `pubspec.yaml` sits between the root and a member without being declared. Keep packages directly under the declared glob or list them explicitly.
- Globs (`packages/*`) and nested workspaces are supported. Intra-workspace dependencies resolve from the local source but must still satisfy the constraint you declare, so keep `path` dependencies out of published packages.
- Extract a package for a real boundary: a second app, an independent release, a separate owner, or a rule that must fail the build. A package that only one app imports is a folder with extra steps.
- Use a package boundary first, an analyzer plugin second, and review convention last. A compile error is stronger than any lint.
- Workspace resolution and script running are separate problems. melos (8.10.0) runs scripts and versions packages; a `tool/` Dart program is the no-dependency alternative. Neither replaces `resolution: workspace`.
- Deferred loading inside a workspace fails silently when a deferred package is also eagerly reachable, and an app shipping only to Android and iOS gains nothing from it. Do not add it for structure.

## 7. Naming and configuration

- Files and folders use snake_case, and a file name matches the public class it declares (`sign_in_view_model.dart`). Packages use `{feature}_{layer}` (`auth_domain`, `auth_data`, `auth_presentation`) with an optional backend suffix (`auth_data_firebase`).
- A package exposes its API from `lib/{feature}_{layer}.dart` and keeps implementation under `lib/src/`. Import another package through its public entry, never through `src/`.
- Dart has no path aliases. A package import (`package:auth_domain/...`) is the alias; inside a package, relative imports are fine.
- One `analysis_options.yaml` at the app root, or one shared file at the workspace root. Start from `flutter_lints` 6.0.0 or `very_good_analysis` 11.0.0, which requires SDK 3.13 or later. Pick one set and do not stack includes from several sets.
- Analyzer plugins are configured in the top-level `plugins:` section of `analysis_options.yaml` and run in the IDE and in `dart analyze` or `flutter analyze`. Plugin-provided lints are off by default, so enable the ones you want under `diagnostics:`; suppress a single finding with `// ignore: plugin_name/code`.
- `import_rules` (0.0.8) is the current dependency-constraint plugin for layered and feature-isolated structures. Riverpod's `riverpod_lint` installs the same way; follow the package's own setup notes when the project already uses that library.
- `custom_lint` (0.8.1, last published 2025-09-09) is stale: it pins `analyzer ^8.0.0` while the ecosystem runs analyzer 14.x, so do not add it to a new project.
- `dart_code_metrics` is discontinued. Replace its metrics rules/flutter with analyzer plugins or with review.
- `dependency_validator` (5.1.0) catches missing, under-promoted, over-promoted, and unused dependencies. It is optional and belongs at the workspace root, not in every package.

## 8. Placement decision

| Question | Place in |
|---|---|
| Is it a route, a route table entry, or a route guard? | `lib/routing/` or the app package |
| Is it a screen or a widget only that screen uses? | the feature's `ui/<feature>/` or `presentation/<screen>/` |
| Is it UI state such as loading, filters, or submission status? | the ViewModel beside that screen |
| Is it ephemeral state of one widget, such as a scroll offset? | that widget's own `State` |
| Is it an entity, repository contract, or shared flow? | `domain/` for that feature |
| Is it an HTTP call, database query, or platform channel wrapper? | `data/services/`, one per data source |
| Is it a repository implementation or cache policy? | `data/repositories/`, or the feature's `data/` |
| Is it a transport model or JSON mapping? | `data/dtos/`, `data/mappers/`; never exported |
| Is it a pure helper used by two or more features? | `lib/utils/` or a shared utils package |
| Is it a theme token, primitive widget, or translation? | `lib/ui/core/` or an `app_ui` package |
| Is it a fake, a mock, or the widget test harness? | `testing/` |
| Do two apps need it unchanged? | a new workspace package |
| Is it signing, permissions, flavors, or build settings? | `ios/` and `android/` |

If ownership stays unclear, keep the module next to its only caller. Premature sharing is harder to reverse than local duplication.

## 9. Migration and validation

Move one vertical feature per change. In the same change, update imports, barrels, `pubspec.yaml` dependencies, tests, fakes, route wiring, and dependency injection; a half-moved feature leaves two sources of truth.

The order that survives review:

1. Create the destination layer or package with its public entry point.
2. Move the code and rewrite imports.
3. Register the new paths in routing and dependency wiring.
4. Add or tighten the boundary rule that prevents the old import.
5. Run `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and the test suite.
6. Delete the old files only after the replacement and its callers are verified.

Checking the result:

- `flutter analyze` reports nothing, including plugin diagnostics you enabled.
- A boundary check fails when you deliberately add a forbidden import. If the rule does not fail the build, it is documentation, not a boundary.
- `dependency_validator` or `dart pub deps` shows no dependency you did not intend, especially across features.
- The workspace still has exactly one lockfile and resolves from the root.
- Generated files were regenerated with build_runner, not edited. Dart macros were cancelled in 2025 and augmentations remain experimental, so build_runner stays the code generation path.

For a brownfield app, keep the current shape until a move is justified by ownership or a dependency rule, and never change folder layout and behavior in the same change. Moving a feature is safe to revert; renaming half the app is not.

## Sources

> Checked 2026-11-04. Version numbers are as of Flutter 3.47.9 stable and Dart 3.13.7.

| Source | URL | Supports | Checked |
|---|---|---|---|
| Flutter, Guide to app architecture | <https://docs.flutter.dev/app-architecture/guide> | two layers, optional domain layer, view and repository cardinality | 2026-11-04 |
| Flutter, Architecture recommendations | <https://docs.flutter.dev/app-architecture/recommendations> | graded recommendations and the conditional domain layer | 2026-11-04 |
| Flutter, Testing each layer case study | <https://docs.flutter.dev/app-architecture/case-study/testing> | fakes, `testApp()` harness, test tree mirroring `lib/` | 2026-11-04 |
| Flutter, Dependency injection case study | <https://docs.flutter.dev/app-architecture/case-study/dependency-injection> | provider wiring in the app layer | 2026-11-04 |
| Flutter samples, compass_app `lib/` listing | <https://api.github.com/repos/flutter/samples/contents/compass_app/app/lib> | `ui/` by feature, `data/` and `domain/` by type | 2026-11-04 |
| Flutter samples, compass_app `testing/` listing | <https://api.github.com/repos/flutter/samples/contents/compass_app/app/testing> | unshipped testing package contents | 2026-11-04 |
| VGV, Feature-First Clean Architecture | <https://verygood.ventures/blog/feature-first-clean-architecture> | layer packages, compile-time violation, fewer-than-three-features rule | 2026-11-04 |
| VGV Engineering, FFCA project structure | <https://engineering.verygood.ventures/architecture/ffca/project_structure> | dependency table, shared-versus-feature test, package naming, melos | 2026-11-04 |
| VGV Engineering, FFCA navigation | <https://engineering.verygood.ventures/architecture/ffca/navigation> | typed callbacks injected by the app for cross-feature navigation | 2026-11-04 |
| Dart, Pub workspaces | <https://dart.dev/tools/pub/workspaces> | SDK 3.6 floor, `workspace:` and `resolution: workspace`, single lockfile, stray-lock deletion | 2026-11-04 |
| Dart, Analyzer plugins | <https://dart.dev/tools/analyzer-plugins> | `plugins:` section, diagnostics gating, CLI and IDE execution | 2026-11-04 |
| pub.dev, `import_rules` | <https://pub.dev/api/packages/import_rules> | 0.0.8, dependency-constraint plugin on the analyzer plugin API | 2026-11-04 |
| pub.dev, `custom_lint` (stale, do not use) | <https://pub.dev/api/packages/custom_lint> | 0.8.1 from 2025-09-09, analyzer `^8.0.0` pin | 2026-11-04 |
| pub.dev, `dart_code_metrics` (discontinued) | <https://pub.dev/api/packages/dart_code_metrics> | package flagged discontinued | 2026-11-04 |
| pub.dev, `flutter_lints` | <https://pub.dev/api/packages/flutter_lints> | 6.0.0 lint set floor | 2026-11-04 |
| pub.dev, `very_good_analysis` | <https://pub.dev/api/packages/very_good_analysis> | 11.0.0 requiring SDK 3.13 | 2026-11-04 |
| pub.dev, `dependency_validator` | <https://pub.dev/api/packages/dependency_validator> | 5.1.0 unused and missing dependency checks | 2026-11-04 |
| pub.dev, `melos` | <https://pub.dev/api/packages/melos> | 8.10.0 for workspace scripts and versioning | 2026-11-04 |
| Dart, An update on Dart macros | <https://dart.dev/blog/an-update-on-dart-macros-data-serialization> | macros cancelled; build_runner remains the code generation path | 2026-11-04 |
| Flutter, JSON serialization | <https://docs.flutter.dev/data-and-backend/serialization/json> | code generation for medium and large projects | 2026-11-04 |
