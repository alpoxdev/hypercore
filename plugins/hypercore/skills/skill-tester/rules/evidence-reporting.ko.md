# Evidence Reporting

**Purpose**: 스킬 테스트 결과를 실행 가능하고, 재현 가능하며, 쉽게 handoff할 수 있게 만든다.

## Verdicts

- `pass`: 필수 시나리오가 통과했고 고위험 공백이 남아 있지 않다.
- `pass-with-risks`: 핵심 동작은 작동하지만 중간/낮은 위험 또는 미테스트 영역이 남아 있다.
- `fail`: 일반적인 대상 요청이 실패하거나, 잘못된 요청이 활성화되거나, 필수 리소스가 깨졌거나, 검증이 빠져 있다.

## Finding format

각 이슈에는 이 형태를 사용한다:

```markdown
- **[severity] [taxonomy] Title**
  - Evidence: `path:section` or command output summary.
  - Impact: why this can misroute or mis-execute the skill.
  - Minimal fix: smallest safe edit or handoff.
```

## Evidence standards

강한 근거에는 다음이 포함된다:

- `SKILL.md`에서 직접 읽은 metadata와 trigger wording
- 스킬에 선언되어 있고 디스크에서 확인된 링크
- 기대 동작과 관찰 동작이 있는 시나리오 표
- 결정적 스크립트 출력
- 정적 검사에 대한 명령 출력

약한 근거에는 다음이 포함된다:

- 시나리오 없이 "looks fine"이라고 하는 것
- 파일 참조 없는 광범위한 의견
- 연결된 리소스를 확인하지 않은 통과 주장

## Handoff rules

- 구조 편집, 트리거 재작성, 리소스 배치 수정은 `skill-maker`에 handoff한다.
- 사용자가 반복 벤치마크 실험이나 점수 기반 mutation을 원하면 `autoresearch-skill`에 handoff한다.
- 테스트 대상이 스킬이 아니라 애플리케이션이면 app QA skills에 handoff한다.

## Final report checklist

- 대상과 verdict를 먼저 말한다.
- 추천보다 먼저 시나리오 결과를 보여준다.
- 스킬의 failure taxonomy를 사용해 실패를 분류한다.
- 실행한 명령과 검사한 파일을 명명한다.
- 전체 커버리지를 암시하지 말고 미테스트 영역을 명시적으로 명명한다.
