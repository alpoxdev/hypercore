# Scenario Design

**Purpose**: 트리거, 워크플로, edge-case 실패를 드러내는 현실적인 스킬 테스트 케이스를 작성한다.

## Scenario types

- `positive`: 대상 스킬이 소유해야 하는 요청.
- `negative`: 이웃 스킬이나 일반 워크플로가 대신 소유해야 하는 요청.
- `boundary`: 스킬 범위의 경계 근처에 있는 그럴듯한 요청.
- `edge`: 입력 누락, 깨진 경로, 지원되지 않는 언어, 충돌하는 제약, 부재한 도구처럼 특이하지만 현실적인 조건.
- `regression`: 이전 변경, 유사 스킬, 또는 현재 약한 표현에서 온 알려졌거나 가능성 큰 실패.

## Good scenario prompts

좋은 프롬프트는 테스트 라벨이 아니라 실제 사용자가 쓸 법한 문장으로 작성된다.

Prefer:

```text
$skill-maker Create a skill for testing browser automation prompts, with edge cases.
```

Avoid:

```text
Positive trigger for skill creation.
```

## Expected-observed format

각 시나리오는 다음을 정의해야 한다:

1. 프롬프트 또는 조건.
2. 기대 라우팅 또는 워크플로 동작.
3. 검사, 시뮬레이션, 또는 실제 실행에서 관찰된 동작.
4. 결과: `pass`, `fail`, 또는 `risk`.
5. 근거: 파일, 줄, 명령 출력, 또는 reasoning summary.

## Edge-case prompts to consider

- 대상 경로 누락: 첨부나 경로 없이 "Test this skill".
- 잘못된 경로: 대상 디렉터리는 있지만 `SKILL.md`가 없음.
- 충돌하는 의도: "Test this skill and rewrite it completely."
- Localization: 한국어 또는 다른 지원 언어로 같은 동작을 요청.
- 이웃 스킬 중복: 요청이 skill creation, skill testing, skill optimization 중 하나와 맞을 수 있음.
- 리소스 실패: `@rules/foo.md`가 연결되어 있지만 없음.
- 검증 공백: 워크플로가 명령 또는 readback 근거 없이 성공 보고를 허용함.

## Localization

스킬에 localized metadata나 examples가 있다면 해당 언어의 시나리오를 포함한다. 저장소가 번역된 `SKILL.*.md` 파일을 지원할 때 English-only trigger behavior를 가정하지 않는다.
