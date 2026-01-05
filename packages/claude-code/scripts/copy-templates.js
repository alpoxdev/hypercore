import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const packageRoot = path.resolve(__dirname, '..');
const projectRoot = path.resolve(packageRoot, '../..');
const docsDir = path.join(projectRoot, 'docs');
const claudeDir = path.join(projectRoot, '.claude');
const templatesDir = path.join(packageRoot, 'templates');

async function copyTemplates() {
  console.log('📦 Copying docs/ → templates/...');

  // Clean templates directory
  await fs.remove(templatesDir);
  await fs.ensureDir(templatesDir);

  // Get all template directories from docs/
  const items = await fs.readdir(docsDir);

  for (const item of items) {
    const srcPath = path.join(docsDir, item);
    const destPath = path.join(templatesDir, item);
    const stat = await fs.stat(srcPath);

    if (stat.isDirectory()) {
      await fs.copy(srcPath, destPath);
      console.log(`  ✓ ${item}/`);
    }
  }

  // Copy .claude/skills and .claude/commands to templates/.claude/
  console.log('📦 Copying .claude/ → templates/.claude/...');
  const claudeDestDir = path.join(templatesDir, '.claude');
  await fs.ensureDir(claudeDestDir);

  const skillsSrc = path.join(claudeDir, 'skills');
  const commandsSrc = path.join(claudeDir, 'commands');
  const agentsSrc = path.join(claudeDir, 'agents');

  if (await fs.pathExists(skillsSrc)) {
    await fs.copy(skillsSrc, path.join(claudeDestDir, 'skills'));
    console.log('  ✓ .claude/skills/');
  }

  if (await fs.pathExists(commandsSrc)) {
    await fs.copy(commandsSrc, path.join(claudeDestDir, 'commands'));
    console.log('  ✓ .claude/commands/');
  }

  if (await fs.pathExists(agentsSrc)) {
    await fs.copy(agentsSrc, path.join(claudeDestDir, 'agents'));
    console.log('  ✓ .claude/agents/');
  }

  console.log('✅ Templates copied successfully!');
}

copyTemplates().catch((err) => {
  console.error('❌ Failed to copy templates:', err);
  process.exit(1);
});
