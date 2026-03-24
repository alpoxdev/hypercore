# Node Pack

Use this pack when the bottleneck is mainly Node runtime latency, CPU work, memory use, CLI throughput, or background job behavior.

## Suggested Prompts

1. `Profile this Node hot path and keep only score-improving optimizations.`
2. `Benchmark the job runtime, CPU cost, and regression checks before editing.`
3. `Improve this Node bottleneck with measured iterations and preserve current behavior.`

## Suggested Proof Commands

- benchmark script
- targeted test suite
- profiler or flame graph command
- CLI smoke command

## Suggested Binary Evals

- Is the chosen proof set appropriate for a Node or CLI bottleneck?
- Does the run preserve output correctness and error handling on the hot path?
- Does the run track a concrete runtime metric such as duration, CPU, memory, or allocations?
- Does the artifact record the owned module or command scope clearly?
- Does the run avoid claiming a win without a repeated non-regression check?
