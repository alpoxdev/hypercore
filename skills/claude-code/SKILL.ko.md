---
name: claude-code
description: >-
  사용자가 Anthropic Claude Code CLI(`claude`) 자체를 명시적으로 원할 때 사용.
  격리된 세션 실행, 비대화형 실행, 세션 재개가 대상이며, 트리거 문구 예시는
  "claude code 써줘", "claude한테 물어봐", "claude 실행해", "지난 claude 세션 이어줘",
  "Anthropic CLI로 이 저장소를 점검하거나 수정해줘" 등이다.
---

@rules/routing.ko.md

# Claude Code 스킬

## 기본값

| 항목 | 기본값 |
|------|--------|
| 모델 선택 | 사용자가 `--model` 을 명시적으로 요구하지 않으면 Claude Code CLI 기본 모델 사용 |
| 추론 강도 | 사용자가 `--effort` 를 명시적으로 요구하지 않으면 CLI 기본값 사용 |
| 권한 모드 | `--permission-mode default` |
| 헤드리스 모드 | `-p` / `--print` |
| 재개 대상 | 현재 디렉터리 최근 세션은 `claude --continue`, 특정 세션은 `claude --resume` |

사용자가 명시적으로 요청하지 않는 한 모델이나 `--effort` 를 묻지 않는다.

## 라우팅

이 스킬은 실제로 Claude Code CLI 또는 별도 Claude Code 세션이 필요한 요청에만 사용한다.

- 요청이 범위를 벗어날 수 있으면 먼저 [rules/routing.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/claude-code/rules/routing.ko.md)를 읽고 커맨드를 만들지 말지 결정한다.
- `claude` CLI 자체가 필요 없는 일반 문서 작성, 문서 정리, 직접 로컬 편집은 다른 스킬이나 직접 작업으로 전환한다.

## 예시

긍정 트리거:

- "Claude Code로 이 저장소를 리뷰하고 위험 요소를 요약해줘."
- "`claude` print 모드로 실행해서 이 아키텍처를 분석해줘."
- "지난 Claude Code 세션 이어서 패치를 마무리하게 해줘."

부정 트리거:

- "이 런북을 읽기 쉽게 다시 써줘."
- "우리 저장소용 새 스킬을 만들어줘."

경계 사례:

- "Claude Code 권한 모드를 조사해서 설명해줘."
  사용자가 `claude` CLI 실행까지 원할 때만 이 스킬을 쓰고, 그렇지 않으면 리서치나 직접 문서 작업으로 전환한다.

## 핵심: 비대화형 실행은 `-p`

비대화형 Claude Code 실행에는 항상 `-p` / `--print` 를 사용한다.
위치 인수 프롬프트는 대화형 REPL을 시작한다.

```bash
# 비대화형
claude --permission-mode default -p "프롬프트"

# 대화형 REPL
claude "프롬프트"
```

`-p` 는 workspace trust 대화상자를 건너뛰므로, 신뢰하는 디렉터리에서만 사용한다.

## 작업 실행

권한 모드를 바꾸거나, 세션을 재개하거나, 추가 디렉터리를 넣기 전에는 [references/recipes.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/claude-code/references/recipes.ko.md)를 먼저 읽는다.

### 권한 모드 선택

| 플래그 | 사용 시점 |
|--------|-----------|
| `--permission-mode default` | 일반적인 Claude Code 사용, 기본 승인 프롬프트 유지 |
| `--permission-mode acceptEdits` | 사용자가 Claude Code가 파일을 수정하길 명시적으로 원할 때만 |
| `--permission-mode plan` | 파일 변경이나 셸 실행 없는 읽기 전용 분석/계획 |
| `--dangerously-skip-permissions` | 사용자의 명시적 승인 이후, 격리된 환경에서만 |

### 명령 작성 규칙

- 시작점은 `claude --permission-mode default -p "프롬프트"` 다.
- 사용자가 명시적으로 원할 때만 `--model <model>` 또는 `--effort <level>` 을 추가한다.
- 사용자가 기계가 읽을 구조화 출력이 필요하다고 할 때만 `--output-format json` 을 추가한다.
- 시작 디렉터리 밖의 파일이 필요할 때만 `--add-dir <path>` 를 추가한다.
- `--dangerously-skip-permissions` 는 반드시 먼저 확인한다.
- 일반적인 파일 수정은 권한 우회를 쓰지 말고 `--permission-mode acceptEdits` 를 우선 사용한다.

### 세션 재개

```bash
claude --continue -p "이전 작업 계속해줘"
claude --resume <session-id> -p "이 후속 요청으로 이어가줘"
```

현재 디렉터리의 최근 대화는 `--continue` 를 사용한다.
특정 세션을 지정해야 하거나 현재 디렉터리 세션이 맞지 않으면 `--resume` 을 사용한다.
재개할 때는 기존 세션 동작을 유지하고, 사용자가 모델, `--effort`, 권한 모드 변경을 명시적으로 요청할 때만 그 설정을 바꾼다.
기존 세션을 덮지 않고 갈라서 이어가고 싶을 때만 `--fork-session` 을 추가한다.

### 완료 후

- 결과와 함께 경고나 부분 출력이 있으면 같이 요약한다.
- 사용자가 `claude --continue` 또는 `claude --resume <session-id>` 로 이어갈 수 있다고 알려준다.
- 계속할지, 프롬프트를 조정할지, 직접 작업으로 돌아갈지 묻는다.

## 비판적으로 사용하기

Claude Code를 권위자가 아니라 동료로 다룬다.

- 근거가 분명하면 자신의 판단을 유지한다.
- 이견이 생기면 최신 문서나 1차 자료로 검증한다.
- 별도 Claude Code 세션도 틀리거나 오래된 판단을 할 수 있음을 기억한다.
- 실제로 애매할 때만 사용자에게 결정을 맡긴다.

## 오류 처리

- `command not found: claude`: Claude Code CLI 설치가 필요하다고 안내한다.
- 인증 오류: `claude auth` 또는 현재 Anthropic 인증 경로를 점검한다.
- 권한 차단: 작업 성격에 맞는 `--permission-mode` 로 재시도하거나, 사용자가 원할 때만 허용/차단 도구 설정을 조정한다.
- 세션을 찾지 못함: 세션 선택용 `claude --resume` 을 쓰거나, 현재 디렉터리 최근 세션이면 `claude --continue` 로 전환한다.
- 잘못된 플래그나 모델 오류: `claude --help` 기준으로 지원되는 옵션으로 다시 시도한다.
