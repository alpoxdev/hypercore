---
description: 프로젝트 버전 업데이트 및 커밋
allowed-tools: Bash, Read, Edit
argument-hint: <new-version | +1 | +minor | +major>
---

@../instructions/git-rules.md

# Version Update Command

프로젝트 전체 버전을 업데이트하고 커밋.

**인수**: $ARGUMENTS

<version_rules>

| 인수 | 동작 | 예시 |
|------|------|------|
| `+1` | patch +1 | 0.1.13 → 0.1.14 |
| `+minor` | minor +1 | 0.1.13 → 0.2.0 |
| `+major` | major +1 | 0.1.13 → 1.0.0 |
| `x.x.x` | 직접 지정 | 0.1.13 → 2.0.0 |

</version_rules>

<workflow>

1. **버전 파일 탐색**
   ```bash
   # package.json 찾기 (root 또는 monorepo packages/)
   fd -t f 'package.json' -E node_modules

   # 버전 코드 찾기 (.version() 패턴)
   rg "\.version\(['\"]" --type ts --type js -l
   ```

2. **현재 버전 확인** (병렬 읽기)
   - 발견된 package.json 파일들
   - 버전 코드 포함 파일들

3. **새 버전 계산**

4. **모든 파일 Edit로 업데이트**

5. **스테이징**
   ```bash
   git add <발견된-버전-파일들>
   ```

6. **커밋**
   ```bash
   git commit -m "chore: 버전 X.X.X로 업데이트"
   ```

7. **완료 확인**
   ```bash
   git status
   ```

</workflow>

<parallel_agent_execution>

## Recommended Agents

| Agent | Model | 용도 |
|-------|-------|------|
| @git-operator | haiku | 버전 커밋 및 태그 |
| @document-writer | haiku | CHANGELOG 작성 |
| @code-reviewer | haiku | 변경사항 검토 |

## Parallel Execution Patterns

```typescript
// ✅ 문서 작성 병렬 (독립적 작업)
Task({
  subagent_type: "document-writer",
  model: "haiku",
  prompt: "CHANGELOG.md에 버전 X.X.X 변경사항 추가"
})
Task({
  subagent_type: "document-writer",
  model: "haiku",
  prompt: "README.md 버전 정보 업데이트"
})

// ✅ 검토 + 문서 병렬
Task({
  subagent_type: "code-reviewer",
  model: "haiku",
  prompt: "버전 업데이트 변경사항 검토"
})
Task({
  subagent_type: "document-writer",
  model: "haiku",
  prompt: "CHANGELOG 작성"
})

// ❌ Git 작업은 순차 필수
// 버전 커밋 → 태그 생성 → 푸시 순서 보장
git commit → git tag → git push
```

## Model Routing

| 복잡도 | 버전 유형 | 모델 | 이유 |
|--------|----------|------|------|
| **LOW** | patch (+1) | haiku | 단순 숫자 증가 |
| **MEDIUM** | minor (+minor) | haiku/sonnet | 기능 추가, 문서 업데이트 |
| **HIGH** | major (+major) | sonnet | Breaking changes, 마이그레이션 가이드 |

## Practical Examples

```typescript
// 패치 버전 (haiku 병렬)
Task({ subagent_type: "document-writer", model: "haiku",
       prompt: "CHANGELOG: 버그 수정 내역 추가" })
Task({ subagent_type: "git-operator", model: "haiku",
       prompt: "버전 0.1.14 커밋" })

// 마이너 버전 (haiku/sonnet 병렬)
Task({ subagent_type: "document-writer", model: "sonnet",
       prompt: "CHANGELOG: 새 기능 문서화" })
Task({ subagent_type: "code-reviewer", model: "haiku",
       prompt: "API 변경사항 검토" })

// 메이저 버전 (sonnet 순차)
// 1. Breaking changes 분석 (sonnet)
// 2. 마이그레이션 가이드 작성 (sonnet)
// 3. 버전 커밋 (git-operator)
```

## Git 작업 순서 (순차 필수)

```bash
# ✅ 올바른 순서
1. git add [files]
2. git commit -m "chore: 버전 X.X.X로 업데이트"
3. git tag vX.X.X
4. git push origin main
5. git push origin vX.X.X

# ❌ 병렬 실행 금지
# Git 작업은 상태 의존성이 있어 순차 실행 필수
```

</parallel_agent_execution>

<update_targets>

| 파일 패턴 | 수정 위치 | 탐색 명령어 |
|----------|----------|-------------|
| `package.json` | `"version": "x.x.x"` | `fd -t f package.json -E node_modules` |
| `*.ts`, `*.js` | `.version('x.x.x')` | `rg "\.version\(['\"]" --type ts --type js -l` |

**참고**: 프로젝트 구조에 따라 버전 파일 위치가 다를 수 있음. 탐색 명령어로 자동 탐지.

</update_targets>

<examples>

```bash
# Patch 버전 증가
/version-update +1
→ 0.1.13 → 0.1.14
→ chore: 버전 0.1.14로 업데이트

# Minor 버전 증가
/version-update +minor
→ 0.1.13 → 0.2.0

# 직접 지정
/version-update 2.0.0
→ 모든 버전 파일을 2.0.0으로 업데이트
```

**워크플로우 예시:**
```bash
# 1. 버전 파일 자동 탐색
fd -t f package.json -E node_modules
→ ./package.json
→ ./packages/core/package.json

rg "\.version\(" --type ts -l
→ ./packages/core/src/index.ts

# 2. 파일 읽기 및 버전 확인
# 3. 새 버전 계산 및 Edit
# 4. git add <발견된-모든-버전-파일>
# 5. git commit
```

</examples>
