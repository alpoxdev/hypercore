# fs-extra 가이드

> Node.js 파일 시스템 유틸리티 (fs 확장)

---

## 기본 Import

```typescript
import fs from 'fs-extra';
import path from 'path';
```

---

## 파일/디렉토리 존재 확인

```typescript
// 존재 확인
const exists = await fs.pathExists('/path/to/file');

if (await fs.pathExists(targetDir)) {
  // 이미 존재
}
```

---

## 디렉토리 생성

```typescript
// 재귀적 생성 (mkdir -p)
await fs.ensureDir('/path/to/nested/dir');

// 단일 생성
await fs.mkdir('/path/to/dir');
```

---

## 파일/디렉토리 복사

```typescript
// 파일 복사
await fs.copy('/src/file.txt', '/dest/file.txt');

// 디렉토리 복사 (재귀)
await fs.copy('/src/dir', '/dest/dir');

// 옵션
await fs.copy(src, dest, {
  overwrite: true,      // 덮어쓰기 (기본: true)
  errorOnExist: false,  // 존재 시 에러 (기본: false)
  filter: (src) => {    // 필터링
    return !src.includes('node_modules');
  },
});
```

---

## 파일/디렉토리 삭제

```typescript
// 삭제 (rm -rf)
await fs.remove('/path/to/dir');

// 빈 디렉토리만 삭제
await fs.rmdir('/path/to/empty-dir');
```

---

## 디렉토리 읽기

```typescript
// 파일/폴더 목록
const items = await fs.readdir('/path/to/dir');
// ['file1.txt', 'folder1', 'file2.txt']

// stat으로 타입 확인
for (const item of items) {
  const itemPath = path.join(dir, item);
  const stat = await fs.stat(itemPath);

  if (stat.isDirectory()) {
    // 디렉토리
  } else {
    // 파일
  }
}
```

---

## 파일 읽기/쓰기

```typescript
// 읽기
const content = await fs.readFile('/path/to/file', 'utf-8');

// 쓰기
await fs.writeFile('/path/to/file', content, 'utf-8');

// JSON 읽기
const data = await fs.readJson('/path/to/file.json');

// JSON 쓰기
await fs.writeJson('/path/to/file.json', data, { spaces: 2 });
```

---

## 파일 정보

```typescript
const stat = await fs.stat('/path/to/file');

stat.isFile();      // 파일 여부
stat.isDirectory(); // 디렉토리 여부
stat.size;          // 파일 크기 (bytes)
stat.mtime;         // 수정 시간
```

---

## 재귀 복사 패턴

```typescript
const copyRecursive = async (
  src: string,
  dest: string,
): Promise<{ files: number; directories: number }> => {
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
```

---

## ESM에서 __dirname 사용

```typescript
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 사용
const templatesDir = path.resolve(__dirname, '../templates');
```
