---
name: version-update
description: node/rust/python 프로젝트의 semantic version을 일관되게 갱신하고, 이 스킬의 Bun MJS helper로 요청된 commit과 push를 직접 수행하는 스킬입니다.
allowed-tools: Bash Read Edit
compatibility: Bun, Git 저장소, `skills/version-update/scripts` 하위 MJS 스크립트가 필요합니다.
---

# Version Update Skill

> node/rust/python 공통 semantic version 업데이트 스킬. 요청된 마지막 git 단계는 직접 수행한다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- node, rust, python 프로젝트의 semantic version을 한 번에 갱신한다.
- manifest 파일과 inline version 패턴을 같은 버전으로 동기화한다.
- 요청된 commit과 push에는 이 스킬의 직접 git helper를 사용한다.

</purpose>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | 지원되는 project file 전반의 semantic version을 동기화해 업데이트합니다. |
| Trigger | version bump/set 요청, 특히 version update와 optional commit 요청에 활성화합니다. |
| Scope | stack detection, version-file discovery, target-version calculation, version application, diff review, 요청된 git operation을 담당합니다. |
| Authority | 사용자와 프로젝트 지시가 이 스킬보다 우선합니다. discovered version file, semver rule, script output, diff는 근거입니다. |
| Evidence | git write 전에 Bun MJS helper, target argument parsing, `git diff`를 사용합니다. |
| Tools | `bun scripts/*.mjs` helper와 local file edit를 사용합니다. 요청된 경우에만 이 스킬의 직접 git helper를 사용합니다. |
| Loop | 루프 없음. 요청당 한 번만 수행합니다: 스택 감지, 버전 파일 탐색, 현재 버전 확인, 목표 버전 계산, 반영, diff 검토 후 멈춥니다. 사용자가 다시 버전 변경을 요청할 때만 재실행합니다. |
| Output | current version, target version, changed file, commit/push status, caveat에 대한 한국어 report입니다. |
| Verification | 의도한 모든 version file이 일관되게 변경되었는지 확인하고, diff를 검토하며, 요청된 경우에만 optional git step을 수행합니다. |
| Stop condition | version file이 업데이트 및 검토되었거나, 요청된 git step이 완료 또는 근거 있는 blocker로 보고되었을 때 멈춥니다. |

</instruction_contract>

<trigger_conditions>

| 사용자 의도 | Activate |
|------|------|
| "이 패키지를 1.4.0으로 올려줘" | yes |
| "버전 올리고 커밋까지 해줘" | yes |
| "이 crate patch 버전만 올려줘" | yes |
| "그냥 git commit만 해줘" | no |
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
| `bun scripts/stack-detect.mjs` | 스택 감지(`node`, `rust`, `python`) |
| `bun scripts/version-find.mjs [--plain]` | 버전 관련 파일 탐색 |
| `bun scripts/version-current.mjs [file]` | 현재 버전 추출 (`file|version`) |
| `bun scripts/version-bump.mjs <current> <type>` | 다음 버전 계산 |
| `bun scripts/version-apply.mjs <new> [files...]` | 탐색/지정 파일에 버전 일괄 반영 |
| `bun scripts/git-commit.mjs "msg" [files]` | 지정한 version-update 파일을 직접 커밋 |
| `bun scripts/git-push.mjs` | 명시적인 사용자 요청 후 직접 푸시 |

</scripts>

<git_integration>

- 사용자가 버전만 바꾸라고 했다면 diff 확인까지만 하고 커밋/푸시는 하지 않는다.
- 커밋을 요청한 경우 사용자가 다른 메시지를 요청하지 않았다면 `version-update` 로 실제 변경된 파일만 지정하여 `bun scripts/git-commit.mjs "chore: bump version to x.y.z" [files...]` 를 실행한다.
- 푸시를 요청한 경우 커밋 성공 후 사용자가 명시적으로 푸시를 요청했을 때만 `bun scripts/git-push.mjs` 를 실행한다.
- Git 쓰기 작업은 순차 실행한다.

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
bun scripts/stack-detect.mjs

# 2) 버전 파일 탐색
bun scripts/version-find.mjs

# 3) 현재 버전 확인
bun scripts/version-current.mjs
# 출력: <file>|<version>

# 4) 새 버전 계산
bun scripts/version-bump.mjs 1.2.3 +minor
# -> 1.3.0

# 5) 버전 일괄 반영
bun scripts/version-apply.mjs 1.3.0

# 6) 최종 diff와 변경 파일 확인
git diff --stat
git diff

# 7) (선택) 명시적으로 요청된 경우에만 커밋
bun scripts/git-commit.mjs "chore: bump version to 1.3.0" package.json

# 8) (선택) 명시적으로 요청된 경우에만 푸시
bun scripts/git-push.mjs
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
| Discovery | 업데이트 전 `bun scripts/version-find.mjs` 실행 |
| Current state | 목표 버전 계산 전에 `bun scripts/version-current.mjs` 로 현재 버전 확인 |
| Consistency | 탐색된 버전 파일을 모두 동기화 |
| Git scope | version-update 파일 집합만 커밋 |
| Safety | 사용자가 다르게 요청하지 않으면 커밋 메시지 규칙(`chore: bump version to x.y.z`) 준수 |
| Git | 요청된 Git 쓰기에는 `bun scripts/git-commit.mjs`, `bun scripts/git-push.mjs` 만 순차적으로 사용 |

</required>

<scope_boundaries>

- `version-update` 는 버전 탐색, 목표 버전 계산, 파일 갱신, diff 검토, 요청된 git operation을 담당한다.
- version-update 로 변경된 파일만 커밋한다.

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

- [ ] `bun scripts/version-current.mjs`로 현재 버전 확인
- [ ] `bun scripts/version-bump.mjs` 또는 직접 semver 검증 완료
- [ ] `bun scripts/version-apply.mjs`로 대상 파일 업데이트
- [ ] `git diff`로 변경 검토
- [ ] 요청된 커밋은 `bun scripts/git-commit.mjs` 로 version-update 파일만 사용
- [ ] 요청된 푸시는 커밋 성공 후 `bun scripts/git-push.mjs` 로 실행

금지:

- [ ] 현재 버전 확인 없이 업데이트 시작
- [ ] 여러 버전 파일이 있는데 일부만 수정
- [ ] version-update 파일 집합 밖의 파일 커밋
- [ ] 보호 브랜치에 force push

</validation>
