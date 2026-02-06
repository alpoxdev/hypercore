import os from 'os';
import fs from 'fs-extra';
import path from 'path';
import type { AgentConfig, AgentType } from './types.js';

/**
 * 에이전트별 설정 레지스트리
 */
const AGENTS: Record<AgentType, AgentConfig> = {
  'claude-code': {
    name: 'claude-code',
    displayName: 'Claude Code',
    projectExtras: {
      skills: '.claude/skills',
      commands: '.claude/commands',
      agents: '.claude/agents',
      instructions: '.claude/instructions',
    },
    globalExtras: {
      skills: '~/.claude/skills',
      commands: '~/.claude/commands',
      agents: '~/.claude/agents',
      instructions: '~/.claude/instructions',
    },
    detectInstalled: async () => {
      const claudeDir = path.join(os.homedir(), '.claude');
      return await fs.pathExists(claudeDir);
    },
  },

  codex: {
    name: 'codex',
    displayName: 'Codex',
    projectExtras: {
      skills: '.codex/skills',
    },
    globalExtras: {
      skills: '~/.codex/skills',
    },
    detectInstalled: async () => {
      const codexDir = path.join(os.homedir(), '.codex');
      return await fs.pathExists(codexDir);
    },
  },

  antigravity: {
    name: 'antigravity',
    displayName: 'Antigravity',
    projectExtras: {
      skills: '.agent/skills',
    },
    globalExtras: {
      skills: '~/.gemini/antigravity/skills',
    },
    detectInstalled: async () => {
      const antigravityDir = path.join(os.homedir(), '.gemini', 'antigravity');
      return await fs.pathExists(antigravityDir);
    },
  },

  cursor: {
    name: 'cursor',
    displayName: 'Cursor',
    projectExtras: {
      skills: '.cursor/skills',
    },
    globalExtras: {
      skills: '~/.cursor/skills',
    },
    detectInstalled: async () => {
      const cursorDir = path.join(os.homedir(), '.cursor');
      return await fs.pathExists(cursorDir);
    },
  },
};

/**
 * 설치된 에이전트 자동 감지
 * 병렬로 모든 에이전트 검사하여 설치된 목록 반환
 */
export async function detectInstalledAgents(): Promise<AgentType[]> {
  const agents = Object.values(AGENTS);
  const results = await Promise.all(
    agents.map(async (agent) => ({
      name: agent.name,
      installed: await agent.detectInstalled(),
    })),
  );

  return results.filter((r) => r.installed).map((r) => r.name);
}

/**
 * 특정 에이전트 설정 반환
 */
export function getAgent(name: AgentType): AgentConfig {
  const agent = AGENTS[name];
  if (!agent) {
    throw new Error(`Unknown agent: ${name}`);
  }
  return agent;
}

/**
 * 모든 에이전트 목록 반환
 */
export function getAllAgents(): AgentConfig[] {
  return Object.values(AGENTS);
}

/**
 * 유효한 에이전트 이름 목록 반환
 */
export function getValidAgentNames(): AgentType[] {
  return Object.keys(AGENTS) as AgentType[];
}

/**
 * 문자열이 유효한 에이전트 이름인지 확인
 */
export function isValidAgentName(name: string): name is AgentType {
  return name in AGENTS;
}

/**
 * CLI에서 입력된 에이전트 이름 목록 유효성 검증
 * 유효하지 않은 이름이 있으면 에러 메시지와 함께 null 반환
 */
export function validateAgentNames(names: string[]): {
  valid: AgentType[];
  invalid: string[];
} {
  const valid: AgentType[] = [];
  const invalid: string[] = [];

  for (const name of names) {
    if (isValidAgentName(name)) {
      valid.push(name);
    } else {
      invalid.push(name);
    }
  }

  return { valid, invalid };
}
