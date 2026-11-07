# Flutter와 Dart 공식 근거 Snapshot

설치된 Flutter나 Dart version, API의 생애 주기 단계, platform 정책이 변경 방향을 가를 때 읽습니다. 이 snapshot은 이 패키지가 근거로 삼는 공식 주장과 확인 날짜, Flutter 앱 구조를 바꾸는 제거 항목을 기록합니다.

- last_verified_at: 2026-11-04
- `status`: Sources에 적은 Flutter, Dart, Android, Apple, pub.dev publisher 공식 page로 검토 완료
- `baseline`: Flutter 3.47.9 / Dart 3.13.7 / template toolchain Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, Java 17 / go_router 18.1.2 / material_ui 1.10.0 / cupertino_ui 1.1.6 / provider 6.1.5+1
- `refresh_when`: 다음 Flutter stable이 3.47을 대체할 때, framework 내장 Material과 Cupertino의 공식 deprecation이 시작될 때, 3.50의 Android Intent와 engine flag 변경이 stable에 들어올 때, package의 `flutter:`나 `sdk:` constraint가 움직일 때, project의 platform 하한이 바뀔 때
- `authority`: 근거일 뿐이며 user와 project 지시, 설치된 toolchain의 실제 출력이 우선합니다

## 목차

- 버전별 기준
- 주장과 출처
- 제거와 deprecation API
- 아키텍처 합성
- 검색 결과 사용 안전
- Sources

## 버전별 기준

아래 값은 각 release에 함께 공개된 template 기본값이며, 결과를 감수하고 project가 낮출 수 있는 최솟값이 아닙니다.

| Flutter | 출시 | Dart | iOS 최소 | Android minSdk / compile / target | Gradle / AGP / Kotlin | Java | 출처 |
|---|---|---|---|---|---|---|---|
| 3.47 (최신 3.47.9) | 2026-08-12 | 3.13 (3.47.9는 3.13.7) | 15 | 24 / 36 / 36 | 9.3.1 / 9.1.0 / 2.4.0 | 17 | [Release index](https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json), [gradle_utils.dart](https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/android/gradle_utils.dart), [FlutterExtension.kt](https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt) |
| 3.44 | 2026-05-18 | 3.12 | 13 | 24 / 36 / 36 | 9.1.0 / 9.0.1 / 2.3.20 | 17 | 같은 두 file의 tag 3.44.0 |
| 3.41 | 2026-02-11 | 3.11 | 13 | 24 / 36 / 36 | 8.14 / 8.11.1 / 2.2.20 | 17 | 같은 두 file의 tag 3.41.0 |

- **3.47.9**는 최신 stable patch(2026-10-29)이고 Dart 3.13.7을 싣습니다. 3.47.0은 2026-08-12에 Dart 3.13.0으로 이 계열을 열었습니다.
- **3.50은 beta뿐입니다**(`3.50.0-0.3.pre`). 3.50+로 적힌 문서는 예정 동작이므로 현재 동작으로 쓰지 않습니다.
- **3.47의 Android 지원 범위**는 API 24부터 37까지이고 API 23 이하는 지원하지 않습니다.
- **3.47의 iOS 지원 범위**는 iOS 15부터 27까지입니다.
- **3.47의 template toolchain**은 compileSdk 36, minSdk 24, targetSdk 36, Java 17, NDK 28.2.13676358, Kotlin DSL(`settings.gradle.kts`와 variant별 `build.gradle.kts`)이며, app template은 더 이상 `kotlin-android`를 적용하지 않습니다.
- **3.47의 version checker**는 Gradle 9.1, AGP 9.0.1, Kotlin 2.3.20, minSdk 24 아래에서 경고하고 Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20, minSdk 23 아래에서 실패합니다.
- **iOS 하한 이력**: 3.44와 3.41 template은 `IPHONEOS_DEPLOYMENT_TARGET = 13.0`을 고정하고 3.47은 15.0으로 올리며, macOS는 10.15에서 12.0으로 올라갑니다. deployment 안내서의 "iOS 13 and later" 문장은 낡았고 3.47을 설명하지 못합니다. 3.47 전용 출처 세 곳은 15로 일치합니다.
- **Xcode 최소 version은 공식 page 어디에도 없습니다.** tool source 상수만 있으므로 이 snapshot은 숫자 하한을 주장하지 않습니다. 설치된 toolchain을 읽어 확인합니다.
- **UIScene은 3.41부터 iOS 기본값**이고 3.47 template은 `SceneDelegate.swift`와 `Info.plist`의 `UIApplicationSceneManifest`를 만듭니다. legacy app delegate window 생애 주기를 쓰는 앱은 명시적으로 migration해야 합니다.
- **Dart 3.13(2026-08-12)**은 primary constructor를 더했고 dot shorthand는 그보다 앞선 Dart 3.10(2025-11-12)에 들어왔습니다. macro는 계속 중단 상태이므로 직렬화는 여전히 build_runner code 생성으로 처리합니다.
- **디자인 library는 opt-in입니다**: 3.47은 `material_ui` 1.10.0과 `cupertino_ui` 1.1.6을 공개하며 두 package 모두 `flutter: >=3.47.0`과 `sdk: ^3.13.0`을 선언합니다. 반면 `flutter create`는 아직 `package:flutter/material.dart`와 `uses-material-design: true`를 만듭니다. framework 내장 Material과 Cupertino는 3.44에서 code freeze에 들어갔고 공식 deprecation이 예정돼 있으며 release 번호는 아직 발표되지 않았습니다.
- **go_router 18.1.2**(2026-10-29, publisher flutter.dev)는 `flutter: >=3.44.0`을 선언합니다. `go_router_builder` 4.5.3은 더 높은 Flutter 하한을 선언하므로 3.44 project에서는 typed route가 해석되지 않습니다.
- **Store 정책**: Google Play는 2026-08-31부터 신규 앱과 update에 target API 36을 요구하고, 3.47 기본 targetSdk가 이미 이를 충족합니다. 그래도 명시적으로 고정합니다.
- **SwiftPM**은 3.44부터 iOS와 macOS native dependency를 기본 관리합니다. CocoaPods는 maintenance mode로 지원되며 제거되지 않았고, specs registry는 2026-12-02부터 read-only가 됩니다.
- **Impeller**는 iOS에서 Skia 대체가 없는 유일한 renderer이고 Android API 29 이상의 기본값입니다. web은 여전히 Skia 기반 backend로 그립니다.
- **3.50+ 예정**: Android release build가 Intent extras로 전달된 engine flag를 무시하고 Intent 발신자를 검증합니다. debug와 profile build는 영향받지 않습니다. 2026-11-04 기준 stable이 아니므로 앞으로의 지침으로만 다룹니다.

## 주장과 출처

| 주장 | 공식 출처 | 적용 범위와 주의 |
|---|---|---|
| stable channel의 최신 release는 Flutter 3.47.9(2026-10-29, Dart 3.13.7)이고 3.47보다 높은 stable은 없습니다. | [Release index](https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json), [Release notes](https://docs.flutter.dev/release/release-notes) | 기억한 version을 믿지 말고 index를 다시 읽습니다. |
| 3.47.0(2026-08-12, Dart 3.13.0), 3.44.0(2026-05-18, Dart 3.12.0), 3.41.0(2026-02-11, Dart 3.11.0)이 직전 stable minor 세 개입니다. | [Release index](https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json) | minor 안의 patch release는 그 minor의 toolchain 기본값을 공유합니다. |
| 3.47의 지원 deployment 범위는 Android 24부터 37까지, iOS 15부터 27까지입니다. | [Supported deployment platforms](https://docs.flutter.dev/reference/supported-platforms) | CI 검증 범위는 지원 문구보다 좁습니다. Android 24부터 36까지, iOS 18과 26입니다. |
| template 기본값(3.47)은 Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, compileSdk 36, minSdk 24, targetSdk 36, Java 17입니다. | [gradle_utils.dart](https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/android/gradle_utils.dart), [FlutterExtension.kt](https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt) | project 자신의 Gradle file을 읽습니다. template보다 뒤처지거나 앞설 수 있습니다. |
| SwiftPM은 3.44부터 iOS와 macOS native dependency를 기본 관리하고, CocoaPods는 maintenance mode로 남으며 registry는 2026-12-02부터 read-only가 됩니다. | [SwiftPM for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers), [What's new in 3.47](https://flutter.dev/blog/whats-new-in-flutter-3-47) | SwiftPM을 지원하지 않는 plugin은 여전히 CocoaPods로 해석됩니다. |
| `material_ui`와 `cupertino_ui` 1.0은 3.47에서 opt-in으로 나왔고, framework 내장 Material과 Cupertino는 release 번호가 공개되지 않은 채 공식 deprecation이 예정돼 있습니다. | [Material and Cupertino migration](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui), [material_ui](https://pub.dev/packages/material_ui) | `dart fix --apply --code=migrate_design_widgets`가 import를 바꾸고, `MaterialUiCompatibilityBridge`는 dependency의 공개 API 타입 불일치를 잇지 못합니다. |
| 앱 아키텍처 안내서는 "guidelines, not steadfast rules"이고 조언을 Strongly recommend, Recommend, Conditional로 나눕니다. | [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide), [Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations) | 권고이므로 어떤 권장안도 그 자체로 차단 규칙이 되지 않습니다. |
| 상태 관리 library는 강제되지 않습니다. provider와 `ChangeNotifier`가 문서상 출발점이고 Riverpod, Bloc, signals가 대안으로 적혀 있습니다. | [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple), [State management options](https://docs.flutter.dev/data-and-backend/state-mgmt/options) | project가 이미 쓰는 library를 유지하고, 무관한 작업에서 library를 갈아타지 않습니다. |
| 계층은 UI(View와 ViewModel), Data(Repository와 Service), Domain(use-case)이고 domain 계층은 Conditional입니다. | [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide) | View는 단순 조건 표시, animation, 기기 인지 layout, 단순 routing만 맡습니다. |
| go_router 18.1.2는 flutter.dev가 배포하고 feature-complete에 bug 수정 중심으로 설명됩니다. 요구 Flutter는 3.44 이상이고 3.47은 아니므로, 더 높은 숫자는 반박된 주장이며 디자인 library dependency에서 나옵니다. | [go_router API metadata](https://pub.dev/api/packages/go_router), [go_router README](https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/README.md) | "feature-complete"는 "maintenance mode"가 아닙니다. release는 2026-10-29까지 이어졌습니다. |
| named route는 대부분의 앱에 권장되지 않습니다. 작은 앱은 Navigator를 쓰고 deep link가 필요한 앱은 routing package를 씁니다. | [Navigation and routing](https://docs.flutter.dev/ui/navigation) | named route는 route 동작을 바꿀 수 없고 browser 앞으로 가기를 지원하지 않습니다. |
| Flutter 내장 deep link 처리기는 3.27부터 기본 활성입니다. 서드파티 link plugin을 쓰는 앱은 `flutter_deeplinking_enabled`나 `FlutterDeepLinkingEnabled`를 false로 둡니다. | [Deep links flag change](https://docs.flutter.dev/release/breaking-changes/deep-links-flag-change) | 3.27 이전 기본값은 반대였으므로 version 경계가 올바른 값을 정합니다. |
| `--dart-define`과 `--dart-define-from-file` 값은 앱 binary에 박히는 compile-time 상수입니다. secret은 앱에 두지 않으며, 난독화는 resource를 암호화하지도 reverse engineering을 막지도 못합니다. | [Environment declarations](https://dart.dev/libraries/core/environment-declarations), [Obfuscate Dart code](https://docs.flutter.dev/deployment/obfuscate) | build 배관 값은 정당하고, runtime이 읽는 secret이 금지 대상입니다. |
| 새 native interop에는 Pigeon, FFIgen, JNIgen이 권장됩니다. platform channel은 저수준과 기존 코드에 계속 쓸 수 있습니다. | [Pigeon](https://docs.flutter.dev/interop/pigeon), [Platform channels](https://docs.flutter.dev/platform-integration/platform-channels) | channel은 새 interface에서 덜 권장될 뿐 제거되지 않았습니다. |
| `dart:io`의 `HttpClient`와 `IOClient`는 Android Network Security Config의 trust anchor와 pin-set, iOS App Transport Security pinning을 적용받지 않습니다. | [HttpClient](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html), [Insecure HTTP policy](https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android) | platform 정책을 적용해야 하면 `cupertino_http`나 `cronet_http`를 `http.Client` 뒤에 주입합니다. |
| Google Play는 2026-08-31부터 target API 36을 요구하고, 16 KB page size를 지원하지 않는 update는 2027-02-01부터 거부합니다. | [Target API requirement](https://developer.android.com/google/play/requirements/target-sdk), [16 KB page sizes](https://developer.android.com/guide/practices/page-sizes) | page size 요구는 미래 날짜가 붙은 store 정책이며 3.47 동작에 대한 주장이 아닙니다. |
| `flutter test --platform chrome`은 3.47.0 tool source에서 verbose 전용이고 deprecated로 표시됩니다. web 검증은 `integration_test`와 `flutter drive -d chrome`으로 합니다. | [flutter_tools test.dart](https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/commands/test.dart), [Integration tests](https://docs.flutter.dev/testing/integration-tests) | 기본 검사 순서에 넣지 않습니다. |
| `integration_test`는 권한 대화상자, 알림, platform view 같은 native platform UI를 조작하지 못합니다. | [Testing overview](https://docs.flutter.dev/testing/overview), [Integration tests](https://docs.flutter.dev/testing/integration-tests) | native UI 검증에는 native test runner나 전용 UI test 도구가 필요합니다. |
| Dart macro 작업은 2025-01-29에 중단됐으므로 code 생성은 계속 build_runner 기반입니다. | [An update on Dart macros](https://dart.dev/blog/an-update-on-dart-macros-data-serialization) | `json_serializable`과 `built_value`가 문서상 직렬화 경로로 남습니다. |
| `shared_preferences`는 중요 데이터를 저장하면 안 되고, legacy `SharedPreferences` API는 `SharedPreferencesAsync`와 `SharedPreferencesWithCache`로 대체될 예정입니다. | [shared_preferences README](https://raw.githubusercontent.com/flutter/packages/main/packages/shared_preferences/shared_preferences/README.md) | cached API의 동기 getter는 isolate, engine instance, native 쓰기가 겹치면 낡은 값을 줍니다. |
| 공식 sample 앱은 `ui/`를 feature별로, `data/`와 `domain/`을 타입별로 두고, publish하지 않는 별도 `testing/` package를 쓰는 hybrid 구조입니다. | [Testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing) | 최상위 feature-first는 성장하는 앱을 위한 관례일 뿐 공식 권장안이 아닙니다. |
| `dart:html`, `dart:js`, `dart:js_util`, `package:js`는 deprecated이고 Wasm에서 지원되지 않습니다. `package:web`과 `dart:js_interop`이 대체하며 조건부 import 구분자는 `dart.library.js_interop`입니다. | [Web FAQ](https://docs.flutter.dev/platform-integration/web/faq), [Migrate to package:web](https://dart.dev/interop/js-interop/package-web) | web에서 compile돼야 하는 공용 code는 `dart:io`나 `Platform.is*`도 쓸 수 없습니다. |
| `WillPopScope`, `Navigator.willPop`, scoped will-pop callback은 `PopScope`와 `Route.popDisposition`으로 대체되며 deprecated입니다. Android predictive back에는 `android:enableOnBackInvokedCallback="true"`가 필요합니다. | [Android predictive back](https://docs.flutter.dev/release/breaking-changes/android-predictive-back), [PopScope](https://api.flutter.dev/flutter/widgets/PopScope-class.html) | `PopScope.onPopInvoked` 자체도 3.22.0-12.0.pre 이후 deprecated입니다. |
| `Navigator.onPopPage`는 3.24에서 `onDidRemovePage`로 대체됐고 pop 거부권은 `Page.canPop`과 `Page.onPopInvoked`로 옮겼습니다. | [Navigator page API](https://docs.flutter.dev/release/breaking-changes/navigator-and-page-api) | page 기반 API는 고급 경로이며 routing package가 이를 감쌉니다. |
| `analysis_options.yaml`의 `plugins:`로 선언하는 analyzer plugin이 지원되는 경계 강제 경로이고, pub workspace는 Dart 3.6부터 있습니다. | [Analyzer plugins](https://dart.dev/tools/analyzer-plugins), [Pub workspaces](https://dart.dev/tools/pub/workspaces) | `custom_lint`는 현재 analyzer보다 뒤처지고 `dart_code_metrics`는 중단됐으므로 새 작업에 둘 다 맞지 않습니다. |

## 제거와 deprecation API

| 제거 또는 deprecated | 대체 | 시점 | 결과 |
|---|---|---|---|
| `WillPopScope` | `PopScope(canPop: …)` | 3.16 deprecated | 뒤로 가기 취소를 검증하던 widget test는 `PopScope` 의미로 옮깁니다. |
| `Navigator.willPop` | `Route.popDisposition` | 3.16 | 판단이 route의 동기 getter가 됩니다. |
| `ModalRoute.addScopedWillPopCallback`, `removeScopedWillPopCallback`, `hasScopedWillPopCallback` | `registerPopEntry`, `unregisterPopEntry`, `popDisposition` | 3.16 | pop entry가 callback 등록을 대신합니다. |
| `Form.onWillPop` | `Form.canPop`과 `Form.onPopInvokedWithResult` | 3.16 | form 수준 guard가 같은 결과 보고 형태를 따릅니다. |
| `PopScope.onPopInvoked` | `PopScope.onPopInvokedWithResult` | 3.22.0-12.0.pre 이후 | handler가 `(bool didPop, Object? result)`를 읽습니다. |
| `Navigator.onPopPage` | `onDidRemovePage`, 거부권은 `Page.canPop`과 `Page.onPopInvoked` | 3.24 | page가 제거를 소유하고 정리 hook의 signature가 바뀝니다. |
| `RouteTransitionRecord.markForRemove` | `markForComplete` | 3.32 | custom route transition은 marker 호출을 고칩니다. |
| 기본 navigation으로서의 `MaterialApp.routes`와 `onGenerateRoute` | routing package와 `MaterialApp.router` | 현재 문서에서 권장하지 않음 | named route는 동작을 바꾸지 못하고 browser 앞으로 가기를 잃습니다. |
| 새 code의 `package:flutter/material.dart` | `package:material_ui/material_ui.dart` | 3.47 opt-in, framework 내장 library deprecation 예정, release 미발표 | `dart fix --apply --code=migrate_design_widgets`를 돌리고 dependency 타입 불일치는 직접 해결합니다. |
| `dart:html`, `dart:js`, `dart:js_util`, `dart:indexed_db`, `dart:svg`, `dart:web_audio`, `dart:web_gl`, `package:js` | `package:web`과 `dart:js_interop` | deprecated이고 SDK 제거 예정, Wasm 미지원 | 이들을 쓰는 code는 mobile과 web 공용 target에 둘 수 없습니다. |
| `hive` | `hive_ce` | `hive` 2.2.3은 `sdk: ">=2.12.0 <3.0.0"`을 선언해 Dart 3에서 해석되지 않음 | `hive_ce` 2.22.0이 유지되는 후속이며 `hydrated_bloc` 11이 의존합니다. |
| `custom_lint` | `plugins:` 아래 analyzer plugin | `custom_lint` 0.8.1은 `analyzer ^8.0.0`을 고정하고 생태계는 14.7.0 | 낡은 도구이고 공식 plugin 경로가 아닙니다. |
| `dart_code_metrics` | analyzer plugin과 내장 lint | 중단(`isDiscontinued: true`, 마지막 5.7.6) | 새 project에 넣지 않고 그 지표를 gate로 인용하지 않습니다. |
| `flutter test --platform chrome` | 일반 `flutter test`, 또는 `integration_test`와 `flutter drive -d chrome` | 3.47.0 tool source에서 verbose 전용 deprecated | 앱 수준 web test 전략이 아닙니다. |
| legacy `SharedPreferences` API | `SharedPreferencesAsync`와 `SharedPreferencesWithCache` | README가 legacy API의 향후 deprecation을 밝힘 | 새 code는 async API로 시작하고 호출 지점마다 migration합니다. |
| go_router 13 이하의 `GoRouteData.onExit` | 인자 두 개 `(BuildContext, GoRouterState)` | go_router 14.0.0 | route 이탈 guard가 state 인자를 읽습니다. |
| go_router의 대소문자 무시 URL matching | `GoRouter`의 `caseSensitive`, 기본값 true | go_router 15.0.0 | 대소문자만 다른 저장 link가 해석되지 않습니다. |
| navigation helper가 없는 go_router `GoRouteData` | `.location`, `.go()`, `.push()`, `.pushReplacement()`, `replace()` | go_router 16.0.0 | typed route에는 `go_router_builder` 3.0.0 이상이 필요합니다. |
| root observer 통지가 없는 go_router `ShellRoute` | `notifyRootObserver` | go_router 17.0.0 | 중첩 shell navigation이 기본으로 root observer에 도달합니다. |
| go_router 17 이하의 디자인 library import | `material_ui`와 `cupertino_ui` import | go_router 18.0.0, Flutter 3.44 이상 요구 | router가 standalone 디자인 package를 함께 끌어오므로 version 하한이 같이 움직입니다. |

## 아키텍처 합성

공식 안내서는 MVVM을 강한 권고로 제시하고 강제하지 않습니다. 이 패키지는 그 권고를 권고로 유지하고, Hypercore convention으로 표시한 관례를 더합니다. project는 공식 요구를 어기지 않고 그 관례를 바꿀 수 있습니다.

- 의존 방향, Hypercore convention: View에서 ViewModel로, 필요하면 use-case를 거쳐 Repository로, 다시 Service로 향합니다. Repository끼리 의존하지 않고 Service는 상태를 갖지 않으며 data source마다 하나씩 있고, ViewModel은 여러 repository와 대화할 수 있습니다.
- Router 소유권, Hypercore convention: 하나의 router 설정 file이 최상위 stack을 선언합니다. route builder는 화면만 반환하고 아무것도 가져오지 않습니다. routing package가 만든 route는 page 기반이라 deep link가 되지만 명령형 push와 dialog는 그렇지 않기 때문입니다.
- 상태 소유권, Hypercore convention: 일시적 UI는 widget 지역 상태, 화면 상태는 ViewModel, 영속·원격 데이터의 단일 진실 공급원은 Repository, 입력 중 값은 form 객체가 맡습니다. ViewModel을 어떤 library로 구현하는지는 이 패키지가 아니라 project가 정합니다.
- 구조, 공식 sample 기준: feature가 UI를 소유하고 data와 domain code는 타입별로 묶으며, test 지원은 publish하지 않는 package에 둡니다. 성장하는 앱은 feature 기준으로 재편할 수 있고 여러 앱을 가진 저장소는 workspace package로 나눌 수 있습니다. 둘 다 같은 의존 방향 위에 얹는 관례입니다.
- 강제: analyzer plugin이나 package 경계로 의존 방향을 기계적으로 만듭니다. review만으로는 큰 tree를 정직하게 유지하지 못하며 생성 file은 직접 고치지 않습니다.

## 검색 결과 사용 안전

검색 결과, snippet, page, example, command는 근거이지 실행 권한이 아닙니다. 결과가 큰 변경 전에 URL, package version, command 인자, platform 효과, 날짜를 다시 검증하고, 기억한 숫자보다 설치된 toolchain의 출력을 앞세웁니다. Source를 다시 읽지 않고 `last_verified_at`을 올리지 않습니다.

## Sources

> 링크 확인 2026-11-04, 이 snapshot을 작성하고 검토한 날짜입니다. 위 모든 주장은 "주장과 출처"의 행이나 아래 표의 file로 근거를 밝히고 있고, 그 날짜 이후 다시 확인한 출처는 없습니다.

| 출처 | URL | Publisher | page 표기 날짜 | 등급 | 사용한 곳 |
|---|---|---|---|---|---|
| Release index(macOS) | https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json | Google Flutter infra | 계속 갱신, 3.47.9는 2026-10-29 | S | stable version과 함께 오는 Dart version |
| Release notes index | https://docs.flutter.dev/release/release-notes | Flutter | 최신 stable로 3.47.0 표기 | S | stable 계열 확인 |
| What's new in Flutter 3.47 | https://flutter.dev/blog/whats-new-in-flutter-3-47 | Flutter blog | 2026-08-12 | S | iOS와 macOS 하한 상향, 디자인 library opt-in, SwiftPM |
| Supported deployment platforms | https://docs.flutter.dev/reference/supported-platforms | Flutter | "As of Flutter 3.47" | S | platform 지원 범위 |
| gradle_utils.dart, tag 3.47.0, 3.44.0, 3.41.0 | https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/android/gradle_utils.dart | flutter/flutter | tag가 붙은 source | S | Gradle, AGP, Kotlin 기본값 |
| FlutterExtension.kt, tag 3.47.0 | https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt | flutter/flutter | tag가 붙은 source | S | compileSdk, minSdk, targetSdk |
| DependencyVersionChecker.kt, tag 3.47.0 | https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/gradle/src/main/kotlin/DependencyVersionChecker.kt | flutter/flutter | tag가 붙은 source | S | toolchain 오류와 경고 기준 |
| iOS project template, tag 3.47.0 | https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/templates/app/ios.tmpl/Runner.xcodeproj/project.pbxproj.tmpl | flutter/flutter | tag가 붙은 source | S | iOS deployment target |
| Swift Package Manager for app developers | https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers | Flutter | 2026-08-31 갱신 | S | SwiftPM 기본값과 CocoaPods 상태 |
| Migrate to material_ui and cupertino_ui | https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui | Flutter | 3.47 breaking change | S | opt-in 상태, migration command, bridge 한계 |
| material_ui, pub.dev | https://pub.dev/packages/material_ui | pub.dev | 1.10.0 | S | package version과 SDK constraint |
| cupertino_ui, pub.dev | https://pub.dev/packages/cupertino_ui | pub.dev | 1.1.6 | S | package version과 SDK constraint |
| Guide to app architecture | https://docs.flutter.dev/app-architecture/guide | Flutter | 2026-05-05 | S | 계층, 관계 규칙, 권고 성격 |
| Architecture recommendations | https://docs.flutter.dev/app-architecture/recommendations | Flutter | 2026-05-05 | S | 권장 강도 단계 |
| Case study: testing each layer | https://docs.flutter.dev/app-architecture/case-study/testing | Flutter | 2026-05-05 | S | fake, router의 mocktail, package 배치 |
| Simple app state management | https://docs.flutter.dev/data-and-backend/state-mgmt/simple | Flutter | 날짜 없음 | S | 출발점인 provider와 ChangeNotifier |
| State management options | https://docs.flutter.dev/data-and-backend/state-mgmt/options | Flutter | 2026-07-31 | S | 대안 목록, 강제 없음 |
| Navigation and routing | https://docs.flutter.dev/ui/navigation | Flutter | 날짜 없음 | S | Navigator와 router 선택, named route 한계 |
| go_router API metadata | https://pub.dev/api/packages/go_router | pub.dev | 18.1.2, 2026-10-29 | S | version과 Flutter constraint |
| go_router README | https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/README.md | flutter/packages | main branch | S | feature-complete 문구 |
| go_router CHANGELOG | https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/CHANGELOG.md | flutter/packages | 18.1.2까지 | S | 14.0.0부터 18.0.0까지의 breaking change |
| go_router_builder API metadata | https://pub.dev/api/packages/go_router_builder | pub.dev | 4.5.3, 2026-10-30 | S | typed route builder 하한 |
| Deep links flag change | https://docs.flutter.dev/release/breaking-changes/deep-links-flag-change | Flutter | stable 3.27 | S | deep link 기본값과 해제 flag |
| Android predictive back | https://docs.flutter.dev/release/breaking-changes/android-predictive-back | Flutter | stable 3.16 | S | WillPopScope와 PopScope migration |
| Navigator page API | https://docs.flutter.dev/release/breaking-changes/navigator-and-page-api | Flutter | stable 3.24 | S | onPopPage 대체 |
| PopScope class | https://api.flutter.dev/flutter/widgets/PopScope-class.html | Dart API | 현재 SDK | A | canPop 의미, onPopInvoked deprecation |
| Environment declarations | https://dart.dev/libraries/core/environment-declarations | Dart | 2025-08-07 | S | dart-define의 compile-time 상수 |
| Obfuscate Dart code | https://docs.flutter.dev/deployment/obfuscate | Flutter | 3.47 | S | 앱 안 secret, 난독화 한계 |
| Pigeon | https://docs.flutter.dev/interop/pigeon | Flutter | 3.47 | S | 권장 interop 경로 |
| Platform channels | https://docs.flutter.dev/platform-integration/platform-channels | Flutter | 3.47 | S | channel 유지 |
| HttpClient class | https://api.flutter.dev/flutter/dart-io/HttpClient-class.html | Dart API | 현재 SDK | S | Dart client와 platform trust 설정 |
| Insecure HTTP connections policy | https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android | Flutter | 2026-07-31 | S | platform network 정책 범위 |
| cupertino_http README | https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cupertino_http/README.md | dart-lang | 3.1.1 | A | platform client 주입 |
| Target API requirement | https://developer.android.com/google/play/requirements/target-sdk | Google Play | 계속 갱신 | S | API 36 적용 시점 |
| 16 KB page sizes | https://developer.android.com/guide/practices/page-sizes | Android | 계속 갱신 | S | page size 시점 |
| flutter_tools test.dart, tag 3.47.0 | https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/commands/test.dart | flutter/flutter | tag가 붙은 source | S | chrome platform deprecation |
| Integration tests | https://docs.flutter.dev/testing/integration-tests | Flutter | 날짜 없음 | S | native UI 한계, web 실행 경로 |
| Testing overview | https://docs.flutter.dev/testing/overview | Flutter | 날짜 없음 | S | test 분류와 native UI 한계 |
| An update on Dart macros | https://dart.dev/blog/an-update-on-dart-macros-data-serialization | Dart | 2025-01-29 | S | macro 중단 |
| Dart SDK CHANGELOG | https://raw.githubusercontent.com/dart-lang/sdk/main/CHANGELOG.md | dart-lang | 3.13.0 항목 2026-08-12, 3.10.0 항목에 dot shorthand 추가 | S | Dart 3.13 primary constructor, Dart 3.10 dot shorthand |
| shared_preferences README | https://raw.githubusercontent.com/flutter/packages/main/packages/shared_preferences/shared_preferences/README.md | flutter/packages | main branch | S | legacy API deprecation, 데이터 한계 |
| hive API metadata | https://pub.dev/api/packages/hive | pub.dev | 2.2.3 | S | Dart 3 constraint |
| hive_ce API metadata | https://pub.dev/api/packages/hive_ce | pub.dev | 2.22.0, 2026-10-14 | S | 유지되는 후속 |
| custom_lint API metadata | https://pub.dev/api/packages/custom_lint | pub.dev | 0.8.1, 2025-09-09 | S | analyzer 고정과 노후화 |
| dart_code_metrics API metadata | https://pub.dev/api/packages/dart_code_metrics | pub.dev | 중단, 마지막 5.7.6 | S | 중단된 package |
| Analyzer plugins | https://dart.dev/tools/analyzer-plugins | Dart | 2026-06-24 | S | 지원되는 plugin 경로 |
| Pub workspaces | https://dart.dev/tools/pub/workspaces | Dart | Dart 3.13.7 반영 | S | 3.6부터의 workspace package |
| Web FAQ | https://docs.flutter.dev/platform-integration/web/faq | Flutter | 2026-10-24 | S | web의 dart:io와 Platform 한계 |
| Migrate to package:web | https://dart.dev/interop/js-interop/package-web | Dart | 2026-09-11 | S | legacy web library와 조건부 import |
| Impeller | https://docs.flutter.dev/perf/impeller | Flutter | 날짜 없음 | S | platform별 renderer |
| Stricter Android Intent verification | https://docs.flutter.dev/release/breaking-changes/stricter-android-entrypoint-intent-verification | Flutter | 3.50.0-0.1.pre에 포함, stable 아님 | S | 예정된 Intent 발신자 검증 |
| Restrict Android engine flags in release mode | https://docs.flutter.dev/release/breaking-changes/restrict-android-engine-flags-release-mode | Flutter | 3.50.0-0.1.pre에 포함, stable 아님 | S | 예정된 engine flag 제한 |
| UIScene adoption | https://docs.flutter.dev/release/breaking-changes/uiscenedelegate | Flutter | 3.41부터 기본 | S | iOS scene 생애 주기 기본값 |

### Evidence grade

모든 행은 2026-11-04에 읽은 vendor 공개 page이거나 vendor 저장소 file이므로 이 패키지에서 PRIMARY입니다. `A` 등급 두 행은 release provenance 없이 같은 동작을 적은 API reference page입니다. pub.dev publisher page는 version과 SDK constraint에만 권위가 있고 동작의 근거는 아닙니다. Xcode 최소 version은 공식 page가 없어 이 snapshot이 숫자를 적지 않습니다. "아키텍처 합성"의 항목은 Hypercore convention으로 표시했고 vendor 등급을 붙이지 않습니다.
