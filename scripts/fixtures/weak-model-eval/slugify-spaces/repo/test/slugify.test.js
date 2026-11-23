import { test } from "node:test";
import assert from "node:assert/strict";
import { slugify } from "../src/slugify.js";

test("surrounding and repeated spaces collapse to one hyphen", () => {
  assert.equal(slugify("  Hello   World "), "hello-world");
});

test("an existing slug only changes case", () => {
  assert.equal(slugify("Already-Slug"), "already-slug");
});
