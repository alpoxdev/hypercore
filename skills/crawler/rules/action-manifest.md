# Action Manifest

> Use `.hypercore/crawler/<ACTION>.json` as the durable context file for resumable crawler work.

---

<purpose>

- Preserve the run intent, current state, evidence pointers, blockers, and next step in one machine-readable file.
- Keep `ACTION.json` compact and orchestration-focused.
- Keep detailed evidence and generated outputs in `.hypercore/crawler/[site]/`.

</purpose>

---

<lifecycle>

## Lifecycle States

- `planned`: the action exists but discovery has not started
- `running`: discovery or documentation is in progress
- `blocked`: evidence or environment is insufficient to continue safely
- `complete`: required outputs are written and the next step is empty or terminal

</lifecycle>

---

<required_fields>

## Required Fields

- `action`
- `site_name`
- `base_url`
- `site_dir`
- `status`
- `capture_mode`
- `evidence`
- `outputs`
- `blockers`
- `next_step`

</required_fields>

---

<capture_mode>

## Capture Mode Values

- `cdp`
- `fallback`
- `dom`

Use `fallback` when CDP attach fails but browser-network evidence is still sufficient.

</capture_mode>

---

<update_rules>

## Update Rules

- Create `ACTION.json` before long-running or resumable discovery begins.
- Update `status`, `capture_mode`, and `next_step` after each major phase.
- When blocked, write blockers and any available output pointers before stopping.
- When complete, point `outputs` to the final files in `.hypercore/crawler/[site]/`.

</update_rules>

---

<validation_notes>

## Validation Notes

- `site_dir` should point to the real site artifact directory by the time `status` becomes `running`, `blocked`, or `complete`.
- `status: "blocked"` requires at least one blocker entry or an explicit limitation note.
- `status: "complete"` requires that `next_step` is empty or terminal and that final output pointers are filled in.

</validation_notes>

---

<example>

## Example

```json
{
  "action": "extract-products",
  "site_name": "shop-example-com",
  "base_url": "https://shop.example.com/products",
  "site_dir": ".hypercore/crawler/shop-example-com",
  "status": "running",
  "capture_mode": "cdp",
  "evidence": {
    "cdp_attached": true,
    "raw_files": [
      "raw/network-summary.json",
      "raw/auth-signals.json",
      "raw/endpoint-candidates.json"
    ]
  },
  "outputs": {
    "analysis": "ANALYSIS.md",
    "api": null,
    "network": null,
    "crawler": null
  },
  "blockers": [],
  "next_step": "summarize endpoint families into API.md"
}
```

</example>
