# 프로바이더 캐시 사실

> 영어판: [`provider-cache-facts.md`](provider-cache-facts.md)

**목적**: 캐싱 계약이 의존하는 수치, 즉 최소 캐시 길이, 수명, 쓰기·읽기 가격, 캐시 가능한 블록 종류를 보관해, 벤더가 수치를 바꿔도 계약 자체는 안정적으로 유지한다.

**정책**: 아래 각 행을 분기마다 재확인하고 [`../CACHE.ko.md`](../CACHE.ko.md)를 고치는 대신 날짜를 갱신한다. 이 분기 주기는 이 프로젝트의 검토 정책이며, 벤더 조건이 그 주기로 바뀐다는 주장이 아니다.

---

## 1. Anthropic

출처: <https://platform.claude.com/docs/en/build-with-claude/prompt-caching> (확인 2026-11-03)

| 항목 | 값 |
|---|---|
| 활성화 | 최상위 `cache_control` 필드 하나를 쓰는 "automatic caching", 또는 개별 콘텐츠 블록에 `cache_control`을 두는 "explicit cache breakpoints". 캐시 타입은 `ephemeral` 하나뿐이다 |
| automatic caching | 캐시 지점을 마지막 캐시 가능 블록에 적용하고 대화가 자라면서 앞으로 옮긴다. 캐시 지점 4개 중 하나를 쓴다. 이미 명시적 지점이 4개면 요청이 400을 반환한다. 마지막 블록이 대상이 아니면 뒤에서 가장 가까운 적격 블록까지 조용히 물러난다. Opus 4.6 이하용 레거시 Amazon Bedrock 연동에서는 쓸 수 없다 |
| 캐시 지점 한도 | 요청당 4개. 캐시 지점 자체에는 비용이 붙지 않는다 |
| TTL | 기본 5분, `"ttl": "1h"`로 1시간. 수명은 항목을 쓴 요청의 시작 시점부터 재므로 생성 시간도 수명에 포함된다. 5분 항목은 사용할 때마다 추가 비용 없이 갱신된다 |
| 쓰기 비용 | 5분 항목은 기본 입력 가격의 1.25배, 1시간 항목은 2배. 한 요청에 TTL을 섞으면 수명이 긴 항목이 짧은 항목보다 앞에 와야 한다 |
| 읽기 비용 | 기본 입력 가격의 0.1배. Claude Fable 5.1과 Claude Mythos 5.1은 0.025배, Claude Opus 5.5와 Claude Sonnet 5.5는 0.05배다 |
| 최소 캐시 길이 | Claude Fable 5.1, Mythos 5.1, Opus 5.5, Opus 5, Sonnet 5.5, Fable 5, Mythos 5, Haiku 5.5는 512 토큰. Opus 4.8, Sonnet 5, Sonnet 4.6, Sonnet 4.5, Opus 4.1, Opus 4, Sonnet 4는 1,024. Mythos Preview, Opus 4.7, Haiku 3.5는 2,048. Opus 4.6, Opus 4.5, Haiku 4.5는 4,096. 더 짧은 프롬프트는 오류 없이 캐시하지 않고 처리된다 |
| 되짚기(lookback) | 캐시 지점마다 최대 20개 위치를 뒤로 확인해 앞선 요청이 쓴 항목을 찾는다. 캐시 지점이 첫 위치다. 연속한 `tool_use` 블록 묶음과 연속한 `tool_result` 블록 묶음은 각각 한 위치로 센다 |
| 격리 | 조직 간에 격리된다. Claude API, Claude Platform on AWS, Microsoft Foundry에서는 조직 안의 워크스페이스 간에도 격리된다. Bedrock과 Claude Models on Google Cloud(Google 관리)는 조직 단위로만 격리한다 |
| 동시 요청 | 첫 응답이 시작된 뒤에야 항목을 읽을 수 있다 |

**캐시 가능**: `tools`의 도구 정의, `system`의 콘텐츠 블록, 양쪽 역할의 `messages.content` 텍스트 블록, 사용자 턴의 이미지와 문서, 양쪽 역할의 도구 사용과 도구 결과.

**직접 캐시 불가**: thinking 블록(이전 assistant 턴에 있으면 다른 내용과 함께 캐시될 수 있고, 그때는 캐시에서 읽을 때 입력 토큰으로 계산된다), citation 같은 하위 콘텐츠 블록(상위 블록을 캐시한다), 빈 텍스트 블록.

**관측**: `usage.cache_read_input_tokens`(읽기), `usage.cache_creation_input_tokens`(쓰기, 중첩된 `cache_creation` 내역의 합), `usage.input_tokens`(마지막 캐시 지점 **뒤**의 토큰만). 중첩된 `cache_creation.ephemeral_5m_input_tokens`와 `ephemeral_1h_input_tokens`가 쓰기를 TTL별로 나눈다.

**접두부를 유지하는 덧붙이기**: `max_tokens: 0`은 출력 없이 캐시를 쓰므로 접두부를 미리 데울 수 있다. thinking 설정과 `output_config.effort`는 프롬프트에 렌더링되므로 실제 요청과 같아야 한다. Claude 5.x 모델에서는 `messages`에 `{"role": "system"}` 메시지를 덧붙이면 시스템·메시지 캐시를 무효화하지 않고 지시를 더할 수 있고(Claude Sonnet 5는 불가), `inline-tools-2026-09-15` 베타는 `tools`를 고치지 않고 대화 중간에 도구를 추가한다.

**레이트 리밋**: 페이지는 캐시 적중이 레이트 리밋에서 차감되지 않는다고 적으면서, 동시에 보고되는 토큰 내역이 레이트 리밋 계산을 좌우한다고 적는다. 레이트 리밋 영향은 계획 상수가 아니라 프로바이더 쪽 동작으로 보고 측정한다.

---

## 2. OpenAI

출처: <https://developers.openai.com/api/docs/guides/prompt-caching> (확인 2026-11-03)

| 항목 | 값 |
|---|---|
| 활성화 | 지원 모델에서 기본으로 켜져 있다. GPT-5.6 이후는 암시적·명시적 캐싱을 모두 지원하고, 이전 모델은 암시적 캐싱만 지원한다 |
| 배치 제어(GPT-5.6 이후) | `prompt_cache_options.mode: "explicit"`는 개발자가 표시한 지점에만 캐시를 쓴다. 지점은 콘텐츠 블록에 `prompt_cache_breakpoint`를 붙여 표시한다. explicit-only 모드에서는 마지막 지점 뒤 내용이 쓰기 요금 없이 비캐시 입력 요율로 과금된다. 암시적 모드는 마지막 적격 메시지 끝에 지점을 둔다. 요청당 캐시 쓰기는 최대 4개다 |
| 최소 캐시 길이 | GPT-5.6 이후는 보이는 입력 토큰 1,024개. 이전 모델은 도구, 이미지, 출력 스키마, 추론 노력도, 상세도 같은 요청 설정에 따라 달라진다. 프로바이더의 숨은 시스템 내용 토큰은 포함되지 않는다 |
| 쓰기 비용 | 기본 30분 수명에 비캐시 입력 요율의 1.25배, Responses API의 12시간 수명에 2.5배. 이전 모델은 별도 쓰기 요금이 없다 |
| 읽기 비용 | 비캐시 입력 요율의 0.1배, GPT-6.1 Sol과 GPT-6.1 Terra는 0.05배. 같은 페이지 첫머리는 캐시 입력 할인 폭을 최대 95%로 적는다 |
| 수명 | `prompt_cache_options.ttl`은 `"30m"`(기본) 또는 `"12h"`다. 30분 읽기는 읽은 시점부터 최소 30분으로 적용 범위를 갱신하며 12시간 시계를 다시 시작하지는 않는다. 이전 모델은 `prompt_cache_retention`을 쓴다. `in_memory`는 보통 5~10분 비활동 뒤 만료되고 최대 1시간까지 유지되며, `24h`는 보통 30분가량 유지되고 최대 24시간까지 남는다. 기본값은 Zero Data Retention을 쓰지 않는 조직이 `24h`, 쓰는 조직이 `in_memory`이며 둘 다 지원하는 모델에 적용된다. `GPT-5.5`와 `GPT-5.5 Pro`는 `24h`만 지원한다 |
| 라우팅 | 캐시 상태는 개별 장비에 있다. 분당 15건을 넘는 트래픽은 넘침 라우팅으로 갈 수 있다. GPT-5.6 이후는 자동 라우팅이다. 그 이전에는 안정된 `prompt_cache_key`가 관련 요청을 같은 캐시로 보내며, 붐비는 그룹은 키당 분당 15건가량을 목표로 한다. 키는 라우팅에 영향을 줄 뿐 적중을 보장하지 않는다 |
| 관측 | `usage.input_tokens_details.cached_tokens`와 `.cache_write_tokens`. GPT-5.6 이후는 `.cache_write_tokens_details.ttl_30m_tokens`와 `.ttl_12h_tokens`가 쓰기를 수명별로 나눈다. 이전 모델은 캐시 토큰을 128의 배수로 내림한다 |
| 미리 데우기 | `prompt_cache_options.prewarm: true`는 출력 없이 캐시를 준비한다. 쓴 토큰은 선택한 수명의 쓰기 요율로 과금된다 |

**세션 재사용은 캐시 보장이 아니다.** Agents API 호출은 Responses API와 같은 프롬프트 캐싱 동작을 쓴다. 세션 안에서 context를 재사용하면 공유 접두부가 유지될 수 있지만, 세션을 유지한다고 적중이 보장되지는 않는다.

**접두부를 다시 쓰게 하는 설정**: `model`, `tools`, `parallel_tool_calls`, `text.format`, `reasoning.effort`, `text.verbosity`, `context_management`(compaction)는 각각 렌더링되는 내용을 바꿀 수 있다. GPT-6 이후에서는 `configuration_update` 입력 항목을 덧붙이면 앞선 접두부를 다시 쓰지 않고 응답 사이에 추론 노력도를 바꿀 수 있다.

---

## 3. Google

출처: [Context caching, generateContent API](https://aistudio.google.com/docs/caching?generate-content=true)와 [암시적 캐싱, Interactions API](https://aistudio.google.com/docs/caching). 두 페이지 모두 "Last updated 2026-10-23"을 표시하며 확인일은 2026-11-03이다. `usage_metadata` 필드 이름은 같은 날 [GenerateContent API 참조](https://aistudio.google.com/api-reference/generate-content)에서 확인했다. 이 페이지들은 `ai.google.dev`에서 `aistudio.google.com`으로 옮겨졌고(2026-11-04에 301 리다이렉트 확인), 아래 암시적 캐싱 사실은 그날 새 주소에서 다시 읽었다.

| 항목 | 값 |
|---|---|
| 두 가지 기제 | Gemini 2.5 이후 기본으로 켜지고 비용 절감을 보장하지 않는 **암시적 캐싱**, Gemini 3와 2.5 모델에서 수동으로 켜고 비용 절감을 보장하는 **명시적 캐싱** |
| 어느 API와 모델인가 | 명시적 캐싱은 `v1beta`의 Beta이며 generateContent API에만 문서화되어 있다. 이 페이지는 제공되는 제목에 "(Legacy)" 표시가 붙고 Interactions API 페이지는 "Recommended"로 표시된다. 명시적 캐싱은 **Gemini 4 Argon 이후에서 지원하지 않고** 암시적 캐싱을 쓴다. Interactions API는 암시적 캐싱만 지원한다 |
| 암시적 캐싱 최소 입력 | Gemini 4 Argon, Gemini 3.8 Flash, Gemini 3.6 Flash, Gemini 3.1 Pro Preview는 4,096 토큰. Gemini 2.5 Flash와 Gemini 2.5 Pro는 2,048 토큰. 이 저장소가 2026-09-19에 인용한 판에는 Gemini 3.7 Flash와 3.5 Flash도 있었으나 지금은 두 행이 사라졌다 |
| Gemini 4 다중 턴 동작 | 새 요청이 2,050 토큰 이상을 더할 때만 직전 요청 전체를 캐시한다. 모델 출력, 사고, 함수 결과가 모두 이 합에 들어간다. 그보다 적게 더하면 직전 요청의 마지막 2,050 토큰을 표준 입력 요율로 다시 처리한다 |
| TTL | 설정하지 않으면 1시간이 기본이고 문서화된 최소·최대 한도가 없다. 기존 캐시에서는 TTL이나 만료 시점만 바꿀 수 있다 |
| 과금 | 캐시된 입력 토큰에 할인된 요율, TTL 동안 캐시한 토큰 수에 대한 보관 요금, 그리고 캐시되지 않은 입력과 출력에 대한 정상 요금 |
| 한도 | 캐싱 전용 레이트·사용 한도는 없다. 표준 `GenerateContent` 한도가 적용되고 토큰 한도에는 캐시된 토큰도 포함된다. 최소 캐시 입력은 모델마다 다르고 최대값은 해당 모델의 최대값과 같다 |
| 관측 | Interactions API는 `usage.total_cached_tokens`, generateContent는 `usage_metadata`이며 REST 하위 필드가 `cachedContentTokenCount`다 |

같은 페이지가 작성 방식에 영향을 주는 적중률 실천 두 가지를 문서화한다. 크거나 공통인 내용을 프롬프트 **맨 앞**에 두고, 접두부를 공유하는 요청을 **시간상 가까이** 보낸다.

> 읽기 주의: 2026-11-03 기준으로 두 페이지 모두 일반 `GET`에 200을 반환하고 markdown 판을 제공했다. 일반 `GET`이 인증 흐름으로 리다이렉트된다는 이전 경고는 더 이상 성립하지 않는다.

---

## 4. Amazon Bedrock(같은 모델 앞단의 게이트웨이)

출처: <https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html> (확인 2026-11-04)

| 항목 | 값 |
|---|---|
| 방식 | **암시적** 캐싱은 스스로 재사용을 시도하며 최선 노력 방식이다. **명시적** 캐싱은 모델별 캐시 제어로 접두부 경계를 표시한다 |
| 최소 길이 | 캐시 체크포인트당 최소 토큰은 모델에 따라 현재 512~4,096개이며, 각 체크포인트 앞의 접두부 전체에 누적 적용된다. 최소값에 못 미치는 체크포인트는 요청을 실패시키지 않고 그 접두부를 캐시하지 않는다 |
| 캐시 지점 | 지원 표에 있는 Claude 모델은 요청당 캐시 체크포인트나 쓰기를 최대 4개 둘 수 있다 |
| TTL | 모델에 따라 5분 또는 1시간이며, 현재 Claude 행은 5분과 1시간을 모두 나열하고 Amazon Nova 행은 5분만 나열한다. TTL은 캐시 적중이 성공할 때마다 다시 시작한다. Converse API에서는 `cachePoint` 객체에, Claude용 InvokeModel에서는 `cache_control`에 `"ttl": "1h"`를 넣는다. 5분만 지원하는 모델에 `ttl`을 보내면 `ValidationException`이 날 수 있다 |
| 과금 | 캐시에서 읽은 토큰은 모델의 캐시 읽기 요율, 캐시되지 않은 입력은 표준 요율로 과금되며, 쓰기는 모델에 따라 표준 입력 요율보다 비쌀 수 있다 |
| 관측 | `cacheReadInputTokens`, `cacheWriteInputTokens`, `cacheDetails`(쓴 토큰의 TTL). 캐싱이 켜지면 `inputTokens`는 캐시에서 읽지도 쓰지도 않은 토큰만 가리키므로 전체 입력은 `inputTokens + cacheReadInputTokens + cacheWriteInputTokens`다 |
| 모델 범위 | Claude 모델은 명시적 캐싱만 지원하며 캐시 제어가 없는 요청은 캐싱되지 않는다. Nova 모델은 모든 텍스트 프롬프트에 암시적 캐싱을 제공하고, 문서에 실린 OpenAI 모델은 암시적 캐싱을 지원하며 GPT-5.6 이후 모델은 명시적 캐싱도 지원한다. 이들의 TTL은 30분이고 쓰기는 1.25배로 과금된다. 콘텐츠 블록 약 20개 되짚기는 Claude의 캐시 지점에 적용된다 |

Bedrock 문서도 이 저장소의 계약이 이미 따르는 운용 규칙을 그대로 적는다. 정적인 내용은 프롬프트 앞에, 동적인 내용은 뒤에 둔다. 또한 지원 모델이라도 적중이 보장되지는 않는다고 적으므로, 재사용을 추론하지 말고 usage 필드를 읽는다.

---

## 5. 프로바이더 비교

| 질문 | Anthropic | OpenAI | Google |
|---|---|---|---|
| 캐시 단위 | 캐시 지점까지의 렌더링된 접두부 | 캐시 지점까지의 렌더링된 접두부 | 암시적 캐싱은 접두부, 명시적 캐싱은 참조하는 캐시 객체 |
| 최소 길이 | 모델별 512~4,096 | 현재 모델은 보이는 토큰 1,024 | 모델별 2,048 또는 4,096 |
| 쓰기 비용 | 1.25배(5분), 2배(1시간) | 1.25배(30분), 2.5배(12시간) | TTL에 따른 보관 요금과 캐시 토큰 요율 |
| 읽기 비용 | 0.1배, 예외 0.025배·0.05배 | 0.1배, 두 모델은 0.05배 | 할인된 캐시 토큰 요율 |
| 기본 수명 | 5분, 사용할 때마다 갱신 | GPT-5.6 이후는 30분. 둘 다 지원하는 이전 모델은 Zero Data Retention을 쓰지 않으면 `24h` 보존이, 쓰면 `in_memory`가 기본이다(`GPT-5.5`와 `GPT-5.5 Pro`는 `24h`만 지원) | 1시간 |
| 캐시 지점 제어 | 최대 4개, 자동 또는 명시 | 쓰기 최대 4개, GPT-5.6 이후는 암시 또는 명시 | 명시적 캐시 객체만 |
| 미리 데우기 | `max_tokens: 0` | `prewarm: true` | 캐시 객체를 먼저 만든다 |

Anthropic과 OpenAI에서 캐시 쓰기는 공짜가 아니다. 현재 모델에서는 접두부를 한 번 쓰고 한 번 읽는 비용이 캐시 없이 한 번 처리하는 비용보다 크고(두 곳 모두 기본 TTL에서 1.25배 + 0.1배), 그래서 재사용은 두 번째 읽기부터 이득이다. 계약이 가정 대신 측정을 요구하는 이유가 여기에 있다. Google은 쓰기 배수가 없고, 캐시된 입력에 할인 요율을 적용하는 한편 TTL 동안 보관 요금을 받는다.

---

## 6. 이 파일을 쓰는 방법

- 여기 있는 수치는 [`../CACHE.ko.md`](../CACHE.ko.md)의 규칙을 뒷받침하는 근거다. 모든 런타임이나 프로바이더 앞단의 게이트웨이에 대한 주장이 아니다. 프록시는 캐시를 끄거나, 줄이거나, 키를 바꿀 수 있다.
- 벤더가 임계값이나 가격을 바꾸면 그 행과 확인일을 갱신한다. 계약에 수치를 다시 적지 않는다.
- 재확인하지 못한 행은 날짜를 갱신하지 않고 그대로 둔다. 오래된 날짜는 정직하지만, 읽지 않은 자료에 새 날짜를 붙이는 것은 정직하지 않다.

## 함께 읽을 문서

- [`../CACHE.ko.md`](../CACHE.ko.md)
- [`../../sourcing/reliable-search.ko.md`](../../sourcing/reliable-search.ko.md)
