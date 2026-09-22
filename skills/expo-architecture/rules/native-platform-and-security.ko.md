# Native Platform과 Security

## Project mode

Native project가 CNG/prebuild로 생성되는지, 의도적으로 commit/관리되는지, 없는지 식별합니다. Config plugin/app config는 project ownership이 지정한 범위에서만 source of truth입니다. 명시적 승인과 검토된 diff/backup 전략 없이 clean prebuild로 manual native change를 덮어쓰지 않습니다.

## App configuration

기존 workspace rule이 다르지 않으면 `app.config.ts`, `app.json`, `eas.json`, Metro, TypeScript config는 app root에 둡니다. `npx expo config`로 resolved public config를 검사하되 secret evaluation path를 출력하지 않습니다. Config-plugin/permission 변경은 일반적으로 JavaScript reload/update만이 아니라 새 native build가 필요합니다.

## Permission

Permission을 build-time native declaration/purpose text와 runtime request/denial handling의 두 부분 contract로 취급합니다. User intent 시점에 요청하고 목적을 설명하며 denied/blocked state를 지원하고 fresh-install flow를 시험합니다. Android permission과 iOS usage description을 최소화합니다. Expo Go는 standalone permission config가 맞다는 증거가 아닙니다.

## Storage/secret

작은 sensitive value는 adapter를 통해 `expo-secure-store` 또는 근거가 있는 equivalent에 저장합니다. Authentication 불가, device change, native error, data loss를 처리합니다. Non-secure storage는 non-sensitive data에만 사용하고 serialization/version migration을 정의합니다. `EXPO_PUBLIC_*`, `extra`, source, log, analytics, error report에 secret을 두지 않습니다.

## Platform seam

명시적 adapter가 있는 shared behavior를 선호합니다. 구현이 실제로 다를 때 `.ios.ts(x)`/`.android.ts(x)`를 사용하고 작은 presentation 차이에는 `Platform.select`를 사용하되 큰 business branch를 숨기지 않습니다. Native-module call은 typed module 뒤에 두어 test와 unsupported platform 동작을 명시합니다.

## Dependency/native effect

설치 Expo SDK compatibility path를 사용하고 해당 React Native architecture에 대한 package 지원을 확인합니다. Package install, pod/Gradle 변경, `prebuild`, EAS credential/build/update/submit, signing, push credential, store action은 gated side effect입니다. 필요한 capability/authorization이 없으면 실행했다고 주장하지 말고 blocked check/change를 정확히 제공합니다.

## Sources

> 자체 검토 확인 2026-09-21. 이 파일은 외부 출처를 직접 사용하지 않았고, Expo 관련 서술은 이 패키지 자체의 공식 snapshot(references/official/expo-react-native-2026-08-03.md)을 재진술한 것입니다.
