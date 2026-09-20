# 프로바이더 캐시 사실

> 영어판: [`provider-cache-facts.md`](provider-cache-facts.md)

**목적**: 캐싱 계약이 의존하는 수치, 즉 최소 캐시 길이, TTL, 쓰기·읽기 가격, 캐시 가능한 블록 종류를 보관해, 벤더가 수치를 바꿔도 계약 자체는 안정적으로 유지한다.

**정책**: 아래 각 행을 분기마다 재확인하고 [`../CACHE.ko.md`](../CACHE.ko.md)를 고치는 대신 날짜를 갱신한다. 이 분기 주기는 이 프로젝트의 검토 정책이며, 벤더 조건이 그 주기로 바뀐다는 주장이 아니다.

---

## 1. Anthropic

출처: <https://platform.claude.com/docs/en/build-with-claude/prompt-caching> (확인 2026-09-19)

| 항목 | 값 |
|---|---|
| 활성화 | 문서화된 두 가지 방식. 최상위 `cache_control` 필드 하나를 쓰는 "automatic caching", 또는 개별 콘텐츠 블록에 `cache_control`을 두는 "explicit cache breakpoints" |
| automatic caching | 캐시 지점을 마지막 캐시 가능 블록에 적용하고 대화가 자라면서 앞으로 옮긴다. 다중 턴 대화에 맞는 방식으로 문서화되어 있다 |
| TTL | 5분과 1시간 두 가지 |

**캐시 가능**: `tools` 배열의 도구 정의, `system` 배열의 콘텐츠 블록, 양쪽 역할의 `messages.content` 텍스트 블록, 사용자 턴의 이미지와 문서, 양쪽 역할의 도구 사용과 도구 결과.

**직접 캐시 불가**: thinking 블록. 다만 이전 assistant 턴에 있는 경우 다른 내용과 함께 캐시될 수는 있다.

**최소 캐시 길이**는 모델마다 다르며 최신 모델의 512 토큰부터 다른 모델의 4,096 토큰까지 걸쳐 있다. 짧은 프롬프트가 캐시된다고 가정하기 전에 해당 모델의 행을 확인한다.

---

## 2. OpenAI

출처: <https://developers.openai.com/api/docs/guides/prompt-caching> (확인 2026-09-19)

| 항목 | 값 |
|---|---|
| 활성화 | 지원 모델에서 기본으로 켜져 있다 |
| 최소 캐시 길이 | GPT-5.6 이후 1,024 토큰. 이전 모델은 요청 설정에 따라 다르다. 프로바이더가 제공하는 숨은 시스템 내용의 토큰은 이 최소값에 포함되지 않는다 |
| 쓰기 비용(GPT-5.6 이후) | 표준 비캐시 입력 요율의 1.25배 |
| 읽기 비용(GPT-5.6 이후) | 표준 입력 요율의 0.1배. 문서화된 할인 폭은 최대 90% |
| 라우팅 | GPT-5.6 이후는 프로바이더가 자동으로 라우팅한다. 그 이전에는 안정된 `prompt_cache_key`가 관련 요청을 같은 캐시로 보내는 데 도움이 된다. 이 키는 라우팅에 영향을 줄 뿐 적중을 보장하지 않는다 |
| 관측 | 적중률 확인용 prompt caching 대시보드와 미스 진단용 prompt cache diagnostics 도구가 문서화되어 있다 |

**세션 재사용은 캐시 보장이 아니다.** Agents API는 Responses API와 같은 프롬프트 캐싱 동작을 쓴다. 세션 안에서 context를 재사용하면 공유 접두부가 유지될 수 있지만, 세션을 유지한다고 적중이 보장되지는 않는다.

---

## 3. Google

출처: [Context caching — generateContent API](https://ai.google.dev/gemini-api/docs/generate-content/caching)(페이지 footer: 2026-09-11 최종 수정)와 그 [Interactions API 변형](https://ai.google.dev/gemini-api/docs/caching)(페이지 footer: 2026-09-02 최종 수정). 둘 다 확인 2026-09-19.

| 항목 | 값 |
|---|---|
| 두 가지 기제 | Gemini 2.5 이후 기본으로 켜지고 비용 절감을 보장하지 않는 **암시적 캐싱**과, 대부분의 모델에서 수동으로 켜고 비용 절감을 보장하는 **명시적 캐싱** |
| 어느 API인가 | 명시적 캐싱은 generateContent API에만 문서화되어 있고 `v1beta`의 Beta로 표시된다. Interactions API는 암시적 캐싱만 지원하므로 어느 변형을 보는지에 따라 답이 달라진다 |
| TTL | 설정하지 않으면 1시간이 기본이며 문서화된 최소·최대 한도가 없다. 기존 캐시에서는 TTL과 만료만 바꿀 수 있다 |
| 과금 | 캐시된 토큰 수에 할인된 요율을 적용하고 TTL에 따른 보관 요금을 더한다. 캐시되지 않은 입력·출력 토큰은 정상 과금된다 |
| 관측 | 필드 이름이 변형마다 다르다. Interactions API는 `usage.total_cached_tokens`, generateContent는 `usage_metadata`이며 그 REST 하위 필드가 API reference의 `cachedContentTokenCount`다 |

같은 페이지가 작성 방식에 영향을 주는 적중률 실천 두 가지를 문서화한다. 크거나 공통인 내용을 프롬프트 **맨 앞**에 두고, 접두부를 공유하는 요청을 **시간상 가까이** 보낸다.

> 읽기 주의: 이 페이지들은 일반 `GET`이 인증 흐름으로 리다이렉트되므로 브라우저 세션으로 읽고 브라우저 user-agent fetch로 교차 확인했다. `HEAD`는 200을 반환하므로 링크 게이트는 통과한다.

---

## 4. 이 파일을 쓰는 방법

- 여기 있는 수치는 [`../CACHE.ko.md`](../CACHE.ko.md)의 규칙을 뒷받침하는 근거다. 모든 런타임이나 프로바이더 앞단의 게이트웨이에 대한 주장이 아니다. 프록시는 캐시를 끄거나, 줄이거나, 키를 바꿀 수 있다.
- 벤더가 임계값이나 가격을 바꾸면 그 행과 확인일을 갱신한다. 계약에 수치를 다시 적지 않는다.
- 재확인하지 못한 행은 날짜를 갱신하지 않고 그대로 둔다. 오래된 날짜는 정직하지만, 읽지 않은 자료에 새 날짜를 붙이는 것은 정직하지 않다.

## 함께 읽을 문서

- [`../CACHE.ko.md`](../CACHE.ko.md)
- [`../../sourcing/reliable-search.ko.md`](../../sourcing/reliable-search.ko.md)
