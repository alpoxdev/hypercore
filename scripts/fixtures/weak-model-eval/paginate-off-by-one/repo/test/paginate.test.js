import { test } from "node:test";
import assert from "node:assert/strict";
import { paginate } from "../src/paginate.js";

const items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

test("first page holds a full page of items", () => {
  assert.deepEqual(paginate(items, 1, 3), [1, 2, 3]);
});

test("last page holds the remainder", () => {
  assert.deepEqual(paginate(items, 4, 3), [10]);
});
