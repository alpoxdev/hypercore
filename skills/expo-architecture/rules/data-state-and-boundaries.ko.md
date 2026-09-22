# Data, State, Boundary

## Owner별 state 분리

- **Server state**: remote cache, request status, invalidation, retry. Query/data layer에 두고 전체를 global client state에 복제하지 않습니다.
- **Feature/UI state**: coordination하는 가장 작은 screen/feature가 소유하는 transient interaction state.
- **Form state**: form workflow 내부 input, validation, dirty/submission lifecycle.
- **Persisted device state**: versioning/migration/failure handling이 있는 의도적인 storage schema.
- **Session secret**: generic persistence store가 아니라 secure-storage adapter 뒤의 최소 값.

설치 project evidence와 requirement로 library를 선택합니다. 이 스킬은 TanStack Query, Zustand, Redux, form/schema library를 강제하지 않습니다.

## Runtime boundary

TypeScript type은 runtime data를 검증하지 않습니다. API response, deep link, push payload, persisted record, environment value, native-module result를 진입 boundary에서 검증합니다. 의미가 다르면 transport DTO를 domain model로 변환합니다. Network/auth/domain error를 presentation 전에 normalize합니다.

Feature application code는 screen global이 아니라 `AuthRepository` 같은 port나 narrow API module에 의존합니다. Infrastructure가 port를 구현합니다. Trivial call에 speculative repository layer를 만들지 말고 substitution, testing, mapping, caching, platform divergence가 실제일 때 abstraction을 추가합니다.

## API/offline 동작

Base URL, header, auth refresh, cancellation, timeout, error normalization을 중앙화합니다. Token/sensitive payload를 log하지 않습니다. Retry는 safe/idempotent operation에만 정의하고 app background/network transition을 의도적으로 처리합니다.

Offline persistence가 필요하면 source of truth, conflict policy, queue idempotency, schema migration, encryption, recovery를 정의합니다. Caching만으로 offline-first라고 주장하지 않습니다.

## Configuration

Public environment variable은 하나의 validated config module에서 읽습니다. `EXPO_PUBLIC_*`는 bundle에 포함되는 client-visible data입니다. Server secret/signing credential은 app bundle 밖에 둡니다. 값을 노출하지 않으면서 적절한 build/runtime path에서 required config 누락을 조기에 실패시킵니다.

## Sources

> 자체 검토 확인 2026-09-21. 이 파일은 외부 출처를 직접 사용하지 않았고, Expo 관련 서술은 이 패키지 자체의 공식 snapshot(references/official/expo-react-native-2026-08-03.md)을 재진술한 것입니다.
