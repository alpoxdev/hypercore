---
name: codex
description: >-
  사용자가 OpenAI Codex CLI(`codex`) 자체를 명시적으로 원할 때 사용.
  격리된 세션 실행, 비대화형 실행, 코드 리뷰(`codex review`), 세션 재개가 대상이며,
  트리거 문구 예시는 "codex 써줘", "codex한테 물어봐", "codex 실행해", "codex exec",
  "codex review", "지난 codex 세션 이어줘", "OpenAI CLI로 이 저장소를 점검하거나 수정해줘"
  등이다.
---

@rules/routing.ko.md

# Codex 스킬

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

## 기본값

| 항목 | 기본값 |
|------|--------|
| 모델 선택 | 사용자가 `-m` / `--model` 을 명시적으로 요구하지 않으면 Codex CLI 기본 모델 사용 |
| 프로필 | 사용자가 `-p` / `--profile` 을 명시적으로 요구하지 않으면 CLI 기본값 사용 |
| 샌드박스 | 분석은 `--sandbox read-only`, 사용자가 편집을 명시했을 때만 `--sandbox workspace-write` |
| 승인 정책 | 대화형 모드 전용 — 사용자가 `-a` / `--ask-for-approval` 을 명시하지 않으면 CLI 기본값 사용 |
| 헤드리스 모드 | `codex exec` |
| 재개 대상 | 비대화형 최근 실행은 `codex exec resume --last`, 대화형 최근 세션은 `codex resume --last` |

사용자가 명시적으로 요청하지 않는 한 모델, 프로필, 승인 정책을 묻지 않는다.

## 라우팅

이 스킬은 실제로 Codex CLI 또는 별도 Codex 세션이 필요한 요청에만 사용한다.

- 요청이 범위를 벗어날 수 있으면 먼저 [rules/routing.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/codex/rules/routing.ko.md)를 읽고 커맨드를 만들지 말지 결정한다.
- `codex` CLI 자체가 필요 없는 일반 문서 작성, 문서 정리, 직접 로컬 편집은 다른 스킬이나 직접 작업으로 전환한다.

## 예시

긍정 트리거:

- "Codex로 이 저장소를 리뷰하고 위험 요소를 요약해줘."
- "`codex exec` 로 이 아키텍처를 분석해줘."
- "지난 Codex 세션 이어서 패치를 마무리하게 해줘."
- "main 기준으로 `codex review` 실행해서 차단 이슈를 알려줘."

부정 트리거:

- "이 런북을 읽기 쉽게 다시 써줘."
- "우리 저장소용 새 스킬을 만들어줘."

경계 사례:

- "Codex 샌드박스 모드를 조사해서 설명해줘."
  사용자가 `codex` CLI 실행까지 원할 때만 이 스킬을 쓰고, 그렇지 않으면 리서치나 직접 문서 작업으로 전환한다.

## 핵심: 비대화형 실행은 `codex exec`

비대화형 Codex 실행에는 항상 `codex exec` 서브커맨드를 사용한다.
서브커맨드 없이 `codex "프롬프트"` 로 부르면 대화형 TUI가 실행된다.

```bash
# 비대화형
codex exec --sandbox read-only "프롬프트"

# 대화형 TUI
codex "프롬프트"
```

`codex exec` 는 인수나 stdin에서 프롬프트를 읽고 실행이 끝나면 stdout에 결과를 출력한다.

## 작업 실행

샌드박스 모드를 바꾸거나, 세션을 재개하거나, 추가 디렉터리를 넣기 전에는 [references/recipes.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/codex/references/recipes.ko.md)를 먼저 읽는다.

### 샌드박스 모드 선택

| 플래그 | 사용 시점 |
|--------|-----------|
| `--sandbox read-only` | 일반 분석/리뷰/계획/구조화 출력처럼 파일 쓰기가 필요 없을 때 |
| `--sandbox workspace-write` | 사용자가 Codex가 워크스페이스 파일을 수정하길 명시적으로 원할 때만 |
| `--sandbox danger-full-access` | 사용자의 명시적 승인 이후, 격리된 환경에서만 |
| `--dangerously-bypass-approvals-and-sandbox` | 사용자의 명시적 승인 이후, 외부에서 별도로 격리된 환경에서만 |

### 승인 정책 선택 (대화형 모드 전용)

`-a` / `--ask-for-approval` 은 최상위 대화형 `codex` 명령에서만 사용할 수 있고, `codex exec` 에는 없다. 비대화형 실행에서는 `--sandbox` 로 안전성을 제어한다.

| 플래그 | 사용 시점 |
|--------|-----------|
| `-a untrusted` | 대화형 전용 — 신뢰되지 않은 명령에 대해 사용자 승인을 매번 요구할 때 |
| `-a on-request` | 대화형 전용 — Codex가 필요하다고 판단할 때만 승인 요청 |
| `-a never` | 대화형 전용 — 승인을 묻지 않음, 반드시 제한적인 `--sandbox` 와 함께만 사용 |

사용자가 명시하지 않으면 `-a` 를 생략하고 CLI 기본값을 따른다.

### 명령 작성 규칙

- 시작점은 `codex exec --sandbox read-only "프롬프트"` 다.
- 사용자가 명시적으로 원할 때만 `-m <model>` 또는 `-p <profile>` 을 추가한다.
- 사용자가 기계가 읽을 출력을 원할 때만 `--json` 을 추가한다.
- 최종 응답이 JSON 스키마를 따라야 할 때만 `--output-schema <FILE>` 을 추가한다.
- 시작 디렉터리 밖의 파일이 필요할 때만 `--add-dir <path>` 를 추가하고, 편집이 명시된 경우에만 쓰기 가능한 샌드박스와 함께 사용한다.
- 사용자가 다른 작업 디렉터리를 명시하면 `-C <dir>` / `--cd <dir>` 로 작업 루트를 지정한다.
- `--dangerously-bypass-approvals-and-sandbox` 는 반드시 먼저 사용자에게 확인한다.
- 일반적인 파일 수정은 권한 우회를 쓰지 말고 `--sandbox workspace-write` 를 우선 사용한다.

### 세션 재개

```bash
codex exec resume --last "이전 작업 계속해줘"
codex exec resume <session-id> "이 후속 요청으로 이어가줘"
codex resume --last       # 최근 대화형 세션 picker
```

비대화형 최근 실행은 `codex exec resume --last` 를 사용한다.
특정 세션을 지정해야 하거나 최근 실행이 맞지 않으면 `codex exec resume <session-id>` 를 사용한다.
재개할 때는 기존 세션 동작을 유지하고, 사용자가 모델, 프로필, 샌드박스, 승인 정책 변경을 명시적으로 요청할 때만 그 설정을 바꾼다.
기존 세션을 덮지 않고 갈라서 이어가고 싶을 때만 `codex fork --last` 를 사용한다.

### 코드 리뷰

```bash
codex review --uncommitted "로컬 변경 사항을 리뷰하고 차단 이슈를 정리해줘."
codex review --base main "이 브랜치를 main 기준으로 리뷰하고 위험 요소를 요약해줘."
codex review --commit <sha> "이 커밋의 변경 사항만 리뷰해줘."
```

`codex review` 는 본래 읽기 전용 흐름이므로 `--sandbox workspace-write` 나 `--dangerously-bypass-approvals-and-sandbox` 와 함께 쓰지 않는다.

### 완료 후

- 결과와 함께 경고나 부분 출력이 있으면 같이 요약한다.
- 사용자가 `codex exec resume --last` 또는 `codex exec resume <session-id>` 로 이어갈 수 있다고 알려준다.
- 계속할지, 프롬프트를 조정할지, 직접 작업으로 돌아갈지 묻는다.

## 비판적으로 사용하기

Codex를 권위자가 아니라 동료로 다룬다.

- 근거가 분명하면 자신의 판단을 유지한다.
- 이견이 생기면 최신 문서나 1차 자료로 검증한다.
- 별도 Codex 세션도 틀리거나 오래된 판단을 할 수 있음을 기억한다.
- 실제로 애매할 때만 사용자에게 결정을 맡긴다.

## 오류 처리

- `command not found: codex`: OpenAI Codex CLI 설치가 필요하다고 안내한다.
- 인증 오류: `codex login` 또는 현재 OpenAI 인증 경로를 점검한다.
- 샌드박스 차단: 사용자가 원할 때만 작업 성격에 맞는 `--sandbox` 로 재시도한다.
- 승인 차단(대화형 `codex` 한정): 사용자가 원할 때만 더 느슨한 `-a` 정책으로 재시도한다.
- 세션을 찾지 못함: `codex exec resume` 을 picker로 띄우거나, 최근 대화형 세션이면 `codex resume --last` 로 전환한다.
- 잘못된 플래그나 모델 오류: `codex --help` 또는 `codex exec --help` 기준으로 지원되는 옵션으로 다시 시도한다.
- Git 저장소 밖에서 실행: 사용자가 저장소 가드 없이 실행해도 된다고 승인한 뒤에만 `--skip-git-repo-check` 를 추가한다.
