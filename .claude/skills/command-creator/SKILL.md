---
name: command-creator
description: Guide for creating effective slash commands. This skill should be used when users want to create a new command (or update an existing command) that extends Claude Code with reusable prompts and workflows.
license: Complete terms in LICENSE.txt
---

# Command Creator

This skill provides guidance for creating effective slash commands.

## About Commands

Commands are simple, reusable prompts that extend Claude Code with custom workflows. Think of them as "shortcuts" for common tasks—they transform frequently-used instructions into quick `/command-name` invocations.

### What Commands Provide

1. Reusable prompts - Common instructions triggered with a slash command
2. Tool permissions - Pre-configured tool access for specific workflows
3. Argument support - Dynamic values passed at invocation time
4. Context injection - Automatic inclusion of files or shell output

### Commands vs Skills

| Feature | Commands | Skills |
|---------|----------|--------|
| Structure | Single `.md` file | `SKILL.md` + bundled resources |
| Complexity | Simple prompts | Multi-step workflows |
| Resources | None | Scripts, references, assets |
| Use case | Quick shortcuts | Domain expertise |

Use Commands for simple, reusable prompts. Use Skills for complex workflows requiring bundled resources.

### Anatomy of a Command

Every command is a single Markdown file with optional YAML frontmatter:

```
command-name.md
├── YAML frontmatter (optional)
│   ├── description: (recommended)
│   ├── allowed-tools: (optional)
│   ├── argument-hint: (optional)
│   ├── model: (optional)
│   └── disable-model-invocation: (optional)
└── Markdown instructions (required)
```

#### File Locations

- **Project commands**: `.claude/commands/` (shared with team via git)
- **Personal commands**: `~/.claude/commands/` (personal only)

Project commands take precedence if names conflict.

#### Frontmatter Fields

| Field | Purpose | Default |
|-------|---------|---------|
| `description` | Brief description (shows in `/help`) | First line of content |
| `allowed-tools` | Tools the command can use | Inherits from conversation |
| `argument-hint` | Expected arguments (for autocomplete) | None |
| `model` | Specific model to use | Inherits from conversation |
| `disable-model-invocation` | Prevent SlashCommand tool usage | false |

#### Naming Convention

- Filename determines command name: `security-check.md` → `/security-check`
- Use hyphen-case (lowercase letters, digits, and hyphens only)
- Max 40 characters recommended

## Command Creation Process

To create a command, follow the "Command Creation Process" in order.

### Step 1: Understanding the Command Purpose

To create an effective command, clearly understand the specific use case:

- "What task will this command automate?"
- "What inputs (arguments) does it need?"
- "What tools should it be allowed to use?"
- "Should it be project-specific or personal?"

Examples of good command use cases:
- `/review-security` - Check code for security vulnerabilities
- `/commit-fix` - Create a commit with conventional format
- `/add-tests` - Generate unit tests for a file
- `/explain-error` - Analyze and explain an error message

### Step 2: Planning the Command Structure

Analyze the command requirements:

1. **Arguments**: What dynamic values are needed?
   - Use `$ARGUMENTS` for all arguments as a single string
   - Use `$1`, `$2`, etc. for positional arguments

2. **Tools**: What tools does the command need?
   - `Bash(git:*)` for git commands
   - `Read`, `Write`, `Edit` for file operations
   - Leave empty to inherit from conversation

3. **Context**: What information should be included?
   - Use `@filepath` to include file contents
   - Use `!`backtick command`!` for shell output

### Step 3: Initializing the Command

To create a new command from scratch, run the `init_command.py` script:

```bash
scripts/init_command.py <command-name> --path <output-directory>
```

Options:
- `--project`: Create in `.claude/commands/` (default)
- `--personal`: Create in `~/.claude/commands/`

The script:
- Creates the command file at the specified path
- Generates a template with proper frontmatter and TODO placeholders
- Provides examples for common patterns

### Step 4: Edit the Command

When editing the command, focus on:

1. **Clear description**: Explain what the command does
2. **Minimal tools**: Only request necessary permissions
3. **Helpful hints**: Provide argument hints for autocomplete
4. **Concrete instructions**: Be specific about what Claude should do

#### Writing Style

Write using **imperative/infinitive form** (verb-first instructions):
- "Review the code for..." (not "You should review...")
- "Generate tests for..." (not "Please generate...")

#### Example Patterns

**Simple command with arguments:**
```markdown
---
description: Create a commit with conventional format
argument-hint: <type> <message>
allowed-tools: Bash(git add:*), Bash(git commit:*)
---

Create a git commit with type "$1" and message "$2".
Follow conventional commit format: <type>: <message>
```

**Command with file context:**
```markdown
---
description: Review code for security issues
allowed-tools: Read
---

Review the following code for security vulnerabilities:

@$ARGUMENTS

Check for:
- SQL injection
- XSS vulnerabilities
- Sensitive data exposure
```

**Command with shell output:**
```markdown
---
description: Explain the current git status
allowed-tools: Bash(git:*)
---

Current git status:
!`git status`

Recent commits:
!`git log --oneline -5`

Explain the current state of the repository.
```

### Step 5: Packaging Commands

To package commands into a distributable zip file:

```bash
scripts/package_command.py <path/to/commands-folder> [output-directory]
```

The packaging script will:
1. **Validate** all command files
2. **Package** into a zip file for distribution

### Step 6: Iterate

After testing the command:
1. Use the command on real tasks
2. Notice any issues or missing functionality
3. Update the command file
4. Test again

## Quick Reference

### Argument Syntax

| Syntax | Description | Example |
|--------|-------------|---------|
| `$ARGUMENTS` | All arguments as string | `/cmd foo bar` → `foo bar` |
| `$1`, `$2` | Positional arguments | `/cmd foo bar` → `$1=foo`, `$2=bar` |

### Context Injection

| Syntax | Description |
|--------|-------------|
| `@filepath` | Include file contents |
| `!`command`!` | Include shell output |

### Common Tool Patterns

| Pattern | Description |
|---------|-------------|
| `Bash(git:*)` | All git commands |
| `Bash(npm:*)` | All npm commands |
| `Read`, `Write`, `Edit` | File operations |
| `WebFetch` | Fetch web content |

## Namespacing

Use subdirectories to organize commands:
- `.claude/commands/frontend/component.md` → `/component` (shows as "project:frontend")
- `.claude/commands/backend/test.md` → `/test` (shows as "project:backend")
