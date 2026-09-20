# Codex CLI 런타임 프로필

> 영어판: [`README.md`](README.md)

이 문서는 Codex CLI(`codex`)에서 실행되는 스킬의 런타임 프로필이다. 공통 안전·질문·승인 계약은 [capability-contract.ko.md](../capability-contract.ko.md)를 따른다. 이 문서의 명령과 정책은 각 행에 명시한 공식 Codex 문서로 확인했다. 이 프로필이 처음 인용한 로컬 `skills/codex/SKILL.md`는 커밋 `d4f79f9`에서 배포 트리에서 제거되었으므로 더 이상 근거가 아니다.

## 적용 범위와 계약

- Codex CLI가 명시적으로 필요할 때만 이 프로필을 적용한다. 일반 문서 작성이나 직접 로컬 편집의 대체 수단으로 사용하지 않는다.
- 비대화형 실행은 `codex exec`를 사용한다. 최상위 `codex "프롬프트"`는 대화형 TUI이므로 자동화 호출로 간주하지 않는다.
- 분석·리뷰·계획은 `--sandbox read-only`에서 시작한다. 사용자가 워크스페이스 파일 수정을 명시한 경우에만 `--sandbox workspace-write`를 선택한다.
- `codex review`는 읽기 전용 흐름으로 유지하며 writable sandbox 또는 우회 플래그와 결합하지 않는다.
- 외부·파괴적·자격 증명 사용·프로덕션 부작업은 어떤 capability나 CLI 옵션도 승인으로 간주하지 않는다.
- 안전 또는 산출물을 실질적으로 바꾸는 결정/승인이 빠졌을 때만 사용자에게 묻는다. 런타임에 구조화된 질문·승인 capability가 노출된 것을 확인한 뒤에만 그것을 사용한다. 확인할 수 없으면 한 문장의 평문 질문만 하고, 답을 받기 전 게이트된 작업을 멈춘다. 질문 도구가 있다고 추측하거나 결정을 대신 만들지 않는다.

## 공식 문서로 확인된 동작

| 영역 | 확인된 규칙 | 근거 |
|---|---|---|
| 실행 | `codex exec`(단축형 `codex e`)는 프롬프트 없이 끝나는 스크립트·CI 실행의 문서화된 진입점이다. `--json`을 더하면 줄 단위 JSON 이벤트를 받는다 | [Command line options](https://learn.chatgpt.com/docs/developer-commands.md?surface=cli) (확인 2026-09-19) |
| 리뷰 | `codex review`는 비대화형으로 리뷰하며 대상은 `--uncommitted`, `--base`, `--commit`, 사용자 프롬프트 중 정확히 하나다. `--title`은 `--commit`과만 쓴다 | 같은 문서 `codex review` (확인 2026-09-19) |
| 재개·분기 | 비대화형 이어가기는 `codex exec resume` 서브커맨드이며 `--last`는 현재 작업 디렉터리로 범위가 좁혀지고 `--all`이 범위를 넓힌다. `codex resume`은 대화형 세션을 이어가고 `codex fork`는 분기한다 | 같은 문서 `codex exec`, `codex resume` (확인 2026-09-19) |
| 샌드박스 | `--sandbox workspace-write`는 `--ask-for-approval on-request`와 함께 문서화되어 있다. `--sandbox danger-full-access`를 강제하는 대신 `--add-dir`를 선호한다 | 같은 문서, 그리고 [Agent approvals and security](https://learn.chatgpt.com/docs/agent-approvals-security.md) (확인 2026-09-19) |
| 승인 플래그 | `-a`/`--ask-for-approval`은 대화형 클라이언트의 전역 옵션으로 문서화되어 있다 | 같은 문서 전역 옵션 (확인 2026-09-19) |
| 추가 경로·루트 | `--add-dir`는 쓰기 가능한 루트를 더하고, `-C`/`--cd`는 실행 전에 작업 디렉터리를 정한다 | 같은 문서 전역 옵션 (확인 2026-09-19) |

위 표는 벤더 문서를 기록한 것이지 현재 설치된 CLI의 완전한 기능·도구 목록이 아니다. 실제 런타임에서 보이지 않거나 동작이 다르면 `codex --help` 또는 해당 서브커맨드 help로 발견·확인하고, 확인 전에는 지원 사실로 서술하지 않는다.

## 읽기·쓰기·명령 안전

- 읽기: 기본 명령은 `codex exec --sandbox read-only`이며, 리뷰도 읽기 전용으로 제한한다.
- 쓰기: `workspace-write`는 사용자가 Codex의 워크스페이스 수정 의도를 명시한 경우에만 사용한다. 일반 수정에 권한 우회를 쓰지 않는다.
- 명령/권한: 모델·프로필·승인 정책은 사용자가 요구하지 않으면 기본값을 유지한다. `--add-dir`는 필요한 경로에만, `--dangerously-bypass-approvals-and-sandbox`는 사용자 확인과 별도 격리 후에만 사용한다.
- 인증·샌드박스·세션 오류는 원인과 차단 상태를 보고하고, 사용자가 원한 범위 안에서만 재시도한다. 저장소 밖 실행의 `--skip-git-repo-check`도 명시적 승인 없이는 추가하지 않는다.

## 비목표

- Codex의 전체 옵션, 설치 상태, 인증 방식, 모델 목록을 추정하거나 보증하지 않는다.
- 런타임 capability를 권한 상승이나 사용자 승인으로 해석하지 않는다.
- 사용자 요청 없이 세션을 재개·분기하거나 파일을 수정하지 않는다.

## 스킬 내 사용 체크리스트

- [ ] 요청이 Codex CLI 또는 별도 Codex 세션을 명시적으로 요구하는가?
- [ ] 비대화형이면 `codex exec`이고, 분석·리뷰면 `read-only`인가?
- [ ] 쓰기·추가 디렉터리·권한 완화가 사용자 의도와 안전 범위에 맞는가?
- [ ] 결과·경고·부분 출력·인증/세션/sandbox 차단을 함께 보고하는가?
- [ ] 중요한 미결정 사항이 있으면 확인된 구조화 capability만 쓰고, 아니면 평문 한 문장으로 묻고 중단하는가?
