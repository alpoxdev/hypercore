import fs from 'fs-extra';
import path from 'path';
import os from 'os';
import { logger } from '../shared/logger.js';
import { CANONICAL_DIR } from '../shared/constants.js';
import {
  detectInstalledAgents,
  getAgent,
  resolveExtrasDir,
  validateAgentNames,
  getValidAgentNames,
} from '../features/agents/index.js';
import type { AgentType, ScopeType } from '../features/agents/types.js';
import { isSymlink } from '../features/installer/index.js';

interface ListOptions {
  agents?: string[];
  global?: boolean;
  cwd?: string;
}

/**
 * 스킬 목록 조회
 */
async function listSkills(
  scope: ScopeType,
  agents: AgentType[],
  cwd: string,
): Promise<void> {
  logger.blank();
  logger.info(`Installed skills (${scope} scope):`);
  logger.blank();

  // 정규 위치에서 스킬 목록 조회
  const canonicalBase =
    scope === 'global'
      ? path.join(os.homedir(), CANONICAL_DIR)
      : path.join(cwd, CANONICAL_DIR);

  const canonicalSkillsDir = path.join(canonicalBase, 'skills');

  if (!(await fs.pathExists(canonicalSkillsDir))) {
    logger.warn('No skills installed.');
    return;
  }

  const skills = await fs.readdir(canonicalSkillsDir);

  if (skills.length === 0) {
    logger.warn('No skills installed.');
    return;
  }

  for (const skill of skills) {
    const canonicalPath = path.join(canonicalSkillsDir, skill);
    const stat = await fs.stat(canonicalPath);

    if (!stat.isDirectory()) {
      continue;
    }

    logger.info(`  ${skill}`);
    logger.step(`    Canonical: ${canonicalPath}`);

    // 각 에이전트별 심링크 상태 표시
    for (const agentName of agents) {
      const agent = getAgent(agentName);
      const agentSkillsDir = resolveExtrasDir(agent, scope, 'skills', cwd);

      if (!agentSkillsDir) {
        logger.step(`    ${agentName}: not supported`);
        continue;
      }

      const agentPath = path.join(agentSkillsDir, skill);

      if (!(await fs.pathExists(agentPath))) {
        logger.step(`    ${agentName}: not installed`);
        continue;
      }

      const isLink = await isSymlink(agentPath);
      const status = isLink ? 'symlink' : 'copy';
      logger.step(`    ${agentName}: ${status} -> ${agentPath}`);
    }
  }

  logger.blank();
}

/**
 * list 명령
 */
export async function list(options: ListOptions): Promise<void> {
  const cwd = options.cwd || process.cwd();
  const scope: ScopeType = options.global ? 'global' : 'project';

  // 에이전트 선택 (CLI 옵션 또는 자동 감지, 유효성 검증 포함)
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
    agents = await detectInstalledAgents();
    if (agents.length === 0) {
      agents = ['claude-code'];
    }
  }

  await listSkills(scope, agents, cwd);
}
