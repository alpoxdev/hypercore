---
name: gemini
version: 1.6.0
description: 사용자가 복잡한 추론, 리서치, AI 지원을 위해 Google Gemini CLI를 호출하려 할 때 사용. 트리거 문구: "gemini 써줘", "gemini한테 물어봐", "gemini 실행해", "gemini 불러줘", "gemini cli", "Google AI", "Gemini 추론", 또는 Google AI 모델 요청, 고급 추론, 웹 검색 리서치, 이전 Gemini 대화 이어가기 등.
---

# Gemini: Claude Code용 Google AI 어시스턴트

---

## 기본 모델: Gemini 3.1 Pro

**모든 Gemini 호출의 기본 모델은 `gemini-3.1-pro-preview`다.**

- 사용자가 명시적으로 다른 모델을 요청하지 않으면 항상 `gemini-3.1-pro-preview` 사용
- 현재 사용 가능한 최고 추론 모델 (2026년 2월 19일 출시)
- CLI 기본값(플래그 없음)은 `gemini-3-flash-preview` (빠르지만 성능 낮음)
- 폴백 체인: `gemini-3.1-pro-preview` → `gemini-3-pro-preview` → `gemini-2.5-flash`

```bash
# 기본 호출 - 항상 gemini-3.1-pro-preview 사용
gemini -m gemini-3.1-pro-preview "프롬프트"
```

---

## 핵심: 헤드리스 모드의 `-p` 플래그

**필수**: Claude Code의 비대화형(헤드리스) 실행에는 `-p`/`--prompt` 플래그를 사용한다.

Gemini CLI v0.29.0+부터 위치 인수 프롬프트는 기본적으로 **대화형 모드**로 동작한다. `-p` 플래그가 **비대화형(헤드리스) 모드**의 올바른 방법이다.

**예시:**
- `gemini -m gemini-3.1-pro-preview -p "프롬프트"` (올바름 - 헤드리스 모드)
- `gemini -m gemini-3.1-pro-preview "프롬프트"` (파이프 연결 시 동작하지만 `-p`가 더 명확)
- `gemini -r latest` (세션 재개)

---

## 중요: Preview Features & OAuth 무료 티어

**헤드리스 모드의 OAuth 무료 티어 사용자:**

`~/.gemini/settings.json`에서 `previewFeatures: true`이면 CLI가 모든 요청을 Gemini 3.1 Pro로 라우팅한다 (`-m gemini-2.5-pro`여도). 무료 티어는 Gemini 3 접근 권한이 없어 404 오류가 발생한다.

**해결책**: 안정적인 헤드리스 동작을 위해 preview features 비활성화:
```json
// ~/.gemini/settings.json
{
  "general": {
    "previewFeatures": false
  }
}
```

**플러그인 동작**: 이 스킬은 404 오류 발생 시 자동으로 `gemini-2.5-flash`로 폴백한다. Flash는 OAuth 무료 티어에서 항상 동작한다.

---

## 트리거 예시

다음과 같은 문구에서 이 스킬이 활성화된다:
- "이 주제를 gemini로 리서치해줘"
- "이 디자인 패턴에 대해 gemini한테 물어봐"
- "이 분석에 gemini 실행해줘"
- "이 문제를 gemini로 도움받아줘"
- "이 작업에 Google AI가 필요해"
- "이것에 대한 Gemini의 추론을 가져와"
- "gemini 계속해줘" 또는 "gemini 세션 재개해줘"
- "Gemini, 이것 도와줘" 또는 그냥 "Gemini"
- "Gemini 3 써줘" 또는 "Gemini 2.5 써줘"

## 사용 시기

다음 상황에서 이 스킬을 호출한다:
- 사용자가 명시적으로 "Gemini"를 언급하거나 Gemini 지원을 요청할 때
- Google AI 모델로 추론, 리서치, 분석이 필요할 때
- 복잡한 문제 해결이나 아키텍처 설계가 필요할 때
- 웹 검색 통합 리서치 기능이 필요할 때
- 이전 Gemini 대화를 이어가고 싶을 때
- 특정 작업에서 Codex나 Claude 대신 다른 선택지가 필요할 때

## 동작 방식

### 새 Gemini 요청 감지

사용자 요청 시 **기본적으로 읽기 전용 모드(기본 승인)**를 사용하고, 파일 편집을 명시적으로 요청할 때만 변경한다:

**모든 작업에 `gemini-3.1-pro-preview` + `default` 승인 모드 사용:**
- 아키텍처, 설계, 검토, 리서치
- 설명, 분석, 문제 해결
- 코드 분석 및 이해
- 사용자가 파일 편집을 명시적으로 요청하지 않는 모든 작업

**승인 모드 선택:**
- **`default`** (기본): 모든 작업 — 편집 시 승인 요청 (안전)
- **`auto_edit`**: 사용자가 파일 편집을 명시적으로 요청할 때만
- **`plan`**: 읽기 전용 모드 — 파일 수정 불가
- **`yolo`**: 사용자가 전체 자동 승인을 원할 때 (주의해서 사용)

**⚠️ 명시적 편집 요청**: 사용자가 "파일 편집", "코드 수정", "변경 사항 작성", "편집 해줘"를 명시적으로 요청할 때만 `--approval-mode auto_edit`를 사용한다.

**폴백 체인** (기본 모델 사용 불가 시):
1. `gemini-3.1-pro-preview` (기본 — 최고 성능)
2. `gemini-2.5-pro` (안정적인 범용 추론)
3. `gemini-2.5-flash` (빠름, 항상 사용 가능)

### Bash CLI 명령어 구조

**중요**: Gemini CLI는 Codex와 다르다 — `exec` 서브커맨드 불필요. 위치 프롬프트를 직접 사용한다.

#### 기본 명령어 (읽기 전용) — 모든 작업에 사용

```bash
gemini -m gemini-3.1-pro-preview \
  "마이크로서비스 e-커머스 아키텍처 설계해줘"
```

#### 명시적 편집 요청 시만 — 사용자가 파일 편집을 요청할 때

```bash
gemini -m gemini-3.1-pro-preview \
  --approval-mode auto_edit \
  "이 파일을 편집해서 함수를 리팩토링해줘"
```

#### 세션 이어가기

```bash
# 가장 최근 세션 재개
gemini -r latest

# 특정 인덱스 세션 재개
gemini -r 3

# 재개하면서 새 프롬프트 추가
gemini -r latest "캐싱 전략 논의 계속해줘"
```

### 모델 선택 로직

**모든 작업에 `gemini-3.1-pro-preview` (기본):**
- 코드 편집, 리팩토링, 구현
- 아키텍처 또는 시스템 설계
- 리서치 또는 분석
- 복잡한 개념 설명
- 구현 전략 계획
- 범용 문제 해결 및 고급 추론

**`gemini-2.5-pro`로 폴백 시:**
- Gemini 3.1 Pro 사용 불가 또는 할당량 소진 시
- 사용자가 명시적으로 "Gemini 2.5" 또는 "2.5 써줘" 요청 시
- 안정적인 프로덕션 작업 시

**`gemini-2.5-flash`로 폴백 시:**
- Gemini 3.1 Pro와 2.5 Pro 모두 사용 불가 시
- 빠른 반복이 필요할 때 (사용자 명시 요청)
- 간단하고 빠른 응답 (사용자 명시 요청)

### 버전별 모델 매핑

| 사용자 요청 | 매핑 대상 | 실제 모델 ID |
|-------------|----------|-------------|
| "3 써줘" / "Gemini 3" | 최신 3.x Pro | `gemini-3.1-pro-preview` |
| "2.5 써줘" | 2.5 Pro | `gemini-2.5-pro` |
| "flash 써줘" | 2.5 Flash | `gemini-2.5-flash` |
| 버전 미지정 | 최신 Pro (전체) | `gemini-3.1-pro-preview` |

### 기본 설정

| 파라미터 | 기본값 | CLI 플래그 | 비고 |
|---------|--------|-----------|------|
| 모델 | `gemini-3.1-pro-preview` | `-m gemini-3.1-pro-preview` | 모든 작업 (최고 성능) |
| 모델 (폴백 1) | `gemini-2.5-pro` | `-m gemini-2.5-pro` | 3.1 Pro 불가 시 |
| 모델 (폴백 2) | `gemini-2.5-flash` | `-m gemini-2.5-flash` | 무료 티어에서 항상 동작 |
| 승인 모드 (기본) | `default` | 플래그 없음 | 안전한 기본값 — 편집 시 승인 요청 |
| 승인 모드 (편집) | `auto_edit` | `--approval-mode auto_edit` | 사용자가 명시적으로 편집 요청 시만 |
| 샌드박스 | `false` (비활성) | 플래그 없음 | 기본적으로 샌드박스 비활성 |
| 출력 형식 | `text` | 플래그 없음 | 사람이 읽는 텍스트 출력 |
| 웹 검색 | 적절 시 활성 | `-e web_search` (필요 시) | 상황에 따라 다름 |

### 오류 처리

#### CLI 미설치

**오류**: `command not found: gemini`

**메시지**: "Gemini CLI가 설치되지 않았습니다. 설치: https://github.com/google-gemini/gemini-cli"

#### 인증 필요

**오류**: 출력에 "auth" 또는 "authentication" 포함

**메시지**: "인증이 필요합니다. `gemini login`으로 Google 계정 인증을 진행하세요"

#### 속도 제한 초과

**오류**: 출력에 "quota", "rate limit" 또는 상태 429 포함

**메시지**: "속도 제한 초과 (분당 60회, 무료 티어 일 1000회). X초 후 재시도하거나 계정을 업그레이드하세요."

#### 모델 사용 불가

**오류**: 출력에 "model not found", "404" 또는 상태 403 포함

**메시지**: "모델 사용 불가. 폴백 모델 시도 중..."

**동작**: 자동으로 폴백 시도:
- `gemini-3.1-pro-preview` 불가 → `gemini-2.5-pro` 시도
- `gemini-2.5-pro` 불가 → `gemini-2.5-flash` 시도

#### 세션 없음

**오류**: `-r` 플래그 사용 시 세션 없음

**메시지**: "세션을 찾을 수 없습니다. `gemini --list-sessions`로 사용 가능한 세션을 확인하세요."

#### Gemini 3.1 Pro 접근 거부

**오류**: 상태 403 또는 "preview access required"

**메시지**: "Gemini 3.1 Pro는 preview 접근이 필요합니다. 설정에서 Preview Features를 활성화하거나 `gemini-2.5-pro`를 사용하세요."

---

## 예시

### 기본 호출 (범용 추론)

```bash
# 시스템 아키텍처 설계
gemini -m gemini-3.1-pro-preview "확장 가능한 결제 처리 시스템 설계해줘"

# 웹 검색으로 리서치
gemini -m gemini-3.1-pro-preview -e web_search "React 19 최신 기능 리서치해줘"

# 복잡한 개념 설명
gemini -m gemini-3.1-pro-preview "CAP 정리를 실제 예시로 설명해줘"
```

### 세션 관리

```bash
# 세션 시작 (자동)
gemini -m gemini-3.1-pro-preview "인증 시스템 설계해줘"

# 사용 가능한 세션 목록
gemini --list-sessions

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
