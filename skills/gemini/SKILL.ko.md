---
name: gemini
version: 1.6.0
description: 사용자가 복잡한 추론, 리서치, AI 지원을 위해 Google Gemini CLI를 호출하려 할 때 사용. 트리거 문구: "gemini 써줘", "gemini한테 물어봐", "gemini 실행해", "gemini 불러줘", "gemini cli", "Google AI", "Gemini 추론", 또는 Google AI 모델 요청, 고급 추론, 웹 검색 리서치, 이전 Gemini 대화 이어가기 등.
---

@rules/routing.ko.md

# Gemini: Claude Code용 Google AI 어시스턴트

## 라우팅

이 요청이 실제로 Gemini CLI 또는 Gemini 세션을 필요로 할 때만 이 스킬을 사용한다.

- 범위가 애매하면 먼저 [rules/routing.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/gemini/rules/routing.ko.md)를 읽고 명령을 만들지 결정한다.
- 일반 문서 작성, 런북 정리, Gemini 없이 가능한 직접 편집은 다른 스킬이나 직접 작업으로 전환한다.

## 기본값

| 항목 | 기본값 |
|------|--------|
| 모델 선택 | 사용자가 `-m` 을 명시적으로 원하지 않으면 Gemini CLI 기본 모델 사용 |
| 승인 모드 | `--approval-mode default` |
| 헤드리스 모드 | `-p` / `--prompt` |
| 재개 대상 | `gemini --resume latest` |

모델은 사용자가 명시적으로 요청할 때만 묻거나 고정한다.

## 핵심: 헤드리스 모드의 `-p`

비대화형 실행에는 항상 `-p` / `--prompt` 를 사용한다. 위치 인수 프롬프트는 대화형 모드로 들어간다.

```bash
# 비대화형
gemini --approval-mode default -p "프롬프트"

# 대화형
gemini "프롬프트"
```

## 실행 절차

[references/recipes.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/gemini/references/recipes.ko.md)를 먼저 읽고 승인 모드를 바꾸거나, 샌드박스를 추가하거나, 세션을 재개한다.

### 승인 모드 선택

| 플래그 | 사용 시점 |
|--------|-----------|
| `--approval-mode default` | 일반 리서치, 추론, 표준 Gemini 사용 |
| `--approval-mode auto_edit` | 사용자가 Gemini가 파일을 수정하길 명시적으로 요청했을 때만 |
| `--approval-mode plan` | 파일 수정 없는 읽기 전용 계획/분석 |
| `--yolo` | 사용자가 전체 자동 실행을 명시적으로 승인했을 때만 |

### 명령 작성 규칙

- 시작점은 `gemini --approval-mode default -p "프롬프트"` 다.
- 특정 모델 제어가 필요할 때만 `-m <model>` 을 추가한다.
- 일반 편집은 `--yolo` 대신 `--approval-mode auto_edit` 를 사용한다.
- `--yolo` 는 사용 전에 반드시 확인한다.
- 위험도가 높거나 로컬 제약이 더 필요하면 곧바로 `--yolo` 로 가지 말고 `--sandbox` 를 먼저 고려한다.

### 세션 재개

```bash
gemini --resume latest -p "후속 프롬프트"
gemini --list-sessions
```

재개할 때는 기존 세션 동작을 유지하고, 사용자가 요청하지 않으면 모델이나 승인 모드를 바꾸지 않는다.

### 완료 후

- 결과와 함께 경고나 부분 출력이 있으면 같이 요약한다.
- 사용자가 `gemini --resume latest` 로 다시 이어갈 수 있다고 알려준다.
- 계속할지, 프롬프트를 조정할지, 직접 작업으로 돌아갈지 묻는다.

## 비판적으로 사용하기

Gemini를 **권위자**가 아니라 **동료**로 다룬다.

- 자신 있는 내용은 그대로 유지하고, 틀렸다고 판단되면 바로 반박한다.
- 의견이 갈리면 최신 문서나 현재 소스로 다시 확인한다.
- 최신성이 중요하면 Gemini가 제시한 내용을 1차 자료나 공식 문서로 검증한다.
- 실제로 애매할 때만 사용자에게 판단을 맡긴다.

## 오류 처리

- `command not found: gemini`: Gemini CLI 설치를 안내한다.
- 인증 오류: `gemini` 를 실행해 로그인 플로우를 완료하거나 `GEMINI_API_KEY` / `GOOGLE_API_KEY` 설정을 확인한다.
- 429 / rate limit: 잠시 기다리거나 계정 한도를 확인한다.
- 404 / model not found: `-m` 없이 다시 시도하거나 `gemini --help` 와 공식 문서에 나온 지원 모델로 바꾼다.
- 403 / access denied: 현재 인증 방식과 계정 권한을 확인하고 지원되는 모델/설정으로 재시도한다.
- 세션 없음: `gemini --list-sessions` 로 사용 가능한 세션을 확인한다.

# 가장 최근 세션 재개
gemini -r latest

# 특정 세션 재개
gemini -r 3

# 새 프롬프트로 이어가기
gemini -r latest "이제 로그인 플로우 구현 도와줘"
```

### 승인 모드

```bash
# 기본 모드 (모두 승인 요청)
gemini -m gemini-3.1-pro-preview --approval-mode default "이 코드 검토해줘"

# 자동 편집 (편집만 자동 승인)
gemini -m gemini-3.1-pro-preview --approval-mode auto_edit "이 모듈 리팩토링해줘"

# Plan 모드 (읽기 전용, 파일 수정 없음)
gemini -m gemini-3.1-pro-preview --approval-mode plan "이 코드베이스 분석해줘"

# YOLO 모드 (전체 자동 승인 — 주의해서 사용)
gemini -m gemini-3.1-pro-preview --approval-mode yolo "프로덕션 배포해줘"
```

---

## 파일 컨텍스트 전달

**중요**: 파일 내용을 프롬프트에 직접 삽입하는 대신 파일 경로를 Gemini CLI에 전달한다. 이를 통해 Gemini가 자율적으로 파일을 읽을 수 있다.

```bash
# @ 문법으로 파일 명시적 참조
gemini -m gemini-3.1-pro-preview \
  "@src/auth.ts와 @src/session.ts를 비교 분석해줘"

# 추가 디렉토리 포함
gemini -m gemini-3.1-pro-preview \
  --include-directories /shared/libs \
  "auth 모듈이 공유 유틸리티를 어떻게 사용하는지 검토해줘"
```

---

## 팁 & 모범 사례

1. **항상 모델 명시**: 예측 가능한 동작을 위해 `-m` 플래그를 명시적으로 사용한다
2. **위치 프롬프트 사용**: `gemini "프롬프트"` 방식 선호
3. **필요 시 웹 검색 활성화**: 리서치 작업에 `-e web_search` 추가
4. **복잡한 작업에 세션 재개**: 다회 대화에 `-r latest` 사용
5. **Gemini 3.1 Pro로 시작**: 기본값 `gemini-3.1-pro-preview`, 필요 시 2.5 모델로 폴백
6. **적절한 승인 모드 사용**: 모든 작업에 `default`, 사용자가 명시적으로 파일 편집 요청 시만 `auto_edit`
7. **속도 제한 모니터링**: 무료 티어 분당 60회, 일 1000회
8. **CLI 사용 가능 여부 확인**: 호출 전 `command -v gemini` 검증

---

## Codex와의 차이점

| 기능 | Codex CLI | Gemini CLI |
|------|-----------|------------|
| 호출 방식 | `codex exec "프롬프트"` | `gemini "프롬프트"` |
| 서브커맨드 | 필요 (`exec`) | 불필요 |
| 위치 프롬프트 | 미지원 | 선호 방식 |
| 세션 재개 | `codex exec resume --last` | `gemini -r latest` |
| 모델 | GPT-5.2, GPT-5.3-Codex | Gemini 3.1 Pro, 2.5 Pro/Flash |
| 제공사 | OpenAI (Codex 경유) | Google |

---

## Gemini vs Codex vs Claude 선택 기준

**Gemini 사용 시:**
- Google의 최신 모델이 필요할 때
- 웹 검색 리서치가 중요할 때
- Google AI 기능을 선호할 때
- Codex가 사용 불가거나 속도 제한에 걸렸을 때

**Codex 사용 시:**
- GPT-5.2의 고추론 기능이 필요할 때
- 복잡한 코딩에 GPT-5.3-Codex (에이전틱 코딩 최적화)가 필요할 때
- Codex 워크플로우를 이미 사용 중일 때

**Claude (네이티브) 사용 시:**
- Claude Code 내에서 간단한 질의
- 외부 AI가 필요 없을 때
- 빠른 응답이 필요할 때
- 특수 모델이 필요 없는 작업

---

## 버전 호환성

**최소 Gemini CLI**: v0.29.5

| 기능 | 최소 버전 | 비고 |
|------|----------|------|
| 핵심 기능 | v0.20.0+ | 위치 프롬프트, 세션 재개 |
| `--include-directories` | v0.20.0+ | 워크스페이스 확장 |
| `--approval-mode plan` | v0.29.5+ | 읽기 전용 모드 |
| `gemini skills` | v0.29.5+ | 스킬 관리 |
| `gemini hooks` | v0.29.5+ | 훅 관리 |

문의 또는 문제 발생 시 `references/gemini-help.md`를 참조하거나 `gemini --help`를 실행한다.
