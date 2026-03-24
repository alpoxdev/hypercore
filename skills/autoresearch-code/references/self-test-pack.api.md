# API Pack

Use this pack when the bottleneck is mainly endpoint latency, query count, payload size, cache behavior, or request-path reliability.

## Suggested Prompts

1. `Reduce latency and query count on this endpoint with measured iterations.`
2. `Benchmark the request path, regression safety, and resource cost before editing.`
3. `Improve this API bottleneck and keep only score-improving mutations.`

## Suggested Proof Commands

- endpoint benchmark or load test
- integration test
- query logging or request tracing
- smoke request for user-visible correctness

## Suggested Binary Evals

- Is the chosen proof set appropriate for an API bottleneck?
- Does the run preserve request correctness, auth, and error handling?
- Does the run track a concrete API metric such as p95 latency, query count, cache hit rate, or payload size?
- Does the artifact record the owned endpoint or service scope clearly?
- Does the run avoid claiming a win without a repeated non-regression check?
