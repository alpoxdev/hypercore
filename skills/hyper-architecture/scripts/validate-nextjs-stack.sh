#!/usr/bin/env bash
# Validate the Next.js stack files inside the hyper-architecture skill folder.
# Run from the repository root. Requires bash 3.2+ and jq 1.6+.
set -euo pipefail

normalize_path() {
  printf '%s' "$1" | awk -F/ '
    {
      out = ""
      for (i = 1; i <= NF; i++) {
        part = $i
        if (part == "" || part == ".") continue
        if (part == "..") {
          if (out != "") sub(/\/[^\/]*$/, "", out)
          continue
        }
        out = out "/" part
      }
      if (out == "") out = "/"
      print out
    }'
}

cwd=$(pwd -P)
root=$(normalize_path "$cwd/skills/hyper-architecture")

required=(
  'stacks/nextjs/core.md'
  'stacks/nextjs/core.ko.md'
  'stacks/nextjs/architecture-rules.md'
  'stacks/nextjs/architecture-rules.ko.md'
  'rules/nextjs/project-structure.md'
  'rules/nextjs/project-structure.ko.md'
  'rules/nextjs/services.md'
  'rules/nextjs/services.ko.md'
  'rules/nextjs/hooks.md'
  'rules/nextjs/hooks.ko.md'
  'rules/nextjs/db.md'
  'rules/nextjs/db.ko.md'
  'rules/nextjs/routes.md'
  'rules/nextjs/routes.ko.md'
  'rules/nextjs/execution-model.md'
  'rules/nextjs/execution-model.ko.md'
  'rules/nextjs/data-fetching.md'
  'rules/nextjs/data-fetching.ko.md'
  'rules/nextjs/server-actions.md'
  'rules/nextjs/server-actions.ko.md'
  'rules/nextjs/route-handlers.md'
  'rules/nextjs/route-handlers.ko.md'
  'rules/nextjs/platform.md'
  'rules/nextjs/platform.ko.md'
  'references/official/nextjs/nextjs-docs.md'
  'references/official/nextjs/nextjs-docs.ko.md'
  'references/official/nextjs/current-docs-2026-11-04.md'
  'references/official/nextjs/current-docs-2026-11-04.ko.md'
  'references/official/nextjs/drizzle-docs.md'
  'references/official/nextjs/drizzle-docs.ko.md'
  'rules/nextjs/validation.md'
  'rules/nextjs/validation.ko.md'
)

errors=()
add_error() { errors+=("$1"); }

for rel in "${required[@]}"; do
  [ -e "$root/$rel" ] || add_error "missing required file: $rel"
done

check_phrases() { # $1 = relative file, rest = required phrases
  local rel=$1 needle
  shift
  [ -e "$root/$rel" ] || return 0
  local text=''
  IFS= read -r -d '' text <"$root/$rel" || true
  for needle in "$@"; do
    case $text in
      *"$needle"*) ;;
      *) add_error "$rel missing required phrase: $needle" ;;
    esac
  done
}

check_phrases 'stacks/nextjs/core.md' 'cacheComponents' 'updateTag' 'Route Handlers' 'Proxy' 'Server Action' 'rules/nextjs/project-structure.md' 'rules/nextjs/services.md' 'rules/nextjs/hooks.md' 'rules/nextjs/db.md' 'references/official/nextjs/drizzle-docs.md' 'instruction_contract' 'activation_examples' 'current-docs-2026-11-04'
check_phrases 'stacks/nextjs/core.ko.md' 'cacheComponents' 'updateTag' 'Route Handlers' 'Proxy' 'Server Action' 'rules/nextjs/project-structure.ko.md' 'rules/nextjs/services.ko.md' 'rules/nextjs/hooks.ko.md' 'rules/nextjs/db.ko.md' 'references/official/nextjs/drizzle-docs.ko.md' 'instruction_contract' 'activation_examples' 'current-docs-2026-11-04'
check_phrases 'stacks/nextjs/architecture-rules.md' 'Current Official Baselines' 'latest checked Next.js 16' 'cacheComponents' 'connection()' 'updateTag' 'middleware' 'Layer Taxonomy' 'src/modules' 'src/db' 'Drizzle schema/config/migrations' 'rules/nextjs/project-structure.md' 'rules/nextjs/services.md' 'rules/nextjs/hooks.md' 'rules/nextjs/db.md' 'current-docs-2026-11-04'
check_phrases 'stacks/nextjs/architecture-rules.ko.md' '현재 공식 기준선' 'Cache Components' 'connection()' 'updateTag' 'middleware' 'Layer Taxonomy' 'src/modules' 'src/db' 'Drizzle schema/config/migrations' 'rules/nextjs/project-structure.ko.md' 'rules/nextjs/services.ko.md' 'rules/nextjs/hooks.ko.md' 'rules/nextjs/db.ko.md'
check_phrases 'rules/nextjs/project-structure.md' 'Project Structure' 'Nested Shared Folder Grouping' 'src/modules' 'src/lib' 'src/services' 'src/db' 'src/server' 'src/integrations' 'src/config' 'direct leaf' 'private folders' 'Hypercore local convention' 'not official Next.js requirement'
check_phrases 'rules/nextjs/project-structure.ko.md' 'Project Structure' 'Nested Shared Folder Grouping' 'src/modules' 'src/services' 'src/db' 'src/server' 'src/integrations' 'src/config' 'direct leaf' 'private folders' 'Hypercore local convention' 'official Next.js requirement'
check_phrases 'rules/nextjs/services.md' 'Services, DAL, and Provider Boundaries' 'DAL/service/provider boundaries' 'DTO' 'authorization' 'server-only helper' 'Route Handlers are public HTTP endpoints' 'src/integrations/<provider>'
check_phrases 'rules/nextjs/services.ko.md' 'Services, DAL, Provider Boundaries' 'DAL/service/provider layering' 'DTO' 'authorization' 'server-only helper' 'Route Handlers는 public HTTP endpoints' 'src/integrations/<provider>'
check_phrases 'rules/nextjs/hooks.md' 'Client Hooks and Orchestration Boundaries' 'client orchestration' 'server/data layers' 'Drizzle schema' 'private env' 'Server Action'
check_phrases 'rules/nextjs/hooks.ko.md' 'Client Hooks and Orchestration Boundaries' 'client orchestration' 'server/data layer' 'Drizzle schema' 'private env' 'Server Action'
check_phrases 'rules/nextjs/db.md' 'Database and Drizzle Boundaries' 'Drizzle schema' 'drizzle.config.ts' 'generate' 'migrate' 'prepared statements' 'RQB' 'validation integrations' 'Hypercore local convention'
check_phrases 'rules/nextjs/db.ko.md' 'Database and Drizzle Boundaries' 'Drizzle schema' 'drizzle.config.ts' 'generate' 'migrate' 'prepared statements' 'RQB' 'validation integrations' 'Hypercore local convention'
# shellcheck disable=SC2016 # needles are matched literally, not expanded
check_phrases 'rules/nextjs/data-fetching.md' '`fetch` requests are not cached by default' 'use cache: remote' 'use cache: private' 'connection()' 'unstable_noStore' 'updateTag' "revalidateTag(tag, 'max')"
check_phrases 'rules/nextjs/server-actions.md' 'reachable POST entry point' 'useActionState' 'refresh' 'updateTag'
check_phrases 'rules/nextjs/route-handlers.md' 'HTTP method exports' 'RouteContext' 'params' 'cacheComponents' 'use cache' 'NextResponse.next()'
check_phrases 'rules/nextjs/platform.md' 'Route Segment Config' "runtime: 'edge'" 'proxy.ts' 'Node.js runtime' 'middleware'
check_phrases 'references/official/nextjs/nextjs-docs.md' 'Last verified: 2026-11-04' 'Next.js 16.4.5' 'https://r.jina.ai/https://nextjs.org/docs/' 'use cache: remote' 'Route Segment Config' 'Authentication' 'authInterrupts'
check_phrases 'references/official/nextjs/current-docs-2026-11-04.md' 'checked_at: 2026-11-04' '/vercel/next.js' 'Next.js 16' 'cacheComponents' 'use cache: remote' 'Server Actions' 'Route Handlers' 'proxy.ts' 'NEXT_PUBLIC_' 'not official Next.js requirement'
check_phrases 'references/official/nextjs/drizzle-docs.md' 'Official Drizzle Docs Summary' 'Drizzle schema' 'drizzle.config.ts' 'out' 'drizzle-kit generate' 'drizzle-kit migrate' 'push' 'pull' 'prepared statement' 'RQB' 'validation integrations'
check_phrases 'references/official/nextjs/drizzle-docs.ko.md' 'Official Drizzle Docs Summary' 'Drizzle schema' 'drizzle.config.ts' 'out' 'drizzle-kit generate' 'drizzle-kit migrate' 'push' 'pull' 'prepared statement' 'RQB' 'validation integrations'
check_phrases 'rules/nextjs/validation.md' 'Skill Anatomy Validation' 'current-docs-2026-11-04' 'src/services' 'src/modules' 'src/db' 'direct leaf' 'Deprecated feature-folder guidance is absent' 'Korean parity' 'source-only' 'no adapter'
check_phrases 'rules/nextjs/validation.ko.md' 'Skill Anatomy Validation' 'current-docs-2026-11-04' 'src/services' 'src/modules' 'src/db' 'direct leaf' 'Deprecated feature-folder guidance is absent' 'Korean parity' 'source-only' 'no adapter'
if [ ! -e "$root/stacks/nextjs/core.md" ]; then
  echo "hyper-architecture nextjs stack: cannot read $root/stacks/nextjs/core.md" >&2
  exit 1
fi

skill_text=''
IFS= read -r -d '' skill_text <"$root/stacks/nextjs/core.md" || true
skill_lines=$(printf '%s' "$skill_text" | jq -Rs 'split("\n") | length')
if [ "$skill_lines" -gt 300 ]; then
  add_error "stacks/nextjs/core.md too long: $skill_lines lines > 300"
fi

md_files=()
walk() { # $1 = directory; depth-first in raw readdir order, like node:fs readdirSync
  local dir=$1 entry
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    [ -L "$entry" ] && continue
    if [ -d "$entry" ]; then
      walk "$entry"
    elif [ -f "$entry" ]; then
      case $entry in
        *.md) md_files+=("$entry") ;;
      esac
    fi
  done < <(find "$dir" -mindepth 1 -maxdepth 1 2>/dev/null)
}
for stack_dir in "$root/stacks/nextjs" "$root/rules/nextjs" "$root/references/official/nextjs"; do
  if [ -d "$stack_dir" ]; then walk "$stack_dir"; fi
done

for file in ${md_files[@]+"${md_files[@]}"}; do
  rel=${file#"$root"/}
  case $rel in
    *.ko.md) continue ;;
  esac
  ko_rel=${rel%.md}.ko.md
  [ -e "$root/$ko_rel" ] || add_error "$rel missing Korean sibling $ko_rel"
done

while IFS= read -r link; do
  [ -n "$link" ] || continue
  case $link in
    *"../"*) add_error "upward reference not allowed in stacks/nextjs/core.md: $link" ;;
  esac
  slashes=$(printf '%s' "$link" | tr -cd '/' | wc -c | tr -d ' ')
  if [ "$slashes" -ge 4 ]; then
    add_error "reference chain too deep from stacks/nextjs/core.md: $link"
  fi
done <<EOF
$(printf '%s' "$skill_text" | jq -Rrs '[scan("`([^`]+\\.md)`")] | .[] | .[0]')
EOF

if [ "${#errors[@]}" -ne 0 ]; then
  echo 'hyper-architecture nextjs stack validation failed:' >&2
  for error in "${errors[@]}"; do
    echo "- $error" >&2
  done
  exit 1
fi

jq -n \
  --argjson skillLines "$skill_lines" \
  --argjson checkedFiles "${#required[@]}" \
  --argjson checkedMarkdownFiles "${#md_files[@]}" \
  '{ok: true, skillLines: $skillLines, checkedFiles: $checkedFiles, checkedMarkdownFiles: $checkedMarkdownFiles, checks: ["required-files", "official-baseline-phrases", "services-hooks-db-drizzle-phrases", "korean-phrase-parity", "project-structure-rule", "core-size", "korean-siblings", "reference-depth"]}'
