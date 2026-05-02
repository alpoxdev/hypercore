# Node Pack

병목이 Node 런타임 지연, CPU 작업, 메모리 사용, CLI 처리량, 백그라운드 작업 동작에 있을 때 이 팩을 사용한다.

## 권장 프롬프트

1. `이 Node hot path를 프로파일링하고 점수 오르는 최적화만 남겨줘.`
2. `수정 전에 작업 실행 시간, CPU 비용, 회귀 검사를 벤치마크해줘.`
3. `이 Node 병목을 측정 가능한 반복 실험으로 개선하고 현재 동작을 유지해줘.`

## 권장 Proof Command

- benchmark script
- 타겟 테스트 스위트
- profiler 또는 flame graph 명령
- CLI smoke 명령

## 권장 이진 Eval

- 선택한 proof set이 Node 또는 CLI 병목에 적절한가?
- 실행이 hot path의 출력 정확성과 오류 처리를 유지하는가?
- duration, CPU, memory, allocation 같은 구체적 런타임 지표를 추적하는가?
- 아티팩트가 소유 모듈 또는 명령 범위를 분명히 기록하는가?
- 반복된 무회귀 점검 없이 성공을 주장하지 않는가?
