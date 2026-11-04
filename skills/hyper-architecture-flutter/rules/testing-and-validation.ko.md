# 테스트와 검증

완료를 선언하기 전에 읽습니다. 이 파일은 Android와 iOS를 주 대상으로 하는 Flutter 앱의 위험 깊이, 검사 순서, 테스트 하한, 필수 시나리오, 아키텍처 재확인, 완료 기록을 소유합니다.

## 위험 깊이

새 아키텍처나 큰 리팩터에는 `standard` 깊이를 씁니다. 전체 검사 순서를 돌리고 바뀐 기능을 선언한 두 모바일 플랫폼에서 모두 실행합니다. 네이티브 모듈, 권한, 인증 또는 secret, 오프라인 데이터, flavor 또는 서명, 플랫폼 차이가 바뀌면 `thorough`를 씁니다. `thorough`는 자동화 묶음이 할 수 없는 플랫폼 단계를 더합니다. 실제 권한 대화상자, 실제 deep link 진입, 실제 flavor 산출물, 실제 서명 구성 중 해당하는 단계입니다.

최종 산출물과 함께 실행 과정도 기록합니다. Flutter와 Dart 버전, 기기 또는 시뮬레이터와 그 OS 버전, flavor, 빌드 시 넘긴 환경 값, 앱을 다시 설치했는지 그대로 두었는지입니다. unit 실행이 초록색이어도 권한 안내가 떴다는 뜻은 아니고, integration 실행이 초록색이어도 어느 플랫폼을 덮었는지는 보여 주지 않습니다.

호스트, 기기나 시뮬레이터, 서명 자료, 자격 증명, 권한 때문에 검사를 돌릴 수 없으면 빠진 항목을 정확히 밝히고, 플랫폼 실행을 대신하지 않는 범위에서 가장 강한 정적 검사를 씁니다. 호스트, VM, web 실행을 Android나 iOS 근거로 보고하지 않습니다. 통과할 때까지 검사를 반복하지 않고, 통과시키려고 검사를 약화하지 않습니다.

## 검사 순서

뒤 단계가 앞 단계의 실패를 가리지 않도록 저장소 루트에서 순서대로 돌립니다. 저장소가 정의한 명령과 Flutter CLI를 쓰고, 프로젝트에 없는 스크립트를 새로 만들지 않습니다.

0. 무엇도 바꾸기 전에 도구체인을 기록합니다. `flutter --version`, `flutter doctor -v`, `pubspec.yaml`의 `environment` 블록입니다. SDK 제약이 포매터 스타일과 변경에 쓸 수 있는 언어 기능을 정합니다.
1. `dart format --output=none --set-exit-if-changed .`는 검사만 하고 다시 포맷할 파일이 있으면 종료 코드 1을 냅니다. 포매터 스타일은 플래그가 아니라 언어 버전이 고릅니다. 최소 SDK가 3.6 이하인 패키지는 짧은 스타일을, 3.7 이상인 패키지는 tall 스타일을 받습니다. `--language-version`이 판정을 덮어쓰고 `analysis_options.yaml`의 `formatter: page_width:`가 폭을 바꿉니다. tall 스타일 서술은 `dart_style` 변경 기록에서 온 것이며, 80열 기본값만 설명하는 `dart format` 페이지에는 없습니다.
2. `flutter analyze`는 Flutter CLI 형태이고 Flutter 프로젝트에서 `dart analyze`를 대체합니다. 오류와 경고에서 0이 아닌 코드로 끝나지만 info 수준 문제에서는 실패하지 않습니다. `dart analyze --fatal-infos`는 저장소가 이미 그 정책을 강제할 때만 더합니다. 관계없는 변경 도중에 새로 도입하지 않습니다. 생성 템플릿은 `build/`, `android/`, `ios/`를 분석에서 제외하므로 분석 통과가 플랫폼 소스에 대한 판정은 아닙니다.
3. `dart fix --dry-run`은 분석기가 적용할 수 있는 수정을 쓰지 않고 나열합니다. 목록을 검토한 뒤 `dart fix --apply`를 별도의 검토된 단계로 실행합니다. `dart format --fix`는 `dart_style` 3.0.0에서 제거되었으므로 자동 수정 경로는 `dart fix` 하나이고, CI의 안전한 기본값은 dry run입니다.
4. `flutter test --coverage`는 unit과 widget 테스트를 돌리고 기본으로 `coverage/lcov.info`를 씁니다. `--merge-coverage`는 여러 실행을 합치며 `lcov`가 설치되어 있어야 하고, `--branch-coverage`와 `--coverage-package`는 집계 범위를 좁힙니다. Flutter 명령에는 기본 제공 커버리지 임계값이 없으므로 커버리지 기준은 이 명령이 아니라 저장소 자체 도구나 CI 스크립트에서 옵니다.
5. `flutter test integration_test`는 기기를 선택한 상태에서 integration 묶음을 돌립니다. 한 플랫폼의 통과가 다른 플랫폼을 보증하지 않으므로 Android와 iOS를 따로 실행합니다.
   ```bash
   flutter test integration_test -d <android-device-id>
   flutter test integration_test -d <ios-device-id>
   ```
   각 실행 뒤 설치 상태를 확인합니다. 남은 설치가 다음 실행에서 오래된 데이터를 재사용하게 만들 수 있고, 실행 사이의 제거는 cold start를 재현하는 일부입니다.
6. 릴리스 산출물을 빌드합니다. `flutter build appbundle`은 `build/app/outputs/bundle/release/app.aab`를 만들고, `flutter build ios --no-codesign`은 코드 서명을 끄고 IPA 생성을 건너뛴 채 iOS 앱을 컴파일합니다. 서명 없는 빌드는 프로젝트가 컴파일되고 링크된다는 근거이며 배포 가능한 산출물은 아닙니다. 기본 변형만이 아니라 선언한 flavor마다 `--flavor <name>`과 대응하는 공유 iOS scheme으로 빌드합니다.
7. 프로젝트가 `patrol`을 쓰고 테스트를 `patrol_test/` 아래에 두면 `patrol test`를 실행하고, 새 환경에서는 `patrol doctor`도 실행합니다. patrol 테스트는 `flutter test`로 돌지 않습니다. `integration_test`가 조작하지 못하는 네이티브 대화상자, 알림, 권한 흐름에 patrol을 쓰고, widget 테스트가 이미 통과하는 여정을 중복하지 않습니다.
8. web이 선언한 대상일 때만 브라우저에서 integration 묶음을 `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome`으로 돌립니다. ChromeDriver가 `PATH`에 있어야 합니다. 보이는 브라우저가 필요 없으면 `-d web-server`를 씁니다. web 실행은 모바일 플랫폼 검사를 대신하지 않습니다.
9. `flutter test --platform chrome`은 deprecated이고 3.47.0 도구 소스에서 verbose 전용으로 표시됩니다. 앱이 아니라 프레임워크를 겨냥합니다. 검사 순서에서 빼고 그 결과를 web이나 플랫폼 근거로 세지 않습니다.

## 테스트 하한

공식 분류는 세 층이고, 비용은 신뢰도와 반대 방향으로 올라갑니다.

| 층 | 신뢰도 | 유지비 | 의존성 | 속도 | 쓰는 곳 |
|---|---|---|---|---|---|
| Unit | 낮음 | 낮음 | 적음 | 빠름 | 로직, 매핑, 검증, 상태 전이 |
| Widget | 높음 | 높음 | 많음 | 빠름 | 렌더링, 상호작용, 접근성 의미, 컴포넌트 트리 하나 |
| Integration | 가장 높음 | 가장 높음 | 가장 많음 | 느림 | 중요한 여정 몇 개의 끝에서 끝까지 |

unit과 widget 테스트를 많이 쓰고 중요한 여정을 덮을 만큼만 integration 테스트를 씁니다. 더 빠른 층이 이미 덮은 로직을 다시 확인하는 곳이 integration 테스트는 아닙니다.

- **service, repository, ViewModel마다 unit 테스트.** service는 fake transport로, repository는 fake service로, ViewModel은 fake repository와 함께 순수 Dart로 테스트합니다. 아키텍처가 온전하면 ViewModel 테스트에 Flutter 바인딩이 필요 없으므로 그 테스트에는 Flutter import를 넣지 않습니다.
- **fake가 먼저.** `implements <Interface>` 클래스를 직접 만들어 `testing/` 폴더로 공유합니다. 자연스러운 fake가 없는 프레임워크 인접 타입, 예를 들어 router에는 `mocktail`을 씁니다. 코드 생성과 빌드 단계가 필요 없기 때문입니다. Mockito는 팀이 이미 생성 mock을 표준으로 삼고 CI의 `build_runner` 단계를 받아들일 때만 씁니다.
- **widget 테스트는 같은 fake를 재사용합니다.** fake가 구동하는 ViewModel과 같은 route 목록으로 만든 테스트 router로 화면을 pump합니다. 공유 `testApp` 도우미가 `tester.view.devicePixelRatio = 1.0`, 고정 surface 크기, 앱 theme, localization, router를 설정해 레이아웃을 결정적으로 만듭니다.
- **플러그인 호출은 자체 API로 감쌉니다.** unit과 widget 테스트에는 호스트 플랫폼 코드가 없으므로 채널을 직접 호출하면 `MissingPluginException`이 납니다. 채널을 mock하지 말고 자체 wrapper를 fake합니다. `TestDefaultBinaryMessenger` 핸들러는 타입이 없고 채널 계약에 테스트를 묶으므로 마지막 수단입니다.
- **integration은 중요한 여정에만.** `integration_test/<name>_test.dart`에 두고 `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`를 호출하며 같은 `testWidgets` API를 씁니다. `integration_test`는 권한 대화상자, 알림, platform view 같은 네이티브 플랫폼 UI를 조작하지 못합니다. 그 단계에는 `patrol`이나 네이티브 Espresso와 XCUITest를 씁니다.
- **golden은 픽셀 단위로 정확합니다.** `matchesGoldenFile`은 비동기이므로 `expectLater`로 기다립니다. 기본 `LocalFileComparator`는 픽셀 단위로 비교하고, 폰트 렌더링은 운영체제와 Flutter 버전에 따라 달라집니다. 기본 테스트 폰트는 상자를 그리므로 `FontLoader`로 실제 폰트를 불러오고, 필요하면 `flutter_test_config.dart`에서 불러옵니다. golden은 CI 운영체제 하나와 Flutter 버전 하나에 고정하고, `flutter test --update-goldens`로 갱신하며, 바뀐 이미지를 모두 검토합니다. 허용 오차는 custom comparator가 필요하고 기본값이 아니라 의도한 결정입니다.

## 필수 시나리오

변경과 관련된 행을 실행합니다. 나머지는 조용히 건너뛰지 말고 해당 없음과 이유를 적습니다.

| 시나리오 | 확인할 것 | 근거 |
|---|---|---|
| Deep link cold start | 앱을 종료하고 각 플랫폼에서 OS로 링크를 연 뒤 warm start와 같은 화면과 파라미터인지 확인합니다. 잘못된 링크와 알 수 없는 링크가 오류 route로 가는지도 봅니다. | 기기 로그와 화면 캡처 |
| 권한 거부 | 허용, 거부, 영구 거부, 새 설치를 확인합니다. 거부 상태에서도 쓸 수 있는 화면이 뜨고 문서화한 복구 경로가 있으며 앱이 죽지 않는지 봅니다. | `integration_test`가 네이티브 대화상자를 누르지 못하므로 patrol 또는 수동 플랫폼 실행 |
| Flavor 빌드 | 선언한 flavor를 Android와 iOS에서 모두 빌드합니다. `appFlavor`와 빌드 시점 구성이 기대값으로 풀리는지, flavor 범위 에셋과 권한 선언이 맞는 변형에 들어가는지 확인합니다. | 생성된 AAB와 대응 iOS 빌드 로그 |
| 오프라인과 오류 `Result` 경로 | repository가 실패를 돌려주거나 시간 초과가 나게 한 뒤 ViewModel이 오류 상태에 이르고 UI가 이를 보여 주며 재시도가 예외 없이 로드 상태로 돌아오는지 확인합니다. | 전이에 대한 unit 테스트와 widget 테스트 하나 |
| 인증 redirect 갱신 | 세션을 만료시키고 `refreshListenable`이 재평가를 일으키는지, guard가 로그인으로 redirect하는지, 복귀 경로가 유지되는지 확인합니다. 다음 요청을 서버가 여전히 인가하는지도 봅니다. | router 로그와 로그인 왕복 |

flavor 식별자, 컴파일 타임 상수, router redirect는 보안 경계가 아닙니다. 동작으로 테스트하고 인가는 서버에 둡니다.

## 아키텍처 재확인

완료를 선언하기 전에 변경이 아키텍처 규칙을 여전히 만족하는지 확인합니다.

- route는 얇게 유지되고 데이터를 가져오거나 상태를 소유하지 않은 채 화면을 만듭니다.
- 각 feature가 presentation 코드를 소유하고, feature 사이 접근은 작은 공개 API를 지납니다.
- 의존성은 View에서 ViewModel, repository, service로 향하고 순환이 없으며, View가 service나 DTO를 import하지 않습니다.
- 런타임 secret이 `lib/`, 에셋, `shared_preferences`, 컴파일 상수에 추가되지 않았습니다.
- 상태는 의도한 주인이 소유하고, 저장하거나 복원하는 상태에는 명시적 주인이 있습니다.
- 플랫폼 이음새는 capability나 wrapper 뒤에 있고, web을 선언한 앱에서 공유 파일이 `dart:io`나 `dart:html`을 import하지 않습니다.
- 남은 고아 파일, 죽은 route, 쓰지 않는 fake가 없습니다.

가장 빠르게 확인하는 아키텍처 신호는 테스트 가능성입니다. widget 테스트에 실제 네트워크, 데이터베이스, 플랫폼 채널이 필요하면 경계가 잘못 놓인 것입니다. 생성 코드와 플랫폼 diff는 직접 쓴 소스와 따로 검토합니다. `.g.dart`와 `.freezed.dart` 산출물, router builder 출력, `ios/`와 `android/` 아래 변경입니다.

## 완료 기록

다음 형태를 그대로 쓰고 화살표 순서를 바꾸지 않습니다.

```text
Claim -> Risk -> Evidence -> Verification -> Result -> Caveat
```

설치된 Flutter와 Dart 버전, 실제로 실행한 명령과 결과, Android와 iOS 범위, 건너뛴 검사와 이유, 결정 하나를 담습니다. 결정은 `ship`, `iterate`, `caveated ship`, `block` 중 하나입니다. 관찰한 실패만 고치고 두 번의 수정 시도 뒤에 멈추며, 통과에 이르려고 검사를 약화하거나 지우지 않습니다. caveat에는 확인하지 못한 플랫폼이나 시나리오를 적고 일반적인 경고를 쓰지 않습니다.

## Sources

> 확인 2026-11-04. 이 파일을 Flutter 3.47.9 기준으로 작성한 날짜입니다.

| Claim | Source |
|---|---|
| unit, widget, integration이 세 층이고 unit과 widget 테스트를 많이, 중요한 여정을 덮을 만큼 integration 테스트를 둔다 | <https://docs.flutter.dev/testing/overview> |
| `integration_test`는 권한 대화상자, 알림, platform view 같은 네이티브 플랫폼 UI와 상호작용하지 못한다 | <https://docs.flutter.dev/testing/overview>, <https://docs.flutter.dev/cookbook/testing/integration/introduction> |
| integration 테스트는 Android와 iOS 기기에서 `flutter test integration_test/...`로 돌리고 web에는 driver 경로가 남아 있다 | <https://docs.flutter.dev/testing/integration-tests>, <https://docs.flutter.dev/release/breaking-changes/flutter-driver-migration> |
| 계층별 테스트는 repository에 fake를 쓰고 widget 테스트에서 재사용하며 router는 mocktail로 mock한다 | <https://docs.flutter.dev/app-architecture/case-study/testing> |
| unit 테스트 cookbook은 `@GenerateMocks`와 `build_runner`를 쓰는 Mockito를 가르친다 | <https://docs.flutter.dev/cookbook/testing/unit/mocking> |
| 플러그인 호출은 앱이 소유한 API로 감싸고 fake 해야 한다. unit과 widget 테스트에는 호스트 플랫폼 코드가 없다 | <https://docs.flutter.dev/testing/plugins-in-tests> |
| `flutter analyze`는 `dart analyze`를, `flutter test`는 `dart test`를 대체한다 | <https://docs.flutter.dev/reference/flutter-cli> |
| `dart format`은 기본 80열을 쓰고 `--set-exit-if-changed`에서 종료 코드 1을 내며 `analysis_options.yaml`의 `page_width`를 읽는다 | <https://dart.dev/tools/dart-format> |
| 포매터는 언어 버전 3.7 이상에서 tall 스타일, 3.6 이하에서 짧은 스타일을 쓴다 | <https://raw.githubusercontent.com/dart-lang/dart_style/master/CHANGELOG.md> |
| `dart analyze`는 기본으로 오류와 경고에서 실패하고 info 수준 문제에서는 실패하지 않는다 | <https://dart.dev/tools/dart-analyze> |
| `dart fix`는 `--dry-run`과 `--apply`를 지원하고 `dart format --fix`는 `dart_style` 3.0.0에서 제거되었다 | <https://dart.dev/tools/dart-fix>, <https://raw.githubusercontent.com/dart-lang/dart_style/master/CHANGELOG.md> |
| `flutter test`의 coverage 플래그, `lcov.info` 기본 경로, deprecated platform chrome 모드 | <https://raw.githubusercontent.com/flutter/flutter/3.47.0/packages/flutter_tools/lib/src/commands/test.dart> |
| `flutter build ios --no-codesign`은 코드 서명을 끄고 IPA 생성을 건너뛴다 | <https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_tools/lib/src/commands/build_ios.dart> |
| `flutter build appbundle`은 릴리스 번들을 `build/app/outputs/bundle/release/app.aab`에 쓴다 | <https://docs.flutter.dev/deployment/android> |
| `flutter build`와 `flutter run`은 `--flavor`로 flavor를 고르고, iOS는 flavor를 공유 Xcode scheme과 configuration에 대응시킨다 | <https://docs.flutter.dev/deployment/flavors>, <https://docs.flutter.dev/deployment/flavors-ios> |
| golden 매칭은 비동기이고 기본 comparator는 정확한 픽셀 비교를 한다 | <https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html>, <https://api.flutter.dev/flutter/flutter_test/goldenFileComparator.html> |
| custom 폰트로 렌더링한 golden 파일은 운영체제에 따라 달라지고 기본 테스트 폰트는 상자를 그린다 | <https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html> |
| patrol은 `integration_test`가 못 하는 네이티브 상호작용을 처리하고 Flutter 3.32 이상이 필요하며 자체 CLI로 실행한다 | <https://pub.dev/packages/patrol>, <https://patrol.leancode.co/documentation> |
| 커버리지 임계값 플래그는 `flutter test`가 아니라 서드파티 CLI에 속한다 | <https://cli.vgv.dev/docs/commands/test> |

### 근거 등급

`OFFICIAL + DERIVED` - 세 층, 장단점 표, fake 우선 계층 테스트, `integration_test`의 네이티브 UI 한계, CLI 명령과 종료 동작, coverage 플래그, 빌드 산출물, golden 주의사항은 표에 적은 Flutter, Dart, pub.dev, `dart_style` 문서를 재진술한 것입니다. 검사 순서, Android 다음 iOS 분리 실행, fakes 우선과 mocktail 차선, 폰트 명시 로딩, 필수 시나리오 목록, 아키텍처 재확인, 완료 기록은 그 문서에서 이끌어 낸 Hypercore 관례입니다. platform chrome 모드의 deprecated 표시는 3.47.0 도구 소스에서 읽었고, 그 모드를 앱 검증에 쓰라고 권하는 공식 문서는 없습니다. 버전 숫자는 Flutter 3.47.9와 Dart 3.13.7 기준입니다.
