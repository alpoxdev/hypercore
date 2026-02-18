---
description: 프로젝트 버전 업데이트 및 커밋
allowed-tools: Bash, Read, Edit
argument-hint: <new-version | +1 | +minor | +major>
---

# Version Update Command

프로젝트 전체 버전을 업데이트하고 커밋.

**인수**: $ARGUMENTS

---

<scripts>

## 사용 가능한 스크립트

| 스크립트 | 용도 |
|----------|------|
| `${CLAUDE_SCRIPTS_ROOT}/version/version-find.sh` | 버전 파일 탐색 (package.json + .version()) |
| `${CLAUDE_SCRIPTS_ROOT}/version/version-bump.sh <current> <type>` | 새 버전 계산 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "msg" [files]` | 커밋 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-push.sh` | 푸시 |

</scripts>

---

<version_rules>

| 인수 | 동작 | 예시 |
|------|------|------|
| `+1` | patch +1 | 0.1.13 → 0.1.14 |
| `+minor` | minor +1 | 0.1.13 → 0.2.0 |
| `+major` | major +1 | 0.1.13 → 1.0.0 |
| `x.x.x` | 직접 지정 | 0.1.13 → 2.0.0 |

</version_rules>

---

<workflow>

## 워크플로우

```bash
# 1. 버전 파일 탐색
${CLAUDE_SCRIPTS_ROOT}/version/version-find.sh

# 2. 현재 버전 확인 (package.json 읽기)

# 3. 새 버전 계산
${CLAUDE_SCRIPTS_ROOT}/version/version-bump.sh 1.2.3 +1
# → 1.2.4

# 4. 모든 파일 Edit로 업데이트

# 5. 커밋
${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "chore: 버전 1.2.4로 업데이트" package.json packages/*/package.json
```

</workflow>

---

<parallel_execution_critical>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "version-update-team", description: "버전 업데이트 작업" })
Task(subagent_type="document-writer", team_name="version-update-team", name="changelog", ...)
Task(subagent_type="document-writer", team_name="version-update-team", name="readme", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

## ⚠️ CRITICAL: 병렬 작업 패턴

### 병렬 실행 가능 작업

**1. 버전 파일 병렬 탐색:**

```typescript
// ✅ 단일 메시지에서 동시 탐색
Bash({ command: "fd -t f 'package.json' -E node_modules", description: "Find package.json files" })
Bash({ command: "rg \"\\.version\\(['\\\"]\" --type ts --type js -l", description: "Find version code" })
```

**이렇게 하면:**
- 2개의 탐색이 동시에 실행됨
- 총 실행 시간 = max(fd 시간, rg 시간)
- 순차 실행 대비 약 50% 시간 단축

**2. 버전 파일 병렬 읽기:**

```typescript
// ✅ 발견된 파일들 동시 읽기
Read({ file_path: "./package.json" })
Read({ file_path: "./packages/core/package.json" })
Read({ file_path: "./packages/core/src/index.ts" })
```

**3. 문서 작성 병렬:**

```typescript
// ✅ CHANGELOG + README 동시 작성
Task({ subagent_type: 'document-writer', model: 'haiku',
       prompt: 'CHANGELOG.md에 버전 X.X.X 변경사항 추가' })
Task({ subagent_type: 'document-writer', model: 'haiku',
       prompt: 'README.md 버전 정보 업데이트' })
```

### 순차 실행 필수 작업

**Git 작업은 반드시 순차로 실행:**

```typescript
// ❌ Git 병렬 실행 금지
Task({ prompt: 'git add [files]' })
Task({ prompt: 'git commit' })  // 충돌 위험!

// ✅ Git 순차 실행
// 1. git add [files]
// 2. git commit -m "chore: 버전 X.X.X로 업데이트"
// 3. git tag vX.X.X
// 4. git push origin main
// 5. git push origin vX.X.X
```

### 병렬 실행 체크리스트

버전 업데이트 전 확인:

- [ ] 파일 탐색을 병렬로 실행하는가? (fd + rg 동시)
- [ ] 발견된 파일들을 병렬로 읽는가?
- [ ] 문서 작성을 병렬로 진행하는가? (CHANGELOG + README)
- [ ] Git 작업은 순차로 진행하는가?
- [ ] 태그 생성 전 커밋이 완료되었는가?

**모든 항목이 체크되어야 올바른 버전 업데이트입니다.**

### 복잡도별 병렬 패턴

**Patch 버전 (+1):**
```typescript
// 간단함 → haiku 병렬
Task({ subagent_type: 'document-writer', model: 'haiku',
       prompt: 'CHANGELOG: 버그 수정 내역' })
Task({ subagent_type: 'document-writer', model: 'haiku',
       prompt: 'README: 버전 번호 업데이트' })
```

**Minor 버전 (+minor):**
```typescript
// 중간 → haiku/sonnet 병렬
Task({ subagent_type: 'document-writer', model: 'sonnet',
       prompt: 'CHANGELOG: 새 기능 문서화' })
Task({ subagent_type: 'code-reviewer', model: 'haiku',
       prompt: 'API 변경사항 검토' })
```

**Major 버전 (+major):**
```typescript
// 복잡함 → sonnet 순차
// 1. Breaking changes 분석 (sonnet)
// 2. 마이그레이션 가이드 작성 (sonnet)
// 3. 문서화 + 검토 병렬
// 4. 버전 커밋 (git-operator 순차)
```

### 실제 버전 업데이트 워크플로우

**Step 1: 병렬 파일 탐색**

```typescript
// 커맨드 시작 시 즉시 병렬 실행
Bash({
  command: "fd -t f 'package.json' -E node_modules",
  description: "Find all package.json files"
})
Bash({
  command: "rg \"\\.version\\(['\\\"]\" --type ts --type js -l",
  description: "Find version code files"
})
```

**Step 2: 병렬 파일 읽기**

```typescript
// 발견된 파일들 동시 읽기
Read({ file_path: "./package.json" })
Read({ file_path: "./packages/core/package.json" })
Read({ file_path: "./packages/cli/package.json" })
Read({ file_path: "./packages/core/src/index.ts" })
```

**Step 3: 새 버전 계산 및 업데이트**

- $ARGUMENTS 분석 (+1, +minor, +major, 또는 직접 버전)
- 모든 파일 Edit로 업데이트

**Step 4: 병렬 문서 작성**

```typescript
// 문서 업데이트 동시 진행
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'CHANGELOG 업데이트',
  prompt: 'CHANGELOG.md에 버전 0.5.2 변경사항 추가'
})
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'README 버전 업데이트',
  prompt: 'README.md 설치 섹션 버전 번호 업데이트'
})
```

**Step 5: Git 작업 (순차 필수)**

```bash
# 반드시 순차로 실행
git add package.json packages/*/package.json packages/*/src/index.ts
git commit -m "chore: 버전 0.5.2로 업데이트"
git tag v0.5.2
git push origin main
git push origin v0.5.2
```

**전체 실행 시간:**
- 순차: 탐색1(1초) + 탐색2(1초) + 읽기(4초) + 문서1(2초) + 문서2(2초) + git(3초) = 13초
- 병렬: 탐색(1초) + 읽기(1초) + 문서(2초) + git(3초) = 7초
- **개선: 46% 시간 단축**

**복잡도별 예시:**

```typescript
// Patch (+1): 전체 haiku 병렬
Task({ subagent_type: 'document-writer', model: 'haiku',
       prompt: 'CHANGELOG: 버그 수정 기록' })
Task({ subagent_type: 'document-writer', model: 'haiku',
       prompt: 'README: 버전 0.5.2 표시' })
// → 총 2초 (병렬)

// Minor (+minor): haiku/sonnet 병렬
Task({ subagent_type: 'document-writer', model: 'sonnet',
       prompt: 'CHANGELOG: 새 기능 상세 문서화' })
Task({ subagent_type: 'code-reviewer', model: 'haiku',
       prompt: 'API 변경사항 영향도 검토' })
// → 총 3초 (병렬)

// Major (+major): sonnet 순차 + 병렬 조합
// 1. Breaking changes 분석 (sonnet, 5초)
// 2. 마이그레이션 가이드 + 문서 병렬 (sonnet, 4초)
// 3. git 작업 (3초)
// → 총 12초
```

</parallel_execution_critical>

---

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
