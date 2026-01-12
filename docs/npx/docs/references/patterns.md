# NPX CLI Patterns

> Integrated CLI implementation patterns

<patterns>

## CLI Entry Point

```typescript
#!/usr/bin/env node
import { Command } from 'commander';
import { logger } from './utils/logger.js';
import { initCommand } from './commands/init.js';

const program = new Command();

program
  .name('my-cli')
  .description('CLI tool description')
  .version('1.0.0');

program
  .option('-t, --template <name>', 'template name')
  .option('-f, --force', 'overwrite existing files')
  .action(async (options) => {
    try {
      await initCommand(options);
      logger.success('Done!');
    } catch (error) {
      logger.error(`Failed: ${error.message}`);
      process.exit(1);
    }
  });

program.parse();
```

## Logger Utility

```typescript
import pc from 'picocolors';

export const logger = {
  info: (msg: string): void => console.log(pc.blue('ℹ'), msg),
  success: (msg: string): void => console.log(pc.green('✔'), msg),
  warn: (msg: string): void => console.log(pc.yellow('⚠'), msg),
  error: (msg: string): void => console.log(pc.red('✖'), msg),
  step: (msg: string): void => console.log(pc.gray('  →'), msg),
};
```

## Interactive Template Selection

```typescript
import prompts from 'prompts';
import fs from 'fs-extra';
import path from 'path';
import { logger } from './utils/logger.js';

export const selectAndCopyTemplate = async (
  templatesDir: string,
  targetDir: string,
): Promise<void> => {
  // 1. Select template
  const { template } = await prompts({
    type: 'select',
    name: 'template',
    message: 'Select a template:',
    choices: [
      { title: 'React', value: 'react' },
      { title: 'Vue', value: 'vue' },
    ],
  });

  if (!template) {
    logger.warn('Cancelled.');
    process.exit(0);
  }

  // 2. Confirm overwrite
  const targetExists = await fs.pathExists(targetDir);
  if (targetExists) {
    const { overwrite } = await prompts({
      type: 'confirm',
      name: 'overwrite',
      message: 'Target exists. Overwrite?',
      initial: false,
    });

    if (!overwrite) {
      logger.warn('Cancelled.');
      process.exit(0);
    }
  }

  // 3. Copy files
  const src = path.join(templatesDir, template);
  await fs.copy(src, targetDir, { overwrite: true });
  logger.success(`Template copied to ${targetDir}`);
};
```

## ESM __dirname Handling

```typescript
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Templates directory path
const templatesDir = path.resolve(__dirname, '../templates');
```

## Recursive Copy with Counter

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

## package.json Configuration

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

## tsup Configuration

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

</patterns>
