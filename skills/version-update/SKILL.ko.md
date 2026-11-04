---
name: version-update
description: "[Hyper] 사용자가 node, rust, python 프로젝트의 시맨틱 버전을 올리거나, 지정하거나, 여러 파일에 맞추도록 요청할 때, 또는 그 버전 변경이 건드린 파일만 커밋하고 푸시하도록 요청할 때 이 스킬을 사용합니다. 버전 변경 없는 커밋, 릴리스 계획이나 체인지로그, 프로젝트 버전은 그대로 두는 의존성 업그레이드에는 사용하지 않습니다."
compatibility: skills/version-update/scripts 아래 스크립트를 실행할 Bash 3.2+와, 선택 사항인 커밋·푸시를 위한 로컬 git 저장소가 필요합니다.
---

# Version Update Skill

> node/rust/python의 시맨틱 버전을 한 번에 맞추고, 요청받은 커밋과 푸시를 직접 수행합니다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 조율 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- node, rust, python의 버전을 담은 파일 전체에 시맨틱 버전 하나를 반영합니다.
- 찾아낸 매니페스트 파일과 코드 안의 버전 표기를 같은 값으로 유지합니다.
- 요청받은 커밋과 푸시는 이 스킬의 git helper로 직접 수행합니다.

</purpose>

<routing_rule>

산출물이 프로젝트의 버전 파일 전체에 걸친 버전 변경이고, 그 파일만 대상으로 하는 커밋과 푸시가 선택 사항으로 붙는 경우에 이 스킬을 사용합니다.

산출물의 형태가 다르면 다른 작업으로 보냅니다.

| 요청한 산출물 | 해당 작업 |
|---|---|
| 버전 변경 없는 커밋 | 커밋 요청이며 버전 업데이트가 아닙니다 |
| 버전 수정 없는 릴리스 계획, 체인지로그, 태그 전략 | 릴리스 계획 |
| 매니페스트는 바뀌지만 프로젝트 버전은 그대로인 의존성 업그레이드 | 의존성 작업 |
| 현재 버전 숫자만 알려주는 확인 | 읽기 전용 버전 보고 |

</routing_rule>

<activation_examples>

긍정:

- "이 repo 0.8.2에서 0.9.0으로 올리고 커밋해줘"
- "이 Python 패키지 patch 버전 올려줘"
- "package.json이랑 Cargo.toml을 2.0.0으로 맞춰줘"

부정:

- "이 문서 변경분 커밋해줘"
- "우리 릴리스 절차 요약해줘"

경계:

- "버전만 올리고 커밋은 아직 하지 마"

</activation_examples>

<trigger_conditions>

| 사용자 의도 | 활성화 |
|------|------|
| "이 패키지 1.4.0으로 올려줘" | 예 |
| "버전 올리고 커밋까지 해줘" | 예 |
| "이 crate patch 버전 올려줘" | 예 |
| "그냥 git commit 해줘" | 아니오 |
| "릴리스 런북 다시 써줘" | 아니오 |

</trigger_conditions>

<instruction_contract>

| 항목 | 계약 |
|---|---|
| Intent | 지원하는 프로젝트 파일의 시맨틱 버전을 같은 값으로 맞춰 갱신합니다. |
| Trigger | 버전을 올리거나 지정해 달라는 요청, 특히 버전 업데이트와 선택적 커밋을 함께 요청할 때 활성화합니다. |
| Scope | 스택 감지, 버전 파일 탐색, 목표 버전 계산, 버전 적용, diff 검토, 요청받은 git 작업을 담당합니다. |
| Authority | 사용자와 프로젝트 지시가 이 스킬보다 우선합니다. 찾아낸 버전 파일, semver 규칙, 스크립트 출력, diff는 근거입니다. |
| Evidence | git 쓰기 전에 bash helper 실행 결과, 인자 해석, `git diff`를 근거로 씁니다. |
| Tools | `bash scripts/*.sh` helper와 로컬 파일 편집을 쓰고, 이 스킬의 git helper는 요청받았을 때만 씁니다. |
| Loop | 없음. 요청당 한 번 통과합니다. 스택 감지, 버전 파일 탐색, 현재 버전 읽기, 목표 계산, 적용, diff 검토 후 멈춥니다. 사용자가 다른 버전 변경을 요청할 때만 다시 호출합니다. |
| Output | 현재 버전, 목표 버전, 변경 파일, 커밋·푸시 상태, 주의 사항을 담은 한국어 보고입니다. |
| Verification | 의도한 버전 파일이 모두 같은 값으로 바뀌었는지 확인하고, diff를 검토하고, 선택 사항인 git 단계는 요청받았을 때만 실행합니다. |
| Stop condition | 버전 파일을 갱신하고 검토했거나, 요청받은 git 단계를 근거와 함께 마쳤거나 막힌 상태로 보고했을 때 멈춥니다. |

</instruction_contract>

<skill_architecture>

- Core(`SKILL.md`): trigger, 계약, 버전 규칙, helper 순서, git 경계를 담습니다.
- Scripts: `<scripts>`에 정리한 bash helper 일곱 개가 유일한 실행 표면이며, 각 helper의 목적과 인자 형태도 그 표에 있습니다.
- Assets: `assets/evals/version-update-cases.jsonl`이 trigger와 행동 사례입니다.
- Rules와 references 없음: 절차가 core 안에 들어가고, 복사한 semver 요약은 그것을 적용하는 helper와 어긋나기만 합니다.

</skill_architecture>

<loop_policy>

반복하지 않습니다. 요청당 한 번 감지, 탐색, 읽기, 계산, 적용, 검토를 거친 뒤 요청받은 git 단계까지 수행합니다. 인자를 잘못 넘겼거나 지원하지 않는 스택이면 helper의 오류와 함께 멈추며 재시도 주기를 만들지 않습니다. 다시 호출하는 경우는 사용자가 다른 버전 변경을 요청할 때뿐입니다.

</loop_policy>

<language_and_translation_default>

- 이 패키지의 정본 파일은 영어이고, 모든 `*.ko.md`는 같은 규칙을 담은 구조 정렬 한국어 번역입니다.
- 산출물은 `<output_language>`를 따릅니다. 기본은 한국어이고, 식별자·명령·경로·커밋 메시지는 원래 형태로 둡니다.

</language_and_translation_default>

<reference_routing>

- 첫 helper 실행 전에 `<scripts>`를 읽습니다. 각 helper의 목적, 인자, 출력이 그 표에 있습니다.
- 실행 순서는 `<workflow>`에서, 사용자 인자가 명시 버전이 아니라 bump 규칙일 때는 `<version_rules>`에서 확인합니다.
- trigger, 버전 규칙, git 경계를 바꿀 때만 `assets/evals/version-update-cases.jsonl`을 읽습니다.

</reference_routing>

<support_file_read_order>

1. 이 core 파일로 trigger 경계, 계약, 버전 규칙을 확인합니다.
2. helper를 실행하기 전에 `<scripts>`를 읽습니다.
3. 실행 중에는 `<workflow>`를 보며 단계별 근거를 그때그때 모읍니다.
4. 보고 전에 `<validation>`을 적용합니다.

</support_file_read_order>

<scripts>

| 스크립트 | 목적 |
|------|------|
| `bash scripts/stack-detect.sh` | 스택 감지 (`node`, `rust`, `python`) |
| `bash scripts/version-find.sh [--plain]` | 버전을 담은 파일 탐색 |
| `bash scripts/version-current.sh [file]` | 현재 semver 추출 (`file|version`) |
| `bash scripts/version-bump.sh <current> <type>` | 다음 semver 계산 |
| `bash scripts/version-apply.sh <new> [files...]` | 찾아낸 파일이나 지정한 파일에 버전 적용 |
| `bash scripts/git-commit.sh "msg" [files]` | 지정한 version-update 파일만 직접 커밋 |
| `bash scripts/git-push.sh` | 명시적 요청 뒤 직접 푸시 |

모든 helper는 Bash 3.2+와 git이 있는 환경의 대상 루트에서 실행합니다. 각 helper는 결과를 표준 출력으로 내고, 입력이 잘못되면 사용법이나 형식 오류와 함께 0이 아닌 값으로 종료합니다. `version-bump.sh`는 `x.y.z` 형식이 아닌 버전과 `+1`, `+patch`, `+minor`, `+major`, 명시적 `x.y.z`가 아닌 bump를 거부하고, `version-current.sh`는 `<file>|<version>`을, `version-find.sh --plain`은 경로만 출력하며, `git-commit.sh`는 넘겨받은 경로만 스테이징하고 무관한 스테이징 변경이 있으면 중단합니다.

</scripts>

<version_rules>

| 인자 | 동작 | 예 |
|------|------|------|
| `+1` / `+patch` | patch +1 | `0.1.13 -> 0.1.14` |
| `+minor` | minor +1 | `0.1.13 -> 0.2.0` |
| `+major` | major +1 | `0.1.13 -> 1.0.0` |
| `x.y.z` | 명시적 설정 | `0.1.13 -> 2.0.0` |

</version_rules>

<stack_targets>

| 스택 | 기본 파일 | 추가 패턴 |
|------|------|------|
| Node | `package.json` | 코드 안의 `.version('x.y.z')` |
| Rust | `Cargo.toml` (`[package].version`) | 코드 안의 `.version('x.y.z')` |
| Python | `pyproject.toml`, `setup.py`, `.py`의 `__version__` | 코드 안의 `.version('x.y.z')` |

</stack_targets>

<git_integration>

- 사용자가 버전 작업만 요청했으면 버전 파일과 diff 검토에서 멈춥니다. 커밋과 푸시를 하지 않습니다.
- 커밋을 요청받았으면 `bash scripts/git-commit.sh "chore: bump version to x.y.z" [files...]`를 `version-update`가 바꾼 파일만 넘겨 실행합니다. 사용자가 다른 메시지를 요청했으면 그 메시지를 씁니다.
- 푸시를 요청받았으면 커밋이 성공한 뒤에만, 그리고 사용자가 명시적으로 푸시를 요청했을 때만 `bash scripts/git-push.sh`를 실행합니다.
- git 쓰기 작업은 순서대로 진행합니다.

</git_integration>

<workflow>

| 단계 | 작업 | 단계를 끝내는 근거 |
|---|---|---|
| 1. 감지 | 대상 루트에서 `bash scripts/stack-detect.sh` 실행 | 출력된 스택 목록, 또는 지원하지 않는 스택 중단 |
| 2. 탐색 | `bash scripts/version-find.sh` 실행 | 버전을 담은 파일 목록 |
| 3. 현재 값 읽기 | `bash scripts/version-current.sh [file]` 실행 | `<file>|<version>` 줄 |
| 4. 목표 계산 | `bash scripts/version-bump.sh <current> <type>` 실행 | 목표 버전 |
| 5. 적용 | `bash scripts/version-apply.sh <new> [files...]` 실행 | 의도한 모든 파일이 새 버전을 담은 상태 |
| 6. 검토 | `git diff --stat`과 `git diff` 실행 | 의도한 파일만 바뀐 diff를 읽은 상태 |
| 7. 커밋(요청 시) | 메시지와 파일을 붙여 `bash scripts/git-commit.sh` 실행 | 버전 파일만 건드린 커밋 |
| 8. 푸시(요청 시) | 커밋 성공 뒤 `bash scripts/git-push.sh` 실행 | 푸시 결과 |

</workflow>

<required>

| 범주 | 요구 사항 |
|------|------|
| 입력 | ARGUMENT를 bump 규칙이나 명시적 semver로 해석합니다. |
| 탐색 | 버전을 적용하기 전에 `bash scripts/version-find.sh`를 실행합니다. |
| 현재 상태 | 목표 버전을 계산하기 전에 `bash scripts/version-current.sh`로 현재 버전을 읽습니다. |
| 일관성 | 찾아낸 버전 파일을 모두 같은 값으로 유지합니다. |
| Git 범위 | version-update 파일 집합만 커밋합니다. |
| 안전 | 사용자가 다른 메시지를 요청하지 않았으면 관례적인 커밋 메시지(`chore: bump version to x.y.z`)를 씁니다. |
| Git | `bash scripts/git-commit.sh`와 `bash scripts/git-push.sh`는 요청받은 git 쓰기에만, 순서대로 씁니다. |

</required>

<forbidden>

| 범주 | 금지 |
|------|------|
| 상태 | 현재 버전을 읽지 않고 업데이트를 적용하기 |
| 일관성 | 버전 파일 하나만 바꾸고 나머지를 예전 값으로 남기기 |
| Git 범위 | version-update 파일 집합 밖의 파일을 커밋하기 |
| Git 안전 | 보호 브랜치 강제 푸시, 커밋이 실패했는데 푸시하기 |
| 권한 | 사용자가 버전 변경만 요청했는데 커밋하거나 푸시하기 |

</forbidden>

<validation>

Trigger 점검:

- [ ] 긍정 trigger 예시 3개 이상이 여전히 유효합니다.
- [ ] 부정 trigger 예시 2개 이상이 범위 밖으로 남습니다.
- [ ] 경계 예시 1개 이상이 커밋과 비커밋을 명시적으로 구분합니다.

실행 점검:

- [ ] `bash scripts/version-current.sh`로 현재 버전을 확인했습니다.
- [ ] `bash scripts/version-bump.sh`로 목표 버전을 계산했거나 명시적 semver를 검증했습니다.
- [ ] `bash scripts/version-apply.sh`가 의도한 파일을 모두 갱신했습니다.
- [ ] `git diff`를 검토했습니다.
- [ ] 요청받은 커밋은 version-update 파일만 넘겨 `bash scripts/git-commit.sh`로 수행했습니다.
- [ ] 요청받은 푸시는 커밋 성공 뒤에만 `bash scripts/git-push.sh`로 수행했습니다.

</validation>
