# CLAUDE.md - NPX CLI

> Node.js CLI 도구 개발

<context>

**Purpose:** Node.js CLI 도구 개발을 위한 작업 지침

**Scope:** npx 배포 가능한 CLI 패키지 구현

**Key Features:**
- Commander.js 명령어 체계
- 대화형 프롬프트 (prompts)
- 파일 시스템 작업 (fs-extra)
- TypeScript + ESM
- 색상 출력 (picocolors)

</context>

---

<instructions>
@../../commands/git.md
@.claude/docs/library/commander/index.md
@.claude/docs/library/fs-extra/index.md
@.claude/docs/library/prompts/index.md
@.claude/docs/references/patterns.md
</instructions>

---

<forbidden>

| 분류 | 금지 행동 |
|------|----------|
| **Git 커밋** | AI 표시 (`Generated with Claude Code`, `🤖`, `Co-Authored-By:`), 여러 줄 메시지, 이모지 |
| **콘솔 출력** | `console.log` 직접 사용 (logger 함수 사용) |
| **파일 작업** | 동기 API (`fs.readFileSync` 등), 하드코딩된 경로 (path.join 사용) |
| **에러 처리** | `process.exit()` 누락, try-catch 없는 async 작업 |
| **코드 검색** | Bash의 grep/rg/find 명령어 (ast-grep 또는 전용 도구 사용) |

</forbidden>

---

<required>

| 작업 | 필수 행동 |
|------|----------|
| **작업 시작 전** | 관련 docs 읽기 (Commander → commander, 파일 → fs-extra) |
| **문서 검색** | serena mcp 사용 (문서 인덱싱/검색, context 길이 최적화) |
| **콘솔 출력** | logger 함수 사용 (info/success/error/warn) |
| **파일 작업** | async API (`fs-extra`), `path.join`으로 경로 조합 |
| **에러 처리** | try-catch + `process.exit(1)`, 사용자에게 명확한 에러 메시지 |
| **코드 검색** | ast-grep 사용 (함수/클래스/패턴 검색) |
| **코드 작성** | UTF-8 인코딩, 코드 묶음별 한글 주석, const 함수 선언 |
| **복잡한 작업** | Sequential Thinking MCP (5+ 단계 작업) |

</required>

---

<tech_stack>

| 기술 | 버전 |
|------|------|
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
├── index.ts      # CLI 진입점
├── commands/     # 명령어 모듈
├── utils/        # logger, copy
└── types/        # 타입

templates/        # 빌드 시 복사
dist/             # 빌드 결과물
```
</structure>

---

<conventions>

**파일명:** kebab-case
**TypeScript:** const 선언, 명시적 return type, interface(객체)/type(유니온), any→unknown
**Import 순서:** 외부 → 내부 → type

</conventions>

---

<quick_patterns>

```typescript
// CLI 진입점 (index.ts)
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
// 파일 복사 (utils/copy.ts)
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
// 대화형 프롬프트
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
└── references/   # CLI 패턴, 베스트 프랙티스
```
</docs_structure>
