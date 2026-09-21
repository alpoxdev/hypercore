# Skill-Maker를 위한 OpenAI 공식 참조

## Contents

- 갱신 정책
- Codex 에이전트 스킬
- Codex 스킬 발견과 배포
- 스킬 평가
- AGENTS.md 지침
- 프롬프트 엔지니어링
- 평가 모범 사례
- 에이전트 구축의 안전
- Sources

## 갱신 정책

- last_verified_at: 2026-09-20
- refresh_when:
  - Codex 스킬 지침이 실질적으로 바뀔 때
  - Codex 스킬 발견 위치, 목록 예산, `agents/openai.yaml`이 바뀔 때
  - AGENTS.md·사용자 지침 지침이 실질적으로 바뀔 때
  - 스킬 평가 지침이 검증 규칙에 영향을 주는 방식으로 바뀔 때
  - 에이전트 안전 또는 도구 호출 지침이 스킬 안전 게이트에 영향을 주는 방식으로 바뀔 때
- supports_rules:
  - `rules/trigger-design.md`
  - `rules/progressive-disclosure.md`
  - `rules/resource-placement.md`
  - `rules/context-and-harness-alignment.md`
  - `rules/validation-and-iteration.md`

## Codex 에이전트 스킬

- source_url: https://learn.chatgpt.com/docs/build-skills
- last_verified_at: 2026-09-20
- applies_to: 스킬 패키지 형태, `name`·`description`, 자원, 스크립트, 점진적 공개, 목록 예산
- summary: 스킬은 `SKILL.md` 파일에 선택적 스크립트·참조·자산을 더한 디렉터리이며 `name`과
  `description`을 반드시 담아야 합니다. ChatGPT와 Codex는 각 스킬의 이름과 설명에서 시작해 그
  스킬을 쓰기로 결정할 때만 `SKILL.md` 전체를 읽습니다. Codex에서는 최초 목록에 각 스킬의 파일
  경로도 들어가며, 그 목록은 **모델 컨텍스트 창의 최대 2%, 컨텍스트 창을 알 수 없으면 8,000자**를
  씁니다. 스킬이 많으면 Codex는 **먼저 설명을 줄이고**, 스킬 집합이 크면 **일부 스킬을 최초
  목록에서 아예 빼고 경고를 냅니다**. 이 예산은 최초 목록에만 적용되며, 스킬이 선택되면
  `SKILL.md` 전체는 그대로 읽힙니다.
- implication_for_skill_maker: 실패 양상은 설명이 잘리는 것만이 아니라 스킬이 아예 나타나지 않는
  것입니다. 그러므로 핵심 트리거가 설명 맨 앞에 와야 하고 설명은 짧아야 합니다. 이 저장소의 스킬
  38개 설명은 이미 합계 14,641자로 Codex 예산을 넘겼으므로 늘어날수록 더 나빠집니다.

## Codex 스킬 발견과 배포

- source_url: https://learn.chatgpt.com/docs/build-skills
- last_verified_at: 2026-09-20
- applies_to: Codex가 스킬을 찾는 위치, 스킬 비활성화, UI 메타데이터, 호출 정책, 배포
- summary: Codex는 저장소, 사용자, 관리자, 시스템 위치에서 스킬을 읽습니다. 저장소의 경우 현재
  작업 디렉터리에서 저장소 루트까지 올라가며 각 디렉터리의 `.agents/skills`를 훑습니다.
  `$CWD/.agents/skills`, `$CWD/../.agents/skills`, `$REPO_ROOT/.agents/skills`입니다. 사용자
  위치는 `$HOME/.agents/skills`, 관리자 위치는 `/etc/codex/skills`이며 시스템 스킬은 OpenAI가
  함께 제공합니다. **두 스킬이 같은 `name`을 가지면 Codex는 병합하지 않고 둘 다 스킬 선택기에
  나타날 수 있습니다.** Codex는 심볼릭 링크된 스킬 폴더를 지원하며 그 대상을 따라갑니다.
  `~/.codex/config.toml`의 `[[skills.config]]` 항목에 `enabled = false`를 넣고 Codex를 다시
  시작하면 삭제 없이 비활성화합니다. `agents/openai.yaml`은 ChatGPT 데스크톱 앱의 UI 메타데이터를
  설정하고 호출 정책을 정하며 도구 의존성을 선언합니다. `interface` 블록(`display_name`,
  `short_description`, `icon_small`, `icon_large`, `brand_color`, `default_prompt`),
  `allow_implicit_invocation`(기본값 `true`, `false`이면 Codex가 암시적으로 호출하지 않고 명시적
  `$skill` 호출만 동작)을 담은 `policy` 블록, 그리고 `dependencies.tools` 목록입니다. 한 저장소를
  넘어 배포할 때 OpenAI가 제시하는 경로는 스킬 폴더가 아니라 **플러그인**입니다.
  `$skill-installer`는 큐레이션된 스킬을 로컬에 추가하고, `$skill-creator`는 새 스킬 생성을
  안내하며, Record & Replay는 시연한 워크플로에서 재사용 스킬 초안을 만듭니다.
- implication_for_skill_maker: "재사용 가능한 Codex 스킬 폴더"는 이야기의 절반입니다. 발견 위치를
  밝히고, `.agents/skills` 관례가 Codex 전용이 아니라 다른 런타임과 공유된다는 점을 적고, 배포
  경로로 플러그인을 다룹니다. `allow_implicit_invocation: false`는 스킬을 명시적 호출로 제한하는
  Codex 쪽 대응물입니다.

## 스킬 평가

- source_url: https://developers.openai.com/blog/eval-skills
- last_verified_at: 2026-09-20
- applies_to: 트리거 테스트, 과정 점검, 출력 형식 점검, 결정적 채점기, 프롬프트 집합 크기
- summary: 스킬 품질은 작은 프롬프트 집합과 관찰 가능한 점검으로 네 축에서 평가해야 합니다.
  **결과(작업 완료), 과정(올바른 호출과 절차), 형식(관례와 출력 형식 준수), 효율(불필요한 명령이나
  토큰 없이 끝내기)** 입니다. 명시적·암시적·맥락적·부정 통제 호출을 아우르는 10-20개 프롬프트로
  시작해 실제 실패에서 늘려가라고 권합니다. 수동 트리거가 숨은 가정을 드러내는 첫 단계이고,
  `codex exec`는 실행을 반복 가능하게 만들며 진행은 stderr로 흘리고 최종 결과만 stdout에 씁니다.
- implication_for_skill_maker: 네 축과 호출 방식 구분이 핵심이며, 케이스 개수는 검증된 최적값이
  아니라 시작 권장값으로 유지합니다.

## AGENTS.md 지침

- source_url: https://learn.chatgpt.com/docs/agent-configuration/agents-md
- last_verified_at: 2026-06-02
- recheck_status: 2026-09-20 점검에서 다시 읽지 않았습니다. 위 날짜는 마지막으로 실제 읽은 날짜입니다
- applies_to: 프로젝트 지침 발견, 범위, 우선순위, 로컬 지침 계층
- summary: 저장소 지침은 에이전트에 범위가 정해진 지침을 제공하며 프로젝트 안에서 작업할 때 고려해야 합니다.
- implication_for_skill_maker: 로컬 `instructions/`와 프로젝트 규칙이 일반적인 제공자 예시보다 우선합니다.

## 프롬프트 엔지니어링

- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-06-02
- recheck_status: 2026-09-20 점검에서 다시 읽지 않았습니다. 위 날짜는 마지막으로 실제 읽은 날짜입니다
- applies_to: 명확한 지침, 예시, 구조화된 컨텍스트, 명시적 출력 형식
- summary: 명확한 지침과 예시, 명시적 형식이 따르기 쉬움을 높입니다.
- implication_for_skill_maker: 핵심 스킬 지침은 명시적이고 예시로 뒷받침되며 계약 형태여야 합니다.

## 평가 모범 사례

- source_url: https://developers.openai.com/api/docs/guides/evaluation-best-practices
- last_verified_at: 2026-06-02
- recheck_status: 2026-09-20 점검에서 다시 읽지 않았습니다. 위 날짜는 마지막으로 실제 읽은 날짜입니다
- applies_to: AI 시스템 변동성, 평가 기반 반복
- summary: 모델 동작은 변하므로 프로덕션에 닿는 동작에는 직관이 아니라 평가가 필요합니다.
- implication_for_skill_maker: 중요한 스킬 변경에는 최소한 작은 평가나 스모크 집합이 있어야 합니다.

## 에이전트 구축의 안전

- source_url: https://developers.openai.com/api/docs/guides/agent-builder-safety
- last_verified_at: 2026-06-02
- recheck_status: 2026-09-20 점검에서 다시 읽지 않았습니다. 위 날짜는 마지막으로 실제 읽은 날짜입니다
- applies_to: 프롬프트 주입, 도구 호출, MCP·도구 안전, 부작용 게이트
- summary: 에이전트 시스템에는 신뢰할 수 없는 입력, 도구, 권한, 부작용에 대한 보호 장치가 필요합니다.
- implication_for_skill_maker: 네트워크, 자격 증명, 파괴적 동작, 프로덕션 부작용을 언급하는 스킬은 그 동작을 명시적으로 게이트해야 합니다.

## Sources

> 링크 확인 2026-09-20. 다음 재검증: 2026-10-29, `instructions/README.md`의 주기와 맞춥니다.

| 주장 | 출처 | 2026-09-20 점검에서 읽음 |
|---|---|---|
| 스킬 패키지 형태, 필수 `name`·`description`, 점진적 로딩, 2%·8,000자 목록 예산, 먼저 줄이고 이후 생략, 네 가지 호출·평가 축 | <https://learn.chatgpt.com/docs/build-skills> | 예 |
| 여섯 발견 위치, 같은 `name` 비병합, 심볼릭 링크 스킬 폴더, `[[skills.config]]`, `allow_implicit_invocation`을 포함한 `agents/openai.yaml`, 배포 경로로서의 플러그인, `$skill-installer`, `$skill-creator`, Record & Replay | <https://learn.chatgpt.com/docs/build-skills> | 예 |
| 네 가지 평가 축, 10-20개 프롬프트 시작 집합, 수동 트리거 우선, 반복 실행을 위한 `codex exec` | <https://developers.openai.com/blog/eval-skills> | 예 |
| AGENTS.md 발견과 우선순위 | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | 아니오 |
| 명확한 지침, 예시, 명시적 출력 형식 | <https://developers.openai.com/api/docs/guides/prompt-engineering> | 아니오 |
| 모델 변동성과 평가 기반 반복 | <https://developers.openai.com/api/docs/guides/evaluation-best-practices> | 아니오 |
| 프롬프트 주입, 도구 호출, 부작용 보호 장치 | <https://developers.openai.com/api/docs/guides/agent-builder-safety> | 아니오 |

### 증거 등급

`VENDOR`입니다. OpenAI가 자기 제품에 대해 한 서술입니다. 자사 로딩 역학(발견 위치, 크기 한도, 호출
정책)에 대한 벤더 서술은 그 제품에 관한 사실이고, 같은 벤더가 무엇이 좋은 스킬인지에 대해 한
서술은 휴리스틱입니다. 위 표의 네 행은 2026-06-02 점검에서 읽은 그대로 이월했으며, 날짜를 새로
찍지 않고 그 사실을 표시했습니다.
