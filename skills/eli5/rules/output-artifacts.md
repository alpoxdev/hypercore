# Output Artifacts

**Purpose**: Let a completed explanation also exist as a file the reader can open, print, or share, without changing the explanation itself.

Read this after the explanation is settled. The artifact is a rendering of an explanation that already passed the five-question gate in [`validation.md`](validation.md); it is never a place to develop or extend one.

## 1. Format selection

The user chooses one format or a combination. Natural language is the primary surface; the exact token is documented for callers that need determinism.

| Format | Exact token | Files produced | Who creates them |
|---|---|---|---|
| Markdown | `md` | `explanation.md` | You write it directly. The renderer is not involved. |
| HTML | `html` | `explanation.json`, `explanation.html` | You write the JSON; `scripts/render-explanation.mjs` produces the HTML. |
| PDF | `pdf` | everything from `html`, plus `explanation.pdf` | You print the HTML with a browser. |
| Combination | `md,html,pdf` | the union of the rows above | As above. |
| Not specified | — | no files | Answer in the conversation only. |

- `pdf` implies `html`: a PDF is a print of the HTML, so the HTML is always produced first.
- `explanation.md` holds the same content as the conversational answer. Copying the answer into a file is not a second explanation.
- When a format was requested but no browser is available, omit only `explanation.pdf` and produce the rest. State the limitation.

## 2. When to produce an artifact

Produce files only when the request asks for an artifact.

- An explicit artifact request (a format name, "save it", "give me a file", "make it printable") is required.
- A structurally large explanation may be *offered* as an artifact, but never written without the request.
- A short answer gets neither files nor an offer.
- Explanations that only clarify, answer a question, or support a decision stay in the conversation.

## 3. Artifact location

Write under `.hyper/eli5/<slug>/` in the working project.

Derive `<slug>` from the requested topic:

1. Keep ASCII letters and digits, lowercased. Collapse every run of other characters (including Hangul) into a single `-`.
2. Trim leading and trailing `-`.
3. If the result is empty, use `explanation`.
4. If the directory already exists, append `-2`, `-3`, and so on until the name is free. Never overwrite files in an existing directory.

Examples: `Database index` becomes `database-index`; `캐시가 뭐야` becomes `explanation`; a second such topic becomes `explanation-2`.

## 4. The structure view

`explanation.html` is a self-contained page: one file, no network, no external font, no build step. It renders the explanation's existing layers, mechanism steps, analogy and its limit, terms, and cautions.

Read [`../references/explanation-view-schema.md`](../references/explanation-view-schema.md) for the JSON schema, the renderer command, and the error contract.

Interactions are limited to five: theme toggle, per-layer collapse, expand/collapse all, mechanism-step highlight, and term jump. Anything larger (search, path tracing, presentation mode, export menus) belongs to a diagram tool, not to an explanation.

## 5. PDF path

Detection is your job, not the renderer's: the renderer may not spawn processes.

```bash
CANDIDATES=(
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  "/Applications/Chromium.app/Contents/MacOS/Chromium"
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
)
BROWSER=""
for candidate in "${CANDIDATES[@]}"; do [ -x "$candidate" ] && BROWSER="$candidate" && break; done
if [ -z "$BROWSER" ]; then for name in google-chrome chromium chromium-browser microsoft-edge; do p="$(command -v "$name" 2>/dev/null)" && [ -n "$p" ] && BROWSER="$p" && break; done; fi
```

On Windows the candidates are `%ProgramFiles%\Google\Chrome\Application\chrome.exe` and `%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe`.

Then print:

```bash
"$BROWSER" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="<artifact-dir>/explanation.pdf" \
  "<artifact-dir>/explanation.html"
```

- When no browser is found, skip only the PDF step and report exactly:
  `Chromium 계열 브라우저를 찾지 못해 PDF를 만들지 않았습니다. <artifact-dir>/explanation.html을 브라우저로 열어 인쇄하면 PDF를 얻을 수 있습니다.`
- Never install or download a browser, and never fetch anything over the network.
- `explanation.html` is kept in every case, including every failure path.

## 6. Fidelity guard

The view must not add anything the explanation does not already say.

- Layers, mechanism steps, terms, cautions, and the analogy limit are extracted from the settled explanation, never invented for the page.
- No new number, source, date, or claim appears only in the artifact.
- The analogy's stated limit travels with the analogy. A view that shows the metaphor without its limit is a fidelity failure.
- If the explanation marks something unknown or uncertain, the view keeps that marking.

## 7. Failure handling

- If the renderer fails, keep the conversational answer and report the failure. Never present a partial or stale view as the result.
- The renderer writes atomically: a failure preserves the previous `explanation.html` byte for byte and leaves no temporary file.
- Report the artifact paths that actually exist. Do not claim a PDF that was skipped.

## Sources

> No external sources were used. Content checked 2026-09-22.

The format contract, the artifact path scheme, the structure-view interaction limit, and the PDF fallback are authored in this package around its own renderer script. No external claim is made, so no external source is cited.
