# layout.jq — resolve a hyper-pptx deck spec into absolute geometry.
#
# Input : deck spec (JSON, see references/spec-format.md)
# Output: resolved deck (JSON) with every shape positioned in EMU.
#
# This is the single source of geometry: the PPTX writer and the HTML preview
# both read the resolved boxes, so a preview render and the delivered deck
# never disagree about placement.
#
# Every constant is a zero-argument function so any definition below can use it
# without depending on where a binding happens to sit in the program.

def W: 12192000;
def H: 6858000;
def MARGIN: 609600;
def CW: W - 2 * MARGIN;

def TITLE_Y: 533400;
def TITLE_H: 838200;
def BODY_Y: 1600200;
def BODY_BOTTOM: 6248400;
def BODY_H: BODY_Y as $y | BODY_BOTTOM - $y;

# Spacing tokens. A card gap below 0.3in fuses two cards into one shape; above
# 0.45in the row stops reading as a row.
def GAP: 304800;
def GAP_TIGHT: 182880;
def RULE_H: 27432;

# Type scale in points. The body floor is 15: below that a projector turns text
# into texture, so a slide that needs more room splits instead of shrinking.
def T_TITLE: 30;
def T_LEAD: 17;
def T_BODY: 18;
def T_BODY_MAX: 22;
def T_SMALL: 15;
def T_CAPTION: 12;
def T_FOOTER: 11;

def palette($name):
  {
    ink: {
      bg: "FFFFFF", fg: "12171D", muted: "66707D", accent: "C2410C",
      surface: "F2F4F7", line: "D7DCE4",
      darkBg: "12171D", darkFg: "F7F8FA", darkMuted: "A8B2BF", darkAccent: "F97316",
      darkSurface: "1E252E"
    },
    paper: {
      bg: "FBF8F3", fg: "1A1613", muted: "6E655C", accent: "9A3412",
      surface: "F0E9DF", line: "DED3C6",
      darkBg: "241E19", darkFg: "FBF8F3", darkMuted: "BCAE9F", darkAccent: "E8A15C",
      darkSurface: "322A23"
    },
    navy: {
      bg: "FFFFFF", fg: "0B1B33", muted: "5A6B84", accent: "1F5DA8",
      surface: "EDF2F9", line: "CFDAEA",
      darkBg: "0B1B33", darkFg: "F5F8FC", darkMuted: "A3B4CC", darkAccent: "6EA8E8",
      darkSurface: "162944"
    },
    forest: {
      bg: "FFFFFF", fg: "10231A", muted: "5A6B62", accent: "1F6B4A",
      surface: "EDF4EF", line: "C9DCCF",
      darkBg: "0F2A1E", darkFg: "F3F8F5", darkMuted: "A5C0B0", darkAccent: "5BC493",
      darkSurface: "183A2A"
    },
    slate: {
      bg: "FFFFFF", fg: "1B2430", muted: "64707E", accent: "2F6F8F",
      surface: "EFF3F6", line: "D2DBE2",
      darkBg: "111A22", darkFg: "F4F7F9", darkMuted: "A3B0BC", darkAccent: "6FB3D2",
      darkSurface: "1C2733"
    },
    mono: {
      bg: "FFFFFF", fg: "111111", muted: "6E6E6E", accent: "111111",
      surface: "F2F2F2", line: "D8D8D8",
      darkBg: "111111", darkFg: "F7F7F7", darkMuted: "A9A9A9", darkAccent: "FFFFFF",
      darkSurface: "1F1F1F"
    }
  }[$name];

def para($text; $size; $color; $bold; $level; $bullet; $space):
  {text: $text, size: $size, color: $color, bold: $bold,
   level: $level, bullet: $bullet, spaceBefore: $space};

# A text shape states its region, alignment, anchor, and inset; the renderer
# owns line breaking, so the box never needs a measured height.
def tshape($x; $y; $cx; $cy; $paras; $align; $anchor; $inset):
  {type: "text",
   x: ($x | floor), y: ($y | floor), cx: ($cx | floor), cy: ($cy | floor),
   align: $align, anchor: $anchor,
   inset: (if $inset == null then [91440, 45720, 91440, 45720] else $inset end),
   paragraphs: $paras};

def rshape($x; $y; $cx; $cy; $fill; $line; $radius):
  {type: "rect",
   x: ($x | floor), y: ($y | floor), cx: ($cx | floor), cy: ($cy | floor),
   fill: $fill, line: $line, radius: $radius};

def pic($x; $y; $cx; $cy; $path; $ext; $crop; $alt):
  {x: ($x | floor), y: ($y | floor), cx: ($cx | floor), cy: ($cy | floor),
   path: $path, ext: $ext, crop: ($crop // {l: 0, t: 0, r: 0, b: 0}), alt: ($alt // "")};

# ---------------------------------------------------------------------------
# Text measurement
# ---------------------------------------------------------------------------

# Advance width of one code point in ems. Hangul, CJK, and fullwidth forms take
# a full em; everything else averages about half. Slightly generous, so a card
# sized from this never comes out shorter than its text.
def em_advance:
  if (. >= 4352 and . <= 4607)
     or (. >= 11904 and . <= 42191)
     or (. >= 44032 and . <= 55203)
     or (. >= 63744 and . <= 64255)
     or (. >= 65280 and . <= 65376)
  then 1 else 0.52 end;

def em_width: explode | map(em_advance) | add // 0;

# Greedy line count for a string in a box that fits $emAvail ems per line.
# The renderer breaks lines itself; this is only used to size a card and to
# decide how a block sits in its area, never to place text.
def line_count($s; $emAvail):
  if ($s | length) == 0 or $emAvail <= 0 then 0
  else
    reduce ($s | explode[]) as $c ({lines: 1, used: 0};
      ($c | em_advance) as $adv
      | if .used > 0 and (.used + $adv) > $emAvail
        then {lines: (.lines + 1), used: $adv}
        else {lines: .lines, used: (.used + $adv)}
        end)
    | .lines
  end;

# Line box height in EMU for a point size at 1.32 line spacing, the value the
# preview uses. Measurement and painting share it, so a fit decision here is the
# fit the reader sees.
def line_h($pt): ($pt * 12700 * 1.32 | floor);

def para_h($p; $emAvail):
  (line_count($p.text; $emAvail) * line_h($p.size))
  + ((($p.spaceBefore // 0) * 12700) | floor);

# Returns the outer box height for the paragraphs: the wrapped lines plus the
# top and bottom insets, which the renderer subtracts from the box before it
# lays text out. A caller that sets cy to this value gets a box that fits.
def paras_h($ps; $cx; $inset):
  (if $inset == null then [91440, 45720, 91440, 45720] else $inset end) as $in
  | (($cx - $in[0] - $in[2]) | floor) as $w
  | (([ $ps[] | (.size * 12700) as $em | para_h(.; ($w / $em)) ] | add // 0)
     + $in[1] + $in[3]);

def bullets_of($list; $size; $color; $mutedColor):
  [ $list[] |
    if type == "string" then para(.; $size; $color; false; 0; true; 6)
    else
      (.level // 0) as $lvl |
      para(
        (.text // "");
        (if .size then .size elif $lvl > 0 then ($size - 2) else $size end);
        (if .color then .color elif $lvl > 0 then $mutedColor else $color end);
        (.bold // false);
        $lvl;
        (if .bullet == false then false else true end);
        (if .space != null then .space elif $lvl > 0 then 0 else 6 end)
      )
    end
  ];

# Bullet sizes step up until the block fills the body, and a block too tall for
# the body steps back down. A slide with one bullet at 18 points in the top-left
# corner reads as unfinished; the same sentence at 22 points reads as a choice.
# The largest size is T_BODY_MAX, which keeps the body below two thirds of the
# 30-point title: a body that matches the title erases the hierarchy. The floor
# is T_BODY - 2, and a block that still does not fit is left to the overflow
# check rather than shrunk further.
def fit_bullets($list; $cx; $inset; $avail; $sizes):
  reduce ($sizes[]) as $s
    ({paras: null, size: null};
     (bullets_of($list; $s; "000000"; "000000")) as $ps
     | if (paras_h($ps; $cx; $inset)) <= $avail then {paras: $ps, size: $s} else . end)
  | if .paras == null
    then {paras: bullets_of($list; ($sizes[0] - 2); "000000"; "000000"), size: ($sizes[0] - 2)}
    else . end;

# A short block spread over the body reads as a deliberate list; the same block
# packed under the title leaves the bottom half of the page empty and reads as a
# render fault. The extra leading per paragraph is capped so three one-line
# bullets do not turn into three islands.
def spread_paras($ps; $room; $capEmu):
  ($ps | length) as $n
  | if $n < 2 or $room <= 0 then $ps
    else
      # The gaps sit between paragraphs, so there are n-1 of them; space above
      # the first paragraph would only push the whole block off its anchor.
      (([ (($room / ($n - 1)) | floor), $capEmu ] | min) / 12700 | floor) as $perPt
      | if $perPt <= 0 then $ps
        else [ $ps | to_entries[] | .value.spaceBefore = ((.value.spaceBefore // 0) + (if .key == 0 then 0 else $perPt end)) | .value ]
        end
    end;

# Vertical anchor for a block: centre a short block, top-align a full one. The
# threshold keeps a two-line block from floating in the middle of a dense page.
def anchor_for($need; $avail): if $need < ($avail * 0.78) then "ctr" else "t" end;

# ---------------------------------------------------------------------------
# Slide kinds
# ---------------------------------------------------------------------------

def title_shape($title; $t):
  tshape(MARGIN; TITLE_Y; CW; TITLE_H; [ para($title; T_TITLE; $t.fg; true; 0; false; 0) ]; "l"; "b"; null);

# The cover holds one claim, so the block is centred on the page as a unit:
# kicker, title, subtitle, then a short rule that stands clear of the subtitle
# instead of touching it. The meta line stays pinned to the foot.
def slide_title($s; $t; $idx):
  (if $s.kicker then 457200 + 182880 else 0 end) as $kickH
  | (paras_h([ para($s.title; 44; "000000"; true; 0; false; 0) ]; CW; null)) as $titleH
  | (if $s.subtitle
     then 182880 + (paras_h([ para($s.subtitle; 20; "000000"; false; 0; false; 0) ]; CW; null))
     else 0 end) as $subH
  | ($kickH + $titleH + $subH + 256032 + 45720) as $blockH
  | (((H - $blockH) / 2 - 274320) | floor) as $y0
  | ($y0 + $kickH + $titleH + $subH) as $ruleY
  | {
    index: $idx, kind: "title", dark: true,
    shapes: (
      (if $s.kicker then
         [ tshape(MARGIN; $y0; CW; 457200;
             [ para($s.kicker; 13; $t.darkAccent; true; 0; false; 0) ]; "l"; "b"; null) ]
       else [] end)
      + [ tshape(MARGIN; ($y0 + $kickH); CW; ($titleH + $subH);
          ([ para($s.title; 44; $t.darkFg; true; 0; false; 0) ]
           + (if $s.subtitle then [ para($s.subtitle; 20; $t.darkMuted; false; 0; false; 8) ] else [] end));
          "l"; "b"; null),
        rshape(MARGIN; $ruleY; 1097280; 45720; $t.darkAccent; null; 0)
      ]
      + (if $s.meta then
           [ tshape(MARGIN; 5760720; CW; 457200;
               [ para($s.meta; 13; $t.darkMuted; false; 0; false; 0) ]; "l"; "t"; null) ]
         else [] end) ),
    notes: ($s.notes // "")
  };

# A section opener holds three short lines and nothing else, so the block is
# centred on the page. Anchoring it to the top leaves the bottom two thirds
# dark and empty, which reads as a rendering fault rather than a pause.
def slide_section($s; $t; $idx):
  (if $s.number then 548640 + 182880 else 0 end) as $numH
  | 868680 as $titleH
  | (if $s.subtitle then 137160 + 548640 else 0 end) as $subH
  | ($numH + $titleH + $subH) as $blockH
  | (((H - $blockH) / 2) | floor) as $y0
  | ($y0 + $numH) as $titleY
  | {
    index: $idx, kind: "section", dark: true,
    shapes: (
      (if $s.number then
         [ tshape(MARGIN; $y0; CW; 548640; [ para($s.number; 15; $t.darkAccent; true; 0; false; 0) ]; "l"; "b"; null),
           rshape(MARGIN; ($y0 + 548640 + 45720); 731520; 27432; $t.darkAccent; null; 0) ]
       else [] end)
      + [ tshape(MARGIN; $titleY; CW; $titleH; [ para($s.title; 36; $t.darkFg; true; 0; false; 0) ]; "l"; "b"; null) ]
      + (if $s.subtitle then
           [ tshape(MARGIN; ($titleY + $titleH + 137160); ((CW * 4) / 5 | floor); 548640;
               [ para($s.subtitle; 17; $t.darkMuted; false; 0; false; 0) ]; "l"; "t"; null) ]
         else [] end) ),
    notes: ($s.notes // "")
  };

def slide_bullets($s; $t; $idx):
  (if $s.lead then BODY_Y + 640080 else BODY_Y end) as $y0
  | (BODY_BOTTOM - $y0) as $avail
  | ([ T_BODY, 19, 20, 21, T_BODY_MAX ]) as $sizes
  | (fit_bullets($s.bullets; ((CW * 86) / 100 | floor); null; $avail; $sizes)) as $fit
  | (paras_h($fit.paras; ((CW * 86) / 100 | floor); null)) as $need0
  | (spread_paras($fit.paras; (($avail * 0.86 | floor) - $need0); (18 * 12700))) as $paras
  | (paras_h($paras; ((CW * 86) / 100 | floor); null)) as $need
  | {
    index: $idx, kind: "bullets", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; BODY_Y; CW; 548640; [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "t"; null) ]
         else [] end)
      # With a lead the block starts right under it: the lead is the opening line
      # of the block, and a gap between them reads as two separate things.
      # Without a lead the block is centred in the body, so a short block sits at
      # the optical centre instead of hanging from the title. The box is as tall
      # as the block, not as tall as the area: a centred box that kept the full
      # area height would slide its bottom edge past the footer.
      + [ tshape(MARGIN; (if $s.lead then $y0
                          else ($y0 + ((($avail - $need) / 2) | floor)) end);
          ((CW * 86) / 100 | floor); $need;
          ([ $paras[] | .color = (if .level > 0 then $t.muted else $t.fg end) ]);
          "l"; "t"; null) ] ),
    notes: ($s.notes // "")
  };

# Cards. Height follows the tallest column's own text, the row is centred in the
# body when it is short, and each card carries a hairline accent rule so three
# short cards still read as three objects rather than three empty panels.
def card_height($columns; $cwd; $cols; $size):
  (((($cwd - 365760 - 342900) / ($size * 12700)) | floor)) as $emAvail
  | ([ range(0; $cols) as $i |
       ($columns[$i].bullets // []) as $bl
       | ([ $bl[] |
            (if type == "string" then {text: ., level: 0, space: 6}
             else {text: (.text // ""), level: (.level // 0),
                   space: (if .space != null then .space elif (.level // 0) > 0 then 0 else 6 end)} end)
            | ((line_count(.text; ($emAvail - (if .level > 0 then 2 else 0 end)))
                 * line_h((if .level > 0 then ($size - 2) else $size end)))
               + (.space * 12700))
          ] | add // 0)
     ] | max // 0);

def slide_columns($s; $t; $idx):
  ($s.columns | length) as $n
  | (if $n > 3 then 3 elif $n < 1 then 1 else $n end) as $cols
  | (((CW - ($cols - 1) * GAP) / $cols) | floor) as $cwd
  | (card_height($s.columns; $cwd; $cols; T_SMALL)) as $bodyNeed
  | (777240 + $bodyNeed + 228600) as $wanted
  | (if $wanted < 2011680 then 2011680 elif $wanted > BODY_H then BODY_H else $wanted end) as $cardH
  | (if $cardH < (BODY_H * 0.66) then (BODY_Y + ((BODY_H - $cardH) / 2 | floor)) else BODY_Y end) as $cardY
  | {
    index: $idx, kind: "columns", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; (BODY_Y - 91440); CW; 548640;
               [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "b"; null) ]
         else [] end)
      + [ range(0; $cols) as $i |
          ($s.columns[$i]) as $c |
          ((MARGIN + $i * ($cwd + GAP)) | floor) as $x |
          rshape($x; $cardY; $cwd; $cardH; $t.surface; null; 0),
          rshape($x; $cardY; $cwd; RULE_H; $t.accent; null; 0),
          tshape($x; ($cardY + 320040); $cwd; 457200;
            [ para($c.heading; 17; $t.accent; true; 0; false; 0) ]; "l"; "t";
            [GAP_TIGHT, 0, GAP_TIGHT, 0]),
          tshape($x; ($cardY + 822960); $cwd; ($cardH - 914400);
            bullets_of(($c.bullets // []); T_SMALL; $t.fg; $t.muted); "l"; "t";
            [GAP_TIGHT, 0, GAP_TIGHT, 0])
        ] ),
    notes: ($s.notes // "")
  };

# Headline numbers. The value is sized from its own length so "1,284억" and "47%"
# carry the same optical weight, and the row is centred when the cards are short.
def stat_value_size($v):
  ($v | length) as $n
  | if $n <= 3 then 60 elif $n <= 5 then 52 elif $n <= 7 then 44 else 36 end;

def slide_stats($s; $t; $idx):
  ($s.stats | length) as $n
  | (if $n > 4 then 4 elif $n < 1 then 1 else $n end) as $cols
  | (((CW - ($cols - 1) * GAP) / $cols) | floor) as $cwd
  # A card holds a number, a label and a note: 0.62 of the body is the tallest
  # that still leaves the block reading as a row rather than three posters.
  | ((BODY_H * (if $cols == 1 then 0.5 else 0.62 end)) | floor) as $cardH
  | (BODY_Y + (((BODY_H - $cardH) / 2) | floor)) as $cardY
  | {
    index: $idx, kind: "stats", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; (BODY_Y - 91440); CW; 548640;
               [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "b"; null) ]
         else [] end)
      + [ range(0; $cols) as $i |
          ($s.stats[$i]) as $st |
          ((MARGIN + $i * ($cwd + GAP)) | floor) as $x |
          (stat_value_size($st.value)) as $vs |
          rshape($x; $cardY; $cwd; $cardH; $t.surface; null; 0),
          rshape($x; $cardY; $cwd; RULE_H; $t.accent; null; 0),
          tshape($x; ($cardY + ($cardH * 0.14 | floor)); $cwd; 1097280;
            [ para($st.value; $vs; $t.accent; true; 0; false; 0) ]; "l"; "b";
            [GAP_TIGHT, 0, GAP_TIGHT, 0]),
          tshape($x; ($cardY + ($cardH * 0.6 | floor)); $cwd; 457200;
            [ para($st.label; T_SMALL; $t.fg; false; 0; false; 0) ]; "l"; "t";
            [GAP_TIGHT, 0, GAP_TIGHT, 0])
        ]
      + [ range(0; $cols) as $i |
          ($s.stats[$i]) as $st |
          ((MARGIN + $i * ($cwd + GAP)) | floor) as $x |
          (if $st.note then
             tshape($x; ($cardY + ($cardH * 0.8 | floor)); $cwd; 365760;
               [ para($st.note; T_CAPTION; $t.muted; false; 0; false; 0) ]; "l"; "t";
               [GAP_TIGHT, 0, GAP_TIGHT, 0])
           else empty end)
        ] ),
    notes: ($s.notes // "")
  };

# One number that carries the slide, with the argument beside it. Used when the
# audience should remember a single figure and the reasons for it.
# A number with its label is one block. The card is sized to that block and the
# block is centred in the body, so a short KPI does not sit in a tall empty box.
def slide_kpi($s; $t; $idx):
  (($s.bullets // []) | length) as $nb
  | (if $nb > 0 then ((CW * 40) / 100 | floor) else CW end) as $lw
  | (if $nb > 0 then (CW - $lw - GAP) else 0 end) as $rw
  | (($s.value | length) as $n | if $n <= 3 then 96 elif $n <= 5 then 80 elif $n <= 7 then 66 else 54 end) as $vs
  | (line_h($vs)) as $valH
  | (if $s.label then ((17 * 12700 * 1.35) | floor) + 91440 else 0 end) as $labH
  | (if $s.delta then ((T_SMALL * 12700 * 1.35) | floor) + 91440 else 0 end) as $delH
  | ($valH + $labH + $delH) as $stackH
  # The card and the argument beside it form one row, so both take the taller
  # of the two heights. A short card next to three bullets leaves a step.
  | (if $nb > 0
     then paras_h(bullets_of($s.bullets; 20; "000000"; "000000"); $rw; null)
     else 0 end) as $argH
  | (([ $stackH, $argH ] | max) + 2 * GAP) as $rowH
  | ($rowH | if . > BODY_H then BODY_H else . end) as $cardH
  | (BODY_Y + (((BODY_H - $cardH) / 2) | floor)) as $cy
  | (($cardH - $stackH) / 2 | floor) as $padTop
  | {
    index: $idx, kind: "kpi", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; (BODY_Y - 91440); CW; 548640;
               [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "b"; null) ]
         else [] end)
      + (if $nb > 0 then
           [ rshape(MARGIN; $cy; $lw; $cardH; $t.surface; null; 0),
             rshape(MARGIN; $cy; $lw; RULE_H; $t.accent; null; 0),
             tshape((MARGIN + GAP_TIGHT); ($cy + $padTop); ($lw - 2 * GAP_TIGHT); $valH;
               [ para($s.value; $vs; $t.accent; true; 0; false; 0) ]; "l"; "b";
               [0, 0, 0, 0]) ]
           + (if $s.label then
                [ tshape((MARGIN + GAP_TIGHT); ($cy + $padTop + $valH + 45720); ($lw - 2 * GAP_TIGHT); ($labH - 45720);
                    [ para($s.label; 17; $t.fg; false; 0; false; 0) ]; "l"; "t"; [0, 0, 0, 0]) ]
              else [] end)
           + (if $s.delta then
                [ tshape((MARGIN + GAP_TIGHT); ($cy + $padTop + $valH + $labH + 45720); ($lw - 2 * GAP_TIGHT); ($delH - 45720);
                    [ para($s.delta; T_SMALL; $t.muted; false; 0; false; 0) ]; "l"; "t"; [0, 0, 0, 0]) ]
              else [] end)
         else
           [ tshape(MARGIN; BODY_Y; CW; (BODY_H - 1371600);
               [ para($s.value; $vs; $t.accent; true; 0; false; 0) ]; "l"; "b"; null) ]
           + (if $s.label then
                [ tshape(MARGIN; (BODY_BOTTOM - 1097280); CW; 731520;
                    [ para($s.label; 20; $t.fg; false; 0; false; 0) ]; "l"; "t"; null) ]
              else [] end)
         end)
      + (if $nb > 0 then
           [ tshape((MARGIN + $lw + GAP); $cy; $rw; $cardH;
               bullets_of($s.bullets; 20; $t.fg; $t.muted); "l"; "ctr";
               [0, 0, 0, 0]) ]
         else [] end) ),
    notes: ($s.notes // "")
  };

# Two panels with a claim each. The divider is a hairline, not a box: two boxes
# side by side read as two slides glued together.
# Short comparison panels get larger type, capped so the two sides still read as
# one row rather than two different documents.
def compare_size($side; $pw):
  reduce (16, 18, 20, 22, 24) as $sz (16;
    if paras_h(bullets_of(($side.bullets // []); $sz; "000000"; "000000"); $pw; null)
       <= (BODY_H * 0.8) then $sz else . end);

def slide_compare($s; $t; $idx):
  ((CW - GAP) / 2 | floor) as $pw
  # The two panels are one block: measure the taller side and centre the block
  # in the body, so a three-point comparison does not sit in the top third with
  # two thirds of the page left white.
  | ([ $s.left, $s.right ] | map(
       (if . == null then 0
        else 777240 + paras_h(bullets_of((.bullets // []); compare_size(.; $pw); "000000"; "000000"); $pw; null)
        end)) | max // 0) as $need
  | (([ $s.left, $s.right ] | map(select(. != null) | compare_size(.; $pw)) | min) // 16) as $bsize
  # Centring is capped: a short block dropped to the exact middle detaches from
  # the title, so the offset never exceeds a third of the body.
  | (BODY_Y + (([ (BODY_H - $need) / 2, BODY_H / 3 ] | min) | floor)) as $py
  | $need as $ph
  | {
    index: $idx, kind: "compare", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; (BODY_Y - 91440); CW; 548640;
               [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "b"; null) ]
         else [] end)
      + [ range(0; 2) as $i |
          (if $i == 0 then $s.left else $s.right end) as $side |
          ((MARGIN + $i * ($pw + GAP)) | floor) as $x |
          (if $side == null then empty
           else
             rshape($x; $py; $pw; RULE_H; (if $i == 0 then $t.line else $t.accent end); null; 0),
             tshape($x; ($py + 137160); $pw; 548640;
               [ para($side.heading; 20; $t.fg; true; 0; false; 0) ]; "l"; "t";
               [0, 0, 0, 0]),
             tshape($x; ($py + 777240); $pw; (($ph - 777240) | if . < 914400 then 914400 else . end);
               bullets_of(($side.bullets // []); $bsize; $t.fg; $t.muted); "l"; "t";
               [0, 0, 0, 0])
           end)
        ] ),
    notes: ($s.notes // "")
  };

# A row of milestones on one rule. Reading order down the page is date, title,
# rule with its markers, then detail. The block is spread over most of the body
# instead of being packed tight and centred: three milestones occupy a wide
# horizontal band, and a band that only fills a third of the height leaves two
# dead margins that read as a layout fault.
def slide_timeline($s; $t; $idx):
  (($s.milestones // []) | length) as $n
  | (if $n > 5 then 5 elif $n < 2 then 2 else $n end) as $cols
  | ((CW / $cols) | floor) as $cwd
  | (($cwd - GAP_TIGHT) | floor) as $tw
  # Each band is measured from the longest milestone in it. A band sized as a
  # fixed share of the body reserves height nothing uses, and the leftover
  # shows up as a dead strip under the detail line.
  | ([ range(0; $cols) | line_count(($s.milestones[.].label // ""); ($tw / (16 * 12700))) ] | max // 1) as $labLines
  | ([ range(0; $cols) | line_count(($s.milestones[.].title // ""); ($tw / (32 * 12700))) ] | max // 1) as $titLines
  | ([ range(0; $cols) | line_count(($s.milestones[.].text // $s.milestones[.].detail // ""); ($tw / (19 * 12700))) ] | max // 1) as $detLines
  | (($labLines * line_h(16))) as $labH
  | (($titLines * line_h(32))) as $titH
  | (($detLines * line_h(19))) as $detH
  | ($labH + 182880 + $titH + 320040 + 19050 + 182880 + $detH) as $blockH
  | ($blockH | if . > BODY_H then BODY_H else . end) as $blockH2
  | (BODY_Y + (((BODY_H - $blockH2) / 2) | floor)) as $y0
  | ($y0 + $labH + 182880) as $titleY
  | ($titleY + $titH + 320040) as $ruleY
  | ($ruleY + 182880) as $detailY
  | {
    index: $idx, kind: "timeline", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; (BODY_Y - 91440); CW; 548640;
               [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "b"; null) ]
         else [] end)
      # The rule stops just past the last marker instead of running to the page
      # edge, so it reads as a measured span rather than a divider.
      + [ rshape(MARGIN; ($ruleY - 9525);
                 ((($cols - 1) * $cwd) + 121920); 19050; $t.line; null; 0) ]
      + [ range(0; $cols) as $i |
          ($s.milestones[$i]) as $m |
          ((MARGIN + $i * $cwd) | floor) as $x |
          tshape($x; $y0; $tw; $labH;
            [ para(($m.label // ""); 16; $t.accent; true; 0; false; 0) ]; "l"; "b";
            [0, 0, 0, 0]),
          tshape($x; $titleY; $tw; $titH;
            [ para(($m.title // ""); 32; $t.fg; true; 0; false; 0) ]; "l"; "b";
            [0, 0, 0, 0]),
          rshape(($x + 68580); ($ruleY - 60960); 121920; 121920; $t.accent; null; 0),
          tshape($x; $detailY; $tw; $detH;
            # `text` is the documented key; `detail` stays readable because the
            # first drafts of this layout used it.
            [ para(($m.text // $m.detail // ""); 19; $t.muted; false; 0; false; 0) ]; "l"; "t";
            [0, 0, 0, 0])
        ] ),
    notes: ($s.notes // "")
  };

# A table with two rows is a statement, not a grid. Rows grow with the space
# available up to a readable cap and the block is centred in the body, so a
# short table does not hang from the title with half the page empty below.
def slide_table($s; $t; $idx):
  ($s.table.columns | length) as $ncols
  | (($s.table.rows | length) + 1) as $nrows
  | (if $s.table.caption then 457200 else 0 end) as $capH
  | (((BODY_H - $capH) / $nrows) | floor) as $rawH
  | ($rawH | if . > 1097280 then 1097280 elif . < 320040 then 320040 else . end) as $rh
  | (($rh * $nrows) | floor) as $th
  | (BODY_Y + (((BODY_H - $capH - $th) / 2) | floor)) as $ty
  | (if $rh >= 731520 then 17 elif $rh >= 548640 then 15 else 13 end) as $tsz
  | {
    index: $idx, kind: "table", dark: false,
    shapes:
      ([ title_shape($s.title; $t) ]
       + (if $s.table.caption then
            [ tshape(MARGIN; ($ty + $th + 91440); CW; 320040;
                [ para($s.table.caption; T_CAPTION; $t.muted; false; 0; false; 0) ]; "l"; "t"; null) ]
          else [] end)),
    table: {
      x: MARGIN, y: $ty, cx: CW, cy: $th,
      colWidths: [ range(0; $ncols) | ((CW / $ncols) | floor) ],
      rowHeights: [ range(0; $nrows) | $rh ],
      header: $s.table.columns,
      rows: $s.table.rows,
      headerFill: $t.accent, headerColor: "FFFFFF",
      bodyFill: $t.bg, altFill: $t.surface, bodyColor: $t.fg,
      size: $tsz
    },
    notes: ($s.notes // "")
  };

# A chart is the visual; the slide carries the claim in the title and the unit
# and base in the caption. The chart box keeps a fixed height so the caption and
# the axis labels never compete for the same space.
def slide_chart($s; $t; $idx):
  ((CW * 88) / 100 | floor) as $chw
  # The chart takes the body almost whole; only the caption line is reserved.
  # A short chart box leaves the page bottom empty, which is the same defect as
  # an empty card row.
  | ((BODY_H - (if $s.chart.caption then 411480 else 0 end)) | floor) as $chh2
  | {
    index: $idx, kind: "chart", dark: false,
    shapes:
      ([ title_shape($s.title; $t) ]
       + (if $s.chart.caption then
            [ tshape(MARGIN; (BODY_Y + $chh2 + 91440); CW; 320040;
                [ para($s.chart.caption; T_CAPTION; $t.muted; false; 0; false; 0) ]; "l"; "t"; null) ]
          else [] end)),
    chart: {
      x: ((W - $chw) / 2 | floor), y: BODY_Y, cx: $chw, cy: $chh2,
      type: ($s.chart.type // "column"),
      categories: $s.chart.categories,
      series: $s.chart.series,
      colors: [ $t.accent, $t.muted, $t.line, $t.surface, $t.fg ],
      fg: $t.fg, muted: $t.muted, bg: $t.bg, accent: $t.accent, line: $t.line,
      axCat: "111111111", axVal: "222222222",
      # A combo needs a second value axis, or the rate line is drawn against the
      # volume scale and flattens onto the baseline.
      axVal2: "333333333",
      labels: ($s.chart.labels // false),
      legend: ($s.chart.legend // (if (($s.chart.series // []) | length) > 1 then "bottom" else "none" end)),
      numberFormat: ($s.chart.numberFormat // "General"),
      valueAxisTitle: ($s.chart.valueAxisTitle // null),
      categoryAxisTitle: ($s.chart.categoryAxisTitle // null),
      hole: ($s.chart.hole // $s.chart.holeSize // 50)
    },
    notes: ($s.notes // "")
  };

# ---------------------------------------------------------------------------
# Pictures
# ---------------------------------------------------------------------------

# contain: the whole picture fits, letterboxed inside the box.
# cover: the picture fills the box and the overflow is cropped through srcRect.
# The crop is expressed as fractions of the source so the PPTX and the preview
# compute the same window.
def fit_box($boxW; $boxH; $aspect; $mode):
  ($boxW / $boxH) as $q
  | if $mode == "fill" then
      (if $aspect >= $q
       then {w: $boxW, h: $boxH, crop: {l: (((1 - ($q / $aspect)) / 2) * 100), t: 0,
                                        r: (((1 - ($q / $aspect)) / 2) * 100), b: 0}}
       else {w: $boxW, h: $boxH, crop: {l: 0, t: (((1 - ($aspect / $q)) / 2) * 100),
                                        r: 0, b: (((1 - ($aspect / $q)) / 2) * 100)}} end)
    else
      (if $aspect >= $q
       then {w: $boxW, h: (($boxW / $aspect) | floor), crop: {l: 0, t: 0, r: 0, b: 0}}
       else {w: (($boxH * $aspect) | floor), h: $boxH, crop: {l: 0, t: 0, r: 0, b: 0}} end)
    end;

def image_of($img; $x; $y; $boxW; $boxH; $mode; $alt):
  (($img.aspect // 1.7777778)) as $aspect
  | (fit_box($boxW; $boxH; $aspect; $mode)) as $f
  | pic(($x + (($boxW - $f.w) / 2 | floor)); ($y + (($boxH - $f.h) / 2 | floor));
        $f.w; $f.h; $img.path; ($img.ext // ($img.path | split(".") | .[-1] | ascii_downcase));
        $f.crop; (if $alt then $alt else ($img.alt // "") end));

def slide_image($s; $t; $idx):
  (if $s.title then 640080 else 0 end) as $titleDrop
  | (BODY_Y + $titleDrop) as $y0
  | (if $s.caption then 411480 else 0 end) as $capH
  | (BODY_BOTTOM - $y0 - $capH) as $areaH
  | {
    index: $idx, kind: "image", dark: false,
    shapes: (
      (if $s.title then [ title_shape($s.title; $t) ] else [] end)
      + (if $s.caption then
           [ tshape(MARGIN; (BODY_BOTTOM - 320040); CW; 320040;
               [ para((if $s.image.credit then $s.caption + "  ·  " + $s.image.credit else $s.caption end);
                       T_CAPTION; $t.muted; false; 0; false; 0) ]; "l"; "t"; null) ]
         else [] end) ),
    images: [ image_of($s.image; MARGIN; $y0; CW; $areaH; ($s.image.fit // "contain"); $s.image.alt) ],
    notes: ($s.notes // "")
  };

# Picture beside an argument. The picture column is 52% of the text column so the
# picture reads as the evidence and the words as the claim, not the reverse.
# Both columns share one measured row: the picture is exactly as tall as the
# text block beside it, never the full body with the words stranded at the top.
def slide_imagetext($s; $t; $idx):
  ((CW * 52) / 100 | floor) as $pw
  | (CW - $pw - GAP * 2) as $tw
  | (if $s.lead then 548640 else 0 end) as $leadH
  | (BODY_Y + $leadH) as $y0
  | (if $s.heading then 731520 else 0 end) as $headH
  | ((BODY_BOTTOM - $y0 - $headH)) as $textAvail
  | (fit_bullets(($s.bullets // []); $tw; null; $textAvail; [16, 18, 20, 22])) as $fit
  | (paras_h($fit.paras; $tw; null)) as $textH
  | (($headH + $textH) | if . < ($textAvail * 0.45) then ($textAvail * 0.45 | floor) else . end) as $blockH
  | ((BODY_Y + $leadH + (((BODY_BOTTOM - $y0 - $blockH) / 2) | floor))) as $ty
  | (if ($s.image.side // "right") == "left" then MARGIN else (MARGIN + $tw + GAP * 2) end) as $ix
  | (if ($s.image.side // "right") == "left" then (MARGIN + $pw + GAP * 2) else MARGIN end) as $tx
  | {
    index: $idx, kind: "imagetext", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; BODY_Y; CW; 548640;
               [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "t"; null) ]
         else [] end)
      + (if $s.heading then
           [ tshape($tx; $ty; $tw; 548640;
               [ para($s.heading; 20; $t.accent; true; 0; false; 0) ]; "l"; "b";
               [0, 0, 0, 0]) ]
         else [] end)
      + [ tshape($tx; ($ty + $headH); $tw; $textH;
            [ $fit.paras[] | .color = (if .level > 0 then $t.muted else $t.fg end) ]; "l"; "t";
            [0, 0, 0, 0]) ] ),
    images: [ image_of($s.image; $ix; $ty; $pw; $blockH; ($s.image.fit // "fill"); $s.image.alt) ],
    notes: ($s.notes // "")
  };

# A picture that is the page. The scrim is a flat overlay at a fixed alpha, and
# the text sits on it at full contrast rather than on the picture itself.
def slide_hero($s; $t; $idx):
  (paras_h([ para($s.title; 44; "000000"; true; 0; false; 0) ]
           + (if $s.subtitle then [ para($s.subtitle; 20; "000000"; false; 0; false; 8) ] else [] end);
           ((CW * 78) / 100 | floor); null)) as $txtH
  | (((H - $txtH) / 2) | floor) as $y0
  | {
    index: $idx, kind: "hero", dark: true,
    shapes: (
      [ tshape(MARGIN; $y0; ((CW * 78) / 100 | floor); $txtH;
          ([ para($s.title; 44; "FFFFFF"; true; 0; false; 0) ]
           + (if $s.subtitle then [ para($s.subtitle; 20; "FFFFFF"; false; 0; false; 8) ] else [] end));
          "l"; "t"; null),
        rshape(MARGIN; ($y0 + $txtH + 228600); 1097280; 45720; $t.darkAccent; null; 0)
      ] ),
    images: [ image_of($s.image; 0; 0; W; H; "fill"; $s.image.alt) + {layer: "back"} ],
    scrim: {color: "000000", alpha: ($s.scrim // 0.55)},
    notes: ($s.notes // "")
  };

# A row of pictures read left to right. Each caption sits under its own picture
# and the picture height is measured from what the captions leave, so a caption
# can never land on top of the image it describes.
def slide_gallery($s; $t; $idx):
  (($s.images // []) | length) as $n
  | (if $n > 4 then 4 elif $n < 1 then 1 else $n end) as $cols
  | (((CW - ($cols - 1) * GAP) / $cols) | floor) as $cwd
  | (BODY_Y + 91440) as $y0
  | ([ range(0; $cols) | ($s.images[.].caption // "") ] | any(. != "")) as $hasCap
  | (if $hasCap then 411480 else 0 end) as $perCapH
  | (if $s.caption then 411480 else 0 end) as $deckCapH
  | ((BODY_BOTTOM - 640080 - $y0 - $perCapH - $deckCapH) | floor) as $imgH
  | {
    index: $idx, kind: "gallery", dark: false,
    shapes: (
      [ title_shape($s.title; $t) ]
      + (if $s.lead then
           [ tshape(MARGIN; (BODY_Y - 91440); CW; 548640;
               [ para($s.lead; T_LEAD; $t.muted; false; 0; false; 0) ]; "l"; "b"; null) ]
         else [] end)
      + [ range(0; $cols) as $i |
          ($s.images[$i]) as $g |
          ((MARGIN + $i * ($cwd + GAP)) | floor) as $x |
          (if ($g.caption // "") == "" then empty
           else
             tshape($x; ($y0 + $imgH + 91440); $cwd; ($perCapH - 91440);
               [ para($g.caption; T_CAPTION; $t.muted; false; 0; false; 0) ]; "l"; "t";
               [0, 0, 0, 0])
           end)
        ]
      + (if $s.caption then
           [ tshape(MARGIN; (BODY_BOTTOM - 320040); CW; 320040;
               [ para($s.caption; T_CAPTION; $t.muted; false; 0; false; 0) ]; "l"; "t"; null) ]
         else [] end) ),
    images: [ range(0; $cols) as $i |
                ($s.images[$i]) as $g |
                image_of($g; (MARGIN + $i * ($cwd + GAP)); $y0; $cwd; $imgH;
                         ($g.fit // "fill"); $g.alt) ],
    notes: ($s.notes // "")
  };

# One sentence on a dark page. The quote and its attribution are measured and
# centred together; a fixed top anchor leaves the sentence floating high on the
# page with an equal void underneath.
def slide_quote($s; $t; $idx):
  (($s.quote | length) as $n | if $n <= 40 then 40 elif $n <= 70 then 34 elif $n <= 110 then 28 else 24 end) as $qs
  | (paras_h([ para($s.quote; $qs; "000000"; false; 0; false; 0) ]; ((CW * 9) / 10 | floor); null)) as $qH
  | (if $s.attribution then 365760 + 457200 else 0 end) as $atH
  | (((H - ($qH + $atH)) / 2) | floor) as $y0
  | {
    index: $idx, kind: "quote", dark: true,
    shapes: (
      [ tshape(MARGIN; $y0; ((CW * 9) / 10 | floor); $qH;
          [ para($s.quote; $qs; $t.darkFg; false; 0; false; 0) ]; "l"; "t"; null) ]
      + (if $s.attribution then
           [ tshape(MARGIN; ($y0 + $qH + 365760); CW; 457200;
               [ para("— " + $s.attribution; 16; $t.darkAccent; false; 0; false; 0) ]; "l"; "t"; null) ]
         else [] end) ),
    notes: ($s.notes // "")
  };

def slide_of($t):
  . as $s
  | ($s.kind // "bullets") as $kind
  | (if $kind == "title" then slide_title($s; $t; 0)
     elif $kind == "section" then slide_section($s; $t; 0)
     elif $kind == "columns" then slide_columns($s; $t; 0)
     elif $kind == "stats" then slide_stats($s; $t; 0)
     elif $kind == "kpi" then slide_kpi($s; $t; 0)
     elif $kind == "compare" then slide_compare($s; $t; 0)
     elif $kind == "timeline" then slide_timeline($s; $t; 0)
     elif $kind == "table" then slide_table($s; $t; 0)
     elif $kind == "chart" then slide_chart($s; $t; 0)
     elif $kind == "image" then slide_image($s; $t; 0)
     elif $kind == "imagetext" then slide_imagetext($s; $t; 0)
     elif $kind == "hero" then slide_hero($s; $t; 0)
     elif $kind == "gallery" then slide_gallery($s; $t; 0)
     elif $kind == "quote" then slide_quote($s; $t; 0)
     else slide_bullets($s; $t; 0) end)
  # Slide number and footer are added once the final index is known, in the
  # entry pipeline below, so a shape can never show the wrong page number.
  | . + {footer: ($t.footer // null),
         bg: (if .dark then $t.darkBg else $t.bg end),
         images: (.images // [])};

# Page number and running footer, appended after the final slide index exists.
# Returns a list of shapes to append; a caller merges with `+` on the array, not
# on the slide object, so the slide's own shapes are never replaced.
def footer_shapes($t; $i; $kind):
  if ($t.footer // null) == null or $kind == "title" or $kind == "hero" then []
  else
    (if $kind == "quote" or $kind == "section" then $t.darkMuted else $t.muted end) as $c
    | [ tshape(MARGIN; 6355080; ((CW * 85) / 100 | floor); 320040;
          [ para($t.footer; T_FOOTER; $c; false; 0; false; 0) ]; "l"; "t"; null) + {role: "chrome"},
        tshape((MARGIN + ((CW * 85) / 100 | floor)); 6355080; ((CW * 15) / 100 | floor); 320040;
          [ para((($i + 1) | tostring); T_FOOTER; $c; false; 0; false; 0) ]; "r"; "t"; null) + {role: "chrome"}
      ]
  end;

# ---------------------------------------------------------------------------
# Entry
# ---------------------------------------------------------------------------

. as $spec
| (($spec.theme // "ink")) as $themeName
| (if ($themeName | type) == "object"
   then
     (palette($themeName.base // "ink")) as $base
     | if $base == null then error("unknown palette: " + ($themeName.base // "ink")) else . end
     | ($base
        + {bg: ($themeName.bg // $base.bg), fg: ($themeName.fg // $base.fg),
           accent: ($themeName.accent // $base.accent), muted: ($themeName.muted // $base.muted),
           surface: ($themeName.surface // $base.surface), line: ($themeName.line // $base.line)})
   else
     (palette($themeName)) as $p
     | if $p == null then error("unknown palette: " + $themeName) else $p end
   end) as $t0
| ($t0 + {
    footer: ($spec.footer // null),
    fonts: {
      latin: ($spec.fonts.latin // "Pretendard"),
      eastAsian: ($spec.fonts.eastAsian // ($spec.fonts.latin // "Pretendard")),
      mono: ($spec.fonts.mono // "SF Mono")
    }
  }) as $t
| {
    title: ($spec.title // ""),
    author: ($spec.author // ""),
    lang: ($spec.lang // "ko"),
    footer: ($spec.footer // null),
    theme: $t,
    size: {w: W, h: H},
    slides: ([ $spec.slides[] | slide_of($t) ] | to_entries | map(
      .key as $i
      | .value
      | .shapes += footer_shapes($t; $i; .kind)
      # A stable id lets a layout finding name the shape it is about.
      | .shapes |= [ to_entries[] | .value + {id: ("s" + ((.key + 1) | tostring))} ]
      | .images |= [ to_entries[] | .value + {id: ("i" + ((.key + 1) | tostring))} ]
      | . + {index: $i}))
  }
