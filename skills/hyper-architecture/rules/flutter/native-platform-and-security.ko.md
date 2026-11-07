# 네이티브 플랫폼과 보안

`android/`, `ios/`, 빌드 설정, 권한, 저장소, 비밀값, HTTP 신뢰, 네이티브 연동, 네이티브 효과가 있는 의존성, 스토어 출시를 다룰 때 읽습니다. 규칙 등급은 Official, Safety, Hypercore convention입니다.

## 직접 소유하는 네이티브 디렉터리

`android/`와 `ios/`는 `flutter create`가 한 번 생성한 뒤 앱 개발자가 소유하는 일반 커밋 소스입니다. Flutter에는 Dart 설정에서 두 디렉터리를 다시 만들어 내는 단계가 없으므로, 그 아래 모든 파일은 빌드 산출물이 아니라 리뷰 대상 코드입니다.

- 기존 프로젝트 위에서 `flutter create`를 다시 실행하는 일, `flutter create .`, 프로젝트 전체를 다시 쓰는 생성기를 모두 승인이 필요한 부수 효과로 다룹니다. 먼저 네이티브 트리의 변경 내용을 확인하고, 서명 설정, `Info.plist` 키, scheme, Gradle 모듈 같은 수동 변경을 명시적 결정 없이 덮어쓰지 않습니다.
- Kotlin DSL을 유지합니다. `android/settings.gradle.kts`와 variant별 `build.gradle.kts`를 쓰고, 그 옆에 Groovy `build.gradle`을 추가하지 않습니다.
- iOS 프로젝트는 Swift Package Manager나 CocoaPods가 붙은 뒤에는 `.xcodeproj`가 아니라 `ios/Runner.xcworkspace`로 열어 편집합니다.
- 로컬 머신 상태는 커밋하지 않습니다. `android/local.properties`, `.gradle/`, `ios/Pods/`, `ios/.symlinks/`, `ios/Flutter/ephemeral/`, 빌드 산출물이 여기에 해당합니다.

## 네이티브 툴체인 기준선

3.47 템플릿은 Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, Java 17, `compileSdk` 36, `minSdk` 24, `targetSdk` 36, NDK 28.2.13676358을 씁니다. 지원 하한은 Android API 24부터 37까지, iOS 15부터 27까지입니다. 이보다 낮은 대상은 빌드가 우연히 성공하더라도 지원 범위 밖입니다.

| 영역 | 3.47 상태 | 규칙 |
|---|---|---|
| Gradle / AGP / Kotlin | 9.3.1 / 9.1.0 / 2.4.0 | Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20 미만은 오류입니다. Gradle 9.1, AGP 9.0.1, Kotlin 2.3.20 미만은 경고입니다. 오래된 플러그인을 맞추려고 버전을 낮추지 않습니다 |
| Java | 17 (`JavaVersion.VERSION_17`, `jvmTarget = JVM_17`) | 플러그인이 근거와 함께 더 높은 하한을 요구하지 않는 한 17을 유지합니다 |
| AGP 9 내장 Kotlin | 템플릿이 `android.builtInKotlin=false`와 `android.newDsl=false`를 임시 플래그로 넣습니다. 3.47은 `android.builtInKotlin=true`를 지원하고 `plugins {}` 블록은 더 이상 `kotlin-android`를 적용하지 않습니다 | 플래그를 조용히 뒤집지 않고 이유를 기록합니다. Kotlin Gradle Plugin 지원은 제거 예정으로 봅니다 |
| iOS 의존성 관리자 | 3.44부터 Swift Package Manager가 기본입니다. CocoaPods는 maintenance mode로 남고 spec registry는 2026-12-02부터 read-only입니다 | SwiftPM을 지원하는 플러그인을 우선합니다. CocoaPods fallback에는 기록된 이유가 필요합니다 |
| iOS scene 수명주기 | 3.41부터 UIScene이 기본입니다. 템플릿은 `SceneDelegate.swift`와 `UIApplicationSceneManifest`를 생성하고 `AppDelegate`는 `FlutterImplicitEngineDelegate`를 채택합니다 | 실행이나 수명주기 처리를 추가해도 scene manifest를 유지합니다. scene 이전의 app delegate 단독 형태로 돌아가지 않습니다 |

문서에 최소 Xcode 버전이 공개되어 있지 않으므로 안내 문서나 CI 이미지에 숫자를 적지 않습니다. 근거 없는 하한을 만들지 말고 설치된 툴체인을 확인합니다.

## 앱 설정과 flavor

빌드 시점 설정은 네이티브 빌드(`android/`, `ios/`)와 Dart 컴파일 환경 선언 두 경로로 들어옵니다. 어느 쪽도 비밀값 저장소가 아닙니다.

- Android flavor는 `android/app/build.gradle.kts` 안의 `productFlavors`와 `flavorDimensions`이고, `flutter run --flavor <name>`이나 `flutter build <target> --flavor <name>`으로 고릅니다. 실제 variant는 flavor와 빌드 타입의 곱입니다. 두 flavor를 나란히 설치하려면 `applicationIdSuffix`를 씁니다.
- iOS와 macOS에는 flavor 개념이 없습니다. flavor마다 공유 scheme 하나를 두고, `Debug.xcconfig`/`Release.xcconfig`를 기반으로 한 사용자 configuration(`Debug-staging`, `Profile-staging`, `Release-staging`)을 붙이는 방식입니다. `Pods-Runner.xcconfig`를 기반으로 하지 않습니다. flavor 접미사는 소문자여야 하고 scheme은 Shared여야 하며, 그렇지 않으면 CLI가 찾지 못합니다.
- flavor별 asset과 shader는 pubspec의 `flavors:` 키로 나누고, `flutter { }` 블록의 `default-flavor`가 `--flavor` 없는 호출을 받습니다.
- Dart에서는 `appFlavor`로 flavor를 읽습니다. `--flavor` 없이 빌드하면 `null`이고, 컴파일 타임 상수로 바이너리에 들어가므로 빌드를 식별할 뿐 보안 경계가 되지 않습니다.
- `--dart-define=K=V`와 `--dart-define-from-file=<path>`는 빌드 시점 값을 넘기는 정식 경로이고, 백엔드 URL, 테넌트 id, Gradle로 전달되는 `-Pdart-defines` 연결 같은 빌드 배관에는 이 플래그가 맞습니다. 도구는 값을 Gradle과 프런트엔드 컴파일러로 넘기고, 값은 컴파일 타임 상수이므로 공개된 것으로 봅니다. `const endpoint = String.fromEnvironment('API_BASE_URL')` 같은 줄은 공개 값이고 산출물에 컴파일되므로, secret을 담으면 안 됩니다.
- `--dart-define-from-file`은 내용이 `{`로 시작하면 JSON을, 아니면 `.env` 형식 `key=value`를 받습니다. UTF-8이나 UTF-16이어야 하고, 경로가 없거나 파싱에 실패하면 빌드가 중단됩니다.
- 런타임 secret은 백엔드나 짧은 수명의 토큰 교환에서 받습니다. 앱이 실행 중에 읽어야 하고 비공개여야 하는 값은 define, asset, `appFlavor`, 소스 어디에도 두지 않습니다.
- 릴리스 빌드는 `--obfuscate --split-debug-info=<dir>`를 쓰고 SYMBOLS 파일을 릴리스와 함께 보관합니다. 난독화는 심볼 이름을 바꿀 뿐 리소스를 암호화하지 않고, 리버스 엔지니어링을 막지 못하며, 웹에서는 쓸 수 없고, enum 이름은 바꾸지 않으며, `runtimeType.toString()`에 의존하는 코드를 깨뜨립니다.
- 네이티브 설정 변경에는 새 빌드가 필요합니다. hot reload와 hot restart로는 확인할 수 없습니다.

## 권한

모든 권한은 네이티브 선언이나 목적 문자열, 그리고 런타임 요청과 거부 처리를 합친 두 부분 계약입니다. 선언이 빠지면 iOS에서는 앱이 종료되고, Android에서는 눈에 보이는 프롬프트 없이 검사가 실패합니다. 조용히 넘어가는 실패가 아닙니다.

- `permission_handler` 13.0.2는 iOS 권한을 의존성 관리자에 따라 다르게 컴파일합니다. Swift Package Manager에서는 `Info.plist`의 usage-description 키가 있으면 그 권한이 컴파일되고, CocoaPods에서는 Podfile `post_install`이 `GCC_PREPROCESSOR_DEFINITIONS` 매크로를 설정합니다. 관리자를 바꾸면 바이너리에 들어가는 권한 코드가 달라집니다.
- 플러그인은 기본적으로 모든 권한을 제외합니다. 앱이 쓰는 것만 켜고, 쓰지 않는 권한은 usage-description 키를 지웁니다. 쓰지 않는 키를 남겨 두지 않습니다.
- 어느 한 flavor의 `Info.plist`에 있는 usage description은 모든 configuration에 병합되고, 이는 App Store 거절 사유(`ITMS-90683`)입니다. flavor가 여러 개면 `strict: true`를 둔 `permission_handler.yaml`을 두고 `dart run permission_handler_apple:select <flavor>`로 flavor별 plist를 고릅니다.
- 사용자 의도가 생기는 지점에서 요청하고 목적을 설명하며, 거부와 차단 상태를 화면에 반영합니다. 이전 실행에서 받은 허용이 빠진 선언을 가리므로 새 설치 상태로 시험합니다.
- Android 13 이상에서 `POST_NOTIFICATIONS`는 예외가 아닌 알림에 필요한 런타임 권한입니다. 이 플러그인은 알림과 Bluetooth 권한에 대화상자를 띄우지 않고 OS 설정값만 돌려주므로, 프롬프트를 가정하지 말고 상태 조회 경로와 설정 화면 이동을 만듭니다.
- Android에서 `Permission.status`는 `permanentlyDenied`를 보고하지 않습니다. `request()`의 결과로 분기합니다.
- `READ_EXTERNAL_STORAGE`와 `WRITE_EXTERNAL_STORAGE`는 API 29부터 deprecated이고 API 33에서 제거됐습니다. `READ_MEDIA_*` 권한을 씁니다. 백그라운드 위치는 포그라운드 위치를 요청한 뒤에 요청합니다.
- `integration_test`는 OS 권한 대화상자를 조작하지 못하므로, 권한 UX는 수동 확인이나 기기 팜으로 검증하고 테스트가 덮었다고 주장하지 않습니다.

## 저장소와 비밀값

저장 위치는 민감도에 따라 정하고, 두 선택 모두 데이터 계층이 소유한 adapter 뒤에 두어 테스트와 미지원 플랫폼이 명시적 동작을 갖게 합니다.

- `shared_preferences`는 암호화되지 않고(`NSUserDefaults`, `SharedPreferences`, DataStore) 자체 문서가 중요 데이터에 쓰지 말라고 합니다. 민감하지 않은 설정에만 쓰고, 새 코드는 `SharedPreferencesAsync`나 `SharedPreferencesWithCache`를 씁니다. 레거시 `SharedPreferences` API는 deprecation 예정입니다.
- 작은 secret은 `flutter_secure_storage` 11.2.0이나 근거가 있는 동등 구현에 넣습니다. iOS는 Keychain이고(`IOSOptions.accessibility`를 의도적으로 고릅니다. `first_unlock`과 `unlocked`는 백그라운드 작업에서 다릅니다), Android 10 이상은 Android Keystore의 RSA-OAEP와 AES-GCM입니다. Jetpack `encryptedSharedPreferences` 백엔드는 10.0.0부터 권장되지 않고, 최소 Android SDK는 23입니다.
- Android 자동 백업은 키 없이 secure storage의 shared-prefs를 복원해 `InvalidKeyException: Failed to unwrap key`를 던집니다. 앱의 백업을 끄거나 플러그인의 shared-prefs 파일을 제외합니다.
- adapter가 실제로 마주치는 실패를 처리합니다. 사용자 인증 불가, 기기 변경, 잠긴 keystore, 손상된 항목, OS 업그레이드 뒤 데이터 소실입니다. secure store는 영구 저장소가 아니므로 값이 남아 있다고 가정하지 말고 다시 인증합니다.
- secret을 소스, asset, `--dart-define` 값, `appFlavor`, 로그, 분석, 크래시 리포트에 두지 않습니다. `key.properties`와 업로드 keystore처럼 실제로 존재하는 빌드 자격 증명은 빌드에 속하고, 앱이나 저장소에 속하지 않습니다.
- 저장 구조에는 직렬화와 버전 표시를 두어 업데이트가 옛 데이터를 읽거나 마이그레이션하거나 버릴 수 있게 합니다.

## 네트워크 신뢰와 인증서 고정

Dart의 기본 HTTP 클라이언트는 자체 신뢰 평가를 하는 소켓 클라이언트이고, 플랫폼의 인증서 정책을 물려받지 않습니다. 보안 검토가 조용히 틀리는 지점이 여기입니다.

- `dart:io`의 `HttpClient`와 그 위의 `package:http` `IOClient`는 Dart 자체 trust anchor(Mozilla 기반 목록)로 인증서를 신뢰하고, Android Network Security Config의 trust anchor나 `<pin-set>`을 적용하지 않으며 iOS App Transport Security의 `NSPinnedDomains`도 적용하지 않습니다. Apple 문서는 ATS가 하위 수준 인터페이스에 적용되지 않는다고 밝히고, Flutter의 breaking-change 문서도 소켓이 Dart 소유이면 정책이 적용되지 않는다고 적습니다.
- Android에서 Dart는 시스템 CA 스냅샷을 읽고 사용자 저장소는 읽지 않으므로, 기업이나 사용자가 설치한 루트 CA를 신뢰하지 않습니다. 반대로 사용자가 비활성화한 시스템 루트는 여전히 신뢰합니다. 기기가 신뢰한다는 이유로 사내 프록시 인증서가 동작한다고 약속하지 않습니다.
- 평문 차단은 부분적이고 통제 수단이 아닙니다. 플랫폼 소켓에는 평문 정책이 적용되지만 도메인별 `<base-config>` 동작은 신뢰하기 어렵고, 두 문제 모두 열린 이슈로 추적됩니다. 트래픽이 TLS만 쓴다는 증거로 쓰지 않습니다.
- 시스템 신뢰, 프록시, VPN, ATS나 Network Security Config pin처럼 플랫폼 네트워크 의미가 필요하면 공용 `http.Client` 인터페이스 뒤에 플랫폼 스택 클라이언트를 주입합니다. iOS와 macOS는 `cupertino_http`의 `CupertinoClient`, Android는 `cronet_http`의 `CronetClient`입니다. cronet_http는 `--dart-define=cronetHttpNoPlay=true`로 빌드하지 않으면 Google Play Services가 필요하고, 이 값은 secret이 아닌 빌드 값입니다.
- 플랫폼 선언형 pinning은 네이티브 디렉터리에 둡니다. manifest에서 참조하는 `android/app/src/main/res/xml/network_security_config.xml`과 `Info.plist`의 `NSAppTransportSecurity`에서 `NSPinnedDomains`로 이어지는 설정(`NSPinnedCAIdentities` 또는 `NSPinnedLeafIdentities`, `NSIncludesSubdomains`, iOS 14 이상)입니다. 이 설정은 플랫폼 스택을 지나는 트래픽에 적용되므로, 프록시와 일부러 틀린 pin으로 확인합니다. 실행되지 않는 설정은 아무것도 증명하지 못합니다.
- Dart에는 전용 pinning API가 없습니다. Dart에서 pinning은 SPKI SHA-256 비교, 백업 pin 하나 이상, 실패 시 닫는 분기를 갖춘 `SecurityContext` trust set이나 `badCertificateCallback`으로만 합니다. `badCertificateCallback: (_, __, ___) => true`는 출시 빌드에 있으면 결함입니다. 디버그 전용 우회는 `kReleaseMode` 뒤에 둡니다.
- 평문 HTTP 클라이언트도 manifest에 `android.permission.INTERNET`이 필요합니다. 앱이 여는 소켓에는 이 권한이 필요합니다.

## 플랫폼 경계

공유 Dart 코드가 동작을 소유하고, 네이티브 코드는 플랫폼만 할 수 있는 일을 소유합니다. 경계는 typed interface이고, 위젯 곳곳에 흩어진 raw channel이 아닙니다.

- 새 Flutter↔네이티브 API에는 Pigeon이 권장 기본값입니다. 스키마에서 type-safe Dart, Kotlin/Java, Swift/Objective-C를 생성합니다. raw `MethodChannel`은 저수준 메시징과 기존 코드에 계속 쓸 수 있습니다. 쓸 때는 도메인 접두사를 붙인 고유 이름을 붙이고, 플랫폼 메인 스레드에서 호출하고, 표준 코덱이 제한된 값 종류만 전달한다는 점을 기억합니다.
- Pigeon은 `@ConfigurePigeon`으로 고르는 두 전송을 지원합니다. platform channel과 native interop(iOS와 macOS는 FFI, Android는 JNI)입니다. native interop은 동기 호출, 고빈도 스트리밍, 백그라운드 isolate에 맞습니다. Pigeon은 복잡한 상속을 모델링하지 못하므로 스키마를 평평하게 유지합니다.
- 생성 파일은 저장소에 커밋하거나 CI에서 생성합니다. 둘 중 하나를 정하고, 생성 파일을 직접 고치지 않습니다.
- FFI 패키징은 3.38부터 `hook/build.dart`를 쓰는 `flutter create --template=package_ffi`가 기준입니다. 시스템 라이브러리는 `LookupInProcess()`로 찾고, 생성 바인딩은 code asset을 대상으로 `@Native() external`을 씁니다.
- 플랫폼 동작은 `dart:io`의 `Platform`이 아니라 `defaultTargetPlatform`과 `kIsWeb`으로 판단합니다. 테스트에서는 덮어쓰지 않는 한 `TargetPlatform.android`가 보이므로, 플랫폼 분기는 `TargetPlatformVariant` 테스트가 있어야 실제로 검증됩니다.
- 웹도 대상으로 하는 코드는 공유 파일에서 `dart:io`를 import하면 안 됩니다. `dart.library.js_interop`을 키로 한 조건부 import를 쓰고 두 구현을 하나의 인터페이스 뒤에 둡니다.
- federated plugin이나 다중 엔진 호스트(add-to-app)에서는 엔진 범위 상태를 인스턴스에 두고 static이나 전역 변수에 두지 않습니다. 공유 네이티브 싱글턴은 참조 카운트로 관리합니다.
- adaptive와 responsive는 다릅니다. responsive는 레이아웃을 공간에 맞추고, adaptive는 그 공간에서 UI를 쓸 수 있게 만듭니다. 기기 모델이 아니라 `MediaQuery.sizeOf`나 `LayoutBuilder`로 창 크기에 따라 고릅니다.

## 의존성과 네이티브 효과

플랫폼 구현이 있는 패키지를 추가하는 일은 그 자체로 네이티브 변경입니다. Gradle 파일, Podfile이나 Swift package 그래프, 플러그인 registrant를 건드립니다. 리뷰 가능한 변경 내용을 남기는 승인 대상 부수 효과로 다룹니다.

- 플러그인을 추가하기 전에 세 가지를 확인합니다. SwiftPM 지원(CocoaPods는 maintenance mode이고 registry가 2026-12-02부터 read-only), AGP 9와 내장 Kotlin 호환성, 그리고 federated platform interface가 endorsed로 자동 포함하는지 `pubspec.yaml`에 직접 적어야 하는지입니다.
- 빌드 훅은 개발자 기기와 CI에서 빌드 시점에 실행되는 임의의 Dart입니다. 훅은 이름이 정해진 허용 목록(`PATH`, `HOME`, 프록시 변수, `ANDROID_*`, `LIBCLANG_PATH`, `NIX_*`)만 전달되는 준격리 환경에서 실행되고, 그 값이 바뀌면 훅 캐시가 무효화됩니다. 훅이 읽는 모든 파일은 `output.dependencies`에 등록해 캐시가 정확하게 유지되도록 합니다.
- 훅은 네이티브 asset을 컴파일하거나 내려받을 수 있습니다. dart.dev와 hooks 패키지 어디에도 해시 검증이 필수라고 적혀 있지 않으므로, 훅이 있는 의존성은 빌드 시점 코드 실행 의존성으로 봅니다. 버전을 고정하고 `hook/build.dart`를 읽고, 내려받는 바이너리에는 SHA-256 고정을 요구합니다. 빌드 시점에 내려받는 클로즈드 소스 사전 빌드 라이브러리도 같은 처리가 필요합니다.
- 훅은 Apple privacy manifest를 낼 수 없고, FFI 전용 플러그인은 bundle 자체가 없을 수 있습니다. 따라서 앱이 해당 required-reason API를 직접 선언하고 업그레이드마다 다시 감사합니다.
- `flutter pub upgrade` 뒤에는 네이티브 변경 내용, 해석된 Swift package 그래프, 병합된 manifest, 아래의 16 KB 검사를 다시 봅니다. 전이 플러그인이 바뀌면 모두 함께 움직입니다.
- 의존성 설치, 서명 변경, 스토어 작업은 자격 증명이 붙은 부수 효과입니다. 권한이나 capability가 없으면 실행했다고 보고하지 말고 정확한 명령과 막힌 입력을 적습니다.

## 스토어와 출시 요구사항

출시 게이트는 선호가 아니라 날짜가 붙은 약속입니다. 템플릿 기본값을 물려받지 말고 출시 주기마다 다시 확인합니다.

| 게이트 | 요구사항 | 확인 |
|---|---|---|
| Play target API | 2026-08-31부터 신규 앱과 업데이트가 API 36 이상(Wear와 Automotive 35, TV와 XR 34)을 대상으로 해야 합니다 | `android/app/build.gradle.kts`에 `compileSdk`와 `targetSdk`를 명시적으로 고정합니다. 3.47 기본값 36은 오늘 요구를 충족합니다 |
| 16 KB page size | API 35 이상 앱은 64비트 기기에서 16 KB page를 지원해야 하고, 2027-02-01부터 미지원 업데이트는 출시할 수 없습니다 | 소스가 아니라 릴리스 산출물을 확인합니다. `zipalign -c -P 16 -v 4 app-release.apk`나 APK Analyzer를 쓰고, 직접 만든 네이티브 코드에는 `-Wl,-z,max-page-size=16384`와 `-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON` 링크 플래그를 줍니다 |
| Android 서명 | Play App Signing은 업로드 키와 Google이 보관하는 앱 서명 키를 분리하고, 앱 서명 키는 다시 받을 수 없습니다 | 키를 구분하고 `key.properties`와 keystore를 소스 관리에서 빼며, 업로드 키 재설정 경로를 문서화합니다 |
| CI secret | keystore, 그 비밀번호, Play 서비스 계정 JSON은 주입하고 커밋하지 않습니다 | 설치 중 base64 keystore를 디코딩하고, 서비스 계정 JSON은 환경 변수에서 읽으며, 값을 콘솔에 되풀이해 출력하지 않습니다 |
| iOS 출시 | `flutter build ipa`가 `.xcarchive`와 `.ipa`를 만들고, `--export-method`가 App Store 외 배포를 고릅니다 | Xcode에서 서명하고 릴리스 빌드에 `--obfuscate --split-debug-info`를 붙입니다 |
| Privacy manifest | `PrivacyInfo.xcprivacy` property list가 required-reason API 사용을 선언하고, 2024-05-01부터 미선언 사용은 App Store Connect에서 거절됩니다 | 앱 자체 manifest를 넣고, 빌드 디렉터리에서 플러그인 manifest를 감사합니다 |

- 16 KB는 릴리스별 산출물 검사입니다. 엔진에 포함된 `libflutter.so`가 요구를 충족한다고 밝힌 공식 페이지나 릴리스 노트가 없고, 플러그인이 정렬되지 않은 `.so`를 다시 들여올 수 있습니다(2026년에 DataStore 의존성이 실제로 그랬습니다). SDK나 플러그인을 올린 뒤 매번 빌드된 APK나 AAB를 확인합니다.
- Apple의 서드파티 SDK 목록에는 Flutter 자체와 다수의 Flutter 플러그인이 버전과 무관하게, 재포장한 것까지 포함됩니다. `connectivity_plus`, `device_info_plus`, `file_picker`, `flutter_local_notifications`, `geolocator_apple`, `image_picker_ios`, `package_info_plus`, `path_provider`, `share_plus`, `shared_preferences_ios`, `sqflite`, `url_launcher_ios`, `video_player_avfoundation`, `webview_flutter_wkwebview`가 그 예입니다. 앱 안의 바이너리마다 자기 manifest가 필요하고, 서드파티 SDK는 앱 manifest에 기댈 수 없습니다.
- Flutter 플러그인은 CocoaPods `resource_bundles`로 manifest를 실어 나르므로 앱 manifest는 앱 자체 사용만 다룹니다. `flutter pub upgrade` 뒤에 `find build/ios/iphoneos -name "*.xcprivacy"`를 실행해 의존성 목록과 비교합니다.

## Sources

> 확인 2026-11-04. 이 날짜에 모든 행을 Flutter 3.47.9 stable 기준으로 읽었습니다.

| 주장 | 출처 |
|---|---|
| 지원 하한, Android 24부터 37까지와 iOS 15부터 27까지 | <https://docs.flutter.dev/reference/supported-platforms> |
| 3.47 템플릿 툴체인 기본값(Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, compile과 target 36, min 24) | <https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/android/gradle_utils.dart> |
| AGP 9 내장 Kotlin 마이그레이션과 임시 `android.builtInKotlin=false` 플래그 | <https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin> |
| 3.44부터 Swift Package Manager가 iOS와 macOS 기본이고, 2026-12-02부터 CocoaPods registry가 read-only | <https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers>, <https://flutter.dev/blog/whats-new-in-flutter-3-47> |
| 3.41부터 UIScene이 기본이고, `SceneDelegate.swift`와 `UIApplicationSceneManifest`를 생성 | <https://docs.flutter.dev/release/breaking-changes/uiscenedelegate> |
| Android `productFlavors`, `applicationIdSuffix`, `--flavor` 선택 | <https://docs.flutter.dev/deployment/flavors> |
| iOS와 macOS의 scheme과 configuration이 flavor 매핑 | <https://docs.flutter.dev/deployment/flavors-ios> |
| `appFlavor`는 컴파일 타임 상수이고 `--flavor` 없으면 null | <https://api.flutter.dev/flutter/services/appFlavor-constant.html> |
| 컴파일 환경 선언은 컴파일 타임 상수 | <https://dart.dev/libraries/core/environment-declarations> |
| 지속적 배포에서 `--dart-define`으로 빌드 시점 값 전달 | <https://docs.flutter.dev/deployment/cd> |
| 앱 안 secret은 나쁜 관행이고 난독화는 리버스 엔지니어링을 막지 못함 | <https://docs.flutter.dev/deployment/obfuscate> |
| `key.properties`는 비공개로 두고 소스 관리에서 제외 | <https://docs.flutter.dev/deployment/android> |
| 2026-08-31부터 Play target API 36 | <https://developer.android.com/google/play/requirements/target-sdk> |
| 16 KB page size 요구와 2027-02-01 출시 차단 | <https://developer.android.com/guide/practices/page-sizes> |
| Play App Signing의 업로드 키와 앱 서명 키 분리 | <https://developer.android.com/studio/publish/app-signing> |
| Android 13 이상에서 `POST_NOTIFICATIONS`가 런타임 권한 | <https://developer.android.com/develop/ui/views/notifications/notification-permission> |
| `permission_handler` 플랫폼 API와 기본 제외 권한 | <https://pub.dev/packages/permission_handler> |
| `shared_preferences`는 중요 데이터를 저장하면 안 됨 | <https://github.com/flutter/packages> |
| `flutter_secure_storage`의 암호화 저장과 Keystore 백엔드 | <https://pub.dev/packages/flutter_secure_storage> |
| `dart:io` `HttpClient`의 trust anchor | <https://api.flutter.dev/flutter/dart-io/HttpClient-class.html> |
| Dart 소유 소켓은 플랫폼 네트워크 정책 밖 | <https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android> |
| Android에서 Dart는 사용자 추가 CA를 무시하고 비활성화한 시스템 루트는 유지 | <https://github.com/dart-lang/sdk/issues/48056> |
| `cupertino_http`와 `cronet_http`를 `http.Client` 뒤의 플랫폼 스택 클라이언트로 사용 | <https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cupertino_http/README.md> |
| Android network security config와 pin set | <https://developer.android.com/privacy-and-security/security-config> |
| iOS `NSPinnedDomains`와 ATS 적용 범위 서술 | <https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nspinneddomains> |
| 새 네이티브 연동의 권장 기본값은 Pigeon이고 raw channel은 저수준 용도 | <https://docs.flutter.dev/interop/pigeon> |
| 준격리 환경에서 실행되는 build hook과 link hook | <https://dart.dev/tools/hooks> |
| 3.38부터 `package_ffi` 템플릿과 code asset 바인딩 | <https://docs.flutter.dev/interop/bind-native-code> |
| `PrivacyInfo.xcprivacy` property list와 required-reason API 규칙 | <https://developer.apple.com/documentation/bundleresources/privacy-manifest-files> |
| 서드파티 SDK 목록에 Flutter와 지정된 Flutter 플러그인 포함 | <https://developer.apple.com/support/third-party-SDK-requirements/> |
| 훅은 privacy manifest를 낼 수 없음 | <https://github.com/flutter/flutter/issues/140966> |
| Flutter 플러그인 manifest는 CocoaPods `resource_bundles`로 포장됨 | <https://github.com/flutter/flutter/issues/131940> |
| 전이 DataStore 의존성이 16 KB 정렬이 안 된 `.so`를 실어 보냈다가 되돌려짐 | <https://github.com/flutter/flutter/issues/182744> |
| `defaultTargetPlatform`과 테스트 환경의 Android 기본값 | <https://api.flutter.dev/flutter/foundation/defaultTargetPlatform.html> |

### Evidence grade

버전, 정책, 플랫폼 동작 행은 공식 벤더 문서와 API 참조가 근거입니다. Android trust store 동작, pinning 공백, privacy manifest 공백은 열린 이슈 스레드에서 나왔으므로 등급이 더 낮고, 보장이 아니라 관찰된 동작으로 적었습니다. 엔진 자체의 16 KB 정렬은 어떤 출처로도 확립되지 않았으므로, 이 파일은 결과를 단정하지 않고 산출물 검사를 요구합니다.
