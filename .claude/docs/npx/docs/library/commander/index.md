# Commander.js

> Node.js CLI 프레임워크

<patterns>

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

## Options

```typescript
// 기본
program
  .option('-t, --template <name>', 'template name')
  .option('-f, --force', 'force overwrite')
  .action((options) => {
    console.log(options.template); // string | undefined
    console.log(options.force);    // boolean | undefined
  });

// 필수
program
  .requiredOption('-c, --config <path>', 'config file path')
  .action((options) => {
    // options.config는 항상 존재
  });

// 기본값
program
  .option('-p, --port <number>', 'port number', '3000')
  .option('-e, --env <name>', 'environment', 'development')

// 여러 값
program
  .option('-i, --include <path...>', 'include paths')
  .action((options) => {
    console.log(options.include); // string[]
  });
```

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

## Subcommands

```typescript
program
  .command('init')
  .description('Initialize project')
  .option('-t, --template <name>', 'template')
  .action((options) => {
    // init 처리
  });

program
  .command('build')
  .description('Build project')
  .action(() => {
    // build 처리
  });
```

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

await program.parseAsync(); // await 필수
```

</patterns>
