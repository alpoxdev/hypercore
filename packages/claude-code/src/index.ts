import { Command } from 'commander';
import { banner, logger } from './shared/logger.js';
import { init } from './commands/init.js';
import { listAvailableTemplates } from './features/templates/index.js';

const program = new Command();

program
  .name('claude-code')
  .description('Claude Code documentation installer for projects')
  .version('0.6.0');

program
  .option(
    '-t, --template <names>',
    'template names (comma-separated: tanstack-start,hono)',
  )
  .option('-f, --force', 'overwrite existing files without prompting')
  .option('--cwd <path>', 'target directory (default: current directory)')
  .option('--list', 'list available templates')
  .option('-s, --skills', 'install skills to .claude/skills/')
  .option('-c, --commands', 'install commands to .claude/commands/')
  .option('-a, --agents', 'install agents to .claude/agents/')
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
      agents: options.agents,
    });
  });

program.parse();
