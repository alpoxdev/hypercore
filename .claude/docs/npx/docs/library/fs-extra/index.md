# fs-extra

> Node.js 파일 시스템 유틸리티

<patterns>

```typescript
import fs from 'fs-extra';
import path from 'path';

// 존재 확인
const exists = await fs.pathExists('/path/to/file');

// 디렉토리 생성
await fs.ensureDir('/path/to/nested/dir');
await fs.mkdir('/path/to/dir');

// 복사
await fs.copy('/src/file.txt', '/dest/file.txt');
await fs.copy('/src/dir', '/dest/dir');
await fs.copy(src, dest, {
  overwrite: true,
  errorOnExist: false,
  filter: (src) => !src.includes('node_modules'),
});

// 삭제
await fs.remove('/path/to/dir');

// 디렉토리 읽기
const items = await fs.readdir('/path/to/dir');

// 파일 타입 확인
const stat = await fs.stat(itemPath);
if (stat.isDirectory()) { /* ... */ }
if (stat.isFile()) { /* ... */ }

// 파일 읽기/쓰기
const content = await fs.readFile('/path/to/file', 'utf-8');
await fs.writeFile('/path/to/file', content, 'utf-8');

// JSON
const data = await fs.readJson('/path/to/file.json');
await fs.writeJson('/path/to/file.json', data, { spaces: 2 });

// 재귀 복사
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
