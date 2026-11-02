# Hermes Agent extensions and operations map

> Korean translation: [EXTENSIONS.ko.md](EXTENSIONS.ko.md)
> Companion guides: [overview](README.md), [configuration](CONFIGURATION.md), [Discord](DISCORD.md), [messaging gateway](MESSAGING.md), [skills](SKILLS.md), [plugins](PLUGINS.md), and [hooks](HOOK.md)
> **Research date:** 2026-11-03, against the documentation shipped with Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`) and the v0.22.0 release notes. Every claim is limited to those official sources. The live documentation site deploys ahead of the tag: anything observed only on the site is dated with its check date instead of being presented as v0.22.5 behavior, and version-sensitive names should be confirmed with `--help` on the installed CLI.

Hermes extensions cross trust boundaries: an MCP server can run a local program or call a remote service; a messaging gateway accepts messages from another platform; and a tool provider receives input and credentials. Treat enabling an extension as granting capability, not merely adding a UI feature.

| Source | Supplies | Checked |
| --- | --- | --- |
| [MCP](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp) | Server kinds, catalog, filtering, security | 2026-11-03 |
| [Plugins](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | Catalog, scanning, isolation | 2026-11-03 |
| [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging) | Gateway lifecycle and delivery | 2026-11-03 |
| [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway) | One process for every profile | 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | Approval stack and trust boundaries | 2026-11-03 |
| [v0.22.0 release notes](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | Connectors, plugin isolation, catalog size | 2026-11-03 |

## Choose the extension surface

| Need | Primary surface | Operational boundary |
| --- | --- | --- |
| Existing external tools, databases, or internal API | MCP (`mcp_servers`) | Server code and its credentials become available to Hermes. |
| Hosted app tools such as Linear or Notion | Connectors through the Nous tool gateway | Sign-in identity and the app's own authorization scope govern access. |
| Hermes-native behavior | Native plugin or provider configuration | In-process code by default; provider sends task content to its service. |
| Chat from Telegram, Discord, Slack, WhatsApp, Signal, or Email | Messaging gateway | Platform identity, pairing, and untrusted inbound text. |
| React to lifecycle events or enforce local policy | Hooks, shell hooks, plugin hooks | Hook code executes with its configured process privileges. |
| Spoken input or output | STT/TTS provider | Audio and text leave the host when cloud-backed. |
| GUI or local control plane | Desktop app or dashboard | Bind and access controls determine who can operate it. |

Do not use a native plugin guide as an MCP substitute, and do not assume a catalog entry is sandboxed.

## MCP: configure, limit, and operate

**Fact:** Hermes supports local stdio servers and remote HTTP servers in one `mcp_servers` block, plus a curated catalog of Nous-reviewed servers that are disabled until installed. The catalog install card appears in Desktop, the TUI, and the CLI, shows all setup fields at once with secrets masked, and saves configuration and tokens together only after the server accepts the token. Hermes never opens a browser on its own.

```yaml
mcp_servers:
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
  remote_api:
    url: "https://mcp.example.com/mcp"
    headers:
      Authorization: "Bearer ${MCP_TOKEN}"
```

**Fact:** `${VAR}` and `${env:VAR}` resolve at connect time from the environment, including `~/.hermes/.env`; an undefined variable stays literal and logs a warning. Stdio servers receive a filtered environment, so a variable must be passed explicitly. OAuth servers handle discovery, PKCE, refresh, and step-up authentication, and tokens are cached per server with restrictive permissions; on a headless host re-authorize with `hermes mcp login <server>`.

**Fact:** filtering precedence is deny-list, then allow-list, then glob patterns under `mcp_servers.<name>.tools`. Utility tools are filtered separately, and a server whose tools are all filtered out is reported rather than silently absent.

**Fact:** a server with `lazy: true` registers from the on-disk schema cache and spawns on first use; `notifications/tools/list_changed` refreshes the registry automatically; `/reload-mcp` re-probes the rest. A running gateway watches `config.yaml` and connects or tears down changed entries within about a minute.

**Recommendation:** select only the tools you need, especially excluding destructive or administrative operations. Review the catalog manifest's source, bootstrap commands, transport, endpoint, and authentication before installing, and remember that catalog review is evidence, not your supply-chain review.

## Hosted connectors

**Fact:** Connectors let the agent act in hosted apps through the Nous tool gateway. The first use of an app creates a free connectors-only identity, so no Nous account is required to start; several named accounts of one app can be connected and managed with `/connectors` or `hermes connectors`. The Desktop's **Connectors** page lists hosted apps and local MCP servers together and replaced the former MCP tab.

**Recommendation:** `tools.connectors.enabled: false` turns connectors off, and `nous.guest: false` disables guest identities. Apply the same credential and scope review you apply to MCP servers; a connector uses your app authorization, not a separate sandbox.

## Provider map: what is extended and where data goes

The official [provider guide](https://hermes-agent.nousresearch.com/docs/integrations/providers) is the authority for current provider IDs, model names, and credentials. The [Tool Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/features/tool-gateway) can supply web search, image generation, TTS, and cloud-browser backends through Nous Portal, while individual backends can also use their own credentials. Model providers can now be installed as out-of-tree plugins and authenticated with `hermes auth`.

| Capability | What to decide | Data/credential boundary |
| --- | --- | --- |
| Model | Provider, model, fallback, endpoint | Prompts, tool schemas, and model-visible context go to the selected provider. |
| Memory/context | Whether persistent memory and project context are appropriate | Local state persists under the Hermes home; imported text is not thereby trusted. |
| Web search | Backend and query handling | Queries and retrieved content cross to that provider; web content stays untrusted input. |
| Browser | Local or cloud backend, authenticated browsing policy | A cloud browser receives navigation and page data; session cookies are high-value credentials. |
| Image/video | Generation or analysis provider and retention | Prompts and media cross to that provider. |
| Secrets | `.env`, OAuth, or external injection | Inject only into the component that needs the secret, never into prompts or committed YAML. |
| TTS/STT | Voice backend and consent | Cloud backends receive audio and transcripts. |

## Messaging gateway and adapters

**Fact:** a single gateway process per machine now serves every profile by default (`gateway.multiplex_profiles`, default `true`). Each served profile keeps its own credentials, allowlists, sessions, and cron jobs; `hermes update` migrates per-profile installs, `hermes gateway migrate --multiplex` does it by hand, webhook platforms route each profile at `/p/<profile>/`, and `gateway.standalone: true` is a temporary opt-out. Creating a profile makes its bots live without a restart.

**Fact:** `platforms.<name>.enabled: false` is authoritative even when credentials remain in `.env`; omitting the key keeps the credentials-present behavior. Read [Messaging gateway](MESSAGING.md) for authorization, session scope, delivery semantics, and adapter differences, and [Discord setup](DISCORD.md) for Developer Portal and access-policy work.

```bash
hermes gateway setup
hermes gateway install
hermes gateway start
```

**Recommendation:** keep bot tokens in `.env`, restrict who may converse through pairing or allowlists, and use separate identities for production. Dangerous-command approval in chat is meaningful only in the correctly paired conversation; do not enable headless auto-approval because an adapter is available.

## Hooks and shell hooks

**Fact:** the four hook systems — gateway hooks, plugin hooks, shell hooks, and outbound webhooks — differ in registration, scope, and authority. Shell hooks now also run in Desktop, TUI, and dashboard chat, and their first-use consent is stored per `(event, command)` pair. Plugin callbacks are bounded by `plugins.hook_callback_timeout` (default 30 s), and a timed-out `pre_tool_call` fails closed.

Read [Hooks](HOOK.md) before configuring any of them. Treat hook configuration as executable code: keep scripts in a reviewed location, never interpolate untrusted text into shell syntax, bound runtime, and log enough to diagnose failure without recording secrets. A successful hook run does not validate the safety of its input.

## Dashboard, desktop, profiles, and state

**Fact:** the default Hermes home is `~/.hermes/`, holding `config.yaml`, `.env`, auth material, memories, skills, cron jobs, sessions, logs, plugin data, and MCP tokens. `HERMES_HOME` selects profile state; the multiplexed gateway serves several profiles from one process while keeping their secrets scoped.

```bash
hermes config
hermes config get model
hermes config set terminal.backend docker
hermes config unset terminal.backend
hermes config check
hermes config migrate
```

**Fact:** `hermes config set` routes API keys to `.env` and non-secret values to `config.yaml`. External secret systems should inject environment values at startup rather than rely on unsupported inline vault references.

**Fact:** profile isolation does not automatically isolate host credentials. With a local backend, `terminal.home_mode: auto` preserves the real OS `HOME`, so subprocesses can see ordinary `ssh`, GitHub CLI, cloud, and package-manager credentials. The safer default for untrusted work is an isolated backend such as Docker, Modal, Daytona, Vercel Sandbox, or Singularity; verify mounts, egress, and environment forwarding because a host mount defeats the boundary.

## Plugin trust at install time

**Fact:** three independent controls now sit in front of plugin code. Install and update run a static scan with `safe`, `caution`, and `dangerous` verdicts, where `dangerous` cannot be overridden by `--force`. `plugins.isolation: host` moves third-party code into a per-profile process with only that profile's secrets. The catalog pins entries to reviewed commits but explicitly is not a code audit.

**Recommendation:** combine the three — reviewed sources, a scan verdict you understand, and host isolation for anything you do not fully trust. None of them replaces reading the code or a capability-free design.

## Security audit, approvals, and safe operation

Before enabling or changing an extension, audit the source and release, execution location, tool list and mutation scope, credentials and OAuth scopes, reachable files and network, authorized gateway users, log retention, and the removal path. `hermes doctor` gives product diagnostics, `hermes plugins validate` runs the catalog check locally, and install/update run a static security scan; none of them replaces reviewing the configuration or the code.

Approval modes live under `approvals.mode`: `smart` (default), `manual`, or `off`. Keep `cron_mode: deny`, `single_query_mode: deny`, and `unattended_mode: deny` unless reviewed automation needs otherwise, and remember that unattended programmatic surfaces (webhook, msgraph webhook, API server) block instantly instead of waiting out the approval timeout, and note that the dangerous-command guard stack runs only on host-reaching backends. `hermes --yolo`, `hermes chat --yolo`, `/yolo`, or `HERMES_YOLO_MODE=1` bypass prompts for the session but not the always-on hardline blocklist. Permanent "always" approvals become `command_allowlist` entries; review them periodically.

## Decision matrix and incident triage

| Situation | Select | Avoid / check first |
| --- | --- | --- |
| Need a vetted third-party integration | MCP catalog entry with least tools | Installing before reviewing its manifest and bootstrap. |
| Need a hosted SaaS app | Connector with a named account | Assuming connector access is scoped more narrowly than the app grant. |
| Need a private or local service | stdio MCP or a controlled internal HTTP MCP | Passing the full host environment or broad filesystem roots. |
| Need messaging control | Gateway adapter plus pairing or allowlist | Treating any channel participant as an operator. |
| Need unattended automation | Cron with explicit review and least privilege | `cron_mode: approve` on a host with production secrets. |
| Need to process untrusted content | Separate profile and isolated backend | Local backend with real HOME, host mounts, and forwarded credentials. |
| Need a third-party plugin | Catalog entry, scan verdict, host isolation | Assuming catalog admission is a code audit. |
| Tool fails after a change | Check config, credentials, endpoint, then filtering | Reloading or broadening access blindly. |

For suspected credential exposure: stop the affected gateway, provider, or MCP connection, revoke and rotate the credential at its issuer, remove the affected `.env` or OAuth state and persistent allowlists, inspect logs and adapter authorization, and re-enable only after reviewing configuration and scopes. Redaction in logs is not a justification for logging sensitive input.
