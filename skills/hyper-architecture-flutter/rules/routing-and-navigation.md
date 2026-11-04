# Routing and Navigation

Read when changing the route table, a guard, a deep link, or back behavior. This file owns the navigation model decision, the single router configuration, guard and redirect contracts, deep-link input handling, restorable screens, and predictive back.

## Official boundary

Flutter owns `Navigator` and `Router`, the platform deep-link flags and verification files, and the predictive-back migration. Route table layout, guard placement, and the folder that holds routing code are conventions in this file unless the statement is marked Official. Name the Flutter version a change targets: samples for 3.47 import design widgets from the standalone packages, and anything from 3.50 is marked as upcoming. Confirm the installed version with `flutter --version` and the `environment` block in `pubspec.yaml` before quoting a floor.

## Navigation model decision

Decide once, before the route table exists, and record the decision next to the router.

| Situation | Model |
|---|---|
| Small app, no deep-link parity requirement, one shallow stack | `Navigator` with `push`/`pop` and `MaterialPageRoute` |
| Links must open the same screen on Android and iOS, or the web address bar must reflect the location | `MaterialApp.router` with a routing package such as `go_router` |
| Requirements exceed what a routing package expresses, such as a custom URL grammar | Raw Router 2.0 (`RouterDelegate` and `RouteInformationParser`), documented as the advanced path |

Named routes (`MaterialApp.routes` and `onGenerateRoute`) are not recommended for most applications (Official). Their behavior cannot be customized because they always push a new `Route`, and the browser forward button is unsupported. Do not add them in new code and do not mix them with a router.

Routes created by a routing package are page-backed and deep-linkable. `Navigator.push` and `showDialog` add pageless routes that a URL cannot address, and removing a page-backed route also removes the pageless routes above it. Keep the top-level stack in the router and use imperative pushes only for local UI the URL does not name.

## One router configuration

Create one router instance under `lib/routing/` and pass it as `routerConfig` to `MaterialApp.router` (Hypercore convention). Nothing else in the app constructs a `GoRouter`; tests inject the same instance or a test double built from the same route list.

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

Read the router with `GoRouter.of(context)` or `maybeOf`, and keep `debugLogDiagnostics` on in debug builds so route transitions appear in the log. Reach for `GoRouter.routingConfig` with a `ValueListenable<RoutingConfig>` only when the route table itself must change at runtime for a feature flag or an auth scope.

## Thin routes

A route builder may read and validate route parameters, choose transition and shell options, and compose a feature screen. It must not fetch data, own state, or implement business rules; the official architecture guide allows only simple routing logic in a view. Screens stay in their feature folder and routing code imports them, never the reverse.

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

Parse parameters into domain types at the route, so a malformed identifier becomes a not-found screen instead of an exception deep in a feature.

## Guards and redirects

`onEnter` and `redirect` have different jobs (Official, go_router 18.1.2).

- `onEnter` (since 16.3.0) is the guard. It runs once per navigation, before the legacy top-level `redirect` and any `GoRoute.redirect` chain, against the literal target URI of a deep link, `go`, or `push`, and returns `Allow` or `Block`. Use it to block by feature flag, paywall, or force-update state. It does not re-run per redirect hop, so logic that depends on the resolved destination does not belong here. Blocking the first navigation raises `BlockedInitialNavigationException` (17.4.0), which `onException` can tell apart from an ordinary routing failure.
- `redirect` normalizes a location and carries authentication. Register auth once at the top level and expose auth state as a `Listenable` through `refreshListenable`, so the redirect re-evaluates after login or logout; the official sample uses `AuthRepository extends ChangeNotifier`. Return to the original location after sign-in from `state.uri`.
- `redirectLimit` defaults to 5. A chain that exceeds it shows the error screen, so a redirect that can loop is a defect to fix, not a runtime condition to tolerate.

Do not hide UI as a substitute for either guard, and do not let the first frame depend on a session read that has not settled.

## Redirect is not authorization

`redirect` is presentation flow driven by app state (Safety). A link can arrive before auth state settles, and `refreshListenable` only re-evaluates after a state change, so a redirect never guarantees that the rendered screen is permitted. Every screen that shows protected data verifies entitlement against the repository or policy layer when it renders the data. Never treat a successful redirect, or the absence of one, as an access decision.

## Deep-link parameters are untrusted input

Path parameters, query parameters, and `extra` arriving from a link are attacker-controllable (Safety). Parse them with the domain type's own parser, reject malformed values before navigation, allow-list the hosts and paths the app owns, and never feed them into a privileged action such as a payment, a role change, or an administrative API call. A validated parameter is still only an identifier; load the object through the repository so authorization runs on real data.

## Typed routes

`go_router_builder` generates route classes from `@TypedGoRoute` annotations. Use typed routes when the generated code is integrated and the team accepts a build step (Hypercore convention), and keep string paths out of feature code.

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

Every generated route file must be a `part` of the same library as its annotations; a file that is not listed is silently omitted from the generated route table. Navigate with the generated class (`const OrderRoute(orderId: '42').go(context)`), never with a hand-built string. Never hand-edit `.g.dart`, and run `dart run build_runner build --delete-conflicting-outputs` in CI followed by a clean-tree check so a stale generation fails the build.

## Restorable screens and extra volatility

State restoration is opt-in (Official). Set `restorationScopeId` on both `GoRouter` and `MaterialApp.router`, give `pageBuilder` routes a page `restorationId`, and give `ShellRoute` or `StatefulShellRoute` their own `restorationScopeId` plus a `pageBuilder` that returns a page with one; each `StatefulShellBranch` also needs `restorationScopeId`. Restoration is not persistence, and it is not what keeps a branch alive.

`extra` is a volatile optimization (Official). It is lost on browser refresh, on process death, and on a cold start from a link, so every screen must rebuild from path and query parameters alone and handle `extra == null` by fetching. Supply `extraCodec` only when a value must survive restoration, and prefer putting the identifier in the URL over encoding a payload.

## Shells

`ShellRoute` renders persistent chrome around a nested `Navigator`, so a bottom bar survives pushes inside the shell. `StatefulShellRoute` with `StatefulShellRoute.indexedStack` gives each `StatefulShellBranch` its own `Navigator` and preserves branch state across tab switches; switch with `navigationShell.goBranch(index)` and use `preload` for branches that must warm up. Branches own their own route trees, and routes are not configured on the shell. The configuration topic recommends `StatefulShellRoute` instead of `ShellRoute` where tab state must survive, which describes most tabbed apps.

17.0.0 made `ShellRoute` navigation notify root observers by default, so re-check analytics and observer callbacks after an upgrade instead of assuming the previous behavior.

## Errors

Use `onException` (Official). It supersedes `errorBuilder` and `errorPageBuilder`, and it receives the router state, so it can show a not-found screen for an unmatched URL and a different screen for a blocked initial navigation. Do not catch `GoError` or `AssertionError`: they are programming errors with a stack trace, not runtime conditions to present to a user. `GoException` is the runtime configuration-mismatch type. Keep one error screen per failure class and log the attempted location.

## Deep links

Flutter's built-in deep-link handler is enabled by default since 3.27, where it was `false` before (Official). When a third-party link plugin handles links, disable the built-in handler or the two compete for the same event: set `flutter_deeplinking_enabled` to `false` in the Android manifest meta-data and `FlutterDeepLinkingEnabled` to `false` in `Info.plist`. Choose one owner for links, record it, and test the link on a build that has the other handler disabled.

Android App Links need an intent filter with `android:autoVerify="true"`, `VIEW`, `DEFAULT`, `BROWSABLE`, and `https` data on the main activity, plus `https://<domain>/.well-known/assetlinks.json` containing `relation: ["delegate_permission/common.handle_all_urls"]`, `namespace: "android_app"`, the `package_name`, and one `sha256_cert_fingerprints` entry per signing certificate, including the Play App Signing fingerprint for store builds. Android verifies at install time; inspect the result with `adb shell pm get-app-links <package>` and re-verify after a signing certificate change.

iOS Universal Links need the `com.apple.developer.associated-domains` entitlement with `applinks:<domain>`, plus `https://<domain>/.well-known/apple-app-site-association` served over HTTPS with a valid certificate, no redirects, and no `.json` extension. Declare `appIDs` and the `components` paths that should open the app, and use `exclude` for paths that must stay in the browser. Apple serves the file through its CDN, so an edit does not take effect immediately.

Keep both ownership files next to the app configuration with a documented owning domain, and treat verification as a release checklist item rather than one-time setup. A 3.50+ beta change hardens the Android embedder: release builds verify engine extras received through intents and require a link URI to match an intent filter. Keep app-link hosts explicit rather than wildcarding paths the app does not own.

## Web URLs

Web is an optional target for this package. Hash URLs are the default; a path-based URL needs `usePathUrlStrategy()` from `flutter_web_plugins` before `runApp`, a server rewrite to `index.html`, and a correct `<base href>` when the app is hosted below the root. Add the path strategy only when the product needs shareable clean URLs, and test the rewrite on the real host rather than locally.

## Predictive back

`PopScope` replaced `WillPopScope`, and `WillPopScope` has been deprecated since 3.16 (Official). `PopScope(canPop: false)` disables the back gesture while a decision is pending, and `onPopInvokedWithResult(bool didPop, Object? result)` reports the outcome after the fact; `onPopInvoked` is deprecated after 3.22.0-12.0.pre. `Form.canPop` and `Form.onPopInvokedWithResult` replace `Form.onWillPop`, `Route.popDisposition` replaces `Route.willPop()`, and `NavigatorPopHandler` covers nested navigators.

Android predictive back needs `android:enableOnBackInvokedCallback="true"` on the `<application>` element. 3.38 changed the default Android page transition to `PredictiveBackPageTransitionsBuilder` and raised the duration from 300ms to 450ms, so tests that hardcode pump durations need updating.

`PopScope` cannot prevent navigation from a page-backed screen. For router-owned screens, block entry with `onEnter` and block leaving with the route's `onExit`; reserve `PopScope` for result reporting and for pageless routes the router does not own.

## Package status

`go_router` 18.1.2 (2026-10-29, publisher `flutter.dev`) is the Flutter team's router and is described as feature-complete, with work focused on bug fixes and stability. That is not abandonment; 18.x patch releases continue. Its 18.x line declares Flutter 3.44 and Dart 3.12 as floors and depends on `material_ui` and `cupertino_ui`. Because `material_ui` 1.10.0 and `go_router_builder` 4.5.3 declare a Flutter 3.47 floor, a new project on 3.47 is the practical target. Pin `go_router` and `go_router_builder` together so the generated code matches the runtime.

On 3.47 the standalone `material_ui` package is the recommended base for new code and is opt-in rather than mandatory. When the project adopts it, import design widgets from `package:material_ui/material_ui.dart` and check that each dependency's public API uses compatible `ColorScheme` and `TextTheme` types; the compatibility bridge does not repair dependency type mismatches. A project that stays on the in-framework library imports `package:flutter/material.dart`. Do not mix both widget sets in one route tree, and do not add `material_ui` to a new project without checking the dependency types first.

A third-party router such as `auto_route` is viable when the team already uses it; keep one router per app and apply the same guard and deep-link rules. Do not take a router whose last release is years old as a new dependency.

## Sources

> Checked 2026-11-04, the date this file was written against Flutter 3.47.9.

| Claim | Source |
|---|---|
| Named routes are not recommended for most apps; small apps use `Navigator`, deep-link apps use a routing package | <https://docs.flutter.dev/ui/navigation> |
| Page-backed routes are deep-linkable, pageless routes are not, and `PopScope` cannot block page-backed navigation | <https://docs.flutter.dev/ui/navigation> |
| Only simple routing logic belongs in a view | <https://docs.flutter.dev/app-architecture/guide> |
| The built-in deep-link handler defaults to enabled since 3.27 and must be disabled for third-party link plugins | <https://docs.flutter.dev/release/breaking-changes/deep-links-flag-change>, <https://docs.flutter.dev/ui/navigation/deep-linking> |
| Android App Links use `autoVerify` and a hosted `assetlinks.json` | <https://docs.flutter.dev/cookbook/navigation/set-up-app-links>, <https://developer.android.com/training/app-links/verify-applinks> |
| iOS Universal Links use the `applinks:` associated domain and a hosted file without the `.json` extension | <https://docs.flutter.dev/cookbook/navigation/set-up-universal-links>, <https://developer.apple.com/documentation/xcode/supporting-associated-domains> |
| `go_router` 18.1.2 metadata, publisher, and feature-complete statement | <https://pub.dev/packages/go_router>, <https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/README.md> |
| Guard order, `onEnter` returning `Allow`/`Block`, `redirectLimit` default 5, and `refreshListenable` | <https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html>, <https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html> |
| `onException` supersedes `errorBuilder` and `errorPageBuilder` | <https://pub.dev/documentation/go_router/latest/topics/Error%20handling-topic.html> |
| `StatefulShellRoute` is preferred over `ShellRoute` where branch state must survive | <https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html> |
| Typed routes extend `GoRouteData` and are generated by `go_router_builder` | <https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html>, <https://pub.dev/api/packages/go_router_builder> |
| Restoration is opt-in through scope and restoration identifiers | <https://pub.dev/documentation/go_router/latest/topics/State%20restoration-topic.html> |
| go_router 18.0.0 migrated to `material_ui` and `cupertino_ui` | <https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/CHANGELOG.md> |
| `WillPopScope` is deprecated, `PopScope` uses `canPop` and `onPopInvokedWithResult`, and Android needs `enableOnBackInvokedCallback` | <https://docs.flutter.dev/release/breaking-changes/android-predictive-back>, <https://api.flutter.dev/flutter/widgets/PopScope-class.html>, <https://docs.flutter.dev/platform-integration/android/predictive-back> |
| 3.38 changed the default Android page transition and its duration | <https://docs.flutter.dev/release/breaking-changes/default-android-page-transition> |
| `onDidRemovePage` replaced `onPopPage`, and pop veto moved to `Page.canPop` | <https://docs.flutter.dev/release/breaking-changes/navigator-and-page-api> |
| Hash URLs are the web default and path URLs need `usePathUrlStrategy` plus server rewrites | <https://docs.flutter.dev/ui/navigation/url-strategies> |
| 3.50+ beta: release builds verify Android intent extras and require a matching intent filter | <https://docs.flutter.dev/release/breaking-changes/stricter-android-entrypoint-intent-verification> |

### Evidence grade

`OFFICIAL + DERIVED` - the navigation model, guard ordering, redirect limit, deep-link flags and verification files, typed route generation, restoration, shells, error handling, and predictive-back statements restate the Flutter and `go_router` pages in the table. The single-router folder, thin-route rule, "redirect is not authorization" rule, and untrusted-parameter rule are Safety and Hypercore conventions derived from those pages: no official page states that a redirect enforces access, and the intent-verification change is the only official statement that link targets are attacker-influenced. Version floors are read from pub metadata, not from prose.
