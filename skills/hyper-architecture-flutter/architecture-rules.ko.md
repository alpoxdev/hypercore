# Flutter 아키텍처 규칙

발견 사항을 분류하거나 규칙을 적용하기 전에 읽습니다. 이 파일은 규칙 등급, authority 순서, 차단 게이트, 기본 트리, 마이그레이션 정책을 소유합니다. Android와 iOS를 1차 대상으로 하는 Flutter·Dart 앱에 적용하며, web과 desktop은 프로젝트가 선언했을 때만 대상입니다.

## 규칙 등급

- **Official**: 설치한 프레임워크 버전에 적용되는 Flutter·Dart 공식 문서 동작이며, `references/official/flutter-dart-2026-11-04.md`의 날짜 박힌 공식 reference를 포함합니다.
- **Safety**: secret, runtime input, permission, signing, transport trust, data loss를 다루는 차단형 로컬 정책입니다.
- **Hypercore convention**: 근거가 있는 프로젝트 관례에 맞게 조정할 수 있는 확장 가능한 기본값입니다.

우선순위는 user/project authority, 설치된 프로젝트 근거, 적용 가능한 공식 동작, 안전 정책, Hypercore convention 순서입니다. Safety 발견 사항은 명시적 해결이 필요합니다.

공식 앱 아키텍처 가이드는 스스로를 "guidelines, not steadfast rules"라고 밝히고, 모든 권장안에 strongly recommend, recommend, conditional 등급을 붙입니다. 아래 차단 게이트에 해당하지 않는 권장안은 조정할 수 있고, 게이트는 조정할 수 없습니다.

## 목표 의존 방향

```text
View (widget)
  -> ViewModel (ChangeNotifier, Notifier, or bloc; the project's choice)
    -> use-case (optional Domain layer)
      -> Repository
        -> Service
```

의존은 아래쪽으로만 향합니다. View는 repository, service, transport DTO, 영속 어댑터를 import하지 않고 ViewModel 상태를 읽고 ViewModel 명령을 호출합니다. Repository는 다른 repository에 의존하지 않습니다. 여러 엔티티를 함께 다루는 조정은 use-case나 ViewModel이 맡습니다. Service는 상태를 갖지 않고 외부 데이터 소스 하나를 감싸며 repository가 호출합니다. Use-case는 둘 이상의 ViewModel이 같은 로직을 공유하거나 여러 repository를 조합할 때만 등장합니다.

공식 관계 모델도 이 순서와 같습니다. View는 ViewModel 하나에 대응하고, ViewModel은 여러 repository를 쓸 수 있으며, View에 허용되는 로직은 조건부 표시, 애니메이션, 기기·창 정보에 따른 레이아웃, 단순 라우팅 네 가지뿐입니다.

Hypercore convention: feature 간 접근은 의도적으로 작은 공개 API를 거치고, 한 feature의 presentation 계층은 다른 feature의 data 계층을 import하지 않습니다.

## 차단 게이트

다음에 해당하는 변경은 차단하거나 수정합니다. 각 게이트는 공식 동작이나 차단형 안전 정책에 근거하며, 스타일 선호가 아닙니다.

1. 앱이 런타임에 읽는 secret을 남깁니다. `String.fromEnvironment`나 `--dart-define` 값 같은 컴파일 상수, 번들 에셋, 소스 리터럴, `shared_preferences`, 암호화하지 않은 파일이 해당합니다. 컴파일 시점에 전달하는 빌드 배관 값은 허용하지만, 바이너리 안에 들어가는 자격 증명과 개인 키는 허용하지 않습니다.
2. 딥링크 파라미터, 푸시 payload, 라우트 `extra` 값, 영속 레코드, API 응답을 경계에서 검증하지 않고 신뢰하거나, 라우터 `redirect`나 가드를 인가로 취급합니다. Redirect는 화면 흐름을 정할 뿐이며 서버는 모든 요청을 계속 인가해야 합니다.
3. `Info.plist` 키나 `AndroidManifest.xml` 선언, 사용자에게 보이는 목적 문구 없이 런타임 권한을 요청하거나, flavor별 권한 선언이 잘못된 variant에 병합되어 `ITMS-90683` 같은 App Store 거절을 부릅니다.
4. `key.properties`, keystore, `.p12`, provisioning profile 같은 서명 자료를 커밋하거나, 명시적 권한 없이 서명, 스토어 업로드, 배포를 실행합니다.
5. true를 돌려주는 `badCertificateCallback`이나 그 밖의 host·peer 검증 우회를 넣거나, Android Network Security Config pinning과 iOS App Transport Security pinning이 `dart:io` `HttpClient` 트래픽을 보호한다고 주장합니다. 보호하지 않으며, 그 정책이 적용되어야 하면 플랫폼 HTTP 클라이언트를 써야 합니다.
6. web이 선언된 대상인데 모든 대상에서 컴파일되는 코드에 `dart:io`, `dart:html`, `dart:js`를 import하거나 `Platform.is*`를 호출합니다. `dart.library.js_interop` 조건부 import를 쓰거나 해당 코드를 capability 경계 뒤에 둡니다.
7. 네이티브 동작이 바뀌었는데 호스트 단위 테스트, widget 테스트, web 실행만으로 Android나 iOS 지원을 주장합니다.
8. 날짜 박힌 공식 reference가 설치 버전에서 제거·deprecated로 표시한 API를 문서상 대체재로 옮기지 않고 씁니다. `WillPopScope`, 레거시 `SharedPreferences` API, web 검증 경로로서의 `flutter test --platform chrome`이 해당합니다.
9. 해시 검증 없이 바이너리를 내려받거나 실행하는 build hook 또는 FFI 의존성을 추가하거나, 내려받는 출처를 감사하지 않았습니다.
10. 공개된 SDK 제약이 설치된 Flutter·Dart 버전을 배제하는 패키지나, 플랫폼 최소 버전이 프로젝트 선언과 어긋나는 패키지를, 그 불일치가 의도적이라는 근거 없이 도입합니다.

## 확장 가능한 기본 구조

작은 앱의 기본값은 공식 샘플 구조를 따릅니다. UI는 feature별로, data와 domain은 타입별로 묶습니다.

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

실제 코드를 소유할 때만 폴더를 추가합니다. 작은 앱은 `ui/`, `data/`, `routing/`, `config/`로 시작하고, `domain/`은 use-case가 생길 때 등장하며, `testing/`은 배포 코드 경로 밖에 둡니다. 평평한 `ui/` 트리가 더 이상 확장되지 않으면 feature별로 묶거나(`lib/features/<domain>/{presentation,domain,data}`) feature를 pub workspace 패키지로 나눕니다. 두 경우 모두 위 의존 방향은 그대로입니다.

## 마이그레이션 정책

수직 슬라이스로 진행합니다. feature 하나를 옮기고 import와 테스트를 갱신한 뒤 포맷, 분석, 테스트를 실행하고 다음으로 넘어갑니다. 구조 이동은 디자인 라이브러리 마이그레이션이나 라우터 교체와 함께 하지 않습니다. 한 단계에는 되돌릴 수 있는 변경 하나만 두어야 실패 원인을 좁힐 수 있습니다. alias, 생성 코드, 네이티브 설정, 소유권이 아직 불확실하면 저장소 전체 이동을 하지 않습니다. `ios/`와 `android/` 수정은 생성물이 아니라 소유 소스이므로 일반 리뷰 대상으로 둡니다. 요청이 없으면 공개 동작을 보존합니다.

## 완료 게이트

치명적인 Official·Safety 발견 사항이 모두 통과해야 합니다. 관례 차이는 기존 프로젝트 근거가 명시적으로 정당화할 때만 반영할 수 있습니다. 빌드와 테스트를 마친 플랫폼(Android, iOS, 선언했다면 web·desktop)과 생략한 네이티브 검사를 함께 보고합니다.

## 출처

> 2026-11-04 확인. 이 파일의 버전과 API 상태는 Flutter 3.47.9, Dart 3.13.7 기준 날짜 박힌 공식 reference를 그대로 옮긴 것입니다.

| 이 파일에서 쓴 주장 | 출처 |
|---|---|
| 계층, View와 ViewModel 및 ViewModel과 repository의 관계, View에 허용되는 로직 | https://docs.flutter.dev/app-architecture/guide |
| 권장 강도 등급(strongly recommend, recommend, conditional) | https://docs.flutter.dev/app-architecture/recommendations |
| `package:provider`를 쓰는 의존성 주입 | https://docs.flutter.dev/app-architecture/case-study/dependency-injection |
| `Result` 객체는 필수가 아닌 권장안 | https://docs.flutter.dev/app-architecture/design-patterns/result |
| 공식 샘플 구조: `ui/`는 feature별, `data/`와 `domain/`은 타입별 | https://api.github.com/repos/flutter/samples/contents/compass_app/app/lib |
| provider와 `ChangeNotifier`를 출발점으로 두는 상태 관리 | https://docs.flutter.dev/data-and-backend/state-mgmt/simple |
| `--dart-define` 값은 바이너리 안의 컴파일 타임 상수 | https://dart.dev/libraries/core/environment-declarations |
| 앱에 secret을 두는 것은 나쁜 보안 관행 | https://docs.flutter.dev/deployment/obfuscate |
| `key.properties`는 비공개로 두고 소스 관리에서 제외 | https://docs.flutter.dev/deployment/android |
| 지속적 배포에서 `--dart-define`으로 빌드 값 전달 | https://docs.flutter.dev/deployment/cd |
| 런타임 권한 요청에는 플랫폼 설정이 필요 | https://pub.dev/packages/permission_handler |
| `dart:io` `HttpClient`의 trust anchor | https://api.flutter.dev/flutter/dart-io/HttpClient-class.html |
| Dart가 소유한 소켓에는 플랫폼 네트워크 정책이 적용되지 않음 | https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android |
| 정책을 적용하려면 플랫폼 HTTP 클라이언트를 사용 | https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cupertino_http/README.md |
| web에서의 `dart:io` import와 `Platform.is*` 동작 | https://docs.flutter.dev/platform-integration/web/faq |
| `dart.library.js_interop`을 쓰는 조건부 import | https://dart.dev/interop/js-interop/package-web |
| build hook은 빌드 시점에 실행 | https://dart.dev/tools/hooks |
| 레거시 `SharedPreferences` API deprecation | https://raw.githubusercontent.com/flutter/packages/main/packages/shared_preferences/shared_preferences/README.md |
| `WillPopScope` deprecation과 predictive back | https://docs.flutter.dev/release/breaking-changes/android-predictive-back |
| `flutter test --platform chrome` deprecation | https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/commands/test.dart |
| `go_router`는 feature-complete이며 Flutter 3.44 이상 필요 | https://pub.dev/packages/go_router |
