# Expo Architecture 규칙

finding을 분류하거나 규칙을 적용하기 전에 읽습니다. 이 파일은 규칙 분류, 권한 순서, blocking gate, migration 정책을 소유합니다.

## 규칙 분류

- **Official**: 설치 version에 적용되는 Expo/React Native 공식 문서 동작.
- **Safety**: secret, runtime input, permission, native effect, data loss를 위한 blocking local policy.
- **Hypercore convention**: 근거가 있는 project convention에 맞게 조정 가능한 scalable default.

우선순위는 user/project authority, 설치 project evidence, 적용 가능한 official behavior, safety policy, Hypercore convention입니다. Safety finding은 명시적 해결이 필요합니다.

## 목표 dependency direction

```text
src/app (route composition)
  -> src/widgets (optional cross-feature section)
    -> src/features/<domain> (product capability)
      -> src/entities/<entity> (optional shared domain concept)
        -> src/shared (domain-agnostic UI/infrastructure)
```

Dependency는 오른쪽/아래쪽으로 향하며 lower layer는 route, widget, feature screen을 import하지 않습니다. Feature-to-feature import보다 `app`/`widgets` composition을 선호합니다. Cross-module access는 의도적으로 작은 public API를 사용합니다.

## Blocking gate

다음 touched work는 block하거나 수정합니다.

1. Server credential/private key를 client code, `EXPO_PUBLIC_*`, app config output, log, unencrypted storage에 둠.
2. Deep-link param, persisted data, push payload, API response를 boundary runtime validation 없이 신뢰함.
3. 필요한 native config와 user-facing purpose text 없이 runtime permission을 요청함.
4. 명시적 권한 없이 destructive native regeneration, EAS publication, signing, store action을 실행함.
5. 근거 없이 설치 Expo SDK/New Architecture와 호환되지 않는 native dependency를 도입함.
6. route/feature/shared dependency cycle 또는 unsafe universal module에서 platform-only module import를 만듦.
7. native 동작이 바뀌었는데 web/Expo Go만 시험하고 Android/iOS 지원을 주장함.

## 확장 가능한 기본 구조

```text
src/
  app/                  # Expo Router route graph only
  widgets/              # optional cross-feature screen section
  features/<domain>/    # feature-owned UI, application logic, data, state
  entities/<entity>/    # optional cross-feature domain concept
  shared/
    api/                # transport, auth injection, error normalization
    config/             # validated public runtime/build config
    observability/      # logging, analytics, crash-reporting port
    storage/            # secure/non-secure adapter
    testing/            # shared test harness
    theme/              # token/theme composition
    ui/                 # reusable presentation primitive
    lib/                # focused framework-independent utility
  server/               # optional Expo Router API-route support
  generated/            # generated code; hand-edit 금지
assets/                 # Expo static asset
app.config.ts           # root native/build config
```

실제 code ownership이 있을 때만 folder를 추가합니다. 작은 앱은 `app`, `features`, `shared`로 시작할 수 있으며 빈 architecture theater를 만들지 않습니다.

## Migration policy

Vertical slice로 이동합니다. route/feature 하나를 옮기고 import/test를 갱신하고 check를 실행한 뒤 계속합니다. Alias, generated route type, native config, test, ownership이 불명확하면 repo-wide move를 피합니다. 요청이 없으면 public behavior를 보존합니다.

## 완료 gate

Critical Official/Safety finding이 모두 통과해야 합니다. Convention 차이는 기존 project evidence로 명시적으로 정당화한 경우에만 ship할 수 있습니다. `rules/testing-and-validation.ko.md`를 실행하고 platform coverage와 생략한 native check를 함께 보고합니다.
