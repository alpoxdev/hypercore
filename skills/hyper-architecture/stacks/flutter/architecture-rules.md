# Flutter Architecture Rules

Read before classifying any finding or enforcing a rule. This file owns the rule classes, the authority order, the blocking gates, the default tree, and the migration policy. It applies to Flutter and Dart apps whose primary targets are Android and iOS, with web and desktop only when the project declares them.

## Rule classes

- **Official**: behavior documented by Flutter or Dart for the installed framework version, including the dated official reference in `references/official/flutter/flutter-dart-2026-11-04.md`.
- **Safety**: blocking local policy for secrets, runtime input, permissions, signing, transport trust, and data loss.
- **Hypercore convention**: scalable default that may be adapted to evidenced project conventions.

Order: user/project authority, installed project evidence, applicable official behavior, safety policy, then Hypercore convention. Safety findings still require an explicit resolution.

The official app-architecture guide describes itself as guidelines, not steadfast rules/flutter, and grades every recommendation as strongly recommend, recommend, or conditional. A recommendation that is not a blocking gate may be adapted; a gate may not.

## Target dependency direction

```text
View (widget)
  -> ViewModel (ChangeNotifier, Notifier, or bloc; the project's choice)
    -> use-case (optional Domain layer)
      -> Repository
        -> Service
```

Dependencies point downward only. A View never imports a repository, service, transport DTO, or persistence adapter; it reads ViewModel state and calls ViewModel commands. A repository never depends on another repository, because coordination across entities belongs in a use-case or the ViewModel. A service is stateless, wraps one external data source, and is called by repositories. A use-case appears only when logic is shared by more than one ViewModel or combines several repositories.

The official relationship model matches this order: a View maps to one ViewModel, a ViewModel may use many repositories, and a View is limited to conditional display, animation, layout from device or window information, and simple routing.

Hypercore convention: cross-feature access goes through a deliberately small public API, and one feature's presentation layer never imports another feature's data layer.

## Blocking gates

Block or fix touched work that does any of the following. Each gate rests on an Official behavior or a blocking Safety policy; none of them is a style preference.

1. Leaves a runtime-read secret in the app: a compiled constant such as `String.fromEnvironment` or a `--dart-define` value, a bundled asset, a source literal, `shared_preferences`, or an unencrypted file. Build plumbing values passed at compile time are fine; a credential or private key that ships inside the binary is not.
2. Trusts deep-link parameters, push payloads, route `extra` values, persisted records, or API responses without validation at the boundary, or treats a router `redirect` or guard as authorization. Redirect decides screen flow; the server still authorizes every request.
3. Requests a runtime permission without the matching `Info.plist` key or `AndroidManifest.xml` declaration and user-facing purpose text, or ships flavor-specific permission declarations that merge into the wrong variant and trigger an App Store rejection such as `ITMS-90683`.
4. Commits signing material such as `key.properties`, a keystore, a `.p12`, or a provisioning profile, or runs signing, store upload, or publish actions without explicit authority.
5. Ships a `badCertificateCallback` that returns true, or another host or peer verification override, or claims that Android Network Security Config pinning and iOS App Transport Security pinning protect `dart:io` `HttpClient` traffic. They do not; platform HTTP clients are required when that policy must apply.
6. Imports `dart:io`, `dart:html`, or `dart:js`, or calls `Platform.is*`, in code that compiles for every target when web is a declared target. Use a conditional import on `dart.library.js_interop` or place the code behind a capability boundary instead.
7. Claims Android or iOS support from host unit tests, a widget test, or a web run alone when native behavior changed.
8. Uses an API that the dated official reference lists as removed or deprecated for the installed version, including `WillPopScope`, the legacy `SharedPreferences` API, and `flutter test --platform chrome` as a web validation path, without migrating to the documented replacement.
9. Adds a build hook or FFI dependency that downloads or executes a binary without hash verification, or whose download source is not audited.
10. Adopts a package whose published SDK constraint excludes the installed Flutter or Dart version, or whose platform minimum contradicts the project's declared minimums, without evidence that the mismatch is intentional.

## Scalable default

The small-app default follows the official sample layout: UI organized by feature, data and domain organized by type.

```text
lib/
  main.dart
  ui/<feature>/           # View and ViewModel for one feature
  data/
    repositories/         # domain-facing data access
    services/             # one per external source, stateless
  domain/                 # optional use-cases and shared models
  routing/                # one router configuration
  config/                 # validated build and runtime configuration
  utils/                  # focused framework-independent helpers
testing/                  # fakes, mocks, harness; never shipped
ios/                      # owned platform sources, committed and reviewed
android/                  # owned platform sources, committed and reviewed
```

Add folders only when they own real code. A small app starts with `ui/`, `data/`, `routing/`, and `config/`; `domain/` appears when use-cases exist, and `testing/` stays outside the shipped code path. When a flat `ui/` tree stops scaling, group by feature (`lib/features/<domain>/{presentation,domain,data}`) or split features into pub-workspace packages. Both keep the dependency direction above unchanged.

## Migration policy

Use vertical slices. Move one feature, update its imports and tests, run format, analyze, and test, then continue. Do not combine a structural move with a design-library migration or with a router replacement; one reversible change per step keeps failures attributable. Do not run repo-wide moves while aliases, generated code, native configuration, or ownership are still uncertain. Keep `ios/` and `android/` edits in ordinary review, because they are owned source rather than generated output. Preserve public behavior unless the request says otherwise.

## Completion gate

All critical Official and Safety findings must pass. A convention difference may ship only when existing project evidence justifies it explicitly. Report which platforms were built and tested (Android, iOS, and any declared web or desktop target), plus every skipped native check.

## Sources

> Checked 2026-11-04. Versions and API status in this file restate the dated official reference for Flutter 3.47.9 and Dart 3.13.7.

| Claim used here | Source |
|---|---|
| Layers, View to ViewModel and ViewModel to repository relationships, allowed View logic | https://docs.flutter.dev/app-architecture/guide |
| Recommendation strength levels (strongly recommend, recommend, conditional) | https://docs.flutter.dev/app-architecture/recommendations |
| Dependency injection with `package:provider` | https://docs.flutter.dev/app-architecture/case-study/dependency-injection |
| `Result` objects as a recommendation, not a requirement | https://docs.flutter.dev/app-architecture/design-patterns/result |
| Official sample layout: `ui/` by feature, `data/` and `domain/` by type | https://api.github.com/repos/flutter/samples/contents/compass_app/app/lib |
| State management starting point of provider with `ChangeNotifier` | https://docs.flutter.dev/data-and-backend/state-mgmt/simple |
| `--dart-define` values are compile-time constants inside the binary | https://dart.dev/libraries/core/environment-declarations |
| Storing secrets in an app is poor security practice | https://docs.flutter.dev/deployment/obfuscate |
| `key.properties` must stay private and out of source control | https://docs.flutter.dev/deployment/android |
| Build values passed with `--dart-define` in continuous delivery | https://docs.flutter.dev/deployment/cd |
| Runtime permission requests require platform configuration | https://pub.dev/packages/permission_handler |
| `dart:io` `HttpClient` trust anchors | https://api.flutter.dev/flutter/dart-io/HttpClient-class.html |
| No platform network policy is enforced on Dart-owned sockets | https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android |
| Platform HTTP clients for policy-backed requests | https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cupertino_http/README.md |
| `dart:io` import and `Platform.is*` behavior on web | https://docs.flutter.dev/platform-integration/web/faq |
| Conditional imports with `dart.library.js_interop` | https://dart.dev/interop/js-interop/package-web |
| Build hooks run at build time | https://dart.dev/tools/hooks |
| Legacy `SharedPreferences` API deprecation | https://raw.githubusercontent.com/flutter/packages/main/packages/shared_preferences/shared_preferences/README.md |
| `WillPopScope` deprecation and predictive back | https://docs.flutter.dev/release/breaking-changes/android-predictive-back |
| `flutter test --platform chrome` deprecation | https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/commands/test.dart |
| `go_router` is feature-complete and requires Flutter 3.44 or later | https://pub.dev/packages/go_router |
