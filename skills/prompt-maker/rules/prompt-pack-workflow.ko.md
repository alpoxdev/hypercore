# Prompt Pack Workflow

## Draft

1. prompt가 재사용될 것인지 확인한다.
2. operator, target model 또는 agent, task class, side-effect boundary를 식별한다.
3. prose를 다듬기 전에 prompt contract를 채운다.
4. examples보다 먼저 variables와 context packet slots를 추가한다.
5. style guidance보다 먼저 output schema를 정의한다.
6. optimization claim보다 먼저 eval cases를 추가한다.

## Refactor

1. 사용자가 behavior change를 요청하지 않았다면 현재 observable behavior를 보존한다.
2. authority, scope, evidence, output requirements를 별도 section으로 나눈다.
3. 중복되거나 장식적인 wording을 삭제한다.
4. vague quality words를 success criteria와 verification checks로 바꾼다.
5. 무엇이 왜 바뀌었는지 version note에 기록한다.

## Optimize

baseline case를 기록하고, failures를 진단하고, 가장 작은 instruction surface를 patch하고, 같은 cases를 다시 실행한다. safety, source, schema constraints를 깨지 않으면서 target behavior를 개선하는 변경만 유지한다.
