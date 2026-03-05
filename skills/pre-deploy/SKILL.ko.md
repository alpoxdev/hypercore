---
name: pre-deploy
description: Node.js, Rust, Python 프로젝트의 배포 전 품질/빌드 차단 이슈를 검증하고 수정합니다.
allowed-tools: Bash Read Edit mcp__sequential-thinking__sequentialthinking
compatibility: 지원 스택(node/rust/python) 중 하나 이상의 로컬 툴체인과 skills/pre-deploy/scripts 스크립트가 필요합니다.
---

# Pre-Deploy Skill

> node/rust/python 공통 배포 전 검증 및 수정 스킬.

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

</execution_plan>
