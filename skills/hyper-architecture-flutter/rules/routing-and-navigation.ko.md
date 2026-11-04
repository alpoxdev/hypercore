# 라우팅과 내비게이션

route table, guard, deep link, 뒤로 가기 동작을 바꿀 때 읽습니다. 이 파일은 내비게이션 모델 결정, 단일 router 구성, guard와 redirect 계약, deep link 입력 처리, 복원 가능한 화면, predictive back을 소유합니다.

## Official 경계

Flutter는 `Navigator`와 `Router`, 플랫폼 deep link 플래그와 검증 파일, predictive back 마이그레이션을 소유합니다. route table 배치, guard 위치, routing code를 두는 폴더는 Official로 표시한 문장이 아니면 이 파일의 관례입니다. 변경이 겨냥하는 Flutter 버전을 밝힙니다. 3.47용 예제는 디자인 위젯을 독립 패키지에서 가져오고, 3.50 항목은 예정으로 표시합니다. 하한을 인용하기 전에 `flutter --version`과 `pubspec.yaml`의 `environment` 블록으로 설치 버전을 확인합니다.

## 내비게이션 모델 결정

route table이 생기기 전에 한 번 정하고 router 옆에 결정을 기록합니다.

| 상황 | 모델 |
|---|---|
| 작은 앱이고 deep link 동등성이 필요 없으며 stack이 하나로 얕다 | `push`/`pop`과 `MaterialPageRoute`를 쓰는 `Navigator` |
| 링크가 Android와 iOS에서 같은 화면을 열어야 하거나 web 주소창이 위치를 반영해야 한다 | `go_router` 같은 라우팅 패키지와 `MaterialApp.router` |
| 라우팅 패키지로 표현하기 어려운 요구가 있다. 예를 들어 자체 URL 문법이 필요하다 | raw Router 2.0(`RouterDelegate`와 `RouteInformationParser`). 고급 경로로 문서화된 방식 |

named route(`MaterialApp.routes`와 `onGenerateRoute`)는 대부분의 앱에 권장되지 않습니다(Official). 항상 새 `Route`를 push하므로 동작을 바꿀 수 없고 browser forward 버튼도 지원하지 않습니다. 새 코드에 넣지 않고 router와 섞지 않습니다.

라우팅 패키지가 만든 route는 page-backed이고 deep link로 열립니다. `Navigator.push`와 `showDialog`는 URL로 가리킬 수 없는 pageless route를 추가하고, page-backed route를 제거하면 그 위의 pageless route도 함께 사라집니다. 최상위 stack은 router가 소유하고, 명령형 push는 URL이 이름 붙이지 않는 로컬 UI에만 씁니다.

## 단일 router 구성

`lib/routing/` 아래에 router 인스턴스 하나를 만들고 `MaterialApp.router`의 `routerConfig`로 넘깁니다(Hypercore convention). 앱의 다른 곳에서는 `GoRouter`를 만들지 않습니다. 테스트는 같은 인스턴스를 쓰거나 같은 route 목록으로 만든 테스트 대역을 주입합니다.

```dart
// lib/routing/app_router.dart
final appRouter = GoRouter(
  debugLogDiagnostics: true,
  refreshListenable: authController,
  redirect: (context, state) {
    final signedIn = authController.isSignedIn;
    final atSignIn = state.matchedLocation == '/sign-in';
    if (!signedIn && !atSignIn) {
      return '/sign-in?from=${Uri.encodeComponent(state.uri.toString())}';
    }
    return null;
  },
  routes: [homeRoute, ordersRoute, signInRoute],
  onException: (context, state, router) => const ErrorScreen(),
);
```

router는 `GoRouter.of(context)`나 `maybeOf`로 읽고, debug 빌드에서는 `debugLogDiagnostics`를 켜 두어 route 전환을 로그에서 확인합니다. feature flag나 인증 범위 때문에 route table 자체가 런타임에 바뀔 때만 `ValueListenable<RoutingConfig>`와 함께 `GoRouter.routingConfig`를 씁니다.

## 얇은 route

route builder는 route parameter를 읽고 검증하며 transition과 shell option을 고르고 feature 화면을 조합할 수 있습니다. 데이터를 가져오거나 상태를 소유하거나 business rule을 구현하면 안 됩니다. 공식 아키텍처 가이드도 view에 단순 routing logic만 허용합니다. 화면은 feature 폴더에 남고 routing code가 화면을 import하며 그 반대는 없습니다.

```dart
GoRoute(
  path: '/orders/:orderId',
  builder: (context, state) {
    final orderId = OrderId.tryParse(state.pathParameters['orderId']);
    return orderId == null
        ? const NotFoundScreen()
        : OrderDetailScreen(orderId: orderId);
  },
),
```

parameter는 route에서 domain 타입으로 파싱합니다. 그래야 잘못된 식별자가 feature 깊은 곳의 예외가 아니라 not-found 화면이 됩니다.

## Guard와 redirect

`onEnter`와 `redirect`는 하는 일이 다릅니다(Official, go_router 18.1.2).

- `onEnter`(16.3.0부터)는 guard입니다. deep link, `go`, `push`의 실제 목표 URI를 대상으로 navigation마다 한 번, 기존 top-level `redirect`와 `GoRoute.redirect` 체인보다 먼저 실행되며 `Allow`나 `Block`을 반환합니다. feature flag, paywall, 강제 업데이트 상태로 막을 때 씁니다. redirect 단계마다 다시 실행되지 않으므로 해석된 목적지에 의존하는 로직은 여기 두지 않습니다. 첫 navigation을 막으면 `BlockedInitialNavigationException`(17.4.0)이 발생하고, `onException`이 이를 일반 routing 실패와 구분할 수 있습니다.
- `redirect`는 위치를 정규화하고 인증을 담당합니다. 인증은 top-level에 한 번만 두고 인증 상태를 `Listenable`로 노출해 `refreshListenable`에 넘깁니다. 그래야 로그인과 로그아웃 뒤 redirect가 다시 평가됩니다. 공식 샘플은 `AuthRepository extends ChangeNotifier`를 씁니다. 로그인 후 복귀는 `state.uri`로 원래 위치를 되돌립니다.
- `redirectLimit` 기본값은 5입니다. 이 한도를 넘는 체인은 error 화면을 보여 주므로, 반복될 수 있는 redirect는 견뎌야 할 런타임 조건이 아니라 고칠 결함입니다.

어느 guard든 UI 숨김으로 대신하지 않고, 첫 프레임이 정착하지 않은 session 읽기에 의존하게 두지 않습니다.

## Redirect는 인가가 아님

`redirect`는 앱 상태로 움직이는 표현 흐름입니다(Safety). 링크는 인증 상태가 정착하기 전에 도착할 수 있고 `refreshListenable`은 상태가 바뀐 뒤에만 다시 평가합니다. 그래서 redirect는 렌더링된 화면의 접근 허용을 보장하지 않습니다. 보호된 데이터를 보여 주는 화면은 데이터를 그릴 때 repository나 정책 계층에 권한을 확인합니다. redirect가 성공했다는 사실, 또는 redirect가 없었다는 사실을 접근 판정으로 쓰지 않습니다.

## Deep link parameter는 신뢰할 수 없는 입력

링크로 들어오는 path parameter, query parameter, `extra`는 공격자가 조작할 수 있습니다(Safety). domain 타입의 parser로 파싱하고, 잘못된 값은 navigation 전에 거부하고, 앱이 소유한 host와 path만 허용 목록에 두며, 결제나 역할 변경이나 관리자 API 호출 같은 특권 동작에 그대로 넣지 않습니다. 검증을 통과한 parameter도 식별자일 뿐이므로 repository로 객체를 읽어 실제 데이터에 인가를 적용합니다.

## Typed route

`go_router_builder`는 `@TypedGoRoute` annotation에서 route class를 생성합니다. 생성 코드가 프로젝트에 통합되어 있고 build 단계를 받아들일 때 typed route를 씁니다(Hypercore convention). 문자열 path는 feature 코드에 두지 않습니다.

```dart
part 'order_routes.g.dart';

@TypedGoRoute<OrderRoute>(path: '/orders/:orderId')
class OrderRoute extends GoRouteData with _$OrderRoute {
  const OrderRoute({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OrderDetailScreen(orderId: orderId);
}
```

생성 route 파일은 annotation과 같은 library의 `part`여야 합니다. 목록에 없는 파일은 생성 route table에서 조용히 빠집니다. 이동은 생성 class로 하고(`const OrderRoute(orderId: '42').go(context)`) 손으로 만든 문자열을 쓰지 않습니다. `.g.dart`는 직접 고치지 않고, CI에서 `dart run build_runner build --delete-conflicting-outputs`를 실행한 뒤 clean-tree 검사를 붙여 오래된 생성 결과가 빌드를 실패시키게 합니다.

## 복원 가능한 화면과 extra 휘발성

상태 복원은 opt-in입니다(Official). `GoRouter`와 `MaterialApp.router` 양쪽에 `restorationScopeId`를 두고, `pageBuilder` route의 page에는 `restorationId`를 줍니다. `ShellRoute`나 `StatefulShellRoute`에는 자체 `restorationScopeId`와 그것을 가진 page를 반환하는 `pageBuilder`가 필요하고, `StatefulShellBranch`마다도 `restorationScopeId`가 필요합니다. 복원은 영속이 아니고 branch를 살려 두는 장치도 아닙니다.

`extra`는 휘발성 최적화입니다(Official). browser 새로고침, 프로세스 종료, 링크로 시작한 콜드 스타트에서 사라지므로 모든 화면은 path와 query parameter만으로 다시 만들어져야 하고 `extra == null`이면 데이터를 가져오는 경로를 가져야 합니다. 복원까지 값을 살려야 할 때만 `extraCodec`을 붙이고, payload를 encoding하기보다 식별자를 URL에 두는 편을 택합니다.

## Shell

`ShellRoute`는 중첩 `Navigator` 둘레에 지속 chrome을 그립니다. 그래서 bottom bar가 shell 안의 push에도 남습니다. `StatefulShellRoute`와 `StatefulShellRoute.indexedStack`은 `StatefulShellBranch`마다 `Navigator`를 주고 tab 전환에도 branch 상태를 유지합니다. 전환은 `navigationShell.goBranch(index)`로 하고 미리 데워야 하는 branch는 `preload`를 씁니다. branch가 각자의 route tree를 소유하며 shell에는 route를 구성하지 않습니다. 구성 주제 문서는 tab 상태를 유지해야 할 때 `ShellRoute` 대신 `StatefulShellRoute`를 권장하는데, 이는 대부분의 tab 앱에 해당합니다.

17.0.0에서 `ShellRoute` navigation이 기본으로 root observer에 알리게 바뀌었으므로, 업그레이드 뒤에는 이전 동작을 가정하지 말고 analytics와 observer callback을 다시 확인합니다.

## 오류

`onException`을 씁니다(Official). `errorBuilder`와 `errorPageBuilder`를 대체하고 router state를 받으므로, 맞지 않는 URL에는 not-found 화면을, 막힌 첫 navigation에는 다른 화면을 보여 줄 수 있습니다. `GoError`와 `AssertionError`는 잡지 않습니다. 사용자에게 보여 줄 런타임 조건이 아니라 stack trace가 붙은 프로그래밍 오류입니다. `GoException`은 런타임 구성 불일치 타입입니다. 실패 종류마다 error 화면 하나를 두고 시도한 위치를 로그에 남깁니다.

## Deep link

Flutter 내장 deep link 처리기는 3.27부터 기본으로 켜져 있습니다. 그 전에는 `false`였습니다(Official). 서드파티 link 플러그인이 링크를 처리하면 내장 처리기를 끕니다. 그러지 않으면 둘이 같은 이벤트를 두고 경쟁합니다. Android manifest meta-data의 `flutter_deeplinking_enabled`를 `false`로, `Info.plist`의 `FlutterDeepLinkingEnabled`를 `false`로 설정합니다. 링크 소유자를 하나로 정해 기록하고, 다른 처리기를 끈 빌드에서 링크를 시험합니다.

Android App Link는 main activity에 `android:autoVerify="true"`, `VIEW`, `DEFAULT`, `BROWSABLE`, `https` data가 붙은 intent filter가 필요하고, `https://<domain>/.well-known/assetlinks.json`에 `relation: ["delegate_permission/common.handle_all_urls"]`, `namespace: "android_app"`, `package_name`, 서명 인증서마다 하나씩 `sha256_cert_fingerprints` 항목이 필요합니다. 스토어 빌드는 Play App Signing 지문을 포함합니다. Android는 설치 시점에 검증하므로 `adb shell pm get-app-links <package>`로 결과를 확인하고 서명 인증서가 바뀌면 다시 검증합니다.

iOS Universal Link는 `com.apple.developer.associated-domains` entitlement에 `applinks:<domain>`이 필요하고, `https://<domain>/.well-known/apple-app-site-association`을 유효한 인증서와 redirect 없는 HTTPS로, `.json` 확장자 없이 제공해야 합니다. 앱을 열어야 할 `appIDs`와 `components` path를 선언하고 browser에 남겨야 할 path는 `exclude`로 뺍니다. Apple은 이 파일을 CDN으로 제공하므로 수정이 즉시 반영되지 않습니다.

두 소유 파일은 앱 구성 옆에 두고 소유 domain을 문서화하며, 검증은 일회성 설정이 아니라 릴리스 체크리스트 항목으로 다룹니다. 3.50+ beta 변경은 Android embedder를 강화합니다. release 빌드는 intent로 받은 엔진 extra를 검증하고 링크 URI가 intent filter와 맞아야 합니다. 앱이 소유하지 않은 path를 wildcard로 두지 말고 app link host를 명시적으로 유지합니다.

## Web URL

웹은 이 패키지에서 선택 대상입니다. hash URL이 기본이고, path 기반 URL은 `runApp` 전에 `flutter_web_plugins`의 `usePathUrlStrategy()`를 호출하고 서버를 `index.html`로 rewrite하며, root 아래에 호스팅할 때 `<base href>`를 맞춰야 합니다. 공유 가능한 깔끔한 URL이 제품에 필요할 때만 path 전략을 넣고, 로컬이 아니라 실제 호스트에서 rewrite를 시험합니다.

## Predictive back

`PopScope`가 `WillPopScope`를 대체했고 `WillPopScope`는 3.16부터 deprecated입니다(Official). `PopScope(canPop: false)`는 결정이 끝나기 전까지 뒤로 가기 제스처를 막고, `onPopInvokedWithResult(bool didPop, Object? result)`는 결과를 사후에 알립니다. `onPopInvoked`는 3.22.0-12.0.pre 이후 deprecated입니다. `Form.canPop`과 `Form.onPopInvokedWithResult`가 `Form.onWillPop`을, `Route.popDisposition`이 `Route.willPop()`을 대체하고, 중첩 navigator는 `NavigatorPopHandler`로 다룹니다.

Android predictive back에는 `<application>` 요소의 `android:enableOnBackInvokedCallback="true"`가 필요합니다. 3.38은 Android 기본 page transition을 `PredictiveBackPageTransitionsBuilder`로 바꾸고 지속 시간을 300ms에서 450ms로 늘렸으므로, pump 시간을 고정한 테스트는 고쳐야 합니다.

`PopScope`는 page-backed 화면의 navigation을 막지 못합니다. router가 소유한 화면은 진입을 `onEnter`로, 이탈을 route의 `onExit`로 막고, `PopScope`는 결과 보고와 router가 소유하지 않은 pageless route에만 씁니다.

## 패키지 상태

`go_router` 18.1.2(2026-10-29, 퍼블리셔 `flutter.dev`)는 Flutter 팀의 router이며 feature-complete로 설명되고, 작업 초점은 버그 수정과 안정성입니다. 방치가 아닙니다. 18.x 패치 릴리스는 계속됩니다. 18.x 계열은 Flutter 3.44와 Dart 3.12를 하한으로 선언하고 `material_ui`와 `cupertino_ui`에 의존합니다. `material_ui` 1.10.0과 `go_router_builder` 4.5.3이 Flutter 3.47 하한을 선언하므로, 새 프로젝트는 3.47을 실질 목표로 잡습니다. 생성 코드와 런타임이 맞도록 `go_router`와 `go_router_builder`를 함께 고정합니다.

3.47에서 독립 `material_ui` 패키지는 새 코드의 권장 기반이고 opt-in이며 강제가 아닙니다. 프로젝트가 이를 받아들이면 디자인 위젯은 `package:material_ui/material_ui.dart`에서 가져오고 각 의존 패키지의 공개 API가 호환되는 `ColorScheme`과 `TextTheme` 타입을 쓰는지 확인합니다. 호환 bridge는 의존 패키지의 타입 불일치를 고치지 못합니다. 프레임워크 내장 라이브러리에 남는 프로젝트는 `package:flutter/material.dart`를 import합니다. 한 route tree에서 두 위젯 집합을 섞지 않고, 의존 타입을 확인하기 전에 새 프로젝트에 `material_ui`를 넣지 않습니다.

`auto_route` 같은 서드파티 router는 팀이 이미 쓸 때 선택할 수 있습니다. 앱마다 router 하나를 유지하고 같은 guard와 deep link 규칙을 적용합니다. 마지막 릴리스가 수년 전인 router는 새 의존성으로 삼지 않습니다.

## Sources

> 확인 2026-11-04. 이 파일을 Flutter 3.47.9 기준으로 작성한 날짜입니다.

| Claim | Source |
|---|---|
| named route는 대부분의 앱에 권장되지 않고, 작은 앱은 `Navigator`, deep link 앱은 라우팅 패키지를 쓴다 | <https://docs.flutter.dev/ui/navigation> |
| page-backed route는 deep link로 열리고 pageless route는 열리지 않으며, `PopScope`는 page-backed navigation을 막지 못한다 | <https://docs.flutter.dev/ui/navigation> |
| view에는 단순 routing logic만 둔다 | <https://docs.flutter.dev/app-architecture/guide> |
| 내장 deep link 처리기는 3.27부터 기본 활성이고 서드파티 link 플러그인을 쓰면 꺼야 한다 | <https://docs.flutter.dev/release/breaking-changes/deep-links-flag-change>, <https://docs.flutter.dev/ui/navigation/deep-linking> |
| Android App Link는 `autoVerify`와 호스팅된 `assetlinks.json`을 쓴다 | <https://docs.flutter.dev/cookbook/navigation/set-up-app-links>, <https://developer.android.com/training/app-links/verify-applinks> |
| iOS Universal Link는 `applinks:` associated domain과 `.json` 확장자가 없는 호스팅 파일을 쓴다 | <https://docs.flutter.dev/cookbook/navigation/set-up-universal-links>, <https://developer.apple.com/documentation/xcode/supporting-associated-domains> |
| `go_router` 18.1.2 metadata, 퍼블리셔, feature-complete 문구 | <https://pub.dev/packages/go_router>, <https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/README.md> |
| guard 순서, `onEnter`의 `Allow`/`Block` 반환, `redirectLimit` 기본값 5, `refreshListenable` | <https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html>, <https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html> |
| `onException`은 `errorBuilder`와 `errorPageBuilder`를 대체한다 | <https://pub.dev/documentation/go_router/latest/topics/Error%20handling-topic.html> |
| branch 상태를 유지해야 할 때 `ShellRoute`보다 `StatefulShellRoute`를 쓴다 | <https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html> |
| typed route는 `GoRouteData`를 상속하고 `go_router_builder`가 생성한다 | <https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html>, <https://pub.dev/api/packages/go_router_builder> |
| 복원은 scope와 restoration 식별자로 opt-in 한다 | <https://pub.dev/documentation/go_router/latest/topics/State%20restoration-topic.html> |
| go_router 18.0.0이 `material_ui`와 `cupertino_ui`로 이전했다 | <https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/CHANGELOG.md> |
| `WillPopScope`는 deprecated이고 `PopScope`는 `canPop`과 `onPopInvokedWithResult`를 쓰며 Android는 `enableOnBackInvokedCallback`이 필요하다 | <https://docs.flutter.dev/release/breaking-changes/android-predictive-back>, <https://api.flutter.dev/flutter/widgets/PopScope-class.html>, <https://docs.flutter.dev/platform-integration/android/predictive-back> |
| 3.38이 Android 기본 page transition과 지속 시간을 바꿨다 | <https://docs.flutter.dev/release/breaking-changes/default-android-page-transition> |
| `onDidRemovePage`가 `onPopPage`를 대체하고 pop 거부권이 `Page.canPop`으로 옮겨졌다 | <https://docs.flutter.dev/release/breaking-changes/navigator-and-page-api> |
| 웹 기본값은 hash URL이고 path URL은 `usePathUrlStrategy`와 서버 rewrite가 필요하다 | <https://docs.flutter.dev/ui/navigation/url-strategies> |
| 3.50+ beta: release 빌드가 Android intent extra를 검증하고 intent filter 일치를 요구한다 | <https://docs.flutter.dev/release/breaking-changes/stricter-android-entrypoint-intent-verification> |

### 근거 등급

`OFFICIAL + DERIVED` - 내비게이션 모델, guard 순서, redirect 한도, deep link 플래그와 검증 파일, typed route 생성, 복원, shell, 오류 처리, predictive back 서술은 표에 적은 Flutter와 `go_router` 문서를 재진술한 것입니다. 단일 router 폴더, 얇은 route 규칙, "redirect는 인가가 아님" 규칙, 신뢰할 수 없는 parameter 규칙은 그 문서에서 이끌어 낸 Safety 및 Hypercore 관례입니다. redirect가 접근을 강제한다고 밝힌 공식 문서는 없고, 링크 목적지가 공격자 영향을 받는다고 밝힌 공식 문장은 intent 검증 변경뿐입니다. 버전 하한은 설명문이 아니라 pub metadata에서 읽었습니다.
