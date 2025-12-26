# NPX CLI Patterns

> 복사용 코드 패턴 모음

## CLI Entry Point

```typescript
#!/usr/bin/env node
import { Command } from 'commander';

const program = new Command();

program
  .name('my-cli')
  .description('CLI description')
  .version('1.0.0');

program
  .option('-t, --template <name>', 'template name')
  .option('-f, --force', 'overwrite existing files')
  .action(async (options) => {
    // 명령어 실행
  });

program.parse();
```

## Logger 유틸

```typescript
import pc from 'picocolors';

export const logger = {
  info: (msg: string): void => console.log(pc.blue('ℹ'), msg),
  success: (msg: string): void => console.log(pc.green('✔'), msg),
  warn: (msg: string): void => console.log(pc.yellow('⚠'), msg),
  error: (msg: string): void => console.log(pc.red('✖'), msg),
  step: (msg: string): void => console.log(pc.gray('  →'), msg),
  blank: (): void => console.log(),
};
```

## Interactive Prompts

```typescript
import prompts from 'prompts';

// Select (단일 선택)
const { template } = await prompts({
  type: 'select',
  name: 'template',
  message: 'Select a template:',
  choices: [
    { title: 'Template A', value: 'a' },
    { title: 'Template B', value: 'b' },
  ],
});

// Multiselect (다중 선택)
const { templates } = await prompts({
  type: 'multiselect',
  name: 'templates',
  message: 'Select templates:',
  choices: [
    { title: 'Template A', value: 'a' },
    { title: 'Template B', value: 'b' },
  ],
  min: 1,
  hint: '- Space to select. Return to submit',
});

// Confirm
const { confirmed } = await prompts({
  type: 'confirm',
  name: 'confirmed',
  message: 'Overwrite existing files?',
  initial: false,
});
```

## File Copy 유틸

```typescript
import fs from 'fs-extra';
import path from 'path';

export const copyRecursive = async (
  src: string,
  dest: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };

  const copy = async (s: string, d: string): Promise<void> => {
    const stat = await fs.stat(s);

    if (stat.isDirectory()) {
      await fs.ensureDir(d);
      counter.directories++;

      const items = await fs.readdir(s);
      for (const item of items) {
        await copy(path.join(s, item), path.join(d, item));
      }
    } else {
      await fs.copy(s, d);
      counter.files++;
    }
  };

  await copy(src, dest);
  return counter;
};
```

## ESM __dirname

```typescript
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
```

## Package.json

```json
{
  "name": "@scope/my-cli",
  "version": "1.0.0",
  "type": "module",
  "bin": "./dist/index.js",
  "files": ["dist", "templates"],
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "prepublishOnly": "npm run build"
  },
  "engines": {
    "node": ">=18"
  }
}
```

## tsup.config.ts

```typescript
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm'],
  target: 'node18',
  clean: true,
  dts: true,
  banner: {
    js: '#!/usr/bin/env node',
  },
});
```
