---
name: git-worktree
description: 격리된 브랜치 폴더와 병렬 에이전트 세션을 위해 Git worktree를 생성, 진입, 목록화, 정리, 복구할 때 사용합니다. `.hypercore/git-worktree/<folder_name>` 프로젝트 규칙으로 워크트리를 만들거나 관리해 달라는 요청에 맞추며, 생성 작업의 목적이 불명확하면 먼저 어떤 작업을 할지 물어 폴더명을 정한 뒤 새 worktree로 후속 작업 컨텍스트를 이동합니다.
compatibility: `git worktree`를 지원하는 Git이 필요합니다. 에디터, tmux, 에이전트 CLI는 이미 사용 가능한 경우에만 선택적으로 사용합니다.
---

@rules/worktree-lifecycle.md
@references/source-survey.md

# Git Worktree Skill

> 브랜치별 격리 작업공간을 빠르고, 잘 보이고, 안전하게 만듭니다.

<purpose>

- 프로젝트 규칙인 `.hypercore/git-worktree/<folder_name>` 아래 Git worktree를 만들고 관리합니다.
- 병렬 기능 개발, 에이전트 세션, 리뷰, 핫픽스, 실험을 브랜치 전환 없이 진행하게 합니다.
- 생성 전 작업 목적 확인, 삭제·정리 전 상태 확인, 명시적 경로 사용, Git worktree 레지스트리 검증으로 안전하게 운영합니다.

</purpose>

<routing_rule>

다음 요청에는 `git-worktree`를 사용합니다.

- worktree, workspace, branch folder, isolated checkout 생성
- 같은 저장소에서 여러 코딩 에이전트나 작업을 병렬 실행
- worktree 목록, 열기, 이동, 삭제, prune, repair, lock, unlock
- `.hypercore/git-worktree/<folder_name>` 규칙 표준화
- PR/이슈/브랜치를 별도 로컬 디렉터리에서 리뷰 또는 테스트

다음 요청에는 사용하지 않습니다.

- 현재 폴더에서 일반 브랜치 생성/checkout만 원하는 경우
- worktree 작업 없이 rebase, 커밋 정리, 히스토리 조작만 원하는 경우
- Git worktree가 아니라 컨테이너, VM, 별도 clone 격리가 필요한 경우

</routing_rule>

<activation_examples>

긍정 요청:

- "`feature/auth` 브랜치 worktree 만들고 Codex를 거기서 열어줘."
- "이 브랜치를 `.hypercore/git-worktree` 아래 워크트리로 만들어줘."
- "병렬 에이전트용으로 격리된 worktree 세 개 만들어줘."
- "새 worktree 만들고 바로 그 폴더로 이동해줘."
- "활성 git worktree 목록 보고 오래된 것 안전하게 지워줘."

부정 요청:

- "여기서 새 브랜치 만들고 checkout 해줘." 일반 Git 브랜치 작업을 사용합니다.
- "Git worktree가 뭔지 설명해줘." 실행 작업이 없으면 직접 설명합니다.
- "브랜치마다 Docker 개발환경을 만들어줘." 컨테이너/개발환경 워크플로를 사용합니다.

경계 요청:

- "위험한 리팩터링을 격리 작업공간에서 하게 세팅해줘."
  브랜치 수준 격리로 충분하면 이 스킬을 사용하고, 런타임·DB·포트 격리가 필요하면 더 강한 격리 워크플로로 넘깁니다.

</activation_examples>

<defaults>

- 기본 루트: `<repo-root>/.hypercore/git-worktree/`.
- 기본 경로: `<repo-root>/.hypercore/git-worktree/<folder_name>`.
- 기본 `<folder_name>`: 사용자가 명확한 작업명을 주지 않았으면 먼저 "이 worktree에서 어떤 작업을 할 예정인가요?"라고 물은 뒤 답변을 안전한 경로 문자열로 변환한 값입니다.
- 사용자가 이미 브랜치, PR, 이슈, 작업명을 제공했다면 다시 묻지 않고 그 맥락에서 `<folder_name>`을 정합니다.
- 생성 직후 후속 명령의 작업 디렉터리를 새 worktree 경로로 이동합니다. 사용자 셸에 대해서는 `cd <path>` 명령을 함께 보고합니다.
- 중첩 worktree 생성 전에 `.hypercore/git-worktree/`가 ignore 또는 local exclude 되어 있는지 확인합니다.
- 추가 매니저 설치보다 네이티브 `git worktree` 명령을 우선합니다.
- worktree 하나당 작업 하나, 브랜치 하나, 터미널/에디터/에이전트 세션 하나를 선호합니다.

</defaults>

<workflow>

1. `git rev-parse --show-toplevel`로 저장소 루트를 확인합니다.
2. `git worktree list --porcelain`으로 기존 worktree를 읽습니다.
3. 작업 유형(create/open/list/remove/prune/repair/lock/unlock)을 정합니다.
4. 생성 작업이고 작업 목적이 불명확하면 먼저 어떤 작업을 할 예정인지 한 문장으로 물어봅니다.
5. 답변 또는 기존 요청 맥락에서 `.hypercore/git-worktree/<folder_name>`의 폴더명을 정합니다.
6. 자세한 명령과 안전 규칙은 `@rules/worktree-lifecycle.md`를 따릅니다.
7. 생성 직후 후속 작업 컨텍스트를 새 worktree 경로로 이동하고, 경로, 브랜치/커밋, clean/dirty 상태, 진입·열기 명령, 남은 setup을 보고합니다.

</workflow>

<validation>

- [ ] 긍정/부정/경계 예시가 올바르게 라우팅됩니다.
- [ ] 경로 생성 전 저장소 루트와 기존 worktree 목록을 확인했습니다.
- [ ] 생성 목적이 불명확하면 먼저 어떤 작업을 할지 물었고, 그 답변으로 폴더명을 정했습니다.
- [ ] `.hypercore/git-worktree/`가 ignore/local exclude 처리되었습니다.
- [ ] 생성 후 후속 명령은 새 worktree 경로를 작업 디렉터리로 사용합니다.
- [ ] 삭제 전 `git -C <path> status --short`를 확인했습니다.
- [ ] prune 전 `git worktree prune --dry-run`을 실행했습니다.
- [ ] 조사 근거와 장점은 `references/source-survey.md`에만 둡니다.

</validation>
