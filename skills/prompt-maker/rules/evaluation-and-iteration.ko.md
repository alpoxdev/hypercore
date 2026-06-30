# Evaluation And Iteration

## Minimum Categories

JSONL prompt eval fixture를 만들 때 positive, negative, boundary, source, safety, schema, regression, adversarial cases를 포함한다.

## Anti-Tautology Rule

eval은 plausible bad prompt에서 실패할 수 있어야 한다. file existence만 확인하거나, behavior와 무관한 keyword presence를 확인하거나, implementation text를 그대로 반복하는 check는 evidence로 세지 않는다.

## Case Shape

각 case에는 non-empty id, category, prompt, `expected.must`, `expected.mustNot`가 있어야 한다. expected arrays는 observable behavior를 설명해야 한다.

## Iteration Loop

1. baseline behavior를 캡처한다.
2. 각 prompt 변경 후 같은 cases를 다시 실행한다.
3. failure를 instruction gap, context gap, schema mismatch, source-boundary issue, safety issue, model/runtime mismatch로 진단한다.
4. 가장 작은 prompt surface를 patch한다.
5. 새 failure pattern마다 regression case를 추가한다.
6. version note와 remaining risk를 기록한다.

## Stop

target cases가 pass하거나, 다음 변경이 scope를 넓히거나, 남은 failures가 missing context, different model/runtime, user authority를 필요로 하면 최적화를 멈춘다.
