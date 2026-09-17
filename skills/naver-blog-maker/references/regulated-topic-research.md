# Regulated Topic Research (Medical)

> Korean version: [`regulated-topic-research.ko.md`](regulated-topic-research.ko.md)

**Purpose**: The source rules for a post whose numbers can affect a reader's body — a dose, an interval, a duration, an eligibility limit, a legal boundary. Read it after [`../rules/topic-research.md`](../rules/topic-research.md) and before drafting. It exists because a number about a person's body is not a value you may approximate, round, or transfer from a similar product.

Scope is medical. Financial, legal, and real-estate quantitative claims follow the general rule in `topic-research.md` §3 (a governing first-party source plus the grade and role split in §2 below). Add a field-specific lane to §3 of this file the first time a run actually needs one; do not stretch the medical lanes to cover another field.

## 1. Scope and when this file is read

Read it when the topic is medical, or when the title or intent turns on a quantitative safety, dosage, interval, duration, eligibility, or legal-limit claim.

A **regulated topic** here means a post where a wrong number can cause harm, not merely one that mentions health. A recipe-level post about sleep habits is not regulated; a post stating how many units of a substance may be injected at one session is.

## 2. Source grade and source role

Two axes, never one. **Grade** says how trustworthy a source is. **Role** says what that source may support in this post.

| Axis | Values, strongest first |
|---|---|
| grade | regulatory authority (approval, 허가사항) > manufacturer label > professional-society guideline > peer-reviewed review > dated news > blog or cafe |
| role | `quantitative_authority` > `recommendation_basis` > `supporting_context` > `lead_only` |

| Role | What it may support |
|---|---|
| `quantitative_authority` | The number itself: a dose, a maximum, an interval, a duration, an eligibility limit. |
| `recommendation_basis` | That a society, regulator, or operator recommends a course, with its stated scope. |
| `supporting_context` | Why a number is uncertain, contested, or limited. Never the number alone. |
| `lead_only` | A search lead that still needs a first-party source. Never a price, safety, or legal basis. |

Rule: **a quantitative claim's role must be `quantitative_authority`.** A peer-reviewed review has a high grade and still may not be the sole basis for a number — it is `supporting_context`. A clinic blog or a cafe post is `lead_only` even when it states a number confidently.

## 3. Quantitative query lanes (medical)

Run these only after the general research pass, and only for the decision fields still open. Never hardcode a domain: confirm that the target is the actual first-party publisher before putting it in a query.

| Lane | What it supplies | Query pattern |
|---|---|---|
| Regulatory approval | Approved indication, dose, maximum, warnings | `"<product or ingredient>" ("허가사항" OR "용법·용량" OR "사용상의 주의사항")` against the regulator's own site |
| Manufacturer label | Product-specific prescribing information, per-site and total dose | `"<product>" ("prescribing information" OR "package insert" OR "용법 용량") filetype:pdf` on the manufacturer's domain |
| Professional-society guideline | What the specialty recommends, under which conditions | `"<procedure or ingredient>" ("guideline" OR "consensus" OR "권고안") filetype:pdf` on the society's domain |
| Peer-reviewed review | Duration, immunogenicity, contradictory findings, uncertainty | `"<ingredient>" ("systematic review" OR "meta-analysis") ("duration" OR "interval" OR "immunogenicity")` |
| Brand-owned material | The clinic's own process, preparation, published price | `site:<brand domain> "<procedure>" ("비용" OR "가격" OR "과정" OR "준비")` |

A review found here is `supporting_context`: it may explain that a value is uncertain, and it may not supply the value.

## 4. Claim scope

A number without its scope is a different number. Keep the source's own scope and its meaning.

- Never convert `recommended` into `maximum`, `total dose` into `per-site dose`, or a single-indication value into a general one.
- Name the product, the indication, the site or population, and the route the source stated. If the source states none of these, do not supply one by inference.
- When two sources disagree, compare date, version, applicable scope, and methodology before choosing; if the disagreement changes the reader's decision, report it rather than picking silently.

## 5. How quantitative sentences are written

Three parts, in order: attribute the fact, bound its scope, separate it from personal advice.

```
<출처명>의 허가사항에는 <제품·적응증 범위>에서 <수치와 원문 의미>로 기재돼 있습니다.
이 값은 해당 제품·적응증의 허가사항 설명이며 개인에게 권하는 용량·간격이 아닙니다.
개인 적용 여부는 진료에서 별도로 판단해야 합니다.
```

Do not attach a meaning the source did not state (`최대`, `안전한`, `권장`). Do not write a sentence that reads as a prescription for this reader. Never invent a source, a date, or a value, and never round a sourced number to a more memorable one.

## 6. Slot kinds

| Slot | What it holds | Filled by | Publish effect |
|---|---|---|---|
| `author slot` | The author's own experience, the amount actually paid, a real case | the author | does not block publishing |
| `source-required slot` | An approved dose, a medical interval, an eligibility limit | a governing first-party source | **blocks publishing** |

Leave only the **number's spot** open. Keep writing the sourced qualitative content around it: the criteria, the process, the conditions that change the answer.

A regulated qualitative judgment is not exempt. For a decision criterion or a condition that flips the advice, a `recommendation_basis` with its scope or a first-party source that directly supports that claim is required; otherwise that sentence is a slot too. Do not generate "if this, do not treat" or "if that, change the interval" out of general knowledge.

## 7. Medical advertising boundary

Korean medical advertising law governs this package's medical posts. Each item below is bound to the statute text that governs it.

| Item | Governing text (의료법 제56조 제2항) | How the post handles it |
|---|---|---|
| Guaranteeing or overstating an effect | 제8호 "객관적인 사실을 과장하는 내용의 광고" | No guaranteed, absolute, or inevitably-effective claim; no 비포·애프터 promise of an outcome. |
| Comparing with another clinic or technique as superior | 제4호 "다른 의료인등의 기능 또는 진료 방법과 비교하는 내용의 광고" | No 최고·최저·1위·유일 comparison, and no implied ranking against another practitioner. |
| Patient testimonials and treatment-experience stories | 제2호 "환자에 관한 치료경험담 등 소비자로 하여금 치료 효과를 오인하게 할 우려가 있는 내용의 광고" | No quoted or invented patient experience; the case section stays a slot when the author has no real one. |
| Omitting a serious downside | 제7호 "심각한 부작용 등 중요한 정보를 누락하는 광고" | The downside section is mandatory, not optional. |
| Discounting or waiving non-covered fees to draw patients | 제13호 "비급여 진료비용을 할인하거나 면제하는 내용의 광고" | No price-offer or discount CTA. |

Source: 국가법령정보센터, 의료법 제56조 (시행 2026-09-11, 법률 제21423호), <https://www.law.go.kr/LSW/lsLinkCommonInfo.do?lsJoLnkSeq=1026149431&chrClsCd=010202>, accessed 2026-09-17.

**Not yet verified in this package:** the detailed criteria that 의료법 시행령 제23조 adds under 제56조 제4항, and the scope of the 제57조 pre-review requirement for a blog post. Treat both as `[법적 범위 확인 필요]` until a first-party source is read in the run that needs them. Never complete this list from memory.

## 8. Medical CTA default while the boundary is UNKNOWN

When an applicable item in §7 is not positive-confirmed, do not confirm the content element it governs. Leave `[법적 범위 확인 필요: <item>]` in place, mark the draft as blocked for publishing, and say so in the publish note.

For a promotional or offer type, or when the goal is a booking or a purchase: do not confirm a booking, discount, or purchase CTA at all while §7 is unconfirmed. A neutral next step — what the reader should verify about their own situation — is allowed and is the default.

## 9. When research fails

- **Some primary coverage:** rebuild the title and the body's scope around what the verified sources actually support, and list the unresolved quantitative fields separately. Do not keep a title promise the sources cannot pay off.
- **No primary coverage for a required regulated claim:** do not deliver a publish-ready quantitative draft. Deliver the decision-complete structure with `[확인 필요]` slots plus one compact list of the sources to find, and say the post is not ready to publish.
- **Neither case asks a second intake question.** The author's memory is not a substitute for a primary source, and the author's own numbers are `author slot`s, which cannot fill a `source-required slot`.
