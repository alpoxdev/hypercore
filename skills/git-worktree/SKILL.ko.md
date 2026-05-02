---
name: git-worktree
description: '격리된 브랜치 폴더와 병렬 에이전트 세션을 위해 Git worktree를 생성, 진입, 목록화, 삭제, 정리, 복구할 때 사용하며, 이미 해당 linked worktree 안에 있는 상태에서 "워크트리 삭제"처럼 요청한 경우에도 안전하게 처리합니다. `git-worktree <ARGUMENT>`처럼 인자가 있으면 되묻지 않고 바로 생성 대상으로 사용합니다. `.hypercore/git-worktree/<folder_name>` 프로젝트 규칙으로 워크트리를 만들거나 관리해 달라는 요청에 맞추며, 생성 작업의 목적과 인자가 모두 불명확할 때만 한국어로 어떤 작업을 할지 물어 폴더명을 정한 뒤 새 worktree로 후속 작업 컨텍스트를 이동합니다.'
compatibility: '`git worktree`를 지원하는 Git이 필요합니다. 에디터, tmux, 에이전트 CLI는 이미 사용 가능한 경우에만 선택적으로 사용합니다.'
---

@rules/worktree-lifecycle.md
@references/source-survey.md

# Git Worktree Skill

> 브랜치별 격리 작업공간을 빠르고, 잘 보이고, 안전하게 만듭니다.

<purpose>

- 프로젝트 규칙인 `.hypercore/git-worktree/<folder_name>` 아래 Git worktree를 만들고 관리합니다.
- 병렬 기능 개발, 에이전트 세션, 리뷰, 핫픽스, 실험을 브랜치 전환 없이 진행하게 합니다.
- 생성 전 작업 목적 확인, 삭제·정리 전 상태 확인, 경로가 생략된 삭제 요청에서 현재 linked worktree 해석, 명시적 경로 사용, Git worktree 레지스트리 검증으로 안전하게 운영합니다.
- 사용자에게 확인 질문이 필요하면 사용자의 언어를 따릅니다. 한국어 요청에는 영어 작업 메뉴를 보여주지 않습니다.

</purpose>

<routing_rule>

다음 요청에는 `git-worktree`를 사용합니다.

- worktree, workspace, branch folder, isolated checkout 생성
- 같은 저장소에서 여러 코딩 에이전트나 작업을 병렬 실행
- worktree 목록, 열기, 이동, 삭제, prune, repair, lock, unlock
- 이미 linked worktree 안에 있는 사용자가 "이 worktree 지워줘", "워크트리 삭제"처럼 현재 worktree 삭제를 요청한 경우
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
- "`git-worktree fix/api-timeout`"
- "이 브랜치를 `.hypercore/git-worktree` 아래 워크트리로 만들어줘."
- "병렬 에이전트용으로 격리된 worktree 세 개 만들어줘."
- "새 worktree 만들고 바로 그 폴더로 이동해줘."
- "활성 git worktree 목록 보고 오래된 것 안전하게 지워줘."
- "이미 이 워크트리 안에 있는데, 워크트리 삭제해줘."
- "I'm already in this worktree; delete this worktree safely."

부정 요청:

- "여기서 새 브랜치 만들고 checkout 해줘." 일반 Git 브랜치 작업을 사용합니다.
- "Git worktree가 뭔지 설명해줘." 실행 작업이 없으면 직접 설명합니다.
- "브랜치마다 Docker 개발환경을 만들어줘." 컨테이너/개발환경 워크플로를 사용합니다.

경계 요청:

- "위험한 리팩터링을 격리 작업공간에서 하게 세팅해줘."
  브랜치 수준 격리로 충분하면 이 스킬을 사용하고, 런타임·DB·포트 격리가 필요하면 더 강한 격리 워크플로로 넘깁니다.

</activation_examples>

<argument_handling>

- 사용자가 `git-worktree <ARGUMENT>`처럼 스킬 이름 뒤에 단일 위치 인자를 주면 `<ARGUMENT>`를 명시적인 생성 대상으로 보고 어떤 worktree를 만들지 되묻지 않습니다.
- `<ARGUMENT>`가 명백한 PR/이슈/ref/경로가 아니라면 브랜치/작업 라벨로 해석합니다. 실제 브랜치명은 보존하고 폴더 라벨만 안전하게 slug 처리합니다.
- 기본 경로 `.hypercore/git-worktree/<folder_name>`에 생성한 뒤 후속 에이전트 작업 컨텍스트를 새 worktree로 이동합니다.
- 인자가 위험하거나, 예약어이거나, 기존 관련 없는 경로와 충돌하거나, Git ref/브랜치/작업 라벨로 해석할 수 없을 때만 추가 질문합니다.

</argument_handling>

<defaults>

- 기본 루트: `<repo-root>/.hypercore/git-worktree/`.
- 기본 경로: `<repo-root>/.hypercore/git-worktree/<folder_name>`.
- 기본 `<folder_name>`: 사용자가 명확한 인자나 작업명을 주지 않았으면 먼저 "이 worktree에서 어떤 작업을 할 예정인가요?"라고 물은 뒤 답변을 안전한 경로 문자열로 변환한 값입니다.
- 사용자가 이미 위치 인자, 브랜치, PR, 이슈, 작업명을 제공했다면 다시 묻지 않고 그 맥락에서 `<folder_name>`을 정합니다.
- 작업 종류는 가능한 한 요청 문맥에서 추론합니다. 정말 모호할 때만 "어떤 worktree 작업을 원하시나요? 생성, 목록, 열기/이동, 삭제, 정리, 복구, 잠금, 잠금 해제 중에서 알려주세요."처럼 한국어로 한 번 묻습니다. 영어 작업 메뉴는 사용하지 않습니다.
- 생성 직후 후속 명령의 작업 디렉터리를 새 worktree 경로로 이동합니다. 생성은 새 worktree 컨텍스트로 전환된 뒤에 완료로 봅니다. 사용자 셸에 대해서는 `cd <path>` 명령을 함께 보고합니다.
- 경로 없는 삭제 요청이 들어왔고 현재 컨텍스트가 이미 linked worktree 안이라면 현재 worktree 루트를 삭제 대상으로 삼되, 삭제 전에 안전한 다른 worktree로 이동하고 main worktree는 절대 삭제하지 않습니다.
- 중첩 worktree 생성 전에 `.hypercore/git-worktree/`가 ignore 또는 local exclude 되어 있는지 확인합니다.
- 추가 매니저 설치보다 네이티브 `git worktree` 명령을 우선합니다.
- worktree 하나당 작업 하나, 브랜치 하나, 터미널/에디터/에이전트 세션 하나를 선호합니다.

</defaults>

<workflow>

1. `git rev-parse --show-toplevel`로 저장소 루트를 확인합니다.
2. `git worktree list --porcelain`으로 기존 worktree를 읽습니다.
3. 작업 유형(create/open/list/remove/prune/repair/lock/unlock)을 정합니다.
4. 삭제 요청에 명시 경로가 없고 현재 디렉터리가 linked worktree 안이면 `git rev-parse --show-toplevel` 결과를 삭제 대상으로 선택합니다. main worktree라면 저장소 루트를 지우지 말고 구체적인 대상 확인으로 멈춥니다.
5. `git-worktree <ARGUMENT>` 인자가 있으면 생성 대상으로 보고 질문 전에 브랜치명, 폴더명, base ref를 그 인자에서 도출합니다.
6. 생성 작업이고 작업 목적이 불명확하면 먼저 "이 worktree에서 어떤 작업을 할 예정인가요?"처럼 한국어 한 문장으로 물어봅니다.
7. 답변, 인자, 또는 기존 요청 맥락에서 `.hypercore/git-worktree/<folder_name>`의 폴더명을 정합니다.
8. 자세한 명령과 안전 규칙은 `@rules/worktree-lifecycle.md`를 따릅니다.
9. "생성하고 들어가/이동/전환/열어줘" 요청은 하나의 작업으로 처리합니다. `git worktree add`만 하고 멈추지 말고 후속 작업 컨텍스트를 새 worktree 경로로 이동합니다.
10. 생성 후에는 경로, 브랜치/커밋, clean/dirty 상태, 실제로 사용한 작업 디렉터리, 사용자 셸용 `cd <path>` 명령, 남은 setup을 보고합니다. 삭제 후에는 제거된 경로와 남은 worktree 목록을 보고합니다.

</workflow>

<validation>

결정적 회귀 검증 명령:

```bash
python3 skills/git-worktree/scripts/validate-git-worktree-skill.py
```

- [ ] 긍정/부정/경계 예시가 올바르게 라우팅됩니다.
- [ ] 경로 생성 전 저장소 루트와 기존 worktree 목록을 확인했습니다.
- [ ] `git-worktree <ARGUMENT>` 직접 호출은 어떤 worktree를 만들지 되묻지 않고 인자에서 생성 대상을 도출합니다.
- [ ] 생성 목적이 불명확하면 먼저 어떤 작업을 할지 물었고, 그 답변으로 폴더명을 정했습니다.
- [ ] 한국어 사용자에게 확인 질문을 할 때 영어 작업 메뉴를 보여주지 않았습니다.
- [ ] `.hypercore/git-worktree/`가 ignore/local exclude 처리되었습니다.
- [ ] 생성 후 후속 명령은 새 worktree 경로를 작업 디렉터리로 사용했고, 부모 셸에 지속 적용할 수 없으면 `cd <path>`를 별도로 안내했습니다.
- [ ] 삭제 전 `git -C <path> status --short`를 확인했습니다.
- [ ] 현재 worktree 삭제는 먼저 현재 top-level 경로를 저장하고, main worktree 삭제를 거부하며, 안전한 다른 worktree로 이동한 뒤 저장된 대상 경로를 제거합니다.
- [ ] prune 전 `git worktree prune --dry-run`을 실행했습니다.
- [ ] 조사 근거와 장점은 `references/source-survey.md`에만 둡니다.

</validation>
