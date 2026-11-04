# Testing and Validation

Read before claiming completion. This file owns the risk depth, the check order, the testing floors, the required scenarios, the architecture readback, and the completion record for a Flutter app whose primary targets are Android and iOS.

## Risk depth

Use `standard` depth for a new architecture or a material refactor: run the full check order and exercise the changed feature on both declared mobile platforms. Use `thorough` when native modules, permissions, auth or secrets, offline data, flavors or signing, or platform divergence change. `thorough` adds the platform step that the automated suite cannot perform: the real permission dialog, the real deep-link entry, the real flavor artifact, or the real signed configuration.

Record the trajectory as well as the final artifact: the Flutter and Dart version, the device or simulator and its OS version, the flavor, the environment values passed at build time, and whether the app was reinstalled or left in place. A green unit run does not show that a permission prompt appeared, and a green integration run does not show which platform it covered.

If a check cannot run because the host, a device or simulator, signing material, credentials, or authorization is unavailable, state the exact gap and use the strongest non-equivalent static check. Never report a host, VM, or web run as Android or iOS evidence. Never rerun a check repeatedly until it passes, and never weaken a check to make it pass.

## Check order

Run the chain from the repository root so that a later stage does not hide an earlier failure. Use the commands the repository defines plus the Flutter CLI; do not add scripts that the project does not already have.

0. Record the toolchain before changing anything: `flutter --version`, `flutter doctor -v`, and the `environment` block of `pubspec.yaml`. The SDK constraint decides the formatter style and the language features available to the change.
1. `dart format --output=none --set-exit-if-changed .` checks only and exits 1 when any file would be reformatted. The formatter style is selected by the language version, not by a flag: a package whose minimum SDK is 3.6 or lower gets the short style and a minimum of 3.7 or later gets the tall style. `--language-version` overrides the detection, and `formatter: page_width:` in `analysis_options.yaml` changes the width. The tall-style statement comes from the `dart_style` changelog, not from the `dart format` page, which documents only the 80-column default.
2. `flutter analyze` is the Flutter CLI form and replaces `dart analyze` for a Flutter project. It exits nonzero on errors and warnings but not on info-level issues. Add `dart analyze --fatal-infos` only when the repository already enforces that policy; do not introduce it in the middle of an unrelated change. The generated template excludes `build/`, `android/`, and `ios/` from analysis, so a clean analyzer run is not a statement about platform sources.
3. `dart fix --dry-run` lists the fixes the analyzer can apply without writing them. Review the list, then run `dart fix --apply` as a separate, reviewed step. `dart format --fix` was removed in `dart_style` 3.0.0, so `dart fix` is the single automated fix path and the dry run is the safe default in CI.
4. `flutter test --coverage` runs unit and widget tests and writes `coverage/lcov.info` by default. `--merge-coverage` combines several runs and needs `lcov` installed; `--branch-coverage` and `--coverage-package` narrow what is counted. The Flutter command has no built-in coverage threshold, so a percentage gate comes from the repository's own tooling or CI script, not from this command.
5. `flutter test integration_test` runs the integration suite with a device selected. Run Android and iOS separately, because a pass on one platform says nothing about the other:
   ```bash
   flutter test integration_test -d <android-device-id>
   flutter test integration_test -d <ios-device-id>
   ```
   Check the install state after each run. A leftover install can make the next run reuse stale data, and an uninstall between runs is part of reproducing a cold start.
6. Build the release artifacts: `flutter build appbundle` produces `build/app/outputs/bundle/release/app.aab`, and `flutter build ios --no-codesign` compiles the iOS app with codesigning disabled and skips IPA creation. The unsigned build proves that the project compiles and links; it is not a distributable archive. Build each declared flavor with `--flavor <name>` and the matching shared iOS scheme instead of only the default variant.
7. When the project uses `patrol` and keeps tests under `patrol_test/`, run `patrol test` and, on a new environment, `patrol doctor`. Patrol tests do not run through `flutter test`. Use patrol for the native dialogs, notifications, and permission flows that `integration_test` cannot drive, and do not duplicate journeys that already pass as widget tests.
8. Only when web is a declared target, run the integration suite in a browser with `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome`, with ChromeDriver on `PATH`. Use `-d web-server` when a visible browser is not wanted. A web run never stands in for a mobile platform check.
9. `flutter test --platform chrome` is deprecated and marked verbose-only in the 3.47.0 tool source; it targets the framework rather than an app. Keep it out of the chain and never count its result as web or platform evidence.

## Testing floors

The official taxonomy has three layers, and the cost rises in the opposite direction from confidence.

| Layer | Confidence | Maintenance | Dependencies | Speed | Use for |
|---|---|---|---|---|---|
| Unit | Low | Low | Few | Quick | Logic, mapping, validation, state transitions |
| Widget | Higher | Higher | More | Quick | Rendering, interaction, semantics, one component tree |
| Integration | Highest | Highest | Most | Slow | A few critical journeys end to end |

Write many unit and widget tests and only enough integration tests to cover the important journeys. An integration test is not a place to re-check logic that a faster layer already covers.

- **Unit per service, repository, and ViewModel.** Test a service against a fake transport, a repository against fake services, and a ViewModel as plain Dart with a fake repository. A ViewModel test needs no Flutter binding when the architecture is sound, so keep Flutter imports out of that test.
- **Fakes first.** Hand-write `implements <Interface>` classes and share them through a `testing/` folder. Reach for `mocktail` when a framework-adjacent type has no natural fake, such as the router, because it needs no code generation and no build step. Use Mockito only when the team already standardizes on generated mocks and accepts the `build_runner` step in CI.
- **Widget tests reuse the same fakes.** Pump the screen with a fake-driven ViewModel and a test router built from the same route list. A shared `testApp` helper should set `tester.view.devicePixelRatio = 1.0`, a fixed surface size, the app theme, localizations, and the router so that layout is deterministic.
- **Wrap plugin calls in your own API.** Host platform code is not loaded in unit and widget tests, so a direct channel call throws `MissingPluginException`. Fake your own wrapper instead of mocking the channel. A `TestDefaultBinaryMessenger` handler is the last resort because it is untyped and couples the test to the channel contract.
- **Integration only for critical journeys.** Put them in `integration_test/<name>_test.dart`, call `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, and keep the same `testWidgets` API. `integration_test` cannot interact with native platform UI such as permission dialogs, notifications, or platform views; use `patrol` or native Espresso and XCUITest for those steps.
- **Goldens are pixel-exact.** `matchesGoldenFile` is asynchronous, so await `expectLater`. The default `LocalFileComparator` compares pixel for pixel, and font rendering differs across operating systems and Flutter versions. The default test font draws boxes, so load real fonts through `FontLoader`, optionally from `flutter_test_config.dart`. Pin goldens to one CI operating system and one Flutter version, refresh with `flutter test --update-goldens`, and review every changed image. Tolerance requires a custom comparator and is a deliberate decision, not a default.

## Required scenarios

Run the rows that the change touches. Mark the others as not applicable with a reason rather than skipping them silently.

| Scenario | What to exercise | Evidence |
|---|---|---|
| Deep link cold start | Terminate the app, open the link from the OS on each platform, and confirm the same screen and parameters as a warm start. Check malformed and unknown links land on the error route. | Device logs and a screen capture |
| Permission denial | Grant, deny, deny permanently, and fresh install. Confirm the denied state still renders a usable screen, offers the documented recovery path, and does not crash. | Patrol or a manual platform run, because `integration_test` cannot press the native dialog |
| Flavor build | Build every declared flavor for Android and iOS. Confirm `appFlavor` and the build-time configuration resolve to the expected values, and that flavor-scoped assets and permission declarations land in the right variant. | The produced AAB and the matching iOS build log |
| Offline and error `Result` path | Make the repository return a failure or time out, then confirm the ViewModel reaches the error state, the UI shows it, and retry returns to the loaded state without an unhandled exception. | Unit test for the transition plus one widget test |
| Auth redirect refresh | Expire the session, confirm `refreshListenable` triggers re-evaluation, the guard redirects to sign-in, and the return path is preserved. Confirm the server still authorizes the next request. | Router log and the sign-in round trip |

A flavor identity, a compile-time constant, or a router redirect is not a security boundary. Test them as behavior, and keep authorization on the server.

## Architecture readback

Before claiming completion, confirm the change still satisfies the architecture rules:

- Routes stay thin and build screens without fetching data or owning state.
- Each feature owns its presentation code, and cross-feature access goes through a small public API.
- Dependencies point View to ViewModel to repository to service, with no cycle and no View importing a service or DTO.
- No runtime secret is added to `lib/`, an asset, `shared_preferences`, or a compiled constant.
- State lives at the intended owner, and persisted or restored state has an explicit owner.
- Platform seams stay behind a capability or wrapper, and no shared file imports `dart:io` or `dart:html` when web is declared.
- No orphaned file, dead route, or unused fake is left behind.

Testability is the cheapest architecture signal: a widget test that needs a real network, database, or platform channel means the boundary is in the wrong place. Review generated and platform diffs separately from authored source: `.g.dart` and `.freezed.dart` output, router builder output, and anything under `ios/` or `android/`.

## Completion record

Write the record in this exact shape, with the literal arrow sequence:

```text
Claim -> Risk -> Evidence -> Verification -> Result -> Caveat
```

Include the installed Flutter and Dart versions, the commands actually run with their outcome, the Android and iOS coverage, the checks skipped with their reason, and exactly one decision: `ship`, `iterate`, `caveated ship`, or `block`. Repair only failures that were observed, stop after two repair passes, and never weaken or delete a check to reach a pass. A caveat names the platform or scenario that was not verified, not a generic warning.

## Sources

> Checked 2026-11-04, the date this file was written against Flutter 3.47.9.

| Claim | Source |
|---|---|
| Unit, widget, and integration are the three layers, with many unit and widget tests and enough integration tests for the important journeys | <https://docs.flutter.dev/testing/overview> |
| `integration_test` cannot interact with native platform UI such as permission dialogs, notifications, or platform views | <https://docs.flutter.dev/testing/overview>, <https://docs.flutter.dev/cookbook/testing/integration/introduction> |
| Integration tests run with `flutter test integration_test/...` on Android and iOS devices, and the driver path remains for web | <https://docs.flutter.dev/testing/integration-tests>, <https://docs.flutter.dev/release/breaking-changes/flutter-driver-migration> |
| Layer-by-layer testing uses fakes for repositories, reuses them in widget tests, and mocks the router with mocktail | <https://docs.flutter.dev/app-architecture/case-study/testing> |
| The unit-test cookbook teaches Mockito with `@GenerateMocks` and `build_runner` | <https://docs.flutter.dev/cookbook/testing/unit/mocking> |
| Plugin calls should be wrapped in an app-owned API and faked, because host platform code is absent in unit and widget tests | <https://docs.flutter.dev/testing/plugins-in-tests> |
| `flutter analyze` replaces `dart analyze`, and `flutter test` replaces `dart test` | <https://docs.flutter.dev/reference/flutter-cli> |
| `dart format` writes 80 columns by default, supports `--set-exit-if-changed` with exit code 1, and reads `page_width` from `analysis_options.yaml` | <https://dart.dev/tools/dart-format> |
| The formatter uses the tall style for language version 3.7 or later and the short style at 3.6 or lower | <https://raw.githubusercontent.com/dart-lang/dart_style/master/CHANGELOG.md> |
| `dart analyze` fails on errors and warnings but not on info-level issues by default | <https://dart.dev/tools/dart-analyze> |
| `dart fix` supports `--dry-run` and `--apply`, and `dart format --fix` was removed in `dart_style` 3.0.0 | <https://dart.dev/tools/dart-fix>, <https://raw.githubusercontent.com/dart-lang/dart_style/master/CHANGELOG.md> |
| `flutter test` coverage flags, the `lcov.info` default, and the deprecated platform chrome mode | <https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/commands/test.dart> |
| `flutter build ios --no-codesign` disables codesigning and skips IPA creation | <https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_tools/lib/src/commands/build_ios.dart> |
| `flutter build appbundle` writes the release bundle to `build/app/outputs/bundle/release/app.aab` | <https://docs.flutter.dev/deployment/android> |
| `flutter build`/`flutter run` select a flavor with `--flavor`, and iOS maps flavors to shared Xcode schemes and configurations | <https://docs.flutter.dev/deployment/flavors>, <https://docs.flutter.dev/deployment/flavors-ios> |
| Golden matching is asynchronous and the default comparator is an exact pixel comparison | <https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html>, <https://api.flutter.dev/flutter/flutter_test/goldenFileComparator.html> |
| Golden files rendered with custom fonts differ across operating systems, and the default test font draws boxes | <https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html> |
| Patrol handles native interactions that `integration_test` cannot, requires Flutter 3.32 or later, and runs through its own CLI | <https://pub.dev/packages/patrol>, <https://patrol.leancode.co/documentation> |
| A coverage threshold flag belongs to a third-party CLI, not to `flutter test` | <https://cli.vgv.dev/docs/commands/test> |

### Evidence grade

`OFFICIAL + DERIVED` - the three layers, the tradeoff table, the fake-first layer testing, the `integration_test` native-UI limit, the CLI commands and exit behavior, the coverage flags, the build outputs, and the golden caveat restate the Flutter, Dart, pub.dev, and `dart_style` pages in the table. The check order, the Android-then-iOS split, the fakes-before-mocktail precedence, the explicit font loading, the required-scenario list, the architecture readback, and the completion record are Hypercore conventions derived from those pages. The deprecation of the platform chrome mode is read from the 3.47.0 tool source; no official page recommends that mode for app validation. Version numbers are as of Flutter 3.47.9 and Dart 3.13.7.
