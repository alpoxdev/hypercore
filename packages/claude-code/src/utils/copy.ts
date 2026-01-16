import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getTemplatesDir = (): string => {
  // dist/index.js -> templates/ (tsup bundles everything into one file)
  return path.resolve(__dirname, '../templates');
};

// 디렉토리에 파일이 실제로 존재하는지 체크
const hasFiles = async (dir: string): Promise<boolean> => {
  if (!(await fs.pathExists(dir))) return false;
  const items = await fs.readdir(dir);
  return items.length > 0;
};

export const getTemplatePath = (template: string): string => {
  return path.join(getTemplatesDir(), template);
};

const copyRecursive = async (
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

/**
 * 단일 템플릿 복사 (CLAUDE.md → 루트, docs/ → 루트/docs/)
 * 기존 docs 폴더는 삭제 후 새로 복사
 */
export const copySingleTemplate = async (
  template: string,
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const templatePath = getTemplatePath(template);

  if (!(await fs.pathExists(templatePath))) {
    throw new Error(`Template "${template}" not found at ${templatePath}`);
  }

  const counter = { files: 0, directories: 0 };

  // CLAUDE.md → 루트
  const claudeMdSrc = path.join(templatePath, 'CLAUDE.md');
  if (await fs.pathExists(claudeMdSrc)) {
    await fs.copy(claudeMdSrc, path.join(targetDir, 'CLAUDE.md'));
    counter.files++;
  }

  // docs/ → 루트/docs/ (기존 폴더 삭제 후 복사)
  const docsSrc = path.join(templatePath, 'docs');
  const docsDest = path.join(targetDir, 'docs');
  if (await fs.pathExists(docsSrc)) {
    // 기존 docs 폴더 삭제
    if (await fs.pathExists(docsDest)) {
      await fs.remove(docsDest);
    }
    await copyRecursive(docsSrc, docsDest, counter);
  }

  return counter;
};

/**
 * 다중 템플릿 복사 (각 템플릿 폴더 전체 → 루트/docs/템플릿명/)
 * 기존 docs 폴더는 삭제 후 새로 복사
 * 루트 CLAUDE.md는 각 템플릿의 CLAUDE.md를 인덱싱
 */
export const copyMultipleTemplates = async (
  templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };

  // 기존 docs 폴더 삭제
  const docsDir = path.join(targetDir, 'docs');
  if (await fs.pathExists(docsDir)) {
    await fs.remove(docsDir);
  }

  for (const template of templates) {
    const templatePath = getTemplatePath(template);

    if (!(await fs.pathExists(templatePath))) {
      throw new Error(`Template "${template}" not found at ${templatePath}`);
    }

    // 템플릿 폴더 전체 → docs/템플릿명/
    await copyRecursive(
      templatePath,
      path.join(targetDir, 'docs', template),
      counter,
    );
  }

  // 루트 CLAUDE.md 생성 (각 템플릿 CLAUDE.md 인덱싱)
  const indexContent = generateIndexClaudeMd(templates);
  await fs.writeFile(path.join(targetDir, 'CLAUDE.md'), indexContent);
  counter.files++;

  return counter;
};

/**
 * 다중 템플릿용 인덱스 CLAUDE.md 생성
 */
const generateIndexClaudeMd = (templates: string[]): string => {
  const templateLinks = templates
    .map((t) => `- [${t}](docs/${t}/CLAUDE.md)`)
    .join('\n');

  return `# CLAUDE.md

> 이 프로젝트는 여러 템플릿의 Claude Code 문서를 포함합니다.

## 템플릿 문서

${templateLinks}

## 사용법

각 템플릿의 \`CLAUDE.md\`를 참조하여 해당 기술 스택의 가이드라인을 확인하세요.
`;
};

export const checkExistingFiles = async (
  targetDir: string,
): Promise<string[]> => {
  const existingFiles: string[] = [];

  const claudeMd = path.join(targetDir, 'CLAUDE.md');
  const docsDir = path.join(targetDir, 'docs');

  if (await fs.pathExists(claudeMd)) {
    existingFiles.push('CLAUDE.md');
  }

  if (await fs.pathExists(docsDir)) {
    existingFiles.push('docs/');
  }

  return existingFiles;
};

export const listAvailableTemplates = async (): Promise<string[]> => {
  const templatesDir = getTemplatesDir();

  if (!(await fs.pathExists(templatesDir))) {
    return [];
  }

  const items = await fs.readdir(templatesDir);
  const templates: string[] = [];

  for (const item of items) {
    // .으로 시작하는 폴더는 제외 (.claude 등)
    if (item.startsWith('.')) {
      continue;
    }
    const itemPath = path.join(templatesDir, item);
    const stat = await fs.stat(itemPath);
    if (stat.isDirectory()) {
      templates.push(item);
    }
  }

  return templates;
};

/**
 * 템플릿별 스킬 매핑
 */
const TEMPLATE_SKILLS_MAP: Record<string, string[]> = {
  nextjs: ['nextjs-react-best-practices', 'vs-design-diverge'],
  'tanstack-start': [
    'tanstack-start-react-best-practices',
    'vs-design-diverge',
  ],
  // hono와 npx는 스킬 없음
};

/**
 * Skills 복사 (templates/.claude/skills/ → 타겟/.claude/skills/)
 * 선택된 템플릿에 해당하는 스킬만 복사
 */
export const copySkills = async (
  templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetSkillsDir = path.join(targetDir, '.claude', 'skills');
  const skillsSrc = path.join(getTemplatesDir(), '.claude', 'skills');

  if (!(await fs.pathExists(skillsSrc))) {
    return counter;
  }

  await fs.ensureDir(targetSkillsDir);

  // 선택된 템플릿에 해당하는 스킬들 수집
  const skillsToCopy = new Set<string>();
  for (const template of templates) {
    const skills = TEMPLATE_SKILLS_MAP[template] || [];
    skills.forEach((skill) => skillsToCopy.add(skill));
  }

  // 매핑된 스킬만 복사
  for (const skill of skillsToCopy) {
    const skillSrc = path.join(skillsSrc, skill);
    const skillDest = path.join(targetSkillsDir, skill);

    if (await fs.pathExists(skillSrc)) {
      await copyRecursive(skillSrc, skillDest, counter);
    }
  }

  return counter;
};

/**
 * Commands 복사 (templates/.claude/commands/ → 타겟/.claude/commands/)
 * Commands는 .md 파일 기반 구조
 */
export const copyCommands = async (
  _templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetCommandsDir = path.join(targetDir, '.claude', 'commands');
  const commandsSrc = path.join(getTemplatesDir(), '.claude', 'commands');

  if (await fs.pathExists(commandsSrc)) {
    await fs.ensureDir(targetCommandsDir);
    await copyRecursive(commandsSrc, targetCommandsDir, counter);
  }

  return counter;
};

/**
 * Skills와 Commands가 존재하는지 확인
 */
export const checkSkillsAndCommandsExist = async (
  _templates: string[],
): Promise<{ hasSkills: boolean; hasCommands: boolean }> => {
  const claudeDir = path.join(getTemplatesDir(), '.claude');
  const skillsSrc = path.join(claudeDir, 'skills');
  const commandsSrc = path.join(claudeDir, 'commands');

  const hasSkills = await fs.pathExists(skillsSrc);
  const hasCommands = await fs.pathExists(commandsSrc);

  return { hasSkills, hasCommands };
};

/**
 * 기존 .claude/skills, .claude/commands, .claude/agents 파일 확인
 */
export const checkExistingClaudeFiles = async (
  targetDir: string,
): Promise<string[]> => {
  const existingFiles: string[] = [];

  const skillsDir = path.join(targetDir, '.claude', 'skills');
  const commandsDir = path.join(targetDir, '.claude', 'commands');
  const agentsDir = path.join(targetDir, '.claude', 'agents');

  if (await fs.pathExists(skillsDir)) {
    existingFiles.push('.claude/skills/');
  }

  if (await fs.pathExists(commandsDir)) {
    existingFiles.push('.claude/commands/');
  }

  if (await fs.pathExists(agentsDir)) {
    existingFiles.push('.claude/agents/');
  }

  return existingFiles;
};

/**
 * Agents 복사 (templates/.claude/agents/ → 타겟/.claude/agents/)
 * Agents는 .md 파일 기반 구조
 */
export const copyAgents = async (
  _templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetAgentsDir = path.join(targetDir, '.claude', 'agents');
  const agentsSrc = path.join(getTemplatesDir(), '.claude', 'agents');

  if (await fs.pathExists(agentsSrc)) {
    await fs.ensureDir(targetAgentsDir);
    await copyRecursive(agentsSrc, targetAgentsDir, counter);
  }

  return counter;
};

/**
 * Skills, Commands, Agents가 존재하는지 확인
 */
export const checkAllExtrasExist = async (
  templates: string[],
): Promise<{
  hasSkills: boolean;
  hasCommands: boolean;
  hasAgents: boolean;
}> => {
  const claudeDir = path.join(getTemplatesDir(), '.claude');
  const commandsSrc = path.join(claudeDir, 'commands');
  const agentsSrc = path.join(claudeDir, 'agents');

  // 스킬: 선택된 템플릿에 매핑된 스킬이 있는지 확인
  const hasSkills = templates.some((template) => {
    const skills = TEMPLATE_SKILLS_MAP[template];
    return skills && skills.length > 0;
  });

  const hasCommands = await hasFiles(commandsSrc);
  const hasAgents = await hasFiles(agentsSrc);

  return { hasSkills, hasCommands, hasAgents };
};
