# Discovery and Precedence

> Korean version: [`discovery-and-precedence.ko.md`](discovery-and-precedence.ko.md)

**Purpose**: record how each runtime actually finds and combines instruction files, so nested files are written to be correct under every implementation rather than under the one you happen to use.

All facts below are vendor statements about their own products, verified 2026-11-03. Re-verify quarterly — this is the fastest-moving material in this base.

---

## 1. The "closest file wins" trap

The `AGENTS.md` site states the rule simply: "Place another AGENTS.md inside each package. Agents automatically read the nearest file in the directory tree, so the closest one takes precedence and every subproject can ship tailored instructions."

> "The closest AGENTS.md to the edited file wins; explicit user chat prompts override everything."

**Most implementations do not work this way.** They merge, and "closest wins" is achieved only by ordering within a concatenated prompt — the parent is still loaded and still in context.

| Runtime | Actual combining behavior |
|---|---|
| **OpenAI Codex** | Concatenates root-to-leaf; closer files override "because they appear later in the combined prompt" |
| **Claude Code** | "All discovered files are concatenated into context rather than overriding each other". Which files are *discovered* depends on the **Project instructions** setting: under the default `claude-md-or-agents-md`, `AGENTS.md` is read only while no `CLAUDE.md` or `CLAUDE.local.md` exists at or above the working directory, and `claude-md-and-agents-md` reads both (§2) |
| **Cursor** | "Instructions from nested `AGENTS.md` files are combined with parent directories, with more specific instructions taking precedence" |
| **GitHub Copilot** | On GitHub.com Copilot Chat: "the nearest `AGENTS.md` file in the directory tree will take precedence". Copilot's own docs caution that this is surface-specific: "Most surfaces and clients, including Copilot CLI, Visual Studio Code and Visual Studio, combine applicable instruction files without defining a general precedence order" |

### The authoring rule this forces

A nested instruction file must be correct under **both** semantics, because you cannot control which agent reads it. Never rely on the parent being absent: in Codex, Claude Code, and Cursor the root file is still loaded, so a nested file saying "ignore the root's test command" does not remove the root's text — it creates a contradiction the model resolves by position, silently. Never rely on the parent being present either: under Copilot's nearest-wins reading a nested file may be the only one applied, so anything essential for that subtree must be stated there.

**Therefore: write nested files as self-contained deltas.** State the subtree's scope explicitly, and override by *restating the correct rule in full* rather than referring to the parent's rule negatively. In a nested file prefer `Run tests with 'pnpm -C cli test' in this package` over `unlike the root, do not use bun here`.

---

## 2. Claude Code

Source: <https://code.claude.com/docs/en/memory> (page last modified 2026-10-27, checked 2026-11-03)

### AGENTS.md is a first-class instruction file

"Claude Code can read AGENTS.md as your project instructions, so a repository already set up for other coding agents works without adding a CLAUDE.md, an import, or a setting." Reading it directly requires v2.1.277 or later.

| Your repository has | Claude reads |
|---|---|
| An `AGENTS.md`, and no `CLAUDE.md` or `CLAUDE.local.md` in your working directory or above it | Your `AGENTS.md` |
| An `AGENTS.md` and a `CLAUDE.md` or `CLAUDE.local.md` in your working directory or above it | Your `CLAUDE.md` files only |
| A `CLAUDE.md` that already imports `AGENTS.md` | Your `CLAUDE.md`, with `AGENTS.md` included through the import |

Files that **count** for that check, and therefore suppress `AGENTS.md`: a `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` in the working directory or any directory above it. Files that **do not count**, and keep loading alongside `AGENTS.md`: `~/.claude/CLAUDE.md`, an organization's managed `CLAUDE.md`, and `.claude/rules/` files.

### Choosing which instruction files load

`/config` exposes a **Project instructions** setting:

| Value | What Claude reads |
|---|---|
| `claude-md-or-agents-md` | `CLAUDE.md` files, or `AGENTS.md` files when no `CLAUDE.md` or `CLAUDE.local.md` exists in the working directory or above it. **The default** |
| `claude-md-and-agents-md` | Both, each directory's `CLAUDE.md` files first and its `AGENTS.md` after them. An `AGENTS.md` already loaded, for example through an import or a symlink, is skipped rather than read twice |
| `claude-md` | `CLAUDE.md` files only |
| `managed-only` | Only the organization's managed `CLAUDE.md` and auto memory at launch. Project, local, and user `CLAUDE.md` files, `.claude/rules/`, and every `AGENTS.md` are left out; a subdirectory's `CLAUDE.md` and `.claude/rules/` files, and path-scoped rules, still load on demand |

The same value can be set in a settings file under the built-in plugin that reads `AGENTS.md`:

```json
{
  "pluginConfigs": {
    "cc-plugin-agents-md@builtin": { "options": { "instructionFiles": "claude-md-and-agents-md" } }
  }
}
```

The plugin ID is `cc-plugin-agents-md@builtin`; before v2.1.285 it was `agents-md@builtin`. A version before v2.1.285 ignores an entry under the new `cc-plugin-agents-md@builtin` ID, so put `agents-md@builtin` in a settings file that earlier versions also read; v2.1.285 and later reads an entry under either ID. Claude Code **ignores this key in project and local settings files.** Use `~/.claude/settings.json`, a `--settings` file, or managed settings.

### When AGENTS.md support is unavailable

In these sessions Claude reads `CLAUDE.md` files only, and **Project instructions** does not appear in `/config`:

- A version before v2.1.277.
- The built-in plugin that reads `AGENTS.md` disabled with `/plugin`.
- In some cases, the first session after upgrading from v2.1.276 or earlier — "Claude reads AGENTS.md from your next session on."

Provider and telemetry conditions are historical, not current: "Before v2.1.281, some sessions, such as those on Amazon Bedrock or with telemetry disabled, read CLAUDE.md files only. On those versions, update Claude Code." Anything reliably running v2.1.281+ reads `AGENTS.md` under the default setting; the fix for an older install is an upgrade, not a workaround.

For those sessions the documented fallback is the import: `@AGENTS.md` inside a `CLAUDE.md`.

### What differs from CLAUDE.md

| | `CLAUDE.md` | `AGENTS.md` read through the setting |
|---|---|---|
| `InstructionsLoaded` hooks | Fire | Do not fire. They fire as usual for an `AGENTS.md` that a `CLAUDE.md` imports or symlinks to |
| A `--add-dir` directory with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` set | Its `CLAUDE.md` loads | Its `AGENTS.md` does not load |
| An `@path` import of a file outside the working directory | Claude asks for approval | Loads only when external imports were already approved for the project, with no prompt |

The list has shrunk: `/memory` and the Memory files list in `/context` now include an `AGENTS.md` that Claude read, so the path appears there as evidence (before v2.1.280 it did not). Inside each `AGENTS.md`, `@path` imports are expanded and `claudeMdExcludes` patterns apply, and a subagent started without project instructions starts without these files too.

**Never read**: `AGENTS.local.md`, `AGENTS.override.md`, and anything under a `.agents/` directory. A nested `AGENTS.md` loads only when that subdirectory has none of the three counting `CLAUDE.md` files of its own.

### Removing an earlier AGENTS.md workaround

- **`CLAUDE.md` containing `@AGENTS.md`**: leave it. The import never causes a double read under any setting, and it still covers sessions that cannot load `AGENTS.md` directly.
- **`CLAUDE.md` saying in words to read `AGENTS.md`**: delete it or replace the sentence with an import — Claude opens the file only if it decides to.
- **`CLAUDE.md` symlinked to `AGENTS.md`, or a `SessionStart` hook that prints it**: a symlink can stay (delete it if you prefer the import); remove the hook, which adds a second copy to context.

Symlink caveat: the Edit and Write tools refuse to write through a symlink and direct the agent to edit the link's target, and on Windows a committed symlink checks out as a plain text file unless `core.symlinks` is enabled — so prefer the import there.

### Discovery

> "Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from your current working directory and every directory above it."

> "All discovered files are concatenated into context rather than overriding each other."

> "Claude also discovers CLAUDE.md and CLAUDE.local.md files in subdirectories under your current working directory. Instead of loading them at launch, they are included when Claude reads files in those subdirectories."

So: ancestors load **eagerly at launch**, descendants load **lazily on file access**. Within the concatenation, "content is ordered from the filesystem root down to your working directory", and inside each directory "CLAUDE.local.md is appended after CLAUDE.md, so your personal notes are the last thing Claude reads at that level." A deep nested file costs nothing until the agent touches that subtree — which makes nesting the correct tool for large monorepos.

### Imports

> "CLAUDE.md files can import additional files using `@path/to/import` syntax."

> "Both relative and absolute paths are allowed. Relative paths resolve relative to the file containing the import, not the working directory." Imported files "can recursively import other files, with a maximum depth of four hops."

Three parser rules bite in practice: a path containing spaces needs a backslash before each space, a path wrapped in quotes "isn't imported at all", and "Import parsing skips Markdown code spans and fenced code blocks" — so `` `@README` `` stays literal text while `@README` imports the file. Moving a file also breaks its imports, because relative paths resolve from the importing file.

### Rules, size, and context cost

`.claude/rules/` holds topic files discovered recursively, so instructions can be split per topic instead of growing one file. A rule without `paths` frontmatter loads at launch with the same priority as `.claude/CLAUDE.md`; a `paths` list scopes it to matching files and loads it only when Claude reads them. Rules load every session or when a matching file is opened, so task-specific instructions belong in a skill instead.

> "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence. Move instructions that matter for only part of the codebase into path-scoped rules, which load only when Claude works with those files."

That is advice, not a cap. There *is* a per-file cap, and it is far higher:

> "Claude gets the whole of each CLAUDE.md file that loads at launch, as long as the file is 4 MiB or smaller. Claude Code skips a file over 4 MiB and loads none of it. Path-scoped rules and CLAUDE.md files in subdirectories have a smaller per-file limit of their own."

So an over-long launch file is not trimmed to fit — it is loaded whole or dropped whole. Subdirectory files behave differently: "If a nested CLAUDE.md is over its per-file size limit, Claude receives only the start of the file." Auto-memory truncates hardest: "The first 200 lines of MEMORY.md, or the first 25KB, whichever comes first, are loaded at the start of every conversation." Three distinct limits, and an over-long `CLAUDE.md` costs adherence silently before it ever hits a cap.

### Related files and commands

- `CLAUDE.local.md` — personal project-specific preferences, documented as something to gitignore. Because it counts for the `AGENTS.md` check, adding one to a repository that relies on `AGENTS.md` stops Claude from reading `AGENTS.md` unless **Project instructions** is `claude-md-and-agents-md`.
- Auto-memory lives per project at `~/.claude/projects/<project>/memory/`; all worktrees of one repository share it.
- `/init` generates a starting `CLAUDE.md` and "suggests improvements rather than overwriting it" if one exists. It also reads other tools' files — Cursor rules, `.github/copilot-instructions.md`, and with `CLAUDE_CODE_NEW_INIT=1` also `AGENTS.md`, `.devin/rules/`, `.windsurf/rules/` or `.windsurfrules`, `.clinerules`. `/import` appends a one-time copy of another agent's instruction files, `AGENTS.md` included, and carries over MCP servers, commands, subagents, and skills.
- `/memory` lists memory file locations across user and project scopes, toggles auto memory, and now shows the path of an `AGENTS.md` that loaded.
- `/doctor` proposes trim cuts for a checked-in `CLAUDE.md`, which is the practical answer to "is this file too big".
- The `#` hotkey is no longer the recommended memory path: "Claude now automatically saves memories that are relevant to the work and to you." (<https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/>, published 2026-07-24, checked 2026-11-03)

---

## 3. OpenAI Codex

Source: <https://learn.chatgpt.com/docs/agent-configuration/agents-md> (checked 2026-11-03; `developers.openai.com/codex/agent-configuration/agents-md` redirects here)

### Global scope

> "In your Codex home directory (defaults to `~/.codex`, unless you set `CODEX_HOME`), Codex reads `AGENTS.override.md` if it exists. Otherwise, Codex reads `AGENTS.md`. Codex uses only the first non-empty file at this level."

The documented use is a temporary global override: "Use `~/.codex/AGENTS.override.md` when you need a temporary global override without deleting the base file." That is also the first thing to check when an agent behaves against the repository's instructions.

### Project scope

> "Starting at the project root (typically the Git root), Codex walks down to your current working directory. If Codex cannot find a project root, it only checks the current directory. In each directory along the path, it checks for `AGENTS.override.md`, then `AGENTS.md`, then any fallback names in `project_doc_fallback_filenames`. Codex includes at most one file per directory."

`project_doc_fallback_filenames` extends the search with project-specific names; the documented example is `["TEAM_GUIDE.md", ".agents.md"]`, and names not on the list "are ignored for instruction discovery". An `AGENTS.override.md` in a directory wins over that directory's `AGENTS.md` — editing the wrong one is a common reason a change appears to have no effect.

### Merge order

> "Codex concatenates files from the root down, joining them with blank lines. Files closer to your current directory override earlier guidance because they appear later in the combined prompt."

Precedence here is **positional**, not exclusive. Later text wins by being later, which is a soft guarantee, not a hard one.

### Size limit

> "Codex skips empty files and stops adding files once the combined size reaches the limit defined by `project_doc_max_bytes` (32 KiB by default)."

This is a hard truncation with a real failure mode: files are dropped **once the budget is exhausted, in root-to-leaf order**. A bloated root file can therefore silently starve the nested file that actually governs the code being edited. This is the strongest mechanical argument for keeping the root file small. Codex's own troubleshooting frames it the same way: "Raise `project_doc_max_bytes` or split large files across nested directories to keep critical guidance intact."

### Code review conventions

Codex documents a `## Code Review Rules` section convention for repositories that want review behavior stated in the same file, so review guidance does not need a second format.

---

## 4. GitHub Copilot

Sources: <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions> and <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> (checked 2026-11-03; the older `prompting/response-customization` path now redirects to the first URL)

### Precedence is surface-specific

Copilot is the only reviewed vendor whose documentation states nearest-wins, but the statement is scoped, and the scope matters:

> "Precedence depends on the client and feature. Most surfaces and clients, including Copilot CLI, Visual Studio Code and Visual Studio, combine applicable instruction files without defining a general precedence order."

For Copilot Chat on GitHub.com the order is documented, highest first: "Personal instructions"; then repository custom instructions — "Path-specific instructions in any applicable `.github/instructions/**/*.instructions.md` file", then `.github/copilot-instructions.md`; then "Agent instructions, such as instructions in an `AGENTS.md` file"; then "Organization custom instructions".

So `AGENTS.md` still ranks **below** the repository's own instruction files, and on most non-GitHub.com clients the files are combined rather than ranked. A repository carrying both `.github/copilot-instructions.md` and `AGENTS.md` should therefore keep them non-contradictory rather than assume one wins.

### AGENTS.md handling

> "You can create one or more `AGENTS.md` files, stored anywhere within the repository. When Copilot is working, the nearest `AGENTS.md` file in the directory tree will take precedence."

Copilot also treats `CLAUDE.md` and `GEMINI.md` as agent-instruction files:

> "Alternatively, you can use a single `CLAUDE.md` or `GEMINI.md` file stored in the root of the repository."

Path-specific and repository-wide files combine rather than replace:

> "If the path you specify matches a file that Copilot is working on, and a repository-wide custom instructions file also exists, then the instructions from both files are used."

Copilot also offers a mechanism the others lack — glob-scoped instruction files via `applyTo:` frontmatter in `.github/instructions/*.instructions.md`, with optional `excludeAgent: "code-review" | "cloud-agent"`; omitting it means both Copilot code review and the cloud agent use the file.

One caveat on the widely repeated "2 pages" figure: it appears only inside GitHub's copy-paste authoring prompt, not as a documented limit. Treat it as a prompt template, not a product rule.

---

## 5. Cursor, Gemini CLI, and the newer adopters

**Cursor** (<https://cursor.com/en-US/docs/rules>, checked 2026-11-03) lists `AGENTS.md` as one of four rule types — "Agent instructions in markdown format. Simple alternative to `.cursor/rules`" — and supports it "in the project root and subdirectories", where "Instructions from nested `AGENTS.md` files are combined with parent directories, with more specific instructions taking precedence". `.cursor/rules/*.mdc` remains the richer mechanism, and a plain `.md` file placed there is ignored because it lacks the frontmatter (`description`, `globs`, `alwaysApply`); Cursor's own advice for plain Markdown is to use `AGENTS.md` instead. Its size heuristic for rules generally is unchanged: "Keep rules under 500 lines."

**Gemini CLI** (<https://geminicli.com/docs/cli/gemini-md/>, page last updated 2026-06-18, checked 2026-11-03) keeps `GEMINI.md` as the default name and `context.fileName` as the setting that lets a project point at `AGENTS.md` instead — support is opt-in, not automatic. Loading is layered rather than nearest-wins: the CLI "loads various context files from several locations, concatenates the contents of all found files, and sends them to the model with every prompt" — global `~/.gemini/GEMINI.md`, then workspace directories and their parents, then just-in-time files scanned when a tool touches a directory. `@file.md` imports work with relative and absolute paths.

Worth knowing for planning: the same page carries a banner that Gemini CLI "was replaced by Antigravity CLI on June 18th, 2026" for unpaid-tier and Google One users. Do not build a new instruction strategy around Gemini CLI without checking which CLI your users actually run.

### Runtimes that adopted AGENTS.md

These matter less as precedence rules than as evidence that the format is now the shared default, which is what makes a single canonical `AGENTS.md` the right base:

| Runtime | Documented behavior |
|---|---|
| **Amp** | Moved from `AGENT.md` to `AGENTS.md` in 2025 while "staying backwards compatible with existing AGENT.md files". Files "in the current working directory (or editor workspace roots) and parent directories (up to `$HOME`) are always included"; subtree files are included "when the agent reads a file in the subtree" — the same eager/lazy split as Claude Code |
| **opencode** | Project `AGENTS.md` applies "when you are working in this directory or its sub-directories", plus a global `~/.config/opencode/AGENTS.md`. Discovery walks up from the current directory and reads `AGENTS.md` before `CLAUDE.md`: "The first matching file wins in each category" |
| **Zed** | "Zed supports `AGENTS.md` as the primary instruction file for personal and project-level agent guidance", with personal `~/.config/zed/AGENTS.md`. Project files are picked by first match from a fixed list, and "Project instructions override personal `AGENTS.md` when they conflict" |

The opencode rule is the important pattern: `AGENTS.md` outranks `CLAUDE.md` for the same directory, so a repository that keeps both must make `CLAUDE.md` a pure pointer rather than a second contract.

---

## 6. Format and ecosystem

The standard imposes no schema:

> "No. AGENTS.md is just standard Markdown. Use any headings you like; the agent simply parses the text you provide."

It is also no longer only a convention. The site states: "AGENTS.md is now stewarded by the Agentic AI Foundation under the Linux Foundation", after emerging from collaborative work across OpenAI Codex, Amp, Jules, Cursor, and Factory. That stewardship is the strongest available argument that a single `AGENTS.md` is the right canonical artifact rather than one file per runtime.

Supported tools listed by name on the site: Codex, Jules, Factory, Aider, goose, opencode, Zed, Warp, VS Code, Devin, UiPath Autopilot and Coded Agents, Junie, Amp, Cursor, RooCode, Gemini CLI, Kilo Code, Phoenix, Semgrep, GitHub Copilot coding agent, Ona, Windsurf, and Augment Code.

One FAQ answer carries a safety implication worth repeating to authors:

> "Will the agent run testing commands found in AGENTS.md automatically? Yes—if you list them. The agent will attempt to execute relevant programmatic checks and fix failures before finishing the task."

A command written into `AGENTS.md` is therefore not documentation of intent — it is an instruction to execute. Never put a destructive or credentialed command there unless running it unattended is intended.

For legacy singular filenames the documented migration is a rename plus symlink, `mv AGENT.md AGENTS.md && ln -s AGENTS.md AGENT.md`.

For runtimes that need pointing at the file, the site documents per-tool configuration — Gemini CLI, for example, sets `context.fileName` to `AGENTS.md` in `.gemini/settings.json`.

No reviewed source documents a general `CLAUDE.md` → `AGENTS.md` migration recipe beyond Claude Code's own options: native `AGENTS.md` reading in §2, the `@AGENTS.md` import, and `/import`. Claude Code's `/init` does the reverse — it reads other tools' instruction files (Cursor rules, `.github/copilot-instructions.md`, and with `CLAUDE_CODE_NEW_INIT=1` also `AGENTS.md`, `.devin/rules/`, `.windsurf/rules/` or `.windsurfrules`, `.clinerules`) and folds the relevant parts into a generated `CLAUDE.md`.

---

## 7. Portability checklist

- [ ] Root file is small enough to survive Codex's 32 KiB root-to-leaf budget with room for nested files.
- [ ] Nested files are self-contained deltas, correct whether or not the parent is loaded.
- [ ] Overrides restate the correct rule in full instead of negating the parent.
- [ ] Every nested file names the subtree it governs.
- [ ] If Claude Code is a target, the repository either relies on its native `AGENTS.md` reading (v2.1.277+ or later, and no `CLAUDE.md` or `CLAUDE.local.md` at or above the working directory) or ships a `CLAUDE.md` that imports or symlinks to `AGENTS.md`, because sessions that cannot read `AGENTS.md` — a version before v2.1.277, the built-in reader disabled, or in some cases the first session after upgrading — load `CLAUDE.md` only, and the fix for an older install is an upgrade rather than a workaround.
- [ ] `CLAUDE.local.md` is not committed to a repository that relies on `AGENTS.md`, since it suppresses `AGENTS.md` under the default setting.
- [ ] `@path` imports stay within four hops, use paths relative to the importing file, and are not wrapped in quotes or code spans by accident.
- [ ] No launch-time instruction file approaches 4 MiB, where Claude Code skips it entirely.
- [ ] If both `.github/copilot-instructions.md` and `AGENTS.md` exist, their content does not conflict, since Copilot ranks the former higher on the surface where it ranks at all.
- [ ] No `AGENTS.override.md` left in the repository root or `~/.codex` silently replaces the file you meant to edit.
- [ ] Personal-preference content lives in a gitignored local file, not the shared one.

---

## Sources

| Source | URL | Checked |
|---|---|---|
| AGENTS.md standard | <https://agents.md/> | 2026-11-03 |
| Claude Code memory | <https://code.claude.com/docs/en/memory> | 2026-11-03 |
| Claude Code features overview | <https://code.claude.com/docs/en/features-overview> | 2026-11-03 |
| New rules of context engineering (Claude 5) | <https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/> | 2026-11-03 |
| OpenAI Codex AGENTS.md | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | 2026-11-03 |
| GitHub Copilot custom instructions | <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions> | 2026-11-03 |
| GitHub Copilot repository instructions | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 2026-11-03 |
| Cursor rules | <https://cursor.com/en-US/docs/rules> | 2026-11-03 |
| Gemini CLI context files | <https://geminicli.com/docs/cli/gemini-md/> | 2026-11-03 |
| opencode rules | <https://opencode.ai/docs/rules/> | 2026-11-03 |
| Amp AGENTS.md | <https://ampcode.com/docs/customize/agents-md> | 2026-11-03 |
| Amp — From AGENT.md to AGENTS.md (2025-08-20) | <https://ampcode.com/news/AGENTS.md> | 2026-11-03 |
| Zed instructions | <https://zed.dev/docs/ai/instructions> | 2026-11-03 |

## Related documents

- [`../AGENTS_MD.md`](../AGENTS_MD.md)
- [`claude-md-adapter.md`](claude-md-adapter.md)
- [`content-contract.md`](content-contract.md)
- [`../../context-engineering/references/runtime-profiles.md`](../../context-engineering/references/runtime-profiles.md)
