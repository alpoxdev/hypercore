import pc from 'picocolors';

export const logger = {
  info: (msg: string): void => console.log(pc.cyan('ℹ'), msg),
  success: (msg: string): void => console.log(pc.green('✓'), msg),
  warn: (msg: string): void => console.log(pc.yellow('⚠'), msg),
  error: (msg: string): void => console.log(pc.red('✗'), msg),
  title: (msg: string): void =>
    console.log('\n' + pc.bold(pc.blue(msg)) + '\n'),
  step: (msg: string): void => console.log(pc.gray('  →'), msg),
  blank: (): void => console.log(),
};

export const banner = (): void => {
  console.log();
  console.log(pc.bold(pc.cyan('  🚀 Claude Code Docs Installer')));
  console.log(pc.gray('  ─────────────────────────────'));
  console.log();
};
