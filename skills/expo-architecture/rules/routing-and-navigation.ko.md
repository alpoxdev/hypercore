# Routing과 Navigation

## Official boundary

Expo Router 프로젝트에서 해당 route root를 쓰면 route file은 `src/app`에 있습니다. 기존/현재 프로젝트는 root `app`을 사용할 수 있습니다. `_layout.tsx`는 layout/navigation 관계를 정의하고 `(group)`은 URL segment 없이 조직하며 `[param]`은 dynamic segment, `+not-found.tsx`는 unmatched route를 처리합니다. 정확한 동작은 설치 Router version으로 확인합니다.

## Thin route

Route는 routing metadata 선언, route/search param 읽기와 검증, layout/navigation option 선택, feature screen composition을 담당할 수 있습니다. Reusable UI, network call, storage, state machine, business rule은 owning feature/shared layer로 옮깁니다.

```tsx
import { ProfileScreen } from '@/features/profile';

export default function ProfileRoute() {
  return <ProfileScreen />;
}
```

Route guard는 UI 숨김에만 의존하지 않습니다. Authentication/session readiness를 명시적으로 모델링하고 redirect loop를 피하며 initial render를 deterministic하게 유지합니다. Deep-link/route param은 domain logic에 도달하기 전에 검증합니다.

## Navigation contract

설치 Expo Router가 지원하고 generated type이 project에 통합될 때만 typed routes를 켭니다. Dynamic route는 typed href object를 선호합니다. Route name은 feature 전반에 string constant로 흩뿌리지 말고 routing code에 둡니다.

Route group은 arbitrary code ownership이 아니라 navigation/product flow를 나타냅니다. Shallow stack/tabs boundary로 같은 동작을 표현할 수 있으면 깊은 nested layout을 피합니다. Feature를 가로지르는 modal, tabs, auth, deep-link ownership을 문서화합니다.

## Platform과 web

Android back action, iOS gesture, web URL, modal, tab lifecycle이 동일하다고 가정하지 않습니다. 영향 navigation을 요청된 각 platform에서 시험합니다. Route 이동 시 URL/deep-link compatibility를 보존하거나 redirect/migration 동작을 명시합니다.

## Sources

> 자체 검토 확인 2026-09-21. 이 파일은 외부 출처를 직접 사용하지 않았고, Expo 관련 서술은 이 패키지 자체의 공식 snapshot(references/official/expo-react-native-2026-08-03.md)을 재진술한 것입니다.
