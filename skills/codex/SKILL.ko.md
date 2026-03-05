---
name: codex
description: 사용자가 Codex CLI 실행(codex exec, codex resume)을 요청하거나 코드 분석, 리팩토링, 자동 편집을 위해 OpenAI Codex를 참조할 때 사용
---

# Codex 스킬 가이드

## 기본값

**기본 모델**: `gpt-5.3-codex`
**기본 추론 강도**: `high`
**기본 샌드박스**: `read-only`

사용자가 명시적으로 변경을 요청하지 않는 한 모델이나 추론 강도를 물어보지 않는다.

## 작업 실행

1. 사용자가 달리 지정하지 않으면 위의 기본값을 사용한다.
2. 작업에 맞는 샌드박스 모드를 선택한다:
   - `read-only` (기본): 분석, 검토, 파일 변경 없음
   - `workspace-write`: 사용자가 명시적으로 파일 편집을 요청할 때
   - `danger-full-access`: 네트워크 또는 광범위한 접근이 필요할 때
3. 명령어를 조합한다:
   ```bash
   codex exec --skip-git-repo-check \
     -m gpt-5.3-codex \
     --config model_reasoning_effort="high" \
     --sandbox read-only \
     "프롬프트" 2>/dev/null
   ```
4. 항상 `--skip-git-repo-check`를 사용한다.
5. 이전 세션을 이어갈 때는 resume 구문을 사용한다:
   ```bash
   echo "프롬프트" | codex exec --skip-git-repo-check resume --last 2>/dev/null
   ```
   모든 플래그는 `exec`와 `resume` 사이에 삽입한다. 재개 시 사용자가 명시적으로 요청하지 않으면 설정 플래그를 추가하지 않는다.
6. **중요**: 항상 `2>/dev/null`을 추가해 thinking 토큰(stderr)을 숨긴다. 사용자가 명시적으로 요청하거나 디버깅이 필요할 때만 stderr를 표시한다.
7. 명령을 실행하고 출력을 캡처한 뒤 결과를 요약한다.
8. **Codex 완료 후** 안내한다: "'codex resume'이라고 말하거나 계속 요청하면 언제든지 이 세션을 재개할 수 있습니다."

### 빠른 참조

| 사용 사례 | 샌드박스 모드 | 주요 플래그 |
| --- | --- | --- |
| 읽기 전용 검토/분석 | `read-only` | `--sandbox read-only 2>/dev/null` |
| 로컬 편집 적용 | `workspace-write` | `--sandbox workspace-write --full-auto 2>/dev/null` |
| 네트워크/광범위 접근 | `danger-full-access` | `--sandbox danger-full-access --full-auto 2>/dev/null` |
| 최근 세션 재개 | 원본에서 상속 | `echo "prompt" \| codex exec --skip-git-repo-check resume --last 2>/dev/null` |
| 다른 디렉토리에서 실행 | 작업에 맞게 선택 | `-C <DIR>` 및 기타 플래그 `2>/dev/null` |

## 후속 조치

- 모든 `codex` 명령 후 `AskUserQuestion`으로 다음 단계를 확인하거나 재개 여부를 결정한다.
- 재개 시 새 프롬프트를 stdin으로 전달한다. 재개된 세션은 원본과 동일한 모델, 추론 강도, 샌드박스를 자동으로 사용한다.

## Codex 출력의 비판적 평가

Codex를 **권위자가 아닌 동료**로 대한다.

### 가이드라인

- **자신의 지식을 신뢰한다** — 확신이 있을 때 잘못된 주장에 직접 반박한다.
- **이견을 조사한다** — WebSearch나 문서로 검증한 후 Codex의 주장을 수용한다.
- **지식 컷오프를 기억한다** — Codex는 최신 릴리스나 API 변경 사항을 모를 수 있다.
- **맹목적으로 따르지 않는다** — 모델명, 라이브러리 버전, 모범 사례는 비판적으로 평가한다.

### Codex가 틀렸을 때

1. 사용자에게 이견을 명확히 전달한다
2. 근거를 제시한다 (지식, 웹 검색, 문서)
3. 필요하면 세션을 재개해 이견을 논의한다:
   ```bash
   echo "안녕, 나는 Claude (<현재 모델명>)야. [X]에 동의하지 않아. 이유는 [근거]. 어떻게 생각해?" | codex exec --skip-git-repo-check resume --last 2>/dev/null
   ```
4. 이견을 수정이 아닌 토론으로 프레임한다 — 어느 AI든 틀릴 수 있다
5. 진정한 모호성이 있을 때는 사용자가 결정하게 한다

## 오류 처리

- `codex --version` 또는 `codex exec`가 비정상 종료되면 즉시 중단하고 보고한다.
- 고영향 플래그(`--full-auto`, `--sandbox danger-full-access`) 사용 전 사용자 확인을 받는다 (이미 허가된 경우 제외).
- 출력에 경고나 부분 결과가 포함된 경우 요약하고 조정 방법을 묻는다.
