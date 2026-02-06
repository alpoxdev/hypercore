import { logger } from '../shared/logger.js';
import {
  detectInstalledAgents,
  validateAgentNames,
  getValidAgentNames,
} from '../features/agents/index.js';
import type { AgentType, ScopeType } from '../features/agents/types.js';
import { uninstallFromAgents } from '../features/installer/index.js';
import {
  promptConfirm,
  promptAgentSelection,
} from '../shared/prompts/index.js';

interface RemoveOptions {
  name: string;
  agents?: string[];
  global?: boolean;
  cwd?: string;
  force?: boolean;
}

/**
 * remove 명령
 */
export async function remove(options: RemoveOptions): Promise<void> {
  const { name, force } = options;
  const cwd = options.cwd || process.cwd();
  const scope: ScopeType = options.global ? 'global' : 'project';

  // 1. 확인 프롬프트 (force 옵션이 없으면)
  if (!force) {
    const result = await promptConfirm(
      `Remove skill '${name}' from ${scope} scope?`,
      false,
    );

    if (!result.confirmed) {
      logger.info('Operation cancelled.');
      return;
    }
  }

  // 2. 에이전트 선택 (유효성 검증 포함)
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

  // 3. 제거
  logger.blank();
  logger.info(`Removing skill '${name}'...`);

  await uninstallFromAgents(name, agents, scope, 'skills', cwd);

  logger.blank();
  logger.success(`Skill '${name}' removed successfully!`);
}
