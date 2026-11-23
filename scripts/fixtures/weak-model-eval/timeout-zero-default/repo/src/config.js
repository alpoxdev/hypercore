// timeoutMs: 0 disables the timeout; a missing value falls back to 30 seconds.
export function readTimeout(options = {}) {
  return options.timeoutMs || 30000;
}
