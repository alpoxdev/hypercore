# CLI Usage

**Read condition**: Read before installing the CLI, configuring credentials, or constructing any Naver API HUB command.

## Installation

Requires Node.js 20 or newer.

```sh
node --version
npm install --global @kood/naver-api-cli
naver-api --help
```

If `naver-api` is already available, do not reinstall it. If package installation cannot run, give the commands above and stop before the API operation. Do not silently substitute a source-tree command or a different package.

## Credentials

Use the CLI's hidden interactive prompt:

```sh
naver-api config set
naver-api config validate
```

For a user-controlled non-interactive environment, credentials may be sent through stdin using this shape:

```yaml
apiKeyId: your-api-key-id
apiKey: your-api-key
```

```sh
naver-api config set --stdin < credentials.yaml
```

Do not create `credentials.yaml` in the repository. Do not put secret values in command arguments or echo them. `config show` masks values; `config validate` checks shape without a network request.

## Commands

```text
naver-api [--json] config set [--stdin]
naver-api [--json] config show
naver-api [--json] config path
naver-api [--json] config validate
naver-api [--json] config delete
naver-api [--json] trends --input <file>
naver-api [--json] shopping-insight categories --input <file>
naver-api [--json] shopping-insight keywords --input <file>
naver-api [--json] search <type> <query> [--display <count>] [--start <index>] [--sort <sort>] [--filter <filter>] [--format json]
```

Use `--input=-` (with `=`) for stdin. Do not use `--input -`; the CLI parser treats the separated `-` as a missing value.

Supported search types are `blog`, `news`, `cafearticle`, `kin`, `local`, `encyc`, `webkr`, `image`, `adult`, and `errata`. `shop`, `book`, and `doc` are retired and unsupported.

Trend input accepts YAML or JSON and uses `startDate`, `endDate`, `timeUnit`, plus the operation-specific group field: `keywordGroups`, `category`, or `keyword`. Use the package README or `naver-api --help` for the exact request schema; never guess group values.

## Output and failure handling

Use `--json` for deterministic parsing. Success writes one stdout document shaped as `{ "ok": true, "command": "...", "data": ... }`. Failure writes only stderr and no stdout.

| Exit | Meaning | Action |
|---:|---|---|
| 2 | usage | Correct the input; retry once after validation. |
| 3 | config | Correct local config; retry once after `config validate`. |
| 4 | auth | Ask the user to verify credentials; do not retry automatically. |
| 5 | rate limit | Report the limit and stop. |
| 6 | upstream | Report the upstream failure and stop. |
| 7 | network/timeout | Report network status or timeout and stop. |

Requests have a 15-second deadline. Trend ratios are normalized relative indices whose maximum is 100 within the returned comparison group; they are not search volume.

## Sources

> Repository-local sources only: `cli/packages/naver-api/README.md` and `cli/packages/naver-api/package.json`. Both were re-read against this document and checked 2026-09-21.

Derived from those files and first reviewed 2026-07-29. Recheck them whenever the package version or command surface changes.
