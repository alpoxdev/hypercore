import { test } from "node:test";
import assert from "node:assert/strict";
import { readTimeout } from "../src/config.js";

test("zero keeps the timeout disabled", () => {
  assert.equal(readTimeout({ timeoutMs: 0 }), 0);
});

test("a missing value falls back to 30 seconds", () => {
  assert.equal(readTimeout({}), 30000);
});
