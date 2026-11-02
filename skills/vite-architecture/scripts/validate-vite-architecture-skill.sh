#!/usr/bin/env bash
# Validate the vite-architecture skill folder anatomy.
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
root=$(normalize_path "$cwd/skills/vite-architecture")

required=(
  'SKILL.md'
  'SKILL.ko.md'
  'architecture-rules.md'
  'architecture-rules.ko.md'
  'rules/conventions.md'
  'rules/conventions.ko.md'
  'rules/routes.md'
  'rules/routes.ko.md'
  'rules/services.md'
  'rules/services.ko.md'
  'rules/hooks.md'
  'rules/hooks.ko.md'
  'rules/execution-model.md'
  'rules/execution-model.ko.md'
  'rules/platform.md'
  'rules/platform.ko.md'
  'rules/validation.md'
  'rules/validation.ko.md'
  'references/official/current-docs-2026-06-02.md'
  'references/official/current-docs-2026-06-02.ko.md'
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

check_phrases 'SKILL.md' 'instruction_contract' 'activation_examples' 'routing_rule' 'rules/validation.md' 'current-docs-2026-06-02' 'src/lib' 'src/services'
check_phrases 'SKILL.ko.md' 'instruction_contract' 'activation_examples' 'routing_rule' 'rules/validation.ko.md' 'current-docs-2026-06-02' 'src/lib' 'src/services'
check_phrases 'architecture-rules.md' 'Shared Nested Folder Grouping' 'src/lib/<domain>' 'src/services/<domain-or-provider>' 'direct leaf' 'repo-local convention' 'not official Vite' 'routeTree.gen.ts'
check_phrases 'rules/services.md' 'services/<domain>' 'services/<domain-or-provider>' 'direct leaf' 'services/index.ts' 'VITE_API_URL'
check_phrases 'rules/platform.md' 'tanstackRouter' 'react()' 'routeTree.gen.ts' 'current-docs-2026-06-02' 'VITE_*'
check_phrases 'rules/validation.md' 'Skill Anatomy Validation' 'current-docs-2026-06-02' 'src/services' 'direct leaf' 'Deprecated feature-folder guidance is absent'
check_phrases 'references/official/current-docs-2026-06-02.md' 'checked_at: 2026-06-02' '/websites/vite_dev' '/tanstack/router' 'VITE_' 'loadEnv' 'tanstackRouter' 'routeTree.gen.ts' 'validateSearch' 'zodValidator' 'not official Vite'

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
walk "$root"

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

if [ ! -e "$root/SKILL.md" ]; then
  echo "vite-architecture: cannot read $root/SKILL.md" >&2
  exit 1
fi

skill_text=''
IFS= read -r -d '' skill_text <"$root/SKILL.md" || true
skill_lines=$(printf '%s' "$skill_text" | jq -Rs 'split("\n") | length')
if [ "$skill_lines" -gt 330 ]; then
  add_error "SKILL.md too long: $skill_lines lines > 330"
fi

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
  echo 'vite-architecture skill validation failed:' >&2
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
