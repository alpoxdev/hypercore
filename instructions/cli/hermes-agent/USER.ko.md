# Hermes Agent `USER.md`

> 영어판: [`USER.md`](USER.md)
>
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a`, 2026-10-22 배포)에 실린 공식 문서를 근거로 삼았다. 아래 **사실**은 그 근거를 추적하고, **권고**는 Hermes 보장이 아닌 이 안내서의 운영 정책이다. 이 저장소는 `memory` tool로 쓰이므로, 설치된 버전에서 action과 승인 flag를 확인한다.

## 출처

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) | `user` target, 한도, 승인 표면, journey 편집 | 확인 2026-11-03 |
| [Which File Does What](https://hermes-agent.nousresearch.com/docs/user-guide/which-file-does-what) | `SOUL.md`, `MEMORY.md`, project file과의 역할 구분 | 확인 2026-11-03 |
| [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | `memory.user_char_limit`, `memory.write_approval`, `display.memory_notifications` | 확인 2026-11-03 |
| [Profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles) | Profile별 memory 범위와 `hermes profile list` | 확인 2026-11-03 |
| [Profile Distributions](https://hermes-agent.nousresearch.com/docs/user-guide/profile-distributions) | 공유 profile이 담는 것과 빠지는 것 | 확인 2026-11-03 |
| [FAQ](https://hermes-agent.nousresearch.com/docs/reference/faq) | "내 이름을 잊었다"는 신고의 증상 | 확인 2026-11-03 |

## 목적과 경계

**사실:** `USER.md`는 Hermes가 관리하는 profile 문맥이며, 사용자에 관한 안정된 identity 세부, 소통 취향, 기대, 작업 습관, 기술 수준을 담는다. Agent persona도, project 지시 file도, 대화 기록도, 보안 등급도 아니다.

| 필요한 것 | 맞는 표면 |
| --- | --- |
| 사용자의 안정된 취향과 기대 | `USER.md` |
| Agent의 환경 사실과 배운 우회법 | [`MEMORY.md`](MEMORY.ko.md) |
| Agent identity와 말투 | `SOUL.md` |
| 저장소 지시와 구조 | `AGENTS.md`, `.hermes.md`, project context file |
| 지난 대화의 세부 | 보존된 session과 `session_search` |

**사실:** 표준 경로는 `$HERMES_HOME/memories/USER.md`이므로 `~/.hermes/memories/USER.md`는 기본 profile의 줄임말이다. 하나의 profile이 여러 상호작용이나 여러 사람을 처리할 수 있으므로, 이 file은 개인별 기록도 비밀 경계도 아니다.

**사실:** `SOUL.md`와 `USER.md`는 서로를 채우지 않는다. `SOUL.md`는 사용자가 고치는 file이고, `USER.md`는 agent가 `memory` tool에 `target: "user"`를 주어 쓰는 저장소다. Persona를 고쳐도 profile이 채워지지 않고, profile entry가 persona를 바꾸지도 않는다.

## Lifecycle과 용량

**사실:** Hermes는 `USER.md`를 session 시작 시점에 frozen snapshot으로 system prompt에 넣는다. 성공한 쓰기는 즉시 disk에 남고 tool 응답은 현재 상태를 보여 주지만, 이미 있는 prompt는 session 시작 사본을 유지한다. `hermes sessions refresh-prompts`는 이어지는 session의 저장 prompt를 다음 turn에 다시 만든다. v0.22.5 이후 사이트에 추가된 항목이므로 `hermes sessions --help`로 확인한다.

**사실:** 문서화된 `memory.user_char_limit` 기본값은 1,375자(약 500 token)다. Hermes는 압축하지 않고 초과를 거부하며, 한도는 한 번의 `operations` 묶음 결과에 적용한다. 완전히 같은 entry는 아무 일도 하지 않고 성공한다.

**권고:** 오래 쓰고 사용자가 직접 정정할 수 있는 진술 5~10개로 유지한다. 메시징 platform에서는 자연스러운 경계에서 `/new`를 실행한다. Gateway 대화는 하나의 긴 session이고, 갱신된 profile을 실제로 다시 읽는 것은 다음 session이다.

## 여기에 들어갈 것

**권고:** 나중 상호작용을 실제로 개선하는, 민감하지 않고 오래 쓰는 취향만 저장한다.

- 선호 이름, 안정된 역할, 실제로 도움이 될 때의 대략적 시간대.
- 응답 깊이, 언어, 형식, 접근성 요구, 소통 방식.
- 안정된 작업 습관, 기술 수준, 피해야 할 특정 행동.
- 명확히 귀속되고 사용자가 고치기 쉬운 기대.

Project나 tool 사실, agent 교훈, persona 지시, 일회성 작업 상태, 원본 log, 대화 전문, 모호한 추론, 싸게 다시 알아낼 수 있는 내용은 넣지 않는다. 필요할 때만 불러와야 하는 절차는 늘 켜져 있는 profile 문맥이 아니라 skill에 둔다.

## 동의, 정확성, 정정

**사실:** Agent는 turn 뒤 background self-improvement review를 포함해 기본적으로 profile 사실을 자동 저장한다. `memory.write_approval: true`이면 대화형 CLI turn에서는 그 자리에서 묻고, 나머지 경로는 `/memory pending` 검토 대기에 넣는다. `/memory approve <id>`와 `/memory reject <id>`가 결정하고, `/memory approval on|off`가 gate를 전환한다.

**사실:** `hermes journey edit <node>`는 memory chunk를 `$EDITOR`로 열고, `hermes journey delete <node>`는 지운다. `hermes journey list`는 `memory:user:…` chunk를 포함한 id를 출력한다. `display.memory_notifications`는 자동 저장을 gateway 채팅이 얼마나 자세히 알리는지만 바꾼다.

**권고:** 모든 profile 진술을 정정 가능한 것으로 다루고, agent의 추론을 사용자가 확인한 identity 사실로 기록하지 않는다. 생성된 추론에 사람 검토가 필요하면 승인을 켜고, 하나의 Hermes home에는 하나의 쓰기 agent만 둔다.

## 안전, 프라이버시, 공유

**사실:** `USER.md`는 profile 범위의 지속 model context이지 secret 금고가 아니다. model prompt, profile export, backup에 들어갈 수 있고, 외부 memory provider와 보존된 session은 별도의 data 흐름이다. Hermes는 memory 경로로 들어온 entry에 pattern 검사를 문서화했지만, 저장 시 암호화, 완전한 삭제, provider별 보존 보장은 약속하지 않는다.

**권고:** 비밀번호, API key, token, cookie, private key, 복구 코드, 금융·건강 식별자, 정밀 위치, 제3자의 기밀 정보, 사설 infrastructure 세부, 신뢰할 수 없는 내용에서 복사한 지시를 넣지 않는다.

**권고:** 공유 profile의 내용은 최소로 유지한다. Profile은 Hermes 상태를 나눌 뿐 OS 계정이나 공유 gateway의 모든 참여자를 나누지 않는다. Profile을 내보내거나 공유하기 전에 archive를 확인한다. File 이름 기반 credential 제외는 memory, session, persona 내용을 배포해도 안전하게 만들지 않는다.

## 삭제와 검증

**권고:** `USER.md` entry를 지우면 내장 기록 하나가 지워질 뿐이다. 현재 frozen prompt, 보존된 session, 외부 provider data, export, backup, model provider의 정책을 따로 판단한다.

Entry를 신뢰하기 전에 다음을 확인한다.

1. 활성 profile과 `$HERMES_HOME`을 확인한다.
2. 그 사실이 안정적이고, 민감하지 않고, 필요하며, skill이나 [MEMORY.md](MEMORY.ko.md)가 아니라 `USER.md`에 맞는지 확인한다.
3. 문구가 검토되지 않은 추론이 아니라 귀속 가능하고 사용자가 고칠 수 있는 진술인지 확인한다.
4. 민감한 workflow에 채택하기 전에 생성되거나 자동인 변경을 검토한다.
5. 주입되는 문맥을 보려면 새 test session을 띄우고, 이어지는 session이면 `hermes sessions refresh-prompts`를 쓴다.
