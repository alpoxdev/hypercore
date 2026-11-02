---
name: git-worktree
description: '격리된 브랜치 폴더와 병렬 에이전트 세션을 위해 Git worktree를 생성, 진입, 목록화, 삭제, 정리, 복구합니다. Git worktree 생성·삭제, `git-worktree ARGUMENT` 직접 생성, 브랜치별 폴더 작업, 병렬 Codex/Claude/Cursor 작업공간, 저장소 로컬 `.hyper/git-worktree/` 규칙을 요청할 때 사용합니다.'
compatibility: '`git worktree`를 지원하는 Git이 필요합니다. 번들 validator는 bash 3.2 이상과 jq 1.6 이상이 필요합니다. 에디터, tmux, 에이전트 CLI는 이미 사용 가능한 경우에만 선택적으로 사용합니다.'
---

@rules/worktree-lifecycle.md

# Git Worktree Skill

> 브랜치별 격리 작업공간을 빠르고, 잘 보이고, 안전하게 만듭니다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- 프로젝트 규칙인 `.hyper/git-worktree/<folder_name>` 아래 Git worktree를 만들고 관리합니다.
- 병렬 기능 개발, 에이전트 세션, 리뷰, 핫픽스, 실험을 브랜치 전환 없이 진행하게 합니다.
- 생성 전 작업 목적 확인, 삭제·정리 전 상태 확인, 경로가 생략된 삭제 요청에서 현재 linked worktree 해석, 명시적 경로 사용, Git worktree 레지스트리 검증으로 안전하게 운영합니다.
- 사용자에게 확인 질문이 필요하면 사용자의 언어를 따릅니다. 한국어 요청에는 영어 작업 메뉴를 보여주지 않습니다.

</purpose>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | 격리된 Git worktree workspace를 생성, 진입, 점검, 삭제, 정리, 복구합니다. |
| Trigger | worktree/workspace/branch-folder 격리 요청 또는 명시적 `git-worktree` 작업에 활성화합니다. |
| Scope | repository/worktree 탐지, path와 branch 도출, local exclude 설정, worktree lifecycle command, context movement, status reporting을 담당합니다. 커밋, 병합, pull request, 컨테이너·VM 격리는 범위 밖입니다. |
| Authority | 사용자와 프로젝트 지시가 이 스킬보다 우선합니다. Git worktree registry 출력, branch state, filesystem check는 실행 근거입니다. |
| Evidence | mutation 전에 `git rev-parse`, `git worktree list --porcelain`, target-path check, branch ref, per-worktree status를 사용합니다. |
| Tools | native Git과 shell을 사용합니다. editor, tmux, agent launch는 사용 가능하고 작업상 요청된 경우에만 선택적으로 실행합니다. |
| Loop | 루프 없음. 요청된 lifecycle 작업마다 한 번씩 repository 탐지, 대상 해석, 안전 점검, mutation, 검증, 보고를 수행합니다. 추가 worktree 작업이 요청된 경우에만 반복하며, dirty/destructive/ambiguous 대상은 mutation 전에 멈춥니다. |
| Output | worktree path, branch/commit, clean/dirty state, active-context movement, remaining setup/cleanup에 대한 한국어 report입니다. |
| Verification | repository root, worktree registry, target path safety, post-create working directory/status, pre-remove status 또는 prune dry run을 확인합니다. |
| Stop condition | 요청된 lifecycle operation이 검증되었거나 dirty/destructive/ambiguous target이 mutation 전에 보고되었을 때 멈춥니다. |

</instruction_contract>

<routing_rule>

다음 요청에는 `git-worktree`를 사용합니다.

- worktree, workspace, branch folder, isolated checkout 생성
- 같은 저장소에서 여러 코딩 에이전트나 작업을 병렬 실행
- worktree 목록, 열기, 이동, 삭제, prune, repair, lock, unlock
- 이미 linked worktree 안에 있는 사용자가 "이 worktree 지워줘", "워크트리 삭제"처럼 현재 worktree 삭제를 요청한 경우
- `.hyper/git-worktree/<folder_name>` 규칙 표준화 또는 설정
- PR/이슈/브랜치를 별도 로컬 디렉터리에서 리뷰 또는 테스트

다음 요청에는 사용하지 않습니다.

- 현재 폴더에서 일반 브랜치 생성/checkout만 원하는 경우
- worktree 작업 없이 rebase, 커밋 정리, 히스토리 조작만 원하는 경우
- 실행할 작업 없이 Git 개념만 묻는 경우
- Git worktree가 아니라 컨테이너, VM, 별도 clone 격리가 필요한 경우

</routing_rule>

<activation_examples>

긍정 요청:

- "`feature/auth` 브랜치 worktree 만들고 Codex를 거기서 열어줘."
- "`git-worktree fix/api-timeout`"
- "병렬 에이전트용으로 격리된 worktree 세 개 만들어줘."
- "새 worktree 만들고 바로 그 폴더로 이동해줘."
- "활성 git worktree 목록 보고 오래된 것 안전하게 지워줘."
- "이미 이 워크트리 안에 있는데, 워크트리 삭제해줘."
- "PR #42를 별도 worktree에서 리뷰할 수 있게 세팅해줘."

부정 요청:

- "여기서 새 브랜치 만들고 checkout 해줘." 일반 Git 브랜치 작업을 사용합니다.
- "Git worktree가 뭔지 설명해줘." 직접 설명합니다.
- "브랜치마다 Docker 개발환경을 만들어줘." 컨테이너/개발환경 워크플로를 사용합니다.

경계 요청:

- "위험한 리팩터링을 격리 작업공간에서 하게 세팅해줘." 브랜치 수준 격리로 충분하면 이 스킬을 사용하고, 런타임·DB·포트 격리가 필요하면 더 강한 격리 워크플로로 넘깁니다.

</activation_examples>

<support_file_read_order>

1. 위에서 불러온 `rules/worktree-lifecycle.md`가 명령 패턴, 이름 규칙, 안전 점검, 삭제, prune, repair, context 이동 규칙을 소유합니다.
2. 근거, upstream behavior, source comparison이 필요할 때만 `references/source-survey.md`를 읽습니다. 기본으로는 불러오지 않습니다.
3. 이 스킬 폴더를 수정한 뒤에는 `scripts/validate-git-worktree-skill.sh`를 실행하고, `assets/evals/git-worktree-cases.jsonl`이 바뀐 동작을 계속 다루는지 확인합니다.

</support_file_read_order>

<defaults>

- 기본 경로: 사용자가 다른 경로를 주지 않았으면 `<repo-root>/.hyper/git-worktree/<folder_name>`입니다.
- 직접 인자: 사용자가 `git-worktree <ARGUMENT>`처럼 스킬 이름 뒤에 단일 위치 인자를 주면 `<ARGUMENT>`를 명시적인 생성 대상으로 보고 어떤 worktree를 만들지 되묻지 않습니다. 명백한 PR/이슈/ref/경로가 아니라면 브랜치/작업 라벨로 해석하고, 실제 브랜치명은 보존한 채 폴더 라벨만 안전하게 slug 처리합니다. 인자가 위험하거나, 예약어이거나, 관련 없는 경로와 충돌하거나, Git ref/브랜치/작업 라벨로 해석할 수 없을 때만 추가 질문합니다.
- 작업 목적: 인자, 브랜치, PR, 이슈, 작업명이 하나도 없으면 생성 전에 "이 worktree에서 어떤 작업을 할 예정인가요?"라고 묻고, 답변을 짧고 안전한 경로 문자열로 바꿔 폴더명을 정합니다.
- 작업 종류: 가능한 한 요청 문맥에서 추론합니다. 정말 모호할 때만 "어떤 worktree 작업을 원하시나요? 생성, 목록, 열기/이동, 삭제, 정리, 복구, 잠금, 잠금 해제 중에서 알려주세요."처럼 한국어로 한 번 묻습니다. 영어 작업 메뉴는 사용하지 않습니다.
- 컨텍스트 이동: 생성은 새 worktree 컨텍스트로 전환된 뒤에 완료로 봅니다. persistent shell/session이 있으면 그 세션에서 실제로 `cd <path>`를 실행합니다. tool-only 환경이면 다음 명령의 `workdir=<path>`를 새 worktree로 설정하고 이후 명령도 그 경로에서 계속 실행합니다. `cd <path>`를 최종 답변으로 표시만 하고 멈추지 않습니다. 부모 셸에 지속 적용할 수 없는 환경에서만 `cd <path>`를 사용자가 실행할 fallback 명령으로 보고하고, 에이전트 컨텍스트가 실제로 이동했는지 함께 밝힙니다.
- 경로 없는 삭제: 현재 컨텍스트가 linked worktree 안이면 현재 worktree 루트를 삭제 대상으로 삼되, 삭제 전에 안전한 다른 worktree로 이동하고 main worktree는 절대 삭제하지 않습니다.
- 중첩 worktree 생성 전에 `.hyper/git-worktree/`가 local exclude 되어 있는지 확인합니다.
- 추가 매니저보다 네이티브 `git worktree` 명령을 우선하고, worktree 하나당 작업·브랜치·터미널 세션·에디터 창 하나를 선호합니다.

</defaults>

<workflow>

1. `git rev-parse --show-toplevel`로 저장소 루트를 확인하고 `git worktree list --porcelain`을 읽습니다.
2. 작업 유형(create/open/list/remove/prune/repair/lock/unlock)을 정합니다.
3. 대상을 정합니다. 생성이면 직접 인자나 요청에 나온 작업을 쓰고, 둘 다 없을 때만 작업 목적을 묻습니다. linked worktree 안에서 경로 없이 삭제를 요청하면 저장한 현재 top-level 경로가 대상이며, main worktree라면 멈춥니다.
4. 해당 작업에 대한 lifecycle 규칙의 안전 점검과 명령을 실행합니다.
5. "생성하고 들어가/이동/전환/열어줘" 요청은 하나의 작업으로 처리합니다. `git worktree add`나 `cd <path>` 안내만 하고 멈추지 말고, 실제로 컨텍스트를 옮기거나 다음 명령이 `workdir=<path>`에서 실행됐음을 보입니다.
6. 경로, 브랜치/커밋, clean/dirty 상태, 사용한 컨텍스트 이동 방식, 남은 setup을 보고합니다. 정리 작업이면 남은 `git worktree list`도 보고합니다.

</workflow>

<validation>

결정적 회귀 검증 명령:

```bash
bash skills/git-worktree/scripts/validate-git-worktree-skill.sh
```

- [ ] 경로 생성이나 mutation 전에 저장소 루트와 `git worktree list --porcelain`을 확인했습니다.
- [ ] `git-worktree <ARGUMENT>` 직접 호출은 어떤 worktree를 만들지 되묻지 않고 인자에서 생성 대상을 도출합니다. 그 외에 생성 목적이 없으면 폴더명을 정하기 전에 한 번만 묻습니다.
- [ ] 한국어 사용자에게 확인 질문을 할 때 영어 작업 메뉴를 보여주지 않았습니다.
- [ ] `.hyper/git-worktree/`가 local exclude 처리되었습니다.
- [ ] 삭제 전 `git -C <path> status --short`를 확인했습니다.
- [ ] 현재 worktree 삭제는 현재 top-level 경로를 저장하고, main worktree 삭제를 거부하며, 안전한 다른 worktree로 이동한 뒤 저장된 대상 경로를 제거합니다.
- [ ] prune 전 `git worktree prune --dry-run`을 실행했습니다.
- [ ] 생성 후 `cd <path>`만 출력하고 멈추지 않았습니다. persistent session에서는 실제로 디렉터리를 바꿨고, tool-only 환경에서는 적어도 하나의 후속 명령을 `workdir=<path>`에서 실행했습니다.

</validation>
