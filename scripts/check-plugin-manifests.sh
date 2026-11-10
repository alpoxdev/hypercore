#!/usr/bin/env bash
# check-plugin-manifests.sh — validate the Codex, Claude Code and Cursor plugin
# manifests.
#
# Usage: check-plugin-manifests.sh [repository-root]
#
# Checks (needs jq):
#   - .codex-plugin/plugin.json, .claude-plugin/plugin.json,
#     .claude-plugin/marketplace.json and .cursor-plugin/plugin.json are valid
#     JSON objects.
#   - All three plugin manifests share name, SemVer version, description,
#     homepage, repository, license, author and keywords.
#   - The marketplace lists the plugin once, under the manifest name, with a
#     relative source that starts with ./ and has no "..", and no version
#     (plugin.json is the single version source).
#   - Every skill directory under the plugin skills path has a SKILL.md whose
#     frontmatter name equals the directory name and whose description fits the
#     Claude Code skill listing cap (1,536 characters).
#
# Exits 1 with "plugin manifest validation failed: <reason>" on stderr at the
# first failed check.
set -o pipefail
export LC_ALL=C

ROOT=${1:-$(cd "$(dirname "$0")/.." && pwd)} || exit 1
CODEX=$ROOT/.codex-plugin/plugin.json
CLAUDE=$ROOT/.claude-plugin/plugin.json
MARKET=$ROOT/.claude-plugin/marketplace.json
CURSOR=$ROOT/.cursor-plugin/plugin.json
DESCRIPTION_CAP=1536

fail() {
  printf 'plugin manifest validation failed: %s\n' "$1" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || fail "jq is required"

for file in "$CODEX" "$CLAUDE" "$MARKET" "$CURSOR"; do
  [ -f "$file" ] || fail "${file#"$ROOT"/} is missing"
  jq -e 'type == "object"' "$file" >/dev/null 2>&1 || fail "${file#"$ROOT"/} is not a valid JSON object"
done

name=$(jq -r '.name // empty' "$CLAUDE")
[ -n "$name" ] || fail ".claude-plugin/plugin.json has no name"

version=$(jq -r '.version // empty' "$CLAUDE")
semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'
printf '%s' "$version" | grep -Eq -- "$semver" || fail ".claude-plugin/plugin.json version '$version' is not SemVer"

for other in "$CODEX" "$CURSOR"; do
  label=$(basename -- "$(dirname -- "$other")")
  [ "$(jq -r '.name // empty' "$other")" = "$name" ] || fail "plugin name differs between $label and .claude-plugin"
  [ "$(jq -r '.version // empty' "$other")" = "$version" ] || fail "version differs between $label and .claude-plugin"
  for field in description homepage repository license author keywords; do
    [ "$(jq -c --arg f "$field" '.[$f]' "$other")" = "$(jq -c --arg f "$field" '.[$f]' "$CLAUDE")" ] \
      || fail "$field differs between $label and .claude-plugin"
  done
done

[ "$(jq -r '.name // empty' "$MARKET")" != "" ] || fail "marketplace.json has no name"
jq -e '.owner.name | type == "string" and length > 0' "$MARKET" >/dev/null || fail "marketplace.json owner.name is missing"
[ "$(jq -r '.plugins | if type == "array" then length else -1 end' "$MARKET")" = "1" ] || fail "marketplace.json must list exactly one plugin"
[ "$(jq -r '.plugins[0].name // empty' "$MARKET")" = "$name" ] || fail "marketplace entry name differs from plugin name '$name'"
jq -e '.plugins[0] | has("version") | not' "$MARKET" >/dev/null || fail "marketplace entry must not set version (plugin.json is the version source)"

source_path=$(jq -r '.plugins[0].source // empty' "$MARKET")
case $source_path in
  ./*) ;;
  *) fail "marketplace entry source '$source_path' must be a relative path starting with ./" ;;
esac
case /$source_path/ in
  */../*) fail "marketplace entry source '$source_path' must not contain .." ;;
esac
plugin_root=$ROOT/${source_path#./}
[ -d "$plugin_root" ] || fail "marketplace entry source '$source_path' does not exist"
[ "$(cd "$plugin_root" && pwd -P)" = "$(cd "$ROOT" && pwd -P)" ] || fail "marketplace entry source '$source_path' must resolve to the repository root"

codex_skills=$(jq -r '.skills // empty' "$CODEX")
[ "$codex_skills" = "./skills/" ] || fail ".codex-plugin skills path '$codex_skills' must be ./skills/"
jq -e 'has("skills") | not' "$CLAUDE" >/dev/null || fail ".claude-plugin/plugin.json must rely on the default skills/ directory"
jq -e 'has("skills") | not' "$CURSOR" >/dev/null || fail ".cursor-plugin/plugin.json must rely on the default skills/ directory"

count=0
for dir in "$ROOT"/skills/*/; do
  [ -d "$dir" ] || continue
  dir_name=$(basename -- "$dir")
  skill=$dir/SKILL.md
  [ -f "$skill" ] || fail "skills/$dir_name/SKILL.md is missing"
  skill_name=$(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} /^name:/{sub(/^name:[ ]*/,"");gsub(/^"|"$/,"");print;exit}' "$skill")
  [ "$skill_name" = "$dir_name" ] || fail "skills/$dir_name/SKILL.md name '$skill_name' differs from its directory"
  desc_len=$(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} /^description:/{sub(/^description:[ ]*/,"");gsub(/^"|"$/,"");print length($0);exit}' "$skill")
  [ -n "$desc_len" ] || fail "skills/$dir_name/SKILL.md has no single-line description"
  [ "$desc_len" -le "$DESCRIPTION_CAP" ] || fail "skills/$dir_name/SKILL.md description is $desc_len characters (cap $DESCRIPTION_CAP)"
  # Claude Code parses frontmatter as YAML; a double-quoted scalar with an
  # invalid escape such as \. makes the whole frontmatter load as empty.
  if sed -n '2,/^---$/p' "$skill" | grep -Eq '^[A-Za-z_-]+: ".*\\[^0abtnvfre "/\\N_LPxuU]'; then
    fail "skills/$dir_name/SKILL.md frontmatter has an invalid YAML escape in a double-quoted value"
  fi
  count=$((count + 1))
done
[ "$count" -gt 0 ] || fail "skills/ has no skill directories"

printf 'plugin manifests: ok (%s %s, %s skills)\n' "$name" "$version" "$count"
