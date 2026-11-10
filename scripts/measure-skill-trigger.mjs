#!/usr/bin/env bun
// Measures how often a model picks one skill from the full skill catalog for each
// eval case of that skill. Reproduces the routing prompt used for the trigger runs
// recorded in skills/<skill>/assets/evals/<skill>-measurements.json.
//
// Usage:
//   bun scripts/measure-skill-trigger.mjs --repo <root> --skill <name> --model <model> \
//     [--runs 5] [--concurrency 6] [--min-hit 4] [--max-hit 1] [--only id,id] [--out file.json]
//
// A trigger case passes with at least --min-hit hits in --runs calls; a no_trigger
// case passes with at most --max-hit hits. Exit 1 when any case fails.
import { existsSync, readFileSync, readdirSync, writeFileSync, mkdtempSync } from "node:fs";
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
const runs = Number(args.get("runs") ?? 5);
const concurrency = Number(args.get("concurrency") ?? 6);
const minHit = Number(args.get("min-hit") ?? 4);
const maxHit = Number(args.get("max-hit") ?? 1);
const only = args.get("only")?.split(",");
const out = args.get("out");
const timeoutMs = 300_000;
const retries = 2;

const catalog = [];
for (const dir of readdirSync(join(repo, "skills")).sort()) {
  const p = join(repo, "skills", dir, "SKILL.md");
  if (!existsSync(p)) continue;
  const fm = readFileSync(p, "utf8").match(/^---\n([\s\S]*?)\n---/);
  if (!fm) continue;
  const name = fm[1].match(/^name:\s*(.+)$/m)?.[1].trim();
  const desc = fm[1].match(/^description:\s*(.+)$/m)?.[1].trim().replace(/^"|"$/g, "");
  if (name && desc) catalog.push(`- ${name}: ${desc}`);
}
const catalogText = catalog.join("\n");
const catalogNames = new Set(catalog.map((l) => l.slice(2).split(":")[0]));

const casesPath = join(repo, "skills", skill, "assets", "evals", `${skill}-cases.jsonl`);
let cases = readFileSync(casesPath, "utf8")
  .split("\n")
  .filter(Boolean)
  .map((l) => JSON.parse(l));
if (only) cases = cases.filter((c) => only.includes(c.id));

const cwd = mkdtempSync(join(tmpdir(), "skill-trigger-"));

async function ask(prompt) {
  const q = `You route user requests to skills. Available skills:\n${catalogText}\n\nUser request: ${prompt}\n\nWhich single skill (if any) would you invoke first? Answer with exactly one line: the skill name, or none. No other text.`;
  for (let attempt = 0; attempt <= retries; attempt++) {
    const proc = Bun.spawn(["omp", "-p", "--no-session", "--model", model, q], {
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
    const last = stdout.trim().split("\n").pop()?.trim().replace(/^[`\-* ]+|[`\-* ]+$/g, "") ?? "";
    return last || `ERR:${stderr.slice(-100)}`;
  }
  return "ERR:timeout";
}

const jobs = cases.flatMap((c) => Array.from({ length: runs }, () => c));
const answers = new Array(jobs.length);
let next = 0;
await Promise.all(
  Array.from({ length: concurrency }, async () => {
    while (next < jobs.length) {
      const i = next++;
      answers[i] = await ask(jobs[i].prompt);
    }
  }),
);

const byId = new Map();
jobs.forEach((c, i) => {
  if (!byId.has(c.id)) byId.set(c.id, []);
  byId.get(c.id).push(answers[i]);
});

const rows = cases.map((c) => {
  const rs = byId.get(c.id);
  const hits = rs.filter((r) => r === skill).length;
  const want = c.expect === "trigger";
  const pass = want ? hits >= minHit : hits <= maxHit;
  return { id: c.id, expect: c.expect, hits, runs, pass, answers: rs };
});
for (const r of rows) {
  console.log(`${r.pass ? "PASS" : "FAIL"} | ${r.id} | ${r.expect} | ${r.hits}/${runs} | ${JSON.stringify(r.answers)}`);
}
const passed = rows.filter((r) => r.pass).length;
console.log(`${passed} / ${rows.length}`);
const unknown = rows.flatMap((r) => r.answers).filter((a) => a !== "none" && !catalogNames.has(a));
if (unknown.length) console.log(`unparsed answers: ${unknown.length}`);
if (out) {
  writeFileSync(
    out,
    JSON.stringify({ skill, model, runs, minHit, maxHit, passed, total: rows.length, rows }, null, 2),
  );
}
process.exit(passed === rows.length ? 0 : 1);
