const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const { test } = require("node:test");
const { runInNewContext } = require("node:vm");

const html = readFileSync(join(__dirname, "../rich-post.html"), "utf8");
const script = html.match(/<script>([\s\S]*?)<\/script>/)?.[1];
assert.ok(script, "The delivery shell must contain its copy handler.");

function mount(copyResult) {
  const handlers = {};
  const sample = { innerHTML: " <p><strong>본문</strong></p> " };
  const status = { textContent: "" };
  const calls = [];
  let source;
  runInNewContext(script, {
    document: {
      getElementById(id) {
        if (id === "sample") return sample;
        if (id === "status") return status;
        return { addEventListener: (event, handler) => { handlers[id] = handler; } };
      },
      createRange() {
        return { selectNodeContents: (node) => { calls.push(node); } };
      },
      execCommand(command) {
        calls.push(command);
        if (copyResult instanceof Error) throw copyResult;
        return copyResult;
      },
    },
    window: {
      getSelection: () => ({
        removeAllRanges() { calls.push("clear"); },
        addRange() { calls.push("select"); },
      }),
    },
    navigator: {
      clipboard: { async writeText(text) { source = text; } },
    },
  });
  return { handlers, sample, status, calls, get source() { return source; } };
}

test("rich copy selects only the body before the native copy request", () => {
  const page = mount(true);
  page.handlers.copyRich();
  assert.deepEqual(page.calls, [page.sample, "clear", "select", "copy"]);
  assert.equal(page.source, undefined, "Rich copy must not use writeText.");
  assert.ok(page.status.textContent);
});

test("false and thrown copy results differ from success and keep the selection", () => {
  const success = mount(true);
  success.handlers.copyRich();
  for (const failure of [false, new Error("blocked")]) {
    const page = mount(failure);
    page.handlers.copyRich();
    assert.deepEqual(page.calls, [page.sample, "clear", "select", "copy"]);
    assert.notEqual(page.status.textContent, success.status.textContent);
    assert.ok(page.status.textContent);
  }
});

test("source copy is a separate explicit plain-text action", async () => {
  const page = mount(true);
  await page.handlers.copySource();
  assert.equal(page.source, page.sample.innerHTML.trim());
  assert.deepEqual(page.calls, []);
});
