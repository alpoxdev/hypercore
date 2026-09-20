# Provider Cache Facts

> Korean version: [`provider-cache-facts.ko.md`](provider-cache-facts.ko.md)

**Purpose**: hold the numbers that the caching contract depends on — minimum cacheable length, TTL, write and read pricing, cacheable block types — so the contract itself stays stable when a vendor changes them.

**Policy**: re-verify every row below each quarter and update its date instead of editing [`../CACHE.md`](../CACHE.md). The quarterly cadence is this project's review policy, not a vendor statement about how often their terms change.

---

## 1. Anthropic

Source: <https://platform.claude.com/docs/en/build-with-claude/prompt-caching> (checked 2026-09-19)

| Fact | Value |
|---|---|
| Enabling | Two documented ways: a single top-level `cache_control` field ("automatic caching"), or `cache_control` placed on individual content blocks ("explicit cache breakpoints") |
| Automatic caching | Applies the breakpoint to the last cacheable block and moves it forward as the conversation grows — the documented fit for multi-turn conversations |
| TTL | 5-minute and 1-hour variants |

**Cacheable**: tool definitions in the `tools` array, content blocks in the `system` array, text blocks in `messages.content` for both roles, images and documents in user turns, and tool use and tool results.

**Not directly cacheable**: thinking blocks. They can still be cached alongside other content when they appear in previous assistant turns.

**Minimum cacheable prompt length** varies by model, from 512 tokens for the newest models up to 4,096 tokens for others. Check the model's row before assuming a short prompt caches.

---

## 2. OpenAI

Source: <https://developers.openai.com/api/docs/guides/prompt-caching> (checked 2026-09-19)

| Fact | Value |
|---|---|
| Enabling | Enabled by default for supported models |
| Minimum cacheable prompt length | 1,024 tokens for GPT-5.6 and later; varies by request settings for earlier models. Tokens in the provider's hidden system content do not count toward it |
| Write cost (GPT-5.6 and later) | 1.25× the standard uncached input rate |
| Read cost (GPT-5.6 and later) | 0.1× the standard input rate — the documented discount is up to 90% |
| Routing | On GPT-5.6 and later the provider routes automatically. Before that, a stable `prompt_cache_key` helps route related requests to the same cache; it influences routing and does not guarantee a hit |
| Observation | A prompt-caching dashboard and a prompt-cache diagnostics tool are documented for hit rates and miss diagnosis |

**Session reuse is not a cache guarantee.** The Agents API uses the same prompt-caching behavior as the Responses API: reusing context within a session can preserve a shared prefix, but maintaining a session does not guarantee a hit.

---

## 3. Google

Sources: [Context caching — generateContent API](https://ai.google.dev/gemini-api/docs/generate-content/caching) (page footer: last updated 2026-09-11) and its [Interactions API variant](https://ai.google.dev/gemini-api/docs/caching) (page footer: last updated 2026-09-02); both checked 2026-09-19.

| Fact | Value |
|---|---|
| Two mechanisms | **Implicit caching**, enabled by default on Gemini 2.5 and newer with no cost-saving guarantee, and **explicit caching**, enabled manually on most models with a cost-saving guarantee |
| Which API | Explicit caching is documented only on the generateContent API and is marked Beta under `v1beta`. The Interactions API supports implicit caching only, so which variant you land on changes the answer |
| TTL | Defaults to 1 hour when not set; no documented minimum or maximum. Only the TTL and expiry can be changed on an existing cache |
| Billing | A reduced rate on the cached token count plus a storage charge based on the TTL; non-cached input and output tokens bill normally |
| Observation | The field name differs by variant: `usage.total_cached_tokens` on the Interactions API, and `usage_metadata` on generateContent, whose REST subfield is `cachedContentTokenCount` in the API reference |

The same page documents two hit-rate practices that shape authoring: place large or common content at the **beginning** of the prompt, and send requests that share a prefix **close together in time**.

> Reading note: a plain `GET` of these pages redirects to an auth flow, so their content was read through a browser session and cross-checked with a browser-user-agent fetch. `HEAD` returns 200, so the link gate still passes.

---

## 4. How to use this file

- A number here justifies a rule in [`../CACHE.md`](../CACHE.md); it is not a claim about every runtime or gateway in front of a provider. A proxy can disable, shrink, or re-key a cache.
- When a vendor changes a threshold or price, update the row and its checked date. Do not restate the number in the contract.
- If you cannot re-verify a row, leave the old date in place rather than refreshing it. A stale date is honest; a refreshed date on unread material is not.

## Related documents

- [`../CACHE.md`](../CACHE.md)
- [`../../sourcing/reliable-search.md`](../../sourcing/reliable-search.md)
