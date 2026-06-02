# Techniques

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
| subagents | “독립적이고 bounded한 조사/검증만 병렬 위임한다”; 세부는 [`parallel-workflows.md`](parallel-workflows.md) |

## 6. Eval-backed Prompt Optimization

Prompt optimizer, meta-prompt, LLM-as-prompt-writer를 사용할 때도 결과를 그대로 채택하지 않는다.

1. 원본 prompt와 실패 사례를 보존한다.
2. 최적화 입력에는 task-specific dataset, 좋은/나쁜 annotation, grader 기준을 포함한다.
3. 최적화 결과는 같은 smoke eval과 edge case로 비교한다.
4. 좋아진 항목과 나빠진 항목을 둘 다 기록한다.
5. production 또는 shared instruction에는 수동 리뷰 후 반영한다.

## 7. Prompt Diffing

Instruction 변경은 코드처럼 diff와 regression risk를 본다.

- 무엇을 더 명시했는가?
- 어떤 런타임에서만 맞는 말인가?
- 기존 workflow를 깨는 금지/필수 변경인가?
- eval case에서 좋아졌는가?
