---
name: gemini
version: 1.7.0
description: 사용자가 복잡한 추론, 리서치, AI 지원, 또는 이전 Gemini 세션 이어가기를 위해 Google Gemini CLI(`gemini`)를 호출하려 할 때 사용. 트리거 문구 — "gemini 써줘", "gemini한테 물어봐", "gemini 실행해", "gemini 불러줘", "gemini cli", "Google AI", "Gemini 추론", Gemini Plan 모드 검토, Gemini 세션 재개. Gemini CLI가 필요 없는 일반 문서 작성, 런북 정리, 로컬 편집에는 사용하지 않는다.
compatibility: Google Gemini CLI(`gemini`) v0.21.1 이상 필요. v0.40.0 동작 기준. CLI가 설치·인증된 환경에서만 동작.
---

@rules/routing.ko.md

# Gemini: Claude Code용 Google AI 어시스턴트

공식 Google Gemini CLI를 추론, 리서치, Plan 모드 검토, 세션 이어가기 용도로 호출한다. 자동화 호출에는 반드시 `-p` / `--prompt` 를 쓴다 — 위치 인수 프롬프트는 대화형 REPL을 띄운다.

## 라우팅

이 요청이 실제로 Gemini CLI 또는 Gemini 세션을 필요로 할 때만 이 스킬을 사용한다.

- 범위가 애매하면 먼저 [rules/routing.ko.md](rules/routing.ko.md) 를 읽고 명령을 만들지 결정한다.
- 일반 문서 작성, 런북 정리, Gemini 없이 가능한 직접 편집은 다른 스킬이나 직접 작업으로 전환한다.

## 기본값

| 항목 | 기본값 |
|------|--------|
| 모델 선택 | 사용자가 `-m pro/flash/flash-lite/<id>` 를 명시적으로 요청하지 않으면 Gemini CLI 기본(`auto`) 사용 |
| 승인 모드 | `--approval-mode default` (도구 호출마다 승인 요청) |
| 헤드리스 모드 | `-p` / `--prompt` |
| 재개 대상 | `gemini --resume latest` (또는 `gemini -r`) |
| 출력 포맷 | `text` (구조화된 결과가 필요할 때만 `--output-format json`) |

사용자가 명시적으로 요청하지 않는 한 `-m` 을 붙이지 않는다. `auto` 라우팅이 추론에는 Pro, 실행에는 Flash 를 자동 선택한다.

## 핵심: 헤드리스 모드의 `-p`

비대화형 실행에는 항상 `-p` / `--prompt` 를 사용한다. 위치 인수 프롬프트는 대화형 REPL로 들어가서 자동화가 멈춘다.

```bash
# 비대화형 (자동화)
gemini --approval-mode default -p "프롬프트"

# 대화형 (자동화에 사용 금지)
gemini "프롬프트"
```

프롬프트로 시작하고 그 뒤에는 사람이 이어서 대화하고 싶다면 `-i` / `--prompt-interactive` 를 사용한다. `-p` 는 한 번에 끝나는 자동화 전용이다.

## 실행 절차

[references/recipes.ko.md](references/recipes.ko.md) 를 먼저 읽고 승인 모드 변경, 샌드박스 추가, 모델 선택, 세션 재개를 진행한다.

### 승인 모드 선택

| 플래그 | 사용 시점 |
|--------|-----------|
| `--approval-mode default` | 일반 리서치, 추론, 표준 Gemini 사용 |
| `--approval-mode auto_edit` | 사용자가 Gemini가 파일을 수정하길 명시적으로 요청했을 때만 |
| `--approval-mode plan` | 파일 수정 없는 읽기 전용 계획/분석. 쓰기는 plans 디렉터리의 Markdown 으로만 허용 |
| `--approval-mode yolo` | 사용자가 전체 자동 실행을 명시적으로 승인했을 때만. 단독 `--yolo` 플래그는 deprecated 이므로 이 표기를 쓴다. |

### 명령 작성 규칙

- 시작점은 `gemini --approval-mode default -p "프롬프트"` 다.
- 사용자가 특정 모델을 요청한 경우에만 `-m <pro|flash|flash-lite|auto|모델ID>` 를 추가한다.
- 일반 편집은 `--approval-mode auto_edit` 를 사용한다.
- `--approval-mode yolo` 는 사용 전에 반드시 사용자에게 확인한다. 먼저 `--approval-mode auto_edit` 또는 `--sandbox` 를 검토한다.
- 위험도가 높거나 로컬 제약이 더 필요하면 `--sandbox` (`-s`) 를 추가한다.
- 워크스페이스 밖 컨텍스트가 필요하면 `--include-directories /path/a,/path/b` 로 추가 디렉터리를 전달한다.
- 호출자가 결과를 프로그래밍 방식으로 파싱해야 할 때만 `--output-format json` 을 사용한다.

### 세션 재개

```bash
gemini --resume latest -p "후속 프롬프트"
gemini --list-sessions
gemini --delete-session 2
```

`--resume` 은 `latest`, `--list-sessions` 의 인덱스, 또는 세션 UUID 를 받는다. 대화형 세션 안에서는 `/resume` 으로 Session Browser 를 열고 `/rewind` 로 이전 단계로 되돌릴 수 있다.

재개할 때는 기존 세션 동작을 유지하고, 사용자가 요청하지 않으면 모델이나 승인 모드를 바꾸지 않는다.

### 완료 후

- 결과와 함께 경고나 부분 출력이 있으면 같이 요약한다.
- 사용자에게 `gemini --resume latest` (또는 `gemini -r`) 로 다시 이어갈 수 있다고 안내한다.
- 계속할지, 프롬프트를 조정할지, 직접 작업으로 돌아갈지 묻는다.

## 비판적으로 사용하기

Gemini를 **권위자**가 아니라 **동료**로 다룬다.

- 자신 있는 내용은 그대로 유지하고, 틀렸다고 판단되면 바로 반박한다.
- 의견이 갈리면 최신 문서나 현재 소스로 다시 확인한다.
- 최신성이 중요하면 Gemini가 제시한 내용을 1차 자료나 공식 문서로 검증한다.
- 실제로 애매할 때만 사용자에게 판단을 맡긴다.

## 사전 점검 (Preflight)

명령을 만들기 전에 CLI 가 설치되어 PATH 에 있는지 먼저 확인한다.

```bash
command -v gemini >/dev/null 2>&1 || { echo "gemini CLI 가 없습니다"; exit 1; }
```

확인이 실패하면 `gemini ...` 명령을 만들지 말고 아래 **오류 처리** 의 설치 안내로 라우팅한다.

## 오류 처리

- `command not found: gemini`: `npm install -g @google/gemini-cli` (또는 `brew install gemini-cli`) 안내.
- 인증 오류: `gemini` 를 실행해 로그인 플로우를 완료하거나 `GEMINI_API_KEY` 를 설정한다. Vertex AI 는 `GOOGLE_API_KEY` 와 `GOOGLE_GENAI_USE_VERTEXAI=true` 가 필요하다.
- 429 / rate limit: 무료 티어는 분당 60회, Gemini 3 기준 일 1000회 — 잠시 대기하거나 한도를 확인한다.
- 404 / model not found: `-m` 없이 다시 시도하거나 `gemini --help` / 공식 문서의 `pro`/`flash`/`flash-lite` 로 바꾼다.
- 403 / access denied: 현재 인증 경로와 계정 권한을 확인하고 지원되는 모델/설정으로 재시도한다.
- 세션 없음: `gemini --list-sessions` 로 사용 가능한 세션을 확인한다.
- 종료 코드 `42` 는 입력 오류, `53` 은 turn limit 초과.

## 버전 메모

- 기준: Gemini CLI v0.40.0 동작. 최소 지원 v0.21.1 (Gemini 3 라우팅).
- `--yolo` 는 deprecated — 정식 표기는 `--approval-mode yolo` 다.
- Plan 모드는 기본 활성화 — 명시적 사용은 `--approval-mode plan` 또는 세션 안에서 `/plan` 이다.
- 비-TTY 환경에서는 헤드리스 모드가 자동 활성화되며 `-p` 를 주면 항상 헤드리스로 동작한다.
