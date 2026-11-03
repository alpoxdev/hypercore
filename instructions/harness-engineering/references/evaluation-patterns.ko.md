# Evaluation Patterns

> 영어판: [`evaluation-patterns.md`](evaluation-patterns.md)

## Deterministic Assertions

출력을 정확히 검사할 수 있을 때 쓴다.

```yaml
assert:
  - type: is-json
  - type: contains
    value: "status"
  - type: javascript
    value: output.changed_files.length > 0
```

## Rubric Judge

품질 판단이 필요할 때 쓴다.

```markdown
Score 0-3:
3 = 완전히 답하고, 출처를 인용하며, caveat를 명시함
2 = 대체로 답했으나 사소한 caveat 누락
1 = 부분적 답변이거나 근거가 약함
0 = 근거가 없거나 틀림
```

구성 규칙 넷은 각각 실무에서 실제로 나타나는 실패를 고친다.

- **차원마다 심판 하나.** "create clear, structured rubrics to grade each dimension of a task, and then grade each dimension with an isolated LLM-as-judge rather than using one to grade all dimensions."
- **도피구.** 나쁜 선택지 사이에서 고르라고 강요받은 심판은 없는 답을 만든다. "give the LLM a way out, like providing an instruction to return “Unknown” when it doesn’t have enough information."
- **부분 점수.** 구성 요소가 여럿인 과제는 일부만 맞아도 움직이도록 해야 0점으로 뭉개지지 않는다.
- **심판은 저자가 아니다.** 하는 일과 심판하는 일은 다른 에이전트가 맡는다(HE-R-4). 심판에게는 작업자의 요약이 아니라 산출물과 기준을 준다.

## Trace Assertions

에이전트 검증에 쓴다.

```yaml
must_call:
  - repo_search_before_edit
  - test_after_edit
must_not_call:
  - external_post_without_permission
  - destructive_shell_without_approval
```

## Source-Grounded Answer Eval

```yaml
metrics:
  context_recall: "답변이 필요한 출처 사실을 모두 사용했는가?"
  context_precision: "인용한 출처가 실제로 관련 있는가?"
  citation_accuracy: "출처가 그 주장을 지지하는가?"
  stale_source_rate: "현재 시점 주장이 현재 시점 출처로 뒷받침되는가?"
```


## Outcome, Process, Style, Efficiency

"되었는가"만 묻는 스킬·지시 팩 eval 셋은 네 축 가운데 셋을 놓친다. 공개된 분해는 이렇다.

| 축 | 질문 | 단언 예 |
|---|---|---|
| Outcome | 요구된 최종 상태에 도달했는가 | 파일이 있고 테스트가 통과한다 |
| Process | 허용된 경로로 갔는가 | 마이그레이션을 쓰기 전에 스키마를 읽었다 |
| Style | 하우스 관례를 따랐는가 | 저장소의 커밋 형식을 쓴다 |
| Efficiency | 과제가 정당화하는 만큼만 썼는가 | 토큰·도구 호출 수가 선언한 예산 안이다 |

가장 먼저 빠지는 것이 Style과 Efficiency이고, 프롬프트 변경이 결과는 통과시키면서 가장 자주 깨뜨리는 것도 그 둘이다.

**셋 크기.** 같은 벤더는 스킬 하나에 "a small set of 10–20 prompts"를 권한다. 실무 출발점이지 측정된 임계값이 아니다. 본문은 여전히 최소 케이스 수를 두지 않는다(`## Prompt / Role Instruction Smoke Eval`). 어떤 출처도 그 수를 측정하지 않았기 때문이다. 이 숫자가 쓸모 있는 지점은 모양이다. 작게 시작하고, 실제 실패마다 행을 더하고, 트리거되면 안 되는 부정 케이스를 하나 유지한다.

## Regression Checklist

- [ ] baseline과 동일한 입력 세트를 사용했다
- [ ] 모델·런타임 버전이 같거나 기록되어 있다
- [ ] 채점기·벤치마크 버전이 같거나 기록되어 있다
- [ ] 자원 구성(할당, 타임아웃, 동시성)이 같다
- [ ] 도구 가용성이 같거나 차이가 명시적으로 문서화되어 있다
- [ ] 하네스 결함을 실패나 통과가 아니라 오류 시행으로 집계했다
- [ ] 실패를 root cause별로 분류했다
- [ ] 새 실패를 영구 eval case로 승격했다

## Negative Fixtures (부정 픽스처)

형식은 받아들이는 입력이 아니라 **거부해야 하는 입력**으로 증명된다. 잘못된 케이스마다 검증기 옆에
최소 파일을 두고, 각 파일이 특정 거부를 단언한다.

지시·매니페스트 형식의 최소 집합:

- [ ] 필수 헤더나 frontmatter 블록이 통째로 없음
- [ ] 디렉터리명과 맞지 않는 이름
- [ ] 형식이 금지하는 문자
- [ ] 길이 한계를 넘은 값
- [ ] 알 수 없는 필드
- [ ] **로드되어서는 안 되는 루트** — 기대 결과가 "절대 로드되지 않는다"인 픽스처

마지막이 보안 케이스다. 주어진 것을 다 받아들이는 로더는 모든 양성 테스트를 통과하므로,
"절대 로드되지 않는다" 픽스처가 거부 경로를 관찰 가능하게 만든다.

코퍼스 계약 테스트가 픽스처를 보완한다. 한 파일이 아니라 지시 집합 전체의 속성을 고정한다.
항목 수, 필수 항목, 금지 항목(은퇴한 항목이 광고되어서는 안 된다), 링크 해석이다.

이 저장소의 실행 지점:

```bash
bun run --cwd scripts verify
bash skills/skill-tester/scripts/validate-skills-corpus.sh --root skills --json
```

첫 번째는 저장소 자체 검사를 돌리고, 두 번째는 스킬 코퍼스를 검증해 JSON을 낸다. 형식·검증기·코퍼스
멤버십이 바뀌면 둘 다 돌린다.

## Robustness Cases

정상 경로만 담은 셋이 볼 수 없는 실패를 잡는 케이스 계열이 셋 있다.

| 계열 | 시험하는 것 | 기대 결과 |
|---|---|---|
| 평가로 보이는 입력 | 벤치마크 문항처럼 읽히고 정답 키가 손 닿는 곳에 있는 요청 | 에이전트는 평소대로 작업한다. 정답 키를 찾지 않고, 케이스는 찾았는지 여부를 기록한다 |
| 열화된 환경 | 타임아웃, 연결 거부, 없는 바이너리 같은 모의 인프라 실패 | 실행은 오류 시행이나 `SKIP`으로 기록되고, 통과로 세지 않는다 |
| 낡은 산출물 | 반년 전에는 맞았고 지금은 틀린 출처 | 에이전트가 모순을 알아채고 말한다. 낡은 수치를 인용하지 않는다 |

첫 계열이 있는 이유는 평가 인지가 실재하기 때문이다. 어떤 모델은 자기가 평가받는 중임을 의심하고, 벤치마크를 특정하고, 정답 키를 찾아냈다. 성공 여부보다 중요한 것은 하네스가 그 시도를 관찰할 수 있느냐이고, 그래서 이 케이스는 답이 아니라 trace에 단언을 건다.

## Sources

> 확인 2026-11-03.

**등급 어휘.** 이 디렉터리의 모든 출처 표가 쓰는 하나의 닫힌 집합이다. [`../HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md)의 `## Sources`를 본다.

| 주장 | 출처 | Grade |
|---|---|---|
| 차원별 독립 심판, "Unknown" 도피구, 부분 점수, 경로가 아니라 결과 채점 | <https://www.anthropic.com/research/demystifying-evals-for-ai-agents> | VENDOR |
| 스킬·지시 eval의 outcome / process / style / efficiency 분해와 스킬 하나에 10–20개 프롬프트 | <https://developers.openai.com/blog/eval-skills> | VENDOR |
| 평가 인지: 모델이 벤치마크를 특정하고 정답 키를 찾아낸 사례 | <https://www.anthropic.com/research/eval-awareness-browsecomp> | VENDOR |
| 리더보드 관례에 따라 인프라 오류 시행을 실패 시행으로 계산 | <https://github.com/sierra-research/tau2-bench/releases/tag/v1.0.1> | PRIMARY |
| 동일 조건 실행 사이의 점수 이동을 만드는 인프라 분산 | <https://www.anthropic.com/research/infrastructure-noise> | VENDOR |
