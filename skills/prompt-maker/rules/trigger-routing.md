# Trigger Routing

Use `prompt-maker` only when the requested deliverable is a reusable prompt artifact.

## Use

- Reusable role prompts, system prompts, developer prompts, and agent prompts.
- Prompt packs that include variables, context packet, examples, output schema, eval cases, and version notes.
- Prompt templates meant for repeated use by humans, agents, scripts, or harnesses.
- Eval fixtures that check prompt behavior, source handling, safety, schema adherence, or regressions.
- Refactors that make an existing prompt clearer, safer, more testable, or more reusable.

## Do Not Use

- Generic documentation, runbooks, release notes, or research reports.
- Skill-folder creation unless the prompt artifact itself is the slice being edited.
- One-off answers where no reusable prompt is requested.
- Code implementation, deployment, git operations, or production operations.

## Boundary

If a request can be read as either a prompt artifact or general documentation, choose `prompt-maker` only when the output will be reused as an instruction contract or eval target. Otherwise route to the documentation or implementation workflow.
