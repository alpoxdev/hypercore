#!/usr/bin/env bun
// Measures how often a model picks one skill from the full skill catalog for each
// eval case of that skill. Reproduces the routing prompt used for the trigger runs
// recorded in skills/<skill>/assets/evals/<skill>-measurements.json. Raw run output
// is kept under scripts/fixtures/skill-trigger-runs/<skill>/, outside the skill
// directory, because it records the catalog name each call answered.
//
// Usage:
//   bun scripts/measure-skill-trigger.mjs --repo <root> --skill <name> --model <model> \
//     [--runs 10] [--concurrency 6] [--min-hit N] [--max-hit N] [--only id,id] \
//     [--cases file.jsonl] [--mode direct|router|agent] [--description-file file.txt] \
//     [--endpoint url] [--api-key-env NAME] [--reask 2] [--error-rounds 2] [--label text] \
//     [--out file.json]
//
// Exit 0: every row passed. Exit 1: a row failed. Exit 3: no row failed, but calls that
// failed in transport leave a row undecided (reported as OPEN, never counted as a miss).
//
// A trigger case passes with at least --min-hit hits in --runs calls (default 80% of
// runs, rounded up); a no_trigger case passes with at most --max-hit hits (default
// 20% of runs, rounded down). Exit 1 when any case fails.
//
// --mode router (default) asks through the omp CLI with tools, installed skills,
//   rules, and context files switched off, so the only skill list the model is meant
//   to see is the catalog in the prompt and it cannot inspect the scratch directory.
// --mode direct posts the same two messages to an OpenAI-compatible chat endpoint
//   (--endpoint, default http://127.0.0.1:3425/v1; key read from the environment
//   variable named by --api-key-env, default SKILL_TRIGGER_API_KEY). Nothing but the
//   routing prompt reaches the model, so it is the least noisy and cheapest mode; the
//   CLI can add a large harness prompt of its own even with every switch off.
// --mode agent is the earliest behavior: a full agent session answers the question.
// --description-file replaces the measured skill's description with the file's text,
//   to compare a candidate wording without editing SKILL.md.
// An answer that is neither a catalog name nor "none" is a format failure, not a
// routing judgment: it is asked again up to --reask times and counted in `invalid`.
import { existsSync, mkdtempSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const args = new Map();
for (let i = 2; i < process.argv.length; i += 2) {
  args.set(process.argv[i].replace(/^--/, ""), process.argv[i + 1]);
}
const need = (k) => {
  const v = args.get(k);
  if (!v) {
    console.error(`missing --${k}`);
    process.exit(2);
  }
  return v;
};
const repo = need("repo");
const skill = need("skill");
const model = need("model");
const runs = Number(args.get("runs") ?? 10);
const concurrency = Number(args.get("concurrency") ?? 6);
const minHit = Number(args.get("min-hit") ?? Math.ceil(runs * 0.8));
const maxHit = Number(args.get("max-hit") ?? Math.floor(runs * 0.2));
const only = args.get("only")?.split(",");
const out = args.get("out");
const mode = args.get("mode") ?? "router";
const reask = Number(args.get("reask") ?? 2);
const label = args.get("label") ?? "";
const descriptionFile = args.get("description-file");
const thinking = args.get("thinking");
const timeoutMs = 300_000;
const retries = 2;
const errorRounds = Number(args.get("error-rounds") ?? 2);
const endpoint = (args.get("endpoint") ?? "http://127.0.0.1:3425/v1").replace(/\/$/, "");
const apiKeyEnv = args.get("api-key-env") ?? "SKILL_TRIGGER_API_KEY";
const apiKey = process.env[apiKeyEnv];
if (mode !== "router" && mode !== "agent" && mode !== "direct") {
  console.error("--mode must be direct, router or agent");
  process.exit(2);
}
if (mode === "direct" && !apiKey) {
  console.error(`--mode direct needs the endpoint key in $${apiKeyEnv}`);
  process.exit(2);
}

const override = descriptionFile ? readFileSync(descriptionFile, "utf8").trim().replace(/\s*\n\s*/g, " ") : null;
const catalog = [];
let measuredDescription = null;
for (const dir of readdirSync(join(repo, "skills")).sort()) {
  const p = join(repo, "skills", dir, "SKILL.md");
  if (!existsSync(p)) continue;
  const fm = readFileSync(p, "utf8").match(/^---\n([\s\S]*?)\n---/);
  if (!fm) continue;
  const name = fm[1].match(/^name:\s*(.+)$/m)?.[1].trim();
  let desc = fm[1].match(/^description:\s*(.+)$/m)?.[1].trim().replace(/^"|"$/g, "");
  if (name === skill) {
    if (override) desc = override;
    measuredDescription = desc;
  }
  if (name && desc) catalog.push(`- ${name}: ${desc}`);
}
if (measuredDescription === null) {
  console.error(`skill ${skill} not found under ${join(repo, "skills")}`);
  process.exit(2);
}
const catalogText = catalog.join("\n");
const catalogNames = new Set(catalog.map((l) => l.slice(2).split(":")[0]));

const casesPath = args.get("cases") ?? join(repo, "skills", skill, "assets", "evals", `${skill}-cases.jsonl`);
let cases = readFileSync(casesPath, "utf8")
  .split("\n")
  .filter(Boolean)
  .map((l) => JSON.parse(l));
if (only) cases = cases.filter((c) => only.includes(c.id));

const systemPrompt =
  "You route user requests to skills. Reply with exactly one line: one skill name from the list, or none.";
const cwd = mode === "direct" ? null : mkdtempSync(join(tmpdir(), "skill-trigger-"));
const isolation =
  mode === "router"
    ? [
        "--no-tools",
        "--no-skills",
        "--no-rules",
        "--no-context-files",
        "--no-extensions",
        "--no-lsp",
        "--no-title",
        ...(thinking ? [`--thinking=${thinking}`] : []),
        "--system-prompt",
        systemPrompt,
      ]
    : [];

const normalize = (text) => {
  const last = text.trim().split("\n").pop()?.trim() ?? "";
  const bare = last.replace(/^[`\-*"' ]+|[`\-*"'. ]+$/g, "");
  return bare.toLowerCase() === "none" ? "none" : bare;
};
const isError = (a) => a.startsWith("ERR:");
const isValid = (a) => a === "none" || catalogNames.has(a);
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
// A dropped connection fails in milliseconds, so retries wait long enough for a gateway restart.
const backoffMs = [5_000, 20_000, 60_000];

let promptTokens = 0;
let calls = 0;
async function askDirect(q) {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const res = await fetch(`${endpoint}/chat/completions`, {
        method: "POST",
        headers: { authorization: `Bearer ${apiKey}`, "content-type": "application/json" },
        body: JSON.stringify({
          model,
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: q },
          ],
        }),
        signal: AbortSignal.timeout(timeoutMs),
      });
      const body = await res.json();
      const text = body?.choices?.[0]?.message?.content;
      if (!res.ok || typeof text !== "string") {
        console.error(`RETRY http=${res.status} attempt=${attempt + 1}`);
        if (attempt < retries) await sleep(backoffMs[attempt]);
        continue;
      }
      promptTokens += body.usage?.prompt_tokens ?? 0;
      calls++;
      return normalize(text) || "ERR:empty";
    } catch (e) {
      console.error(`RETRY ${e?.name ?? "error"} ${e?.code ?? e?.cause?.code ?? ""} attempt=${attempt + 1}`);
      if (attempt < retries) await sleep(backoffMs[attempt]);
    }
  }
  return "ERR:timeout";
}

async function askOnce(prompt) {
  const q = `You route user requests to skills. Available skills:\n${catalogText}\n\nUser request: ${prompt}\n\nWhich single skill (if any) would you invoke first? Answer with exactly one line: the skill name, or none. No other text.`;
  if (mode === "direct") return askDirect(q);
  for (let attempt = 0; attempt <= retries; attempt++) {
    const proc = Bun.spawn(["omp", "-p", "--no-session", ...isolation, "--model", model, q], {
      cwd,
      stdout: "pipe",
      stderr: "pipe",
    });
    const timer = setTimeout(() => proc.kill(), timeoutMs);
    const [stdout, stderr] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text()]);
    await proc.exited;
    clearTimeout(timer);
    if (proc.signalCode) {
      console.error(`RETRY timeout attempt=${attempt + 1}`);
      continue;
    }
    return normalize(stdout) || `ERR:${stderr.slice(-100)}`;
  }
  return "ERR:timeout";
}

let invalidTotal = 0;
async function ask(prompt) {
  let answer = await askOnce(prompt);
  for (let i = 0; i < reask && !isValid(answer) && !isError(answer); i++) {
    invalidTotal++;
    answer = await askOnce(prompt);
  }
  return answer;
}

const jobs = cases.flatMap((c) => Array.from({ length: runs }, () => c));
const answers = new Array(jobs.length);
async function runPool(indexes, width) {
  let next = 0;
  await Promise.all(
    Array.from({ length: width }, async () => {
      while (next < indexes.length) {
        const i = indexes[next++];
        answers[i] = await ask(jobs[i].prompt);
      }
    }),
  );
}
await runPool(
  jobs.map((_, i) => i),
  concurrency,
);
// Transport failures are not model answers: ask those calls again at a quarter of the width.
for (let round = 1; round <= errorRounds; round++) {
  const failed = answers.flatMap((a, i) => (isError(a) ? [i] : []));
  if (!failed.length) break;
  console.error(`REFILL round=${round} calls=${failed.length}`);
  await sleep(30_000);
  await runPool(failed, Math.max(1, Math.ceil(concurrency / 4)));
}

const byId = new Map();
jobs.forEach((c, i) => {
  if (!byId.has(c.id)) byId.set(c.id, []);
  byId.get(c.id).push(answers[i]);
});

const rows = cases.map((c) => {
  const rs = byId.get(c.id);
  const hits = rs.filter((r) => r === skill).length;
  const none = rs.filter((r) => r === "none").length;
  const errors = rs.filter(isError).length;
  const invalid = rs.filter((r) => !isValid(r) && !isError(r)).length;
  const other = rs.length - hits - none - invalid - errors;
  const want = c.expect === "trigger";
  // A row is judged only when the calls that failed in transport cannot change the outcome.
  const pass = want
    ? hits >= minHit
      ? true
      : hits + errors < minHit
        ? false
        : null
    : hits > maxHit
      ? false
      : hits + errors <= maxHit
        ? true
        : null;
  const margin = want ? hits - minHit : maxHit - hits;
  return { id: c.id, expect: c.expect, hits, none, other, invalid, errors, runs, pass, margin, answers: rs };
});
for (const r of rows) {
  const misses = r.answers.filter((a) => a !== skill);
  console.log(
    `${r.pass === null ? "OPEN" : r.pass ? "PASS" : "FAIL"} | ${r.id} | ${r.expect} | ${r.hits}/${runs - r.errors} | ${JSON.stringify(r.expect === "trigger" ? misses : r.answers.filter((a) => a === skill).length ? r.answers : [...new Set(r.answers)])}`,
  );
}
const passed = rows.filter((r) => r.pass === true).length;
const failed = rows.filter((r) => r.pass === false).length;
const rate = (expect) => {
  const sel = rows.filter((r) => r.expect === expect);
  const answered = sel.reduce((s, r) => s + runs - r.errors, 0);
  return answered ? Number((sel.reduce((s, r) => s + r.hits, 0) / answered).toFixed(4)) : null;
};
const summary = {
  passed,
  total: rows.length,
  failed,
  openRows: rows.filter((r) => r.pass === null).map((r) => r.id),
  transportErrors: rows.reduce((s, r) => s + r.errors, 0),
  triggerHitRate: rate("trigger"),
  noTriggerHitRate: rate("no_trigger"),
  rowsAtThreshold: rows.filter((r) => r.pass && r.margin === 0).map((r) => r.id),
  unstableRows: rows.filter((r) => r.hits !== 0 && r.hits !== runs).length,
  invalidAnswersKept: rows.reduce((s, r) => s + r.invalid, 0),
  invalidAnswersReasked: invalidTotal,
};
console.log(`${passed} / ${rows.length}`);
console.log(JSON.stringify(summary));
if (out) {
  writeFileSync(
    out,
    `${JSON.stringify(
      {
        skill,
        model,
        mode,
        label,
        thinking: thinking ?? "default",
        ...(mode === "direct" ? { endpoint, meanPromptTokens: calls ? Math.round(promptTokens / calls) : null } : {}),
        cases: casesPath.startsWith(repo) ? casesPath.slice(repo.length).replace(/^\//, "") : casesPath,
        descriptionChars: measuredDescription.length,
        description: measuredDescription,
        runs,
        minHit,
        maxHit,
        reask,
        ...summary,
        rows,
      },
      null,
      2,
    )}\n`,
  );
}
process.exit(failed ? 1 : passed === rows.length ? 0 : 3);
