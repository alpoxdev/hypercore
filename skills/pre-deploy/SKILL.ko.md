---
name: pre-deploy
description: Node.js, Rust, Python 저장소의 deploy-readiness를 검증하고 재현된 lint/typecheck/build blocker를 수정합니다. "pre-deploy check", "deploy-ready", "배포 전 blocker 수정" 요청에 사용합니다.
allowed-tools: Bash Read Edit Write TodoWrite mcp__sequential-thinking__sequentialthinking
compatibility: 지원 스택(node/rust/python) 중 하나 이상의 로컬 툴체인, skills/pre-deploy/scripts 하위 스크립트가 필요하며, 독립 remediation lane에는 bounded subagent/background-agent 기능이 있으면 활용할 수 있습니다.
---

@rules/parallel-remediation.ko.md
@rules/tracked-remediation.ko.md

# Pre-Deploy Skill

> 저장소가 배포 가능한지 증명하거나, 그 증명을 막는 재현된 품질/빌드 blocker만 좁게 수정합니다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<request_routing>

## 긍정 트리거

- "pre-deploy check 실행해줘" 또는 "배포 준비됐는지 확인해줘."
- "이 repo를 deploy-ready로 만들어줘" 또는 "배포 전 blocker를 고쳐줘."
- "릴리스 전 최종 lint/typecheck/build 검증해줘."
- "이 Node/Rust/Python workspace를 배포 전에 검증해줘."

## 범위 밖

- 구체적인 배포 실패 로그, 플랫폼 빌드 실패, CI 전용 환경 차이, production deploy 문제는 `deploy-fix`로 보냅니다.
- 재현 절차가 있는 runtime bug나 잘못된 앱 동작은 `bug-fix`로 보냅니다.
- 재현된 pre-deploy blocker와 연결되지 않은 신규 기능, 광범위 리팩터, 추측성 cleanup은 `execute` 또는 관련 구현 스킬로 보냅니다.
- `package.json`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`, `setup.py`, `Pipfile`, `poetry.lock` 중 루트 marker가 없는 unsupported 저장소는 대상이 아닙니다.

## 경계 사례

- 사용자가 validation only를 요청하면 검사와 blocker 보고만 하고 파일을 수정하지 않습니다.
- 첫 검사에서 명백하고 낮은 위험의 blocker 하나만 나오면 Fix-now를 사용합니다.
- 여러 stack, workspace, 모호한 dependency/config chain에 걸친 실패면 tracked remediation과 가능한 parallel lane을 사용합니다.
- 실패 원인이 배포 플랫폼 또는 runtime app 이슈라면 잘못 흡수하지 말고 pre-deploy remediation을 멈춘 뒤 handoff합니다.

</request_routing>

<argument_validation>

- 인자가 없으면 현재 repository root를 기본 scope로 사용합니다.
- 사용자가 subdirectory 또는 workspace를 지정하면 존재 여부를 확인하고, 그 디렉터리에서 command를 실행하며 stack detection을 다시 시작합니다.
- 사용자가 validate-only, report-only, audit-only 등으로 말하면 파일을 수정하지 않습니다.
- 스킬 적용을 주장하기 전에 항상 target root에서 stack detection을 실행합니다.
- 지원 stack이 감지되지 않으면 즉시 중단하고 `pre-deploy` 대상이 아니라고 보고합니다. 가짜 수정 루프로 들어가지 않습니다.

</argument_validation>

<scripts>

## 사용 가능한 스크립트

Detection이 정확하도록 현재 작업 디렉터리를 target root로 설정해 실행합니다. target root가 repository root라면 아래 repository-relative path를 사용하고, target이 subdirectory/workspace라면 같은 script를 absolute path 또는 repository root로 돌아가는 올바른 relative path로 호출합니다.

| 스크립트 | 용도 |
|------|------|
| `skills/pre-deploy/scripts/stack-detect.sh` | 프로젝트 stack 자동 감지(`node`, `rust`, `python`) |
| `skills/pre-deploy/scripts/deploy-check.sh` | 전체 검증(품질 검사 + 빌드) |
| `skills/pre-deploy/scripts/lint-check.sh` | stack별 품질 검사 실행 |
| `skills/pre-deploy/scripts/build-run.sh` | stack별 빌드 단계 실행 |
| `skills/pre-deploy/scripts/pm-detect.sh` | Node package manager 감지(`npm/yarn/pnpm/bun`) |

메모:

- helper scripts는 현재 작업 디렉터리를 기준으로 stack과 package manager를 감지합니다.
- `lint-check.sh`는 Node typecheck와 lint가 둘 다 설정된 경우 내부적으로 독립 command를 동시에 실행합니다. 이 내부 병렬성을 추가 agent로 중복하지 않습니다.
- skipped check는 "미설정" 또는 "tool unavailable"로 취급하고, passed로 취급하지 않습니다.

</scripts>

<mandatory_reasoning>

## Adaptive Sequential Thinking

구현 전 `sequential-thinking`을 사용하고 실패 형태에 따라 깊이를 조절합니다.

| 복잡도 | 사고 깊이 | 신호 |
|------|------|------|
| Simple | 3 thoughts | 하나의 stack, 하나의 실패 command, 명확한 root cause, 낮은 위험 수정 |
| Medium | 5 thoughts | 한 stack 안의 여러 관련 실패, 중간 수준 config/dependency 영향 |
| Complex | 7+ thoughts | 여러 stack/workspace, 모호한 fix strategy, shared config, dependency chain, CI/deploy 경계 |

권장 순서: classify -> 정확한 실패 출력 읽기 -> root cause 식별 -> targeted validation 선택 -> direct fix, parallel lane, tracked remediation, handoff 중 결정.

</mandatory_reasoning>

<complexity_classification>

첫 full deploy check가 실패한 뒤 분류합니다.

| 복잡도 | 신호 | 경로 |
|------|------|------|
| Simple | 단일 실패 check, 하나의 stack, 명확한 file/config owner, 안전한 fix path 하나 | Fix-now |
| Medium | 한 stack 또는 한 workspace 안의 여러 실패, targeted fix가 가능할 정도로 독립적 | TodoWrite tracking이 있는 Fix-now |
| Complex | Multi-stack 실패, shared config, monorepo/build graph 이슈, 불확실한 repair option, cross-cutting side effect 가능성 | Tracked remediation; subagent 전 `rules/parallel-remediation.ko.md` 사용 |

확신이 없으면 더 높은 복잡도로 분류합니다. 광범위 변경을 조용히 적용하는 것보다 evidence와 ownership을 보존하는 편이 낫습니다.

</complexity_classification>

<execution_modes>

- **Validate-only**: detection과 `deploy-check.sh`를 실행하고 detected stacks, passed/failed/skipped checks, blockers를 보고합니다. 수정하지 않습니다.
- **Fix-now**: simple/medium 재현 blocker는 TodoWrite에 등록하고 좁게 수정한 뒤 targeted check와 full deploy check를 재실행합니다.
- **Parallel remediation**: 실패를 grouping한 뒤 독립 diagnosis 또는 겹치지 않는 edit lane에 한해 bounded subagent/background agent를 사용합니다. leader가 integration과 final verification을 소유합니다. 먼저 `rules/parallel-remediation.ko.md`를 읽습니다.
- **Tracked remediation**: complex case에서는 `rules/tracked-remediation.ko.md`를 읽은 뒤 `.hypercore/pre-deploy/flow.json`을 만들거나 재개하며 phase는 `detect`, `baseline`, `triage`, `fix`, `verify`, `report`입니다.
- **Handoff**: platform deployment 실패는 `deploy-fix`, runtime application bug는 `bug-fix`, 무관한 구현 요청은 `execute`로 보냅니다.

</execution_modes>

<workflow>

## 전체 검증 증명

Repository root 기준:

```bash
skills/pre-deploy/scripts/deploy-check.sh
```

Target root에 지원 stack이 없는 경우를 제외하고 이 초기 command를 건너뛰지 않습니다. baseline과 정확한 blocker를 확보합니다.

## 단계별 검증

Repository root 기준:

```bash
# 1) 품질 검사
skills/pre-deploy/scripts/lint-check.sh

# 2) 빌드 단계
skills/pre-deploy/scripts/build-run.sh
```

수정 후 targeted recheck에는 단계별 command를 사용할 수 있지만, 최종 readiness claim에는 반드시 full `deploy-check.sh` 실행이 필요합니다.

## Stack별 동작 요약

- **Node.js**: typecheck/lint(설정된 경우) + build script(설정된 경우)
- **Rust**: `cargo fmt --check` + `cargo clippy` + `cargo check` + `cargo build --release`
- **Python**: lint(`ruff`/`flake8` 가능 시) + 타입/문법 검사(`mypy` 또는 `compileall`) + 빌드(`poetry build` 또는 `python -m build`, 없으면 `compileall` fallback)
- **Unsupported repository**: unsupported-stack 오류를 보고하고 remediation으로 진행하지 않습니다.

</workflow>

<implementation_rules>

- 수정 전 정확한 command output을 읽습니다. 실패를 추측하지 않습니다.
- 실패를 stack, command, priority 기준으로 TodoWrite 항목으로 전환합니다.
- 실패들이 독립적임이 명확하지 않으면 cascading error를 쫓기 전에 첫/root failure를 고칩니다.
- 각 edit은 재현된 blocker와 직접 dependency에만 제한합니다.
- 수정 후 가장 좁은 관련 check를 재실행합니다.
- subagent를 사용할 때 각 lane에 objective, scope, ownership, output, stop condition을 줍니다. 두 lane이 같은 파일이나 shared config를 동시에 수정하게 하지 않습니다.
- leader는 subagent 결과를 합성하고 final diff를 직접 확인하며 final proof command를 직접 실행해야 합니다.

</implementation_rules>

<completion_report>

다음 report 형식을 사용합니다.

```markdown
## Done

**Scope**: [repo root 또는 workspace]
**Stacks detected**: [node/rust/python]
**Mode**: [validate-only/fix-now/parallel remediation/tracked remediation/handoff]
**Initial blockers**: [없음 또는 실패 요약]
**Fixes applied**: [변경 파일 또는 없음]
**Validation**:
- `skills/pre-deploy/scripts/deploy-check.sh`: [passed/failed/not run + reason]
- Skipped/not configured checks: [목록]
**Remaining risks**: [없음 또는 명시적 caveat]
```

최종 full `deploy-check.sh`가 통과했을 때만 "ready to deploy"라고 말합니다.

</completion_report>

<validation>

Execution checklist:

- [ ] Target root 또는 workspace 검증됨
- [ ] 지원 stack 감지됨, 또는 unsupported stack을 보고하고 중단함
- [ ] 지원 stack에서는 full `skills/pre-deploy/scripts/deploy-check.sh`를 먼저 실행함
- [ ] 실패가 stack/command/priority 기준으로 추적됨
- [ ] 수정 전 root-cause evidence를 수집함
- [ ] 적절한 깊이의 sequential thinking 완료
- [ ] parallel lane을 썼다면 독립적이고 bounded했음
- [ ] 각 수정 후 targeted validation 실행
- [ ] readiness claim 전 full deploy check 통과
- [ ] skipped checks를 passed checks와 분리 보고

Forbidden:

- [ ] 통과한 full deploy check 없이 deploy readiness를 주장
- [ ] 사용자가 이 스킬 밖 구현을 명시 요청한 경우가 아닌데, 재현된 실패 없이 수정
- [ ] skipped checks를 passed로 취급
- [ ] unsupported-stack detection 뒤 계속 진행
- [ ] 모든 runtime이 지원하는 것처럼 product-specific subagent syntax를 강제
- [ ] subagent가 겹치는 파일을 수정하거나 final readiness 결정을 소유하게 함

</validation>
