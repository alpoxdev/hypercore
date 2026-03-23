---
name: version-update
description: node/rust/python 프로젝트의 semantic version을 일관되게 갱신하고, 마지막 git 단계에서는 설치된 `git-commit` 스킬을 우선 사용하며 없을 때만 직접 fallback 하는 스킬입니다.
allowed-tools: Bash Read Edit
compatibility: Git 저장소와 `skills/version-update/scripts` 하위 스크립트가 필요합니다. 마지막 git 경로를 고르기 전에 현재 저장소 안의 `skills/git-commit`, `.agents/skills/git-commit`, `.claude/skills/git-commit`, `.codex/skills/git-commit` 만 탐지합니다.
---

# Version Update Skill

> node/rust/python 공통 semantic version 업데이트 스킬. 마지막 git 단계는 조건부로 `git-commit` 에 handoff 한다.

<purpose>

- node, rust, python 프로젝트의 semantic version을 한 번에 갱신한다.
- manifest 파일과 inline version 패턴을 같은 버전으로 동기화한다.
- 마지막 `git add`/`git commit`/`git push` 단계는 설치된 `git-commit` 스킬을 우선 사용한다.
- `git-commit` 이 없을 때만 로컬 fallback 스크립트로 직접 수행한다.

</purpose>

<trigger_conditions>

| 사용자 의도 | Activate |
|------|------|
| "이 패키지를 1.4.0으로 올려줘" | yes |
| "버전 올리고 커밋까지 해줘" | yes |
| "이 crate patch 버전만 올려줘" | yes |
| "그냥 git commit만 해줘" | no, `git-commit` 사용 |
| "릴리즈 문서 정리해줘" | no |

</trigger_conditions>

<supported_targets>

- `package.json`
- `Cargo.toml`
- `pyproject.toml`
- `setup.py`
- python `__version__` 선언
- 코드 안의 `.version('x.y.z')` 패턴

</supported_targets>

<scripts>

## 사용 가능한 스크립트

| 스크립트 | 용도 |
|------|------|
| `scripts/stack-detect.sh` | 스택 감지(`node`, `rust`, `python`) |
| `scripts/version-find.sh [--plain]` | 버전 관련 파일 탐색 |
| `scripts/version-current.sh [file]` | 현재 버전 추출 (`file|version`) |
| `scripts/version-bump.sh <current> <type>` | 다음 버전 계산 |
| `scripts/version-apply.sh <new> [files...]` | 탐색/지정 파일에 버전 일괄 반영 |
| `scripts/git-commit-detect.sh` | 현재 저장소의 스킬 디렉터리에 usable 한 `git-commit` 스킬이 있는지 판정 |
| `scripts/git-commit.sh "msg" [files]` | `git-commit` 스킬이 없을 때만 사용하는 fallback 직접 커밋 helper |
| `scripts/git-push.sh` | `git-commit` 스킬이 없을 때만 사용하는 fallback 직접 푸시 helper |

</scripts>

<git_integration>

- 마지막 git 단계 전에 `scripts/git-commit-detect.sh` 를 먼저 실행한다.
- detector는 현재 저장소 안에서 순서대로 `skills/git-commit`, `.agents/skills/git-commit`, `.claude/skills/git-commit`, `.codex/skills/git-commit` 만 검사한다.
- detector가 `installed|...` 를 반환할 때만 마지막 git 단계를 `git-commit` 스킬에 넘긴다.
- `git-commit` 에 넘길 때는 `version-update` 로 실제 변경된 파일만 범위로 넘기고, 기본 메시지는 `chore: bump version to x.y.z` 를 사용한다.
- detector가 `missing|...` 를 반환하면 `skills/version-update/scripts/` 아래 fallback 스크립트로 직접 처리한다.
- 사용자가 버전만 바꾸라고 했다면 diff 확인까지만 하고 커밋/푸시는 하지 않는다.
- push 요청이 있을 때 detector가 `installed|...` 를 반환하면 push 확인은 `git-commit` 이 담당한다. 아니면 명시적 요청 이후에만 `scripts/git-push.sh` 를 사용한다.

</git_integration>

<version_rules>

| 인수 | 동작 | 예시 |
|------|------|------|
| `+1` / `+patch` | Patch +1 | `0.1.13 -> 0.1.14` |
| `+minor` | Minor +1 | `0.1.13 -> 0.2.0` |
| `+major` | Major +1 | `0.1.13 -> 1.0.0` |
| `x.y.z` | 직접 지정 | `0.1.13 -> 2.0.0` |

</version_rules>

<workflow>

## 워크플로우

```bash
# 1) 스택 감지
scripts/stack-detect.sh

# 2) 버전 파일 탐색
scripts/version-find.sh

# 3) 현재 버전 확인
scripts/version-current.sh
# 출력: <file>|<version>

# 4) 새 버전 계산
scripts/version-bump.sh 1.2.3 +minor
# -> 1.3.0

# 5) 버전 일괄 반영
scripts/version-apply.sh 1.3.0

# 6) 최종 diff와 변경 파일 확인
git diff --stat
git diff

# 7) git-commit 스킬이 실제로 usable 한지 확인
scripts/git-commit-detect.sh
# -> installed|/abs/path/to/current-repo/skills/git-commit
# 또는 missing|comma,separated,current-repo,paths|reason

# 8a) git-commit 이 설치되어 있고 usable 하면 그 스킬로 마지막 git 단계 handoff
# 기본 메시지: chore: bump version to 1.3.0

# 8b) 아니면 fallback 직접 실행
scripts/git-commit.sh "chore: bump version to 1.3.0" package.json

# 9) (선택) 푸시는 명시적으로 요청된 경우에만
scripts/git-push.sh
```

</workflow>

<stack_targets>

| 스택 | 주요 파일 | 추가 패턴 |
|------|------|------|
| Node | `package.json` | 코드 내 `.version('x.y.z')` |
| Rust | `Cargo.toml` (`[package].version`) | 코드 내 `.version('x.y.z')` |
| Python | `pyproject.toml`, `setup.py`, `.py`의 `__version__` | 코드 내 `.version('x.y.z')` |

</stack_targets>

<required>

| 분류 | 필수 |
|------|------|
| Input | ARGUMENT를 bump 규칙 또는 semver로 파싱 |
| Discovery | 업데이트 전 `version-find.sh` 실행 |
| Current state | 목표 버전 계산 전에 `version-current.sh` 로 현재 버전 확인 |
| Consistency | 탐색된 버전 파일을 모두 동기화 |
| Git detection | git 경로를 고르기 전에 `scripts/git-commit-detect.sh` 실행 |
| Git scope | `git-commit` 에 handoff 할 때는 version-update 파일 집합으로 범위를 제한 |
| Safety | 사용자가 다르게 요청하지 않으면 커밋 메시지 규칙(`chore: bump version to x.y.z`) 준수 |
| Git | Git 쓰기 작업은 순차 실행 |

</required>

<scope_boundaries>

- `version-update` 는 버전 탐색, 목표 버전 계산, 파일 갱신, diff 검토를 담당한다.
- detector가 현재 저장소의 그 스킬이 usable 하다고 확인했을 때만 저장소 상태 확인, 스테이징 규율, 커밋 생성, push 확인은 `git-commit` 이 담당한다.
- `skills/version-update/scripts/git-commit.sh`, `git-push.sh` 는 fallback helper일 뿐이고, `git-commit` 이 있을 때 기본 경로가 아니다.

</scope_boundaries>

<examples>

## Positive trigger 예시

- "이 저장소 버전을 0.8.2에서 0.9.0으로 올리고 커밋해줘"
- "이 Python 패키지 patch 버전만 올려줘"
- "package.json이랑 Cargo.toml 버전을 2.0.0으로 맞춰줘"

## Negative trigger 예시

- "이 문서 변경만 git commit 해줘"
- "릴리즈 프로세스만 요약해줘"

## Boundary trigger 예시

- "버전만 바꾸고 아직 커밋은 하지마"

</examples>

<validation>

Trigger 체크:

- [ ] positive trigger 예시 최소 3개가 여전히 자연스럽게 맞는다
- [ ] negative trigger 예시 최소 2개가 범위 밖으로 남아 있다
- [ ] boundary 예시 최소 1개가 커밋 여부 경계를 분명히 한다

실행 체크리스트:

- [ ] `version-current.sh`로 현재 버전 확인
- [ ] `version-bump.sh` 또는 직접 semver 검증 완료
- [ ] `version-apply.sh`로 대상 파일 업데이트
- [ ] `git diff`로 변경 검토
- [ ] git 경로 선택 전에 `scripts/git-commit-detect.sh` 실행
- [ ] detector가 현재 저장소 안의 `skills/git-commit`, `.agents/skills/git-commit`, `.claude/skills/git-commit`, `.codex/skills/git-commit` 만 검사함
- [ ] detector가 `installed|...` 를 반환하면 좁혀진 version-update 범위로 마지막 git 단계 handoff
- [ ] detector가 `missing|...` 를 반환하면 fallback `scripts/git-commit.sh` 로 해당 파일만 직접 커밋
- [ ] 푸시는 요청된 경우에만 실행

금지:

- [ ] 현재 버전 확인 없이 업데이트 시작
- [ ] 여러 버전 파일이 있는데 일부만 수정
- [ ] detector가 이미 `installed|...` 를 반환했는데 이유 없이 fallback git 스크립트를 기본 경로처럼 사용
- [ ] 보호 브랜치에 force push

</validation>
