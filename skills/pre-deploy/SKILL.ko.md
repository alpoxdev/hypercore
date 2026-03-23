---
name: pre-deploy
description: Node.js, Rust, Python 프로젝트의 배포 전 품질/빌드 차단 이슈를 검증하고 수정합니다.
allowed-tools: Bash Read Edit TodoWrite mcp__sequential-thinking__sequentialthinking
compatibility: 지원 스택(node/rust/python) 중 하나 이상의 로컬 툴체인과 skills/pre-deploy/scripts 스크립트가 필요합니다.
---

# Pre-Deploy Skill

> node/rust/python 공통 배포 전 검증 및 수정 스킬.

현재 저장소 루트에 `package.json`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`, `setup.py`, `Pipfile`, `poetry.lock` 중 하나 이상이 있을 때만 이 스킬을 사용합니다.

저장소 루트에서 지원 스택이 감지되지 않으면 검증이 실행된 척하지 말고 즉시 중단하고 `pre-deploy` 대상이 아니라는 점을 보고합니다.

<scripts>

## 사용 가능한 스크립트

| 스크립트 | 용도 |
|------|------|
| `scripts/stack-detect.sh` | 프로젝트 스택 자동 감지(`node`, `rust`, `python`) |
| `scripts/deploy-check.sh` | 전체 검증(품질 검사 + 빌드) |
| `scripts/lint-check.sh` | 스택별 품질 검사 실행 |
| `scripts/build-run.sh` | 스택별 빌드 단계 실행 |
| `scripts/pm-detect.sh` | Node 패키지 매니저 감지(`npm/yarn/pnpm/bun`) |

</scripts>

<workflow>

## 워크플로우

### 전체 검증 (권장)

```bash
scripts/deploy-check.sh
```

스크립트는 반드시 저장소 루트에서 실행합니다. 보조 스크립트는 현재 작업 디렉터리를 기준으로 스택과 패키지 매니저를 감지합니다.

### 단계별 검증

```bash
# 1) 품질 검사
scripts/lint-check.sh

# 2) 빌드 단계
scripts/build-run.sh
```

### 스택별 동작 요약

- **Node.js**: typecheck/lint(설정된 경우) + build script(설정된 경우)
- **Rust**: `cargo fmt --check` + `cargo clippy` + `cargo check` + `cargo build --release`
- **Python**: lint(`ruff`/`flake8` 가능 시) + 타입/문법 검사(`mypy` 또는 `compileall`) + 빌드(`poetry build` 또는 `python -m build`, 없으면 `compileall` 폴백)
- **지원하지 않는 저장소**: unsupported-stack 오류를 그대로 보고하고, 가짜 수정 루프로 들어가지 않고 즉시 중단

</workflow>

<required>

| 분류 | 필수 |
|------|------|
| **Thinking** | 이슈별 Sequential Thinking 3-5단계 |
| **Tracking** | 실패 항목을 TodoWrite로 추적 |
| **Strategy** | 스택 검사 실행 -> 순차 수정 -> 재검증 -> 빌드 |
| **Validation** | 파일 수정 후 관련 검사 재실행 |
| **Completion** | deploy-check 전체 통과 후 완료 선언 |

</required>

<execution_plan>

1. `scripts/deploy-check.sh` 실행
2. 오류를 스택/우선순위 기준으로 TodoWrite 등록
3. 각 오류마다
   - sequential-thinking 수행
   - 범위 제한 수정 적용
   - 관련 검사 재실행
4. 전체 deploy-check 재실행
5. 최종 상태와 잔여 리스크 보고

1단계를 건너뛰지 않습니다. `deploy-check.sh`가 동일한 저장소 루트에서 품질 검사와 빌드 단계를 함께 증명하는 진입점입니다.

</execution_plan>
