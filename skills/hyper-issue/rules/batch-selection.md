# Batch Selection

Use this rule when a selection condition or a batch is named. It owns the fixed list, the query, dedupe, the lane grouping, and the manifest write.

## 1. Freeze The List

1. Turn the user's words into one complete query. Keep every term they gave; add only the repository scope and the open-state filter.
2. Collect the complete result: every page, pull requests excluded, and the total checked against the number of rows returned.
3. Stop on a capped, partial, or failed collection. Report the limitation; never silently narrow the query or take the first page.
4. Deduplicate by repository and issue number, and keep first-occurrence order as the canonical order.
5. The list is frozen at this point. Later discoveries are reported as new candidates for the next batch, never added here.

An empty complete result ends the batch with no lanes and no manifest beyond a one-line note.

## 2. Re-derive The Graph

The `hyper:` blocks are the input; the edges are computed, never trusted blindly.

1. Read each issue's `hyper:` block. An issue with no block is a gap: re-derive its write set from its `## Scope` and mark the manifest row `block: missing`.
2. Build `touches` overlap edges: two issues whose `touches` share a path or one glob covers the other's path.
3. Merge with the declared `depends_on` and `conflicts_with` edges.
4. A cycle among issues is a blocker. Report it with the issue numbers and stop that component; do not invent an ordering.

## 3. Group Lanes

A lane is one write set processed in a fixed order. Lanes run in parallel; the issues inside a lane run in order.

1. Connected components of the overlap graph become lanes. An issue with no edge is its own lane.
2. Order each lane topologically. Two issues with no path between them go in declaration order, lower issue number first.
3. Cap the lane count at the local concurrency limit, defaulting to four. Excess lanes queue and their issues keep their lane order.
4. Prefer the issue `lane_hint` for the lane name when it is unique; otherwise use `<lowest-issue-number>-<short-slug>`.

Do not merge two lanes to reduce their count. Do not put two issues that share a path in different lanes.

## 4. The Manifest

Write `.hyper/issues/<slug>/batch.md` from `references/batch-manifest.md`. It carries:

- the exact query and the collection completeness evidence
- the canonical fixed list with number, title, class, lane, size, and verify command
- the lane table with each lane's order and union of written paths
- the blockers: missing `hyper:` blocks, cycles, and issues needing a split
- the handoff line the next stage reads

## 5. What The Batch Does Not Do

- It never implements, branches, commits, or pushes.
- It never reopens a closed issue or adopts an existing branch as its own.
- It never adds an issue to the frozen list because the implementation turned out to be easy.
- It never removes an issue because it looks blocked; it records the blocker.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| A fixed canonical list collected once, with later discoveries excluded, and a complete collection required before dispatch | [kdy1-scripts slop-fix-batch](https://github.com/kdy1/kdy1-scripts) |
| Dependency components become one stack; independent components start separately | same, `references/construction.md` |
| Declared `conflicts_with` plus a single owner for shared files | [automazeio/ccpm](https://github.com/automazeio/ccpm) |
| Conflicts are frequent between concurrent agent changes, and roughly 42% are structural | [AI Agent PRs on GitHub](https://arxiv.org/abs/2607.04697) |
| Cap the fan-out and declare the join shape | `instructions/graph-engineering/GRAPH_ENGINEERING.md` |

### Evidence grade

`LOCAL` - the lane cap and the manifest fields are this package's design. The freeze rule and the component grouping are adapted from the named prior art.
