# 명령 예시

이 예시들은 라우팅 판단이 끝난 뒤에만 사용한다.

## 기본 비대화형 분석

비대화형 실행에는 `-p/--print` 를 사용한다.

```bash
claude --permission-mode default \
  -p "이 저장소의 최신 diff를 검토하고 주요 위험을 요약해줘."
```

## 명시적 파일 수정

사용자가 Claude Code가 파일을 수정하길 명시적으로 요청했을 때만 사용한다.

```bash
claude --permission-mode acceptEdits \
  -p "src/app.ts 를 패치해서 failing build를 고치고 변경 이유를 설명해줘."
```

## 읽기 전용 계획

파일 변경이나 셸 실행 없이 분석/계획만 원할 때 사용한다.

```bash
claude --permission-mode plan \
  -p "이 아키텍처를 분석하고 주요 위험을 정리해줘."
```

## 최근 세션 계속하기

현재 디렉터리의 가장 최근 대화에 이어서 붙는다.

```bash
claude --continue \
  -p "이전 작업을 계속하고 다음 의사결정을 요약해줘."
```

## 특정 세션 재개

특정 세션 ID를 지정해야 하거나 현재 디렉터리 세션이 맞지 않을 때 사용한다.

```bash
claude --resume <session-id> \
  -p "이 세션에서 이어서 후속 요청을 처리해줘."
```

## 기존 세션에서 분기

원래 세션을 재사용하지 않고 갈라서 시도하고 싶을 때 사용한다.

```bash
claude --resume <session-id> \
  --fork-session \
  -p "이 시점부터 이어가되, 다른 수정 방안을 탐색해줘."
```

## 추가 디렉터리 포함

시작 디렉터리 밖의 파일이 필요할 때 사용한다.

```bash
claude --add-dir ../shared \
  --permission-mode default \
  -p "이 저장소와 shared 디렉터리를 함께 보고 통합 지점을 요약해줘."
```

## 구조화된 JSON 출력

사용자가 기계가 읽을 출력을 명시적으로 원할 때만 사용한다.

```bash
claude --permission-mode default \
  --output-format json \
  -p "이 diff를 기준으로 summary, risks, next_steps 키를 가진 JSON 객체를 반환해줘."
```

## 위험한 권한 우회는 명시적 승인 후에만

사용자의 명시적 승인 이후, 격리된 환경에서만 사용한다.

```bash
claude --dangerously-skip-permissions \
  -p "요청된 패치를 적용하고 필요한 검증을 실행해줘."
```
