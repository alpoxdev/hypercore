import { Command } from 'commander';
import { banner, logger } from './shared/logger.js';
import { init } from './commands/init.js';
import { add } from './commands/add.js';
import { remove } from './commands/remove.js';
import { list } from './commands/list.js';
import { listAvailableTemplates } from './features/templates/index.js';

const program = new Command();

program
  .name('claude-code')
  .description('Claude Code documentation installer for projects')
  .version('0.6.1');

// 기본 명령 (init)
program
  .option(
    '-t, --template <names>',
    'template names (comma-separated: tanstack-start,hono)',
  )
  .option('-f, --force', 'overwrite existing files without prompting')
  .option('--cwd <path>', 'target directory (default: current directory)')
  .option('--list', 'list available templates')
  .option('-s, --skills', 'install skills')
  .option('-c, --commands', 'install commands')
  .option('--install-agents', 'install agents')
  .option(
    '-a, --agents <names>',
    'target agents (comma-separated: claude-code,cursor)',
  )
  .option(
    '-g, --global',
    'install to global scope (~/.claude, ~/.cursor, etc.)',
  )
  .action(async (options) => {
    banner();

    // 템플릿 목록 출력
    if (options.list) {
      const templates = await listAvailableTemplates();
      logger.info('Available templates:');
      templates.forEach((t) => logger.step(t));
      logger.blank();
      return;
    }

    // 초기화 실행
    await init({
      templates: options.template?.split(',').map((t: string) => t.trim()),
      force: options.force,
      cwd: options.cwd,
      skills: options.skills,
      commands: options.commands,
      installAgents: options.installAgents,
      targetAgents: options.agents?.split(',').map((a: string) => a.trim()),
      global: options.global,
    });
  });

// add 명령
program
  .command('add <source>')
  .description('Add a skill from local source')
  .option('-a, --agents <names>', 'target agents (comma-separated)')
  .option('-g, --global', 'install to global scope')
  .option('--cwd <path>', 'target directory (default: current directory)')
  .action(async (source, options) => {
    banner();
    await add({
      source,
      agents: options.agents?.split(',').map((a: string) => a.trim()),
      global: options.global,
      cwd: options.cwd,
    });
  });

// remove 명령
program
  .command('remove <name>')
  .description('Remove an installed skill')
  .option('-a, --agents <names>', 'target agents (comma-separated)')
  .option('-g, --global', 'remove from global scope')
  .option('-f, --force', 'skip confirmation prompt')
  .option('--cwd <path>', 'target directory (default: current directory)')
  .action(async (name, options) => {
    banner();
    await remove({
      name,
      agents: options.agents?.split(',').map((a: string) => a.trim()),
      global: options.global,
      force: options.force,
      cwd: options.cwd,
    });
  });

// list 명령
program
  .command('list')
  .description('List installed skills')
  .option('-a, --agents <names>', 'filter by agents (comma-separated)')
  .option('-g, --global', 'list global skills')
  .option('--cwd <path>', 'target directory (default: current directory)')
  .action(async (options) => {
    banner();
    await list({
      agents: options.agents?.split(',').map((a: string) => a.trim()),
      global: options.global,
      cwd: options.cwd,
    });
  });

program.parse();
