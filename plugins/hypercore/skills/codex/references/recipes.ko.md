# 명령 예시

이 예시들은 라우팅 판단이 끝난 뒤에만 사용한다.

## 기본 비대화형 분석

비대화형 실행은 `codex exec` 와 read-only 샌드박스를 사용한다.

```bash
codex exec --sandbox read-only \
  "이 저장소의 최신 diff를 검토하고 주요 위험을 요약해줘."
```

## 명시적 파일 수정

사용자가 Codex가 파일을 수정하길 명시적으로 요청했을 때만 사용한다.

```bash
codex exec --sandbox workspace-write \
  "src/app.ts 를 패치해서 failing build를 고치고 변경 이유를 설명해줘."
```

## 읽기 전용 계획

파일 변경이나 셸 실행 없이 분석/계획만 원할 때 사용한다.

```bash
codex exec --sandbox read-only \
  "이 아키텍처를 분석하고 주요 위험을 정리해줘."
```

## 코드 리뷰

사용자가 diff 기반 리뷰를 원할 때 사용한다.

```bash
codex review --uncommitted \
  "로컬 staged/unstaged/untracked 변경 사항을 리뷰하고 차단 이슈를 정리해줘."

codex review --base main \
  "이 브랜치를 main 기준으로 리뷰하고 위험 요소와 필수 후속 작업을 요약해줘."

codex review --commit <sha> \
  "이 커밋의 변경 사항만 리뷰해줘."
```

`codex review` 는 본래 읽기 전용 흐름이므로 `--sandbox workspace-write` 나 `--dangerously-bypass-approvals-and-sandbox` 와 함께 쓰지 않는다.

## 최근 비대화형 실행 이어가기

가장 최근 `codex exec` 세션을 그대로 이어간다.

```bash
codex exec resume --last \
  "이전 작업을 계속하고 다음 의사결정을 요약해줘."
```

## 특정 세션 재개

특정 세션 ID를 지정해야 하거나 최근 실행이 맞지 않을 때 사용한다.

```bash
codex exec resume <session-id> \
  "이 세션에서 이어서 후속 요청을 처리해줘."
```

## 최근 대화형 세션 재개

`exec` 실행이 아니라 가장 최근 TUI 세션을 이어가고 싶을 때 사용한다.

```bash
codex resume --last
```

## 기존 세션에서 분기

원래 세션을 재사용하지 않고 갈라서 시도하고 싶을 때 사용한다.

```bash
codex fork --last
```

## 추가 디렉터리 포함

시작 디렉터리 밖의 파일이 필요할 때 사용한다.

```bash
codex exec --add-dir ../shared \
  --sandbox read-only \
  "이 저장소와 shared 디렉터리를 함께 보고 통합 지점을 요약해줘."
```

## 구조화된 JSON 출력

사용자가 기계가 읽을 출력을 명시적으로 원할 때만 사용한다.

```bash
# 실행 중 이벤트를 JSONL로 스트리밍
codex exec --json --sandbox read-only \
  "diff 요약을 최종 메시지로 반환해줘."

# 최종 응답을 JSON Schema 에 맞춰 제한
codex exec --output-schema schema.json --sandbox read-only \
  "이 diff를 기준으로 summary, risks, next_steps 키를 가진 객체를 반환해줘."
```

## 다른 작업 디렉터리에서 실행

사용자가 다른 디렉터리를 작업 루트로 지정한 경우에만 사용한다.

```bash
codex exec -C ../service-a --sandbox read-only \
  "service-a 저장소를 검토하고 주요 위험을 요약해줘."
```

## 위험한 권한 우회는 명시적 승인 후에만

사용자의 명시적 승인 이후, 외부에서 별도로 격리된 환경에서만 사용한다.

```bash
codex exec --dangerously-bypass-approvals-and-sandbox \
  "요청된 패치를 적용하고 필요한 검증을 실행해줘."
```
