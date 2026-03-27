---
name: qa
description: Analyze non-developer stakeholder requests (clients, executives, PMs) by searching the codebase, presenting technical interpretation candidates with risks, then implementing after user feedback. Use when relaying a vague or non-technical change request that needs interpretation before execution.
compatibility: Use in environments with code exploration (Read/Grep/Glob), editing (Edit/Write), and validation commands (Bash).
---

# QA — Stakeholder Request Analyzer

> Translate non-developer change requests into precise technical work — analyze first, confirm with the developer, then execute.

<request_routing>

## Positive triggers

- A relayed stakeholder request in non-technical language: "고객사에서 이렇게 해달래", "경영진이 이거 바꿔달라고 했어", "The client wants this changed".
- A pasted message from a non-developer (email, Slack, Jira ticket): "PM이 이거 보냈는데 분석해줘", "Here's what the client sent".
- A vague change request that needs technical interpretation before implementation: "이 요청 분석 좀 해줘", "What would this request actually mean for our codebase?".
- An ambiguous feature or UI change request from a business stakeholder.

## Out-of-scope

- Clear technical tasks with a specific deliverable. Route to `execute`.
- Bug reports with error messages or failing symptoms. Route to `bug-fix`.
- Repository-wide build or CI failures. Route to `build-fix`.
- Architecture decisions or strategic planning. Route to `plan`.

## Boundary cases

- If the stakeholder request is already technically precise, still run analysis to surface risks and side effects — then fast-track to execution.
- If the request is actually a bug disguised as a feature request, own the interpretation phase and note it as a finding.
- If scope is too large for a single implementation pass, surface this and recommend breaking it down or routing to `plan`.

</request_routing>

<argument_validation>

If ARGUMENT is missing or has no actionable request, ask:

```text
What did the stakeholder request?
- Paste the original message (email, Slack, ticket, verbal summary)
- Who requested it (client, executive, PM, etc.)
- Any additional context or constraints you know
```

One round of clarification maximum. The point is to work with imperfect information — that's what this skill is for.

</argument_validation>

<mandatory_reasoning>

## Mandatory Sequential Thinking

Always run `sequential-thinking` before presenting candidates. Minimum 5 thoughts:

1. Parse the non-technical language — what is the stakeholder actually asking for?
2. Identify ambiguities — what could this mean in multiple ways?
3. Map to codebase — which files, components, or systems are affected?
4. Assess risks — what could break, what are the side effects?
5. Formulate interpretation candidates — distinct technical readings of the request.

For complex or multi-part requests, use 7+ thoughts.

</mandatory_reasoning>

<workflow>

## Phase 1 — Analyze & Present

| Step | Task | Tool |
|------|------|------|
| 1 | Validate input — identify the stakeholder request | - |
| 2 | Parse and analyze with sequential-thinking | sequential-thinking |
| 3 | Search codebase for affected areas | Read/Grep/Glob |
| 4 | Present interpretation candidates + issues | - |
| 5 | Wait for user feedback | - |

## Phase 2 — Execute

| Step | Task | Tool |
|------|------|------|
| 6 | Confirm scope based on user feedback | - |
| 7 | Implement the confirmed interpretation | Edit/Write |
| 8 | Run validation (typecheck/test/build) | Bash |
| 9 | Report outcome and changed files | - |

Do not skip Phase 1. Do not implement before user feedback.

</workflow>

<candidate_presentation>

Present findings in this format:

```markdown
## Stakeholder Request Analysis

**Original request**: [paste or summarize the raw request]
**Requested by**: [client/executive/PM/etc.]

### Codebase Impact
- **Affected areas**: [list files, components, or systems]
- **Scope estimate**: [small / medium / large]

### Interpretation Candidates

#### Candidate 1: [technical summary] ⭐ Recommended
- **What this means**: [detailed technical description]
- **Changes needed**: [specific files and modifications]
- **Risks/Side effects**: [what could break or be affected]

#### Candidate 2: [technical summary]
- **What this means**: [detailed technical description]
- **Changes needed**: [specific files and modifications]
- **Risks/Side effects**: [what could break or be affected]

#### Candidate 3: [technical summary] (if applicable)
- ...

### Potential Issues
- [Issue 1: something the stakeholder may not have considered]
- [Issue 2: technical constraint or limitation]
- [Issue 3: ambiguity that needs stakeholder clarification]

### Questions for Stakeholder (if any)
- [Question that would resolve ambiguity before implementation]

---
Which interpretation is correct? Any adjustments needed?
```

Rules for candidates:
- Always present at least 2 candidates unless the request is completely unambiguous.
- Mark the most likely interpretation with ⭐ Recommended.
- Each candidate must reference specific files and changes.
- Issues section must include things the stakeholder likely didn't consider.

</candidate_presentation>

<execution_rules>

## After user feedback

- Implement only the confirmed interpretation.
- If the user provides corrections or additional context, adjust scope accordingly.
- Keep changes scoped to what was confirmed — do not add unrequested improvements.
- Run targeted validation after changes.
- If validation fails, fix within scope.

## Reporting

After execution, report:

```markdown
## Done

**Request**: [original stakeholder request]
**Interpretation applied**: [which candidate, with any adjustments]
**Changes**: [list of changed files]
**Validation**: [what was verified and result]
**Notes for stakeholder**: [anything they should know about what was done]
```

</execution_rules>

<validation>

Execution checklist:

- [ ] ARGUMENT validated — stakeholder request identified
- [ ] sequential-thinking completed (5+ thoughts)
- [ ] Codebase searched for affected areas
- [ ] Interpretation candidates presented (2+ unless unambiguous)
- [ ] Potential issues and risks listed
- [ ] User feedback received before implementation
- [ ] Implementation matches confirmed interpretation
- [ ] Validation executed (typecheck/test/build)
- [ ] Outcome reported with changed files

Forbidden:

- [ ] Implementing before user feedback (this is not `execute`)
- [ ] Presenting only one candidate without justification
- [ ] Ignoring potential issues or risks
- [ ] Expanding scope beyond confirmed interpretation
- [ ] Claiming completion without running validation

</validation>
