# Trigger Routing

요청 산출물이 재사용 가능한 prompt artifact일 때만 `prompt-maker`를 사용한다.

## Use

- 재사용 가능한 role prompts, system prompts, developer prompts, agent prompts.
- variables, context packet, examples, output schema, eval cases, version notes가 있는 prompt packs.
- 사람, agent, script, harness가 반복 사용할 prompt templates.
- prompt behavior, source handling, safety, schema adherence, regression을 확인하는 eval fixtures.
- 기존 prompt를 더 명확하고 안전하며 테스트 가능하고 재사용 가능하게 만드는 refactor.

## Do Not Use

- 일반 documentation, runbooks, release notes, research reports.
- prompt artifact 자체가 편집 범위가 아닌 skill-folder creation.
- reusable prompt가 요청되지 않은 one-off answers.
- code implementation, deployment, git operations, production operations.

## Boundary

요청이 prompt artifact와 일반 documentation 양쪽으로 해석될 수 있으면, output이 instruction contract 또는 eval target으로 재사용될 때만 `prompt-maker`를 선택한다. 그렇지 않으면 documentation 또는 implementation workflow로 라우팅한다.
