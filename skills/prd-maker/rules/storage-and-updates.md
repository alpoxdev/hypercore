# Storage And Updates

Use this rule file whenever the skill creates or updates files.

## 1. Folder location

Store each PRD here:

`.hypercore/prd/[slug]/`

Default files:

- `prd.md`
- `sources.md`

## 2. Slug rules

- Prefer short ASCII kebab-case slugs.
- Base the slug on the initiative or feature, not the full request sentence.
- Reuse an existing slug when the user is clearly updating the same topic.

Good:

- `billing-retry-flow`
- `team-inbox-assignment`

Avoid:

- full sentence slugs
- dated slugs unless the date is part of the product concept
- multiple folders for the same initiative

## 3. File responsibilities

- `prd.md`: the living requirements document
- `sources.md`: evidence log, query log, and source notes

Do not create extra README, notes, or changelog files unless the user explicitly asks for them.

## 4. Create flow

When the folder does not exist:

- create the folder
- create `prd.md` from the template asset
- create `sources.md` from the template asset
- fill unknowns with explicit placeholders or open questions, not silent omissions

## 5. Update flow

When the folder already exists:

- read the current `prd.md` and `sources.md` first
- patch only the sections that changed
- preserve existing links, prior decisions, and useful context
- append a dated entry to the change-history section in `prd.md`
- append new research to `sources.md` without destroying earlier evidence unless it is clearly obsolete

## 6. Missing-folder recovery

If the user asks to update a PRD but the matching folder does not exist:

- create the new folder
- state the missing baseline as an assumption inside the PRD change history
- continue in `create` mode
