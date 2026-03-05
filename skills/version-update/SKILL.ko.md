---
name: version-update
description: node/rust/python 프로젝트의 semantic version을 일관되게 갱신하고, 안전하게 커밋(선택적으로 푸시)하는 스킬입니다.
allowed-tools: Bash Read Edit
compatibility: Git 저장소와 skills/version-update/scripts 하위 스크립트가 필요합니다.
---

# Version Update Skill

> node/rust/python 공통 semantic version 업데이트 스킬.

<scripts>

## 사용 가능한 스크립트

| 스크립트 | 용도 |
|------|------|
| `scripts/stack-detect.sh` | 스택 감지(`node`, `rust`, `python`) |
| `scripts/version-find.sh [--plain]` | 버전 관련 파일 탐색 |
| `scripts/version-current.sh [file]` | 현재 버전 추출 (`file|version`) |
| `scripts/version-bump.sh <current> <type>` | 다음 버전 계산 |
| `scripts/version-apply.sh <new> [files...]` | 탐색/지정 파일에 버전 일괄 반영 |
| `scripts/git-commit.sh "msg" [files]` | 변경 파일 커밋 |
| `scripts/git-push.sh` | 현재 브랜치 안전 푸시 |

</scripts>

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

# 6) 커밋
scripts/git-commit.sh "chore: bump version to 1.3.0"

# 7) (선택) 푸시
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
| Consistency | 탐색된 버전 파일을 모두 동기화 |
| Safety | 커밋 메시지 규칙(`chore: bump version to x.y.z`) 준수 |
| Git | Git 쓰기 작업은 순차 실행 |

</required>

<validation>

실행 체크리스트:

- [ ] `version-current.sh`로 현재 버전 확인
- [ ] `version-bump.sh` 또는 직접 semver 검증 완료
- [ ] `version-apply.sh`로 대상 파일 업데이트
- [ ] `git diff`로 변경 검토
- [ ] `scripts/git-commit.sh`로 커밋 생성
- [ ] 푸시는 요청된 경우에만 실행

금지:

- [ ] 현재 버전 확인 없이 업데이트 시작
- [ ] 여러 버전 파일이 있는데 일부만 수정
- [ ] 보호 브랜치에 force push

</validation>
