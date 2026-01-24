---
description: 모든 변경사항 커밋 후 푸시
---

# Git All Command

> @git-operator 에이전트를 사용하여 모든 변경사항을 커밋하고 푸시.

---

<critical_requirements>

## ⚠️ CRITICAL: 작업 시작 전 필수 확인

**이 커맨드는 반드시 @git-operator 에이전트를 사용해야 합니다.**

### MANDATORY: Task 도구로 @git-operator 호출

```typescript
Task({
  subagent_type: 'git-operator',
  description: '모든 변경사항 커밋 후 푸시',
  prompt: `
    전체 커밋 모드:
    - 모든 변경사항을 논리적 단위로 분리하여 전부 커밋
    - 반드시 푸시 (git push)
    - clean working directory 확인 필수
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
- 완료 후 clean working directory 확인

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

**전체 커밋 모드**

- **모든 변경사항**을 논리적 단위로 분리하여 **전부 커밋**
- **반드시 푸시** (git push)
- **남은 변경사항 없음** (clean working directory) 확인 필수

</mode>

---

<workflow>

1. 모든 변경사항 분석
2. 논리적 단위로 그룹핑
3. 각 그룹별 커밋 (반복)
4. clean working directory 확인
5. git push 실행

</workflow>

---

<parallel_agent_execution>

## 병렬 에이전트 실행

### Recommended Agents

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **@git-operator** | haiku (기본), sonnet (복잡한 경우) | Git 커밋/푸시 작업 (순차 실행 필수) |
| **@code-reviewer** | haiku/sonnet | 변경사항 검토 |
| **@explore** | haiku | 변경된 파일 탐색 및 영향도 분석 |

---

### Parallel Execution Patterns

#### 0. 분석 단계 병렬 (git-operator 내부)

**git-operator는 분석 단계를 병렬로 실행:**

```typescript
// ✅ git-operator 내부에서 자동으로 병렬 실행
// 단일 메시지에서 git status + git diff 동시 호출
Task({
  subagent_type: 'git-operator',
  model: 'haiku',
  prompt: '전체 커밋 모드'
})

// git-operator가 내부적으로:
// Bash: git status (동시 실행)
// Bash: git diff   (동시 실행)
// → 분석 결과 기반 논리적 그룹핑
// → 순차 커밋
```

**병렬 분석으로 인한 성능 향상:**
- 순차 실행: git status (1초) → git diff (1초) = 2초
- 병렬 실행: git status + git diff (동시) = 1초

#### 1. 검토 + 탐색 병렬

```typescript
// ✅ 분석 단계를 병렬로 실행
Task({
  subagent_type: 'code-reviewer',
  model: 'sonnet',
  description: '변경된 코드 품질 검토',
  prompt: '모든 변경사항의 코드 품질, 잠재적 버그, 개선점 검토'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: '변경 파일 영향도 분석',
  prompt: '변경된 파일들이 다른 모듈에 미치는 영향 분석'
})

// 병렬 분석 완료 후 순차 커밋
Task({
  subagent_type: 'git-operator',
  description: '분석 결과 기반 커밋 및 푸시',
  prompt: '검토/분석 결과를 반영하여 커밋'
})
```

#### 2. 여러 저장소 병렬 작업

```typescript
// ✅ 독립적인 저장소는 병렬 처리 가능
Task({
  subagent_type: 'git-operator',
  model: 'haiku',
  description: '프론트엔드 저장소 커밋',
  prompt: 'frontend/ 디렉토리 변경사항 커밋 및 푸시'
})

Task({
  subagent_type: 'git-operator',
  model: 'haiku',
  description: '백엔드 저장소 커밋',
  prompt: 'backend/ 디렉토리 변경사항 커밋 및 푸시'
})
```

**⚠️ 주의:** 동일 저장소의 커밋은 반드시 순차 실행

#### 3. 분석 후 순차 커밋

```typescript
// 1단계: 병렬 분석
Task({ subagent_type: 'explore', prompt: '파일 변경 범위 파악' })
Task({ subagent_type: 'code-reviewer', prompt: '코드 품질 검토' })

// 2단계: 순차 커밋 (병렬 분석 완료 대기 후)
Task({
  subagent_type: 'git-operator',
  description: '전체 커밋 및 푸시',
  prompt: '분석 결과 기반 논리적 단위 커밋'
})
```

---

### Model Routing

| 복잡도 | 조건 | 권장 모델 | 예시 |
|--------|------|----------|------|
| **LOW** | 1-3개 파일, 단순 변경 | haiku | 오타 수정, 문서 업데이트 |
| **MEDIUM** | 4-10개 파일, 로직 변경 | sonnet | 기능 추가, 버그 수정 |

**선택 기준:**
- 파일 수와 변경 복잡도 고려
- 대부분의 경우 haiku로 충분
- 복잡한 로직 변경 시 sonnet

---

### Practical Examples

#### ✅ 올바른 병렬 실행

```typescript
// 검토 + 탐색 병렬 → 복잡도에 맞는 모델로 커밋
Task({
  subagent_type: 'code-reviewer',
  model: 'sonnet',
  prompt: '변경된 코드 품질 검토'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '변경 파일 영향도 분석'
})

// 병렬 작업 완료 후 복잡도에 맞는 모델로 실행
// 간단한 경우
Task({
  subagent_type: 'git-operator',
  model: 'haiku',  // 1-3개 파일
  description: '모든 변경사항 커밋 후 푸시',
  prompt: '검토 결과 반영하여 전체 커밋'
})

// 복잡한 경우
Task({
  subagent_type: 'git-operator',
  model: 'sonnet',  // 4개 이상 또는 로직 변경
  description: '모든 변경사항 커밋 후 푸시',
  prompt: '검토 결과 반영하여 전체 커밋'
})
```

#### ❌ 잘못된 병렬 실행

```typescript
// ❌ 여러 커밋을 병렬로 실행 (충돌 위험)
Task({ subagent_type: 'git-operator', prompt: '커밋 1' })
Task({ subagent_type: 'git-operator', prompt: '커밋 2' })
Task({ subagent_type: 'git-operator', prompt: '커밋 3' })

// ❌ 동일 저장소에 병렬 푸시
Task({ subagent_type: 'git-operator', prompt: '푸시 1' })
Task({ subagent_type: 'git-operator', prompt: '푸시 2' })
```

---

### 핵심 원칙

| 작업 유형 | 실행 방식 | 이유 |
|-----------|----------|------|
| **Git 분석 (status/diff)** | 병렬 가능 | 읽기 전용, 충돌 없음 |
| **분석/검토** | 병렬 가능 | 읽기 전용 작업, 충돌 없음 |
| **Git 커밋/푸시** | 순차 필수 | 저장소 상태 변경, 충돌 위험 |
| **다중 저장소** | 병렬 가능 | 독립적인 저장소 |

```typescript
// ✅ 권장 패턴
// 1. 병렬 분석
const analysisPromises = [
  Task({ subagent_type: 'explore', ... }),
  Task({ subagent_type: 'code-reviewer', ... })
]

// 2. 분석 완료 대기 후 순차 커밋
Task({ subagent_type: 'git-operator', ... })
```

</parallel_agent_execution>
