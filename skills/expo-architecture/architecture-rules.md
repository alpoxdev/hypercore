# Expo Architecture Rules

Read before classifying any finding or enforcing a rule. This file owns the rule classes, the authority order, the blocking gates, and the migration policy.

## Rule classes

- **Official**: behavior documented by Expo or React Native and applicable to the installed versions.
- **Safety**: blocking local policy for secrets, runtime input, permissions, native effects, and data loss.
- **Hypercore convention**: scalable default that may be adapted to evidenced project conventions.

Order: user/project authority, installed project evidence, applicable official behavior, safety policy, then Hypercore convention. Safety findings still require an explicit resolution.

## Target dependency direction

```text
src/app (route composition)
  -> src/widgets (optional cross-feature sections)
    -> src/features/<domain> (product capabilities)
      -> src/entities/<entity> (optional shared domain concepts)
        -> src/shared (domain-agnostic UI and infrastructure)
```

Dependencies point right/downward; lower layers never import routes, widgets, or feature screens. Prefer composition in `app`/`widgets` over feature-to-feature imports. Cross-module access uses a deliberately small public API.

## Blocking gates

Block or fix touched work that:

1. Places server credentials or private keys in client code, `EXPO_PUBLIC_*`, app config output, logs, or unencrypted storage.
2. Trusts deep-link params, persisted data, push payloads, or API responses without runtime validation at the boundary.
3. Requests a permission at runtime without corresponding native configuration and user-facing purpose text where required.
4. Runs destructive native regeneration, EAS publication, signing, or store actions without explicit authority.
5. Introduces native dependencies incompatible with the installed Expo SDK/New Architecture without evidence.
6. Creates route/feature/shared dependency cycles or imports platform-only modules from an unsafe universal module.
7. Claims Android/iOS support after testing only web or Expo Go when native behavior changed.

## Scalable default

```text
src/
  app/                  # Expo Router route graph only
  widgets/              # optional cross-feature screen sections
  features/<domain>/    # feature-owned UI, application logic, data, state
  entities/<entity>/    # optional cross-feature domain concepts
  shared/
    api/                # transport, auth injection, error normalization
    config/             # validated public runtime/build config
    observability/      # logging, analytics, crash-reporting ports
    storage/            # secure/non-secure adapters
    testing/            # shared test harness
    theme/              # tokens and theme composition
    ui/                 # reusable presentation primitives
    lib/                # focused framework-independent utilities
  server/               # optional Expo Router API-route support
  generated/            # generated code; never hand-edit
assets/                 # Expo static assets
app.config.ts           # root native/build config
```

Add folders only when they own real code. A small app may begin with `app`, `features`, and `shared`; do not create empty architecture theater.

## Migration policy

Use vertical slices. Move one route/feature, update imports/tests, run checks, then continue. Avoid repo-wide moves when aliases, generated route types, native config, tests, or ownership remain uncertain. Preserve public behavior unless the request says otherwise.

## Completion gate

All critical Official and Safety findings must pass. Convention differences may ship only when explicitly justified by existing project evidence. Run `rules/testing-and-validation.md` and report both platform coverage and skipped native checks.
