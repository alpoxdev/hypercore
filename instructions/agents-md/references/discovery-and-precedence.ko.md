# 탐색과 우선순위

> 영어판: [`discovery-and-precedence.md`](discovery-and-precedence.md)

**목적**: 각 런타임이 instruction 파일을 실제로 어떻게 찾고 결합하는지 기록해, 중첩 파일이 내가 쓰는 하나가 아니라 모든 구현에서 옳도록 작성하게 한다.

아래 사실은 모두 벤더가 자기 제품에 대해 밝힌 내용이며 2026-11-03에 확인했다. 이 베이스에서 가장 빠르게 변하는 자료이므로 분기마다 재검증한다.

---

## 1. "가장 가까운 파일이 이긴다"의 함정

`AGENTS.md` 사이트는 규칙을 이렇게 적는다: "Place another AGENTS.md inside each package. Agents automatically read the nearest file in the directory tree, so the closest one takes precedence and every subproject can ship tailored instructions."

> "The closest AGENTS.md to the edited file wins; explicit user chat prompts override everything."

**대부분의 구현은 이렇게 동작하지 않는다.** 실제로는 merge하며, "closest wins"는 concatenate된 프롬프트 안의 순서로만 달성된다. 부모 파일은 여전히 로드되어 context에 남아 있다.

| 런타임 | 실제 결합 동작 |
|---|---|
| **OpenAI Codex** | 루트→말단 concatenate. 더 가까운 파일이 "because they appear later in the combined prompt" override |
| **Claude Code** | "All discovered files are concatenated into context rather than overriding each other". 어떤 파일을 *탐색*하는지는 **Project instructions** 설정에 달려 있다. 기본값 `claude-md-or-agents-md`에서는 작업 디렉터리나 그 위에 `CLAUDE.md`나 `CLAUDE.local.md`가 없을 때만 `AGENTS.md`를 읽고, `claude-md-and-agents-md`에서는 둘 다 읽는다(§2) |
| **Cursor** | "Instructions from nested `AGENTS.md` files are combined with parent directories, with more specific instructions taking precedence" |
| **GitHub Copilot** | GitHub.com의 Copilot Chat에서는 "the nearest `AGENTS.md` file in the directory tree will take precedence". 다만 Copilot 문서 스스로 이 판정이 surface에 국한된다고 밝힌다: "Most surfaces and clients, including Copilot CLI, Visual Studio Code and Visual Studio, combine applicable instruction files without defining a general precedence order" |

### 여기서 도출되는 작성 규칙

어떤 에이전트가 읽을지 통제할 수 없으므로 중첩 instruction 파일은 **두 방식 모두**에서 옳아야 한다. 부모의 부재에 기대지 않는다. Codex, Claude Code, Cursor에서 루트 파일은 여전히 로드되므로 "루트의 test 명령을 무시하라"고 쓴 중첩 파일은 루트 텍스트를 없애지 못하고, 모델이 위치로 조용히 해소하는 모순만 만든다. 부모의 존재에도 기대지 않는다. Copilot의 nearest-wins 해석에서는 중첩 파일만 적용될 수 있으므로 그 하위 트리에 필수적인 내용은 거기에 적혀 있어야 한다.

**따라서 중첩 파일은 자기 완결적 delta로 쓴다.** 하위 트리 범위를 명시하고, 부모 규칙을 부정하는 대신 **올바른 규칙을 온전히 다시 진술**해 override한다. 중첩 파일에서는 "루트와 달리 여기서는 bun을 쓰지 말라"보다 "이 패키지의 테스트는 `pnpm -C cli test`로 실행한다"를 택한다.

---

## 2. Claude Code

출처: <https://code.claude.com/docs/en/memory> (문서 최종 수정 2026-10-27, 확인 2026-11-03)

### AGENTS.md는 정식 instruction 파일이다

"Claude Code can read AGENTS.md as your project instructions, so a repository already set up for other coding agents works without adding a CLAUDE.md, an import, or a setting." 직접 읽으려면 v2.1.277 이상이 필요하다.

| 저장소 상태 | Claude가 읽는 것 |
|---|---|
| `AGENTS.md`가 있고, 작업 디렉터리나 그 위에 `CLAUDE.md`나 `CLAUDE.local.md`가 없다 | `AGENTS.md` |
| `AGENTS.md`와 함께 작업 디렉터리나 그 위에 `CLAUDE.md`나 `CLAUDE.local.md`가 있다 | `CLAUDE.md` 파일만 |
| `CLAUDE.md`가 이미 `AGENTS.md`를 import한다 | `CLAUDE.md`, 그 import를 통해 `AGENTS.md` 포함 |

이 판정에 **포함되는**, 따라서 `AGENTS.md`를 억제하는 파일: 작업 디렉터리나 그 위 디렉터리의 `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`. **포함되지 않아** `AGENTS.md`와 나란히 계속 로드되는 파일: `~/.claude/CLAUDE.md`, 조직의 관리 `CLAUDE.md`, `.claude/rules/` 파일.

### 어떤 instruction 파일을 로드할지 고르기

`/config`에 **Project instructions** 설정이 있다.

| 값 | Claude가 읽는 것 |
|---|---|
| `claude-md-or-agents-md` | `CLAUDE.md` 파일, 또는 작업 디렉터리나 그 위에 `CLAUDE.md`·`CLAUDE.local.md`가 없을 때 `AGENTS.md` 파일. **기본값** |
| `claude-md-and-agents-md` | 둘 다. 각 디렉터리의 `CLAUDE.md` 파일이 먼저, 그다음 `AGENTS.md`. import나 심볼릭 링크로 이미 로드된 `AGENTS.md`는 두 번 읽지 않고 건너뛴다 |
| `claude-md` | `CLAUDE.md` 파일만 |
| `managed-only` | 시작 시 조직의 관리 `CLAUDE.md`와 auto memory만. 프로젝트·로컬·사용자 `CLAUDE.md`, `.claude/rules/`, 모든 `AGENTS.md`는 제외된다. 하위 디렉터리의 `CLAUDE.md`와 `.claude/rules/` 파일, 그리고 경로 범위 규칙은 필요할 때 여전히 로드된다 |

같은 값을 `AGENTS.md`를 읽는 내장 플러그인 아래 설정 파일에도 쓸 수 있다.

```json
{
  "pluginConfigs": {
    "cc-plugin-agents-md@builtin": { "options": { "instructionFiles": "claude-md-and-agents-md" } }
  }
}
```

플러그인 ID는 `cc-plugin-agents-md@builtin`이며, v2.1.285 이전에는 `agents-md@builtin`이었다. v2.1.285 이전 버전은 새 `cc-plugin-agents-md@builtin` 항목을 무시하므로 이전 버전도 읽는 설정 파일에는 `agents-md@builtin`을 쓴다. v2.1.285 이후 버전은 두 ID의 항목을 모두 읽는다. Claude Code는 **프로젝트·로컬 설정 파일에서는 이 키를 무시한다.** `~/.claude/settings.json`, `--settings` 파일, 또는 managed settings를 쓴다.

### AGENTS.md 지원이 없는 세션

다음 세션에서는 Claude가 `CLAUDE.md`만 읽고 `/config`에 **Project instructions**가 나타나지 않는다.

- v2.1.277 이전 버전.
- `AGENTS.md`를 읽는 내장 플러그인을 `/plugin`으로 끈 경우.
- v2.1.276 이하에서 업그레이드한 뒤의 첫 세션인 경우가 있다. 이때는 "Claude reads AGENTS.md from your next session on"이다.

프로바이더·telemetry 조건은 현재 사실이 아니라 과거 사실이다. "Before v2.1.281, some sessions, such as those on Amazon Bedrock or with telemetry disabled, read CLAUDE.md files only. On those versions, update Claude Code." v2.1.281 이상을 쓰는 세션은 기본 설정에서 `AGENTS.md`를 읽으므로, 구버전의 해법은 우회책이 아니라 업그레이드다.

그런 세션을 위한 문서화된 대체 경로는 import다. `CLAUDE.md` 안에 `@AGENTS.md`를 둔다.

### CLAUDE.md와 다른 점

| | `CLAUDE.md` | 설정을 통해 읽는 `AGENTS.md` |
|---|---|---|
| `InstructionsLoaded` 훅 | 발생 | 발생하지 않음. `CLAUDE.md`가 import하거나 심볼릭 링크한 `AGENTS.md`에서는 평소대로 발생 |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD`가 켜진 `--add-dir` 디렉터리 | 그 `CLAUDE.md`가 로드됨 | 그 `AGENTS.md`는 로드되지 않음 |
| 작업 디렉터리 밖 파일의 `@path` import | 승인을 요청함 | 그 프로젝트에서 외부 import를 이미 승인한 경우에만, 프롬프트 없이 로드됨 |

목록이 줄었다. `/memory`와 `/context`의 Memory files 목록이 이제 Claude가 읽은 `AGENTS.md`를 포함하므로 경로가 증거로 보인다(v2.1.280 이전에는 그렇지 않았다). 각 `AGENTS.md` 안에서는 `@path` import가 확장되고 `claudeMdExcludes` 패턴이 적용되며, 프로젝트 지시 없이 시작한 subagent도 이 파일 없이 시작한다.

**절대 읽지 않는 것**: `AGENTS.local.md`, `AGENTS.override.md`, `.agents/` 디렉터리 아래의 모든 것. 중첩 `AGENTS.md`는 그 하위 디렉터리에 위 세 `CLAUDE.md` 계열 파일이 하나도 없을 때만 로드된다.

### 이전 AGENTS.md 우회책 정리

- **`@AGENTS.md`를 품은 `CLAUDE.md`**: 그대로 둔다. 어떤 설정에서도 두 번 읽히지 않으며, `AGENTS.md`를 직접 읽지 못하는 세션을 계속 커버한다.
- **글로 "`AGENTS.md`를 읽으라"고 적은 `CLAUDE.md`**: 지우거나 그 문장을 import로 바꾼다. Claude는 스스로 결정할 때만 그 파일을 연다.
- **`AGENTS.md`를 가리키는 심볼릭 링크 `CLAUDE.md`, 또는 그것을 출력하는 `SessionStart` 훅**: 심볼릭 링크는 그대로 두어도 되고(import를 선호하면 지운다) 훅은 제거한다. context에 두 번째 사본을 더할 뿐이다.

심볼릭 링크 주의: Edit·Write 도구는 심볼릭 링크를 통해 쓰기를 거부하고 링크 대상 파일을 수정하도록 안내하며, Windows에서는 `core.symlinks`가 켜져 있지 않으면 커밋된 심볼릭 링크가 일반 텍스트 파일로 체크아웃된다. 그래서 그런 환경에서는 import를 택한다.

### 탐색

> "Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from your current working directory and every directory above it."

> "All discovered files are concatenated into context rather than overriding each other."

> "Claude also discovers CLAUDE.md and CLAUDE.local.md files in subdirectories under your current working directory. Instead of loading them at launch, they are included when Claude reads files in those subdirectories."

즉 상위 파일은 **시작 시 즉시** 로드되고, 하위 파일은 **해당 파일 접근 시 지연** 로드된다. concatenate 순서는 "content is ordered from the filesystem root down to your working directory"이며, 각 디렉터리 안에서는 "CLAUDE.local.md is appended after CLAUDE.md, so your personal notes are the last thing Claude reads at that level"이다. 깊은 중첩 파일은 에이전트가 그 하위 트리를 건드리기 전까지 비용이 0이므로, 대형 monorepo에서 중첩이 올바른 도구가 된다.

### Import

> "CLAUDE.md files can import additional files using `@path/to/import` syntax."

> "Both relative and absolute paths are allowed. Relative paths resolve relative to the file containing the import, not the working directory."

import된 파일은 "can recursively import other files, with a maximum depth of four hops"다.

실무에서 걸리는 parser 규칙이 셋이다. 경로에 공백이 있으면 공백마다 백슬래시를 넣어야 하고, 따옴표로 감싼 경로는 "isn't imported at all"이며, "Import parsing skips Markdown code spans and fenced code blocks"이므로 `` `@README` ``는 글자로 남고 `@README`는 파일을 import한다. 파일을 옮기면 import가 깨지는 것도 상대 경로가 import한 파일 기준으로 해석되기 때문이다.

### 규칙, 크기, context 비용

`.claude/rules/`는 주제별 파일을 재귀적으로 탐색해, 한 파일을 키우는 대신 주제별로 나눌 수 있게 한다. `paths` frontmatter가 없는 규칙은 시작 시 `.claude/CLAUDE.md`와 같은 우선순위로 로드되고, `paths` 목록이 있으면 일치하는 파일을 읽을 때만 로드된다. 규칙은 매 세션 또는 일치 파일을 열 때 로드되므로, 작업 특정 지시는 skill에 둔다.

> "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence. Move instructions that matter for only part of the codebase into path-scoped rules, which load only when Claude works with those files."

이는 권고이고 상한이 아니다. 상한은 따로 있으며 훨씬 높다.

> "Claude gets the whole of each CLAUDE.md file that loads at launch, as long as the file is 4 MiB or smaller. Claude Code skips a file over 4 MiB and loads none of it. Path-scoped rules and CLAUDE.md files in subdirectories have a smaller per-file limit of their own."

그래서 시작 시 로드되는 파일은 잘려서 맞춰지지 않는다. 전부 로드되거나 전부 버려진다. 하위 디렉터리 파일은 다르게 동작한다: "If a nested CLAUDE.md is over its per-file size limit, Claude receives only the start of the file." auto-memory의 절단이 가장 강하다: "The first 200 lines of MEMORY.md, or the first 25KB, whichever comes first, are loaded at the start of every conversation." 서로 다른 세 한계이며, 긴 `CLAUDE.md`는 상한에 닿기 전에 이미 준수율을 조용히 떨어뜨린다.

### 관련 파일과 명령

- `CLAUDE.local.md` — 개인용 프로젝트 선호이며 gitignore 대상으로 문서화되어 있다. 이 파일도 `AGENTS.md` 판정에 포함되므로, `AGENTS.md`를 쓰는 저장소에 두면 **Project instructions**가 `claude-md-and-agents-md`가 아닌 한 Claude가 `AGENTS.md`를 읽지 않는다.
- auto-memory는 프로젝트별로 `~/.claude/projects/<project>/memory/`에 있고, 한 저장소의 모든 worktree가 이를 공유한다.
- `/init`은 시작용 `CLAUDE.md`를 생성하고, 이미 있으면 "suggests improvements rather than overwriting it". 다른 도구의 파일도 읽는다. Cursor 규칙, `.github/copilot-instructions.md`, 그리고 `CLAUDE_CODE_NEW_INIT=1`이면 `AGENTS.md`, `.devin/rules/`, `.windsurf/rules/` 또는 `.windsurfrules`, `.clinerules`다. `/import`는 다른 에이전트의 instruction 파일(`AGENTS.md` 포함) 사본을 한 번 붙이고 MCP server, command, subagent, skill을 함께 가져온다.
- `/memory`는 user·project 범위의 memory 파일 위치를 나열하고 auto memory를 토글하며, 로드된 `AGENTS.md`의 경로도 보여준다.
- `/doctor`는 체크인된 `CLAUDE.md`에 대해 줄일 곳을 제안한다. "이 파일이 너무 큰가"에 대한 실무적 답이다.
- `#` 단축키는 더 이상 권장 경로가 아니다: "Claude now automatically saves memories that are relevant to the work and to you." (<https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/>, 2026-07-24 게시, 확인 2026-11-03)

---

## 3. OpenAI Codex

출처: <https://learn.chatgpt.com/docs/agent-configuration/agents-md> (확인 2026-11-03. `developers.openai.com/codex/agent-configuration/agents-md`는 여기로 리다이렉트된다)

### 전역 범위

> "In your Codex home directory (defaults to `~/.codex`, unless you set `CODEX_HOME`), Codex reads `AGENTS.override.md` if it exists. Otherwise, Codex reads `AGENTS.md`. Codex uses only the first non-empty file at this level."

문서화된 용도는 임시 전역 override다: "Use `~/.codex/AGENTS.override.md` when you need a temporary global override without deleting the base file." 에이전트가 저장소 지시와 다르게 행동할 때 가장 먼저 확인할 파일이기도 하다.

### 프로젝트 범위

> "Starting at the project root (typically the Git root), Codex walks down to your current working directory. If Codex cannot find a project root, it only checks the current directory. In each directory along the path, it checks for `AGENTS.override.md`, then `AGENTS.md`, then any fallback names in `project_doc_fallback_filenames`. Codex includes at most one file per directory."

`project_doc_fallback_filenames`는 탐색에 프로젝트 고유 이름을 더한다. 문서 예시는 `["TEAM_GUIDE.md", ".agents.md"]`이고, 목록에 없는 이름은 "are ignored for instruction discovery"다. 디렉터리의 `AGENTS.override.md`는 같은 디렉터리의 `AGENTS.md`를 이기므로, 잘못된 파일을 고치면 변경이 반영되지 않은 것처럼 보인다.

### Merge 순서

> "Codex concatenates files from the root down, joining them with blank lines. Files closer to your current directory override earlier guidance because they appear later in the combined prompt."

여기서 우선순위는 배타적이 아니라 **위치 기반**이다. 나중 텍스트가 나중이라는 이유로 이기며, 이는 하드한 보장이 아니라 소프트한 경향이다.

### 크기 제한

> "Codex skips empty files and stops adding files once the combined size reaches the limit defined by `project_doc_max_bytes` (32 KiB by default)."

이는 실제 실패 모드가 있는 하드 절단이다. 예산이 소진되면 **루트→말단 순서로** 파일이 버려지므로, 비대한 루트 파일이 정작 지금 수정 중인 코드를 관장하는 중첩 파일을 조용히 굶길 수 있다. 루트 파일을 작게 유지해야 하는 가장 강력한 기계적 근거다. Codex의 troubleshooting도 같은 문제로 설명한다: "Raise `project_doc_max_bytes` or split large files across nested directories to keep critical guidance intact."

### 코드 리뷰 관례

Codex는 리뷰 동작을 같은 파일에 적으려는 저장소를 위해 `## Code Review Rules` 섹션 관례를 문서화한다. 리뷰 지침 때문에 별도 포맷을 만들 필요가 없다.

---

## 4. GitHub Copilot

출처: <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions>, <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> (확인 2026-11-03. 옛 `prompting/response-customization` 경로는 첫 URL로 리다이렉트된다)

### 우선순위는 surface에 따라 다르다

검토한 벤더 중 nearest-wins를 문서에 적은 곳은 Copilot뿐이지만, 그 서술에는 범위가 있고 그 범위가 중요하다.

> "Precedence depends on the client and feature. Most surfaces and clients, including Copilot CLI, Visual Studio Code and Visual Studio, combine applicable instruction files without defining a general precedence order."

GitHub.com의 Copilot Chat에서는 순서가 문서화되어 있고, 높은 것부터 이렇다. "Personal instructions", 그다음 repository custom instructions — "Path-specific instructions in any applicable `.github/instructions/**/*.instructions.md` file", 이어서 `.github/copilot-instructions.md` —, 그다음 "Agent instructions, such as instructions in an `AGENTS.md` file", 마지막으로 "Organization custom instructions"다.

즉 `AGENTS.md`는 여전히 저장소 자체 instruction 파일보다 **아래**에 있고, GitHub.com이 아닌 대부분의 클라이언트에서는 순위가 아니라 결합이 일어난다. 그래서 `.github/copilot-instructions.md`와 `AGENTS.md`를 함께 두는 저장소는 어느 한쪽이 이긴다고 가정하지 말고 내용이 충돌하지 않게 유지해야 한다.

### AGENTS.md 처리

> "You can create one or more `AGENTS.md` files, stored anywhere within the repository. When Copilot is working, the nearest `AGENTS.md` file in the directory tree will take precedence."

Copilot은 `CLAUDE.md`와 `GEMINI.md`도 agent instruction 파일로 취급한다.

> "Alternatively, you can use a single `CLAUDE.md` or `GEMINI.md` file stored in the root of the repository."

path-specific 파일과 repository-wide 파일은 대체가 아니라 결합된다:

> "If the path you specify matches a file that Copilot is working on, and a repository-wide custom instructions file also exists, then the instructions from both files are used."

Copilot에는 다른 도구에 없는 기능도 있다. `.github/instructions/*.instructions.md`의 `applyTo:` frontmatter로 glob 범위를 지정하고, 선택적으로 `excludeAgent: "code-review" | "cloud-agent"`를 준다. 이 값을 생략하면 Copilot code review와 cloud agent가 모두 그 파일을 쓴다.

널리 인용되는 "2 pages" 수치는 GitHub의 복사용 작성 프롬프트 안에만 있고 문서화된 한도가 아니다. 제품 규칙이 아니라 프롬프트 템플릿으로 다룬다.

---

## 5. Cursor, Gemini CLI, 새로 합류한 런타임

**Cursor** (<https://cursor.com/en-US/docs/rules>, 확인 2026-11-03)는 `AGENTS.md`를 네 가지 규칙 유형 중 하나로 나열하며 "Agent instructions in markdown format. Simple alternative to `.cursor/rules`"라고 설명한다. 지원 위치는 "in the project root and subdirectories"이고, 중첩 파일은 "Instructions from nested `AGENTS.md` files are combined with parent directories, with more specific instructions taking precedence"로 결합된다. `.cursor/rules/*.mdc`는 여전히 더 풍부한 수단이며, 그 디렉터리에 둔 일반 `.md` 파일은 frontmatter(`description`, `globs`, `alwaysApply`)가 없어 무시된다. Cursor 자신도 일반 Markdown에는 `AGENTS.md`를 쓰라고 안내한다. 규칙 전반의 크기 휴리스틱은 그대로다: "Keep rules under 500 lines."

**Gemini CLI** (<https://geminicli.com/docs/cli/gemini-md/>, 문서 최종 수정 2026-06-18, 확인 2026-11-03)는 `GEMINI.md`를 기본 이름으로 두고, 프로젝트가 `AGENTS.md`를 가리키게 하는 설정으로 `context.fileName`을 둔다. 즉 지원은 자동이 아니라 opt-in이다. 로딩은 nearest-wins가 아니라 층으로 쌓인다. CLI는 "loads various context files from several locations, concatenates the contents of all found files, and sends them to the model with every prompt"이며, 순서는 전역 `~/.gemini/GEMINI.md`, 작업공간 디렉터리와 그 상위, 그리고 도구가 디렉터리에 접근할 때 스캔하는 just-in-time 파일이다. `@file.md` import는 상대·절대 경로를 모두 지원한다.

계획에 참고할 점이 있다. 같은 문서 상단에는 무료 tier와 Google One 사용자에게 Gemini CLI가 "was replaced by Antigravity CLI on June 18th, 2026"라는 안내가 붙어 있다. 사용자가 실제로 어느 CLI를 쓰는지 확인하지 않고 Gemini CLI를 전제로 instruction 전략을 새로 세우지 않는다.

### AGENTS.md를 받아들인 런타임

이 셋은 우선순위 규칙보다, 포맷이 공유 기본값이 되었다는 증거로 중요하다. 정본 `AGENTS.md` 하나를 두는 전략이 성립하는 이유가 여기에 있다.

| 런타임 | 문서화된 동작 |
|---|---|
| **Amp** | 2025년에 `AGENT.md`에서 `AGENTS.md`로 옮기면서 "staying backwards compatible with existing AGENT.md files"를 유지했다. "in the current working directory (or editor workspace roots) and parent directories (up to `$HOME`) are always included"이고, 하위 트리 파일은 "when the agent reads a file in the subtree"에 포함된다. Claude Code와 같은 즉시·지연 분리다 |
| **opencode** | 프로젝트 `AGENTS.md`는 "when you are working in this directory or its sub-directories"에 적용되고, 전역 `~/.config/opencode/AGENTS.md`도 있다. 탐색은 현재 디렉터리에서 위로 올라가며 `AGENTS.md`를 `CLAUDE.md`보다 먼저 읽는다: "The first matching file wins in each category" |
| **Zed** | "Zed supports `AGENTS.md` as the primary instruction file for personal and project-level agent guidance"이며 개인용은 `~/.config/zed/AGENTS.md`다. 프로젝트 파일은 고정 목록에서 첫 일치로 고르고, "Project instructions override personal `AGENTS.md` when they conflict"다 |

opencode 규칙이 중요한 패턴이다. 같은 디렉터리에서 `AGENTS.md`가 `CLAUDE.md`보다 앞서므로, 둘을 함께 두는 저장소는 `CLAUDE.md`를 두 번째 계약이 아니라 순수 포인터로 유지해야 한다.

---

## 6. 포맷과 생태계

표준은 schema를 강제하지 않는다.

> "No. AGENTS.md is just standard Markdown. Use any headings you like; the agent simply parses the text you provide."

관행을 넘어선 지위도 갖는다. 사이트는 "AGENTS.md is now stewarded by the Agentic AI Foundation under the Linux Foundation"라고 밝히며, OpenAI Codex, Amp, Jules, Cursor, Factory의 협업에서 출발했다고 설명한다. 런타임마다 파일을 따로 두지 않고 정본 `AGENTS.md` 하나를 두는 전략의 가장 강한 근거가 이 관리 주체다.

사이트가 이름으로 나열한 지원 도구: Codex, Jules, Factory, Aider, goose, opencode, Zed, Warp, VS Code, Devin, UiPath Autopilot·Coded Agents, Junie, Amp, Cursor, RooCode, Gemini CLI, Kilo Code, Phoenix, Semgrep, GitHub Copilot coding agent, Ona, Windsurf, Augment Code.

작성자에게 그대로 전해야 할 안전 관련 답변이 하나 있다.

> "Will the agent run testing commands found in AGENTS.md automatically? Yes—if you list them. The agent will attempt to execute relevant programmatic checks and fix failures before finishing the task."

`AGENTS.md`에 적은 명령은 의도 설명이 아니라 실행 지시다. 무인 실행을 의도하지 않았다면 파괴적 명령이나 credential을 쓰는 명령을 여기에 두지 않는다.

단수형 legacy 파일명에 대해 문서화된 마이그레이션은 rename과 심볼릭 링크다. `mv AGENT.md AGENTS.md && ln -s AGENTS.md AGENT.md`

파일을 가리켜야 하는 런타임을 위한 도구별 설정도 문서화되어 있다. 예를 들어 Gemini CLI는 `.gemini/settings.json`에서 `context.fileName`을 `AGENTS.md`로 둔다.

검토한 어떤 출처도 `CLAUDE.md` → `AGENTS.md` 일반 마이그레이션 레시피를 문서화하지 않았다. §2의 Claude Code 자체 방법, 즉 네이티브 `AGENTS.md` 읽기, `@AGENTS.md` import, `/import`가 전부다. Claude Code의 `/init`은 반대 방향으로, 다른 도구의 instruction 파일(Cursor 규칙, `.github/copilot-instructions.md`, `CLAUDE_CODE_NEW_INIT=1`이면 `AGENTS.md`, `.devin/rules/`, `.windsurf/rules/` 또는 `.windsurfrules`, `.clinerules`)을 읽어 생성되는 `CLAUDE.md`에 필요한 부분을 접어 넣는다.

---

## 7. 이식성 체크리스트

- [ ] 루트 파일이 Codex의 32 KiB 루트→말단 예산에서 중첩 파일 몫을 남길 만큼 작다.
- [ ] 중첩 파일이 부모 로드 여부와 무관하게 옳은 자기 완결적 delta다.
- [ ] override가 부모를 부정하지 않고 올바른 규칙을 온전히 다시 진술한다.
- [ ] 모든 중첩 파일이 관장하는 하위 트리를 명시한다.
- [ ] Claude Code가 대상이면 저장소가 자체 `AGENTS.md` 읽기(v2.1.277 이상, 작업 디렉터리나 그 위에 `CLAUDE.md`·`CLAUDE.local.md` 없음)에 기대거나, `AGENTS.md`를 import 또는 심볼릭 링크하는 `CLAUDE.md`를 함께 제공한다. `AGENTS.md`를 읽지 못하는 세션(v2.1.277 이전 버전, 내장 리더를 끈 경우, 업그레이드 직후 첫 세션인 경우가 있음)은 `CLAUDE.md`만 읽기 때문이며, 구버전 설치의 해법은 우회책이 아니라 업그레이드다.
- [ ] `AGENTS.md`를 쓰는 저장소에 `CLAUDE.local.md`를 커밋하지 않는다. 기본 설정에서 `AGENTS.md`를 억제하기 때문이다.
- [ ] `@path` import가 4 hop 이내이고, import한 파일 기준 상대 경로를 쓰며, 실수로 따옴표나 코드 span에 싸이지 않았다.
- [ ] 시작 시 로드되는 instruction 파일이 4 MiB에 근접하지 않는다. Claude Code는 그 크기를 넘으면 파일을 통째로 건너뛴다.
- [ ] `.github/copilot-instructions.md`와 `AGENTS.md`가 함께 있으면 내용이 충돌하지 않는다. 순위가 적용되는 surface에서는 Copilot이 전자를 더 높게 매긴다.
- [ ] 저장소 루트나 `~/.codex`에 남은 `AGENTS.override.md`가 고치려던 파일을 조용히 대체하고 있지 않다.
- [ ] 개인 선호 내용은 공유 파일이 아니라 gitignore된 로컬 파일에 있다.

---

## 출처

| 출처 | URL | 확인일 |
|---|---|---|
| AGENTS.md 표준 | <https://agents.md/> | 확인 2026-11-03 |
| Claude Code memory | <https://code.claude.com/docs/en/memory> | 확인 2026-11-03 |
| Claude Code features overview | <https://code.claude.com/docs/en/features-overview> | 확인 2026-11-03 |
| New rules of context engineering (Claude 5) | <https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/> | 확인 2026-11-03 |
| OpenAI Codex AGENTS.md | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | 확인 2026-11-03 |
| GitHub Copilot custom instructions | <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions> | 확인 2026-11-03 |
| GitHub Copilot repository instructions | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 확인 2026-11-03 |
| Cursor rules | <https://cursor.com/en-US/docs/rules> | 확인 2026-11-03 |
| Gemini CLI context files | <https://geminicli.com/docs/cli/gemini-md/> | 확인 2026-11-03 |
| opencode rules | <https://opencode.ai/docs/rules/> | 확인 2026-11-03 |
| Amp AGENTS.md | <https://ampcode.com/docs/customize/agents-md> | 확인 2026-11-03 |
| Amp — From AGENT.md to AGENTS.md (2025-08-20) | <https://ampcode.com/news/AGENTS.md> | 확인 2026-11-03 |
| Zed instructions | <https://zed.dev/docs/ai/instructions> | 확인 2026-11-03 |

## 함께 읽을 문서

- [`../AGENTS_MD.ko.md`](../AGENTS_MD.ko.md)
- [`claude-md-adapter.ko.md`](claude-md-adapter.ko.md)
- [`content-contract.ko.md`](content-contract.ko.md)
- [`../../context-engineering/references/runtime-profiles.ko.md`](../../context-engineering/references/runtime-profiles.ko.md)
