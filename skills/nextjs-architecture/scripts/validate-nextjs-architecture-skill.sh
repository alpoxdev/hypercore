#!/usr/bin/env bash
# Validate the nextjs-architecture skill folder anatomy.
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
root=$(normalize_path "$cwd/skills/nextjs-architecture")

required=(
  'SKILL.md'
  'SKILL.ko.md'
  'architecture-rules.md'
  'architecture-rules.ko.md'
  'rules/project-structure.md'
  'rules/project-structure.ko.md'
  'rules/services.md'
  'rules/services.ko.md'
  'rules/hooks.md'
  'rules/hooks.ko.md'
  'rules/db.md'
  'rules/db.ko.md'
  'rules/routes.md'
  'rules/routes.ko.md'
  'rules/execution-model.md'
  'rules/execution-model.ko.md'
  'rules/data-fetching.md'
  'rules/data-fetching.ko.md'
  'rules/server-actions.md'
  'rules/server-actions.ko.md'
  'rules/route-handlers.md'
  'rules/route-handlers.ko.md'
  'rules/platform.md'
  'rules/platform.ko.md'
  'references/official/nextjs-docs.md'
  'references/official/nextjs-docs.ko.md'
  'references/official/current-docs-2026-06-02.md'
  'references/official/current-docs-2026-06-02.ko.md'
  'references/official/drizzle-docs.md'
  'references/official/drizzle-docs.ko.md'
  'rules/validation.md'
  'rules/validation.ko.md'
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

check_phrases 'SKILL.md' 'cacheComponents' 'updateTag' 'Route Handlers' 'Proxy' 'Server Action' 'rules/project-structure.md' 'rules/services.md' 'rules/hooks.md' 'rules/db.md' 'references/official/drizzle-docs.md' 'instruction_contract' 'activation_examples' 'current-docs-2026-06-02'
check_phrases 'SKILL.ko.md' 'cacheComponents' 'updateTag' 'Route Handlers' 'Proxy' 'Server Action' 'rules/project-structure.ko.md' 'rules/services.ko.md' 'rules/hooks.ko.md' 'rules/db.ko.md' 'references/official/drizzle-docs.ko.md' 'instruction_contract' 'activation_examples' 'current-docs-2026-06-02'
check_phrases 'architecture-rules.md' 'Current Official Baselines' 'latest checked Next.js 16' 'cacheComponents' 'connection()' 'updateTag' 'middleware' 'Layer Taxonomy' 'src/modules' 'src/db' 'Drizzle schema/config/migrations' 'rules/project-structure.md' 'rules/services.md' 'rules/hooks.md' 'rules/db.md' 'current-docs-2026-06-02'
check_phrases 'architecture-rules.ko.md' '현재 공식 기준선' 'Cache Components' 'connection()' 'updateTag' 'middleware' 'Layer Taxonomy' 'src/modules' 'src/db' 'Drizzle schema/config/migrations' 'rules/project-structure.ko.md' 'rules/services.ko.md' 'rules/hooks.ko.md' 'rules/db.ko.md'
check_phrases 'rules/project-structure.md' 'Project Structure' 'Nested Shared Folder Grouping' 'src/modules' 'src/lib' 'src/services' 'src/db' 'src/server' 'src/integrations' 'src/config' 'direct leaf' 'private folders' 'Hypercore local convention' 'not official Next.js requirement'
check_phrases 'rules/project-structure.ko.md' 'Project Structure' 'Nested Shared Folder Grouping' 'src/modules' 'src/services' 'src/db' 'src/server' 'src/integrations' 'src/config' 'direct leaf' 'private folders' 'Hypercore local convention' 'official Next.js requirement'
check_phrases 'rules/services.md' 'Services, DAL, and Provider Boundaries' 'DAL/service/provider boundaries' 'DTO' 'authorization' 'server-only helper' 'Route Handlers are public HTTP endpoints' 'src/integrations/<provider>'
check_phrases 'rules/services.ko.md' 'Services, DAL, Provider Boundaries' 'DAL/service/provider layering' 'DTO' 'authorization' 'server-only helper' 'Route Handlers는 public HTTP endpoints' 'src/integrations/<provider>'
check_phrases 'rules/hooks.md' 'Client Hooks and Orchestration Boundaries' 'client orchestration' 'server/data layers' 'Drizzle schema' 'private env' 'Server Action'
check_phrases 'rules/hooks.ko.md' 'Client Hooks and Orchestration Boundaries' 'client orchestration' 'server/data layer' 'Drizzle schema' 'private env' 'Server Action'
check_phrases 'rules/db.md' 'Database and Drizzle Boundaries' 'Drizzle schema' 'drizzle.config.ts' 'generate' 'migrate' 'prepared statements' 'RQB' 'validation integrations' 'Hypercore local convention'
check_phrases 'rules/db.ko.md' 'Database and Drizzle Boundaries' 'Drizzle schema' 'drizzle.config.ts' 'generate' 'migrate' 'prepared statements' 'RQB' 'validation integrations' 'Hypercore local convention'
# shellcheck disable=SC2016 # needles are matched literally, not expanded
check_phrases 'rules/data-fetching.md' '`fetch` requests are not cached by default' 'use cache: remote' 'use cache: private' 'connection()' 'unstable_noStore' 'updateTag' "revalidateTag(tag, 'max')"
check_phrases 'rules/server-actions.md' 'reachable POST entry point' 'useActionState' 'refresh' 'updateTag'
check_phrases 'rules/route-handlers.md' 'HTTP method exports' 'RouteContext' 'params' 'cacheComponents' 'use cache' 'NextResponse.next()'
check_phrases 'rules/platform.md' 'Route Segment Config' "runtime: 'edge'" 'proxy.ts' 'Node.js runtime' 'middleware'
check_phrases 'references/official/nextjs-docs.md' 'Last verified: 2026-05-24' 'Next.js 16.2.6' 'https://r.jina.ai/https://nextjs.org/docs/' 'use cache: remote' 'Route Segment Config' 'Authentication' 'authInterrupts'
check_phrases 'references/official/current-docs-2026-06-02.md' 'checked_at: 2026-06-02' '/vercel/next.js' 'Next.js 16' 'cacheComponents' 'use cache: remote' 'Server Actions' 'Route Handlers' 'proxy.ts' 'NEXT_PUBLIC_' 'not official Next.js requirement'
check_phrases 'references/official/drizzle-docs.md' 'Official Drizzle Docs Summary' 'Drizzle schema' 'drizzle.config.ts' 'out' 'drizzle-kit generate' 'drizzle-kit migrate' 'push' 'pull' 'prepared statement' 'RQB' 'validation integrations'
check_phrases 'references/official/drizzle-docs.ko.md' 'Official Drizzle Docs Summary' 'Drizzle schema' 'drizzle.config.ts' 'out' 'drizzle-kit generate' 'drizzle-kit migrate' 'push' 'pull' 'prepared statement' 'RQB' 'validation integrations'
check_phrases 'rules/validation.md' 'Skill Anatomy Validation' 'current-docs-2026-06-02' 'src/services' 'src/modules' 'src/db' 'direct leaf' 'Deprecated feature-folder guidance is absent' 'Korean parity' 'source-only' 'no adapter'
check_phrases 'rules/validation.ko.md' 'Skill Anatomy Validation' 'current-docs-2026-06-02' 'src/services' 'src/modules' 'src/db' 'direct leaf' 'Deprecated feature-folder guidance is absent' 'Korean parity' 'source-only' 'no adapter'
if [ ! -e "$root/SKILL.md" ]; then
  echo "nextjs-architecture: cannot read $root/SKILL.md" >&2
  exit 1
fi

skill_text=''
IFS= read -r -d '' skill_text <"$root/SKILL.md" || true
skill_lines=$(printf '%s' "$skill_text" | jq -Rs 'split("\n") | length')
if [ "$skill_lines" -gt 300 ]; then
  add_error "SKILL.md too long: $skill_lines lines > 300"
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
walk "$root"

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
    *"../"*) add_error "upward reference not allowed in SKILL.md: $link" ;;
  esac
  slashes=$(printf '%s' "$link" | tr -cd '/' | wc -c | tr -d ' ')
  if [ "$slashes" -ge 3 ]; then
    add_error "reference chain too deep from SKILL.md: $link"
  fi
done <<EOF
$(printf '%s' "$skill_text" | jq -Rrs '[scan("`([^`]+\\.md)`")] | .[] | .[0]')
EOF

if [ "${#errors[@]}" -ne 0 ]; then
  echo 'nextjs-architecture skill validation failed:' >&2
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
