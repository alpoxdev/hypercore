# Web Pack

Use this pack when the bottleneck is frontend rendering, bundle size, navigation speed, or user-visible web performance.

## Recommended Prompts

1. `Reduce the main route's loading cost while preserving visible behavior.`
2. `Before editing, benchmark bundle size, Core Web Vitals proxies, and regression safety.`
3. `Improve this frontend bottleneck through measurable iterative experiments and keep only score-improving changes.`

## Recommended Proof Command

- production build
- bundle analysis command
- smoke route or E2E check
- existing perf script or synthetic vitals check

## Recommended Binary Eval

- Is the selected proof set appropriate for the web bottleneck?
- Does the run preserve the visible behavior of the target route?
- Does it track concrete resource metrics such as bundle size, LCP proxy, INP proxy, and request count?
- Does the artifact clearly record the owned route or app scope?
- Does it avoid claiming success without repeated no-regression checks?
