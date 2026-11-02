# CLI 런타임 프로필

> 영어판: [`README.md`](README.md)

이 디렉터리는 재사용 가능한 skill이 CLI별 기능 차이를 **발견·선택·검증**하도록 돕는 참조 계층이다. 공통 규칙은 [`capability-contract.ko.md`](capability-contract.ko.md)에 한 번만 두고, 변동 가능한 런타임 차이는 하위 프로필에 격리한다.

## 범위와 권한

- 범위: Claude Code, Codex, GJC, Hermes Agent, JCode, OMO, OpenClaw, OpenCode에서 skill이 질문·승인·파일·명령·위임·백그라운드·스케줄 기능을 안전하게 선택하는 방법.
- 비범위: 특정 CLI의 설치, 인증, 모델 선택, 전체 명령 레퍼런스, 프로젝트 규칙의 대체.
- 권한: 사용자 요청과 프로젝트의 `AGENTS.md`가 이 문서와 런타임 출력보다 우선한다. 런타임이 노출한 기능은 **사용 가능성**만 뜻하며 권한이나 승인으로 간주하지 않는다.
- 근거: 각 프로필은 확인에 쓴 1차 문서와 버전 또는 릴리스 기준을 밝힌다. 근거 원장과 날짜, 한계는 [`sources.ko.md`](sources.ko.md)에 있다(확인 2026-11-03). 원장의 어떤 행도 뒷받침하지 않는 기능은 지원 사실로 쓰지 않고 런타임 발견 절차로 처리한다.

## 읽는 순서

1. 모든 skill 작성자는 [`capability-contract.ko.md`](capability-contract.ko.md)를 읽는다.
2. 특정 CLI 동작에 의존할 때만 해당 런타임 프로필을 읽는다.
3. 프로필이 런타임 의존으로 표시한 기능은 현재 세션에서 기능 이름, 입력 스키마, 권한 경계를 확인한다.
4. 확인할 수 없으면 보수적 fallback을 사용하거나, 안전·산출물에 영향을 주는 누락 결정만 한 문장으로 질문한다.

## 프로필

| 런타임 | 프로필 | 근거 기준 | 프로필에 기록된 기능 | 질문·승인 기본값 |
|---|---|---|---|---|
| Claude Code | [`claude-code/README.ko.md`](claude-code/README.ko.md) | 공식 문서, Claude Code 2.1.316(2026-10-31) | 여섯 권한 모드, `-p`/`-c`/`-r`과 출력 형식, 백그라운드 실행을 포함한 subagent(동시 20개·중첩 3계층), 33개 hook, skill, plugin, 동적 workflow, `/loop`·`/schedule`·`/goal` | 노출된 `AskUserQuestion`, 없으면 평문 한 문장 |
| Codex | [`codex/README.ko.md`](codex/README.ko.md) | 공식 문서, Codex CLI 0.166.0(2026-10-29) | `codex exec`·`review`(대상 하나), 샌드박스와 승인 정책, 부모 정책을 상속하는 subagent, TOML 커스텀 agent, `.agents/skills`, 신뢰 검토가 필요한 hook, `/goal`. 예약 작업은 **CLI에서 관리하지 않음** | 평문. 문서화된 구조화 질문 도구가 없음 |
| GJC | [`gjc/README.ko.md`](gjc/README.ko.md) | 1차 문서, 안정 `v0.19.2`(2026-10-29) | 변경 전 계획 승인과 `ask`, 조건부 등록되는 `ask`와 timeout 자동 선택, 권한 우회 플래그 없음 | 등록된 경우 `ask`. timeout으로 자동 선택된 답은 동의가 아님 |
| Hermes Agent | [`hermes-agent/README.ko.md`](hermes-agent/README.ko.md) | `v0.22.5`(`bf0203a794a`, 2026-10-22)에 고정한 1차 문서 | `clarify` 질문 도구, `delegate_task` 위임, `cronjob` 스케줄, `process` 백그라운드 제어, 승인 설정 키, 네 가지 hook 시스템, plugin 신뢰 | 대화형 세션은 `clarify`. 단발(`--oneshot`) 실행에는 `clarify`가 없음 |
| JCode | [`jcode/README.ko.md`](jcode/README.ko.md) | 1차 문서와 SDK, 안정 `v0.99.1`(2026-10-22) | 버전 고정된 config·도구 정책·MCP·세션·swarm·SDK·자동화 경계, allow/allow_always/deny를 담은 SDK `permission_request` | 평문. 런타임 gate는 사용자 승인이 아님 |
| OMO | [`omo/README.ko.md`](omo/README.ko.md) | 1차 문서, `v5.1.58`(2026-11-02) | guard hook으로 집행되는 agent별 `permission` 설정, 지시 파일은 보안 경계가 아님, Orca reporter는 완전한 Dispatch context 안에서만 best-effort 상태 메일 전송 | 평문으로 질문. 복구는 coordinator 소유 |
| OpenClaw | [`openclaw/README.ko.md`](openclaw/README.ko.md) | 1차 문서, `v2026.10.9`(2026-10-29) | 구조화 `ask_user` 도구, `tools.exec.mode`, 정책·allowlist·합의가 모두 필요한 exec 승인, gateway당 하나의 신뢰 경계 | 질문 가능 표면에서는 native `ask_user`, 아니면 평문 |
| OpenCode | [`opencode/README.ko.md`](opencode/README.ko.md) | 공식 문서 `docs`·`v2/docs`(페이지 갱신 2026-11-02) | `question` 권한으로 제어되는 `question` 도구, 마지막 일치 우선 `allow`/`ask`/`deny` 규칙, `subagent_depth`를 가진 primary·subagent, 권한 이벤트를 관찰만 하는 plugin | 노출된 `question`, 없으면 평문 한 문장 |

이 표는 완전한 제품 기능표가 아니다. 기록된 기능은 원장으로 직접 추적되는 최소 집합이며, 프로필이 명시한 전제와 검증을 함께 따른다.

## Skill에 넣는 최소 패턴

```markdown
## 런타임 기능
- 필요한 논리 기능: `read`, `search`, `ask_user`, `edit`
- 함께 쓰는 선택 기능: `delegate`, `background`, `loop`, `schedule`
- 런타임 프로필: `@instructions/cli/<runtime>/README.md`
- 발견 규칙: 실제로 노출된 기능과 입력 스키마를 먼저 확인한다.
- fallback: `ask_user`를 확인할 수 없으면 사용자 언어로 한 문장 질문 후, 답변 전에는 gated 작업을 수행하지 않는다.
- 백그라운드 규칙: 비동기 작업은 런타임이 결과를 확인해 줄 때까지 완료로 보고하지 않는다.
- 승인 경계: 파일 변경, 네트워크, 자격 증명, 외부 시스템 변경, 지속되는 스케줄은 사용자의 명시적 요청과 별도 안전 규칙을 함께 만족해야 한다.
```

`ask_user`는 논리 기능 이름이며, 특정 런타임의 도구/API 이름이 아니다. 세부 계약은 [`capability-contract.ko.md`](capability-contract.ko.md)를 따른다.

## 검증

- [ ] skill이 필요한 **논리 기능**과 fallback을 선언한다.
- [ ] 런타임 고유 기능은 원장으로 뒷받침되는 프로필 항목이나 현재 세션의 발견 결과가 있다.
- [ ] 질문은 결과나 안전을 실질적으로 바꾸는 누락 결정에만 사용한다.
- [ ] 구조화 질문/승인 기능이 없을 때 평문 질문 후 gated 작업을 멈춘다.
- [ ] 백그라운드·루프·스케줄 작업에 종료 조건과 관찰 가능한 결과가 있고, 런타임 확인 전에는 완료로 보고하지 않는다.
- [ ] 외부·파괴적·자격 증명·production 작업은 기능 존재와 별개로 명시적 권한을 확인한다.
