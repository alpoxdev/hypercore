# Gemini Model Selection Guide

**Version**: v0.29.5+ | **Last Updated**: 2026-02-16

## Quick Reference

| User request | Model | Status |
|--------------|-------|--------|
| No version / "use 3" | `gemini-3.1-pro-preview` | Preview (requires access) |
| "use 2.5" | `gemini-2.5-pro` | Stable |
| "use flash" | `gemini-2.5-flash` | Stable, always available |

**Default**: Use `gemini-3.1-pro-preview` for ALL tasks. No task-type differentiation needed.

## Fallback Chain

```
gemini-3.1-pro-preview
  ↓ (unavailable / quota exhausted / 403)
gemini-2.5-pro
  ↓ (unavailable)
gemini-2.5-flash  ← always works on free tier
```

```bash
# Try primary, fall back on error
gemini -m gemini-3.1-pro-preview -p "Your task" 2>&1
if [ $? -ne 0 ]; then
    gemini -m gemini-2.5-pro -p "Your task"
fi
```

## Access Requirements

**Gemini 3.1 Pro** (preview):
- Requires: Google AI Ultra subscription, paid API key, or Vertex API key with Gemini 3 access
- Free tier: stricter quotas; 404/403 errors indicate no access
- Fix for free tier: disable `previewFeatures` in `~/.gemini/settings.json`

**Gemini 2.5 models**: Always available on free tier (60 req/min, 1000 req/day, 1M token context)

## Capabilities Comparison

| | Gemini 3.1 Pro | Gemini 2.5 Pro | Gemini 2.5 Flash |
|-|----------------|----------------|------------------|
| Reasoning | ★★★★★ | ★★★★ | ★★★ |
| Code | ★★★★★ | ★★★★ | ★★★★★ |
| Speed | ★★★ | ★★★★ | ★★★★★ |
| Context | 1M tokens | 1M tokens | — |
| Free tier | Limited | Yes | Yes |

## Verification

```bash
# Test Gemini 3.1 Pro access
gemini -m gemini-3.1-pro-preview -p "test" 2>&1
# Success: model responds
# Failure: 404 "model not found" or 403 "access denied"
```

## Maintenance

When new models release: update Quick Reference table, add to Capabilities Comparison, revise fallback chain, update "Last Updated" date.

## See Also

- `gemini-help.md` — Full CLI reference
- `command-patterns.md` — Common command templates
- `session-workflows.md` — Session continuation patterns
