# Hermes Agent Plugins

> Korean version: [PLUGINS.ko.md](PLUGINS.ko.md)
> Implementation guide: [PLUGIN_AUTHORING.md](PLUGIN_AUTHORING.md)  
> 2026 deltas that invalidate older notes: [hermes-agent-2026-changes.md](references/hermes-agent-2026-changes.md)
> **Research date:** 2026-11-03, against the documentation shipped with Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`, 2026-10-22) plus the v0.22.0 release notes. Confirm behavior against the installed version before release. The live documentation site deploys ahead of the tag: anything observed only on the site is dated with its check date instead of being presented as v0.22.5 behavior, and version-sensitive names should be confirmed with `--help` on the installed CLI.

## Scope and sources

This guide covers choosing, discovering, installing, operating, and securing Hermes plugins. For manifests, `register(ctx)`, code, validation, packaging, and compatibility, read [Plugin authoring](PLUGIN_AUTHORING.md).

| Source | Supplies | Checked |
| --- | --- | --- |
| [Plugins overview](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | Discovery, opt-in allow-list, catalog, packs, scanning, isolation | 2026-11-03 |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | Native and portable plugin contracts | 2026-11-03 |
| [Plugins source at v0.22.5](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/user-guide/features/plugins.md) | Exact defaults and field lists quoted below | 2026-11-03 |
| [Plugin catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog) | Catalog trust model and admission | 2026-11-03 |
| [MCP](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp) | MCP as the external-tool surface | 2026-11-03 |
| [Agent Plugins v1.0.0 specification](https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md) | Portable package format | 2026-11-03 |
| [v0.22.0 release notes](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | Catalog at 600 entries, plugin isolation, dependency handling | 2026-11-03 |

## Choose the smallest extension surface

| Need | Use | Do not use a native general plugin when |
|---|---|---|
| LLM-callable tools, Python hooks, slash commands, CLI subcommands, packaged skills | **Native plugin**: `plugin.yaml` + Python `register(ctx)` | The integration is only an external MCP server or a knowledge workflow. |
| Portable skills and a limited MCP package usable by Agent Plugins implementations | **Portable Agent Plugin v1**: `plugin.json`, `skills/`, optional `mcp.json` | You need Python handlers, hooks, commands, provider registration, or a sandbox. Hermes supports a subset, not full conformance. |
| Instructions/workflow with no executable integration | **Skill** | You need a runtime tool, credentialed API, or lifecycle behavior. |
| Existing external tool server | **MCP** in `mcp_servers` configuration | You need in-process Python behavior or Hermes lifecycle hooks. |
| Native desktop or dashboard UI | Desktop Plugin SDK or dashboard extension | You need agent tools rather than UI slots. |
| TTS/STT backend or a shell event command | Config-driven command provider or shell hook | A command template fully expresses the integration. |

**Recommendation:** build a plugin that integrates a third-party product in a standalone repository. Hermes states this as a coupling and maintenance boundary, not a quality judgment.

## Discovery and activation lifecycle

**Fact:** discovery sources are bundled `<repo>/plugins/`, user `~/.hermes/plugins/`, project `.hermes/plugins/`, pip `hermes_agent.plugins` entry points, and Nix declarations. On a same-name collision a later source replaces an earlier one, so a user plugin can shadow a bundled plugin of the same name.

**Fact:** the gateway does not load project-local plugins. Every session — `hermes`, `--tui`, Desktop, messaging, cron — discovers plugins once for the whole gateway process, never from the directory a session started in, so `HERMES_ENABLE_PROJECT_PLUGINS=true` has no effect and only produces a startup warning. Install and enable a user plugin instead.

**Fact:** general user plugins and pip-installed backend plugins are **discovered but not executed** until named in `plugins.enabled`; `plugins.disabled` wins on a conflict. Bundled platform adapters, bundled backends, memory providers, context engines, and model providers are not gated by that allow-list — they auto-load and are selected by `gateway.platforms.<name>.enabled`, `<category>.provider`, `memory.provider`, `context.engine`, or `--provider`.

```bash
hermes plugins                      # interactive toggle
hermes plugins install owner/repository --no-enable
hermes plugins list
hermes plugins enable calculator
hermes plugins disable calculator
hermes plugins remove calculator
```

**Fact:** three timing knobs matter for load behavior: `plugins.clone_timeout_seconds` (default 300, clamped above 3600), `plugins.load_timeout_seconds` (default 10; an overrunning import or `register()` is skipped with "load timed out after Ns" and the remaining plugins keep loading), and `plugins.hook_callback_timeout` (default 30, `0` disables, clamped above 600).

**Fact:** a reproducible install pins a full 40-character commit. Hermes checks out detached, verifies `HEAD` matches, and records source, revision, and pin status per profile. Tags, branches, and abbreviated SHAs are rejected, and `plugins update` refuses to move a pinned plugin; change it with `install <source> --force --ref <new-commit>`. A forced reinstall from the same source keeps untracked files and backs up edits to tracked files under `~/.hermes/plugins-backup/<name>-<sha>/`.

**Fact:** private repositories resolve a credential only after anonymous access is refused, in order: `GITHUB_TOKEN`/`GH_TOKEN` from `.env`, the `gh` CLI login, then the git credential helper. The credential is used for that one request and is never written into the plugin's `.git/config` or install metadata.

**Recommendation:** pin the exact production revision and treat an update as a code deployment. Enablement is the consent boundary; an install alone runs nothing.

## Catalog, packs, and install-time scanning

**Fact:** `hermes plugins search <term>`, `browse`, and `info <name>` search the curated catalog maintained in the repository's `plugin-catalog/`. The catalog page listed **910 entries** (20 Official, 9 Verified, 881 Community) on 2026-11-03, up from the 600 reported at the v0.22.0 launch. Installing by bare name resolves to the entry's repository at its pinned commit SHA and records catalog provenance so `hermes plugins update` can re-pin when the catalog moves. Explicit `owner/repo` or Git URLs are flagged as custom, unreviewed sources.

**Fact:** catalog admission means a human looked at the pinned commit, capability declarations were checked, and the repository met the submission bar. The catalog page states plainly that this **is not a security audit** and says nothing about other commits in the same repository. Listings can declare known issues that install shows, and catalog rules keep entries from patching Hermes internals or shipping unscannable binaries.

**Fact:** a plugin pack is a `hermes-pack.yaml` file pinning several plugins, each with an exact 40-character `ref`, plus optional non-secret `config:` seeds and a declarative `skills:` list. `hermes plugins pack show|install|export` reviews, installs, and snapshots them. Pack install always shows a mandatory review screen, asks one confirmation for the contents, then runs the normal per-plugin capability consent. There is no `--yes`, secrets are rejected and stripped, and each plugin installs independently.

**Fact:** every `hermes plugins install` and `plugins update` runs a static scan with three verdicts: `safe` installs, `caution` shows findings and asks for confirmation (or `--force`), and `dangerous` blocks with no `--force` override. A dangerous verdict on an update leaves the plugin disabled until review. Documentation prose and test fixtures decay to "context" findings rather than becoming a behavioral block. Disable with `plugins.scan_on_install: false`.

**Recommendation:** treat catalog inclusion, a `safe` scan, and a passing Doctor as three different signals, none of which is a security review of behavior.

## Provider and extension boundaries

Use the dedicated interface, not an ordinary tool, for these backends:

| Extension | Boundary and selection |
|---|---|
| Inference/model provider | Register `ProviderProfile` in `plugins/model-providers/<name>/`; user selects it with `--provider` or configuration. Out-of-tree providers install with `hermes plugins install` and log in through `hermes auth`. |
| Memory provider or context engine | Dedicated single-active-provider interface (`memory.provider`, `context.engine`). |
| Gateway platform, image/video generation, browser, web search, TTS/STT, delegation, computer use, terminal backend, secret source, dashboard auth | Their documented `ctx.register_*` interface and discovery path. |
| External tools | Configure MCP; Hermes discovers the server's tools. Plugins can also call MCP through a capability-gated `ctx.call_mcp`. |

General plugins can coexist. Provider selection has different ownership and activation semantics, so keep credentials, retries, and capability behavior inside the provider interface.

## Portable Agent Plugins v1

Portable packages are compatibility packages, not native Python plugins:

```text
my-portable-plugin/
├── plugin.json
├── skills/
│   └── summarize/
│       └── SKILL.md
└── mcp.json
```

**Fact:** Hermes targets the **Agent Plugins v1.0.0** format. It validates `plugin.json`, skill frontmatter, fixed component locations, `mcp.json`, resolved paths, and symlink containment locally, and never fetches schemas while loading. Enabled packages provide read-only namespaced skills through `skills_list` and `skill_view`, plus MCP. The namespace is deterministic (`agent-plugin-<slug>-<hash>`). `PLUGIN_ROOT` is the resolved package root; `PLUGIN_DATA` is profile-scoped writable storage.

**Fact:** the supported MCP subset is **stdio** and **Streamable HTTP**. Stdio uses one executable token plus a separate argument list, never a shell. Streamable HTTP requires an absolute `http(s)` URL without userinfo or fragments; plain HTTP is restricted to loopback and headers do not cross cross-origin redirects. Legacy `sse` is reported then skipped. A duplicate server name resolves in favor of `config.yaml`, then the first loaded package.

**Fact — version pin:** the upstream specification repository also publishes `spec/1.1.0.md`, whose own header marks it **Working Draft**; only `v1.0.0` is tagged. Hermes documents v1.0.0 as the format it loads, so target v1.0.0. Do not read 1.1.0 features as Hermes behavior until an official Hermes doc says otherwise.

Portable v1 defines no trust, permissions, provenance, or sandbox. Enabling one gives its instructions and local executable the same full-trust posture as any other installed plugin.

## Operations and security

```bash
# Review discovery and load diagnostics.
HERMES_PLUGINS_DEBUG=1 hermes plugins list
hermes logs --level WARNING
hermes plugins capabilities calculator
hermes plugins doctor ./calculator --ci     # same discovery/import/register path
hermes plugins validate ./calculator --install-deps   # catalog CI parity
```

Declare missing runtime credentials with `requires_env` in a native manifest; a missing required variable disables the plugin rather than crashing Hermes. Never store credentials in portable `mcp.json`, manifests, source, logs, or plugin state.

**Fact:** privileged host surfaces are declared under `capabilities:` — `tools.override`, `llm.provider_override`, `llm.model_override`, `llm.agent_id_override`, `llm.profile_override`, `llm.task_override` — and consented at install or enable time, with re-consent only for newly added ids. Unconsented capabilities fail closed, so a plugin probes `ctx.has_capability()` and degrades gracefully. Pip-distributed plugins declare them in the `hermes_agent.plugin_capabilities` entry-point group.

**Fact — isolation:** `plugins.isolation: host` (default `in_process`) moves third-party plugin code into one separate Python process per profile, started on demand and talking over a private pipe. A crash kills the host, not Hermes; the in-flight call returns a tool error and the host restarts. Gateway platform adapters, approval transports, Telegram handlers, providers that build their own SDK client, terminal backends, streaming/websocket dashboard endpoints, and plugins that monkeypatch Hermes stay in-process and fail with a clear reason under `host`. Pin the setting in managed scope when profiles belong to people you isolate from each other.

**Critical fact:** capabilities are consent and audit controls, **not a sandbox**, and `isolation: host` does not sandbox either — it separates interpreters and profile secrets, not OS permissions. Install and enable only trusted code.

2026 additions worth knowing: `ctx.llm` for host-owned model calls, `ctx.register_middleware` for `tool_request`/`llm_request`/`tool_execution`/`llm_execution`, approval transports, delegation providers, provider plugins, `plugin_data_dir()`/`plugin_db()` for state that survives updates, and plugin skills invoked as `/plugin:skill`.

For authoring details see [Plugin authoring](PLUGIN_AUTHORING.md).
