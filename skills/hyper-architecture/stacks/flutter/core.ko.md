`hyper-architecture`의 Flutter 스택 가이드입니다. `rules/stack-detection.ko.md`가 대상을 Flutter로 라우팅하면 이 파일을 읽고, 이 파일이 그 대상의 작업을 맡습니다.

- 범위: Flutter와 Dart로 확장 가능한 Android/iOS 앱 architecture를 생성하거나 검토하고 refactor할 때 사용합니다. project structure, routing과 deep link, feature boundary, data/state 소유권, native config와 platform seam, validation을 포함합니다. 순수 Dart CLI나 서버, 독립 package와 plugin 개발, React Native·Expo 앱, Flutter가 아닌 web 전용, 문서 요약에는 사용하지 않습니다.
- 실행 조건: Flutter 프로젝트 또는 Flutter 프로젝트 생성 요청이 필요하며, 최신 버전과 API 주장은 공식 Flutter·Dart·Android·Apple·pub.dev 문서와 로컬 `flutter --version`, `pubspec.yaml` 확인이 필요할 수 있습니다.

@architecture-rules.ko.md
@../../rules/flutter/project-structure.ko.md
@../../rules/flutter/routing-and-navigation.ko.md
@../../rules/flutter/data-state-and-boundaries.ko.md
@../../rules/flutter/native-platform-and-security.ko.md
@../../references/official/flutter/flutter-dart-2026-11-04.ko.md
@../../rules/flutter/testing-and-validation.ko.md

# Flutter Architecture

> 공식 framework 동작과 Hypercore convention을 구분하면서 Android/iOS용 Flutter + Dart architecture를 생성하고 강제합니다.

<output_language>

사용자-facing 산출물, 보고서, 계획, handoff note, validation note는 기본적으로 한국어로 작성합니다. code identifier, command, path, schema key, package/API 이름, 인용문은 필요한 원문 언어를 유지합니다.

</output_language>

<purpose>

- 공식 MVVM 계층, 라우터 설정 하나, 엄격한 analyzer 설정, 명시적 feature boundary를 중심으로 Flutter 앱을 bootstrap하거나 refactor합니다.
- view를 얇게 유지하고 화면 상태를 짝이 되는 view model에 두며, 성장해도 흐트러지지 않도록 data layer를 단방향 dependency 뒤에 둡니다.
- secret, permission, signing, native config, storage, Android/iOS 차이를 물려받은 가정이 아니라 명시적 gate로 보호합니다.
- 최신 공식 지침을 적용하기 전에 설치된 Flutter·Dart toolchain과 프로젝트 근거로 architecture를 검증하며, 상태 라이브러리는 강제하지 않습니다.

</purpose>

<routing_rule>

Android와 iOS를 1차 대상으로 하는 Flutter 앱의 architecture 설정, 구현, review, remediation에 사용합니다. web과 desktop은 프로젝트가 선언했을 때만 대상에 넣습니다.

순수 Dart CLI나 서버, 독립 package와 plugin 개발, React Native·Expo 앱, Flutter가 아닌 web 전용 프로젝트, architecture 영향이 없는 단일 화면 변경, deployment-only 작업, 문서 요약에는 사용하지 않습니다. Brownfield 앱에서는 사용자가 migration을 요청하거나 safety/correctness 문제로 변경이 필요한 경우가 아니면 작동 중인 프로젝트 관례를 보존합니다.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | 앱이 성장해도 view, view model, data, native, platform boundary를 이해할 수 있는 확장 가능하고 testable한 Flutter architecture를 만듭니다. |
| Trigger | 앱 구성, folder 구조, routing과 deep link, state/data 흐름, native config, platform 차이, test, architecture review가 포함된 Flutter/Dart 작업. |
| Scope | 손대는 Dart source, route table, feature/shared module, `pubspec.yaml`, analyzer 설정, test, architecture validation note. native directory 재생성, dependency 교체, signing, store 작업은 명시적 scope가 필요합니다. |
| Authority | user와 project 지시가 이 스킬보다 우선합니다. 설치된 toolchain과 프로젝트 설정이 프로젝트 동작을 결정합니다. API 사실은 공식 Flutter·Dart·package 문서가 정하고, Hypercore convention은 프로젝트가 채택하지 않는 한 권고입니다. |
| Evidence | 먼저 `pubspec.yaml`, `analysis_options.yaml`, `lib/` entry point, 라우터 설정, `ios/`와 `android/`, 기존 test, lockfile이나 pub workspace, `flutter --version`을 확인합니다. 버전 차이가 결정을 가르면 날짜가 있는 공식 reference를 봅니다. |
| Tools | capability 기반 inspect/read/search/edit/execute를 사용합니다. command와 path를 검증하고 network install, credential, signing, store 게시, 프로젝트 전체 generator, binary를 내려받아 실행하는 build hook을 gate합니다. |
| Loop | 제한된 verify-repair loop를 사용합니다. 관련 check를 실행하고 관찰된 실패만 고치며 두 번의 repair 뒤 멈춥니다. format check, analyzer, test, 그리고 변경에 관련된 safety gate를 모두 통과한 변경만 유지합니다. |
| Output | 프로젝트에 적용한 architecture 구현이나 review와, 결정·변경 file·check·출처/버전 caveat·residual risk를 담은 간결한 한국어 보고서. |
| Verification | 프로젝트가 정의한 command와 format check, `flutter analyze`, `flutter test`, 선언된 플랫폼별 integration 실행, artifact build를 손댄 surface에 맞게 실행하고, 바뀐 경우 native 설정과 route 동작을 확인합니다. |
| Stop condition | toolchain, 선언된 대상 플랫폼, 라우터, state 소유권을 확인하고 적용 가능한 critical gate 통과, 변경 검증, residual risk 기록 뒤 끝냅니다. 권한 부족, unsafe native 효과, 해결되지 않은 버전·package 불일치, 필수 검증 불가 시 block합니다. |

</instruction_contract>

<activation_examples>

Positive:
- "Flutter와 Dart로 Android/iOS 앱 architecture를 세팅해줘. 화면은 feature 단위로 나누고 라우팅이랑 상태 소유권 경계도 같이 잡아줘."
- "Refactor this Flutter app so go_router setup stays in one place and features stop importing each other's internals."
- "우리 Flutter 앱의 Android productFlavors랑 iOS scheme별 권한 설정을 아키텍처 관점에서 검토해줘."
- "Set up deep links in this Flutter app with go_router and a bottom-tab shell, and tell me what breaks on Android and iOS."

Negative:
- "Our React Native app uses Expo Router with file routes under app/. Rework the navigation and native config so it scales."
- "Design the package structure for a Dart command-line tool that talks to a REST API. No Flutter, no mobile targets."
- "우리가 쓰는 Flutter 위젯 패키지에서 카드 위젯 하나만 복사해서 문구만 바꾼 변형 위젯을 만들어줘. 앱 구조는 상관없어."
- "Flutter로 만들 화면인데 피그마 시안처럼 로그인 화면 목업만 그려줘. 코드는 나중에."

Boundary:
- "Flutter 앱을 Play 스토어랑 App Store에 올릴 준비를 해줘. 서명 설정이랑 target SDK가 요구사항에 맞는지만 확인해줘." build와 release 설정을 검토하고 signing material 생성과 upload 전에 멈춥니다.
- "Flutter 로그인 화면 버튼 문구 한 줄만 '계속하기'로 바꿔줘." 빠른 boundary check만 하고 architecture churn을 강제하지 않습니다.

</activation_examples>

<trigger_conditions>

요청에 Flutter 앱, `flutter`에 의존하는 `pubspec.yaml`, `lib/` 구조, `go_router` 같은 라우터, deep link, flavor, `ios/`나 `android/`의 native 설정, platform별 code, 앱 data와 state 배치가 나오고, 하는 일이 설정, 구현, review, remediation이면 활성화합니다.

이미 운영 중이거나 커지는 Flutter 프로젝트의 구조, routing, import, platform seam, validation 순서를 바꿔야 하거나, review 요청이 change set으로 끝나는 경우에도 활성화합니다.

요청보다 프로젝트 판정을 먼저 합니다. 로컬 파일이 Flutter 앱 의존이 없는 Dart 프로젝트를 보여 주고, 사용자가 Flutter 앱 생성을 요청하지도 않았다면 이 스킬로 routing하지 않습니다. 나머지 제외 대상은 `<routing_rule>`에 있습니다.

</trigger_conditions>

<skill_architecture>

| 구성 | 역할 | 읽는 조건 |
|---|---|---|
| `stacks/flutter/core.ko.md` | trigger, contract, workflow, gate, validation | 항상 |
| `stacks/flutter/architecture-rules.ko.md` | rule class, authority 순서, blocking gate, 기본 tree | finding을 분류하기 전 |
| `rules/flutter/project-structure.ko.md` | 규모별 profile, ownership, import, migration 순서, workspace 배치 | folder나 import, module 소유권을 바꿀 때 |
| `rules/flutter/routing-and-navigation.ko.md` | navigation model, 단일 router, guard, deep link, back 처리 | route나 link를 바꿀 때 |
| `rules/flutter/data-state-and-boundaries.ko.md` | state 소유권, repository, DTO, persistence, dependency injection | data 흐름이나 state를 바꿀 때 |
| `rules/flutter/native-platform-and-security.ko.md` | native directory, flavor, permission, secret, 신뢰, interop | native config나 platform code를 건드릴 때 |
| `rules/flutter/testing-and-validation.ko.md` | check 순서, testing floor, 필수 scenario, 완료 기록 | 완료를 주장하기 전 |
| `references/official/flutter/flutter-dart-2026-11-04.ko.md` | 날짜가 고정된 공식 버전·API·플랫폼 사실 | 현재 toolchain이나 API 주장이 변경을 가를 때 |

</skill_architecture>

<loop_policy>

change set마다 loop는 한 번만 돌립니다. check를 실행하고 실패를 읽고 실패한 것만 고친 뒤 다시 실행합니다. 한 round는 repair 한 번과 그 재실행이며, 두 round 뒤에 끝냅니다. 변경에 관련된 format, analyzer, test, native-config, safety gate를 모두 통과한 변경만 남기고, 통과하지 못하면 실패한 check를 밝히고 끝내며 검증됐다고 주장하지 않습니다. tree가 만족스러워질 때까지 구조를 고치는 loop도, 스스로 점수를 매기는 loop도 없습니다. 근거는 기록한 command 출력, build artifact, resolved config이고, 계획을 다시 읽는 것이 아닙니다.

</loop_policy>

<language_and_translation_default>

사용자에게 보이는 글은 기본적으로 한국어로 씁니다. 보고서, 결정, caveat, residual risk가 여기 해당합니다. code identifier, command, path, package/API 이름, 인용한 원문은 원래 형태를 유지합니다. 이 패키지는 영문/한글 쌍(`X.md` ↔ `X.ko.md`)으로 관리하므로 한 번에 한 언어판만 읽고, 규칙이 바뀌면 양쪽을 함께 고칩니다.

</language_and_translation_default>

<reference_routing>

- finding을 분류하거나 규칙을 적용하기 전에 `stacks/flutter/architecture-rules.ko.md`를 읽습니다.
- folder, import, module 소유권, 규모 profile, migration 순서를 바꿀 때 `rules/flutter/project-structure.ko.md`를 읽습니다.
- navigation model, route table, guard, redirect, deep link, back 처리를 바꿀 때 `rules/flutter/routing-and-navigation.ko.md`를 읽습니다.
- state 소유권, repository, DTO, serialization, persistence, dependency 연결을 바꿀 때 `rules/flutter/data-state-and-boundaries.ko.md`를 읽습니다.
- flavor, permission, secret, storage, HTTP 신뢰, native interop, build 설정, release 요구사항을 건드릴 때 `rules/flutter/native-platform-and-security.ko.md`를 읽습니다.
- 완료를 주장하기 전에 `rules/flutter/testing-and-validation.ko.md`를 읽습니다.
- 설치된 toolchain, package 버전, 공식 API 동작이 변경을 가를 때 `references/official/flutter/flutter-dart-2026-11-04.ko.md`를 읽고 `last_verified_at`을 `flutter --version`과 `environment` block에 맞춰 봅니다.

</reference_routing>

<support_file_read_order>

한 번에 한 언어판만, 다음 순서로 읽습니다. 경로는 이 스킬 directory 기준입니다.

1. rule class, authority 순서, blocking gate는 `stacks/flutter/architecture-rules.ko.md`에서 읽습니다.
2. 변경이 건드리는 topic의 rule file은 `<reference_routing>`으로 골라 읽습니다.
3. 현재 toolchain 동작이나 API lifecycle이 결정을 가를 때만 `references/official/flutter/flutter-dart-2026-11-04.ko.md`를 읽습니다.
4. 구현을 마치기 전에 `rules/flutter/testing-and-validation.ko.md`를 읽습니다.

</support_file_read_order>

<workflow>

| Phase | Task | Output |
|---|---|---|
| 0 | 로컬 파일에서 Flutter·Dart 버전(`flutter --version`과 `pubspec.yaml`의 `environment` block), 존재하는 플랫폼 folder(`android/`, `ios/`, 선택적 `web/`, `macos/`, `linux/`, `windows/`), flavor와 entry point, 사용 중인 상태 라이브러리, 라우터, Swift Package Manager와 CocoaPods 중 무엇인지, pub workspace인지 단일 package인지, `material_ui` 채택 여부, 프로젝트 command, 요청에 install·signing·store effect가 필요한지 확인 | Scope decision |
| 1 | feature, route table, shared module, state와 data 흐름, native config, test, dependency 방향 inventory | Architecture map |
| 2 | finding을 Official, Safety, Hypercore convention으로 분류 | Prioritized plan |
| 3 | target boundary와 최소 vertical slice 정의, 사용자 작업 보존 | Change set |
| 4 | 안전하고 reversible한 변경 구현 및 영향받는 callsite·test·설정 갱신 | Integrated architecture |
| 5 | 선언된 플랫폼마다 focused check와 프로젝트 단위 check 실행, resolved 동작 확인 | Verification evidence |
| 6 | 결정, 버전과 출처, 결과, residual risk를 한국어로 보고 | Handoff |

</workflow>

<required>

- 소유권이 분명한 가장 작은 구조 profile을 고릅니다. 작은 앱은 공식 hybrid tree, 커지는 앱은 feature 우선 folder를 쓰고, 앱이 둘 이상이거나 독립 배포·별도 소유자가 있거나 build 실패로 경계를 강제해야 할 때는 pub workspace package를 씁니다.
- view는 얇게 유지합니다. 화면 상태는 짝이 되는 view model에 두고, repository는 해당 data type의 단일 진실 공급원이며, service는 외부 source마다 하나씩 두고 상태를 갖지 않습니다.
- 라우터 설정은 하나로 두고, route builder는 parameter를 domain type으로 parse하는 얇은 형태로 유지하며, 새 code에 named route나 섞인 router를 두지 않습니다.
- 의존 방향은 View, ViewModel, 선택적 use-case, Repository, Service 순서로만 향하게 하고, repository끼리 의존하지 않으며 view가 data layer를 import하지 않습니다.
- widget-local, view model, repository, persisted, form state를 소유자와 lifecycle로 나누고, 프로젝트가 이미 쓰는 상태 라이브러리를 그대로 유지하며 무관한 작업 중에 교체하지 않습니다.
- `--dart-define`, `--dart-define-from-file`, `appFlavor`, asset, 모든 컴파일 상수를 앱 binary에 실려 나가는 공개 값으로 취급합니다.
- platform 차이는 capability나 adapter 뒤로 명시하고, 공용 code에서는 `defaultTargetPlatform`과 `kIsWeb`으로 판단합니다.
- `ios/`와 `android/`는 검토 대상 소유 source로 유지하고, 모든 runtime permission을 선언과 사용자에게 보이는 목적 문구에 맞춥니다.
- 버전을 추측하지 않고 설치된 toolchain과 각 package가 선언한 `flutter:`·`sdk:` 제약을 따릅니다.

</required>

<forbidden>

- 프로젝트 command, package, native capability, API contract, environment variable을 지어내기.
- 프로젝트 규모와 기존 관례를 확인하지 않은 채 만능 folder template 적용.
- 상태 라이브러리 강제, 작업 중 교체, 한 화면 안에서 두 state mechanism 운용.
- view가 repository, service, DTO, persistence adapter를 import하기, repository끼리 의존하기, cycle을 만드는 넓은 barrel 사용.
- source, asset, `--dart-define` 값, `appFlavor`, log, analytics, crash report, `shared_preferences`, 암호화되지 않은 file에 secret 저장.
- 명시적 승인 없는 dependency install·upgrade, 기존 프로젝트 위 `flutter create`, signing, store upload, publish.
- host unit test, widget test, web 실행만으로 Android나 iOS 지원을 주장하기.
- router redirect를 인가로 취급하거나 deep link, push, route `extra`, persisted, API 입력을 boundary 검증 없이 사용하기.
- 검증된 incremental slice가 없는 무제한 구조 변경.

</forbidden>

<validation>

- [ ] Flutter·Dart 버전, 선언된 대상 플랫폼, 라우터, 상태 라이브러리, native dependency 관리 방식을 확인했습니다.
- [ ] positive 3개, negative 2개, boundary 1개 이상의 trigger example이 유지됩니다.
- [ ] route builder가 얇고 라우터 설정이 하나이며, 어떤 feature도 routing 내부를 import하지 않습니다.
- [ ] dependency 방향과 feature/shared 소유권이 명확하고 cycle과 unsafe barrel이 없습니다.
- [ ] runtime input, 설정, persistence, permission, secure storage가 boundary와 safety 규칙을 따릅니다.
- [ ] 동작이나 설정이 다르면 Android와 iOS 변경을 각각 확인했습니다.
- [ ] 관련 format check, `flutter analyze`, unit·widget test, 플랫폼별 실행, artifact build를 실행했거나 불가 사유를 기록했습니다.
- [ ] 영문/한글 파일의 trigger, authority, workflow, safety, 완료 의미가 동등합니다.
- [ ] 최신 공식 주장은 날짜가 있는 reference를 인용하며, 기준값은 `references/official/flutter/flutter-dart-2026-11-04.md`의 Flutter 3.47.9 / Dart 3.13.7이고 source date가 미래가 아닙니다.
- [ ] 완료 기록에 `Claim -> Risk -> Evidence -> Verification -> Result -> Caveat`와 ship, iterate, caveated ship, block 가운데 하나의 결정을 담았습니다.

</validation>
