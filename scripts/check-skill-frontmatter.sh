#!/usr/bin/env bash
# check-skill-frontmatter.sh — strictly parse and validate YAML frontmatter of
# every skill's SKILL.md (and SKILL.ko.md when present).
#
# Usage:
#   bash scripts/check-skill-frontmatter.sh [--root <skills-dir>] [--canonical-only]
#
# Checks:
#   - Frontmatter opens on line 1 with --- and closes with ---.
#   - Strict YAML parsing (PyYAML via python3, or Psych via ruby) succeeds with
#     no duplicate keys, no tab indentation, and no unquoted inline ' #'
#     comment truncation.
#   - Root parses to a mapping; name is a string matching the skill folder name;
#     description is a non-empty string; compatibility and license, when
#     present, are non-empty strings.
#
# Exit codes: 0 ok, 1 validation failure, 2 configuration/usage/parser error.
set -uo pipefail

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
REPO_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)

ROOT_DIR=$REPO_ROOT/skills
CANONICAL_ONLY=0
SHOW_HELP=0

print_help() {
  cat <<'EOF'
Usage: bash scripts/check-skill-frontmatter.sh [--root <skills-dir>] [--canonical-only]

Strictly parses YAML frontmatter for every skill directory under <skills-dir>
(default: skills/) using PyYAML (python3) or Psych (ruby).

Options:
  --root <dir>      Directory containing top-level skill folders (default: skills)
  --canonical-only  Check SKILL.md only (default checks SKILL.md and SKILL.ko.md)
  -h, --help        Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case $1 in
    --root)
      if [ "$#" -lt 2 ] || [ -z "$2" ] || [ "${2#--}" != "$2" ]; then
        printf 'skill frontmatter: --root requires a value\n' >&2
        exit 2
      fi
      ROOT_DIR=$2
      shift 2
      ;;
    --canonical-only)
      CANONICAL_ONLY=1
      shift
      ;;
    -h|--help)
      SHOW_HELP=1
      shift
      ;;
    *)
      printf 'skill frontmatter: unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

if [ "$SHOW_HELP" -eq 1 ]; then
  print_help
  exit 0
fi

if [ ! -d "$ROOT_DIR" ]; then
  printf 'skill frontmatter: skills root is not a directory: %s\n' "$ROOT_DIR" >&2
  exit 2
fi

run_python() {
  python3 - "$ROOT_DIR" "$CANONICAL_ONLY" <<'PY'
import os
import re
import sys
import yaml

root_dir = sys.argv[1]
canonical_only = sys.argv[2] == "1"


class UniqueKeyLoader(yaml.SafeLoader):
    pass


def construct_unique_mapping(loader, node, deep=False):
    mapping = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            line = key_node.start_mark.line + 2
            raise yaml.constructor.ConstructorError(
                "while constructing a mapping",
                node.start_mark,
                f"duplicate key {key!r} at line {line}",
                key_node.start_mark,
            )
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_unique_mapping,
)

KV_RE = re.compile(r"^([A-Za-z0-9_-]+):[ \t]*(.*)$")
BLOCK_SCALAR_RE = re.compile(r"^[|>][+-]?[0-9]*([ \t]+#.*)?$")


def check_line_hazards(fm_lines):
    errs = []
    block_indent = None
    for idx, line in enumerate(fm_lines, start=2):
        stripped_leading = line.lstrip(" ")
        if stripped_leading.startswith("\t"):
            errs.append(f"line {idx}: tab indentation is forbidden in YAML frontmatter")
            continue
        indent = len(line) - len(stripped_leading)
        if block_indent is not None:
            if line.strip() == "" or indent > block_indent:
                continue
            block_indent = None
        if not stripped_leading or stripped_leading.startswith("#"):
            continue
        m = KV_RE.match(stripped_leading)
        if m:
            key, val = m.group(1), m.group(2)
            if BLOCK_SCALAR_RE.match(val):
                block_indent = indent
                continue
            if not val or val[0] in ('"', "'", "[", "{"):
                continue
            if " #" in val:
                errs.append(
                    f"line {idx}: unquoted value for '{key}' contains ' #' which YAML parses as a comment; quote the value"
                )
    return errs


def validate_file(file_path, display_path, folder_name):
    errs = []
    try:
        with open(file_path, "r", encoding="utf-8") as fh:
            text = fh.read()
    except OSError as exc:
        return [f"{display_path}: cannot read file: {exc}"]

    lines = text.splitlines()
    if not lines or lines[0] != "---":
        return [f"{display_path}: line 1 must be '---' to open YAML frontmatter"]

    end_idx = None
    for i in range(1, len(lines)):
        if lines[i] == "---":
            end_idx = i
            break
    if end_idx is None:
        return [f"{display_path}: YAML frontmatter is not closed with '---'"]

    fm_lines = lines[1:end_idx]
    for hazard in check_line_hazards(fm_lines):
        errs.append(f"{display_path}: {hazard}")

    fm_text = "\n".join(fm_lines)
    try:
        data = yaml.load(fm_text, Loader=UniqueKeyLoader)
    except yaml.YAMLError as exc:
        msg = str(exc).splitlines()[0]
        if hasattr(exc, "problem") and exc.problem:
            mark = getattr(exc, "problem_mark", None)
            if mark is not None:
                msg = f"YAML parse error at line {mark.line + 2}, col {mark.column + 1}: {exc.problem}"
            else:
                msg = f"YAML parse error: {exc.problem}"
        errs.append(f"{display_path}: {msg}")
        return errs

    if not isinstance(data, dict):
        errs.append(
            f"{display_path}: frontmatter must be a YAML mapping, got {type(data).__name__}"
        )
        return errs

    name = data.get("name")
    if "name" not in data:
        errs.append(f"{display_path}: missing required key 'name'")
    elif not isinstance(name, str) or not name.strip():
        errs.append(
            f"{display_path}: 'name' must be a non-empty string, got {type(name).__name__}"
        )
    elif name != folder_name:
        errs.append(
            f"{display_path}: 'name' ({name!r}) does not match folder name ({folder_name!r})"
        )

    desc = data.get("description")
    if "description" not in data:
        errs.append(f"{display_path}: missing required key 'description'")
    elif not isinstance(desc, str) or not desc.strip():
        errs.append(
            f"{display_path}: 'description' must be a non-empty string, got {type(desc).__name__}"
        )

    for opt_key in ("compatibility", "license"):
        if opt_key in data:
            val = data[opt_key]
            if not isinstance(val, str) or not val.strip():
                errs.append(
                    f"{display_path}: '{opt_key}' must be a non-empty string, got {type(val).__name__}"
                )

    return errs


skill_dirs = sorted(
    entry
    for entry in os.listdir(root_dir)
    if not entry.startswith(".")
    and not os.path.islink(os.path.join(root_dir, entry))
    and os.path.isdir(os.path.join(root_dir, entry))
)

if not skill_dirs:
    print(f"skill frontmatter: no skill directories found under {root_dir}", file=sys.stderr)
    sys.exit(1)

all_errors = []
checked_files = 0
for folder in skill_dirs:
    skill_dir = os.path.join(root_dir, folder)
    canonical = os.path.join(skill_dir, "SKILL.md")
    if not os.path.isfile(canonical):
        all_errors.append(f"{folder}/SKILL.md: missing SKILL.md")
        continue
    targets = [("SKILL.md", canonical)]
    if not canonical_only:
        ko = os.path.join(skill_dir, "SKILL.ko.md")
        if os.path.isfile(ko):
            targets.append(("SKILL.ko.md", ko))
    for fname, fpath in targets:
        checked_files += 1
        all_errors.extend(validate_file(fpath, f"{folder}/{fname}", folder))

if all_errors:
    for err in all_errors:
        print(f"FAIL {err}", file=sys.stderr)
    print(
        f"skill frontmatter: failed ({len(all_errors)} error(s) across {checked_files} file(s), {len(skill_dirs)} skill(s); parser: python3-pyyaml)",
        file=sys.stderr,
    )
    sys.exit(1)

print(
    f"skill frontmatter: ok ({checked_files} file(s) across {len(skill_dirs)} skill(s); parser: python3-pyyaml)"
)
PY
}

run_ruby() {
  ruby -ryaml - "$ROOT_DIR" "$CANONICAL_ONLY" <<'RB'
root_dir = ARGV[0]
canonical_only = ARGV[1] == "1"

KV_RE = /\A([A-Za-z0-9_-]+):[ \t]*(.*)\z/
BLOCK_SCALAR_RE = /\A[|>][+-]?[0-9]*([ \t]+#.*)?\z/

def check_line_hazards(fm_lines)
  errs = []
  block_indent = nil
  fm_lines.each_with_index do |line, i|
    line_no = i + 2
    stripped_leading = line.sub(/\A +/, "")
    if stripped_leading.start_with?("\t")
      errs << "line #{line_no}: tab indentation is forbidden in YAML frontmatter"
      next
    end
    indent = line.length - stripped_leading.length
    if block_indent
      next if line.strip.empty? || indent > block_indent
      block_indent = nil
    end
    next if stripped_leading.empty? || stripped_leading.start_with?("#")
    if (m = KV_RE.match(stripped_leading))
      key, val = m[1], m[2]
      if BLOCK_SCALAR_RE.match?(val)
        block_indent = indent
        next
      end
      next if val.empty? || ['"', "'", "[", "{"].include?(val[0])
      if val.include?(" #")
        errs << "line #{line_no}: unquoted value for '#{key}' contains ' #' which YAML parses as a comment; quote the value"
      end
    end
  end
  errs
end

def find_duplicate_keys(node, errs, display_path)
  return unless node
  if node.is_a?(Psych::Nodes::Mapping)
    seen = {}
    node.children.each_slice(2) do |k_node, v_node|
      key = k_node.respond_to?(:value) ? k_node.value : k_node.to_ruby
      if seen.key?(key)
        line_no = (k_node.start_line || 0) + 2
        errs << "#{display_path}: duplicate key #{key.inspect} at line #{line_no}"
      else
        seen[key] = true
      end
      find_duplicate_keys(v_node, errs, display_path)
    end
  elsif node.respond_to?(:children) && node.children
    node.children.each { |child| find_duplicate_keys(child, errs, display_path) }
  end
end

def validate_file(file_path, display_path, folder_name)
  errs = []
  begin
    text = File.read(file_path, encoding: "UTF-8")
  rescue => exc
    return ["#{display_path}: cannot read file: #{exc.message}"]
  end

  lines = text.gsub(/\r\n/, "\n").split("\n", -1)
  if lines.empty? || lines[0] != "---"
    return ["#{display_path}: line 1 must be '---' to open YAML frontmatter"]
  end

  end_idx = nil
  (1...lines.length).each do |i|
    if lines[i] == "---"
      end_idx = i
      break
    end
  end
  if end_idx.nil?
    return ["#{display_path}: YAML frontmatter is not closed with '---'"]
  end

  fm_lines = lines[1...end_idx]
  check_line_hazards(fm_lines).each { |h| errs << "#{display_path}: #{h}" }

  fm_text = fm_lines.join("\n")
  begin
    doc = Psych.parse(fm_text)
    find_duplicate_keys(doc, errs, display_path)
    data = Psych.safe_load(fm_text)
  rescue Psych::SyntaxError => exc
    line_no = (exc.line || 0) + 1
    col_no = (exc.column || 0) + 1
    errs << "#{display_path}: YAML parse error at line #{line_no}, col #{col_no}: #{exc.problem}"
    return errs
  rescue => exc
    errs << "#{display_path}: YAML parse error: #{exc.message}"
    return errs
  end

  unless data.is_a?(Hash)
    errs << "#{display_path}: frontmatter must be a YAML mapping, got #{data.class}"
    return errs
  end

  if !data.key?("name")
    errs << "#{display_path}: missing required key 'name'"
  elsif !data["name"].is_a?(String) || data["name"].strip.empty?
    errs << "#{display_path}: 'name' must be a non-empty string, got #{data['name'].class}"
  elsif data["name"] != folder_name
    errs << "#{display_path}: 'name' (#{data['name'].inspect}) does not match folder name (#{folder_name.inspect})"
  end

  if !data.key?("description")
    errs << "#{display_path}: missing required key 'description'"
  elsif !data["description"].is_a?(String) || data["description"].strip.empty?
    errs << "#{display_path}: 'description' must be a non-empty string, got #{data['description'].class}"
  end

  %w[compatibility license].each do |opt_key|
    next unless data.key?(opt_key)
    val = data[opt_key]
    if !val.is_a?(String) || val.strip.empty?
      errs << "#{display_path}: '#{opt_key}' must be a non-empty string, got #{val.class}"
    end
  end

  errs
end

skill_dirs = Dir.children(root_dir).sort.select do |entry|
  next false if entry.start_with?(".")
  full = File.join(root_dir, entry)
  !File.symlink?(full) && File.directory?(full)
end

if skill_dirs.empty?
  warn "skill frontmatter: no skill directories found under #{root_dir}"
  exit 1
end

all_errors = []
checked_files = 0
skill_dirs.each do |folder|
  skill_dir = File.join(root_dir, folder)
  canonical = File.join(skill_dir, "SKILL.md")
  unless File.file?(canonical)
    all_errors << "#{folder}/SKILL.md: missing SKILL.md"
    next
  end
  targets = [["SKILL.md", canonical]]
  unless canonical_only
    ko = File.join(skill_dir, "SKILL.ko.md")
    targets << ["SKILL.ko.md", ko] if File.file?(ko)
  end
  targets.each do |fname, fpath|
    checked_files += 1
    all_errors.concat(validate_file(fpath, "#{folder}/#{fname}", folder))
  end
end

if !all_errors.empty?
  all_errors.each { |e| warn "FAIL #{e}" }
  warn "skill frontmatter: failed (#{all_errors.length} error(s) across #{checked_files} file(s), #{skill_dirs.length} skill(s); parser: ruby-psych)"
  exit 1
end

puts "skill frontmatter: ok (#{checked_files} file(s) across #{skill_dirs.length} skill(s); parser: ruby-psych)"
RB
}

if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
  run_python
elif command -v ruby >/dev/null 2>&1 && ruby -ryaml -e 'Psych' >/dev/null 2>&1; then
  run_ruby
else
  printf 'skill frontmatter: no strict YAML parser available (install python3 PyYAML or ruby)\n' >&2
  exit 2
fi
