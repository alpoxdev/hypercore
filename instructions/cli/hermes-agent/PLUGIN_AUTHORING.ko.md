# Hermes native 플러그인 작성

> English version: [PLUGIN_AUTHORING.md](PLUGIN_AUTHORING.md)
> 개념, 수명 주기, catalog, portable 패키지, 보안: [PLUGINS.ko.md](PLUGINS.ko.md)
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a` 측정치)에 포함된 문서와 v0.22.0 릴리스 노트를 근거로 삼았습니다. 라이브 문서 사이트는 tag보다 먼저 배포되므로, 사이트에서만 확인한 내용은 v0.22.5 동작으로 적지 않고 확인일과 함께 적었으며, 버전에 민감한 이름은 설치된 CLI의 `--help`로 다시 확인해야 합니다.

## 출처와 구조

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | 매니페스트 필드, `register(ctx)`, 설정, 상태, 명령, middleware | 확인 2026-11-03 |
| [v0.22.5의 플러그인 문서 source](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/developer-guide/plugins/index.md) | 아래에 인용한 정확한 signature와 기본값 | 확인 2026-11-03 |
| [Event Hooks catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) | hook 시점, payload, 반환 계약 | 확인 2026-11-03 |
| [플러그인 개요](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | allow-list, isolation, 보안 검사 | 확인 2026-11-03 |
| [v0.22.0 릴리스 노트](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | 의존성 처리, isolation, 제거된 import 계층 | 확인 2026-11-03 |

native 플러그인은 매니페스트, 모델이 보는 schema, handler, 시작 시 연결 코드를 나눠 둡니다.

```text
calculator/
├── plugin.yaml
├── __init__.py
├── schemas.py
└── tools.py
```

`register(ctx)`는 시작할 때 한 번 실행됩니다. 문서화된 표면을 등록하고, 여기서 예외가 나면 해당 플러그인만 비활성화되고 Hermes는 계속 동작합니다. import와 등록은 결정적으로 유지합니다. 네트워크 접근, 자격 증명 읽기, background 작업, 상태 변경은 handler로 미룹니다. import나 `register()`가 `plugins.load_timeout_seconds`(기본 10초)를 넘기면 그 플러그인은 건너뜁니다.

## 매니페스트

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

`provides_tools`와 `provides_hooks`는 Doctor와 catalog 심사가 실제 등록 결과와 비교하는 선언이며, 무엇이 load되는지를 정하지는 않습니다. `manifest_version`이 없으면 v1 매니페스트이고 계속 지원합니다. 모르는 필드는 경고만 남기고 load를 막지 않으며, 이해하지 못하는 더 높은 `manifest_version`도 경고와 함께 load됩니다.

**v2 필드:** `manifest_version`, `api_version`(파일 형식 버전과 별개인 축), `requires_plugins`(선택적 `version_range`를 가진 권고 의존성이며 `register()` 순서도 정합니다), `python_dependencies`, sidecar interpreter용 `python_runtime: external`, `config_schema`, `license`, `homepage`, `tags`, `provides_locales`, `requires_auth`, `oauth`입니다.

**사실:** 선언한 Python 의존성은 더 이상 표시만 되지 않습니다. 설치와 활성화 때 Hermes는 같은 의존성 home을 공유하는 모든 profile에서 core, 선택한 extras, 활성화된 모든 플러그인의 요구 사항을 함께 package manager로 준비하고 새 환경을 한 번에 교체합니다. 해석에 실패하면 이전 세대를 그대로 두고 플러그인은 비활성 상태로 남습니다. `plugin.yaml` 옆의 `pyproject.toml`이 `python_dependencies`보다 우선하고, `--no-deps`와 `--yes-deps`는 동의 질문을 미리 정하며, `python_runtime: external`은 sidecar 패키지를 공유 집합에서 뺍니다. 상한을 반드시 적습니다. Hermes가 자기 의존성에 적용하는 3일 경과 규칙은 플러그인 의존성에는 적용되지 않습니다.

`requires_env` 값이 없으면 플러그인은 조용히 비활성화됩니다.

## 완성된 계산기 예제

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

handler는 인자 dictionary와 주입된 context keyword를 받고, 성공과 예상한 실패 모두에서 JSON **문자열**을 반환하며, 예상 가능한 예외를 처리하고 `**kwargs`를 받습니다. 모델이 보는 것은 schema의 description입니다. 모델이나 사용자 입력에 `eval`을 쓰지 않습니다. 이 예제는 작은 숫자 AST만 허용합니다.

## 도구와 hook

`ctx.register_tool(name=..., toolset=..., schema=..., handler=...)`은 tool을 registry에 넣습니다. `toolset`은 소유 이름 공간이고 `check_fn`으로 사용할 수 없는 선택 도구를 숨길 수 있습니다. 이름이 충돌하면 `override=True`가 필요하고, 번들에 없는 플러그인은 선언하고 동의받은 `tools.override` capability도 있어야 합니다.

hook은 `ctx.register_hook(event, callback)`으로 등록합니다. 시점, payload, 반환값은 [hooks catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks)가 기준입니다. 대부분은 관찰만 하고, `pre_tool_call`은 차단, 얕은 인자 수정, approval 요청이 가능하며 `pre_llm_call`은 turn 단위 문맥을 주입합니다.

**사실 — 시간 제한:** hot-path observer와 `pre_tool_call`은 `plugins.hook_callback_timeout`(기본 30초, 최대 600)을 넘기면 버려집니다. `pre_tool_call`이 시간을 넘기면 fail closed로 차단하고, 나머지 제한 대상 hook은 fail open입니다. payload 필드 이름을 잘못 적은 callback은 실제로 전달되는 필드 목록과 함께 한 번 경고하고 이후에는 DEBUG로 기록합니다.

**사실 — 유지되는 지침:** `ctx.register_system_prompt_section("my-plugin.rules", text_or_callable, position="after_memory", max_chars=4000)`은 새 session마다 한 번 렌더링되고, 압축 때 고정되며, 재시작 뒤에도 저장된 prompt에서 복원됩니다. 매 turn 같은 문장을 주입하는 대신 이 방식을 씁니다. 전체 한도는 최대 32개, 8,000자입니다.

**사실 — middleware는 별개입니다:** `ctx.register_middleware(kind, callback)`의 kind는 `tool_request`, `llm_request`, `tool_execution`, `llm_execution`입니다. 요청 kind는 `{"args": ...}`나 `{"request": ...}`를 반환해 hook과 approval이 보기 전에 실제 payload를 바꾸고, 실행 kind는 호출을 감싸며 한 번만 쓸 수 있는 `next_call`을 정확히 한 번 호출해야 합니다. 예외를 낸 callback은 기록 후 건너뛰므로 middleware가 기본 경로를 깨뜨릴 수는 없습니다.

approval을 hook으로 조용히 승인하지 않습니다. hardline 차단, 승인 요청 결속, 최종 인가는 Hermes가 소유합니다.

## 명령, skill, 데이터, 설정, 상태

slash command는 session 안에서 쓰는 `/name` 명령(CLI와 gateway)이고, CLI 명령은 터미널에서만 쓰는 `hermes name ...`입니다.

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

**사실 — slash handler의 실행 위치:** session을 소유한 gateway 프로세스이며, 기존 CLI에서 입력한 명령도 마찬가지입니다. 보여 줄 문자열을 반환하고 `print()`를 쓰지 않습니다. 경로는 `os.getcwd()`가 아니라 `agent.runtime_cwd.resolve_agent_cwd()`를 기준으로 풉니다. `session_id`, `session_key`, `platform`, `source`를 keyword로 선언하면 호출한 session 정보를 받습니다. 내장 명령과 이름이 겹치면 내장 명령이 이깁니다. handler는 async여도 됩니다.

**사실 — 사용자에게 묻기:** 동기 handler는 `ctx.ask_choice(question, choices)`로 Telegram/Discord/Slack에서는 버튼, 그 밖의 messaging에서는 번호 목록, CLI/TUI/Desktop에서는 clarify picker를 띄웁니다. 반환값은 고른 값이고, 취소, 잘못된 입력, timeout, 또는 물어볼 수 없는 상황(hook, cron, async handler)에서는 `None`입니다. choice는 문자열이거나 `{"value", "label", "description"}`입니다.

명령이나 hook에서 tool을 호출하려면 `ctx.dispatch_tool(name, args)`를 씁니다. 부모 context, approval, redaction, budget이 그대로 유지됩니다. `ctx.profile_name`은 어느 프로세스에서나 현재 profile을 알려 주므로, gateway와 Kanban worker에서 `None`인 `_cli_ref`보다 이 값을 씁니다.

바뀌지 않는 데이터는 `Path(__file__).parent / "data" / "file.json"` 기준으로 읽습니다. `skills/<name>/SKILL.md`는 `ctx.register_skill`로 등록하며, skill은 읽기 전용이고 `plugin:skill` 이름 공간을 쓰며 chat에서는 `/plugin:skill`로 호출합니다. `ctx.get_config`와 `ctx.set_config`는 `plugins.entries.<id>.settings` 아래의 사용자 노출 설정에만 쓰고, `config_schema`에 선언해 Desktop이 form을 그리게 합니다. 저장할 때마다 `plugin.<id>.settings.changed`가 broadcast됩니다. 업데이트 뒤에도 남아야 하는 런타임 데이터는 `ctx.state`(profile 범위, 원자적 교체, 플러그인당 10 MiB) 또는 `plugin_data_dir()`/`plugin_db()`를 씁니다. 설치 디렉터리에 상태나 secret을 쓰지 않습니다.

## Doctor, 디버깅, 배포, 호환성

```bash
hermes plugins doctor . --ci          # 탐색, import, register, registry 검사
hermes plugins validate . --install-deps   # catalog CI와 같은 검사를 로컬에서
HERMES_PLUGINS_DEBUG=1 hermes plugins list
hermes logs --level WARNING
```

Doctor는 임시 `HERMES_HOME`을 쓰고 등록 상태를 되돌리며, 등록 중에는 직접 Python socket 생성을 막습니다. 그래도 코드를 프로세스 안에서 import하므로 **sandbox가 아니며**, 신뢰하는 코드에만 실행합니다.

디렉터리 플러그인은 독립 저장소에 두고 되도록 변경 불가능한 커밋으로 설치합니다. pip 패키지는 entry point를 씁니다.

```toml
[project.entry-points."hermes_agent.plugins"]
calculator = "hermes_calculator:register"

[project.entry-points."hermes_agent.plugin_capabilities"]
"calculator.tools.override" = "hermes_calculator:register"
```

지원하는 Hermes 버전, 요청하는 capability, 환경 변수, 데이터 보존, 네트워크 endpoint, 업그레이드 방법을 문서에 적습니다.

**호환성 사실:** 계약은 API 번호가 아니라 동작을 기준으로 합니다. `PluginContext` 메서드는 추가만 되고, 새 매개변수는 선택적이며 keyword 전용을 권장합니다. hook payload는 keyword 필드로 늘어나고, 모르는 매니페스트 필드는 무시되며, provider interface는 기본 구현을 더합니다. 저장한 상태와 재개 데이터는 계속 읽히거나 명시적 이전 경로를 가져야 합니다. 문서화된 동작은 대체 수단과 이전 안내, 프로세스당 한 번의 제거 예정 릴리스 경고, 최소 두 번의 후속 minor 릴리스 지원, 구 경로와 대체 경로를 모두 덮는 fixture를 갖춘 경우에만 제거할 수 있습니다.

**사실 — 실제 제거 사례:** 2026년 9월 모듈 분리 때 내부 import 경로를 유지하던 호환 계층이 2026-09-14에 만료되어 삭제됐습니다. 아직 옛 경로를 import하는 플러그인은 이제 `ImportError`로 load에 실패하며 그 사유가 표시됩니다. 이름을 정의한 모듈에서 import하거나, 더 나은 방법으로 `ctx`와 문서화된 ABC를 씁니다.

**사실 — 지원하지 않는 확장 방식:** core 함수, module, `sys.modules`, core dict를 monkeypatch하는 것입니다. catalog가 심사에서 거부하고, `plugins.isolation: host`에서는 이런 플러그인이 아예 실행될 수 없습니다.

**권고:** 문서화된 API를 쓰고, `**kwargs`를 받고, 내부 import를 피하고, 통신 형식과 저장 형식의 버전을 직접 관리하고, 외부 호환 fixture를 유지합니다.
