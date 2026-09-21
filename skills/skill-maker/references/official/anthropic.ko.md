# Skill-Maker를 위한 Anthropic 공식 참조

## Contents

- 갱신 정책
- Claude Code 스킬
- 스킬 제작 모범 사례
- 엔터프라이즈용 스킬
- Agent Skills 엔지니어링 글
- Claude Skills 제품 글
- Sources

## 갱신 정책

- last_verified_at: 2026-09-20
- refresh_when:
  - Claude Code 또는 Agent Skills 지침이 실질적으로 바뀔 때
  - frontmatter 필드 표, 목록 예산, 표준·확장 구분이 바뀔 때
  - 스킬 구조, 점진적 공개, 스크립트, 검증 지침이 바뀔 때
  - 핵심 skill-maker 규칙이 Anthropic 동작을 더 직접 인용할 때
- supports_rules:
  - `rules/skill-anatomy.md`
  - `rules/trigger-design.md`
  - `rules/progressive-disclosure.md`
  - `rules/resource-placement.md`
  - `rules/validation-and-iteration.md`

## Claude Code 스킬

- source_url: https://code.claude.com/docs/en/skills
- last_verified_at: 2026-09-20
- applies_to: `SKILL.md`, frontmatter 전체 표면, 지원 파일, 호출 제어, 동적 컨텍스트 주입, 문자열 치환, 목록 예산, 발견 위치
- summary: Claude Code 스킬은 Agent Skills 공개 표준을 따르고 그것을 확장합니다. **Claude Code는 여는
  `---`가 파일의 첫 줄일 때만 frontmatter를 읽습니다.** 그렇지 않으면 `---` 표시를 포함한 파일 전체를
  스킬 내용으로 취급합니다. 문서는 frontmatter 필드 스무 개를 제시하며, 그중 표준에 속하는 것은
  `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` 여섯뿐입니다. 나머지
  열넷은 Claude Code 확장입니다. claude.ai 업로드, Skills API, `package_skill.py` 배포 경로에서는
  명세가 허용하지 않는 필드가 조용히 무시되지 않고 **하드 오류**가 되며, 동적 컨텍스트 주입 같은
  Claude Code 전용 본문 기능은 그곳에서 동작하지 않습니다. 스킬은 엔터프라이즈, 개인, 프로젝트,
  중첩, `--add-dir`, 플러그인, claude.ai 계정 위치에서 로드됩니다. 프로젝트 스킬은 시작 디렉터리와
  저장소 루트까지의 모든 상위 디렉터리에 있는 `.claude/skills/`에서 오고, 시작 디렉터리 아래의 중첩
  `.claude/skills/`는 Claude가 그 하위 디렉터리의 파일을 처음 읽거나 편집할 때 로드됩니다. `synced`는
  대소문자와 무관하게 예약된 스킬 폴더 이름이며 그 이름으로 만든 스킬은 건너뜁니다. 스킬 폴더에
  `.claude-plugin/plugin.json`을 더하면 플러그인이 됩니다.
- implication_for_skill_maker: 규칙 문구에서 표준 여섯 필드와 확장 열넷을 구분해야 합니다. 둘을
  섞은 스킬은 Claude Code에서만 이식 가능합니다. 첫 줄 규칙은 이미 두 저장소 게이트가 강제하므로
  새 도구가 아니라 서술이 필요합니다.

### 문서가 제시하는 frontmatter 필드

표준 필드(이식 가능): `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`.

Claude Code 확장: `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`,
`user-invocable`, `disallowed-tools`, `model`, `effort`, `context`, `agent`, `background`, `hooks`,
`paths`, `shell`.

| 필드 | 규칙으로 가져갈 동작 |
|---|---|
| `description` | `when_to_use`와 합쳐 스킬 목록에서 **1,536자**에서 잘립니다. 핵심 용도를 앞에 둡니다 |
| `when_to_use` | 추가 트리거 맥락으로, `description` 뒤에 붙고 같은 1,536자 한도에 포함됩니다 |
| `disable-model-invocation` | `true`이면 Claude가 스킬을 자동으로 로드하지 않아 명시적 호출만 동작합니다. Codex의 `allow_implicit_invocation: false`에 대응합니다 |
| `user-invocable` | `false`이면 `/` 메뉴에서 숨겨져 Claude만 호출합니다 |
| `allowed-tools` | 스킬을 호출한 **턴 동안 Claude가 승인 없이 쓸 수 있는** 도구입니다. 다음 메시지에서 권한이 해제됩니다. 제한적 경계가 아니라 허용적 부여입니다 |
| `disallowed-tools` | 스킬이 활성인 동안 도구 풀에서 제거됩니다. 다음 메시지에서 해제됩니다 |
| `context` | `fork`로 두면 분기된 서브에이전트 컨텍스트에서 실행되며, `agent`가 서브에이전트 유형을, `background`가 턴의 대기 여부를 정합니다 |
| `paths` | 자동 활성화를 일치하는 파일로 제한하는 글롭 패턴입니다 |
| `shell` | 인라인 셸 블록에 쓸 셸입니다. 기본은 `bash`입니다 |
| `hooks` | 스킬 호출 시 등록되어 세션 동안 유지되는 훅입니다 |

### 본문 기능

- **동적 컨텍스트 주입**: `` !`command` ``는 명령을 실행하고 Claude가 스킬 내용을 보기 전에 그 줄을
  출력으로 바꿉니다. Claude Code 전용이며 claude.ai나 API 경로에서는 동작하지 않습니다.
- **문자열 치환**: `$ARGUMENTS`, `$ARGUMENTS[N]`·`$N`, `arguments` 목록의 이름 있는 `$name`,
  `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, 그리고
  플러그인 스킬에서는 `${CLAUDE_PLUGIN_ROOT}`와 `${CLAUDE_PLUGIN_DATA}`입니다.
- `${CLAUDE_SKILL_DIR}`과 `${CLAUDE_PROJECT_DIR}`는 스킬의 마크다운 내용과 `allowed-tools`의 Bash
  규칙 두 곳에서 치환됩니다. 같은 변수를 두 곳에 쓰면 스킬이 함께 넣은 스크립트를 권한 프롬프트 없이
  실행할 수 있습니다. 스크립트를 함께 배포할 때의 문서화된 패턴입니다.

### 목록 예산

- Claude Code는 스킬 이름과 설명의 목록을 컨텍스트에 로드합니다. **목록에는 항상 모든 스킬 이름이
  들어가지만 넘치면 Claude Code가 설명을 줄이며, 가장 적게 호출한 스킬부터 시작합니다.** 예산은
  **모델 컨텍스트 창의 1%**로 정해지고, 각 항목의 `description` + `when_to_use` 합친 텍스트는 예산과
  무관하게 1,536자에서 잘립니다. `skillListingBudgetFraction`, `SLASH_COMMAND_TOOL_CHAR_BUDGET`,
  `skillListingMaxDescChars`가 예산을 바꾸고 `/doctor`가 목록 비용을 추정합니다.
- implication_for_skill_maker: Codex의 2%·8,000자보다 더 빠듯한 두 번째 예산이며, 위치가 아니라 사용
  빈도로 잘립니다. 드물게 호출되는 스킬이 설명을 가장 먼저 잃으므로 핵심 트리거가 앞에 와야 합니다.

## 스킬 제작 모범 사례

- source_url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- last_verified_at: 2026-09-20
- applies_to: Claude가 더하는 frontmatter 제약, 작명, 설명의 인칭, 점진적 공개 패턴, 참조 파일 구조, 모델 커버리지, 자유도
- summary: Claude는 표준 위에 제약을 더합니다. `name`은 XML 태그를 담을 수 없고 예약어 **"anthropic"**과
  **"claude"**를 담을 수 없으며, `description`은 XML 태그를 담을 수 없습니다. 설명은 **3인칭**으로
  써야 합니다. 이 필드가 시스템 프롬프트에 주입되므로 인칭이 일관되지 않으면 발견에 문제가 생깁니다.
  동명사형 이름(동사 + `-ing`)이 권장 관례이고, 명사구와 동작 지향 이름도 허용되며 `helper`나 `utils`
  같은 모호한 이름은 피합니다. `SKILL.md`는 500줄 미만으로 유지합니다. 참조는 **한 단계 깊이**로
  유지합니다. Claude는 다른 참조에서 참조된 파일을 부분적으로 읽고 `head -100`으로 미리보기할 수
  있어 전체를 읽지 않을 수 있기 때문입니다. **100줄을 넘는 참조 파일에는 맨 위에 목차를 넣어**
  부분 읽기에서도 전체 범위가 보이게 합니다. 계획한 모든 모델에서 스킬을 시험합니다. "Opus에서
  완벽하게 동작하는 것이 Haiku에는 더 자세한 설명이 필요할 수 있습니다". 구체성은 깨지기 쉬움에
  맞춥니다. 여러 접근이 유효하면 높은 자유도(텍스트 지침), 선호 패턴이 있으면 중간 자유도(매개변수
  있는 스크립트), 동작이 깨지기 쉽고 일관성이 중요하면 낮은 자유도(매개변수 없는 정확한 스크립트)입니다.
- implication_for_skill_maker: 3인칭 규칙, 예약어·XML 태그 제약, 동명사 관례, 100줄 초과 목차
  규칙은 모두 검사 가능하므로 규칙 문구에 들어가야 합니다. 500줄은 명세와 일치합니다.

## 엔터프라이즈용 스킬

- source_url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise
- last_verified_at: 2026-09-20
- applies_to: 스킬 심사, 위험 등급표, 공존을 포함한 평가 차원, 버전 고정
- summary: 스킬 심사는 "스킬이 일반적으로 안전한가"와 "이 스킬이 안전한가" 두 질문에 답하는 일입니다.
  위험 등급표는 우려 수준과 함께 일곱 지표를 제시합니다. **코드 실행**(스킬 디렉터리의 스크립트가
  환경 전체 접근으로 실행됨, 높음), **지침 조작**(안전 규칙을 무시하거나 동작을 숨기거나 조건부로
  바꾸라는 지시, 높음), **MCP 서버 참조**(높음), **네트워크 접근 패턴**(높음), **하드코딩된 자격
  증명**(높음), **파일시스템 접근 범위**(중간), **도구 호출**(중간)입니다. 검토 체크리스트는 샌드박스
  에서 스크립트 동작이 명시된 목적과 맞는지 확인하고, 적대적 지시를 찾고, 리다이렉트 대상을 확인하고,
  데이터 유출 패턴이 없는지 확인하는 항목을 더합니다. 배포 전에 다섯 차원의 평가가 요구되며, 그중
  하나가 **공존입니다. 이 스킬을 더하면 다른 스킬이 나빠지는가?** 실패 사례로 "새 스킬의 설명이 너무
  넓어 기존 스킬의 트리거를 가로챕니다"를 듭니다. 평가 묶음은 트리거해야 하는 경우, 트리거하지 말아야
  하는 경우, 모호한 경우를 아우르는 대표 질의 3-5개를 담고 조직이 쓰는 모델 전반에서 시험해야 합니다.
  스킬 설치는 프로덕션 시스템에 소프트웨어를 설치하는 것과 같은 엄격함으로 다루고, 스킬은 버전에
  고정해 바뀌면 다시 검토해야 합니다.
- implication_for_skill_maker: 산출물 감사는 위험 행 일곱 개를 모두 담아야 하며 일부만 담아서는 안
  되고, 공존은 부차적 항목이 아니라 평가 차원이어야 합니다.

## Agent Skills 엔지니어링 글

- source_url: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- last_verified_at: 2026-06-02
- recheck_status: 2026-09-20 점검에서 다시 읽지 않았습니다. 위 날짜는 마지막으로 실제 읽은 날짜입니다
- applies_to: 스킬 구조, 점진적 공개, 스크립트, 평가 우선 반복, 신뢰 경계
- summary: Agent Skills는 지침, 스크립트, 자원의 폴더이며 메타데이터에서 전체 지침으로, 다시 참조 파일과 실행 도우미로 점진적으로 로드됩니다.
- implication_for_skill_maker: 점진적 공개, 목적이 분명한 스크립트, 출처·자원 신뢰 점검이 일급 규칙입니다.

## Claude Skills 제품 글

- source_url: https://claude.com/blog/skills
- last_verified_at: 2026-06-02
- recheck_status: 2026-09-20 점검에서 다시 읽지 않았습니다. 위 날짜는 마지막으로 실제 읽은 날짜입니다
- applies_to: 이식성, 조합성, 재사용 역량으로서의 스크립트·자원
- summary: 스킬은 지침, 스크립트, 자원을 담은 폴더이며 전문 워크플로를 이식 가능하고 조합 가능하게 만듭니다.
- implication_for_skill_maker: 스킬은 일회성 프롬프트가 아니라 재사용 패키지로 유지해야 합니다.

## Sources

> 링크 확인 2026-09-20. 다음 재검증: 2026-10-29, `instructions/README.md`의 주기와 맞춥니다.

| 주장 | 출처 | 2026-09-20 점검에서 읽음 |
|---|---|---|
| 스무 개 frontmatter 필드 표, 표준 여섯 필드, claude.ai·API 경로에서 비표준 필드의 하드 오류, 첫 줄 규칙, 발견 위치, 예약된 `synced` 이름, `context: fork`, 동적 컨텍스트 주입, 문자열 치환, `allowed-tools`의 `${CLAUDE_SKILL_DIR}` 패턴, 적게 호출한 순서로 잘리는 1%·1,536자 목록 예산 | <https://code.claude.com/docs/en/skills> | 예 |
| `name`의 XML 태그·예약어 제약, `description`의 XML 태그 제약, 3인칭 설명, 동명사 관례, 한 단계 깊이 참조와 부분 읽기 이유, 100줄 초과 목차 규칙, 모델 커버리지 시험, 세 단계 자유도 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> | 예 |
| 필수 frontmatter 두 필드와 Claude 고유 제약, 토큰 비용이 있는 세 단계 로딩 모델 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> | 예 |
| 우려 수준이 있는 위험 등급 일곱 행, 검토 체크리스트, 공존을 포함한 다섯 평가 차원, 3-5개 질의 묶음, 버전 고정 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> | 예 |
| 스킬 구조, 점진적 공개, 스크립트, 신뢰 경계 | <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills> | 아니오 |
| 이식성, 조합성, 재사용 패키지로서의 스킬 | <https://claude.com/blog/skills> | 아니오 |

### 증거 등급

`VENDOR`입니다. Anthropic이 자기 제품에 대해 한 서술입니다. 위 표의 두 행은 2026-06-02 점검에서 읽은
그대로 이월했으며 날짜를 새로 찍지 않고 그 사실을 표시했습니다. 엔터프라이즈 문서의 심각도 표시는
그 문서의 부여이며 통제된 연구의 결과가 아니므로, 그것에 대한 감사는 알려진 산출물 수준 문제를
걸러내는 체크리스트이지 안전의 증명이 아닙니다.
