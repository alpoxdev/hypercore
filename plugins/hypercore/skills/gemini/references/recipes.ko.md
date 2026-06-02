# 명령 예시

라우팅 결정이 끝난 뒤에만 이 예시를 사용한다. Gemini CLI v0.40.0 기준.

## 기본 헤드리스 리서치

비대화형 실행에는 `-p` / `--prompt` 를 사용한다. 위치 인수 프롬프트는 대화형 REPL 로 들어간다.

```bash
gemini --approval-mode default \
  -p "React 19 최신 변경 사항을 조사하고 사용한 현재 소스를 요약해줘."
```

## 명시적 파일 편집

사용자가 Gemini가 파일을 수정하길 명시적으로 요청했을 때만 사용한다.

```bash
gemini --approval-mode auto_edit \
  -p "src/app.ts 를 수정해서 failing build 를 고쳐줘."
```

## 읽기 전용 Plan 모드

파일 수정 없이 계획이나 분석만 원할 때 사용한다. Plan 모드는 plans 디렉터리의 Markdown 파일에만 쓰기를 허용한다.

```bash
gemini --approval-mode plan \
  -p "이 아키텍처를 검토하고 주요 리스크를 정리해줘."
```

## 최신 세션 재개

```bash
gemini --resume latest \
  -p "이전 작업을 이어서 진행하고 다음 의사결정을 요약해줘."
```

`--resume` 은 인덱스(`gemini -r 1`) 나 세션 UUID 도 받는다. 대상 세션이 불명확하면 먼저 `gemini --list-sessions` 를 실행하고, 세션 정리는 `gemini --delete-session <인덱스>` 로 한다.

## 샌드박스 자동 편집

위험도가 높거나 로컬 제약을 더 강하게 두고 싶다면 곧바로 YOLO 로 가지 말고 샌드박스를 추가한다.

```bash
gemini --sandbox \
  --approval-mode auto_edit \
  -p "이 저장소를 확인하고 요청된 패치를 적용한 뒤 결과를 설명해줘."
```

`-s` 가 `--sandbox` 의 단축 형태다.

## YOLO 는 명시적 승인 후에만

전체 자동 실행은 사용자가 명시적으로 승인했을 때만 사용한다. 단독 `--yolo` 는 deprecated 이므로 `--approval-mode yolo` 를 쓴다.

```bash
gemini --approval-mode yolo \
  -p "요청된 패치를 적용하고 요청된 체크를 실행해줘."
```

## 여러 디렉터리 컨텍스트 추가

작업이 여러 저장소에 걸칠 때 Gemini 워크스페이스에 추가 폴더를 포함시킨다.

```bash
gemini --include-directories ../shared-libs,../docs \
  -p "auth 모듈이 공유 유틸리티를 어떻게 사용하는지 설명해줘."
```

## 구조화 JSON 출력

호출자가 결과를 프로그래밍 방식으로 파싱해야 할 때만 `--output-format json` 을 사용한다. `stream-json` 은 스트리밍 소비자용 NDJSON 이벤트를 내보낸다.

```bash
gemini --approval-mode default \
  --output-format json \
  -p "이 PR 의 리스크를 JSON 배열로 반환해줘."
```

## 특정 모델 선택

사용자가 특정 모델을 명시적으로 요청한 경우에만 사용한다. 별칭 `pro`, `flash`, `flash-lite`, `auto` 와 전체 모델 ID 모두 허용된다.

```bash
gemini -m pro --approval-mode default \
  -p "이 설계 트레이드오프를 신중하게 추론해줘."
```

## 시드 프롬프트로 대화형 시작

프롬프트로 시작한 뒤 사용자가 이어서 대화하길 원하면 `-p` 대신 `-i` / `--prompt-interactive` 를 사용한다.

```bash
gemini --approval-mode default \
  -i "auth 플로우 먼저 설명해줘. 그 뒤에 후속 질문 이어갈게."
```

`-p` 는 한 번 실행하고 종료, `-i` 는 프롬프트를 시드하고 REPL 에 남는다.

## `@` 로 파일 컨텍스트 전달

프롬프트 안에서 `@<경로>` 를 쓰면 git-aware 필터링과 함께 파일/디렉터리 내용을 포함시킨다.

```bash
gemini --approval-mode default \
  -p "@src/auth.ts 와 @src/session.ts 를 비교하고 차이를 정리해줘."
```
