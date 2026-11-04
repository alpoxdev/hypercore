# Project Structure

폴더, 모듈 소유권, import, 마이그레이션 순서를 고르거나 바꿀 때 읽습니다. 이 파일은 규모별 프로필, 계층 경계, import 방향, 워크스페이스 배치를 소유합니다.

## 1. 근거로 구조 선택

앱 크기와 feature 수, 팀 경계, 진입점과 flavor, 라우팅 루트, `analysis_options.yaml`, 워크스페이스 배치, 생성 파일, `ios/`/`android/` 소유, 테스트, 현재 import를 조사합니다. 이 규칙에 맞추려고 일관된 기존 구조를 교체하지 않습니다.

명확한 소유권을 지키는 가장 작은 프로필을 씁니다.

| 프로필 | 사용 시점 | 시작 구조 |
|---|---|---|
| Small | 앱 하나, 팀 하나, 독립 feature가 세 개 미만 | 공식 하이브리드 트리: `lib/ui/`, `lib/data/`, `lib/domain/`, `lib/routing/`, `lib/config/`, `lib/utils/`에 `test/`, `testing/` |
| Growing | 데이터 흐름이 다른 제품 feature가 여럿이거나 기여자가 여럿 | `lib/features/<domain>/{data,domain,presentation}`에 `lib/shared/` |
| Multi-team | 앱이 여럿이거나 feature를 따로 배포하거나 경계를 빌드 실패로 강제해야 함 | pub 워크스페이스 패키지 `{feature}_domain`, `{feature}_data`, `{feature}_presentation`과 공유 패키지 |

Small과 Growing은 공식 네 구성 요소(View, ViewModel, Repository, Service)로 짜 맞춘 관례입니다. Multi-team만 잘못된 import를 컴파일 오류로 만듭니다. VGV의 판단 기준도 같은 방향입니다. feature가 세 개 미만인 단일 앱은 계층형 트리가 더 단순합니다. 폴더는 정돈해 보일 때가 아니라 별도 소유자나 의존 규칙이 생겼을 때 승격합니다. 빈 디렉터리와 파일 하나짜리 추상 계층은 확장성이 아닙니다.

## 2. 권장 구조

아래 세 트리는 도착지 지도이고, 모든 디렉터리를 만들라는 요구가 아닙니다. 보통 앱은 실제 코드가 생길 때까지 `domain/`, `shared/`, 패키지 분리를 두지 않습니다.

### Small 앱: 공식 하이브리드 배치

`ui/`는 feature별로, `data/`와 `domain/`은 타입별로 나눕니다. repository와 service가 특정 feature 하나에 묶이지 않기 때문입니다. 공식 샘플이 쓰는 배치입니다.

```text
.
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── main_development.dart        # flavor를 쓰면 flavor마다 진입점 하나
│   ├── ui/
│   │   ├── core/                    # 공용 위젯, 테마, 지역화
│   │   │   ├── ui/                  # 기본 위젯. 최상위 "widgets/"를 두지 않음
│   │   │   ├── themes/
│   │   │   └── localization/
│   │   └── activities/              # feature마다 폴더 하나, 사용자가 하는 일로 이름 짓기
│   │       ├── view_models/
│   │       └── widgets/
│   ├── data/
│   │   ├── repositories/
│   │   │   └── activities/
│   │   │       ├── activities_repository.dart
│   │   │       ├── activities_repository_remote.dart
│   │   │       └── activities_repository_dev.dart
│   │   └── services/
│   │       ├── api/
│   │       │   ├── api_client.dart
│   │       │   └── model/           # 전송 DTO는 여기서 끝남
│   │       └── local/
│   ├── domain/
│   │   ├── models/
│   │   └── use_cases/               # 필요할 때만 추가
│   ├── routing/
│   │   ├── router.dart
│   │   └── routes.dart
│   ├── config/
│   │   ├── assets.dart
│   │   └── dependencies.dart        # provider 연결과 환경 선택
│   └── utils/                       # 여러 feature가 쓰는 순수 헬퍼
├── test/                            # lib/를 그대로 반영: data/, domain/, ui/, utils/
└── testing/                         # 배포하지 않는 패키지: 하네스, fake, mock
    ├── app.dart                     # 크기, 테마, delegate를 잡는 testApp() 래퍼
    ├── mocks.dart
    ├── fakes/
    │   ├── repositories/
    │   └── services/
    └── models/
```

feature 이름은 사용자가 보는 화면이 아니라 사용자가 하는 일에 맞춥니다. 화면 이름을 붙인 폴더는 모델과 repository를 다시 최상위 묶음으로 끌어당겨 트리를 불균형하게 만듭니다.

### Growing 앱: 계층을 품은 feature 우선 배치

feature가 많아지면 계층을 feature 안에 두어, feature 하나를 한 단위로 바꾸고 시험하고 지울 수 있게 합니다.

```text
.
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                 # 루트 위젯, 테마, 지역화 delegate
│   │   └── bootstrap.dart           # 연결: repository, 라우터, provider
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── data_sources/    # 원격, 로컬 접근
│   │   │   │   ├── dtos/            # 전송 모델, 절대 export하지 않음
│   │   │   │   ├── mappers/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/          # UI가 들고 다닐 수 있는 엔티티
│   │   │   │   ├── repositories/    # 추상 repository 계약
│   │   │   │   └── use_cases/
│   │   │   └── presentation/
│   │   │       ├── sign_in/
│   │   │       │   ├── sign_in_screen.dart
│   │   │       │   ├── sign_in_view_model.dart
│   │   │       │   └── widgets/
│   │   │       └── widgets/         # 이 feature 안에서만 쓰는 위젯
│   │   └── checkout/
│   ├── shared/
│   │   ├── ui/                      # feature 둘 이상이 쓰는 디자인 기본 요소
│   │   ├── network/                 # 클라이언트, 인터셉터, 오류 매핑
│   │   ├── storage/                 # 키-값 저장, 보안 저장 어댑터
│   │   ├── config/                  # 컴파일 타임과 런타임 설정
│   │   ├── utils/                   # 순수 헬퍼
│   │   └── testing/                 # 여러 feature가 쓰는 fake와 하네스
│   └── routing/
│       └── app_router.dart
├── test/                            # lib/를 그대로 반영
└── testing/                         # 선택: 공용 하네스 패키지
```

각 feature는 화면, 모델, repository 계약을 다시 export하는 공개 진입점 하나(`lib/features/auth/auth.dart`)를 둡니다. 나머지는 그 feature 안에 감춥니다.

### Multi-team 앱: pub 워크스페이스 패키지

경계를 컴파일러가 강제해야 할 때 feature를 계층 패키지로 쪼개고 `pubspec.yaml`에 의존 규칙을 적습니다.

```text
.
├── pubspec.yaml                     # 워크스페이스 루트: sdk ^3.6.0과 workspace 목록
├── analysis_options.yaml            # 공용 lint 집합과 plugin 목록 하나
├── pubspec.lock                     # 워크스페이스 전체의 lockfile 하나
├── apps/
│   └── shop_app/
│       ├── pubspec.yaml             # resolution: workspace
│       └── lib/
│           ├── main.dart
│           └── bootstrap.dart       # feature 모듈을 라우트와 DI에 연결
├── packages/
│   ├── auth_domain/                 # 엔티티, repository 계약, use-case
│   ├── auth_data/                   # auth_domain을 백엔드에 맞춰 구현
│   ├── auth_presentation/           # 화면, view model, 모듈 위젯
│   ├── checkout_domain/
│   ├── checkout_data/
│   ├── checkout_presentation/
│   ├── app_ui/                      # 어느 앱이든 그대로 쓰는 디자인 기본 요소
│   ├── core_network/
│   ├── core_storage/
│   └── shared_testing/              # fake와 하네스. 배포하지 않음
└── tool/                            # 선택 스크립트. melos.yaml로 대체 가능
```

두 변형은 정당하므로 특별 대우가 필요 없습니다. 표현 계층 패키지 없이 `auth_domain`과 `auth_data`만 두는 headless feature, 다른 feature의 domain을 조합하는 presentation 전용 feature입니다. 백엔드별 구현은 `auth_data` 안의 조건문이 아니라 별도 패키지(`auth_data_firebase`)로 만듭니다.

## 3. 계층 소유권

### `lib/ui/<feature>`와 `presentation/`

View는 상태의 불변 스냅샷을 그리고 사용자 의도를 위로 넘깁니다. ViewModel은 로딩 플래그, 필터 결과, 선택된 탭, 폼 제출 상태 같은 상태를 들고 있습니다. 관계는 view 하나에 view model 하나입니다. View에 허용되는 로직은 짧습니다. 조건부 표시, 애니메이션, 기기 정보에 따른 배치, 단순 내비게이션입니다. 나머지는 ViewModel이나 그 아래 계층으로 갑니다.

View는 데이터 계층에 닿지 않습니다. ViewModel은 생성자로 repository를 받을 수 있고 domain 계층이 있으면 use-case를 받을 수 있습니다. 이것은 문서화된 MVVM 연결 방식이며 위반이 아닙니다.

### `lib/data`와 `data/`

repository는 한 종류 데이터의 단일 진실 공급원이고 캐싱, 오류 매핑, 재시도, 갱신 정책을 소유합니다. service는 데이터 소스 하나(HTTP API, 데이터베이스, 플랫폼 채널)만 다루고 상태를 갖지 않으며, 데이터 소스마다 service 클래스가 하나입니다. repository는 서로를 알지 못합니다. 둘을 함께 써야 하면 use-case나 ViewModel에서 조합합니다. repository와 view model은 다대다 관계입니다.

전송 DTO, JSON 매핑, 데이터 소스는 여기에 두고 계층 경계를 넘기지 않습니다. 의미가 다르면 DTO를 domain 모델로 매핑합니다. API 모양을 위젯까지 넘기면 UI가 백엔드에 묶입니다.

### `lib/domain`과 `domain/`

domain 계층은 조건부입니다. 엔티티, 추상 repository 계약, use-case를 둡니다. 여러 view model이 같은 흐름을 수행하거나, ViewModel을 만들지 않고 시험해야 하는 로직이 있을 때 use-case를 추가합니다. 단순한 앱에서 repository를 바로 호출하며 계층을 건너뛰는 것이 문서상 기본값입니다.

### `lib/shared`와 공유 패키지

공유는 도메인과 무관하고 소유자가 둘 이상일 때만 성립합니다. 두 질문으로 확인합니다. 앱이 조합하는 비즈니스 feature면 feature로 두고, 그대로 공개해도 남이 수정 없이 쓸 수 있으면 공유로 둡니다. `PrimaryButton`은 공유이고 `LoginButton`은 아닙니다. HTTP 클라이언트는 공유이고 상품 API 클라이언트는 아닙니다. `formatCurrency()`는 공유이고 `calculateTax()`는 아닙니다.

공유 코드는 feature를 import하지 않습니다. `shared/` 안에서는 무관한 파일을 루트에 쌓지 말고 관심사(`network`, `storage`, `ui`, `config`)로 묶습니다.

### `lib/routing`, `lib/config`, `lib/utils`

라우팅은 라우터 생성과 라우트 표를 소유합니다. 라우트 빌더는 검증한 매개변수를 읽고 화면을 반환합니다. 설정은 에셋 경로, 환경 선택, 어떤 repository 구현이 도는지 정하는 provider 연결을 소유합니다. 유틸리티는 feature나 데이터를 import하지 않는 순수 함수를 담습니다.

이 셋은 두 번째 `shared/`가 되면 안 됩니다. feature 하나만 쓰는 헬퍼는 그 feature에 둡니다.

### `testing/`와 `test/`

`testing/`은 배포하지 않는 앱의 한 버전입니다. 표면 크기, 테마, 지역화 delegate, 기기 픽셀 비율, 라우터를 잡는 `testApp()` 래퍼와 repository와 service fake, 공용 mock을 둡니다. `test/`는 실제 테스트 파일을 두고 `lib/`(`data/`, `domain/`, `ui/`, `utils/`)를 그대로 반영합니다.

프로덕션 코드는 `testing/`을 import하지 않습니다. fake는 테스트 파일 둘 이상이 쓸 때만 여기에 둡니다. 한 곳에서만 쓰는 fake는 그 테스트 옆에 남깁니다.

### `ios/`와 `android/`

Flutter 프로젝트에서 이 둘은 도구가 다시 만드는 폴더가 아니라 직접 커밋하고 리뷰하는 소스 디렉터리입니다. 서명, entitlement, 권한, 빌드 설정에 영향을 주는 폴더 변경은 그것을 필요로 하는 Dart 변경과 같은 리뷰에 들어갑니다. 플랫폼별 설정 세부는 네이티브 플랫폼 규칙이 소유합니다.

## 4. 의존 규칙

```text
View -> ViewModel -> (use-case) -> Repository -> Service
feature presentation -> own domain -> shared
feature data -> own domain, other features' domain, shared
app -> every feature package, every shared package
```

계층은 이 방향으로만 import합니다. 같은 계층끼리의 import는 공개 진입점이 필요하고 순환을 만들면 안 됩니다.

- View는 위젯, 테마, 자기 ViewModel을 import합니다. `data/`는 import하지 않습니다.
- ViewModel은 자기 feature의 domain을 import합니다. domain 계층이 없으면 repository를 바로 import합니다.
- repository는 다른 repository를 import하지 않습니다.
- Growing 프로필에서 feature는 다른 feature의 공개 진입점을 거쳐 import하고, 가능하면 그 feature의 domain만 씁니다. 워크스페이스 프로필의 규칙은 더 엄격하고 기계적입니다. 어떤 presentation 패키지도 `_data` 패키지에 의존하지 않으며 자기 것도 예외가 아닙니다.
- 공유 패키지는 feature 패키지에 의존하지 않습니다.
- 앱 패키지에 의존하는 코드는 없습니다. feature는 공유 라이브러리에 의존하고, 앱은 feature에 의존합니다.

feature 사이 내비게이션은 import가 아니라 주입으로 처리합니다. feature는 모듈 위젯이나 생성자에서 타입이 있는 콜백을 노출하고 앱 계층이 그것을 라우트에 연결합니다. 화면 하나를 띄우려고 두 feature가 서로 의존하는 일이 없어집니다.

배럴은 좁게 유지합니다. 데이터 배럴은 repository와 데이터 소스를 export할 수 있지만 DTO와 매퍼는 절대 export하지 않습니다. 내부 파일은 자기 배럴을 거치지 않고 직접 import합니다.

## 5. 횡단 관심사 배치

| 관심사 | 권장 위치 | 피할 것 |
|---|---|---|
| 라우터 생성, 라우트 표 | `lib/routing/` 또는 앱 패키지 | 위젯마다 흩어진 라우트 문자열 |
| 의존성 연결, 환경 선택 | `lib/config/dependencies.dart`, 앱 bootstrap | 위젯 안의 service locator 조회 |
| HTTP 클라이언트, 인터셉터, 인증 헤더 | `shared/network` | feature마다 중복 재시도를 가진 클라이언트 하나씩 |
| DTO, JSON 매핑 | `data/dtos`, `data/mappers` | 위젯으로 넘어가거나 배럴에서 export되는 DTO |
| 엔티티, repository 계약 | `domain/models`, `domain/repositories` | 의미가 다를 때 API 모델을 domain 모델로 재사용 |
| 디자인 기본 요소 | `lib/ui/core/ui` 또는 `app_ui` 패키지 | 두 번째 소비자가 생기기 전의 feature 전용 카드 승격 |
| 테마, 지역화 | `lib/ui/core/themes`, `localization` | 화면마다 반복되는 테마 값 |
| 분석, 로깅 | 공유 코드의 타입 있는 포트, 소유자 근처의 호출 | feature 전반에 퍼진 벤더 SDK import |
| 저장 어댑터, 보안 값 | `shared/storage`, 비밀은 보안 저장 어댑터 뒤 | 비밀을 담는 환경설정 보관소 |
| 테스트 하네스, fake | `testing/` 패키지 | 테스트 파일마다 복사한 fake |
| 생성 코드(`*.g.dart`, `*.freezed.dart`) | 원본 파일 옆, 직접 수정 금지 | 생성 파일을 고치거나 복제 |
| 플랫폼 차이 | bootstrap에서 주입하는 capability나 policy 객체 | 위젯에 퍼진 `Platform.is*`, `kIsWeb` 검사 |

## 6. 모노레포와 워크스페이스 프로필

pub 워크스페이스는 Dart 3.6 이상이 필요합니다. 루트가 멤버를 선언하고 각 멤버가 참여를 선언하며, 해석은 프로젝트 전체에서 한 번만 일어납니다.

```yaml
name: shop_workspace              # root pubspec.yaml
environment:
  sdk: ^3.6.0
workspace:
  - apps/shop_app
  - packages/*
```

```yaml
name: auth_domain                 # packages/auth_domain/pubspec.yaml
environment:
  sdk: ^3.6.0
resolution: workspace
```

설계에 반영해야 할 결과입니다.

- 워크스페이스에 `pubspec.lock` 하나와 `.dart_tool/package_config.json` 하나가 존재합니다. 패키지별 lockfile은 버그이고 `pub get`이 남은 파일을 지웁니다.
- 루트와 멤버 사이에 선언되지 않은 `pubspec.yaml`이 있으면 `pub get`이 오류를 냅니다. 패키지를 선언한 glob 바로 아래에 두거나 목록에 직접 넣습니다.
- glob(`packages/*`)과 중첩 워크스페이스를 지원합니다. 워크스페이스 내부 의존은 로컬 소스에서 해석되지만 선언한 제약을 여전히 만족해야 하므로 공개 패키지에는 `path` 의존을 두지 않습니다.
- 패키지는 실제 경계에만 추출합니다. 그 경계의 예는 두 번째 앱, 독립 배포, 별도 소유자, 빌드 실패로 강제해야 하는 규칙입니다. 앱 하나만 import하는 패키지는 단계만 늘어난 폴더입니다.
- 패키지 경계를 먼저 쓰고 analyzer plugin을 다음에, 리뷰 관례를 마지막에 둡니다. 컴파일 오류가 어떤 lint보다 강합니다.
- 워크스페이스 해석과 스크립트 실행은 다른 문제입니다. melos(8.10.0)는 스크립트를 돌리고 패키지 버전을 올립니다. `tool/` Dart 프로그램이 의존성 없는 대안입니다. 둘 다 `resolution: workspace`를 대체하지 않습니다.
- 워크스페이스 안의 지연 로딩(deferred loading)은 지연 패키지가 즉시 도달 가능한 경로에도 있으면 조용히 실패하고, Android와 iOS에만 배포하는 앱에서는 얻는 것이 없습니다. 구조를 위해서 넣지 않습니다.

## 7. 이름과 설정

- 파일과 폴더는 snake_case를 쓰고 파일 이름은 선언하는 공개 클래스와 맞춥니다(`sign_in_view_model.dart`). 패키지는 `{feature}_{layer}`(`auth_domain`, `auth_data`, `auth_presentation`)를 쓰고 백엔드 접미사를 붙일 수 있습니다(`auth_data_firebase`).
- 패키지는 `lib/{feature}_{layer}.dart`에서 API를 노출하고 구현은 `lib/src/`에 둡니다. 다른 패키지는 공개 진입점으로 import하고 `src/`를 직접 import하지 않습니다.
- Dart에는 경로 별칭이 없습니다. `package:auth_domain/...` 패키지 import가 별칭 역할을 하고, 패키지 안에서는 상대 import도 괜찮습니다.
- `analysis_options.yaml`은 앱 루트에 하나, 워크스페이스에서는 루트에 공용 파일 하나를 둡니다. `flutter_lints` 6.0.0이나 `very_good_analysis` 11.0.0에서 시작하고, 후자는 SDK 3.13 이상을 요구합니다. 한 집합을 고르고 여러 집합의 include를 겹쳐 쓰지 않습니다.
- analyzer plugin은 `analysis_options.yaml`의 최상위 `plugins:`에 설정하고 IDE와 `dart analyze`, `flutter analyze`에서 실행됩니다. plugin이 주는 lint는 기본으로 꺼져 있으므로 원하는 것만 `diagnostics:`에서 켭니다. 한 건만 끌 때는 `// ignore: plugin_name/code`를 씁니다.
- `import_rules`(0.0.8)는 계층 구조와 feature 격리를 위한 현재의 의존 제약 plugin입니다. Riverpod의 `riverpod_lint`도 같은 방식으로 설치하므로 해당 라이브러리를 이미 쓰는 프로젝트라면 그 패키지의 설정 안내를 따릅니다.
- `custom_lint`(0.8.1, 2025-09-09 마지막 배포)는 stale 상태입니다. 생태계가 analyzer 14.x를 쓰는 동안 `analyzer ^8.0.0`에 고정되어 있으므로 새 프로젝트에 넣지 않습니다.
- `dart_code_metrics`는 중단(discontinued)되었습니다. 메트릭 규칙은 analyzer plugin이나 리뷰로 대체합니다.
- `dependency_validator`(5.1.0)는 빠졌거나, 덜 승격되었거나, 과하게 승격되었거나, 쓰지 않는 의존성을 잡습니다. 선택 사항이고 모든 패키지가 아니라 워크스페이스 루트에 둡니다.

## 8. 배치 결정

| 질문 | 둘 곳 |
|---|---|
| 라우트, 라우트 표 항목, 라우트 가드인가? | `lib/routing/` 또는 앱 패키지 |
| 화면이거나 그 화면만 쓰는 위젯인가? | feature의 `ui/<feature>/` 또는 `presentation/<screen>/` |
| 로딩, 필터, 제출 상태 같은 UI 상태인가? | 그 화면 옆의 ViewModel |
| 스크롤 위치처럼 위젯 하나의 일시 상태인가? | 그 위젯의 `State` |
| 엔티티, repository 계약, 공용 흐름인가? | 그 feature의 `domain/` |
| HTTP 호출, 데이터베이스 질의, 플랫폼 채널 래퍼인가? | `data/services/`, 데이터 소스마다 하나 |
| repository 구현이나 캐시 정책인가? | `data/repositories/` 또는 feature의 `data/` |
| 전송 모델이나 JSON 매핑인가? | `data/dtos/`, `data/mappers/`. export하지 않음 |
| feature 둘 이상이 쓰는 순수 헬퍼인가? | `lib/utils/` 또는 공유 유틸 패키지 |
| 테마 토큰, 기본 위젯, 번역인가? | `lib/ui/core/` 또는 `app_ui` 패키지 |
| fake, mock, 위젯 테스트 하네스인가? | `testing/` |
| 앱 둘이 수정 없이 써야 하는가? | 새 워크스페이스 패키지 |
| 서명, 권한, flavor, 빌드 설정인가? | `ios/`와 `android/` |

소유권이 계속 불명확하면 모듈을 유일한 호출자 옆에 둡니다. 이른 공유는 지역 중복보다 되돌리기 어렵습니다.

## 9. 마이그레이션과 검증

변경 하나에 feature 하나를 세로로 옮깁니다. 같은 변경에서 import, 배럴, `pubspec.yaml` 의존성, 테스트, fake, 라우트 연결, 의존성 주입을 갱신합니다. 절반만 옮긴 feature는 진실 공급원을 둘로 만듭니다.

리뷰를 통과하는 순서입니다.

1. 공개 진입점을 갖춘 도착 계층이나 패키지를 만듭니다.
2. 코드를 옮기고 import를 고칩니다.
3. 라우팅과 의존성 연결에 새 경로를 등록합니다.
4. 예전 import를 막는 경계 규칙을 추가하거나 강화합니다.
5. `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, 테스트 모음을 실행합니다.
6. 대체 코드와 호출자가 검증된 뒤에만 예전 파일을 지웁니다.

결과 확인 항목입니다.

- `flutter analyze`가 켠 plugin 진단을 포함해 아무것도 보고하지 않습니다.
- 일부러 금지 import를 넣었을 때 경계 검사가 실패합니다. 규칙이 빌드를 실패시키지 않으면 경계가 아니라 문서입니다.
- `dependency_validator`나 `dart pub deps`에 의도하지 않은 의존성이 없습니다. 특히 feature 사이에 없어야 합니다.
- 워크스페이스에 lockfile이 여전히 하나이고 루트에서 해석됩니다.
- 생성 파일은 직접 고치지 않고 build_runner로 다시 만듭니다. Dart macro는 2025년에 중단되었고 augmentations는 실험 단계이므로 코드 생성 경로는 build_runner입니다.

기존 앱이라면 소유권이나 의존 규칙이 이동을 정당화할 때까지 현재 모양을 유지하고, 폴더 배치와 동작을 같은 변경에서 바꾸지 않습니다. feature 하나를 옮기는 일은 되돌리기 쉽지만 앱 절반의 이름을 바꾸는 일은 그렇지 않습니다.

## Sources

> 확인 2026-11-04. 버전 숫자는 Flutter 3.47.9 stable과 Dart 3.13.7 기준입니다.

| 출처 | URL | 뒷받침하는 내용 | 확인일 |
|---|---|---|---|
| Flutter, Guide to app architecture | <https://docs.flutter.dev/app-architecture/guide> | 두 계층, 조건부 domain 계층, view와 repository의 관계 | 2026-11-04 |
| Flutter, Architecture recommendations | <https://docs.flutter.dev/app-architecture/recommendations> | 강도가 나뉜 권장안과 조건부 domain 계층 | 2026-11-04 |
| Flutter, Testing each layer case study | <https://docs.flutter.dev/app-architecture/case-study/testing> | fake, `testApp()` 하네스, `lib/`를 반영하는 테스트 트리 | 2026-11-04 |
| Flutter, Dependency injection case study | <https://docs.flutter.dev/app-architecture/case-study/dependency-injection> | 앱 계층의 provider 연결 | 2026-11-04 |
| Flutter samples, compass_app `lib/` 목록 | <https://api.github.com/repos/flutter/samples/contents/compass_app/app/lib> | `ui/`는 feature별, `data/`와 `domain/`은 타입별 | 2026-11-04 |
| Flutter samples, compass_app `testing/` 목록 | <https://api.github.com/repos/flutter/samples/contents/compass_app/app/testing> | 배포하지 않는 테스트 패키지 구성 | 2026-11-04 |
| VGV, Feature-First Clean Architecture | <https://verygood.ventures/blog/feature-first-clean-architecture> | 계층 패키지, 컴파일 타임 위반, feature 세 개 미만 판단 기준 | 2026-11-04 |
| VGV Engineering, FFCA project structure | <https://engineering.verygood.ventures/architecture/ffca/project_structure> | 의존 표, 공유와 feature 구분 질문, 패키지 이름, melos | 2026-11-04 |
| VGV Engineering, FFCA navigation | <https://engineering.verygood.ventures/architecture/ffca/navigation> | 앱이 주입하는 타입 있는 콜백으로 feature 간 이동 | 2026-11-04 |
| Dart, Pub workspaces | <https://dart.dev/tools/pub/workspaces> | SDK 3.6 하한, `workspace:`와 `resolution: workspace`, lockfile 하나, 남은 lock 삭제 | 2026-11-04 |
| Dart, Analyzer plugins | <https://dart.dev/tools/analyzer-plugins> | `plugins:` 절, diagnostics 활성화, CLI와 IDE 실행 | 2026-11-04 |
| pub.dev, `import_rules` | <https://pub.dev/api/packages/import_rules> | 0.0.8, analyzer plugin API 기반 의존 제약 plugin | 2026-11-04 |
| pub.dev, `custom_lint` (stale, 사용 금지) | <https://pub.dev/api/packages/custom_lint> | 0.8.1, 2025-09-09 배포, `analyzer ^8.0.0` 고정 | 2026-11-04 |
| pub.dev, `dart_code_metrics` (discontinued) | <https://pub.dev/api/packages/dart_code_metrics> | 중단 표시된 패키지 | 2026-11-04 |
| pub.dev, `flutter_lints` | <https://pub.dev/api/packages/flutter_lints> | 6.0.0 lint 집합 하한 | 2026-11-04 |
| pub.dev, `very_good_analysis` | <https://pub.dev/api/packages/very_good_analysis> | SDK 3.13을 요구하는 11.0.0 | 2026-11-04 |
| pub.dev, `dependency_validator` | <https://pub.dev/api/packages/dependency_validator> | 5.1.0, 미사용과 누락 의존성 검사 | 2026-11-04 |
| pub.dev, `melos` | <https://pub.dev/api/packages/melos> | 워크스페이스 스크립트와 버전 관리를 위한 8.10.0 | 2026-11-04 |
| Dart, An update on Dart macros | <https://dart.dev/blog/an-update-on-dart-macros-data-serialization> | macro 중단, 코드 생성 경로는 build_runner | 2026-11-04 |
| Flutter, JSON serialization | <https://docs.flutter.dev/data-and-backend/serialization/json> | 중대형 프로젝트의 코드 생성 권장 | 2026-11-04 |
