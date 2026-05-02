# API Pack

Use this pack when the bottleneck is endpoint latency, query count, payload size, cache behavior, or request-path reliability.

## Recommended Prompts

1. `Reduce this endpoint's latency and query count through measurable iterative experiments.`
2. `Before editing, benchmark the request path, regression safety, and resource cost.`
3. `Improve this API bottleneck and keep only changes that raise the score.`

## Recommended Proof Command

- endpoint benchmark or load test
- integration test
- query logging or request tracing
- smoke request that checks user-visible correctness

## Recommended Binary Eval

- Is the selected proof set appropriate for the API bottleneck?
- Does the run preserve request correctness, authentication, and error handling?
- Does it track concrete API metrics such as p95 latency, query count, cache hit rate, and payload size?
- Does the artifact clearly record the owned endpoint or service scope?
- Does it avoid claiming success without repeated no-regression checks?
