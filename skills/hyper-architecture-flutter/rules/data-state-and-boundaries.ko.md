# 데이터, 상태, 경계

repository를 추가하거나, 상태를 계층 사이에서 옮기거나, 영속 저장 API를 고르거나, JSON mapper를 쓰거나, 의존성을 연결할 때 읽습니다. 이 파일은 상태 소유권, 데이터 계층 경계, 전송 service와 결과 타입, 영속 저장 선택, 직렬화, 의존성 주입을 소유합니다. 2026-11-04에 확인한 Flutter 3.47.9와 Dart 3.13.7을 기준으로 하며, 버전을 고정하기 전에 설치된 패키지 버전을 확인합니다.

## 소유자별 상태 분리

공식 아키텍처 문서는 자기 내용을 "guidelines, not steadfast rules"라고 밝히고 상태 라이브러리를 강제하지 않습니다. 오래 남는 것은 소유권이고, 라이브러리는 프로젝트가 정할 문제입니다.

| 상태 | 소유자 | 규칙 |
|---|---|---|
| 위젯 로컬·일시적 상태 | 그 상태를 그리는 위젯 | `setState`나 `ValueNotifier`를 씁니다. 다른 위젯이 필요로 하거나 rebuild를 넘겨 살아남아야 할 때만 위로 올립니다 |
| ViewModel UI 상태 | view와 1:1로 짝지은 view model | view가 그리는 불변 snapshot입니다. repository 객체가 view에 닿지 않습니다 |
| 공유 데이터와 앱 session | 데이터 계층의 repository, 단일 진실 원천 | 데이터 타입마다 repository 하나입니다. caching, retry, refresh, 앱 전역 lifecycle 상태가 여기 있습니다 |
| 영속 기기 상태 | storage service 하나 위의 repository | version이 있는 schema, migration, 정의된 실패 경로가 있습니다 |
| form 상태 | form 자체의 controller 또는 view model | 입력, 검증, dirty, 제출 lifecycle은 제출 전까지 로컬에 있습니다 |

**위젯 로컬 상태**는 animation 진행률, 펼침 여부, 선택된 tab index, 화면 하나가 소유하는 text입니다. 여기서 `setState`는 맞는 선택이며 나쁜 신호가 아닙니다. 화면이 가져온 데이터는 위젯 상태에 두지 않습니다. rebuild나 뒤로 이동으로 사라지기 때문입니다.

**view model 상태**는 view가 화면 하나를 그리려고 쓰는 값입니다. view는 네 종류의 logic만 가집니다(Official). flag나 nullable에 따른 표시 여부, animation, 기기 정보에 따른 layout, 단순 routing입니다. view model과 repository는 의존성을 private 생성자 member로 받으므로 view가 view model을 거쳐 repository에 닿을 수 없습니다.

**repository 상태**는 해당 데이터 타입의 단일 진실 원천이며 "data changes always happen in the SSOT, which is the data layer"입니다(Official). 앱 전역 lifecycle 상태도 repository에 둡니다. session, 메모리 cache, 일시 설정을 dependency injection container로 view model 사이에서 공유합니다. view model은 server 데이터를 두 번째로 들고 있지 않고 repository에서 다시 읽습니다. repository끼리는 서로를 알지 않습니다(Official). 여러 repository를 합치는 logic이 실제로 복잡하거나 여러 view model이 재사용할 때만 선택적 domain 계층이 그 결합을 맡고, 그 조건일 때만 추가합니다.

**영속 상태**는 storage 위의 repository입니다. 위젯이나 view model이 key를 직접 쓰는 곳이 아닙니다. schema version과 migration을 갖고, 오래된 record를 읽는 일은 신뢰할 수 없는 입력을 다루는 일로 봅니다.

**form 상태**는 제출 전까지 form 안에 남습니다. keystroke마다 공유 상태로 복제하지 않고, 제출할 때 동작 하나가 repository를 호출해 form이 이미 가진 command나 상태로 결과를 보고합니다.

Token과 session secret은 일반 상태가 아닙니다(Safety). 가능한 한 짧게 유지한 값만 secure storage adapter 뒤에 두고, 일반 key-value store에 넣지 않으며, 화면이 필요로 하는 시간보다 오래 위젯이나 view model field에 두지 않습니다.

## 런타임 경계

Dart 타입은 compile time에서 끝납니다. 다음 값은 진입 boundary에서 신뢰할 수 없는 입력으로 다룹니다(Safety). HTTP response body, deep link path와 query parameter 및 `extra`, push payload, disk에서 읽은 record, platform channel과 plugin 결과, 모든 `--dart-define` 값입니다.

`jsonDecode`는 `Object?`를 돌려주고, 모양이 틀리면 analyzer 오류가 아니라 runtime에 `TypeError`로 드러납니다. 따라서 parsing은 타입 표기가 아니라 코드입니다. 타입을 확인하고, 필수 key를 확인하고, 알 수 없는 enum 값을 거절하거나 정규화하고, cast가 위젯 build 안에서 throw하지 않도록 typed failure를 만듭니다.

DTO는 데이터 계층 밖으로 나가지 않습니다(Hypercore convention, raw를 domain으로 바꾸는 일이 repository 몫이라는 Official 규칙과 같습니다). source와 방향마다 mapper를 하나 두고 source와 방향을 이름에 드러냅니다. `ApiToDomainOrder`, `DbToDomainOrder`가 그 예입니다. cent를 통화 단위로 바꾸거나 epoch를 `DateTime`으로 바꾸는 변환 의미는 mapper가 소유하며 view model이나 위젯이 다시 구현하지 않습니다. remote, local, 메모리 source가 공유하는 추상 DTO를 하나 정의하지 않습니다. field와 실패 방식이 다르고, 공유 상위 타입은 nullable field 모음이 됩니다.

실패는 계층마다 하나의 오류 모양으로 정규화해 presentation 앞에 넘깁니다. socket 오류, 401, parse 실패가 view model에 서로 무관한 exception 셋으로 도착하면 안 되고, 하나의 `Result`나 하나의 typed failure 계층으로 도착해야 합니다.

boundary는 substitution, testing, caching, mapping, platform divergence 가운데 하나를 가능하게 할 때 비로소 class로 존재할 이유가 생깁니다. 그중 어느 것도 없는 단일 직접 호출에는 repository와 mapper를 두지 않습니다.

## 전송과 결과 타입

`Service`는 데이터 계층의 맨 아래입니다(Official). 상태가 없고 side effect가 없으며, data source마다 하나 있고, `Future`나 `Stream`을 노출하고, repository를 알 필요가 없습니다. 그 위의 repository가 caching, 오류 처리, retry, refresh, polling, offline 동기화, raw를 domain으로 바꾸는 일을 맡습니다.

HTTP client는 앱마다 하나를 고르고 감춥니다. `http` 1.6.0은 Dart 팀의 최소 client이고, `dio` 5.11.1은 interceptor, 취소, upload를 더하며 production에서 흔히 고릅니다. 고른 package를 `data/services/api/` 아래 `ApiClient` 하나로 감싸고, 기능별 client는 package가 아니라 그 wrapper에 의존합니다.

`dart:io`의 `HttpClient`와 그 위에 만든 `IOClient`는 Android Network Security Config의 trust anchor와 iOS App Transport Security pinning을 적용받지 않습니다(Safety). 플랫폼 정책을 실제로 강제해야 하면 자체 certificate callback을 쓰지 않고 `cupertino_http` 3.1.1이나 `cronet_http` 1.10.1을 `http.Client` 구현으로 주입합니다.

`Result<T>`는 `Ok<T>`와 `Error<T>` 하위 클래스를 둔 sealed class입니다. 공식 데이터 계층 case study는 이 타입을 "a recommendation, but not a requirement"라고 부르고, 공식 sample도 service, repository, view model 전체에 이 타입을 씁니다. 새 데이터 계층에는 빠짐없는 switch가 호출자에게 실패 처리를 강제하므로 이 타입을 채택합니다(Hypercore convention).

```dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.error);
  final Exception error;
}

// Caller
final result = await repository.loadOrder(id);
switch (result) {
  case Ok(:final value):
    _order = value;
  case Error(:final error):
    _failure = mapToMessage(error);
}
```

view model에 도착한 `Error`는 사용자에게 보이는 상태가 되거나 의도적으로 기록한 no-op이 됩니다. 조용히 삼키는 것은 오류 처리가 아니라 결함입니다.

비동기 UI 동작에는 `Command0`과 `Command1<T, A>`를 씁니다. 호출을 감싸고 `running`, `completed`, `error`와 재진입 guard를 노출하므로 view가 비동기 상태를 직접 들지 않습니다. 공식 문서는 이 패턴을 "not a pattern that every app will want to implement"라고 규정하므로, 전면 의무가 아니라 view model 경로와 함께 받아들입니다.

`Command`라는 이름은 생태계에서 뜻이 둘입니다. 다른 확립된 관례는 domain mutation에 `Command`(`UpdateProductTitleCommand`)를, 읽기에 `Query`를 씁니다. 한 앱 안에 두 뜻을 함께 두지 않습니다. 프로젝트가 domain mutation을 `...Command`로 부른다면 UI 비동기 wrapper는 다른 이름을 쓰거나 utility 파일 하나에 가두고 차이를 문서화합니다. 이 결정을 미루면 한 앱에 호환되지 않는 `Command` 추상이 둘 생깁니다.

## 상태 라이브러리

어떤 라이브러리도 필수가 아닙니다(Official). 문서가 제시하는 출발점은 `provider`와 `ChangeNotifier`이고, riverpod, bloc, signals는 동등하게 유효한 대안으로 언급됩니다. 공식 options 문서는 선택을 앱 복잡도와 팀 선호에 맡깁니다.

기능마다 주 메커니즘은 하나만 씁니다. 기능 사이에서 메커니즘이 섞이는 것은 의도적이면 괜찮지만, 화면 하나 안에 두 메커니즘이 있으면 결함입니다. 상태 소유권을 읽을 수 없게 만들기 때문입니다.

### Riverpod 3을 쓸 때

`flutter_riverpod` 3.4.3(2026-09-03)은 아키텍처 검토가 반영해야 할 동작을 바꿨습니다.

- 모든 provider가 `==`로 update를 걸러 냅니다(Official migration guide). 상태 객체에 값 동등성이 필요합니다. `freezed`, `equatable`, record, 명시적 `==` 가운데 하나를 씁니다. 같은 mutable list 인스턴스를 다시 내보내는 provider는 rebuild를 만들지 않습니다.
- provider 초기화 실패를 기본으로 자동 재시도합니다. 약 200ms에서 6.4s까지 지수 backoff를 씁니다. 실패를 즉시 드러내야 하면 `ProviderScope`나 `ProviderContainer`, 또는 provider별로 `retry: (count, error) => null`을 지정해 끕니다.
- `Ref`에 type parameter가 없습니다. `ExampleRef`가 아니라 `Ref ref`로 씁니다. `AutoDispose*` interface는 없어졌고, `FamilyNotifier`와 `FamilyAsyncNotifier`는 생성자 인자를 받고 parameter 없는 `build()`를 쓰는 `Notifier` 하나로 합쳐졌습니다.
- view 밖에 있는 provider의 listener는 일시 정지됩니다. 정지된 provider가 계속 update를 받아야 하면 `TickerMode(enabled: true)`로 덮습니다.
- dispose 뒤에 `Ref`를 쓰면 `UnmountedRefException`이 납니다. await 뒤마다 `ref.mounted`로 확인합니다.
- provider persistence와 mutations는 아직 experimental입니다. 이것 없이는 출시할 수 없는 data migration이나 write 경로를 여기에 얹지 않습니다.

### Bloc 9를 쓸 때

`bloc` 9.2.1, `flutter_bloc` 9.1.1, `hydrated_bloc` 11.0.0이며 `hydrated_bloc`의 storage는 `hive_ce`로 옮겨졌습니다. 문서의 모델은 계층 셋이고 엄격한 규칙이 하나 있습니다. 어떤 bloc도 다른 bloc을 알지 않습니다. 기능 사이의 반응은 presentation listener나 반응형 repository stream으로 잇습니다. bloc은 생성자로 repository를 받고 직접 만들지 않습니다.

## 영속 저장

습관이 아니라 데이터 모양으로 고릅니다.

| 필요 | API |
|---|---|
| flag, 설정값, 작은 scalar | `shared_preferences` 2.5.6과 `SharedPreferencesAsync`(로컬 cache 없음) 또는 `SharedPreferencesWithCache`(동기 getter, 외부 write 뒤 `reload()` 필요) |
| 구조가 있고 조회가 필요한 관계형 데이터 | `drift` 2.35.3(typed SQL, migration, 반응형 query) 또는 `sqflite` 2.4.5(raw SQLite, Dart 3.12와 Flutter 3.44 이상 필요) |
| 작은 객체 graph, key로 찾는 record | `hive_ce` 2.22.0 |

`SharedPreferences` class는 legacy API이고 앞으로 deprecated될 예정이며, 새 코드는 `SharedPreferencesAsync`나 `SharedPreferencesWithCache`를 씁니다(Official). async API는 로컬 cache를 쓰지 않으므로 읽기마다 platform을 호출합니다. cached API는 동기 getter를 주지만 isolate, engine instance, native write 사이에서 stale해지며, 그래서 `reload()`가 있습니다. 새 API는 Android에서 DataStore Preferences를 기본으로 씁니다.

`shared_preferences`는 README가 중요 데이터에 쓰지 말라고 밝히고 암호화되지 않으므로 token, session secret, 개인 record를 넣지 않습니다. 작은 민감 값은 `flutter_secure_storage` 11.2.0 뒤에 둡니다. iOS에서는 Keychain을, Android에서는 Keystore 기반 cipher를 쓰며, unwrap 실패와 backup 제외를 처리하는 좁은 adapter로 감쌉니다.

`hive`가 아니라 `hive_ce`를 씁니다. `hive` 2.2.3은 `sdk: ">=2.12.0 <3.0.0"`을 선언해 Dart 3 프로젝트에서 resolve되지 않습니다. `hive_ce`가 유지되는 fork이고 `hydrated_bloc` 11이 의존하는 쪽입니다.

모든 영속 저장에는 version과 migration, migration 실패 시의 결정이 필요합니다. 버리고 다시 가져오거나, 메시지와 함께 기능을 막습니다. 기본값을 돌려주는 `catch`는 데이터 손실을 숨깁니다.

## 직렬화

prototype에서는 직접 쓴 `fromJson`도 괜찮습니다. 공식 JSON 문서는 중간 규모 이상 프로젝트에 code generation을 쓰라고 하고 `json_serializable`과 `built_value`를 듭니다. Flutter에는 reflection이 없으므로 reflection 기반 mapping은 선택지가 아닙니다.

모델이 몇 개를 넘으면 DTO에 `json_serializable` 6.15.2를 채택합니다(Hypercore convention). 직접 쓴 parser에는 field 타입마다 단위 test가 필요합니다. key 누락, 타입 불일치, 알 수 없는 enum 값을 포함합니다.

Dart macro는 2025-01-29에 중단됐고 augmentation은 experimental이므로, code generation은 여전히 `build_runner` 2.17.1로 돌립니다. CI에서 생성하고, 작업 tree가 깨끗하지 않으면 실패하게 해서 오래된 `.g.dart`가 출시되지 않게 합니다.

`freezed` 4.0.3은 공식 권장이 아니라 community 관례입니다. 불변 상태, `copyWith`, 값 동등성을 주고, 이 파일의 규칙 몇 가지가 그 값에 기댑니다. `==` provider filtering과 불변 view model snapshot입니다. 프로젝트가 이미 쓰면 쓰고, 아니면 명시적 `==`와 `hashCode`를 둔 평범한 class도 유효한 대안입니다. 필수로 제시하지 않습니다. 생성 파일은 프로젝트가 commit할 때만 commit하고 직접 고치지 않습니다.

## 구성

의존성 주입은 배선 문제이지 package 선택 문제가 아닙니다. 공식 권장은 `package:provider` 6.1.5+1입니다. 앱 root에서 `MultiProvider`로 service와 repository를 등록하고, remote 목록과 local·fake 목록 같은 환경별 목록을 entry point가 고르게 두고, route builder에서 `context.read()`로 view model을 만듭니다. 생성자 주입이 먼저이고, provider tree는 위젯 계층이 composition root에 닿는 통로일 뿐입니다.

프로젝트가 다른 메커니즘을 받아들이면(Riverpod `ProviderScope`, bloc `BlocProvider`, service locator로서 `get_it` 9.3.0) 메커니즘은 하나만 두고, 선택을 composition root 옆에 기록하고, 같은 규칙을 유지합니다. root에서 조립하고 그 아래는 private 생성자 의존성입니다. 위젯이 전역에서 repository를 찾지 않습니다.

구성 값은 시작 시점에 만든 typed 객체 하나로 들어옵니다. base URL, flavor, feature flag, log level입니다. 기능 곳곳에 `String.fromEnvironment` 호출을 흩뿌리지 않습니다. `--dart-define` 값은 모두 출시 binary 안의 compile time 상수이므로 전부 공개 값으로 다룹니다. 비밀로 남아야 하는 값은 server에 두고, secret 저장은 이 파일이 아니라 보안 규칙이 다룹니다.

필수 구성은 시작 시점에 검증하고 이름 있는 오류로 실패합니다. 빈 base URL이 request까지 도달하면 구성 실수가 runtime 미스터리가 됩니다.

## Sources

> 확인 2026-11-04. 이 파일을 Flutter 3.47.9 기준으로 작성한 날짜입니다.

| Claim | Source |
|---|---|
| 아키텍처 문서는 구속력이 없고 상태 라이브러리를 강제하지 않는다 | <https://docs.flutter.dev/app-architecture/guide>, <https://docs.flutter.dev/data-and-backend/state-mgmt/options> |
| 데이터 계층이 단일 진실 원천이고 변경이 그곳에서 일어나며, 데이터 타입마다 repository가 하나다 | <https://docs.flutter.dev/app-architecture/guide>, <https://docs.flutter.dev/app-architecture/concepts> |
| repository는 session과 메모리 cache 같은 앱 전역 lifecycle 상태도 소유한다 | <https://docs.flutter.dev/app-architecture/guide> |
| service는 상태가 없고 side effect가 없으며 data source마다 하나 있고 repository를 알지 않는다 | <https://docs.flutter.dev/app-architecture/guide> |
| view는 표시 여부, animation, layout, 단순 routing logic만 갖고 view model은 private 생성자 의존성을 받는다 | <https://docs.flutter.dev/app-architecture/guide>, <https://docs.flutter.dev/app-architecture/case-study/ui-layer> |
| `Result`는 `Ok`와 `Error`를 둔 sealed class이고 권장이지 요구가 아니다 | <https://docs.flutter.dev/app-architecture/design-patterns/result>, <https://docs.flutter.dev/app-architecture/case-study/data-layer> |
| `Command`는 동작을 감싸 running, completed, error 상태를 노출하며 모든 앱에 맞는 패턴은 아니다 | <https://docs.flutter.dev/app-architecture/design-patterns/command> |
| 의존성 주입은 `package:provider`로 권장되며 repository를 root에 등록한다 | <https://docs.flutter.dev/app-architecture/case-study/dependency-injection> |
| DTO와 mapper는 data package 안에 남고 source와 방향마다 converter가 하나다 | <https://engineering.verygood.ventures/architecture/ffca/data> |
| domain mutation class를 `Command`로 부르는 관례가 UI 비동기 `Command` 이름과 충돌한다 | <https://engineering.verygood.ventures/architecture/ffca/domain> |
| `Command0`/`Command1`과 `Result` 계약, 재진입 guard | <https://raw.githubusercontent.com/flutter/samples/main/compass_app/app/lib/utils/command.dart>, <https://raw.githubusercontent.com/flutter/samples/main/compass_app/app/lib/utils/result.dart> |
| 환경별 provider 목록을 둔 `MultiProvider`와 route builder의 `context.read()` | <https://raw.githubusercontent.com/flutter/samples/main/compass_app/app/lib/config/dependencies.dart> |
| Riverpod 3은 `==`로 update를 거르고, 실패한 provider를 기본 재시도하며, typed `Ref`와 `AutoDispose` interface를 없애고 view 밖 listener를 일시 정지한다 | <https://riverpod.dev/docs/3.0_migration> |
| Riverpod persistence와 mutations는 experimental이다 | <https://riverpod.dev/docs/whats_new> |
| Riverpod 버전과 lint 동반 package | <https://pub.dev/api/packages/flutter_riverpod>, <https://pub.dev/api/packages/riverpod_lint> |
| Bloc 9 버전, 3계층 모델, bloc이 다른 bloc을 모르는 규칙 | <https://bloclibrary.dev/architecture>, <https://pub.dev/api/packages/bloc>, <https://pub.dev/api/packages/flutter_bloc> |
| `hydrated_bloc` 11은 `hive_ce`로 저장한다 | <https://pub.dev/api/packages/hydrated_bloc> |
| `shared_preferences`에 API가 셋 있고 legacy class는 deprecated 예정이며 async API에는 로컬 cache가 없고 중요 데이터를 담으면 안 된다 | <https://raw.githubusercontent.com/flutter/packages/main/packages/shared_preferences/shared_preferences/README.md>, <https://pub.dev/packages/shared_preferences> |
| `flutter_secure_storage`는 Keychain과 Keystore 기반 암호화를 쓴다 | <https://pub.dev/packages/flutter_secure_storage> |
| `drift`와 `sqflite` 버전과 SDK 하한 | <https://pub.dev/api/packages/drift>, <https://pub.dev/api/packages/sqflite> |
| `hive` 2.2.3은 Dart 3 이전 SDK 경계를 선언하고 `hive_ce`가 유지되는 fork다 | <https://pub.dev/api/packages/hive>, <https://pub.dev/api/packages/hive_ce> |
| 공식 JSON 문서는 중간 규모 이상 프로젝트에 `json_serializable`이나 `built_value` code generation을 권한다 | <https://docs.flutter.dev/data-and-backend/serialization/json> |
| Dart macro가 중단되어 `build_runner`가 codegen 기반으로 남는다 | <https://dart.dev/blog/an-update-on-dart-macros-data-serialization> |
| `json_serializable`, `build_runner`, `freezed` 버전과 SDK 하한 | <https://pub.dev/api/packages/json_serializable>, <https://pub.dev/api/packages/build_runner>, <https://pub.dev/api/packages/freezed> |
| `http`와 `dio` 버전과 기능 차이 | <https://pub.dev/api/packages/http>, <https://pub.dev/api/packages/dio> |
| `dart:io` 연결은 플랫폼 network 정책을 우회하고 `cupertino_http`/`cronet_http`가 플랫폼 기반 client를 제공한다 | <https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android>, <https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cupertino_http/README.md>, <https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cronet_http/README.md> |
| `provider`와 `get_it` 버전 | <https://pub.dev/api/packages/provider>, <https://pub.dev/api/packages/get_it> |

### 근거 등급

`OFFICIAL + DERIVED` - 계층 소유권, 단일 진실 원천, service와 repository의 책임, view model의 가시성 규칙, `Result`와 `Command` 계약, `package:provider` 권장, 계층 사이의 `==` filtering, 모든 버전과 SDK 하한은 표에 적은 Flutter, Riverpod, bloc, `shared_preferences`, pub 문서를 재진술한 것입니다. DTO와 mapper 경계, domain `Command` 충돌은 유지되는 실무 아키텍처 문서에서 가져왔고 Flutter 요구 사항이 아닙니다. 상태 소유권 표와 소유자별 문장, 신뢰할 수 없는 입력 목록, HTTP client 하나 규칙, "처리되지 않은 `Error`는 결함" 규칙은 그 문서에서 이끌어 낸 Hypercore 관례와 Safety 규칙입니다. deep link나 push payload를 쓰기 전에 검증해야 한다고 밝힌 공식 문서는 없고, 단일 호출에 mapper class를 요구하는 문서도 없습니다. Package 버전은 설명문이 아니라 pub metadata에서 읽었고 2026-11-04 기준입니다.
