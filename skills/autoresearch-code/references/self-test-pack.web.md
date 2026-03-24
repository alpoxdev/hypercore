# Web Pack

Use this pack when the bottleneck is mainly frontend rendering, bundle size, navigation speed, or user-visible web performance.

## Suggested Prompts

1. `Reduce the main route's loading cost and keep visible behavior unchanged.`
2. `Benchmark bundle size, Core Web Vitals proxies, and regression safety before editing.`
3. `Improve this frontend bottleneck with measured iterations and keep only score-improving changes.`

## Suggested Proof Commands

- production build
- bundle analysis command
- smoke route or E2E check
- any existing perf script or synthetic vitals check

## Suggested Binary Evals

- Is the chosen proof set appropriate for a web bottleneck?
- Does the run preserve visible behavior on the target route?
- Does the run track a concrete resource metric such as bundle size, LCP proxy, INP proxy, or request count?
- Does the artifact record the owned route or app scope clearly?
- Does the run avoid claiming a win without a repeated non-regression check?
