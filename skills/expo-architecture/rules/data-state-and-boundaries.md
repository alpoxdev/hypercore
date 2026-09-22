# Data, State, and Boundaries

## Separate state by owner

- **Server state**: remote cache, request status, invalidation, retries. Keep it in a query/data layer; do not mirror it wholesale into global client state.
- **Feature/UI state**: transient interaction state owned by the smallest screen/feature that coordinates it.
- **Form state**: input, validation, dirty/submission lifecycle local to the form workflow.
- **Persisted device state**: a deliberate storage schema with versioning/migration and failure handling.
- **Session secrets**: minimal values behind a secure-storage adapter, never a generic persistence store.

Choose libraries from installed project evidence and requirements; this skill does not mandate TanStack Query, Zustand, Redux, or a form/schema library.

## Runtime boundaries

TypeScript types do not validate runtime data. Validate API responses, deep links, push payloads, persisted records, environment values, and native-module results at their entry boundary. Convert transport DTOs to domain models when semantics differ. Normalize network/auth/domain errors before presentation.

Feature application code depends on ports such as `AuthRepository` or a narrow API module, not directly on screen globals. Infrastructure implements those ports. Avoid speculative repository layers for trivial calls; add abstraction where substitution, testing, mapping, caching, or platform divergence is real.

## API and offline behavior

Centralize base URL, headers, auth refresh, cancellation, timeout, and error normalization. Never log tokens or sensitive payloads. Define retry only for safe/idempotent operations and handle app background/network transitions intentionally.

If offline persistence is required, define source of truth, conflict policy, queue idempotency, schema migration, encryption needs, and recovery. Do not claim offline-first behavior from caching alone.

## Configuration

Read public environment variables through one validated config module. `EXPO_PUBLIC_*` is bundled client-visible data. Server secrets and signing credentials must remain outside the app bundle. Fail early for required config in the appropriate build/runtime path without leaking values.

## Sources

> Claims checked 2026-09-21. No external source was used in this file; the Expo-specific statements restate this package's own official snapshot, references/official/expo-react-native-2026-08-03.md.
