# Provider Cache Facts

> Korean version: [`provider-cache-facts.ko.md`](provider-cache-facts.ko.md)

**Purpose**: hold the numbers that the caching contract depends on (minimum cacheable length, lifetime, write and read pricing, cacheable block types) so the contract itself stays stable when a vendor changes them.

**Policy**: re-verify every row each quarter and update its date instead of editing [`../CACHE.md`](../CACHE.md). The quarterly cadence is this project's review policy, not a vendor statement about how often their terms change.

---

## 1. Anthropic

Source: <https://platform.claude.com/docs/en/build-with-claude/prompt-caching> (checked 2026-11-03)

| Fact | Value |
|---|---|
| Enabling | A single top-level `cache_control` field ("automatic caching"), or `cache_control` on individual content blocks ("explicit cache breakpoints"). `ephemeral` is the only cache type |
| Automatic caching | The breakpoint is applied to the last cacheable block and moves forward as the conversation grows. It uses one of the 4 breakpoint slots; if 4 explicit breakpoints already exist the request returns a 400. If the last block is ineligible, the system walks backward to the nearest eligible block. Not available on the legacy Amazon Bedrock integration for Opus 4.6 and earlier |
| Breakpoint limit | 4 cache breakpoints per request. Breakpoints themselves add no cost |
| TTL | 5 minutes by default, 1 hour with `"ttl": "1h"`. The lifetime is measured from the start of the request that wrote the entry, so generation time counts against it. A 5-minute entry is refreshed at no additional cost each time it is used |
| Write cost | 1.25× the base input price for a 5-minute entry; 2× for a 1-hour entry. When TTLs are mixed in one request, a longer-TTL entry must appear before any shorter-TTL entry |
| Read cost | 0.1× the base input price; 0.025× on Claude Fable 5.1 and Claude Mythos 5.1, 0.05× on Claude Opus 5.5 and Claude Sonnet 5.5 |
| Minimum cacheable length | 512 tokens for Claude Fable 5.1, Mythos 5.1, Opus 5.5, Opus 5, Sonnet 5.5, Fable 5, Mythos 5, Haiku 5.5. 1,024 for Opus 4.8, Sonnet 5, Sonnet 4.6, Sonnet 4.5, Opus 4.1, Opus 4, Sonnet 4. 2,048 for Mythos Preview, Opus 4.7, Haiku 3.5. 4,096 for Opus 4.6, Opus 4.5, Haiku 4.5. A shorter prompt is processed without caching and returns no error |
| Lookback | Each breakpoint checks at most 20 positions backward for an entry an earlier request wrote, counting the breakpoint as the first. A run of consecutive `tool_use` blocks, or of consecutive `tool_result` blocks, counts as one position |
| Isolation | Between organizations; additionally between workspaces on the Claude API, Claude Platform on AWS, and Microsoft Foundry. Bedrock and Claude Models on Google Cloud (Google managed) isolate at the organization level only |
| Concurrent requests | An entry becomes readable only after the first response starts |

**Cacheable**: tool definitions in `tools`, content blocks in `system`, text blocks in `messages.content` for both roles, images and documents in user turns, and tool use and tool results in both roles.

**Not directly cacheable**: thinking blocks (they can still be cached alongside other content in earlier assistant turns, and then count as input tokens when read), sub-content blocks such as citations (cache the top-level block instead), and empty text blocks.

**Observation**: `usage.cache_read_input_tokens` (reads), `usage.cache_creation_input_tokens` (writes, equal to the sum of the nested `cache_creation` breakdown), and `usage.input_tokens`, which counts only tokens **after** the last breakpoint. The nested `cache_creation.ephemeral_5m_input_tokens` and `ephemeral_1h_input_tokens` split writes by TTL.

**Append-only updates that keep the prefix**: `max_tokens: 0` writes the cache and returns without output, so a prefix can be pre-warmed; the thinking configuration and `output_config.effort` must match the real requests because both render into the prompt. On Claude 5.x models a `{"role": "system"}` message appended to `messages` carries new instructions without invalidating the system or message caches (not available on Claude Sonnet 5), and the `inline-tools-2026-09-15` beta adds a tool mid-conversation without editing `tools`.

**Rate limits**: the page states that cache hits are not deducted against the rate limit, while also noting that the reported token breakdown drives rate-limit accounting. Treat rate-limit effects as provider-side behavior to measure, not as a planning constant.

---

## 2. OpenAI

Source: <https://developers.openai.com/api/docs/guides/prompt-caching> (checked 2026-11-03)

| Fact | Value |
|---|---|
| Enabling | Enabled by default for supported models. GPT-5.6 and later support both implicit and explicit caching; earlier models support implicit caching only |
| Placement control (GPT-5.6 and later) | `prompt_cache_options.mode: "explicit"` restricts caching to developer-marked breakpoints made with `prompt_cache_breakpoint` on a content block. Explicit-only mode lets content after the last breakpoint be billed at the uncached input rate with no write charge. Implicit mode places a breakpoint at the end of the latest eligible message. Up to 4 cache writes per request |
| Minimum cacheable prompt length | 1,024 visible input tokens for GPT-5.6 and later. For earlier models it varies with request settings such as tools, images, output schemas, reasoning effort, and verbosity. Tokens in the provider's hidden system content do not count |
| Write cost | 1.25× the uncached input rate for the default 30-minute lifetime; 2.5× for the 12-hour lifetime in the Responses API. Earlier models add no separate write charge |
| Read cost | 0.1× the uncached input rate; 0.05× on GPT-6.1 Sol and GPT-6.1 Terra. The same page states cached input is discounted up to 95% |
| Lifetime | `prompt_cache_options.ttl` is `"30m"` (default) or `"12h"`. A 30-minute read refreshes coverage to at least 30 minutes after the read; it does not restart a 12-hour clock. Earlier models use `prompt_cache_retention`: `in_memory` (typically 5–10 minutes of inactivity, up to 1 hour) or `24h` (typically around 30 minutes, retained up to 24 hours). Organizations without Zero Data Retention default to `24h`; organizations with it default to `in_memory` for models that support both, while `GPT-5.5` and `GPT-5.5 Pro` support `24h` only |
| Routing | Cached states live on individual machines; traffic above 15 requests per minute can cause overflow routing. GPT-5.6 and later route automatically. Before that, a stable `prompt_cache_key` routes related requests to the same cache, with about 15 requests per minute per key for busy groups. A key influences routing and does not guarantee a hit |
| Observation | `usage.input_tokens_details.cached_tokens` and `.cache_write_tokens`; on GPT-5.6 and later, `.cache_write_tokens_details.ttl_30m_tokens` and `.ttl_12h_tokens` split writes by lifetime. Earlier models round cached tokens down to a multiple of 128 |
| Prewarm | `prompt_cache_options.prewarm: true` prepares the cache without generating output; the written tokens bill at the write rate for the chosen lifetime |

**Session reuse is not a cache guarantee.** Agents API calls use the same prompt-caching behavior as the Responses API; reusing context within a session can preserve a shared prefix, but maintaining a session does not guarantee a hit.

**Settings that rewrite the prefix**: `model`, `tools`, `parallel_tool_calls`, `text.format`, `reasoning.effort`, `text.verbosity`, and `context_management` (compaction) can each change rendered content. On GPT-6 and later, appending a `configuration_update` input item changes reasoning effort between responses without rewriting the earlier prefix.

---

## 3. Google

Sources: [Context caching, generateContent API](https://aistudio.google.com/docs/caching?generate-content=true) and [implicit caching, Interactions API](https://aistudio.google.com/docs/caching); both pages state "Last updated 2026-10-23" and were checked 2026-11-03. The `usage_metadata` field name was confirmed in the [GenerateContent API reference](https://aistudio.google.com/api-reference/generate-content) on the same date. The pages moved from `ai.google.dev` to `aistudio.google.com` (301 redirects observed 2026-11-04); the implicit-caching facts below were re-read at the new address that day.

| Fact | Value |
|---|---|
| Two mechanisms | **Implicit caching**, enabled by default on Gemini 2.5 and newer with no cost-saving guarantee, and **explicit caching**, manually enabled on Gemini 3 and 2.5 models with a cost-saving guarantee |
| Which API and model | Explicit caching is Beta under `v1beta` and is documented on the generateContent API only, a page whose served title carries a "(Legacy)" label while the Interactions API page is marked "Recommended". Explicit caching is **not supported on Gemini 4 Argon and later**, which use implicit caching. The Interactions API supports implicit caching only |
| Minimum input for implicit caching | 4,096 tokens for Gemini 4 Argon, Gemini 3.8 Flash, Gemini 3.6 Flash, and Gemini 3.1 Pro Preview; 2,048 for Gemini 2.5 Flash and Gemini 2.5 Pro. The page also listed Gemini 3.7 Flash and 3.5 Flash when this repository cited it on 2026-09-19; both rows are gone now |
| Gemini 4 multi-turn behavior | The full previous request is cached only if the new request adds at least 2,050 tokens, counting model output, thoughts, and function results. Smaller additions re-process the last 2,050 tokens of the previous request at the standard input rate |
| TTL | Defaults to 1 hour when not set; no documented minimum or maximum bound. Only the TTL or expiry of an existing cache can be changed |
| Billing | A reduced rate on cached input tokens, a storage charge for the cached token count over the TTL, and normal charges for uncached input and output |
| Limits | No special rate or usage limits for caching; the standard `GenerateContent` limits apply and token limits include cached tokens. The minimum cacheable input varies by model and the maximum matches the model's maximum |
| Observation | `usage.total_cached_tokens` on the Interactions API; `usage_metadata` on generateContent, whose REST subfield is `cachedContentTokenCount` |

The same pages document two hit-rate practices that shape authoring: place large or common content at the **beginning** of the prompt, and send requests that share a prefix **close together in time**.

> Reading note: on 2026-11-03 both pages returned HTTP 200 to a plain `GET` and exposed a markdown rendition, so the earlier warning that a plain `GET` redirects into an auth flow no longer holds.

---

## 4. Amazon Bedrock (a gateway in front of the same models)

Source: <https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html> (checked 2026-11-03)

| Fact | Value |
|---|---|
| Modes | **Implicit** caching attempts reuse on its own and is best effort. **Explicit** caching marks prefix boundaries with model-specific cache controls |
| Minimum length | Minimums currently range from 512 to 4,096 tokens per cache checkpoint, depending on the model, and apply cumulatively to the entire prefix before each checkpoint. A checkpoint under the minimum does not fail the request; the prefix is simply not cached |
| Breakpoints | Up to 4 cache checkpoints or writes per request on the Claude models in the support table |
| TTL | 5 minutes or 1 hour, model dependent; Claude 3.7 Sonnet and Claude 3.5 Sonnet v2 support 5 minutes only. The TTL resets with each successful cache hit. Set `"ttl": "1h"` in the `cachePoint` object on the Converse API, or in `cache_control` on InvokeModel for Claude. Sending `ttl` to a model that supports only 5 minutes can return a `ValidationException` |
| Billing | Cached reads bill at the model's cache-read rate, uncached input at the standard rate, and writes may bill above the standard input rate depending on the model |
| Observation | `cacheReadInputTokens`, `cacheWriteInputTokens`, and `cacheDetails` (the TTL of the written tokens). When caching is on, `inputTokens` covers only tokens that were neither read from nor written to the cache, so total input is `inputTokens + cacheReadInputTokens + cacheWriteInputTokens` |
| Model coverage | Claude models support both modes, and the page also lists OpenAI models with a 30-minute TTL and a 1.25× write rate on current rows. Implicit caching on Bedrock looks back about 20 content blocks from the breakpoint |

Bedrock's own page states the operating rule this repository's contract already relies on: keep static content at the beginning of the prompt and dynamic content at the end. It also states that a supported model does not guarantee a hit, so read the usage fields rather than inferring reuse.

---

## 5. Cross-provider summary

| Question | Anthropic | OpenAI | Google |
|---|---|---|---|
| Cache unit | Rendered prefix up to a breakpoint | Rendered prefix up to a breakpoint | Prefix for implicit caching; a referenced cache object for explicit caching |
| Minimum length | 512–4,096 by model | 1,024 visible tokens on current models | 2,048 or 4,096 by model |
| Write cost | 1.25× (5m), 2× (1h) | 1.25× (30m), 2.5× (12h) | Storage charge by TTL, plus the cached-token rate |
| Read cost | 0.1×, with 0.025×/0.05× exceptions | 0.1×, with 0.05× on two models | Reduced cached-token rate |
| Default lifetime | 5 minutes, refreshed on use | 30 minutes on GPT-5.6 and later; earlier models that support both default to `24h` retention without Zero Data Retention and `in_memory` with it (`GPT-5.5` and `GPT-5.5 Pro`: `24h` only) | 1 hour |
| Breakpoint control | Up to 4, automatic or explicit | Up to 4 writes, implicit or explicit on GPT-5.6+ | Explicit cache object only |
| Pre-warm | `max_tokens: 0` | `prewarm: true` | Create the cache object first |

A cache write is never free on a current model. Writing a prefix once and reading it once costs more than processing it once uncached on both Anthropic (1.25× + 0.1×) and OpenAI (1.25× + 0.1×); reuse pays off from the second read onward, which is why the contract asks for measurement instead of assumption.

---

## 6. How to use this file

- A number here justifies a rule in [`../CACHE.md`](../CACHE.md); it is not a claim about every runtime or gateway in front of a provider. A proxy can disable, shrink, or re-key a cache.
- When a vendor changes a threshold or price, update the row and its checked date. Do not restate the number in the contract.
- If you cannot re-verify a row, leave the old date in place rather than refreshing it. A stale date is honest; a refreshed date on unread material is not.

## Related documents

- [`../CACHE.md`](../CACHE.md)
- [`../../sourcing/reliable-search.md`](../../sourcing/reliable-search.md)
