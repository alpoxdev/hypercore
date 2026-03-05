---
name: codex
description: 사용자가 Codex CLI 실행(codex exec, codex resume)을 요청하거나 코드 분석, 리팩토링, 자동 편집을 위해 OpenAI Codex를 참조할 때 사용
---

# Codex 스킬 가이드

## 작업 실행

1. `AskUserQuestion`으로 사용자에게 **하나의 프롬프트로** 두 가지를 질문한다:
   - 실행할 모델 (`gpt-5.3-codex-spark`, `gpt-5.3-codex`, `gpt-5.2` 중 선택)
   - 추론 강도 (`xhigh`, `high`, `medium`, `low` 중 선택)
2. 작업에 맞는 샌드박스 모드를 선택한다. 편집이나 네트워크 접근이 필요하지 않으면 기본값 `--sandbox read-only` 사용.
3. 아래 옵션으로 명령어를 조합한다:
   - `-m, --model <MODEL>`
   - `--config model_reasoning_effort="<xhigh|high|medium|low>"`
   - `--sandbox <read-only|workspace-write|danger-full-access>`
   - `--full-auto`
   - `-C, --cd <DIR>`
   - `--skip-git-repo-check`
   - `"프롬프트"` (마지막 위치 인수)
3. 항상 `--skip-git-repo-check`를 사용한다.
4. 이전 세션을 이어갈 때는 stdin으로 `codex exec --skip-git-repo-check resume --last`를 사용한다. 재개 시 사용자가 명시적으로 요청하지 않으면 설정 플래그를 추가하지 않는다. 재개 구문: `echo "프롬프트" | codex exec --skip-git-repo-check resume --last 2>/dev/null`. 모든 플래그는 `exec`와 `resume` 사이에 삽입한다.
5. **중요**: 기본적으로 모든 `codex exec` 명령에 `2>/dev/null`을 추가해 thinking 토큰(stderr)을 숨긴다. 사용자가 명시적으로 요청하거나 디버깅이 필요할 때만 stderr를 표시한다.
6. 명령을 실행하고 stdout/stderr(필요 시 필터링)를 캡처한 뒤 결과를 요약한다.
7. **Codex 완료 후**, 사용자에게 안내한다: "'codex resume'이라고 말하거나 계속 진행하도록 요청하면 언제든지 이 Codex 세션을 재개할 수 있습니다."

### 빠른 참조

| 사용 사례 | 샌드박스 모드 | 주요 플래그 |
| --- | --- | --- |
| 읽기 전용 검토/분석 | `read-only` | `--sandbox read-only 2>/dev/null` |
| 로컬 편집 적용 | `workspace-write` | `--sandbox workspace-write --full-auto 2>/dev/null` |
| 네트워크/광범위 접근 허용 | `danger-full-access` | `--sandbox danger-full-access --full-auto 2>/dev/null` |
| 최근 세션 재개 | 원본에서 상속 | `echo "prompt" \| codex exec --skip-git-repo-check resume --last 2>/dev/null` (플래그 추가 불가) |
| 다른 디렉토리에서 실행 | 작업에 맞게 선택 | `-C <DIR>` 및 기타 플래그 `2>/dev/null` |

## 후속 조치

- 모든 `codex` 명령 실행 후 즉시 `AskUserQuestion`으로 다음 단계를 확인하거나, 추가 내용을 수집하거나, `codex exec resume --last`로 재개 여부를 결정한다.
- 재개 시 새 프롬프트를 stdin으로 전달한다: `echo "새 프롬프트" | codex exec resume --last 2>/dev/null`. 재개된 세션은 원본과 동일한 모델, 추론 강도, 샌드박스 모드를 자동으로 사용한다.
- 후속 작업을 제안할 때 선택한 모델, 추론 강도, 샌드박스 모드를 다시 명시한다.

## Codex 출력의 비판적 평가

Codex는 자체적인 지식 컷오프와 한계를 가진 OpenAI 모델로 구동된다. Codex를 **권위자가 아닌 동료**로 대한다.

### 가이드라인

- **자신의 지식을 신뢰한다** — 확신이 있을 때 Codex의 잘못된 주장에 직접 반박한다.
- **이견을 조사한다** — Codex의 주장을 수용하기 전에 WebSearch나 문서로 검증한다. 필요하면 재개를 통해 결과를 Codex와 공유한다.
- **지식 컷오프를 기억한다** — Codex는 학습 데이터 이후의 최신 릴리스, API, 변경 사항을 모를 수 있다.
- **맹목적으로 따르지 않는다** — Codex는 틀릴 수 있다. 특히 다음 사항은 비판적으로 평가한다:
  - 모델 이름 및 기능
  - 최신 라이브러리 버전 또는 API 변경 사항
  - 발전했을 수 있는 모범 사례

### Codex가 틀렸을 때

1. 사용자에게 이견을 명확히 전달한다
2. 근거를 제시한다 (자신의 지식, 웹 검색, 문서)
3. 필요하면 Codex 세션을 재개해 이견을 논의한다. **Claude임을 밝혀** Codex가 동료 AI 토론임을 알게 한다. 하드코딩된 이름 대신 실제 모델명을 사용한다:
   ```bash
   echo "안녕, 나는 Claude (<현재 모델명>)야. [X]에 대해 동의하지 않아. 이유는 [근거]. 어떻게 생각해?" | codex exec --skip-git-repo-check resume --last 2>/dev/null
   ```
4. 이견을 수정이 아닌 토론으로 프레임한다 — 어느 AI든 틀릴 수 있다
5. 진정한 모호성이 있을 때는 사용자가 결정하게 한다

## 오류 처리

- `codex --version` 또는 `codex exec` 명령이 비정상 종료되면 즉시 중단하고 보고한 뒤 방향을 요청한다.
- 고영향 플래그(`--full-auto`, `--sandbox danger-full-access`, `--skip-git-repo-check`)를 사용하기 전에 이미 허가된 경우가 아니면 `AskUserQuestion`으로 사용자 승인을 받는다.
- 출력에 경고나 부분 결과가 포함된 경우, 내용을 요약하고 `AskUserQuestion`으로 조정 방법을 묻는다.
