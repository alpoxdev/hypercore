import fs from 'fs-extra';
import path from 'path';

/**
 * 스킬 메타데이터 인터페이스
 * SKILL.md frontmatter에서 파싱
 */
export interface SkillMetadata {
  name: string;
  description: string;
  userInvocable?: boolean;
  uiOnly?: boolean;
  framework?: string;
}

/**
 * SKILL.md frontmatter 파싱
 * yaml 라이브러리 없이 간단한 key: value 파싱
 */
export const parseSkillMetadata = async (
  skillPath: string,
): Promise<SkillMetadata | null> => {
  const skillMdPath = path.join(skillPath, 'SKILL.md');

  if (!(await fs.pathExists(skillMdPath))) {
    return null;
  }

  const content = await fs.readFile(skillMdPath, 'utf-8');
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);

  if (!frontmatterMatch) {
    return null;
  }

  const frontmatter = frontmatterMatch[1];
  const metadata: SkillMetadata = {
    name: '',
    description: '',
  };

  // 간단한 YAML 파싱 (key: value 형식만 지원)
  const lines = frontmatter.split('\n');
  for (const line of lines) {
    const colonIndex = line.indexOf(':');
    if (colonIndex === -1) continue;

    const key = line.slice(0, colonIndex).trim();
    const value = line.slice(colonIndex + 1).trim();

    switch (key) {
      case 'name':
        metadata.name = value;
        break;
      case 'description':
        metadata.description = value;
        break;
      case 'user-invocable':
        metadata.userInvocable = value === 'true';
        break;
      case 'ui-only':
        metadata.uiOnly = value === 'true';
        break;
      case 'framework':
        metadata.framework = value;
        break;
    }
  }

  return metadata;
};

/**
 * 모든 스킬의 메타데이터 로드
 * 스킬 폴더를 동적 탐색하여 각 SKILL.md 파싱
 */
export const loadAllSkillMetadata = async (
  skillsSrc: string,
): Promise<Map<string, SkillMetadata>> => {
  const metadataMap = new Map<string, SkillMetadata>();

  if (!(await fs.pathExists(skillsSrc))) {
    return metadataMap;
  }

  const entries = await fs.readdir(skillsSrc, { withFileTypes: true });

  for (const entry of entries) {
    if (entry.isDirectory()) {
      const skillPath = path.join(skillsSrc, entry.name);
      const metadata = await parseSkillMetadata(skillPath);
      if (metadata) {
        // 이름이 없으면 폴더명 사용
        if (!metadata.name) {
          metadata.name = entry.name;
        }
        metadataMap.set(entry.name, metadata);
      }
    }
  }

  return metadataMap;
};
