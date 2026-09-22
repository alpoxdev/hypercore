# Testing과 Validation

## Risk depth

새 architecture/material refactor는 `standard`, native module, permission, auth/secret, offline data, EAS config, platform divergence 변경은 `thorough`를 사용합니다. Install, native generation, credential, publication gate에는 final-output check와 trajectory check를 함께 적용합니다.

## Check 순서

1. 실제 manifest의 repository-defined format/lint/typecheck/test를 실행합니다.
2. 변경 feature/boundary module의 focused unit/component test를 실행합니다.
3. 설치 SDK에 맞는 Expo diagnostic(일반적으로 `npx expo-doctor`)을 실행하고 실패를 숨기지 않고 조사합니다.
4. App-config/plugin 변경은 resolved config(`npx expo config`)와 승인된 경우 native output/diff를 검사합니다.
5. Routing 변경은 initial route, auth redirect, dynamic/deep-link param, back, not-found 동작을 실행합니다.
6. Native/platform 변경은 project의 documented development-build/build path로 Android/iOS를 각각 검증합니다.

Command를 지어내지 않습니다. Host, credential, simulator/device, package install, authorization 부족으로 native check를 못 하면 정확한 gap과 가장 강한 non-equivalent static check를 기록하고 platform 성공을 주장하지 않습니다.

## 필수 scenario

- 요청 platform의 happy path.
- Invalid/missing runtime data/config.
- 영향 범위의 API timeout/offline/auth expiration.
- 영향 범위의 permission granted/denied/blocked/fresh-install.
- 영향 범위의 secure storage unavailable/corrupt/missing value.
- 영향 범위의 deep-link/malformed route param.
- Platform-specific module 부재 또는 lifecycle 차이.
- 이동한 import, alias, route type, persisted schema regression.

## Architecture readback

Route thinness, feature ownership, dependency direction, cycle 부재, secret leak 부재, intentional state ownership, platform seam, orphan file 부재를 확인합니다. Generated/native diff는 authored source와 분리해 review합니다.

## Completion record

다음을 기록합니다.

```text
Claim -> Risk -> Evidence -> Verification -> Result -> Caveat
```

설치 version, 실제 실행 command, Android/iOS coverage, skipped check, `ship`/`iterate`/`caveated ship`/`block` 중 하나를 포함합니다. 관찰된 실패만 수정하고 2회 pass 후 멈추며 통과를 위해 check를 약화하지 않습니다.

## Sources

> 자체 검토 확인 2026-09-21. 이 파일은 외부 출처를 직접 사용하지 않았고, Expo 관련 서술은 이 패키지 자체의 공식 snapshot(references/official/expo-react-native-2026-08-03.md)을 재진술한 것입니다.
