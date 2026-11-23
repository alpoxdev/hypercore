#!/usr/bin/env bash
# check-skill-harness.sh — enforce multi-agent portability and weak-model
# workflow-compliance harness contracts across Hypercore skills.
#
# Usage:
#   bash scripts/check-skill-harness.sh [--root <skills-dir>] [--skill <name> ...]
#
# Enforces five invariants on every selected skill (<skills-dir>/<name>):
#   (a) Required sections & weak-model harness blocks in BOTH SKILL.md & SKILL.ko.md:
#       - All 15 canonical XML sections in identical sequence
#       - Top 4-line summary before <output_language>
#         (EN: Purpose / Do not use when / Input / Output;
#          KO: 목적 / 쓰지 않을 때 / 입력 / 산출물)
#       - Trigger-first description with both positive and negative boundaries
#       - Shared guardrail reference (`instructions/harness-engineering/references/skill-common-rules*.md`)
#       - Numbered <workflow> steps where every step specifies Done when (끝 조건)
#         and Why not skip (건너뛰면 안 되는 이유)
#       - Explicit disk-state / Resume (재개) rule inside <workflow>
#       - Per-step binary Yes/No checklist (3–7 items) with rollback step target
#         (On violation / 위반 시 되돌아갈 단계)
#       - At least 3 Bad -> Good (나쁜 예 -> 좋은 예) mistake pairs in <forbidden>
#       - At least 4 `- [ ]` checkboxes in <validation>
#   (b) Forbidden environment-specific tool/host names outside allowlisted
#       runtime-mapping and provider-adapter reference files.
#   (c) Local markdown links `[label](relpath)`, concrete `../<skill>/SKILL.md`
#       sibling references, and concrete `instructions/.../*.md` references resolve.
#   (d) Per-skill size ceiling (grounded in SK-P-2 progressive disclosure and
#       check-sources.sh MAX_LINES=300 to prevent weak-model mid-prompt drop-off):
#       - SKILL.md <= 300 lines and <= 5,500 est. tokens (chars / 4 <= 5500, i.e. <= 22,000 chars)
#       - SKILL.ko.md <= 300 lines and <= 5,500 est. tokens (chars / 3.2 <= 5500, i.e. <= 17,600 chars)
#   (e) Exact EN vs KO parity on <workflow> step numbers, Yes/No checklist item
#       count, and <validation> checkbox count.
#
# Exit codes: 0 ok, 1 validation failure, 2 usage/configuration error.
set -uo pipefail

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
REPO_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)

ROOT_DIR=$REPO_ROOT/skills
SELECTED_SKILLS=()
SHOW_HELP=0

print_help() {
  sed -n '2,35p' "$0" | sed 's/^# \{0,1\}//'
}

while [ "$#" -gt 0 ]; do
  case $1 in
    --root)
      if [ "$#" -lt 2 ] || [ -z "$2" ] || [ "${2#--}" != "$2" ]; then
        printf 'skill harness: --root requires a directory\n' >&2
        exit 2
      fi
      ROOT_DIR=$2
      shift 2
      ;;
    --skill)
      if [ "$#" -lt 2 ] || [ -z "$2" ] || [ "${2#--}" != "$2" ]; then
        printf 'skill harness: --skill requires a skill name\n' >&2
        exit 2
      fi
      SELECTED_SKILLS+=("$2")
      shift 2
      ;;
    -h|--help)
      SHOW_HELP=1
      shift
      ;;
    *)
      printf 'skill harness: unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

if [ "$SHOW_HELP" -eq 1 ]; then
  print_help
  exit 0
fi

if [ ! -d "$ROOT_DIR" ]; then
  printf 'skill harness: skills root is not a directory: %s\n' "$ROOT_DIR" >&2
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  printf 'skill harness: python3 is required\n' >&2
  exit 2
fi

python3 - "$REPO_ROOT" "$ROOT_DIR" ${SELECTED_SKILLS[@]+"${SELECTED_SKILLS[@]}"} <<'PY'
import os
import re
import sys
import urllib.parse

repo_root = os.path.abspath(sys.argv[1])
skills_root = os.path.abspath(sys.argv[2])
selected = sys.argv[3:]

MAX_LINES = 300
MAX_TOKENS = 5500
MAX_EN_CHARS = 22000   # 5,500 est. tokens at ~4.0 chars/token
MAX_KO_CHARS = 17600   # 5,500 est. tokens at ~3.2 chars/token
MAX_DESC_CHARS = 850

REQUIRED_SECTIONS = [
    "output_language",
    "purpose",
    "routing_rule",
    "instruction_contract",
    "activation_examples",
    "trigger_conditions",
    "skill_architecture",
    "loop_policy",
    "language_and_translation_default",
    "reference_routing",
    "support_file_read_order",
    "workflow",
    "required",
    "forbidden",
    "validation",
]

# Files allowed to mention runtime-specific tool names because their purpose is
# runtime tool mapping, host adapter documentation, or skill-authoring examples.
TOOL_LEAK_ALLOWLIST_PATTERNS = [
    re.compile(r"^hyper/references/runtime-tool-map(\.ko)?\.md$"),
    re.compile(r"^hyper/references/routing-examples(\.ko)?\.md$"),
    re.compile(r"^hyper-skill/references/(official|local)/.*\.md$"),
    re.compile(r"^hyper-skill/rules/(skill-anatomy|trigger-design|resource-placement|anti-patterns|self-containment)(\.ko)?\.md$"),
    re.compile(r"^hyper-handoff/references/agent-support(\.ko)?\.md$"),
    re.compile(r"^hyper-mcp/(references/host-integration|rules/mcp-workflow)(\.ko)?\.md$"),
    re.compile(r"^hyper-documentation/(references/memory/evidence-ledger|rules/(agents-md|docs|memory|readme)/.*|rules/mode-routing.*)(\.ko)?\.md$"),
    re.compile(r"^hyper-imagegen/references/runtime-capability-and-drift(\.ko)?\.md$"),
    re.compile(r"^hyper-interview/references/runtime-invocation(\.ko)?\.md$"),
]

FORBIDDEN_TOOL_RES = [
    ("rule:// URI", re.compile(r"rule://")),
    ("skill:// URI", re.compile(r"skill://")),
    ("/skill: command", re.compile(r"/skill:[a-z0-9_-]+")),
    ("AskUserQuestion tool", re.compile(r"\bAskUserQuestion\b")),
    ("TodoWrite tool", re.compile(r"\bTodoWrite\b")),
    ("invoke_subagent tool", re.compile(r"\binvoke_subagent\b")),
    ("ask_question tool", re.compile(r"\bask_question\b")),
    ("run_workflow tool", re.compile(r"\brun_workflow\b")),
    ("spawn_agent tool", re.compile(r"\bspawn_agent\b")),
    ("gpt-image-2.6-sunburst model lock", re.compile(r"gpt-image-2\.6-sunburst")),
    ("$hyper-* runtime invocation", re.compile(r"\$hyper-[a-z0-9-]+")),
    ("repo-root skills/hyper-*/ path", re.compile(r"(?<![A-Za-z0-9_.-])skills/hyper-[a-z0-9-]+/")),
]

TAG_LINE_RE = re.compile(r"^(</?[a-z][a-z0-9_]*>)[ \t]*$", re.IGNORECASE)
FENCE_RE = re.compile(r"^[ \t]{0,3}(`{3,}|~{3,})")
MD_LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)\s]+)(?:[ \t]+\"[^\"]*\")?\)")
SIBLING_REF_RE = re.compile(r"`\.\./([a-z0-9][a-z0-9-]*)/SKILL(?:\.ko)?\.md`")
INSTR_REF_RE = re.compile(r"`(instructions/[A-Za-z0-9_./-]+\.md)`")


def is_allowlisted_for_tool_leaks(rel_from_skills):
    return any(p.match(rel_from_skills) for p in TOOL_LEAK_ALLOWLIST_PATTERNS)


def strip_fences_with_lines(lines):
    out = []
    in_fence = False
    fence_char = ""
    fence_len = 0
    for idx, line in enumerate(lines, start=1):
        m = FENCE_RE.match(line)
        if m:
            tok = m.group(1)
            if not in_fence:
                in_fence = True
                fence_char = tok[0]
                fence_len = len(tok)
                continue
            elif tok[0] == fence_char and len(tok) >= fence_len:
                in_fence = False
                fence_char = ""
                fence_len = 0
                continue
        if not in_fence:
            out.append((idx, line))
    return out


def parse_frontmatter(lines):
    if not lines or lines[0].rstrip("\r") != "---":
        return {}, 0
    end_idx = None
    for i in range(1, len(lines)):
        if lines[i].rstrip("\r") == "---":
            end_idx = i
            break
    if end_idx is None:
        return {}, 0
    data = {}
    for line in lines[1:end_idx]:
        m = re.match(r"^([A-Za-z0-9_-]+):[ \t]*(.*)$", line)
        if m:
            k, v = m.group(1), m.group(2).strip()
            if len(v) >= 2 and v[0] == v[-1] and v[0] in ('"', "'"):
                v = v[1:-1]
            data[k] = v
    return data, end_idx


def extract_section(lines, tag_name):
    open_re = re.compile(rf"^<{tag_name}>[ \t]*$", re.IGNORECASE)
    close_re = re.compile(rf"^</{tag_name}>[ \t]*$", re.IGNORECASE)
    inside = False
    buf = []
    for line in lines:
        if not inside:
            if open_re.match(line):
                inside = True
            continue
        if close_re.match(line):
            break
        buf.append(line)
    return buf


def parse_table_blocks(section_lines):
    tables = []
    cur = []
    for line in strip_fences_with_lines(section_lines):
        txt = line[1].strip()
        if txt.startswith("|") and txt.endswith("|"):
            cur.append(txt)
        else:
            if len(cur) >= 2:
                tables.append(cur)
            cur = []
    if len(cur) >= 2:
        tables.append(cur)
    return tables


def split_row(row):
    inner = row.strip()[1:-1]
    parts = [c.replace(r"\|", "|").strip() for c in re.split(r"(?<!\\)\|", inner)]
    return parts


def is_delim_row(cells):
    return all(bool(re.match(r"^:?-{2,}:?$", c)) for c in cells if c != "") and len(cells) > 0


def check_top_summary(lines, fm_end, is_ko, label):
    errs = []
    out_lang_idx = None
    for i in range(fm_end + 1, len(lines)):
        if re.match(r"^<output_language>[ \t]*$", lines[i], re.IGNORECASE):
            out_lang_idx = i
            break
    if out_lang_idx is None:
        return [f"{label}: missing <output_language> tag (cannot locate top summary)"]
    header_slice = "\n".join(lines[fm_end + 1 : out_lang_idx])
    if is_ko:
        expected = [
            ("목적", r"^-[ \t]+\*\*목적\*\*:[ \t]+\S+"),
            ("쓰지 않을 때", r"^-[ \t]+\*\*쓰지 않을 때\*\*:[ \t]+\S+"),
            ("입력", r"^-[ \t]+\*\*입력\*\*:[ \t]+\S+"),
            ("산출물", r"^-[ \t]+\*\*산출물\*\*:[ \t]+\S+"),
        ]
    else:
        expected = [
            ("Purpose", r"^-[ \t]+\*\*Purpose\*\*:[ \t]+\S+"),
            ("Do not use when", r"^-[ \t]+\*\*Do not use when\*\*:[ \t]+\S+"),
            ("Input", r"^-[ \t]+\*\*Input\*\*:[ \t]+\S+"),
            ("Output", r"^-[ \t]+\*\*Output\*\*:[ \t]+\S+"),
        ]
    positions = []
    for key_label, pat in expected:
        m = re.search(pat, header_slice, re.MULTILINE)
        if not m:
            errs.append(f"{label}: missing top 4-line summary bullet '- **{key_label}**: ...' before <output_language>")
        else:
            positions.append(m.start())
    if len(positions) == 4 and positions != sorted(positions):
        errs.append(f"{label}: top 4-line summary bullets must appear in order ({', '.join(k for k, _ in expected)})")
    return errs


def analyze_workflow(wf_lines, is_ko, label):
    errs = []
    tables = parse_table_blocks(wf_lines)
    step_numbers = []
    found_step_table = False
    yesno_count = 0
    found_yesno_table = False

    for tbl in tables:
        hdr = split_row(tbl[0])
        if len(tbl) < 3 or not is_delim_row(split_row(tbl[1])):
            continue
        hdr_join = " | ".join(h.lower() for h in hdr)
        # Check if this is the step table with Done when + Why not skip
        is_step_tbl = (
            ("done when" in hdr_join and "why not skip" in hdr_join)
            if not is_ko
            else ("끝 조건" in hdr_join and "건너뛰면 안 되는 이유" in hdr_join)
        )
        if is_step_tbl and not found_step_table:
            found_step_table = True
            if len(hdr) < 4:
                errs.append(f"{label}: <workflow> step table must have at least 4 columns (Step, Action, Done when, Why not skip)")
                continue
            for r in tbl[2:]:
                cells = split_row(r)
                if len(cells) != len(hdr):
                    errs.append(f"{label}: <workflow> step row column count mismatch: {r}")
                    continue
                step_id = re.sub(r"[*` ]", "", cells[0])
                m_num = re.match(r"^(?:step|phase|단계)?([0-9]+)(?:단계)?$", step_id, re.IGNORECASE)
                if not m_num:
                    errs.append(f"{label}: <workflow> step table first column must be a step number, got '{cells[0]}'")
                    continue
                step_numbers.append(int(m_num.group(1)))
                for c_idx, cell in enumerate(cells[1:], start=2):
                    if not cell or cell == "-":
                        errs.append(f"{label}: <workflow> step {m_num.group(1)} has empty column {c_idx}")
            continue

        # Check if this is the Yes/No checklist table with violation rollback target
        is_yesno_tbl = (
            ("yes/no" in hdr_join and ("on violation" in hdr_join or "return to" in hdr_join))
            if not is_ko
            else ("예/아니오" in hdr_join and ("위반 시" in hdr_join or "되돌아갈" in hdr_join))
        )
        if is_yesno_tbl and not found_yesno_table:
            found_yesno_table = True
            if len(hdr) < 3:
                errs.append(f"{label}: <workflow> Yes/No checklist table must have 3 columns (#, Yes/No question, On violation -> return to)")
                continue
            rows = tbl[2:]
            yesno_count = len(rows)
            if yesno_count < 3 or yesno_count > 7:
                errs.append(f"{label}: <workflow> Yes/No checklist must have 3 to 7 items, got {yesno_count}")
            for r in rows:
                cells = split_row(r)
                if len(cells) < 3:
                    errs.append(f"{label}: malformed Yes/No checklist row: {r}")
                    continue
                q_cell, rb_cell = cells[1], cells[2]
                if not is_ko and "yes/no" not in q_cell.lower():
                    errs.append(f"{label}: checklist question must be binary '(Yes/No)': {q_cell}")
                if is_ko and "예/아니오" not in q_cell:
                    errs.append(f"{label}: checklist question must be binary '(예/아니오)': {q_cell}")
                if not re.search(r"[0-9]", rb_cell):
                    errs.append(f"{label}: checklist rollback target must name a step number, got '{rb_cell}'")

    if not found_step_table:
        errs.append(
            f"{label}: <workflow> must include a numbered step table with "
            + ("'Done when' and 'Why not skip'" if not is_ko else "'끝 조건' and '건너뛰면 안 되는 이유'")
        )
    elif len(step_numbers) < 3:
        errs.append(f"{label}: <workflow> must define at least 3 numbered steps, got {len(step_numbers)}")
    else:
        expected_seq = list(range(step_numbers[0], step_numbers[0] + len(step_numbers)))
        if step_numbers != expected_seq:
            errs.append(f"{label}: <workflow> step numbers must be contiguous {expected_seq}, got {step_numbers}")

    if not found_yesno_table:
        errs.append(
            f"{label}: <workflow> must include a 3-7 item binary checklist table with "
            + ("'Yes/No' and 'On violation'" if not is_ko else "'예/아니오' and '위반 시 되돌아갈 단계'")
        )

    wf_text = "\n".join(wf_lines)
    if not is_ko:
        if not re.search(r"\bresume\b", wf_text, re.IGNORECASE):
            errs.append(f"{label}: <workflow> must specify a Resume procedure reading disk state first")
    else:
        if "재개" not in wf_text:
            errs.append(f"{label}: <workflow> must specify a 재개 절차 reading disk state first")

    return errs, step_numbers, yesno_count


def check_skill(skill_name):
    errs = []
    skill_dir = os.path.join(skills_root, skill_name)
    en_path = os.path.join(skill_dir, "SKILL.md")
    ko_path = os.path.join(skill_dir, "SKILL.ko.md")
    if not os.path.isfile(en_path):
        return [f"{skill_name}: missing SKILL.md"]
    if not os.path.isfile(ko_path):
        return [f"{skill_name}: missing SKILL.ko.md"]

    en_text = open(en_path, encoding="utf-8").read()
    ko_text = open(ko_path, encoding="utf-8").read()
    en_lines = en_text.splitlines()
    ko_lines = ko_text.splitlines()

    # (d) Size ceiling
    if len(en_lines) > MAX_LINES:
        errs.append(f"{skill_name}/SKILL.md: {len(en_lines)} lines exceeds {MAX_LINES}-line ceiling (split overflow to references/)")
    if len(ko_lines) > MAX_LINES:
        errs.append(f"{skill_name}/SKILL.ko.md: {len(ko_lines)} lines exceeds {MAX_LINES}-line ceiling (split overflow to references/)")
    if len(en_text) > MAX_EN_CHARS:
        est = len(en_text) // 4
        errs.append(f"{skill_name}/SKILL.md: ~{est} est. tokens ({len(en_text)} chars) exceeds {MAX_TOKENS}-token ceiling ({MAX_EN_CHARS} chars)")
    if len(ko_text) > MAX_KO_CHARS:
        est = int(len(ko_text) / 3.2)
        errs.append(f"{skill_name}/SKILL.ko.md: ~{est} est. tokens ({len(ko_text)} chars) exceeds {MAX_TOKENS}-token ceiling ({MAX_KO_CHARS} chars)")

    # Frontmatter description boundaries
    en_fm, en_fm_end = parse_frontmatter(en_lines)
    ko_fm, ko_fm_end = parse_frontmatter(ko_lines)
    en_desc = en_fm.get("description", "")
    ko_desc = ko_fm.get("description", "")
    if len(en_desc) > MAX_DESC_CHARS:
        errs.append(f"{skill_name}/SKILL.md: description ({len(en_desc)} chars) exceeds {MAX_DESC_CHARS}-char budget")
    if "Use this skill when" not in en_desc:
        errs.append(f"{skill_name}/SKILL.md: description must include 'Use this skill when'")
    if not re.search(r"\b(Do not use|Not for)\b", en_desc):
        errs.append(f"{skill_name}/SKILL.md: description must state negative boundary ('Do not use...' or 'Not for...')")
    if len(ko_desc) > MAX_DESC_CHARS:
        errs.append(f"{skill_name}/SKILL.ko.md: description ({len(ko_desc)} chars) exceeds {MAX_DESC_CHARS}-char budget")
    if not re.search(r"(사용|쓴다|씁니다)", ko_desc):
        errs.append(f"{skill_name}/SKILL.ko.md: description must state positive trigger in Korean")
    if not re.search(r"(쓰지 않|사용하지 않|아니다|아닙니다|제외)", ko_desc):
        errs.append(f"{skill_name}/SKILL.ko.md: description must state negative exclusion in Korean")

    # Required sections & tag parity
    en_tags = [TAG_LINE_RE.match(l).group(1).lower() for _, l in strip_fences_with_lines(en_lines) if TAG_LINE_RE.match(l)]
    ko_tags = [TAG_LINE_RE.match(l).group(1).lower() for _, l in strip_fences_with_lines(ko_lines) if TAG_LINE_RE.match(l)]
    for sec in REQUIRED_SECTIONS:
        if f"<{sec}>" not in en_tags or f"</{sec}>" not in en_tags:
            errs.append(f"{skill_name}/SKILL.md: missing required section <{sec}>")
        if f"<{sec}>" not in ko_tags or f"</{sec}>" not in ko_tags:
            errs.append(f"{skill_name}/SKILL.ko.md: missing required section <{sec}>")
    if en_tags != ko_tags:
        errs.append(f"{skill_name}: SKILL.md and SKILL.ko.md XML tag sequences differ")

    # Top 4-line summary
    errs.extend(check_top_summary(en_lines, en_fm_end, False, f"{skill_name}/SKILL.md"))
    errs.extend(check_top_summary(ko_lines, ko_fm_end, True, f"{skill_name}/SKILL.ko.md"))

    # Shared common rules reference
    if "instructions/harness-engineering/references/skill-common-rules.md" not in en_text:
        errs.append(f"{skill_name}/SKILL.md: must reference `instructions/harness-engineering/references/skill-common-rules.md`")
    if (
        "instructions/harness-engineering/references/skill-common-rules.ko.md" not in ko_text
        and "instructions/harness-engineering/references/skill-common-rules.md" not in ko_text
    ):
        errs.append(f"{skill_name}/SKILL.ko.md: must reference `instructions/harness-engineering/references/skill-common-rules.ko.md`")

    # Workflow analysis + EN/KO step & checklist parity
    en_wf_errs, en_steps, en_yn = analyze_workflow(extract_section(en_lines, "workflow"), False, f"{skill_name}/SKILL.md")
    ko_wf_errs, ko_steps, ko_yn = analyze_workflow(extract_section(ko_lines, "workflow"), True, f"{skill_name}/SKILL.ko.md")
    errs.extend(en_wf_errs)
    errs.extend(ko_wf_errs)
    if en_steps and ko_steps and en_steps != ko_steps:
        errs.append(f"{skill_name}: <workflow> step-number mismatch between SKILL.md ({en_steps}) and SKILL.ko.md ({ko_steps})")
    if en_yn and ko_yn and en_yn != ko_yn:
        errs.append(f"{skill_name}: <workflow> Yes/No checklist count mismatch between SKILL.md ({en_yn}) and SKILL.ko.md ({ko_yn})")

    # <forbidden> Bad -> Good examples
    en_forb = "\n".join(extract_section(en_lines, "forbidden"))
    ko_forb = "\n".join(extract_section(ko_lines, "forbidden"))
    en_bg = len(re.findall(r"Bad[ \t]*`?:?[ \t]*.*->[ \t]*`?Good", en_forb, re.IGNORECASE))
    ko_bg = len(re.findall(r"나쁜 예[ \t]*`?:?[ \t]*.*->[ \t]*`?좋은 예", ko_forb))
    if en_bg < 3:
        errs.append(f"{skill_name}/SKILL.md: <forbidden> must include at least 3 'Bad: ... -> Good: ...' pairs (found {en_bg})")
    if ko_bg < 3:
        errs.append(f"{skill_name}/SKILL.ko.md: <forbidden> must include at least 3 '나쁜 예: ... -> 좋은 예: ...' pairs (found {ko_bg})")

    # <validation> checkboxes + parity
    en_val_boxes = [l for _, l in strip_fences_with_lines(extract_section(en_lines, "validation")) if re.match(r"^[ \t]*-[ \t]+\[[ xX]\]", l)]
    ko_val_boxes = [l for _, l in strip_fences_with_lines(extract_section(ko_lines, "validation")) if re.match(r"^[ \t]*-[ \t]+\[[ xX]\]", l)]
    if len(en_val_boxes) < 4:
        errs.append(f"{skill_name}/SKILL.md: <validation> must have at least 4 '- [ ]' checkboxes (found {len(en_val_boxes)})")
    if len(ko_val_boxes) < 4:
        errs.append(f"{skill_name}/SKILL.ko.md: <validation> must have at least 4 '- [ ]' checkboxes (found {len(ko_val_boxes)})")
    if len(en_val_boxes) != len(ko_val_boxes):
        errs.append(
            f"{skill_name}: <validation> checkbox count mismatch between SKILL.md ({len(en_val_boxes)}) and SKILL.ko.md ({len(ko_val_boxes)})"
        )

    # Walk all markdown files in skill_dir for (b) tool leaks and (c) link & sibling path validity
    instr_root = os.path.join(os.path.dirname(skills_root), "instructions")
    has_instr_root = os.path.isdir(instr_root)

    for dirpath, _, filenames in os.walk(skill_dir):
        for fn in sorted(filenames):
            if not fn.endswith(".md"):
                continue
            fpath = os.path.join(dirpath, fn)
            rel_skill = os.path.relpath(fpath, skill_dir).replace(os.sep, "/")
            rel_skills = f"{skill_name}/{rel_skill}"
            flines = open(fpath, encoding="utf-8").read().splitlines()

            # (b) Forbidden environment-specific tool names
            if not is_allowlisted_for_tool_leaks(rel_skills):
                for lno, raw_line in enumerate(flines, start=1):
                    for leak_label, leak_re in FORBIDDEN_TOOL_RES:
                        if leak_re.search(raw_line):
                            errs.append(f"{rel_skills}:{lno}: forbidden environment-specific reference ({leak_label})")

            # (c) Markdown links and relative cross-skill / instructions paths (outside code fences)
            for lno, line in strip_fences_with_lines(flines):
                for m in MD_LINK_RE.finditer(line):
                    href = m.group(1)
                    if re.match(r"^(https?://|mailto:|#)", href, re.IGNORECASE):
                        continue
                    clean = urllib.parse.unquote(href.split("#", 1)[0])
                    if not clean:
                        continue
                    target = os.path.normpath(os.path.join(os.path.dirname(fpath), clean))
                    rel_to_skill = os.path.relpath(target, skill_dir)
                    if rel_to_skill.startswith("..") or os.path.isabs(clean) or not os.path.exists(target):
                        errs.append(f"{rel_skills}:{lno}: unresolved or escaping markdown link '{href}'")

                for m in SIBLING_REF_RE.finditer(line):
                    sib = m.group(1)
                    sib_target = os.path.join(skills_root, sib, "SKILL.md")
                    if not os.path.isfile(sib_target):
                        errs.append(f"{rel_skills}:{lno}: sibling skill path '../{sib}/SKILL.md' does not exist")

                if has_instr_root:
                    for m in INSTR_REF_RE.finditer(line):
                        irel = m.group(1)
                        itarget = os.path.join(os.path.dirname(skills_root), irel)
                        if not os.path.isfile(itarget):
                            errs.append(f"{rel_skills}:{lno}: instruction path '{irel}' does not exist")

    return errs


all_dirs = sorted(
    d
    for d in os.listdir(skills_root)
    if not d.startswith(".")
    and not os.path.islink(os.path.join(skills_root, d))
    and os.path.isdir(os.path.join(skills_root, d))
)

if not all_dirs:
    print(f"skill harness: no skill directories found under {skills_root}", file=sys.stderr)
    sys.exit(1)

if selected:
    missing = [s for s in selected if s not in all_dirs]
    if missing:
        print(f"skill harness: unknown skill(s): {', '.join(missing)}", file=sys.stderr)
        sys.exit(2)
    targets = selected
else:
    targets = all_dirs

errors = []
for s in targets:
    errors.extend(check_skill(s))

if errors:
    for e in errors:
        print(f"FAIL {e}", file=sys.stderr)
    print(f"skill harness: failed ({len(errors)} error(s) across {len(targets)} skill(s))", file=sys.stderr)
    sys.exit(1)

print(f"skill harness: ok ({len(targets)} skill(s) passed all harness, portability, link, budget, and parity gates)")
PY
