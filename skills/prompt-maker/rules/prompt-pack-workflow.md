# Prompt Pack Workflow

## Draft

1. Confirm the prompt will be reused.
2. Identify the operator, target model or agent, task class, and side-effect boundary.
3. Fill the prompt contract before polishing prose.
4. Add variables and context packet slots before adding examples.
5. Define output schema before writing style guidance.
6. Add eval cases before optimization claims.

## Refactor

1. Preserve current observable behavior unless the user requested a behavior change.
2. Split authority, scope, evidence, and output requirements into separate sections.
3. Delete duplicate or decorative wording.
4. Replace vague quality words with success criteria and verification checks.
5. Add a version note that states what changed and why.

## Optimize

Record a baseline case, diagnose failures, patch the smallest instruction surface, rerun the same cases, and keep only changes that improve the target behavior without breaking safety, source, or schema constraints.
