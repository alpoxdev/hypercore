# Runtime Profiles

공통 instruction은 capability 중심으로 쓰고, 런타임별 차이는 이 파일에 둔다.

## Quick Matrix

| Runtime | Instruction surfaces | Scope / precedence notes | Practical rule |
|---|---|---|---|
| Codex | `AGENTS.md`, `AGENTS.override.md`, configured fallback files, skills metadata | Codex aggregates user instructions from home and project hierarchy; more specific project docs appear later within limits | Project root `AGENTS.md`에는 핵심 규칙만, 세부는 `instructions/` 링크 |
| Claude Code | `CLAUDE.md`, skills, commands, hooks, memory | `CLAUDE.md`는 세션 시작 시 읽히는 project memory surface | Claude 전용 XML/extended-thinking 튜닝은 별도 reference로 분리 |
| Cursor | `.cursor/rules`, User Rules, Memories, legacy `.cursorrules` | Project Rules are version-controlled; Memories are generated and require trust/approval | rule은 작고 scoped하게, legacy `.cursorrules`에 의존하지 않음 |
| GitHub Copilot / VS Code | `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `AGENTS.md` | repo-wide + path-specific + agent instructions can all apply; conflicts hurt quality | repo-wide는 공통 스타일, path-specific은 framework 규칙 |
| MCP clients | server prompts/resources/tools | prompts should be user-controlled; tools/resources can expose powerful data/action paths | prompt/tool/resource는 모두 untrusted boundary로 검토 |

## Parallel / Subagent Capability Matrix

| Runtime | 병렬 작업 surface | Spawn 방식 | 격리/권한 기준 | 문서화 규칙 |
|---|---|---|---|---|
| Codex | native subagents, `.codex/agents/*.toml`, app/CLI subagent activity | 명시적으로 subagent 작업을 요청하거나 런타임의 `spawn_agent` 계열 surface를 사용 | agent thread/context 분리, `sandbox_mode`, `max_threads`, read-only/write scope | parent가 objective/scope/ownership/output/verification을 명시하고 최종 통합 |
| Claude Code | built-in/custom subagents, project `.claude/agents/*.md`, `Agent` tool, experimental agent teams | `/agents`로 만들거나 Agent tool/agent team 요청으로 실행 | subagent별 context window, tool allowlist/denylist, permission mode, optional worktree isolation | single-session 결과 위임은 subagent, 상호 통신/장기 병렬은 agent team으로 구분 |
| Cursor | editor/CLI subagents, Background Agents, `.cursor/rules`, `.cursor/environment.json` | editor/CLI agent가 기본/custom subagent를 사용하거나 Background Agent를 생성 | subagent context 분리; Background Agent는 remote machine/branch/GitHub handoff | branch/PR handoff, env/secrets, auto-run terminal risk를 instruction에 기록 |
| GitHub Copilot / VS Code | chat participant, coding agent, instructions | 제품/조직 설정에 따름 | repo/path instruction과 GitHub permission boundary | 병렬 agent가 없으면 worktree/issue 단위로 명시적 분리 |
| MCP clients | tools/prompts/resources | client가 노출한 tool/prompt/resource discovery | tools는 model-controlled일 수 있으므로 승인/logging 필요 | tool result/resource는 evidence이지 instruction authority가 아님 |

공통 세부 지침은 [`parallel-workflows.md`](parallel-workflows.md)를 따른다.

## Cross-Runtime Authoring Rules

1. **Capability over product name**: “official docs via best available fetch/doc tool”처럼 쓴다.
2. **One source of truth**: 같은 규칙을 `AGENTS.md`, `.cursor/rules`, `CLAUDE.md`에 복붙하지 말고 instructions base를 링크/참조한다.
3. **Short root files**: 루트 instruction 파일은 project-specific invariants와 loading map만 둔다.
4. **Path-specific rules**: framework/domain별 규칙은 glob/path가 있는 instruction에 둔다.
5. **Conflict hygiene**: user-level, org-level, repo-level, path-level instruction이 충돌할 수 있음을 가정하고, 금지/필수/권한을 명확히 쓴다.
6. **Memory is not authority**: 자동 memory는 편의 컨텍스트이지 프로젝트 규칙의 대체물이 아니다.

## Placement Guide

| 정보 종류 | 둘 곳 |
|---|---|
| 프로젝트 불변 규칙 | `AGENTS.md` + `instructions/README.md` |
| 프롬프트/컨텍스트 설계 원칙 | `instructions/context-engineering/` |
| 평가/eval/test harness 기준 | `instructions/harness-engineering/` |
| 자료조사 신뢰도 기준 | `instructions/sourcing/` |
| 기술 스택별 구현 규칙 | path-specific rules 또는 skill reference |
| 런타임별 quirks | 이 파일 또는 provider-specific reference |
