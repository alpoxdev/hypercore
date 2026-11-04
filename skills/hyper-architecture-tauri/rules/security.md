# Tauri v2 Security Boundary

> Read before adding or approving a Tauri capability, plugin permission, custom command, filesystem/network scope, remote content, updater, credential flow, or release configuration.

## Evidence, authority, and classification

**Official fact.** Tauri v2 uses capabilities to restrict which windows/webviews receive permissions; permissions can allow or deny commands; scopes constrain permission access. See the [Tauri v2 evidence ledger](../references/official/tauri-v2-2026-07-30.md), [Capabilities](https://v2.tauri.app/security/capabilities/), [Permissions](https://v2.tauri.app/security/permissions/), and [Scopes](https://v2.tauri.app/security/scope/). These official pages were accessed on 2026-07-30 as evidence only and can change; recheck the ledger and the current official documentation before version-sensitive configuration changes.

**Safety policy.** Treat the WebView, all rendered JavaScript, navigation/deep-link input, IPC arguments, event payloads, local content, and remote responses as inputs that can be malformed or hostile. The frontend is not the authorization authority and browser-origin expectations alone are not a native security boundary.

**Project convention.** Security decisions are explicit, reviewable files in `src-tauri/capabilities/` and (for app commands) `src-tauri/permissions/`, plus narrowly scoped plugin configuration. Never rely on defaults, a broad plugin permission, or an undocumented inherited capability for privileged behavior.

No capability, credential, update publication, release, deployment, key rotation, destructive operation, or production write is authorized by this rule. Those actions need explicit user authority in addition to passing these gates.

---

## Command-side trust boundary

A capability controls whether a WebView can request an operation; it does not make the request safe. Every custom Rust command must independently:

1. Deserialize into a bounded, typed request DTO.
2. Validate type, required fields, size, format, enumeration values, path/URL canonicalization, and operation-specific limits.
3. Establish the relevant local/session/user identity from trusted native state or an authenticated remote service—not from a frontend-supplied role, path, feature flag, or `isAdmin` field.
4. Authorize the operation and resource for that identity.
5. Execute through a least-privileged service and return a safe structured result/error.
6. Audit or log only approved metadata; never log secrets or unrestricted user content.

**Safety policy:** frontend validation improves UX only. It cannot replace command-side validation, authorization, resource ownership checks, rate/size limits, or safe error mapping. A hidden menu item, disabled button, or route guard is not an authorization control.

**Convention:** commands accept explicit DTOs rather than filesystem paths, shell fragments, arbitrary URLs, raw SQL, serialized closures, or plugin option bags whenever a narrower domain input exists. Resolve IDs to trusted records/services on the native side. See [tauri-ipc.md](tauri-ipc.md) for DTO and error requirements.

---

## Custom command manifest and least privilege

**Official fact.** Commands registered only through `invoke_handler` are available to application windows/webviews by default. To let capabilities restrict custom commands, declare the application commands in Tauri's `AppManifest`, define app-command permissions, and grant them to targeted window/webview labels. See [Application manifest](https://v2.tauri.app/security/capabilities/#application-manifest), [App Permissions](https://v2.tauri.app/security/permissions/), and [Runtime Authority](https://v2.tauri.app/security/runtime-authority/). Exact `build.rs`, generated schema, and permission syntax are version-sensitive; use the installed Tauri version's schema and official example.

**Project convention:** every custom command follows one reviewable chain: `AppManifest` declaration in `build.rs` -> named permission in `src-tauri/permissions/` -> least-privilege capability for intended labels -> Rust validation/authorization. Keep plugin permissions separate from app-command permissions.

```toml
# src-tauri/permissions/settings.toml
[[permission]]
identifier = "settings:allow-read"
description = "Allows reading non-secret settings."
commands.allow = ["settings_read"]

[[permission]]
identifier = "settings:allow-update"
description = "Allows updating non-secret settings."
commands.allow = ["settings_update"]
```

```json
// src-tauri/capabilities/main.json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "main-settings",
  "windows": ["main"],
  "permissions": ["settings:allow-read", "settings:allow-update"]
}
```

The snippets show the intended review shape, not a copy-paste substitute for the generated schema or an approval to grant those operations.

- **Safety policy:** give each capability the smallest set of command/plugin permissions needed by one label/window role. A settings window, main window, authentication window, and untrusted/remote-content window must not inherit one broad capability merely for convenience.
- **Safety policy:** use explicit allow permissions and narrowly justified denies. Do not grant a plugin's `default` or all commands when a single operation suffices. Remove obsolete grants when the command is removed.
- **Convention:** keep a human-readable reason next to every non-obvious permission, scope entry, remote origin, and label match. Review capability diffs as security-sensitive changes.
- **Convention:** test both an allowed call from the intended label and a denied call from every other relevant label. A missing denial test blocks security-sensitive changes.

---

## Plugin permissions and scopes

**Official fact.** Tauri plugin permissions and scopes are part of the v2 access-control model. Scopes restrict the data or resources a permission can reach; their syntax and availability are plugin-specific. See [Permissions](https://v2.tauri.app/security/permissions/) and [Scopes](https://v2.tauri.app/security/scope/) (accessed 2026-07-30; see the evidence caveat above).

- **Safety policy:** grant filesystem, shell, HTTP, opener, clipboard, notification, process, deep-link, and asset permissions only after identifying the exact command, resource, origin, and label that need them.
- **Safety policy:** scope filesystem access to the smallest required directories/files and allowed operations. Canonicalize and validate paths after resolution; reject traversal, symlink escape where relevant, and user-controlled unrestricted roots.
- **Safety policy:** scope HTTP/remote access to explicit schemes, hosts, paths, methods, and request shapes where the plugin supports them. Never turn a user-provided URL into general network authority.
- **Safety policy:** do not expose a generic shell/process launcher. Model approved operations as fixed native commands with fixed executables/arguments and validated domain input.
- **Convention:** use the plugin's current generated schema and official docs to express its scope. Do not invent configuration keys or assume scope behavior is shared across plugins.

---

## CSP, assets, and remote content

**Official fact.** Tauri documents CSP configuration and the asset protocol as security-relevant features. See [Content Security Policy](https://v2.tauri.app/security/csp/) and [Asset Protocol](https://v2.tauri.app/security/asset-protocol/) (accessed 2026-07-30; see the evidence caveat above).

**Safety policy:** ship a restrictive CSP appropriate to the packaged SPA. Keep `default-src` restrictive; explicitly enumerate only required script/style/connect/image/font/media/frame sources. Do not weaken CSP with broad wildcards, `unsafe-eval`, or `unsafe-inline` unless an explicit, documented compatibility need has been security-reviewed. Do not disable CSP modification or inject remote script URLs to make a build work.

**Safety policy:** remote content is untrusted even when loaded in a Tauri WebView. Prefer opening untrusted external content in the system browser. If an in-app remote-content window is unavoidable, isolate it under a distinct label and capability with no privileged commands/plugins, constrain navigation/origins, and do not attach credentials, tokens, or sensitive IPC/event data.

**Safety policy:** expose local files through the asset protocol only when necessary. Authorize each resolved file/resource, use the narrowest scope, encode URLs correctly, and never convert a user path into an unrestricted asset URL. A `asset:` URL is not proof that the requester is authorized to read its target.

**Convention:** record every CSP exception, remote origin, and asset-protocol use with owner, purpose, label, capability, and removal condition. Treat a new `connect-src`, remote origin, or asset scope as a blocking security review change.

---

## Secrets, remote services, and updater boundary

**Safety policy:** frontend bundles, Tauri configuration, capabilities, permissions, logs, source maps, and updater artifacts are not secret stores. Never embed API secrets, private updater signing keys, service-account credentials, or production tokens in them. Environment-variable syntax changes delivery, not client-side secrecy.

**Safety policy:** credentials used for native or remote operations require explicit authority, an approved platform storage strategy, rotation/revocation behavior, minimal scope, and redacted logging. A secret retrieved from a native store may be used only by the authorized native service; do not round-trip it through `invoke`, events, query cache, route data, or React state.

**Official fact.** Tauri's updater is a plugin/configured update mechanism and signed update artifacts are security-sensitive. See [Updater Plugin](https://v2.tauri.app/plugin/updater/) and [Tauri Security](https://v2.tauri.app/security/) (accessed 2026-07-30; see the evidence caveat above).

**Safety policy:** do not configure, sign, publish, or test against a production updater endpoint without explicit authority. Keep private signing material outside the repository and build artifacts. Pin/update endpoint trust deliberately, validate the release process in a non-production environment first, and define rollback/revocation ownership before enabling auto-update.

---

## Do not reintroduce Tauri v1 access-control patterns

**Official fact.** Tauri v2 changed configuration and access control from v1; follow the current migration guidance rather than copying v1 examples. See [Migrate from Tauri 1.0](https://v2.tauri.app/start/migrate/from-tauri-1/) (accessed 2026-07-30; see the evidence caveat above).

Block and replace these v1-derived patterns:

- `tauri.allowlist` or a single broad allowlist in `tauri.conf.json`; use v2 capabilities, permissions, and plugin scopes instead.
- `@tauri-apps/api/tauri` or the `window.__TAURI__` global as an application-wide invoke shortcut; use explicit v2 API imports inside typed native adapters only.
- Trusting frontend route/UI checks as command authorization; enforce validation and authorization in Rust.
- Broad filesystem/shell/http access added to make a feature work; use a narrow capability, permission, scope, and fixed domain command.
- One capability matched to every window/webview label; use separate least-privilege capabilities by label/role.
- Treating bundled web assets, frontend environment variables, or updater configuration as places to store secrets.

---

## Blocking security gates

Block implementation, review approval, and release of the affected change until every applicable gate passes:

1. **Trust gate:** the threat boundary, untrusted inputs, authorized identity, and command-side validation/authorization are specified; no UI-only control is accepted as enforcement.
2. **Manifest gate:** each custom command is declared in the installed version's application manifest, has a reviewed app-command permission, and is granted only by intended capability labels; each plugin operation has its narrow permission and scope.
3. **Least-privilege gate:** no capability, default grant, scope, remote origin, filesystem root, shell executable, or label match is broader than the documented need.
4. **WebView gate:** CSP, remote-content isolation, navigation, asset-protocol exposure, and event/IPC data flow do not give untrusted content privileged access.
5. **Secret/update gate:** no secret reaches client-distributed material or IPC; credential/updater configuration, signing, publication, and production endpoints have explicit authority and a reviewed lifecycle.
6. **Compatibility gate:** no v1 allowlist/global/direct-invoke pattern remains; the generated v2 schema and current official guidance were checked for the actual installed version.
7. **Evidence gate:** the change includes allowed and denied label/resource cases, malformed input, authorization failure, listener cleanup where applicable, and safe-error behavior. Security-sensitive changes without focused negative evidence are blocked.

A blocker is resolved by narrowing the design or obtaining explicit authority and documented review evidence—not by disabling checks, adding a catch-all permission, or declaring the WebView trusted.

## Sources

> Links checked 2026-07-30.

| Claim | Source |
|---|---|
| Capabilities, permissions, scopes, runtime authority, the application manifest, CSP, the asset protocol, and updater security behavior | [tauri-v2-2026-07-30.md](../references/official/tauri-v2-2026-07-30.md); <https://v2.tauri.app/security/capabilities/>; <https://v2.tauri.app/security/permissions/>; <https://v2.tauri.app/security/scope/>; <https://v2.tauri.app/security/runtime-authority/>; <https://v2.tauri.app/security/csp/>; <https://v2.tauri.app/security/asset-protocol/>; <https://v2.tauri.app/plugin/updater/> |
| The v1 -> v2 access-control change behind the "do not reintroduce v1 patterns" list | [tauri-v2-2026-07-30.md](../references/official/tauri-v2-2026-07-30.md); <https://v2.tauri.app/start/migrate/from-tauri-1/> |
| Command-side validation, authorization, least privilege, secret handling, and allowed/denied evidence | This file's safety policy and this repository's convention; no external source |
