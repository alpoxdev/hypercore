# chrome-devtools-mcp

> Use after Playwriter when you need first-party CDP-backed network, console, performance, accessibility, or memory evidence with Chrome DevTools fidelity.

---

<routing>

## Playwriter vs chrome-devtools-mcp

| Tool | Optimized for | Use when |
|------|------|------|
| `playwriter` (Playwright MCP) | **Driving** the page | Login, click, fill, scroll, lazy-load triggering, selector validation |
| `chrome-devtools-mcp` | **Debugging** the page | Live network capture, performance traces, console errors, Lighthouse audit, memory snapshot |

These are complementary, not redundant. Reproduce the user flow with `playwriter`, then attach `chrome-devtools-mcp` to capture rich evidence with native Chrome DevTools fidelity. If only one is available, prefer `playwriter` for navigation and CDP fallback for evidence.

</routing>

---

<tool_surface>

## chrome-devtools-mcp Tool Families

Discovery and navigation:
- `navigate_page`, `take_snapshot`, `take_screenshot`, `list_pages`, `select_page`, `new_page`, `close_page`

Network evidence (replaces or supplements CDP via Playwriter):
- `list_network_requests`, `get_network_request` — structured request/response with headers, status, mime, body where allowed

Console evidence:
- `list_console_messages`, `get_console_message` — runtime errors, warnings, deprecation notices

Performance and audits:
- `performance_start_trace`, `performance_stop_trace`, `performance_analyze_insight`
- `lighthouse_audit` — accessibility, SEO, best-practices, performance audit
- `take_memory_snapshot`

Page interaction (when Playwriter is not available):
- `click`, `fill`, `fill_form`, `hover`, `drag`, `press_key`, `wait_for`, `handle_dialog`, `type_text`, `upload_file`

Programmatic evaluation:
- `evaluate_script` — run page-context JavaScript

</tool_surface>

---

<workflow>

## Standard discovery flow

```text
1. Reproduce target page flow with `playwriter` (login, navigation, lazy scroll)
2. Attach `chrome-devtools-mcp` to the same browser session or open it on the same URL
3. Use `list_network_requests` to enumerate request families
4. Sample bodies with `get_network_request` only for endpoint candidates
5. If perf or detection signals matter, run `performance_start_trace` → trigger flow → `performance_stop_trace` → `performance_analyze_insight`
6. For accessibility-aware structure inspection use `take_snapshot` (a11y tree) instead of full HTML
```

</workflow>

---

<decision_notes>

## When to choose chrome-devtools-mcp over Playwriter CDP

- **Network capture** with header detail and status families: prefer `list_network_requests` over hand-rolling Playwriter CDP listeners — it returns normalized, deduplicated rows and is cheaper to read.
- **Performance traces**: only chrome-devtools-mcp ships native trace + insight tooling.
- **Lighthouse audit** for SEO/perf/a11y baselines: only chrome-devtools-mcp.
- **Console diagnostics**: `list_console_messages` is structured and filterable; Playwriter `page.on("console")` is fine for one-off but requires custom buffering.

When the run only needs page driving and quick selector checks, stay with Playwriter and avoid double-attaching another browser.

</decision_notes>

---

<anti_detect_caveat>

## Anti-detect interaction

`chrome-devtools-mcp` opens a real Chrome with full CDP attach. That means:

- **`Runtime.Enable` is on** — Cloudflare and DataDome detect this. If the target has strong bot-detection, run discovery in `chrome-devtools-mcp` only on a throwaway origin or a pre-login page, then move execution to a stealth runner ([anti-bot-checklist.md](anti-bot-checklist.md)).
- IP / fingerprint / TLS surface is whatever the host gives you. Pair with residential proxy and stealth profile when scaling.
- Use `chrome-devtools-mcp` for *evidence collection* on a representative session, not as the long-running crawler runtime against protected targets.

</anti_detect_caveat>

---

<artifact_outputs>

## Where evidence lands

- Normalize chrome-devtools-mcp output into the same `raw/network-summary.json`, `raw/auth-signals.json`, `raw/endpoint-candidates.json` files described in [cdp-capture.md](cdp-capture.md).
- Record `capture_mode: "chrome-devtools-mcp"` in `ACTION.json` when this path was used end-to-end.
- Lighthouse and performance trace summaries belong in `ANALYSIS.md` with a one-line link to the raw artifact.

</artifact_outputs>
