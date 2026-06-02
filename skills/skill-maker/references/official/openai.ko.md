# OpenAI 공식 참고 자료

## 갱신 정책

- last_verified_at: 2026-06-02
- refresh_when:
  - Codex skills guidance가 실질적으로 바뀜
  - AGENTS.md/custom instruction guidance가 실질적으로 바뀜
  - skill evaluation guidance가 validation rule에 영향을 줄 만큼 바뀜
  - agent safety 또는 tool-calling guidance가 skill safety gate에 영향을 줄 만큼 바뀜
- supports_rules:
  - `rules/trigger-design.ko.md`
  - `rules/progressive-disclosure.ko.md`
  - `rules/resource-placement.ko.md`
  - `rules/context-and-harness-alignment.ko.md`
  - `rules/validation-and-iteration.ko.md`

## Codex Agent Skills

- source_url: https://developers.openai.com/codex/skills
- last_verified_at: 2026-06-02
- applies_to: skill package shape, `name`/`description`, resources, scripts, progressive disclosure
- summary: Codex skills는 instructions, resources, optional scripts를 패키징해 Codex가 reusable workflow를 안정적으로 따르게 합니다.
- implication_for_skill_maker: skill을 독립 prompt text가 아니라 trigger 가능한 execution package로 다룹니다.

## Evaluating Skills

- source_url: https://developers.openai.com/blog/eval-skills
- last_verified_at: 2026-06-02
- applies_to: trigger tests, process checks, output style checks, deterministic graders
- summary: Skill 품질은 trigger behavior, process adherence, output shape, efficiency에 대한 작은 prompt set과 observable checks로 평가해야 합니다.
- implication_for_skill_maker: prose-only review 대신 trigger smoke test와 validation note를 요구합니다.

## AGENTS.md Guide

- source_url: https://developers.openai.com/codex/guides/agents-md
- last_verified_at: 2026-06-02
- applies_to: project instruction discovery, scope, precedence, local guidance layering
- summary: Repository instructions는 project 안에서 agent가 따라야 하는 scoped guidance를 정의합니다.
- implication_for_skill_maker: 로컬 `instructions/`와 project rules가 generic provider examples보다 우선합니다.

## Prompt Engineering

- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-06-02
- applies_to: clear instructions, examples, structured context, explicit output formats
- summary: 명확한 지시, 예시, 명시적 형식 지정은 followability를 높입니다.
- implication_for_skill_maker: Core skill instructions는 explicit, example-backed, contract-shaped여야 합니다.

## Evaluation Best Practices

- source_url: https://developers.openai.com/api/docs/guides/evaluation-best-practices
- last_verified_at: 2026-06-02
- applies_to: AI system variability, eval-backed iteration
- summary: Model behavior는 변동성이 있으므로 production-facing behavior는 intuition이 아니라 evaluation으로 확인해야 합니다.
- implication_for_skill_maker: 중요한 skill 변경은 최소한 작은 eval 또는 smoke set을 포함해야 합니다.

## Safety in Building Agents

- source_url: https://developers.openai.com/api/docs/guides/agent-builder-safety
- last_verified_at: 2026-06-02
- applies_to: prompt injection, tool calling, MCP/tool safety, side-effect gates
- summary: Agent systems는 untrusted input, tools, permissions, side effects 주변의 safeguard가 필요합니다.
- implication_for_skill_maker: Network, credentials, destructive actions, production side effects를 언급하는 skill은 해당 행동을 명시적으로 gate해야 합니다.
