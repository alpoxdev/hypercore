---
description: 현재 세션에서 수정한 파일만 커밋 후 푸시
---

# Git Session Command

> @git-operator 에이전트를 사용하여 현재 세션 파일만 선택적으로 커밋하고 푸시.

---

<critical_requirements>

## ⚠️ CRITICAL: 작업 시작 전 필수 확인

**이 커맨드는 반드시 @git-operator 에이전트를 사용해야 합니다.**

### MANDATORY: Task 도구로 @git-operator 호출

```typescript
Task({
  subagent_type: 'git-operator',
  description: '세션 파일만 커밋 후 푸시',
  prompt: `
    세션 커밋 모드:
    - 현재 세션 관련 파일만 선택적 커밋
    - 반드시 푸시 (git push)
    - 이전 세션의 미완성 작업은 제외
  `
})
```

**❌ 절대 금지:**
- Bash 도구로 git 명령 직접 실행
- @git-operator 없이 커밋/푸시 수행
- 커맨드 내에서 직접 파일 분석

**✅ 필수:**
- Task 도구로 @git-operator 에이전트 호출
- 모든 git 작업을 에이전트에 위임
- 현재 세션 파일만 선택

---

**진행 전 자가 점검:**
```text
□ Task 도구 사용 준비?
□ @git-operator 에이전트로 작업 위임?
□ Bash로 git 직접 실행 안 함?
```

**⚠️ 위 체크리스트를 통과하지 않으면 작업을 시작하지 마세요.**

</critical_requirements>

---

<mode>

**세션 커밋 모드**

- **현재 세션 관련 파일만** 선택적 커밋
- **반드시 푸시** (git push)

</mode>

---

<selection_criteria>

| 포함 | 제외 |
|------|------|
| 현재 세션 관련 파일 | 이전 세션의 미완성 작업 |
| 방금 전 작업한 파일 | 자동 생성 파일 (lock, cache) |
| 관련 기능의 파일들 | 무관한 변경사항 |

</selection_criteria>

---

<workflow>

1. 모든 변경사항 분석
2. **현재 세션 관련 파일만 선택**
3. 논리적 단위로 그룹핑
4. 각 그룹별 커밋
5. git push 실행

</workflow>

---

<example>

```bash
# 상황: 로그인 기능 작업 중, 이전 프로필 기능은 미완성

git status
# modified: src/auth/login.ts (현재 세션)
# modified: src/auth/logout.ts (현재 세션)
# modified: src/profile/edit.ts (이전 세션)

# ✅ 로그인 관련만 커밋
git add src/auth/login.ts src/auth/logout.ts && git commit -m "feat: 로그인/로그아웃 기능 추가"
git push
```

</example>

---

<parallel_agent_execution>

## Recommended Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| **@git-operator** | haiku (기본), sonnet (복잡한 경우) | Git 커밋/푸시 작업 (필수) |
| **@code-reviewer** | haiku/sonnet | 세션 변경사항 검토 |
| **@explore** | haiku | 세션 파일 탐색 |

---

## Parallel Execution Patterns

| Pattern | Description |
|---------|-------------|
| **검토 + 탐색 병렬** | @code-reviewer와 @explore 동시 실행 |
| **분석 후 순차 커밋** | 병렬 분석 → 순차 git 작업 |

**❌ Git 커밋은 순차 실행:**
- git-session은 단일 커밋 흐름
- 병렬화 불필요

---

## Model Routing

| Complexity | Model | Scenario |
|------------|-------|----------|
| **LOW** | haiku | 단순 세션 커밋 (1-3 files, 간단한 변경) |
| **MEDIUM** | sonnet | 일반 세션 커밋 (4-10 files, 로직 변경) |

**선택 기준:**
- 파일 수 1-3개 + 단순 변경 → haiku
- 파일 수 4개 이상 또는 로직 변경 → sonnet

---

## Practical Examples

```typescript
// ✅ 병렬 분석 + 적절한 모델 선택
Task({
  subagent_type: 'code-reviewer',
  model: 'haiku',  // 간단한 검토
  prompt: '세션 변경사항 간단 검토'
})
Task({
  subagent_type: 'explore',
  model: 'haiku',  // 빠른 탐색
  prompt: '세션 파일 목록 확인'
})

// 분석 완료 후 복잡도에 맞는 모델로 커밋
// 단순한 경우
Task({
  subagent_type: 'git-operator',
  model: 'haiku',  // 1-3개 파일
  prompt: '세션 커밋 (간단한 변경)'
})

// 복잡한 경우
Task({
  subagent_type: 'git-operator',
  model: 'sonnet',  // 4개 이상 또는 로직 변경
  prompt: '세션 커밋 (여러 파일, 로직 변경)'
})
```

```typescript
// ❌ Git 커밋 병렬화 시도
// git-session은 단일 커밋이므로 병렬화 불필요
Task({ subagent_type: 'git-operator', prompt: '파일 A 커밋' })
Task({ subagent_type: 'git-operator', prompt: '파일 B 커밋' })  // 불필요
```

</parallel_agent_execution>
