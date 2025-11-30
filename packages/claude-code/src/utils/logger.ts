import pc from 'picocolors';

export const logger = {
  info: (msg: string) => console.log(pc.cyan('ℹ'), msg),
  success: (msg: string) => console.log(pc.green('✓'), msg),
  warn: (msg: string) => console.log(pc.yellow('⚠'), msg),
  error: (msg: string) => console.log(pc.red('✗'), msg),
  title: (msg: string) => console.log('\n' + pc.bold(pc.blue(msg)) + '\n'),
  step: (msg: string) => console.log(pc.gray('  →'), msg),
  blank: () => console.log(),
};

export const banner = () => {
  console.log();
  console.log(pc.bold(pc.cyan('  🚀 Claude Code Docs Installer')));
  console.log(pc.gray('  ─────────────────────────────'));
  console.log();
};
