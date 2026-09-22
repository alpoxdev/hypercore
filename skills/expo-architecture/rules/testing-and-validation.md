# Testing and Validation

## Risk depth

Use `standard` depth for new architecture or material refactors; `thorough` when native modules, permissions, auth/secrets, offline data, EAS config, or platform divergence changes. Pair final-output checks with trajectory checks for installs, native generation, credentials, and publication gates.

## Check order

1. Run repository-defined format/lint/typecheck/tests from actual manifests.
2. Run focused unit/component tests for changed feature and boundary modules.
3. Run Expo diagnostics appropriate to the installed SDK (commonly `npx expo-doctor`) and inspect failures rather than suppressing them.
4. For app-config/plugin changes, inspect resolved config (`npx expo config`) and native outputs/diffs when authorized.
5. For routing changes, exercise initial route, auth redirect, dynamic/deep-link params, back behavior, and not-found behavior.
6. For native/platform changes, verify Android and iOS independently using the project's documented development-build/build path.

Do not invent scripts. If a native check cannot run because the host, credentials, simulator/device, package install, or authorization is unavailable, state the exact gap and use the strongest non-equivalent static check without claiming platform success.

## Required scenarios

- Happy path on the requested platforms.
- Invalid/missing runtime data and configuration.
- API timeout/offline/auth expiration where touched.
- Permission granted, denied, blocked, and fresh-install behavior where touched.
- Secure storage unavailable/corrupt/missing value where touched.
- Deep-link and malformed route params where touched.
- Platform-specific module absence or differing lifecycle.
- Regression around moved imports, aliases, route types, and persisted schema.

## Architecture readback

Confirm route thinness, feature ownership, dependency direction, no cycles, no secret leakage, intentional state ownership, platform seams, and no orphaned files. Review generated/native diffs separately from authored source.

## Completion record

Record:

```text
Claim -> Risk -> Evidence -> Verification -> Result -> Caveat
```

Include installed versions, commands actually run, Android/iOS coverage, skipped checks, and one decision: `ship`, `iterate`, `caveated ship`, or `block`. Repair only observed failures and stop after two passes; never weaken checks to pass.

## Sources

> Claims checked 2026-09-21. No external source was used in this file; the Expo-specific statements restate this package's own official snapshot, references/official/expo-react-native-2026-08-03.md.
