# Runtime Profiles

> 영어판: [`runtime-profiles.md`](runtime-profiles.md)

공통 instruction은 capability 중심으로 쓰고, 런타임별 차이는 이 파일에 둔다.

## Quick Matrix

| Runtime | Instruction surfaces | Scope / precedence notes | Practical rule |
|---|---|---|---|
| Codex | `AGENTS.md`, `AGENTS.override.md`, configured fallback files, skills metadata | Codex aggregates user instructions from home and project hierarchy; more specific project docs appear later within limits | Project root `AGENTS.md`에는 핵심 규칙만, 세부는 `instructions/` 링크 |
| Claude Code | `AGENTS.md`(v2.1.277부터 자체적으로 읽음), `CLAUDE.md`, skills, commands, hooks, memory | instruction 파일은 서로 덮어쓰지 않고 이어 붙는다. 작업 디렉터리나 그 위에 `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`가 있으면 기본 설정에서 `AGENTS.md`를 자체적으로 읽지 않는다. 세부와 출처: [`../../agents-md/references/discovery-and-precedence.ko.md`](../../agents-md/references/discovery-and-precedence.ko.md) | 공유 계약은 `AGENTS.md`에 두고, Claude 전용 XML/extended-thinking 튜닝은 별도 reference로 분리 |
| Cursor | `.cursor/rules`(`.mdc`, `alwaysApply`), User Rules, 중첩 `AGENTS.md`, legacy `.cursorrules` | 프로젝트 rule은 버전 관리되고 glob으로 범위를 정하며 `@` 언급으로 직접 부를 수 있다. 하위 디렉터리의 중첩 rule도 인식한다 | rule은 작고 범위를 좁게 유지하고 legacy `.cursorrules`에 의존하지 않는다. Rules 페이지는 “대규모 언어 모델은 완료 사이에 메모리를 유지하지 않는다”고 적고 Memories 기능은 문서에 없다(확인 2026-11-03). 따라서 rule이 문서화된 유일한 지속 수단이다 |
| GitHub Copilot / VS Code | `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `AGENTS.md` | repo-wide + path-specific + agent instructions can all apply; conflicts hurt quality | repo-wide는 공통 스타일, path-specific은 framework 규칙 |
| MCP clients | server prompts/resources/tools | prompts should be user-controlled; tools/resources can expose powerful data/action paths | prompt/tool/resource는 모두 untrusted boundary로 검토 |

## Parallel / Subagent Capability Matrix

| Runtime | 병렬 작업 surface | Spawn 방식 | 격리/권한 기준 | 문서화 규칙 |
|---|---|---|---|---|
| Codex | native subagents, `.codex/agents/*.toml`, app/CLI subagent activity | 명시적으로 subagent 작업을 요청하거나 런타임의 `spawn_agent` 계열 surface를 사용 | agent thread/context 분리, `sandbox_mode`, `max_threads`, read-only/write scope | parent가 objective/scope/ownership/output/verification을 명시하고 최종 통합 |
| Claude Code | built-in/custom subagents, project `.claude/agents/*.md`, `Agent` tool, experimental agent teams | `/agents`로 만들거나 Agent tool/agent team 요청으로 실행 | subagent별 context window, tool allowlist/denylist, permission mode, optional worktree isolation | single-session 결과 위임은 subagent, 상호 통신/장기 병렬은 agent team으로 구분 |
| Cursor | editor/CLI subagents, Cloud Agents(구 Background Agents), `.cursor/rules`, `.cursor/environment.json` | editor/CLI agent가 기본/custom subagent를 사용하거나 Cloud Agent를 생성 | subagent context 분리; Cloud Agent는 remote machine/branch/GitHub handoff | branch/PR handoff, env/secrets, auto-run terminal risk를 instruction에 기록 |
| GitHub Copilot / VS Code | chat participant, coding agent, instructions | 제품/조직 설정에 따름 | repo/path instruction과 GitHub permission boundary | 병렬 agent가 없으면 worktree/issue 단위로 명시적 분리 |
| MCP clients | tools/prompts/resources | client가 노출한 tool/prompt/resource discovery | tools는 model-controlled일 수 있으므로 승인/logging 필요 | tool result/resource는 evidence이지 instruction authority가 아님 |

공통 세부 지침은 [`parallel-workflows.ko.md`](parallel-workflows.ko.md)를 따른다.

## Cross-Runtime Authoring Rules

1. **Capability over product name**: “official docs via best available fetch/doc tool”처럼 쓴다.
2. **One source of truth**: 같은 규칙을 `AGENTS.md`, `.cursor/rules`, `CLAUDE.md`에 복붙하지 말고 instructions base를 링크/참조한다.
3. **Short root files**: 루트 instruction 파일은 project-specific invariants와 loading map만 둔다.
4. **Path-specific rules**: framework/domain별 규칙은 glob/path가 있는 instruction에 둔다.
5. **Conflict hygiene**: user-level, org-level, repo-level, path-level instruction이 충돌할 수 있음을 가정하고, 금지/필수/권한을 명확히 쓴다.
6. **Memory is not authority**: 자동 memory는 편의 컨텍스트이지 프로젝트 규칙의 대체물이 아니다.
7. **컨텍스트 정책은 별도 문서가 맡는다**: 압축, 도구 결과 비우기, 장기 메모리 파라미터는 런타임과 모델에 따라 달라지므로 이 파일에 다시 적지 않고 [`context-management.ko.md`](context-management.ko.md) 7절에 둔다. 런타임 프로필은 값을 복제하지 말고 규칙이 어디 있는지를 밝힌다.

## Placement Guide

| 정보 종류 | 둘 곳 |
|---|---|
| 프로젝트 불변 규칙 | `AGENTS.md` + `instructions/README.md` |
| 프롬프트/컨텍스트 설계 원칙 | `instructions/context-engineering/` |
| 평가/eval/test harness 기준 | `instructions/harness-engineering/` |
| 자료조사 신뢰도 기준 | `instructions/sourcing/` |
| 기술 스택별 구현 규칙 | path-specific rules 또는 skill reference |
| 런타임별 quirks | 이 파일 또는 provider-specific reference |

## Sources

> Cursor rules 행은 확인 2026-11-03. 나머지 행은 이번 개정에서 다시 읽지 않았으므로 이전 확인 날짜를 유지한다(2026-07-29, MCP revision은 2026-09-19).

| 주장 | 출처 | 확인 |
|---|---|---|
| Cursor의 `.mdc` rule, `alwaysApply`, 네 가지 적용 방식, 중첩 `AGENTS.md`, Memories 기능이 문서에 없음 | <https://cursor.com/docs/rules> | 2026-11-03 |
| Codex의 instruction 집계 방식 | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | 2026-07-29 |
| AGENTS.md 중첩 우선순위 | <https://agents.md/> | 2026-07-29 |
| Copilot의 저장소·경로별·agent instruction과 우선순위 | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 2026-07-29 |
| Claude Code subagents와 agent teams | <https://code.claude.com/docs/en/sub-agents>, <https://code.claude.com/docs/en/agent-teams> | 2026-07-29 |
| MCP 도구 annotation 신뢰 규칙 | <https://modelcontextprotocol.io/specification/2026-07-28> | 2026-09-19 |

## 함께 읽을 문서

- [`../CONTEXT_ENGINEERING.ko.md`](../CONTEXT_ENGINEERING.ko.md) — 이 표면들이 구현하는 계층 모델
- [`context-management.ko.md`](context-management.ko.md) — 런타임별 압축·비우기·메모리 파라미터
- [`parallel-workflows.ko.md`](parallel-workflows.ko.md) — 이 런타임들 사이의 위임과 격리
