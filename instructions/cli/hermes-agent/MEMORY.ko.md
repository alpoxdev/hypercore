# Hermes Agent `MEMORY.md`

> 영어판: [`MEMORY.md`](MEMORY.md)
>
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a`, 2026-10-22 배포)에 실린 공식 문서를 근거로 삼았다. 아래 **사실**은 그 근거를 추적하고, **권고**는 Hermes 보장이 아닌 이 안내서의 운영 정책이다. 기억 동작은 `memory` tool 계약에 묶여 있으므로, 자동화 전에 설치된 버전에서 action과 승인 flag를 확인한다.

## 출처

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) | 저장소 한도, frozen snapshot, tool action, `write_approval`, background review, journey | 확인 2026-11-03 |
| [Which File Does What](https://hermes-agent.nousresearch.com/docs/user-guide/which-file-does-what) | `SOUL.md`, `USER.md`, `MEMORY.md`, project file의 소유 구분 | 확인 2026-11-03 |
| [Memory Providers](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory-providers) | 외부 provider, `memory.provider`, 내장 store가 계속 살아 있는 조건 | 확인 2026-11-03 |
| [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | `memory.*`, `display.memory_notifications`, `auxiliary.background_review` 기본값 | 확인 2026-11-03 |
| [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | `hermes memory`, `hermes journey`, `hermes sessions refresh-prompts` | 확인 2026-11-03 |
| [v0.22.5 릴리스](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.5) | 위 동작의 버전 기준점 | 확인 2026-11-03 |

## 목적과 경계

**사실:** `MEMORY.md`는 agent가 관리하는 note 저장소이며, 오래 쓰는 환경 사실, project 관례, 작업 교훈, 재사용 가능한 운영 지식을 담는다. 사용자의 취향 profile도, identity file도, 대화 기록 보관소도 아니다.

| 필요한 것 | 맞는 표면 |
| --- | --- |
| Project 규칙, 명령, 구조 | `AGENTS.md`, `.hermes.md`, 그 밖의 project context file |
| Agent identity와 오래 쓰는 persona | `SOUL.md` |
| 사용자 취향과 소통 기대 | `USER.md` |
| Agent의 운영 note | `MEMORY.md` |
| 필요할 때만 불러올 절차 | skill. memory entry는 2,200자 예산을 나눠 쓴다 |
| 지난 대화의 세부 | 보존된 session과 `session_search`(`state.db` 대상 FTS5) |

**사실:** 표준 위치는 `$HERMES_HOME/memories/MEMORY.md`다. 기본 profile에서는 대개 `~/.hermes/memories/MEMORY.md`가 되지만, 이름 있는 profile은 각자의 `HERMES_HOME`을 쓰므로 기본 경로는 줄임말이지 보편 경로가 아니다.

## Frozen snapshot과 session 경계

**사실:** 두 memory 저장소는 session 시작 시점에 system prompt로 렌더링되고, session이 도는 동안 바뀌지 않는다. Header에 저장소 이름, 사용률, 문자 수가 나오고 entry는 `§`로 구분된다. 승인된 쓰기는 즉시 disk에 남고 tool 응답은 현재 상태를 보여 주지만, 이미 만들어진 prompt는 session 시작 시점의 사본을 유지한다. Hermes는 이를 provider의 prompt cache를 지키기 위한 의도된 동작으로 설명한다.

**사실:** `hermes sessions refresh-prompts`는 이어지는 session이 다음 turn에 현재 `SOUL.md`, skill, context file로 저장된 system prompt를 다시 만들게 한다. 대화 기록과 session id는 유지된다. `--session ID`는 한 session으로 범위를 좁히고, `-p/--profile`은 다른 profile을 지정하며, 새로 고친 session마다 prompt cache miss를 한 번 치른다. 현재 사이트에는 문서화되어 있지만 v0.22.5 tag의 CLI reference에는 없다(v0.22.5 이후). `hermes sessions --help`로 확인한다.

**권고:** 메시징 platform의 대화는 재시작을 견디는 하나의 긴 session이므로 기억은 경계에서만 값을 낸다. 끝난 작업, 화제 전환, 하루의 시작에 `/new`를 실행한다. 그렇지 않으면 학습 loop가 돌 기회를 얻지 못하고 compaction만 점점 길어지는 기록 위에서 반복된다.

## 용량, 초과, 중복

**사실:** 문서화된 기본값은 `MEMORY.md`에 `memory.memory_char_limit: 2200`(약 800 token), `USER.md`에 `memory.user_char_limit: 1375`다. 기억은 자동 압축하지 않는다. 한도를 넘는 쓰기는 초과분, 현재 entry, 확보해야 할 문자 수를 담은 오류로 돌아온다.

**사실:** 한도는 한 번의 `operations` 묶음 결과에 적용된다. 그래서 같은 호출에서 공간을 확보하고 새 entry를 더하는 것이 문서화된 경로다. `patch`도 같은 한도를 받으므로 entry를 늘리는 patch는 여전히 넘칠 수 있다. 완전히 같은 `add`는 "no duplicate added" 메시지와 함께 성공한다.

**권고:** 실용적인 형태는 8~15개의 짧은 entry로 보고, system prompt header가 늘 보여 주는 사용률이 80%를 넘으면 겹치는 사실을 먼저 합친다.

## Tool 계약: `add`, `patch`, `remove`

**사실:** `memory` tool에는 세 action이 있고 읽기 action은 없다. 기억은 이미 prompt에 들어 있기 때문이다.

| Action | 동작 |
| --- | --- |
| `add` | 새 entry를 덧붙인다 |
| `patch` | 기존 entry 안의 한 구간(`old_text`)을 바꾸고 나머지는 남긴다. 그 구간은 해당 entry 안에서 정확히 한 번 나와야 한다 |
| `remove` | 짧고 고유한 `old_text` 부분 문자열로 찾은 entry를 지운다 |

**사실:** `replace`는 더 이상 없다. 일치한 entry 전체를 덮어쓰는 동작이라 model이 찾아 바꾸기로 오용했고, 여러 사실이 든 entry의 나머지를 지웠다. 지금 `replace` 호출은 `patch`를 가리키는 오류를 돌려준다. 이 변경 전에 승인 대기로 들어간 쓰기는 예약된 그대로 적용된다.

**사실:** 모든 호출은 최상위 `target`에 `"memory"` 또는 `"user"`를 담고, 한 묶음은 그 target을 모든 operation에 쓴다. target이 없거나 null이거나, operation 안의 target이 최상위와 다르면 쓰기나 승인 예약 전에 실패한다. entry 전체와 정확히 일치하는 `old_text`는 부분 문자열 일치보다 우선한다.

## 승인과 검토 표면

**사실:** `memory.write_approval` 기본값은 `false`라서 agent는 background self-improvement review가 만든 쓰기를 포함해 자유롭게 저장한다. `true`이면 대화형 CLI의 foreground 쓰기는 그 자리에서 묻고, 그 밖의 모든 경로, 즉 메시징 platform, script, background review는 검토 대기에 넣는다.

```text
/memory pending            # 대기 중인 쓰기, 자동 쓰기는 [auto] 표시
/memory approve <id>       # 또는 'all'
/memory reject <id>        # 또는 'all'
/memory approval on|off    # gate를 켜거나 끄고 저장
```

**사실:** 대기 중인 `patch`나 `remove`는 대상 entry 전체를 고정한다. 승인 전에 그 entry가 바뀌면 쓰기는 거부되고 대기 상태로 남는다. `approve`는 덮어쓰거나 지우는 모든 entry의 전문을 보여 준다.

**사실:** `display.memory_notifications`는 gateway 채팅 줄만 제어한다(`off`, 기본 `on`, `verbose`). review 자체와 store 쓰기는 그 설정과 무관하게 계속된다. review는 `auxiliary.background_review`에서 설정한다. `enabled`, 다른 `provider`/`model`(지정하면 압축 digest 재생으로 바뀐다), `max_input_tokens`, 관리형 local GPU용 `defer`, 좁은 `extra_tools` 허용 목록이 있다. 같은 model을 쓰는 review는 부모의 reasoning effort를 물려받는다. `memory.nudge_interval`과 `skills.creation_nudge_interval`은 nudge 주기를 정한다.

**권고:** 생성된 추론에 사람 검토가 필요하면 쓰기 승인을 켠다. 다만 이를 저장소 백업으로 보지 않는다. 승인은 쓰기를 막을 뿐 보존 기간을 바꾸지 않고, 이미 provider로 나간 session 시작 시점 사본을 되돌리지도 않는다.

## Session 밖에서 entry 고치기

**사실:** `hermes journey`(별칭 `hermes learning`, `hermes memory-graph`)는 Hermes가 배운 것을 보여 준다. `hermes journey list`는 skill 이름과 `memory:<source>:<index>:<fingerprint>` id를 출력하고, `hermes journey edit <node>`는 memory chunk를 `$EDITOR`로 열며, `hermes journey delete <node>`는 memory chunk를 지운다. 같은 하위 명령이 CLI의 `/journey`와 desktop panel에도 있다.

**권고:** 파일을 직접 고치는 대신 `journey edit`를 쓴다. Agent가 이미 아는 id에 기록이 붙은 채로 남고, session이 도는 중에 부분 쓰기가 생길 위험도 없다.

## 안전과 신뢰 경계

**사실:** `MEMORY.md`는 profile 범위의 지속 model context이지 secret 저장소가 아니다. prompt에 들어가므로 원격 model을 쓴다면 그 provider가 내용을 처리한다. 보존된 session, 외부 provider, profile export, backup은 각각 다른 노출 표면이다.

**사실:** memory tool로 들어온 entry는 prompt injection, credential 유출, SSH backdoor, 보이지 않는 Unicode pattern을 검사하고 일치하면 막는다. 이는 방어 계층 하나이며, 직접 파일 편집, import, 복원, provider가 넣은 내용까지 덮지 않는다.

**권고:** credential, token, cookie, private key, 민감한 개인·제3자 정보, 악용 가능한 infrastructure 세부, 검토하지 않은 지시문 원문을 넣지 않는다. 하나의 Hermes home에는 하나의 쓰기 agent만 둔다. 같은 home에 두 process를 붙이면 서로의 entry를 덧쌓으므로, 두 번째 agent에는 별도 profile을 주거나 의도적으로 공유할 때 외부 provider를 쓴다.

## 외부 memory provider

**사실:** `memory.provider`는 외부 provider 하나를 고른다. 묶음 제공인 RetainDB와 ByteRover, 또는 plugin catalog의 Honcho, Hindsight, Supermemory, Mem0, OpenViking, Holographic이 있다. 한 번에 하나만 돌고, 내장 file을 대체하지 않고 나란히 동작한다. `hermes memory setup`, `hermes memory status`, `hermes memory off`로 관리한다.

**사실:** `memory_enabled`와 `user_profile_enabled`를 모두 `false`로 두면 `memory` tool과 그 안내가 prompt에서 빠진다. 외부 provider는 자기 tool을 그대로 유지한다. `agent.disabled_toolsets`에 `memory`를 넣는 쪽이 더 강한 스위치이며 provider tool까지 숨긴다. `memory.prefetch_spill_enabled`는 과대한 provider recall을 머리·꼬리 미리보기로 바꾸는 선택이다.

## 프라이버시와 삭제

**권고:** 삭제는 범위가 정해진 정리로 본다. entry를 지우면 이 저장소는 바뀌지만, 현재 session에 이미 보낸 frozen prompt, session 기록, provider 사본, 외부 provider data, export, backup까지 닿지 않을 수 있다. Profile은 Hermes 상태를 나눌 뿐 OS 계정이나 하나의 gateway 뒤에 있는 사람들을 나누지 않는다.

## 실패 진단

| 증상 | 문서화된 원인 | 조치 |
| --- | --- | --- |
| "기억하라고 했는데" 다음 session이 잊는다 | model이 저장했다고 말했지만 `memory` tool을 부르지 않았다 | file을 확인하고 `memory` tool 저장을 명시적으로 요청한다. 작은 model이나 tool 호출이 약한 model에서 흔하다 |
| 쓰기가 file에 닿지 않는다 | `write_approval: true`가 대기에 넣었다 | `/memory pending` 확인 후 승인한다 |
| 예상과 다른 저장소를 본다 | 기억은 profile 단위다 | `hermes profile list`로 확인하고 process가 어느 profile인지 본다 |
| Tool 자체가 없다 | `memory_enabled: false`와 `user_profile_enabled: false`, 또는 `agent.disabled_toolsets`의 `memory` | 설정을 고친다. tool이 없으면 model은 저장할 수 없다 |
| 도는 session에서 새 사실이 안 보인다 | Frozen snapshot | 새 session을 시작하거나, 이어지는 session이면 `hermes sessions refresh-prompts`를 쓴다 |

## 검증

1. 기억을 고치거나 자동화하기 전에 활성 `HERMES_HOME`과 profile을 확인한다.
2. 각 entry가 `USER.md`, `SOUL.md`, project context, skill이 아니라 여기에 맞는지 확인한다.
3. Secret, 민감 정보, 신뢰할 수 없는 지시, 낡은 사실이 없는지 검토한다.
4. 바뀐 내용이 prompt에 주입된다고 믿기 전에 새 test session을 띄운다.
5. Upgrade 뒤에는 [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) reference를 다시 읽는다. tool action과 승인 flag는 release마다 바뀌었다.
