# Node Pack

Use this pack when the bottleneck is Node runtime latency, CPU work, memory use, CLI throughput, or background-job behavior.

## Recommended Prompts

1. `Profile this Node hot path and keep only score-improving optimizations.`
2. `Before editing, benchmark task runtime, CPU cost, and regression checks.`
3. `Improve this Node bottleneck through measurable iterative experiments while preserving current behavior.`

## Recommended Proof Command

- benchmark script
- target test suite
- profiler or flame graph command
- CLI smoke command

## Recommended Binary Eval

- Is the selected proof set appropriate for the Node or CLI bottleneck?
- Does the run preserve output correctness and error handling for the hot path?
- Does it track concrete runtime metrics such as duration, CPU, memory, and allocation?
- Does the artifact clearly record the owned module or command scope?
- Does it avoid claiming success without repeated no-regression checks?
