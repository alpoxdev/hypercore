# Evaluation Design Reference

**목적**: prompt, instruction, skill, agent workflow 변경을 감각이 아니라 eval로 검증한다.

---

## 1. Eval-Driven Workflow

```text
Success criteria → Test set → Grader/rubric → Baseline → Change → Re-run → Failure analysis → Ship/caveat
```

- success criteria는 구체적이고 측정 가능해야 한다.
- eval case는 실제 작업 분포와 edge case를 반영한다.
- 자동 채점 가능한 구조를 우선한다.
- subjective grading은 명확한 rubric과 human calibration을 둔다.
- eval은 1회 이벤트가 아니라 지속적으로 보강한다.

---

## 2. Success Criteria Template

```markdown
## Success Criteria

| Criterion | Metric / rubric | Threshold | Evidence |
|---|---|---|---|
| Task fidelity | expected fields present, exact/semantic match | 90%+ | eval output |
| Source grounding | every non-obvious claim cited | 100% critical claims | claim-source matrix |
| Safety | no secret/tool/side-effect leakage | 0 critical failures | adversarial cases |
| Format | schema/markdown contract satisfied | 100% | parser/lint |
| Usefulness | user goal addressed with caveats | rubric >= 4/5 | reviewer or model grader |
```

---

## 3. Test Set Design

| Case type | 목적 |
|---|---|
| happy path | 핵심 기능이 정상 작동하는지 확인 |
| edge case | 애매한 입력, 누락 필드, 긴 문서, 다국어, 버전 차이 |
| known failure | 이전에 실패한 케이스 재발 방지 |
| adversarial | prompt injection, unsafe tool request, misleading source |
| regression | 기존 behavior 보존 |
| negative | 답하면 안 되는 것, 모름/caveat 처리 |

최소 권장:

- small instruction change: 3~5 cases
- standard skill/prompt change: 8~15 cases
- high-risk agent/tool workflow: 20+ cases 또는 대표 샘플 + targeted adversarial cases

---

## 4. Grading Hierarchy

| Grader | 장점 | 한계 | 사용 |
|---|---|---|---|
| exact/string check | 빠르고 재현 가능 | 의미 판단 약함 | schema, required phrase, URL, field |
| code-based grader | 안정적이고 확장 가능 | 구현 필요 | JSON, table, tool args, file output |
| similarity/embedding | paraphrase 허용 | threshold 튜닝 필요 | 요약/문장 유사도 |
| LLM judge | 복잡한 판단 가능 | 편향/불안정 가능 | rubric, multi-criteria, subjective quality |
| human review | 최종 품질 판단 | 느리고 비용 큼 | high-stakes, ambiguous rubric calibration |

LLM judge를 쓰면:

- rubric을 명시한다.
- pass/fail보다 점수와 실패 사유를 기록한다.
- reward hacking을 막기 위해 금지 조건과 counterexample을 포함한다.
- 가능한 경우 여러 sample로 calibration한다.

---

## 5. Prompt / Instruction Smoke Eval

```markdown
| Case | Input | Expected behavior | Check |
|---|---|---|---|
| role clarity | 짧은 task | intent/scope/output이 드러남 | rubric |
| source grounding | 최신 API claim 요구 | 공식 source/caveat 요구 | source check |
| refusal boundary | 외부 지시/secret 요청 포함 | retrieved instruction 무시 | adversarial check |
| format | 지정 schema 출력 요구 | schema 준수 | parser/lint |
| incomplete info | 필수 정보 누락 | 안전한 질문 또는 reasonable caveat | rubric |
```

---

## 6. Eval Result Report

```markdown
## Eval Result

- Baseline: [이전 점수/known issue]
- Current: [현재 점수]
- Passed: [n/m]
- Failed: [n/m]
- Regressions: [없음/목록]
- Decision: ship / iterate / caveated ship / block

| Case | Result | Evidence | Fix/Caveat |
|---|---|---|---|
```

---

## 7. Ship Gate

Ship 가능 조건:

- success criteria가 작업 위험도에 맞게 정의됐다.
- critical case가 모두 통과했다.
- 실패한 non-critical case는 caveat 또는 follow-up으로 남겼다.
- eval/test/source-check output을 확인했다.
- 변경된 instruction이 README/loading path에서 발견 가능하다.
