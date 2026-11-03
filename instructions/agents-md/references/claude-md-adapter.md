# CLAUDE.md as an Adapter

> Korean version: [`claude-md-adapter.ko.md`](claude-md-adapter.ko.md)

**Purpose**: decide whether a repository needs a `CLAUDE.md` at all, and if so, how to keep it from becoming a second, drifting copy of the shared contract.

The default answer is **one canonical `AGENTS.md`, and a `CLAUDE.md` only for a real Claude-only difference or for sessions that cannot read `AGENTS.md` directly.**

---

## 1. Why the question exists

`AGENTS.md` has broad adoption, and Claude Code reads it directly from v2.1.277 on, so a repository that ships only `AGENTS.md` is no longer invisible to Claude. The question survives for two narrower reasons:

- Under the default **Project instructions** setting, a `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` at or above the working directory makes Claude read the `CLAUDE.md` files instead of `AGENTS.md`.
- Some sessions cannot read `AGENTS.md` at all: a version before v2.1.277, a session where the built-in reader plugin was disabled with `/plugin`, or occasionally the first session after upgrading from v2.1.276 or earlier. The old provider and telemetry caveat is historical — "Before v2.1.281, some sessions, such as those on Amazon Bedrock or with telemetry disabled, read CLAUDE.md files only. On those versions, update Claude Code."

For those cases the documented fallback is the import, and a repository that ships both files still risks the two drifting apart. Both failure modes are worse than picking a strategy deliberately. See [`discovery-and-precedence.md`](discovery-and-precedence.md) §2 for the full behavior.

---

## 2. Choosing a strategy

| Strategy | How | Use when |
|---|---|---|
| **A. Native only** | No `CLAUDE.md` at all — Claude Code reads `AGENTS.md` directly (v2.1.277+) | The default. Choose it when no real Claude-only difference exists and every session you must support can read `AGENTS.md` |
| **B. Symlink** | `ln -s AGENTS.md CLAUDE.md` | Same as A, but some supported session needs the `CLAUDE.md` fallback. Note that the Edit and Write tools refuse to write through a symlink, and a Windows checkout turns a committed symlink into a plain text file unless `core.symlinks` is enabled |
| **C. Import stub** | `CLAUDE.md` contains `@AGENTS.md` and nothing else | Same as B, but the repo cannot rely on symlinks (Windows checkouts, tooling that dereferences poorly) |
| **D. Thin adapter** | `CLAUDE.md` imports `@AGENTS.md`, then adds only verified Claude-specific rules | Real Claude-only differences exist: skills, hooks, permission modes, plugin metadata |
| **E. Separate files** | Two independently maintained files | Almost never. Choose only with an explicit reason, and expect drift |

Strategy E is a maintenance liability. Every shared rule now has two homes and no mechanism keeps them equal.

> The native path is the default because Claude Code reads `AGENTS.md` on its own. An existing symlink or import is not wrong — it never causes a double read — but it is now a fallback for sessions that cannot read `AGENTS.md` directly, not a requirement.

### This repository

`hypercore` currently runs **A**: `AGENTS.md` is tracked even though `.gitignore` lines 43–45 list it beside `CLAUDE.md` under `# Local agent instructions`, because it was added before that ignore rule; `git ls-files AGENTS.md` returns `AGENTS.md`, which is how that was verified. No `CLAUDE.md` exists (it is gitignored, untracked, and absent as of 2026-11-03), so Claude Code reads the canonical file natively with nothing to maintain in parallel.

If a genuinely Claude-only rule appears, the move is **D**, not E: a `CLAUDE.md` that starts with `@AGENTS.md` and adds only that rule below the import. Two facts shape the choice. The import guarantees the contract loads but pays for it every session, where a prose pointer costs nothing up front yet stays advisory, so the agent may proceed without reading the canonical file. And because `CLAUDE.md` is gitignored here while `AGENTS.md` is version-controlled, `CLAUDE.md` would be a *local clone adapter*, not a shared artifact — which makes "shared contract stays canonical in `AGENTS.md`" a correctness rule, not a style preference: anything written only into `CLAUDE.md` does not exist for anyone else and cannot be reviewed.

---

## 3. What belongs in the adapter

Only content that is **false or absent for other runtimes**:

- Claude Code skills, and which one to load for a given task.
- Hooks, and which behavior they enforce deterministically.
- Permission modes, plugin metadata paths, and MCP servers actually exposed in this repository.
- Explicit statements about what *not* to read (for example, global `~/.claude/` configuration that must not be used as project evidence).
- Import wiring: the `@AGENTS.md` line and any `@path` references.

What must **not** go there:

- Any rule that would also be true for Codex, Cursor, or Copilot. That belongs in `AGENTS.md`.
- A restatement, summary, or "quick version" of the shared contract. Duplication is the failure mode this file exists to avoid.
- Relaxations of shared rules. An adapter adds runtime detail; it does not weaken the canonical contract.

Current Anthropic guidance names repetition across surfaces as an anti-pattern in its own right: the same instruction restated in a system prompt, a skill, and an instruction file produces conflict rather than emphasis.

---

## 4. Import mechanics

`CLAUDE.md` can pull in other files:

> "CLAUDE.md files can import additional files using `@path/to/import` syntax."

> "Both relative and absolute paths are allowed. Relative paths resolve relative to the file containing the import, not the working directory."

> "Imported files can recursively import other files, with a maximum depth of four hops."

Practical consequences:

- **Four hops is a real ceiling.** A chain like `CLAUDE.md` → `AGENTS.md` → an instructions index → an area doc → a reference doc reaches it. Import leaf documents directly rather than building deep chains.
- **Relative paths resolve from the importing file.** Moving a file breaks its imports even though the target still exists.
- **Imports are eager.** An imported file costs context at session start exactly like inlined text. Import only what is needed every session; link (do not import) everything else so the agent reads it on demand.

That last point is the practical dividing line: `@import` for always-needed material, plain markdown link for read-when-relevant material.

---

## 5. Sizing

> "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."

An adapter should be far under that — typically a stub plus a short runtime section. If it approaches 200 lines, the content almost certainly belongs in `AGENTS.md` or in a skill.

Anthropic's stated escape hatch for growth is not a longer file:

> "Keep CLAUDE.md under 200 lines. Move reference material to skills, which load on demand."

The 200-line figure is guidance, not truncation. The actual limit is much higher and binary: a file that loads at launch is read whole "as long as the file is 4 MiB or smaller", and "Claude Code skips a file over 4 MiB and loads none of it". Exceeding 200 lines therefore costs adherence silently rather than dropping content visibly, which is why nothing warns you; `/doctor` will propose cuts for a checked-in file.

---

## 6. Local and personal content

`CLAUDE.local.md` is documented for "personal project-specific preferences" and is meant to be gitignored. Use it for sandbox URLs, preferred test data, and individual workflow habits.

Never put personal preference into the shared file, and never put shared project rules into the local one. GitHub's guidance independently reaches the same boundary from the other direction, listing response-style and verbosity preferences among things instructions should not contain.

Separately, Claude Code maintains automatic per-project memory at `~/.claude/projects/<project>/memory/`. This is a distinct mechanism from `CLAUDE.md` and is not a place to author shared project rules — it is not present in another clone.

---

## 7. Verification

- [ ] The strategy (A–E) is a deliberate choice, not an accident.
- [ ] If a `CLAUDE.md` exists, it resolves — the symlink target or `@AGENTS.md` import actually exists. Under the native strategy there is nothing to resolve.
- [ ] No rule appears in both `AGENTS.md` and `CLAUDE.md`.
- [ ] Every rule in `CLAUDE.md` is genuinely Claude-specific and verified against the current runtime.
- [ ] The adapter does not weaken any shared safety or authority rule.
- [ ] Import chains stay within four hops; relative paths resolve from the importing file.
- [ ] Only always-needed material is imported; the rest is linked.
- [ ] Personal preferences live in `CLAUDE.local.md`, gitignored.
- [ ] If `CLAUDE.md` is gitignored, no shared contract content exists only there.
- [ ] Claimed skills, hooks, MCP servers, and plugin paths were confirmed present in this repository.

---

## Sources

| Source | URL | Checked |
|---|---|---|
| Claude Code memory | <https://code.claude.com/docs/en/memory> | 2026-11-03 |
| Claude Code features overview | <https://code.claude.com/docs/en/features-overview> | 2026-11-03 |
| Claude 5 context engineering | <https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/> | 2026-11-03 |
| AGENTS.md standard | <https://agents.md/> | 2026-11-03 |
| GitHub Copilot custom instructions | <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions> | 2026-11-03 |

## Related documents

- [`../AGENTS_MD.md`](../AGENTS_MD.md)
- [`discovery-and-precedence.md`](discovery-and-precedence.md)
- [`content-contract.md`](content-contract.md)
- [`../../context-engineering/references/runtime-profiles.md`](../../context-engineering/references/runtime-profiles.md)
