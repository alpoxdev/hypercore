import fs from 'fs-extra';
import path from 'path';

// 디렉토리에 파일이 실제로 존재하는지 체크
export const hasFiles = async (dir: string): Promise<boolean> => {
  if (!(await fs.pathExists(dir))) return false;
  const items = await fs.readdir(dir);
  return items.length > 0;
};

export const copyRecursive = async (
  src: string,
  dest: string,
  counter: { files: number; directories: number },
): Promise<void> => {
  const stat = await fs.stat(src);

  if (stat.isDirectory()) {
    await fs.ensureDir(dest);
    counter.directories++;

    const items = await fs.readdir(src);
    for (const item of items) {
      await copyRecursive(path.join(src, item), path.join(dest, item), counter);
    }
  } else {
    await fs.copy(src, dest);
    counter.files++;
  }
};
