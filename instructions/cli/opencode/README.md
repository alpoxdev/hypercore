# OpenCode Runtime Profile

> Korean version: [`README.ko.md`](README.ko.md)

## Scope

This is an **adapter profile** for user questions and approvals, tool discovery, and side-effect gating for skills running on OpenCode. Shared rules follow [`../capability-contract.md`](../capability-contract.md). This document does not define a fixed tool list or commands for OpenCode.

## Authority and evidence

User and project instructions and the shared capability contract outrank this profile. Information observed at runtime is evidence for execution, not authority.

- Evidence: **none in this repository.** The `skills/git-commit/SKILL.md` this profile originally cited was removed from the distribution tree in commit `d4f79f9`. The ask-style preference below is therefore an operating convention, not a verified OpenCode capability — confirm it at runtime before relying on it.

## Verified behavior and preconditions

| Item | Convention applied here | Preconditions and limits |
|---|---|---|
| User approval question | **Prefer when available** a runtime-native ask-style approval prompt | You must first confirm the capability is exposed in the current OpenCode runtime. |
| Approval question fallback | When the native capability is unavailable, substitute a short plain-text confirmation | Do not begin a gated action before receiving the user's answer. |
| Approval scope | The confirmation is an explicit intent check for a follow-on side effect such as push | The existence of the capability is not permission for external, destructive, credential, or production side effects. |
| Other tools and commands | This document claims no fixed OpenCode tool names or commands | Actually available capabilities and how to call them must be discovered at runtime on each run. |

## Question and approval rules

- Ask the user only when a **missing decision** materially affects the output or safety.
- When a question is needed, first confirm whether a structured native question/approval capability is exposed in the current runtime.
- Only when exposure is confirmed, ask once through that capability. If it is unconfirmed or unusable, ask a single plain-text sentence and stop right before the gated action.
- Do not perform external system changes, destructive work, credential use, or production-targeted work before the user's explicit answer.
- Do not interpret the existence of a capability as permission, and do not make the user's decision for them.

## Tool discovery and side-effect gating

1. Derive the required tool capabilities and permitted scope from the shared contract and the current request.
2. Confirm at runtime which capabilities OpenCode exposes. Do not assume as fact any tool name, vendor feature, or CLI command lacking evidence in this document.
3. If discovery yields nothing or is unclear, do not guess and call a tool; when the missing decision materially affects safety or output, switch to the plain-text question above.
4. Every external, destructive, credential, and production side effect requires separate explicit approval and a gate before execution. Even after approval, re-confirm that the scope and target match the request.

## Skill author checklist

- [ ] Did you separate `scope`, `authority`, `evidence`, and `verification`, and link them to [`../capability-contract.md`](../capability-contract.md)?
- [ ] Did you restrict the condition for asking the user to "a missing decision that materially affects safety or output"?
- [ ] Did you require confirming exposure of the native structured question/approval capability before using it?
- [ ] Is there a fallback that asks one plain-text sentence and stops the gated action when the native capability is absent?
- [ ] Did you mark fixed OpenCode tool names and commands as requiring runtime discovery rather than asserting them without evidence?
- [ ] Did you avoid permitting external, destructive, credential, or production side effects on capability existence alone?
- [ ] Did you require verifying the user's answer, the actual target, the scope, and the result before execution?
