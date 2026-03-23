# 명령 예시

라우팅 결정이 끝난 뒤에만 이 예시를 사용한다.

## 기본 헤드리스 리서치

비대화형 실행에는 `-p/--prompt` 를 사용한다.

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

## 읽기 전용 계획 모드

파일 수정 없이 계획이나 분석만 원할 때 사용한다.

```bash
gemini --approval-mode plan \
  -p "이 아키텍처를 검토하고 주요 리스크를 정리해줘."
```

## 최신 세션 재개

```bash
gemini --resume latest \
  -p "이전 작업을 이어서 진행하고 다음 의사결정을 요약해줘."
```

인덱스로 재개하거나 세션 식별자가 불명확하면 먼저 `gemini --list-sessions` 를 실행한다.

## YOLO는 명시적 승인 후에만

전체 자동 실행은 사용자가 명시적으로 승인했을 때만 사용한다.

```bash
gemini --yolo \
  -p "요청된 패치를 적용하고 요청된 체크를 실행해줘."
```

## 더 안전한 샌드박스 편집

위험도가 높거나 로컬 제약을 더 강하게 두고 싶다면 곧바로 `--yolo` 로 가지 말고 샌드박스를 추가한다.

```bash
gemini --sandbox \
  --approval-mode auto_edit \
  -p "이 저장소를 확인하고 요청된 패치를 적용한 뒤 결과를 설명해줘."
```
