# API Pack

병목이 엔드포인트 지연 시간, query 수, payload 크기, 캐시 동작, 요청 경로 신뢰성에 있을 때 이 팩을 사용한다.

## 권장 프롬프트

1. `이 엔드포인트의 지연 시간과 query 수를 측정 가능한 반복 실험으로 줄여줘.`
2. `수정 전에 요청 경로, 회귀 안전성, 자원 비용을 벤치마크해줘.`
3. `이 API 병목을 개선하고 점수 오르는 변경만 남겨줘.`

## 권장 Proof Command

- endpoint benchmark 또는 load test
- integration test
- query logging 또는 request tracing
- 사용자 가시 정확성을 확인하는 smoke request

## 권장 이진 Eval

- 선택한 proof set이 API 병목에 적절한가?
- 실행이 요청 정확성, 인증, 오류 처리를 유지하는가?
- p95 latency, query 수, cache hit rate, payload 크기 같은 구체적 API 지표를 추적하는가?
- 아티팩트가 소유 엔드포인트 또는 서비스 범위를 분명히 기록하는가?
- 반복된 무회귀 점검 없이 성공을 주장하지 않는가?
