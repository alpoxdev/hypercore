# Hermes Native Plugin Authoring

> Korean version: [PLUGIN_AUTHORING.ko.md](PLUGIN_AUTHORING.ko.md)
> Concepts, lifecycle, catalog, portable packages, and security: [PLUGINS.md](PLUGINS.md)
> **Research date:** 2026-11-03, against the docs shipped with Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`) and the v0.22.0 release notes. The live documentation site deploys ahead of the tag: anything observed only on the site is dated with its check date instead of being presented as v0.22.5 behavior, and version-sensitive names should be confirmed with `--help` on the installed CLI.

## Sources and architecture

| Source | Supplies | Checked |
| --- | --- | --- |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | Manifest fields, `register(ctx)`, settings, state, commands, middleware | 2026-11-03 |
| [Plugin source at v0.22.5](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/developer-guide/plugins/index.md) | Exact signatures and defaults quoted below | 2026-11-03 |
| [Event Hooks catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) | Hook timing, payloads, return contracts | 2026-11-03 |
| [Plugins overview](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | Allow-list, isolation, scanning | 2026-11-03 |
| [v0.22.0 release notes](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | Dependency handling, isolation, removed import layer | 2026-11-03 |

A native plugin separates the manifest, model-facing schemas, handlers, and startup wiring:

```text
calculator/
├── plugin.yaml
├── __init__.py
├── schemas.py
└── tools.py
```

`register(ctx)` runs once at startup. It registers documented surfaces; an exception disables that plugin while Hermes continues. Keep imports and registration deterministic: defer network access, credential reads, background work, and mutations to handlers. `plugins.load_timeout_seconds` (default 10) skips a plugin whose import or `register()` overruns.

## Manifest

```yaml
name: calculator
version: 1.0.0
description: Evaluate basic arithmetic expressions
manifest_version: 2
provides_tools:
  - calculate
provides_hooks:
  - post_tool_call
requires_env:
  - name: WEATHER_API_KEY
    description: API key for the weather service
    url: https://example.com/keys
    secret: true
capabilities:
  - tools.override
python_dependencies:
  - "somepkg>=1.0,<2"
config_schema:
  endpoint: {type: str, default: "https://example.com", label: "Endpoint"}
  mode: {type: str, choices: [fast, careful], default: fast}
```

`provides_tools` and `provides_hooks` are declarations Doctor and catalog admission compare with actual registration; they do not decide what loads. A manifest without `manifest_version` is v1 and stays supported. Unknown fields warn but do not block loading, and a newer `manifest_version` still loads with a warning.

**v2 fields:** `manifest_version`, `api_version` (a separate axis from the file-format version), `requires_plugins` (advisory dependencies with optional `version_range` that also order `register()` calls), `python_dependencies`, `python_runtime: external` for a sidecar interpreter, `config_schema`, `license`, `homepage`, `tags`, `provides_locales`, `requires_auth`, and `oauth`.

**Fact:** declared Python dependencies are no longer inert. On install and enable, Hermes prepares them through its package manager together with core, extras, and every enabled plugin's requirements across profiles sharing the dependency home, then publishes the new environment atomically; a failed resolution keeps the previous generation and leaves the plugin disabled. `pyproject.toml` beside `plugin.yaml` wins over `python_dependencies`, `--no-deps` and `--yes-deps` answer the consent question up front, and `python_runtime: external` keeps a sidecar's packages out of the shared union. Pin upper bounds: Hermes's own three-day release-age policy does not apply to your dependencies.

A missing `requires_env` value disables the plugin cleanly.

## Complete calculator example

### `schemas.py`

```python
"""Model-facing tool schema."""

CALCULATE = {
    "name": "calculate",
    "description": "Evaluate a basic arithmetic expression such as '2 * (3 + 4)'.",
    "parameters": {
        "type": "object",
        "properties": {
            "expression": {
                "type": "string",
                "description": "Expression using numbers, +, -, *, /, parentheses, and **.",
            }
        },
        "required": ["expression"],
    },
}
```

### `tools.py`

```python
"""Calculator handler."""

import ast
import json
import operator

_BINARY = {
    ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul,
    ast.Div: operator.truediv, ast.Pow: operator.pow,
}
_UNARY = {ast.UAdd: operator.pos, ast.USub: operator.neg}


def _evaluate(node):
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in _BINARY:
        return _BINARY[type(node.op)](_evaluate(node.left), _evaluate(node.right))
    if isinstance(node, ast.UnaryOp) and type(node.op) in _UNARY:
        return _UNARY[type(node.op)](_evaluate(node.operand))
    raise ValueError("Only numeric arithmetic is allowed")


def calculate(args: dict, **kwargs) -> str:
    """Return JSON on both success and failure; never expose eval()."""
    del kwargs
    expression = str(args.get("expression", "")).strip()
    if not expression:
        return json.dumps({"error": "expression is required"})
    try:
        value = _evaluate(ast.parse(expression, mode="eval").body)
        return json.dumps({"expression": expression, "result": value})
    except (SyntaxError, ValueError, ZeroDivisionError, OverflowError) as exc:
        return json.dumps({"expression": expression, "error": str(exc)})
```

### `__init__.py`

```python
"""Calculator registration."""

import logging
from .schemas import CALCULATE
from .tools import calculate

logger = logging.getLogger(__name__)


def _after_tool(tool_name, args, result, task_id, **kwargs):
    del args, result, kwargs
    logger.debug("tool=%s task_id=%s", tool_name, task_id)


def register(ctx):
    if ctx.has_capability("tools.override"):
        logger.info("calculator may override built-in tools")
    ctx.register_tool(
        name="calculate", toolset="calculator", schema=CALCULATE,
        handler=calculate,
    )
    ctx.register_hook("post_tool_call", _after_tool)
```

Handlers receive an argument dictionary plus injected context keywords, return a JSON **string** on success and expected failure, catch expected exceptions, and accept `**kwargs`. The schema description is what the model sees. Never `eval` model or user input; this example permits only a small numeric AST.

## Tools and hooks

`ctx.register_tool(name=..., toolset=..., schema=..., handler=...)` puts a tool in the registry; `toolset` is the ownership namespace and `check_fn` can hide an unavailable optional tool. A conflicting name needs `override=True`, which for a non-bundled plugin also needs the declared and granted `tools.override` capability.

`ctx.register_hook(event, callback)`. The [hooks catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) is authoritative for timing, payloads, and returns. Most hooks observe; `pre_tool_call` can block, modify shallow arguments, or request approval, and `pre_llm_call` can inject per-turn context.

**Fact — bounded callbacks:** hot-path observers and `pre_tool_call` are abandoned after `plugins.hook_callback_timeout` (default 30 s, max 600). A timed-out `pre_tool_call` fails closed; other bounded hooks fail open. A callback that misnames a payload field is reported once with the fields the hook actually sends, then at DEBUG.

**Fact — durable guidance:** `ctx.register_system_prompt_section("my-plugin.rules", text_or_callable, position="after_memory", max_chars=4000)` renders once per new session, freezes on compression, and survives restart from the persisted prompt. Use it instead of injecting the same text every turn. The whole budget is 8,000 characters across at most 32 sections.

**Fact — middleware is separate:** `ctx.register_middleware(kind, callback)` with kinds `tool_request`, `llm_request`, `tool_execution`, `llm_execution`. Request kinds return `{"args": ...}` or `{"request": ...}` to rewrite the effective payload before hooks and approvals see it; execution kinds wrap the call and must invoke the single-use `next_call` exactly once. A raising callback is logged and skipped; middleware can never break the base path.

Do not use hooks to silently approve actions. Hermes owns hardline blocks, approval binding, and final authorization.

## Commands, skills, data, configuration, and state

A slash command is an in-session `/name` command (CLI and gateway); a CLI command is terminal-only `hermes name ...`.

```python
def status(raw_args: str, *, platform: str = "", session_id: str = "") -> str:
    if raw_args.strip() == "help":
        return "Usage: /calc-status"
    return f"calculator ready on {platform or 'cli'} ({session_id or 'no session'})"

def setup(subparser):
    subparser.add_parser("status", help="Show calculator status")

def cli_handler(args):
    print("calculator ready")

def register(ctx):
    ctx.register_command("calc-status", status, description="Show calculator status")
    ctx.register_cli_command(
        name="calculator", help="Calculator administration",
        setup_fn=setup, handler_fn=cli_handler,
    )
```

**Fact — where slash handlers run:** the gateway process that owns the session, including for commands typed in the classic CLI. Return the text to show instead of calling `print()`, resolve paths against `agent.runtime_cwd.resolve_agent_cwd()` rather than `os.getcwd()`, and declare `session_id`, `session_key`, `platform`, or `source` as keywords to receive the calling context. Built-in slash names win over conflicts. Handlers may be async.

**Fact — asking the user:** a synchronous handler can call `ctx.ask_choice(question, choices)` to render buttons on Telegram/Discord/Slack, a numbered list elsewhere, or the clarify picker in CLI/TUI/Desktop. It returns the chosen value or `None` on cancel, invalid input, timeout, or when nothing can ask (a hook, cron job, or async handler). A choice is a string or `{"value", "label", "description"}`.

To invoke a tool from a command or hook, use `ctx.dispatch_tool(name, args)`, which retains parent context, approval, redaction, and budgets. `ctx.profile_name` identifies the active profile in every process, so prefer it over `_cli_ref`, which is `None` in the gateway and in Kanban workers.

Read immutable shipped data relative to `Path(__file__).parent / "data" / "file.json"`. Register `skills/<name>/SKILL.md` with `ctx.register_skill`; skills are read-only and namespaced as `plugin:skill`, invoked as `/plugin:skill` in a chat. Use `ctx.get_config`/`ctx.set_config` only for user-visible settings under `plugins.entries.<id>.settings`, and declare them in `config_schema` so the Desktop renders a form. Every save broadcasts `plugin.<id>.settings.changed`. Use `ctx.state` (profile-scoped, atomic, 10 MiB per plugin) or `plugin_data_dir()`/`plugin_db()` for runtime data that must survive updates; never write state or secrets to the install tree.

## Doctor, debugging, distribution, and compatibility

```bash
hermes plugins doctor . --ci          # discovery, import, register, registry checks
hermes plugins validate . --install-deps   # the catalog CI check, locally
HERMES_PLUGINS_DEBUG=1 hermes plugins list
hermes logs --level WARNING
```

Doctor uses temporary `HERMES_HOME`, restores registration state, and blocks direct Python sockets during registration. It still imports code in-process and is **not a sandbox**; run it only for trusted code.

Publish directory plugins in a standalone repository, preferably installed by immutable commit. A pip package uses entry points:

```toml
[project.entry-points."hermes_agent.plugins"]
calculator = "hermes_calculator:register"

[project.entry-points."hermes_agent.plugin_capabilities"]
"calculator.tools.override" = "hermes_calculator:register"
```

Document supported Hermes versions, requested capabilities, environment variables, data retention, network endpoints, and upgrades.

**Compatibility facts:** the contract is behavior-based, not an API version number. `PluginContext` methods evolve additively, new parameters are optional and preferably keyword-only, hook payloads add keyword fields, unknown manifest fields are ignored, and provider interfaces add defaults. Persisted state and resumable data must stay readable or ship a migration. A documented behavior may be removed only with a replacement and migration guide, a once-per-process warning naming the earliest removal release, support through two subsequent minor releases, and fixtures covering old and replacement paths.

**Fact — removal precedent:** the September 2026 module decomposition deleted internal import paths after a compatibility layer that expired on 2026-09-14. A plugin that still imports an old path now fails to load with a visible `ImportError`. Import from the defining module or, better, stay on `ctx` and the documented ABCs.

**Fact — not a supported extension point:** monkeypatching core functions, modules, `sys.modules`, or core dicts. The catalog rejects it at admission, and `plugins.isolation: host` cannot run such a plugin at all.

**Recommendation:** use documented APIs, accept `**kwargs`, avoid internal imports, version wire and persisted formats locally, and keep an external compatibility fixture.
