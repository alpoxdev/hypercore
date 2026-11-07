#!/usr/bin/env bash
# Validate the Vite + TanStack Router stack files inside the hyper-architecture skill folder.
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
  'stacks/vite/core.md'
  'stacks/vite/core.ko.md'
  'stacks/vite/architecture-rules.md'
  'stacks/vite/architecture-rules.ko.md'
  'rules/vite/conventions.md'
  'rules/vite/conventions.ko.md'
  'rules/vite/routes.md'
  'rules/vite/routes.ko.md'
  'rules/vite/services.md'
  'rules/vite/services.ko.md'
  'rules/vite/hooks.md'
  'rules/vite/hooks.ko.md'
  'rules/vite/execution-model.md'
  'rules/vite/execution-model.ko.md'
  'rules/vite/platform.md'
  'rules/vite/platform.ko.md'
  'rules/vite/validation.md'
  'rules/vite/validation.ko.md'
  'references/official/vite/current-docs-2026-11-04.md'
  'references/official/vite/current-docs-2026-11-04.ko.md'
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

check_phrases 'stacks/vite/core.md' 'instruction_contract' 'activation_examples' 'routing_rule' 'rules/vite/validation.md' 'current-docs-2026-11-04' 'src/lib' 'src/services'
check_phrases 'stacks/vite/core.ko.md' 'instruction_contract' 'activation_examples' 'routing_rule' 'rules/vite/validation.ko.md' 'current-docs-2026-11-04' 'src/lib' 'src/services'
check_phrases 'stacks/vite/architecture-rules.md' 'Shared Nested Folder Grouping' 'src/lib/<domain>' 'src/services/<domain-or-provider>' 'direct leaf' 'repo-local convention' 'not official Vite' 'routeTree.gen.ts'
check_phrases 'rules/vite/services.md' 'services/<domain>' 'services/<domain-or-provider>' 'direct leaf' 'services/index.ts' 'VITE_API_URL'
check_phrases 'rules/vite/platform.md' 'tanstackRouter' 'react()' 'routeTree.gen.ts' 'current-docs-2026-11-04' 'VITE_*'
check_phrases 'rules/vite/validation.md' 'Skill Anatomy Validation' 'current-docs-2026-11-04' 'src/services' 'direct leaf' 'Deprecated feature-folder guidance is absent'
check_phrases 'references/official/vite/current-docs-2026-11-04.md' 'checked_at: 2026-11-04' '/websites/vite_dev' '/tanstack/router' 'VITE_' 'loadEnv' 'tanstackRouter' 'routeTree.gen.ts' 'validateSearch' 'zodValidator' 'not official Vite'

forbidden=('src/features' 'features/' 'feature layer' 'features<')

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
for stack_dir in "$root/stacks/vite" "$root/rules/vite" "$root/references/official/vite"; do
  if [ -d "$stack_dir" ]; then walk "$stack_dir"; fi
done

for file in ${md_files[@]+"${md_files[@]}"}; do
  rel=${file#"$root"/}
  text=''
  IFS= read -r -d '' text <"$file" || true
  fences=$(printf '%s' "$text" | awk '{ n += gsub(/```/, "") } END { print n + 0 }')
  if [ $((fences % 2)) -ne 0 ]; then
    add_error "$rel has unbalanced code fences"
  fi
  for bad in "${forbidden[@]}"; do
    case $text in
      *"$bad"*) add_error "$rel contains forbidden feature-folder guidance: $bad" ;;
    esac
  done
  case $rel in
    *.ko.md) continue ;;
  esac
  ko_rel=${rel%.md}.ko.md
  [ -e "$root/$ko_rel" ] || add_error "$rel missing Korean sibling $ko_rel"
done

if [ ! -e "$root/stacks/vite/core.md" ]; then
  echo "hyper-architecture vite stack: cannot read $root/stacks/vite/core.md" >&2
  exit 1
fi

skill_text=''
IFS= read -r -d '' skill_text <"$root/stacks/vite/core.md" || true
skill_lines=$(printf '%s' "$skill_text" | jq -Rs 'split("\n") | length')
if [ "$skill_lines" -gt 330 ]; then
  add_error "stacks/vite/core.md too long: $skill_lines lines > 330"
fi

while IFS= read -r link; do
  [ -n "$link" ] || continue
  case $link in
    *"../"*) add_error "upward reference not allowed in stacks/vite/core.md: $link" ;;
  esac
  slashes=$(printf '%s' "$link" | tr -cd '/' | wc -c | tr -d ' ')
  if [ "$slashes" -ge 4 ]; then
    add_error "reference chain too deep from stacks/vite/core.md: $link"
  fi
done <<EOF
$(printf '%s' "$skill_text" | jq -Rrs '[scan("`([^`]+\\.md)`")] | .[] | .[0]')
EOF

if [ "${#errors[@]}" -ne 0 ]; then
  echo 'hyper-architecture vite stack validation failed:' >&2
  for error in "${errors[@]}"; do
    echo "- $error" >&2
  done
  exit 1
fi

jq -n \
  --argjson skillLines "$skill_lines" \
  --argjson checkedFiles "${#required[@]}" \
  --argjson checkedMarkdownFiles "${#md_files[@]}" \
  '{ok: true, skillLines: $skillLines, checkedFiles: $checkedFiles, checkedMarkdownFiles: $checkedMarkdownFiles, checks: ["required-files", "current-docs", "nested-shared-folders", "no-feature-guidance", "core-size", "korean-siblings", "reference-depth"]}'
