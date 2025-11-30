# Commander.js 가이드

> Node.js CLI 프레임워크

---

## 기본 설정

```typescript
import { Command } from 'commander';

const program = new Command();

program
  .name('my-cli')
  .description('CLI description')
  .version('1.0.0');

program.parse();
```

---

## Options

### 기본 옵션
```typescript
program
  .option('-t, --template <name>', 'template name')
  .option('-f, --force', 'force overwrite')
  .option('-v, --verbose', 'verbose output')
  .action((options) => {
    console.log(options.template); // string | undefined
    console.log(options.force);    // boolean | undefined
  });
```

### 필수 옵션
```typescript
program
  .requiredOption('-c, --config <path>', 'config file path')
  .action((options) => {
    // options.config는 항상 존재
  });
```

### 기본값
```typescript
program
  .option('-p, --port <number>', 'port number', '3000')
  .option('-e, --env <name>', 'environment', 'development')
```

### 여러 값 수집
```typescript
program
  .option('-i, --include <path...>', 'include paths')
  .action((options) => {
    console.log(options.include); // string[]
  });

// 사용: --include src lib tests
```

---

## Arguments

```typescript
program
  .argument('<source>', 'source file')
  .argument('[destination]', 'destination file')
  .action((source, destination, options) => {
    console.log(source);      // 필수
    console.log(destination); // 선택
  });
```

---

## Subcommands

```typescript
program
  .command('init')
  .description('Initialize project')
  .option('-t, --template <name>', 'template')
  .action((options) => {
    // init 명령어 처리
  });

program
  .command('build')
  .description('Build project')
  .action(() => {
    // build 명령어 처리
  });

// 사용: my-cli init --template react
// 사용: my-cli build
```

---

## Async Action

```typescript
program
  .action(async (options) => {
    try {
      await doSomething();
    } catch (error) {
      console.error(error);
      process.exit(1);
    }
  });

// await 필요
await program.parseAsync();
```

---

## Help 커스터마이징

```typescript
program
  .addHelpText('beforeAll', 'Custom header')
  .addHelpText('afterAll', 'Custom footer');
```

---

## 전체 예시

```typescript
#!/usr/bin/env node
import { Command } from 'commander';

const program = new Command();

program
  .name('my-cli')
  .description('My awesome CLI tool')
  .version('1.0.0');

program
  .option('-t, --template <name>', 'template name')
  .option('-f, --force', 'overwrite existing files')
  .option('--cwd <path>', 'working directory', process.cwd())
  .action(async (options) => {
    const { template, force, cwd } = options;

    try {
      // 실행 로직
      await init({ template, force, cwd });
    } catch (error) {
      console.error('Error:', error.message);
      process.exit(1);
    }
  });

program.parse();
```
