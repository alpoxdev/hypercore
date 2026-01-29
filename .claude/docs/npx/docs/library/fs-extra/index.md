# fs-extra

> Node.js file system utilities

<patterns>

```typescript
import fs from 'fs-extra';
import path from 'path';

// Check existence
const exists = await fs.pathExists('/path/to/file');

// Create directory
await fs.ensureDir('/path/to/nested/dir');
await fs.mkdir('/path/to/dir');

// Copy
await fs.copy('/src/file.txt', '/dest/file.txt');
await fs.copy('/src/dir', '/dest/dir');
await fs.copy(src, dest, {
  overwrite: true,
  errorOnExist: false,
  filter: (src) => !src.includes('node_modules'),
});

// Remove
await fs.remove('/path/to/dir');

// Read directory
const items = await fs.readdir('/path/to/dir');

// Check file type
const stat = await fs.stat(itemPath);
if (stat.isDirectory()) { /* ... */ }
if (stat.isFile()) { /* ... */ }

// Read/Write files
const content = await fs.readFile('/path/to/file', 'utf-8');
await fs.writeFile('/path/to/file', content, 'utf-8');

// JSON
const data = await fs.readJson('/path/to/file.json');
await fs.writeJson('/path/to/file.json', data, { spaces: 2 });

// Recursive copy
const copyRecursive = async (src: string, dest: string) => {
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

// ESM __dirname
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const templatesDir = path.resolve(__dirname, '../templates');
```

</patterns>
