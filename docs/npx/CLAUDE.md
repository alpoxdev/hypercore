# CLAUDE.md - NPX CLI

> Node.js CLI tool development

<context>

**Purpose:** Work instructions for Node.js CLI tool development

**Scope:** Implement CLI packages deployable via npx

**Key Features:**
- Commander.js command system
- Interactive prompts (prompts)
- File system operations (fs-extra)
- TypeScript + ESM
- Colored output (picocolors)

</context>

---

<instructions>
@../../commands/git.md
@docs/library/commander/index.md
@docs/library/fs-extra/index.md
@docs/library/prompts/index.md
@docs/references/patterns.md
</instructions>

---

<forbidden>

| Category | Prohibited Actions |
|----------|-------------------|
| **Git Commits** | AI markers (`Generated with Claude Code`, `🤖`, `Co-Authored-By:`), multi-line messages, emojis |
| **Console Output** | Direct `console.log` usage (use logger functions) |
| **File Operations** | Synchronous APIs (`fs.readFileSync`, etc.), hardcoded paths (use path.join) |
| **Error Handling** | Missing `process.exit()`, async operations without try-catch |
| **Code Search** | Bash grep/rg/find commands (use ast-grep or dedicated tools) |

</forbidden>

---

<required>

| Task | Required Actions |
|------|-----------------|
| **Before Starting** | Read relevant docs (Commander → commander, Files → fs-extra) |
| **Console Output** | Use logger functions (info/success/error/warn) |
| **File Operations** | Async API (`fs-extra`), `path.join` for paths |
| **Error Handling** | try-catch + `process.exit(1)`, clear error messages to users |
| **Code Search** | Use ast-grep (search functions/classes/patterns) |
| **Code Writing** | UTF-8 encoding, Korean comments per code block, const function declarations |
| **Complex Tasks** | Sequential Thinking MCP (5+ step tasks) |

</required>

---

<tech_stack>

| Technology | Version |
|-----------|---------|
| Node.js | >= 18 (ESM) |
| TypeScript | 5.x (strict) |
| Commander | 12.x |
| fs-extra | 11.x |
| prompts | 2.x |
| picocolors | 1.x |
| tsup | 8.x |

</tech_stack>

---

<structure>
```
src/
├── index.ts      # CLI entry point
├── commands/     # Command modules
├── utils/        # logger, copy
└── types/        # Types

templates/        # Copied during build
dist/             # Build output
```
</structure>

---

<conventions>

**File naming:** kebab-case
**TypeScript:** const declarations, explicit return types, interface(objects)/type(unions), any→unknown
**Import order:** external → internal → type

</conventions>

---

<quick_patterns>

```typescript
// CLI entry point (index.ts)
#!/usr/bin/env node
import { Command } from 'commander'
import { logger } from './utils/logger.js'

const program = new Command()
  .name('my-cli')
  .version('1.0.0')
  .description('CLI tool description')

program
  .command('init')
  .description('Initialize project')
  .option('-f, --force', 'Force overwrite')
  .action(async (options) => {
    try {
      await initCommand(options)
    } catch (error) {
      logger.error(`Failed: ${error.message}`)
      process.exit(1)
    }
  })

program.parse()
```

```typescript
// Logger (utils/logger.ts)
import pc from 'picocolors'

export const logger = {
  info: (msg: string) => console.log(pc.blue('ℹ'), msg),
  success: (msg: string) => console.log(pc.green('✔'), msg),
  error: (msg: string) => console.log(pc.red('✖'), msg),
  warn: (msg: string) => console.log(pc.yellow('⚠'), msg),
}
```

```typescript
// File copying (utils/copy.ts)
import path from 'node:path'
import { copy, pathExists } from 'fs-extra'

export const copyTemplate = async (
  templatePath: string,
  targetPath: string,
  force: boolean = false
): Promise<void> => {
  const exists = await pathExists(targetPath)

  if (exists && !force) {
    throw new Error(`${targetPath} already exists`)
  }

  await copy(templatePath, targetPath, { overwrite: force })
}
```

```typescript
// Interactive prompts
import prompts from 'prompts'

const response = await prompts([
  {
    type: 'select',
    name: 'template',
    message: 'Select template',
    choices: [
      { title: 'React', value: 'react' },
      { title: 'Vue', value: 'vue' },
    ],
  },
  {
    type: 'confirm',
    name: 'install',
    message: 'Install dependencies?',
    initial: true,
  },
])
```

</quick_patterns>

---

<docs_structure>
```
docs/
├── library/      # commander, fs-extra, prompts
└── references/   # CLI patterns, best practices
```
</docs_structure>
