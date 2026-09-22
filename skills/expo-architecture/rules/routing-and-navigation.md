# Routing and Navigation

## Official boundary

For Expo Router projects, route files live in `src/app` when that route root is used; a root `app` may exist in older/current projects. `_layout.tsx` defines layout/navigation relationships, `(group)` organizes without adding a URL segment, `[param]` represents a dynamic segment, and `+not-found.tsx` handles unmatched routes. Confirm exact behavior against the installed Router version.

## Thin routes

A route may declare routing metadata, read and validate route/search params, choose layout/navigation options, and compose a feature screen. Move reusable UI, network calls, storage, state machines, and business rules into the owning feature/shared layer.

```tsx
import { ProfileScreen } from '@/features/profile';

export default function ProfileRoute() {
  return <ProfileScreen />;
}
```

Route guards must not rely only on hiding UI. Model authentication/session readiness explicitly, avoid redirect loops, and keep the initial render deterministic. Validate deep-link and route params before they reach domain logic.

## Navigation contracts

Enable typed routes only when supported by the installed Expo Router and generated types are integrated into the project. Prefer typed href objects for dynamic routes. Keep route names in routing code rather than scattering string constants through features.

Route groups represent navigation/product flow, not arbitrary code ownership. Avoid deeply nested layouts when a shallow stack/tabs boundary communicates the same behavior. Document modal, tabs, auth, and deep-link ownership when they cross features.

## Platform and web

Do not assume an Android back action, iOS gesture, web URL, modal, or tab lifecycle is identical. Test affected navigation behavior on each requested platform. Preserve URL/deep-link compatibility during route moves or explicitly define redirects/migration behavior.

## Sources

> Claims checked 2026-09-21. No external source was used in this file; the Expo-specific statements restate this package's own official snapshot, references/official/expo-react-native-2026-08-03.md.
