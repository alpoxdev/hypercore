# Commander.js

> Node.js CLI framework

<patterns>

## Basic Setup

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
// Basic
program
  .option('-t, --template <name>', 'template name')
  .option('-f, --force', 'force overwrite')
  .action((options) => {
    console.log(options.template); // string | undefined
    console.log(options.force);    // boolean | undefined
  });

// Required
program
  .requiredOption('-c, --config <path>', 'config file path')
  .action((options) => {
    // options.config is always present
  });

// Default values
program
  .option('-p, --port <number>', 'port number', '3000')
  .option('-e, --env <name>', 'environment', 'development')

// Multiple values
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
    console.log(source);      // required
    console.log(destination); // optional
  });
```

## Subcommands

```typescript
program
  .command('init')
  .description('Initialize project')
  .option('-t, --template <name>', 'template')
  .action((options) => {
    // Handle init
  });

program
  .command('build')
  .description('Build project')
  .action(() => {
    // Handle build
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

await program.parseAsync(); // await required
```

</patterns>
