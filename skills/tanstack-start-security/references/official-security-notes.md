# Official Security Notes

Use this reference when the change depends on current framework or auth-stack behavior.

## TanStack Start

- Execution model: route `loader` is not a secret-safe boundary by itself; use `createServerFn` or `createServerOnlyFn` for privileged work.
- Code execution patterns: explicit server-only and client-only functions are the preferred way to prevent accidental environment leakage.
- Environment variables: secrets belong on the server; public env exposure should be intentional.

Primary docs:

- https://tanstack.com/start/latest/docs/framework/react/guide/execution-model
- https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns
- https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables
- https://tanstack.com/start/latest/docs/framework/react/guide/server-functions
- https://tanstack.com/start/latest/docs/framework/react/guide/middleware
- https://tanstack.com/router/latest/docs/guide/authenticated-routes
- https://tanstack.com/router/latest/docs/how-to/validate-search-params
- https://tanstack.com/router/latest/docs/guide/ssr

## Better Auth

- TanStack Start integration commonly uses server-side session helpers plus route `beforeLoad` for protected UI.
- `tanstackStartCookies()` should be the last Better Auth plugin when used.
- `trustedOrigins` and cross-subdomain cookie settings must be explicit when cross-origin or multi-subdomain auth flows exist.

Primary docs:

- https://www.better-auth.com/docs/integrations/tanstack
- https://www.better-auth.com/docs/installation
- https://www.better-auth.com/docs/concepts/cookies
- https://www.better-auth.com/docs/reference/security
- https://www.better-auth.com/docs/concepts/rate-limit

## Usage Note

If the repository uses a different auth provider, keep the TanStack execution-boundary rules and replace the Better Auth-specific guidance with that provider's official requirements.

## Sources

> Links checked 2026-09-22: every documentation URL listed above returned HTTP 200 on that date. No other external source was used.

- TanStack Start and TanStack Router guides (execution model, code execution patterns, environment variables, server functions, middleware, authenticated routes, search-param validation, SSR): the `Primary docs` list above under `TanStack Start`, from https://tanstack.com/
- Better Auth documentation (TanStack Start integration, installation, cookies, security, rate limit): the `Primary docs` list above under `Better Auth`, from https://www.better-auth.com/
- The `Usage Note` section is this package's own guidance for non-Better-Auth stacks and cites no external source.
