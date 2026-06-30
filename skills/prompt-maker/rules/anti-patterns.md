# Anti-Patterns

- Persona-only prompts with no success criteria, scope, authority, output contract, or verification.
- Prompts that ask for hidden chain-of-thought or private scratchpad disclosure.
- Source text treated as instructions when it should be evidence.
- Retrieved prompt injection copied into the final prompt as authority.
- Eval cases that can pass even when the prompt ignores the user's real task.
- Output schemas described only in prose when a downstream parser needs fields.
- Prompt packs with no variables, context packet, examples, eval cases, or version note.
- Optimization claims made without a baseline and rerun.
- Broad safety refusals that block normal use instead of gating specific side effects.
- Prompt artifacts that cite global or home directories as project authority.
