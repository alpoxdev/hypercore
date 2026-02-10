---
name: agent-teams-setup
description: 프로젝트에 Agent Teams 환경 구성. 에이전트 디렉토리, 환경변수, 기본 페르소나 생성.
user-invocable: true
---

@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Agent Teams Setup Skill

> Claude Code Agent Teams 환경을 프로젝트에 구성

---

<when_to_use>

| 상황 | 설명 |
|------|------|
| **새 프로젝트** | Agent Teams 처음 도입 |
| **팀 확장** | 기존 에이전트에 새 역할 추가 |
| **패턴 적용** | 특정 협업 패턴 구성 (리뷰, 파이프라인) |

</when_to_use>

---

<architecture>

## Agent Teams 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                     Team Lead                            │
│  - 전체 조율 및 의사결정                                  │
│  - TeamCreate로 팀 생성                                  │
│  - SendMessage로 팀원 관리                               │
└─────────────────────┬───────────────────────────────────┘
                      │ spawnTeam / broadcast / write
                      ▼
┌─────────────────────────────────────────────────────────┐
│              Shared Task List                            │
│  - TaskCreate/TaskUpdate로 작업 관리                     │
│  - blockedBy, addBlocks로 의존성 관리                    │
└─────────────────────────────────────────────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
    ┌──────────┐         ┌──────────┐         ┌──────────┐
    │ Teammate │         │ Teammate │         │ Teammate │
    │  Alpha   │◄───────►│   Beta   │◄───────►│  Gamma   │
    └──────────┘  Inbox  └──────────┘  Inbox  └──────────┘
```

**핵심 구성요소:**

| 구성요소 | 위치 | 설명 |
|---------|------|------|
| **에이전트 정의** | `.claude/agents/*.md` | YAML frontmatter + Markdown |
| **팀 설정** | `~/.claude/teams/{name}/` | 팀 config, inbox |
| **작업 목록** | `~/.claude/tasks/{name}/` | 공유 Task List |
| **환경변수** | `settings.json` | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` |

</architecture>

---

<frontmatter_spec>

## Persona Frontmatter 필드 (2026-02 기준)

| 필드 | 필수 | 설명 | 예시 |
|------|------|------|------|
| `name` | ✅ | 고유 식별자 (소문자+하이픈) | `security-auditor` |
| `description` | ✅ | 위임 판단용 설명 | `보안 취약점 분석 전문` |
| `tools` | ❌ | 허용 도구 배열 | `Read, Grep, Glob` |
| `disallowedTools` | ❌ | 차단 도구 배열 | `Write, Edit` |
| `model` | ❌ | `opus` \| `sonnet` \| `haiku` \| `inherit` | `sonnet` |
| `permissionMode` | ❌ | `default` \| `acceptEdits` \| `delegate` \| `dontAsk` \| `bypassPermissions` \| `plan` | `default` |
| `maxTurns` | ❌ | 최대 에이전틱 턴 수 | `50` |
| `memory` | ❌ | `user` \| `project` \| `local` | `project` |
| `skills` | ❌ | 로드할 스킬 배열 | `security-analysis` |
| `mcpServers` | ❌ | MCP 서버 목록 | `slack` |
| `hooks` | ❌ | 라이프사이클 훅 | (구조화된 배열) |

**주의사항:**
- `model`: 전체 ID (`claude-opus-4-6`) 아닌 **별칭** (`opus`) 사용
- `memory`: 객체가 아닌 **단일 문자열**
- `hooks`: 문자열 경로가 아닌 **구조화된 배열**

</frontmatter_spec>

---

<workflow>

## 셋업 워크플로우

| Step | 작업 | 도구 |
|------|------|------|
| **1. 환경 확인** | 기존 `.claude/agents/` 확인, 설정 파일 확인 | Glob, Read |
| **2. 환경변수 설정** | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 추가 | Edit |
| **3. 디렉토리 생성** | `.claude/agents/` 생성 | Bash |
| **4. 기본 에이전트 생성** | 역할별 페르소나 파일 생성 | Write |
| **5. 검증** | 프론트매터 형식 검증 | Grep |

</workflow>

---

<agent_templates>

## 기본 에이전트 템플릿

### 1. Explore (탐색)

```yaml
---
name: explore
description: 코드베이스 빠른 탐색. 파일/코드 패턴 검색, 구현 위치 파악.
tools: Read, Glob, Grep, Bash
disallowedTools:
  - Write
  - Edit
model: haiku
permissionMode: default
maxTurns: 20
---

# Explore Agent

코드베이스 탐색 전문가. 파일과 코드를 빠르게 찾아 정확한 정보 제공.

<workflow>
1. 의도 분석 (요청의 실제 의미 파악)
2. 병렬 도구 실행 (3개 이상 동시)
3. 결과 종합 및 정확한 위치 제공
</workflow>
```

### 2. Planner (계획)

```yaml
---
name: planner
description: 전략적 작업 계획 수립. 구현 전 인터뷰-조사-계획. 코드 작성 없이 계획만.
tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion
model: opus
permissionMode: plan
maxTurns: 50
---

# Planner Agent

전략적 계획 수립 전문가. **구현 없이 계획만 수립**.

<workflow>
1. 발견 인터뷰 (요구사항 파악)
2. 코드베이스 조사 (explore 위임)
3. 계획 작성 (.claude/plans/*.md)
4. 사용자 확인 대기
</workflow>
```

### 3. Implementer (구현)

```yaml
---
name: implementer
description: 계획/작업을 즉시 구현. Sequential Thinking으로 분석 후 실행.
tools: Read, Write, Edit, Grep, Glob, Task, Bash
model: sonnet
permissionMode: default
maxTurns: 100
---

# Implementer Agent

구현 전문가. 옵션 제시 없이 최적 방법으로 즉시 구현.

<workflow>
1. Sequential Thinking으로 복잡도 판단
2. Task(Explore)로 코드베이스 탐색
3. 최적 접근법 내부적으로 결정
4. 단계별 구현 및 검증
</workflow>
```

### 4. Reviewer (검토)

```yaml
---
name: reviewer
description: 코드 품질, 보안, 유지보수성 검토. git diff 기반 변경사항 분석.
tools: Read, Grep, Glob, Bash
disallowedTools:
  - Write
  - Edit
model: sonnet
permissionMode: default
maxTurns: 30
---

# Reviewer Agent

시니어 코드 리뷰어. 높은 기준 유지, 건설적 피드백 제공.

<workflow>
1. git diff로 변경사항 확인
2. 코드 품질/보안/성능 분석
3. 구체적 피드백 (파일:라인 참조)
4. 승인/수정 요청 결정
</workflow>
```

### 5. Tester (테스트)

```yaml
---
name: tester
description: 테스트 작성 및 실행. TDD 사이클, 80%+ 커버리지 목표.
tools: Read, Write, Edit, Bash, Glob
model: sonnet
permissionMode: default
maxTurns: 50
---

# Tester Agent

테스트 전문가. Red-Green-Refactor 사이클, 높은 커버리지 보장.

<workflow>
1. 테스트 대상 분석
2. 테스트 케이스 작성 (엣지 케이스 포함)
3. 테스트 실행 및 검증
4. 커버리지 확인
</workflow>
```

</agent_templates>

---

<team_patterns>

## 팀 구성 패턴

### 패턴 1: 병렬 전문가 리뷰

```
Code Change
     │
     ├──► Security Expert
     ├──► Performance Expert
     └──► Testing Expert
              │
              ▼
         Team Lead (종합 판정)
```

**적용:** PR 리뷰 자동화

### 패턴 2: 순차 파이프라인

```
Research → Plan → Implement → Test → Review → Deploy
   │        │         │         │       │        │
[Task 1] → [Task 2] → [Task 3] → [Task 4] → [Task 5]
          blockedBy   blockedBy  blockedBy  blockedBy
```

**적용:** 신규 기능 개발

### 패턴 3: Cross-Layer 협업

```
          ┌── Frontend (React) ──┐
API Spec ─┼── Backend (Node.js) ─┼─► Integration Test
          └── Test Agent ────────┘
```

**적용:** 풀스택 기능 구현

### 패턴 4: 경쟁적 가설 검증

```
     ┌── Conservative Analyst
     ├── Innovative Analyst
Lead ┼── Pragmatic Analyst
     ├── Devil's Advocate
     └── Synthesizer (종합)
```

**적용:** 복잡한 버그 조사, 아키텍처 결정

</team_patterns>

---

<model_routing>

## 모델 라우팅

| 복잡도 | 모델 | 대표 역할 | 비용 |
|--------|------|----------|------|
| **LOW** | haiku | explore, document-writer | 💰 |
| **MEDIUM** | sonnet | implementer, reviewer, tester | 💰💰 |
| **HIGH** | opus | planner, architect, security | 💰💰💰 |

**비용 최적화:**
- 탐색 작업 → haiku (빠르고 저렴)
- 구현/검토 → sonnet (균형)
- 전략/보안 → opus (최고 품질)

</model_routing>

---

<examples>

## 셋업 예시

### 새 프로젝트 셋업

```bash
/agent-teams-setup

# 1. 환경변수 설정
# ~/.claude/settings.json에 추가:
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}

# 2. 디렉토리 생성
mkdir -p .claude/agents

# 3. 기본 에이전트 생성
# - .claude/agents/explore.md
# - .claude/agents/planner.md
# - .claude/agents/implementer.md
# - .claude/agents/reviewer.md
# - .claude/agents/tester.md

# 4. 검증
grep -r "^name:" .claude/agents/
grep -r "^model:" .claude/agents/
```

### 특정 패턴 셋업

```bash
/agent-teams-setup 병렬 리뷰 패턴

# 리뷰 전문가 팀 생성
# - .claude/agents/security-reviewer.md
# - .claude/agents/performance-reviewer.md
# - .claude/agents/testing-reviewer.md
# - .claude/agents/review-lead.md
```

### 기존 프로젝트 확장

```bash
/agent-teams-setup 보안 에이전트 추가

# .claude/agents/security-auditor.md 생성
---
name: security-auditor
description: 보안 취약점 분석 전문. OWASP Top 10, 시크릿 노출, 입력 검증.
tools: Read, Grep, Glob, Bash
disallowedTools:
  - Write
  - Edit
model: opus
permissionMode: default
maxTurns: 30
---
```

</examples>

---

<validation>

## 셋업 체크리스트

```text
□ Phase 1: 환경 구성
  □ CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 설정
  □ .claude/agents/ 디렉토리 생성
  □ settings.json 업데이트

□ Phase 2: 기본 에이전트
  □ explore (탐색) - haiku, READ-ONLY
  □ planner (계획) - opus, plan 모드
  □ implementer (구현) - sonnet
  □ reviewer (검토) - sonnet, READ-ONLY
  □ tester (테스트) - sonnet

□ Phase 3: Frontmatter 검증
  □ name: 소문자+하이픈
  □ description: 필수
  □ model: opus/sonnet/haiku (별칭)
  □ permissionMode: 유효한 값
  □ maxTurns: 역할에 맞는 값
  □ disallowedTools: READ-ONLY 에이전트에 Write, Edit 차단

□ Phase 4: 팀 패턴 (선택)
  □ 병렬 리뷰 패턴
  □ 순차 파이프라인
  □ Cross-Layer 협업
  □ 경쟁적 가설 검증
```

## 금지 사항

| 금지 | 이유 |
|------|------|
| 전체 모델 ID 사용 | `claude-opus-4-6` → `opus` |
| memory 객체 사용 | 단일 문자열만 허용 |
| hooks 문자열 경로 | 구조화된 배열 필요 |
| permissionMode: strict | 존재하지 않는 값 |

</validation>

---

<cost_considerations>

## 비용 고려사항

| 방식 | 시간당 비용 | 적합 작업 |
|------|-----------|----------|
| **직접 처리** | $5-20 | 단순 수정 |
| **Subagent** | $20-100 | 탐색, 단일 위임 |
| **Agent Teams** | $50-150 | 복잡한 병렬 협업 |

**비용 최적화 전략:**
- 모델 티어링: 탐색=Haiku, 분석=Sonnet, 구현=Opus
- Task 그래뉼래리티: 2-4시간 단위로 분할
- 조기 종료: maxTurns 설정, 작업 완료 시 즉시 종료
- 컨텍스트 공유: 공통 정보는 공유 메모리에

</cost_considerations>

---

<references>

## 참고자료

| 제목 | URL |
|------|-----|
| Agent Teams 공식 문서 | https://code.claude.com/docs/en/agent-teams |
| Sub-agents 공식 문서 | https://code.claude.com/docs/en/sub-agents |
| Claude Opus 4.6 발표 | https://www.anthropic.com/news/claude-opus-4-6 |

</references>
