import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const packageRoot = path.resolve(__dirname, '..');
const projectRoot = path.resolve(packageRoot, '../..');
const docsDir = path.join(projectRoot, 'docs');
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

  console.log('✅ Templates copied successfully!');
}

copyTemplates().catch((err) => {
  console.error('❌ Failed to copy templates:', err);
  process.exit(1);
});
