# Native Platform and Security

Read when touching `android/`, `ios/`, build configuration, permissions, storage, secrets, HTTP trust, native interop, dependencies with native effects, or store delivery. Rule classes are Official, Safety, and Hypercore convention.

## Owned native directories

`android/` and `ios/` are ordinary committed source: generated once by `flutter create`, then owned by the app developer. Flutter has no step that rebuilds those directories from Dart configuration, so every file under them is reviewable code, not build output.

- Treat a second `flutter create` over an existing project, `flutter create .`, or any project-wide generator as a gated side effect. Diff the native tree first, and do not overwrite manual edits (signing config, `Info.plist` keys, schemes, Gradle modules) without an explicit decision.
- Keep Kotlin DSL: `android/settings.gradle.kts` and per-variant `build.gradle.kts`. Do not add a Groovy `build.gradle` beside them.
- Open and edit the iOS project through `ios/Runner.xcworkspace`, not the `.xcodeproj`, once Swift Package Manager or CocoaPods is in play.
- Never commit machine-local state: `android/local.properties`, `.gradle/`, `ios/Pods/`, `ios/.symlinks/`, `ios/Flutter/ephemeral/`, or build outputs.

## Native toolchain baseline

The 3.47 template ships Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, Java 17, `compileSdk` 36, `minSdk` 24, `targetSdk` 36, and NDK 28.2.13676358. Supported floors are Android API 24 through 37 and iOS 15 through 27; anything lower is outside the support matrix even if a build happens to succeed.

| Area | 3.47 state | Rule |
|---|---|---|
| Gradle / AGP / Kotlin | 9.3.1 / 9.1.0 / 2.4.0 | Below Gradle 8.14, AGP 8.11.1, or Kotlin 2.2.20 is an error; below Gradle 9.1, AGP 9.0.1, or Kotlin 2.3.20 is a warning. Do not downgrade to make an old plugin fit |
| Java | 17 (`JavaVersion.VERSION_17`, `jvmTarget = JVM_17`) | Keep 17 unless a plugin documents a higher floor with a reason |
| AGP 9 built-in Kotlin | The template writes `android.builtInKotlin=false` and `android.newDsl=false` as temporary flags; 3.47 supports `android.builtInKotlin=true`, and the `plugins {}` block no longer applies `kotlin-android` | Do not flip the flags silently; record the reason, and treat Kotlin Gradle Plugin support as scheduled for removal |
| iOS dependency manager | Swift Package Manager is the default from 3.44; CocoaPods stays in maintenance mode, and its spec registry becomes read-only on 2026-12-02 | Prefer plugins with SwiftPM support; a CocoaPods fallback needs a written reason |
| iOS scene lifecycle | UIScene is the default from 3.41; the template generates `SceneDelegate.swift` and `UIApplicationSceneManifest`, and `AppDelegate` adopts `FlutterImplicitEngineDelegate` | Keep the scene manifest when adding launch or lifecycle handling; do not return to the pre-scene app-delegate-only shape |

No minimum Xcode version is published in the documentation, so do not put a number into guides or CI images. Check the installed toolchain instead of inventing a floor.

## App configuration and flavors

Build-time configuration arrives through two channels, the native build (`android/`, `ios/`) and Dart compilation environment declarations. Neither is a secret store.

- Android flavors are `productFlavors` plus `flavorDimensions` inside `android/app/build.gradle.kts`, selected with `flutter run --flavor <name>` or `flutter build <target> --flavor <name>`. The real variant is flavor times build type. Use `applicationIdSuffix` to install two flavors side by side.
- iOS and macOS have no flavor concept. The mapping is one shared Xcode scheme per flavor, backed by custom configurations (`Debug-staging`, `Profile-staging`, `Release-staging`) based on `Debug.xcconfig`/`Release.xcconfig`, never on `Pods-Runner.xcconfig`. Flavor suffixes must be lowercase and schemes must be shared, or the CLI will not find them.
- Flavor-scoped assets and shaders use the pubspec `flavors:` key; `default-flavor` in the `flutter { }` block covers invocations without `--flavor`.
- Dart reads the flavor with `appFlavor`. It is `null` when no flavor was passed, and it is a compile-time constant baked into the binary, so it identifies a build but is not a security boundary.
- `--dart-define=K=V` and `--dart-define-from-file=<path>` are the supported way to pass build-time values, and the flag is correct for build plumbing such as a backend URL, a tenant id, or the Gradle-visible `-Pdart-defines` chain. The tool forwards them to Gradle and the frontend compiler, and the values are compile-time constants, which makes them public: a line such as `const endpoint = String.fromEnvironment('API_BASE_URL')` is public and compiled into the artifact, so it must never carry a secret.
- `--dart-define-from-file` accepts JSON when the content starts with `{`, otherwise an `.env`-style `key=value` file. Content must be UTF-8 or UTF-16, and a missing or unparsable path fails the build.
- Runtime secrets come from the backend or a short-lived token exchange. A value the app reads at runtime and must keep private belongs in none of a define, an asset, `appFlavor`, or source.
- Release builds use `--obfuscate --split-debug-info=<dir>` and archive the SYMBOLS file with the release. Obfuscation renames symbols, does not encrypt resources, does not stop reverse engineering, is unavailable on web, does not rename enum names, and breaks code that depends on `runtimeType.toString()`.
- A native configuration change needs a new build; hot reload and hot restart cannot validate it.

## Permissions

Every permission is a two-part contract: the native declaration or purpose string, and the runtime request with denial handling. A missing declaration terminates the app on iOS, and on Android the check fails without a visible prompt, so it is not a soft failure.

- `permission_handler` 13.0.2 compiles iOS permissions per dependency manager. With Swift Package Manager a permission is compiled in when its `Info.plist` usage-description key is present; with CocoaPods the Podfile `post_install` sets `GCC_PREPROCESSOR_DEFINITIONS` macros. Changing the manager changes which permission code exists in the binary.
- The plugin excludes every permission by default. Enable only what the app uses, and delete the usage-description key for everything else instead of leaving an unused key behind.
- A usage description in any one flavor's `Info.plist` merges into every configuration, which is grounds for App Store rejection (`ITMS-90683`). With multiple flavors, keep a `permission_handler.yaml` with `strict: true` and select the per-flavor plist with `dart run permission_handler_apple:select <flavor>`.
- Request at the point of user intent, explain the purpose, and render denied and blocked states. Test a fresh install, because a grant from an earlier run hides a missing declaration.
- On Android 13 and later, `POST_NOTIFICATIONS` is a runtime permission for non-exempt notifications. The plugin shows no dialog for notification or Bluetooth permissions and only reports OS settings, so build a status-read path and a settings route instead of assuming a prompt.
- On Android, `Permission.status` never reports `permanentlyDenied`; branch on the result of `request()`.
- `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` are deprecated from API 29 and removed at API 33; use the `READ_MEDIA_*` permissions. Request background location only after foreground location.
- `integration_test` cannot drive OS permission dialogs, so permission UX needs a manual or device-farm check rather than a claim of coverage.

## Storage and secrets

Storage choice follows sensitivity, and both choices sit behind an adapter owned by the data layer so tests and unsupported platforms get explicit behavior.

- `shared_preferences` is unencrypted (`NSUserDefaults`, `SharedPreferences`, or DataStore) and its own documentation says it must not hold critical data. Use it for non-sensitive preferences only, with `SharedPreferencesAsync` or `SharedPreferencesWithCache` for new code; the legacy `SharedPreferences` API is slated for deprecation.
- Small secrets go to `flutter_secure_storage` 11.2.0 or an evidenced equivalent: Keychain on iOS (choose `IOSOptions.accessibility` deliberately, since `first_unlock` and `unlocked` differ for background work) and Android Keystore with RSA-OAEP and AES-GCM on Android 10 and later. The Jetpack `encryptedSharedPreferences` backend is no longer recommended since 10.0.0, and the minimum Android SDK is 23.
- Android auto-backup restores secure-storage prefs without their key and throws `InvalidKeyException: Failed to unwrap key`; disable backup for the app or exclude the plugin's shared-prefs file.
- Handle the failures the adapter actually meets: unavailable user authentication, device change, locked keystore, corrupt entry, and data loss after an OS upgrade. A secure store is not durable storage, so re-authenticate instead of assuming the value survived.
- Never place a secret in source, assets, a `--dart-define` value, `appFlavor`, logs, analytics, or crash reports. The build-time credentials that do exist, such as `key.properties` and the upload keystore, belong to the build and never to the app or the repository.
- Define serialization and a version marker for persisted structures so an update can read, migrate, or discard old data.

## Network trust and pinning

Dart's default HTTP client is a socket client with its own trust evaluation, and it does not inherit the platform's certificate policy. This is where a security review quietly goes wrong.

- `dart:io` `HttpClient`, and `package:http`'s `IOClient` on top of it, trust certificates from Dart's own anchor set (a Mozilla-derived list) and apply neither Android Network Security Config trust anchors or `<pin-set>` entries, nor iOS App Transport Security `NSPinnedDomains`. Apple states that ATS does not apply to lower-level interfaces, and Flutter's breaking-change page notes that when the socket is owned by Dart, no policy is enforced.
- On Android, Dart reads the system CA snapshot and not the user store, so a corporate or user-installed root CA is not trusted, while a system root the user disabled is still trusted. Never promise that an enterprise proxy certificate works because the device trusts it.
- Cleartext blocking is partial, not a control: the policy is checked for platform sockets, per-domain `<base-config>` behaviour is unreliable, and open issues track both. Do not use it as proof that traffic is TLS-only.
- When platform network semantics matter (system trust, proxy, VPN, ATS or Network Security Config pins), inject a platform-stack client behind the shared `http.Client` interface at the composition root: `cupertino_http`'s `CupertinoClient` on iOS and macOS, `cronet_http`'s `CronetClient` on Android. cronet_http needs Google Play Services unless the app is built with `--dart-define=cronetHttpNoPlay=true`, which is a build value and not a secret.
- Platform-declarative pinning belongs in the native directories: `android/app/src/main/res/xml/network_security_config.xml` referenced from the manifest, and `Info.plist` `NSAppTransportSecurity` to `NSPinnedDomains` with `NSPinnedCAIdentities` or `NSPinnedLeafIdentities`, `NSIncludesSubdomains`, iOS 14 and later. Those settings govern traffic that goes through the platform stack; verify with a proxy and a deliberately wrong pin, because a config that is never exercised proves nothing.
- Dart has no first-class pinning API. Pinning in Dart means a custom `SecurityContext` trust set or `badCertificateCallback`, with an SPKI SHA-256 comparison, at least one backup pin, and a fail-closed branch. `badCertificateCallback: (_, __, ___) => true` is a defect in any shipped build, and a debug-only bypass stays behind `kReleaseMode`.
- Plain HTTP clients still need `android.permission.INTERNET` in the manifest; any socket the app opens needs it.

## Platform seams

Shared Dart code owns behavior; native code owns what only the platform can do. The seam is a typed interface, not a raw channel scattered across widgets.

- Pigeon is the recommended default for new Flutter-to-native APIs: it generates type-safe Dart, Kotlin/Java, and Swift/Objective-C from a schema. Raw `MethodChannel` stays supported for low-level messaging and legacy code; when used, give it a unique domain-prefixed name, invoke on the platform's main thread, and remember that the standard codec carries only a limited value set.
- Pigeon supports two transports, platform channels and native interop (FFI on iOS and macOS, JNI on Android), selected through `@ConfigurePigeon`. Native interop suits synchronous calls, high-frequency streaming, and background isolates. Pigeon does not model complex inheritance, so keep the schema flat.
- Check in the generated outputs or generate them in CI, pick one, and never hand-edit generated files.
- FFI packaging uses `flutter create --template=package_ffi` with `hook/build.dart` since 3.38; system libraries are resolved with `LookupInProcess()` and generated bindings use `@Native() external` against code assets.
- Decide platform behavior with `defaultTargetPlatform` and `kIsWeb`, not `dart:io`'s `Platform`. Tests see `TargetPlatform.android` unless overridden, so a platform branch is only real when a `TargetPlatformVariant` test covers it.
- Code that also targets web must not import `dart:io` in shared files; use conditional imports keyed on `dart.library.js_interop` and keep both implementations behind one interface.
- In a federated plugin or a multi-engine host (add-to-app), keep engine-scoped state on the instance rather than in static or global variables, and reference-count shared native singletons.
- Adaptive and responsive differ: responsive fits the layout into the space, adaptive makes the UI usable in that space. Choose per window size with `MediaQuery.sizeOf` or `LayoutBuilder`, not per device model.

## Dependencies and native effects

Adding a package is a native change as soon as it has a platform implementation: it edits Gradle files, the Podfile or the Swift package graph, and the plugin registrant. Treat that as a gated side effect with a reviewable diff.

- Before adding a plugin, check three things: SwiftPM support (CocoaPods is in maintenance mode and its registry goes read-only on 2026-12-02), compatibility with AGP 9 and built-in Kotlin, and whether the federated platform interface endorses the package or `pubspec.yaml` must list it directly.
- A build hook is arbitrary Dart that runs on developer machines and CI at build time. Hooks run in a semi-hermetic environment where only a named allowlist of variables passes through (`PATH`, `HOME`, proxy variables, `ANDROID_*`, `LIBCLANG_PATH`, `NIX_*`), and changing any of them invalidates the hook cache; register every file the hook reads in `output.dependencies` so caching stays correct.
- Hooks can compile or download native assets. Neither dart.dev nor the hooks package requires hash verification, so a dependency with a hook is a build-time code-execution dependency: pin the version, read `hook/build.dart`, and require SHA-256 pinning for any downloaded binary. A closed-source prebuilt library downloaded at build time needs the same treatment.
- Hooks cannot emit an Apple privacy manifest, and an FFI-only plugin may ship no bundle at all, so the app declares those required-reason APIs itself and re-audits on every upgrade.
- Re-audit after `flutter pub upgrade`: the native diff, the resolved Swift package graph, merged manifests, and the 16 KB check below all move when a transitive plugin changes.
- Installing dependencies, changing signing, and running store actions are side effects with credentials attached. When the capability or authorization is missing, name the exact command and the blocked input instead of reporting that it ran.

## Store and delivery requirements

Release gates are dated commitments, not preferences. Re-check them at the start of each release cycle instead of inheriting template defaults.

| Gate | Requirement | Check |
|---|---|---|
| Play target API | New apps and updates must target API 36 from 2026-08-31 (Wear and Automotive 35, TV and XR 34) | Pin `compileSdk` and `targetSdk` explicitly in `android/app/build.gradle.kts`; the 3.47 default of 36 satisfies the requirement today |
| 16 KB page size | Apps targeting API 35 and later must support 16 KB pages on 64-bit devices, and from 2027-02-01 a non-compliant update cannot be released | Check the release artifact, not the source: `zipalign -c -P 16 -v 4 app-release.apk` or APK Analyzer, plus `-Wl,-z,max-page-size=16384` and `-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON` for your own native code |
| Android signing | Play App Signing separates the upload key from the Google-held app signing key, which cannot be retrieved | Keep the keys distinct, keep `key.properties` and the keystore out of source control, and document the upload-key reset path |
| CI secrets | The keystore, its passwords, and the Play service-account JSON are injected, never committed | Decode a base64 keystore during install, read the service-account JSON from an environment variable, and never echo the values |
| iOS delivery | `flutter build ipa` produces an `.xcarchive` and an `.ipa`; `--export-method` selects non-App-Store distribution | Sign in Xcode, and add `--obfuscate --split-debug-info` to release builds |
| Privacy manifest | A `PrivacyInfo.xcprivacy` property list declares required-reason API use, and App Store Connect rejects undeclared use since 2024-05-01 | Ship the app's own manifest, then audit the build directory for plugin manifests |

- 16 KB is a per-release artifact check. No official page or release note states that the engine's bundled `libflutter.so` meets the requirement, and a plugin can reintroduce a non-aligned `.so` (a DataStore dependency did exactly that in 2026), so verify the built APK or AAB after every SDK or plugin bump.
- Apple's third-party SDK list includes Flutter itself and many Flutter plugins, at any version, including repackaged ones: among them `connectivity_plus`, `device_info_plus`, `file_picker`, `flutter_local_notifications`, `geolocator_apple`, `image_picker_ios`, `package_info_plus`, `path_provider`, `share_plus`, `shared_preferences_ios`, `sqflite`, `url_launcher_ios`, `video_player_avfoundation`, and `webview_flutter_wkwebview`. Each binary in the app needs its own manifest, and a third-party SDK cannot rely on the app's manifest.
- Flutter plugins ship manifests through CocoaPods `resource_bundles`, so the app's manifest covers the app's own usage. After `flutter pub upgrade`, run `find build/ios/iphoneos -name "*.xcprivacy"` and compare the result with the dependency list.

## Sources

> Checked 2026-11-04. Every row was read on that date against Flutter 3.47.9 stable.

| Claim | Source |
|---|---|
| Supported floors, Android 24 through 37 and iOS 15 through 27 | <https://docs.flutter.dev/reference/supported-platforms> |
| 3.47 template toolchain defaults (Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, compile and target 36, min 24) | <https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/android/gradle_utils.dart> |
| AGP 9 built-in Kotlin migration and the temporary `android.builtInKotlin=false` flags | <https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin> |
| Swift Package Manager as the iOS and macOS default from 3.44, and the CocoaPods read-only registry from 2026-12-02 | <https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers>, <https://flutter.dev/blog/whats-new-in-flutter-3-47> |
| UIScene as the default from 3.41, with `SceneDelegate.swift` and `UIApplicationSceneManifest` | <https://docs.flutter.dev/release/breaking-changes/uiscenedelegate> |
| Android `productFlavors`, `applicationIdSuffix`, and `--flavor` selection | <https://docs.flutter.dev/deployment/flavors> |
| iOS and macOS schemes and configurations as the flavor mapping | <https://docs.flutter.dev/deployment/flavors-ios> |
| `appFlavor` as a compile-time constant, null without `--flavor` | <https://api.flutter.dev/flutter/services/appFlavor-constant.html> |
| Compilation environment declarations as compile-time constants | <https://dart.dev/libraries/core/environment-declarations> |
| Build-time values passed with `--dart-define` in continuous delivery | <https://docs.flutter.dev/deployment/cd> |
| Secrets in an app are poor practice, and obfuscation does not stop reverse engineering | <https://docs.flutter.dev/deployment/obfuscate> |
| `key.properties` stays private and out of source control | <https://docs.flutter.dev/deployment/android> |
| Play target API 36 from 2026-08-31 | <https://developer.android.com/google/play/requirements/target-sdk> |
| 16 KB page-size requirements and the 2027-02-01 release block | <https://developer.android.com/guide/practices/page-sizes> |
| Play App Signing's upload key and app signing key split | <https://developer.android.com/studio/publish/app-signing> |
| `POST_NOTIFICATIONS` as a runtime permission on Android 13 and later | <https://developer.android.com/develop/ui/views/notifications/notification-permission> |
| `permission_handler` platform API and its default-excluded permissions | <https://pub.dev/packages/permission_handler> |
| `shared_preferences` must not store critical data | <https://github.com/flutter/packages> |
| `flutter_secure_storage` encrypted storage and Keystore backend | <https://pub.dev/packages/flutter_secure_storage> |
| `dart:io` `HttpClient` trust anchors | <https://api.flutter.dev/flutter/dart-io/HttpClient-class.html> |
| Dart-owned sockets are outside the platform network policy | <https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android> |
| Dart on Android ignores user-added CAs and keeps disabled system roots | <https://github.com/dart-lang/sdk/issues/48056> |
| `cupertino_http` and `cronet_http` as platform-stack clients behind `http.Client` | <https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cupertino_http/README.md> |
| Android network security config and pin sets | <https://developer.android.com/privacy-and-security/security-config> |
| iOS `NSPinnedDomains` and the ATS scope statement | <https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nspinneddomains> |
| Pigeon as the recommended default for new native interop, with raw channels for low-level use | <https://docs.flutter.dev/interop/pigeon> |
| Build and link hooks in a semi-hermetic environment | <https://dart.dev/tools/hooks> |
| `package_ffi` template and code-asset bindings since 3.38 | <https://docs.flutter.dev/interop/bind-native-code> |
| `PrivacyInfo.xcprivacy` as a property list and the required-reason API rule | <https://developer.apple.com/documentation/bundleresources/privacy-manifest-files> |
| Flutter and named Flutter plugins on the third-party SDK list | <https://developer.apple.com/support/third-party-SDK-requirements/> |
| Hooks cannot supply a privacy manifest | <https://github.com/flutter/flutter/issues/140966> |
| Flutter plugin manifests are packaged through CocoaPods `resource_bundles` | <https://github.com/flutter/flutter/issues/131940> |
| A transitive DataStore dependency shipped a non-16 KB-aligned `.so` and was reverted | <https://github.com/flutter/flutter/issues/182744> |
| `defaultTargetPlatform` and the test-environment Android default | <https://api.flutter.dev/flutter/foundation/defaultTargetPlatform.html> |

### Evidence grade

Official vendor pages and API references supply the version, policy, and platform-behavior rows. The Android trust-store behavior, the pinning gaps, and the privacy-manifest gap come from open issue threads, which grade lower and are stated as observed behavior rather than as guarantees. The engine's own 16 KB alignment is not established by any source, so the file requires an artifact check instead of asserting a result.
