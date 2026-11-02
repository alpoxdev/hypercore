# Techniques

> 영어판: [`techniques.md`](techniques.md)

## 1. Decomposition

복잡한 작업은 “한 번에 잘하기”보다 분해가 안정적이다.

| 작업 | 분해 방식 |
|---|---|
| 코드 수정 | explore → plan → edit → test → review |
| 리서치 | questions → source plan → collect → synthesize → validate |
| UX/문서 | audience → task → examples → output contract → QA |
| 에이전트 하네스 | scenario → expected behavior → metrics → regression run |

## 2. Few-shot Examples

예시는 규칙보다 강하다. 단, 너무 많은 예시는 context를 오염시킨다.

```markdown
<examples>
  <good>원하는 형태 1개</good>
  <bad>피해야 할 형태 1개</bad>
</examples>
```

- 형식·톤·API shape를 고정할 때 사용한다.
- 도메인 사실을 예시에 숨기지 않는다. 사실은 evidence section에 둔다.
- 예시가 오래되면 instruction도 같이 stale해진다.
- 예시와 본문 규칙이 충돌하면 모델은 예시 패턴을 더 강하게 따를 수 있으므로, 예시는 현재 규칙의 대표 사례만 둔다.

## 3. Structured Output

후속 도구/검증이 읽어야 하는 출력은 Markdown보다 schema를 우선한다.

```json
{
  "status": "pass|fail|blocked",
  "evidence": [{ "claim": "...", "source": "..." }],
  "next_actions": ["..."]
}
```

## 4. Reasoning Control

- 복잡한 문제에는 “계획/검토/대안 비교”를 요구한다.
- 최종 답변에는 필요한 만큼의 rationale과 검증 결과를 내보낸다.
- 숨겨진 chain-of-thought 원문을 요구하지 말고, 결정 근거·근거 링크·테스트 결과를 요구한다.
- reasoning 모델에는 무조건적인 “think step by step”보다 명확한 목표, 제약, 성공 기준, 반복/검증 조건을 준다. 모델별 reasoning/effort 파라미터가 있으면 runtime profile에 분리한다.

최근 벤더 지침은 여기로 수렴한다. OpenAI는 reasoning 모델에 “think step by step”을 지시하면 “성능이 좋아지지 않고 때로는 나빠질 수 있다”고 적는다. 현재 세대 지침은 대신 지속성을 요구한다. “행동 쪽으로 기울여 사용자가 의도한 작업을 끝까지 완수하라”고 하고, 확인 질문을 하기 전에 “맥락상 이미 허가된 작업”을 먼저 끝내라고 한다(확인 2026-11-03). Anthropic이 쓰는 수단은 구획 구조와 명시적 성공 기준이지 특정 문구가 아니다. 추론 제어는 목표, 제약, 검증으로 쓰고 effort 설정은 런타임에 맡긴다.

분량은 문장보다 파라미터로 먼저 정한다. OpenAI는 `text.verbosity`(`low` / `medium` / `high`)를 두고 “간결함과 완전함의 균형을 잡는 주된 수단”이라고 부른다. 이전 모델에서 쓰던 “간결하게” 같은 광범위한 지시가 모델을 올린 뒤에도 유효한지 확인하라는 이전 안내도 함께 둔다. 길이는 파라미터로 정하고, 지시문은 모양(구조, 순서, 무엇을 빼는지)에 쓴다.

| 필요 | 지시 |
|---|---|
| 빠른 사실 답 | 직접 답하고 출처/날짜만 표시 |
| 다단계 분석 | 계획, 대안, 검증 기준 작성 |
| 고위험 판단 | 자료 확인, 반대 근거 검색, caveat 명시 |
| 코드 변경 | 파일 읽기, 최소 diff, 테스트 결과 보고 |

## 5. Tool Use

도구 지시는 제품명이 아니라 capability로 쓴다.

| Capability | 좋은 지시 |
|---|---|
| repo search | “수정 전 관련 파일/심볼을 검색하고 읽는다” |
| web/source lookup | “변동 가능 정보는 live source로 검증한다” |
| browser/visual QA | “UI 변경은 screenshot/interaction으로 확인한다” |
| shell/test | “주장에 필요한 최소 검증 명령을 실행하고 출력 읽는다” |
| subagents | “독립적이고 bounded한 조사/검증만 병렬 위임한다”; 세부는 [`parallel-workflows.ko.md`](parallel-workflows.ko.md) |

도구 개수는 별도 설정이 아니라 instruction의 일부다. Anthropic은 “기능을 지나치게 많이 덮는 비대한 도구 집합”을 가장 흔한 실패 유형으로 꼽고 판단 기준을 준다. 사람 엔지니어가 상황별로 어느 도구를 써야 하는지 확정하지 못하면 모델도 확정하지 못한다(확인 2026-11-03). 작업 중에 도구를 빼야 하면 정의를 삭제하지 말고 마스킹한다. 정의가 캐시 접두부에 놓이기 때문이다([`context-management.ko.md`](context-management.ko.md) 3절).

## 6. Long-Context Ordering

두 벤더가 같은 순서로 수렴한다. 문서를 먼저, 질문을 마지막에 둔다.

- Anthropic: “긴 문서와 입력을 프롬프트 위쪽, 질의·지시·예시보다 앞에 둔다.” 질의를 끝에 두면 “테스트에서 응답 품질이 최대 30퍼센트까지” 좋아질 수 있다고 적는다.
- Google: “큰 맥락(문서, 코드)을 줄 때는 맥락을 먼저 모두 주고, 구체적 지시나 질문은 프롬프트 맨 끝에 둔다.” 자료와 질의를 잇는 전환 문구(“위 정보를 바탕으로…”)도 함께 권한다.

규칙:

1. 자료마다 id와 출처를 붙이고, 답할 때 사용한 id를 밝히게 한다.
2. 모음이 크면 최종 답 전에 근거 추출을 먼저 시킨다. 두 번째 단계는 짧고 확인 가능한 집합을 읽는다.
3. 순서를 선택의 대체물로 쓰지 않는다. Chroma는 순서를 섞은 문서가 정연한 문서보다 좋은 점수를 냈다고 보고했다. 배치는 자료가 이미 관련성을 갖춘 뒤에만 도움이 된다.

## 7. Eval-backed Prompt Optimization

Prompt optimizer, meta-prompt, LLM-as-prompt-writer를 사용할 때도 결과를 그대로 채택하지 않는다.

1. 원본 prompt와 실패 사례를 보존한다.
2. 최적화 입력에는 task-specific dataset, 좋은/나쁜 annotation, grader 기준을 포함한다.
3. 최적화 결과는 같은 smoke eval과 edge case로 비교한다.
4. 좋아진 항목과 나빠진 항목을 둘 다 기록한다.
5. production 또는 shared instruction에는 수동 리뷰 후 반영한다.

## 8. Prompt Diffing

Instruction 변경은 코드처럼 diff와 regression risk를 본다.

- 무엇을 더 명시했는가?
- 어떤 런타임에서만 맞는 말인가?
- 기존 workflow를 깨는 금지/필수 변경인가?
- eval case에서 좋아졌는가?

## Sources

> 출처 확인 2026-11-03.

| 주장 | 출처 | 발행·갱신 |
|---|---|---|
| reasoning 모델에 chain-of-thought 지시를 피한다. “think step by step”은 성능을 해칠 수 있다 | <https://developers.openai.com/api/docs/guides/reasoning-best-practices> | 날짜 표기 없음, 2026-11-03 확인 |
| 지속성·“행동 우선” 지침, 간결성의 주된 수단은 `text.verbosity` | <https://developers.openai.com/api/docs/guides/latest-model> | 날짜 표기 없음, 2026-11-03 확인 |
| 긴 문서를 먼저, 질의를 끝에. 최대 30퍼센트 개선 | <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices> | 날짜 표기 없음, 2026-11-03 확인 |
| 맥락 먼저, 지시 마지막, 전환 문구 | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/prompts/prompt-design-strategies?hl=en> | 2026-10-30 갱신 |
| 섞은 문서가 정연한 문서보다 낫다. 순서보다 선택이 먼저다 | <https://www.trychroma.com/research/context-rot> | 2025-07-14 |
