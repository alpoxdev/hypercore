import fs from 'fs-extra';
import path from 'path';
import { logger } from '../shared/logger.js';
import {
  detectInstalledAgents,
  validateAgentNames,
  getValidAgentNames,
} from '../features/agents/index.js';
import type { AgentType, ScopeType } from '../features/agents/types.js';
import { installToAgents } from '../features/installer/index.js';
import { promptAgentSelection } from '../shared/prompts/index.js';

interface AddOptions {
  source: string;
  agents?: string[];
  global?: boolean;
  cwd?: string;
}

/**
 * 스킬 이름 추출 (디렉토리명 또는 SKILL.md의 name 필드)
 */
async function getSkillName(sourcePath: string): Promise<string> {
  // SKILL.md에서 name 파싱 시도
  const skillMdPath = path.join(sourcePath, 'SKILL.md');

  if (await fs.pathExists(skillMdPath)) {
    const content = await fs.readFile(skillMdPath, 'utf-8');
    const nameMatch = content.match(/^name:\s*(.+)$/m);
    if (nameMatch) {
      return nameMatch[1].trim();
    }
  }

  // SKILL.md가 없거나 name 필드가 없으면 디렉토리명 사용
  return path.basename(sourcePath);
}

/**
 * add 명령
 */
export async function add(options: AddOptions): Promise<void> {
  const { source } = options;
  const cwd = options.cwd || process.cwd();
  const scope: ScopeType = options.global ? 'global' : 'project';

  // 1. 소스 경로 검증
  const sourcePath = path.resolve(cwd, source);
  if (!(await fs.pathExists(sourcePath))) {
    logger.error(`Source path does not exist: ${sourcePath}`);
    process.exit(1);
  }

  const stat = await fs.stat(sourcePath);
  if (!stat.isDirectory()) {
    logger.error(`Source must be a directory: ${sourcePath}`);
    process.exit(1);
  }

  // 2. 스킬 이름 추출
  const skillName = await getSkillName(sourcePath);
  logger.info(`Adding skill: ${skillName}`);
  logger.step(`Source: ${sourcePath}`);

  // 3. 에이전트 선택 (유효성 검증 포함)
  let agents: AgentType[];
  if (options.agents && options.agents.length > 0) {
    const { valid, invalid } = validateAgentNames(options.agents);
    if (invalid.length > 0) {
      logger.error(`Unknown agents: ${invalid.join(', ')}`);
      logger.info(`Available agents: ${getValidAgentNames().join(', ')}`);
      process.exit(1);
    }
    agents = valid;
  } else {
    const installedAgents = await detectInstalledAgents();
    const result = await promptAgentSelection({ installedAgents });
    agents = result.agents;
  }

  // 4. 설치
  logger.blank();
  const result = await installToAgents(
    sourcePath,
    agents,
    scope,
    'skills',
    cwd,
    skillName,
  );

  if (result.success) {
    logger.blank();
    logger.success(`Skill '${skillName}' installed successfully!`);
    logger.info(`Mode: ${result.mode}`);
    logger.info('Installed to:');
    result.paths.forEach((p) => logger.step(p));
  } else {
    logger.blank();
    logger.error(`Failed to install skill: ${result.error}`);
    process.exit(1);
  }
}
