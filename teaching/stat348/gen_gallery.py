#!/bin/sh
""":"
# 1. Try Unix venv
PYTHON_EXEC="$(dirname "$0")/.venv/bin/python"

# 2. If not found, try Windows venv
if [ ! -f "$PYTHON_EXEC" ]; then
    PYTHON_EXEC="$(dirname "$0")/.venv/Scripts/python"
fi

# 3. If still not found, try system PATH
if [ ! -f "$PYTHON_EXEC" ]; then
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_EXEC="python3"
    elif command -v python >/dev/null 2>&1; then
        PYTHON_EXEC="python"
    else
        echo "gen_gallery: Neither virtualenv nor system Python found." >&2
        exit 1
    fi
fi

exec "$PYTHON_EXEC" "$0" "$@"
"""

# Regenerates gallery.qmd (the "Figures, Tables, and Apps" index) straight from
# the labels and captions already in the chapter .qmd files, so the gallery
# can never drift out of sync with the book. Run it after adding, removing, or
# relabeling any fig-/tbl- chunk or shinylive app section:
#
#   ./gen_gallery.py
#
# It reads chapter order from _quarto.yml, so no chapter list is hardcoded here.

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
QUARTO_YML = ROOT / "_quarto.yml"
OUTPUT = ROOT / "gallery.qmd"
SKIP = {"index.qmd", "gallery.qmd"}

HEADING_RE = re.compile(r'^(#{1,6})\s+(.*)$')
HEADING_ID_RE = re.compile(r'\{#([\w-]+)\}')
# Every shinylive app in this book is wrapped in a Pandoc "Figure Div":
#   ::: {#fig-foo-app ...}
#
#   ```{shinylive-r}
#   ...
#   ```
#
#   **Caption.** More caption text.
#
#   :::
# Quarto treats the trailing paragraph inside a `fig-`-id'd div as that
# figure's caption, exactly like #| fig-cap does for a plain chunk -- so that
# is where the app's real caption/label lives, not the id on the enclosing
# heading (which is a separate, plain section anchor). An opener always
# carries `{...}` attributes; a closer is always bare, so the two are told
# apart by that rather than by counting colons (openers are usually ":::",
# but a handful of legacy files use "::::").
DIV_FENCE_RE = re.compile(r'^:{3,}')
DIV_OPEN_RE = re.compile(r'^:{3,}\s*\{([^}]*)\}\s*$')
DIV_ID_IN_ATTRS_RE = re.compile(r'#([\w-]+)')
CHUNK_START_RE = re.compile(r'^```\{(r|shinylive-r)[^}]*\}')
KABLE_CAPTION_RE = re.compile(r'caption\s*=\s*(["\'])(.*?)\1')
# A real chunk option always has exactly one space after "#|" (knitr/quarto
# convention: "#| key: value"). A continuation line of a multi-line quoted
# value is indented further ("#|   more text") to align under the value, and
# must be checked first -- otherwise a continuation that happens to start
# with "Word:" (e.g. captions with "Left: ... / Right: ...") would be
# misparsed as a brand-new option.
OPTION_RE = re.compile(r'^#\| ([\w.-]+):\s*(.*)$')
CONTINUATION_RE = re.compile(r'^#\|\s{2,}(.*)$')
TITLE_RE = re.compile(r'^title:\s*(.+)$', re.M)


def get_chapter_order():
    text = QUARTO_YML.read_text(encoding="utf-8")
    lines = text.splitlines()
    chapters = []
    in_chapters = False
    for line in lines:
        if re.match(r'^\s*chapters:\s*$', line):
            in_chapters = True
            continue
        if in_chapters:
            m = re.match(r'^\s*-\s*(\S+\.qmd)\s*$', line)
            if m:
                chapters.append(m.group(1))
                continue
            if re.match(r'^\s*-\s', line):
                continue  # tolerate other list forms
            if re.match(r'^\S', line) or re.match(r'^\s*\w+:', line):
                break  # dedented to a new top-level/sibling key: chapters block ended
    return [c for c in chapters if c not in SKIP]


def get_title(path):
    text = path.read_text(encoding="utf-8")
    m = TITLE_RE.search(text)
    return m.group(1).strip().strip('"').strip("'") if m else path.stem


def clean_caption(raw):
    raw = raw.strip()
    if not raw:
        return raw
    quote = raw[0] if raw[0] in "\"'" else None
    if quote and raw.endswith(quote):
        raw = raw[1:-1]
        if quote == '"':
            raw = raw.replace('\\\\', '\\')
        else:
            raw = raw.replace("''", "'")
    return raw.strip()


SENTENCE_SPLIT_RE = re.compile(r'(?<=[.!?])\s+(?=\*{0,2}[A-Z(])')


def split_sentences(text):
    text = re.sub(r'\s+', ' ', text).strip()
    if not text:
        return []
    return [s.strip() for s in SENTENCE_SPLIT_RE.split(text) if s.strip()]


def first_sentence(text):
    """The gallery shows only a one-line teaser, not the full caption/paragraph."""
    sentences = split_sentences(text)
    return sentences[0] if sentences else text.strip()


# Every app's Figure Div caption opens with a bold label -- "**Shinylive App
# Illustrating X.** Real description follows." -- and that label is exactly
# what the gallery lists, since it names the app the way the book's own
# cross-references do. The period of that first sentence sits inside the
# closing "**" rather than against whitespace, so split_sentences does not
# see a sentence break there and would return the label glued to the
# description that follows; match the leading bold run directly instead.
LEADING_BOLD_RE = re.compile(r'^\*\*([^*]+)\*\*\s*[:.]?')


def app_label_sentence(text):
    """Return the bold label opening an app's Figure Div caption, or None.

    The "**" markers are dropped so app entries read like the figure and
    table entries around them, and the terminal punctuation is normalised to
    a period whether it was written inside or outside the bold run.
    """
    if not text:
        return None
    m = LEADING_BOLD_RE.match(text.strip())
    if not m:
        return None
    label = m.group(1).strip().rstrip(':.').strip()
    return (label + '.') if label else None


def strip_heading_text(raw_heading):
    text = raw_heading.lstrip('#').strip()
    text = HEADING_ID_RE.sub('', text).strip()
    return text


def parse_chapter(path):
    title = get_title(path)
    lines = path.read_text(encoding="utf-8").splitlines()
    n = len(lines)

    figs, tbls, apps = [], [], []

    last_heading_raw = ""
    paragraph_buffer = []
    last_paragraph = None
    div_stack = []      # id (or None) of each currently open ::: div, innermost last
    pending_app = None  # the fig- div id a shinylive-r chunk was just found inside

    def flush_paragraph():
        nonlocal last_paragraph
        if paragraph_buffer:
            last_paragraph = ' '.join(paragraph_buffer).strip()
            paragraph_buffer.clear()

    def current_fig_div():
        for div_id in reversed(div_stack):
            if div_id and div_id.startswith('fig-'):
                return div_id
        return None

    i = 0
    while i < n:
        line = lines[i]

        hm = HEADING_RE.match(line)
        if hm:
            flush_paragraph()
            last_paragraph = None
            last_heading_raw = line
            i += 1
            continue

        fm = DIV_FENCE_RE.match(line.strip())
        if fm:
            flush_paragraph()
            om = DIV_OPEN_RE.match(line.strip())
            if om:
                idm = DIV_ID_IN_ATTRS_RE.search(om.group(1))
                div_stack.append(idm.group(1) if idm else None)
            else:
                closed_id = div_stack.pop() if div_stack else None
                if pending_app is not None and closed_id == pending_app:
                    # We've just closed the fig- div a shinylive-r chunk was
                    # found in; whatever paragraph immediately preceded this
                    # closing fence is that Figure Div's caption, and its
                    # leading bold label is the gallery entry.
                    desc = app_label_sentence(last_paragraph)
                    if desc is None:
                        print(f"WARNING: {path.name}: app '{pending_app}' has no "
                              f"bold '**...**' label opening its Figure Div "
                              f"caption; falling back to the first sentence.",
                              file=sys.stderr)
                        desc = (first_sentence(last_paragraph) if last_paragraph
                                else strip_heading_text(last_heading_raw))
                    apps.append((pending_app, desc))
                    pending_app = None
            i += 1
            continue

        cm = CHUNK_START_RE.match(line)
        if cm:
            flush_paragraph()
            engine = cm.group(1)
            start = i
            i += 1
            opts = {}
            current_key = None
            code_lines = []
            while i < n and lines[i].rstrip() != '```':
                contm = CONTINUATION_RE.match(lines[i])
                if contm and current_key:
                    opts[current_key] = opts[current_key] + ' ' + contm.group(1)
                else:
                    om = OPTION_RE.match(lines[i])
                    if om:
                        current_key = om.group(1)
                        opts[current_key] = om.group(2)
                    else:
                        current_key = None
                        code_lines.append(lines[i])
                i += 1
            label = opts.get('label', '')

            if label.startswith('fig-') and 'fig-cap' in opts:
                figs.append((label, first_sentence(clean_caption(opts['fig-cap']))))
            elif label.startswith('tbl-'):
                if 'tbl-cap' in opts:
                    tbls.append((label, first_sentence(clean_caption(opts['tbl-cap']))))
                else:
                    # kable()/gt() etc. sometimes carry the caption as a call
                    # argument (caption = "...") instead of a #| tbl-cap option.
                    cm = KABLE_CAPTION_RE.search('\n'.join(code_lines))
                    if cm:
                        tbls.append((label, first_sentence(cm.group(2))))
                    else:
                        print(f"WARNING: {path.name}: table '{label}' has no "
                              f"tbl-cap option or caption= argument; skipped in gallery.",
                              file=sys.stderr)

            if engine == 'shinylive-r':
                fig_id = current_fig_div()
                if fig_id:
                    pending_app = fig_id
                else:
                    print(f"WARNING: {path.name}: shinylive app '{label}' near line "
                          f"{start+1} is not inside a '::: {{#fig-...}}' div; skipped "
                          f"in gallery.", file=sys.stderr)
            i += 1
            continue

        if line.strip() == '':
            flush_paragraph()
        else:
            paragraph_buffer.append(line.strip())
        i += 1

    return title, figs, tbls, apps


def render_gallery(chapters_data):
    lines = []
    lines.append("# List of Figures, Tables, and Apps")
    lines.append("")
    lines.append("A consolidated index of every numbered figure and table in the book, plus "
                  "the interactive Shiny apps. Click any entry to jump to it in context.")
    lines.append("")
    lines.append("## List of Shinylive Apps")
    lines.append("")
    for title, figs, tbls, apps in chapters_data:
        for sec_id, desc in apps:
            lines.append(f"* @{sec_id} — {desc}")
    lines.append("")

    lines.append("## List of Figures")
    lines.append("")
    for title, figs, tbls, apps in chapters_data:
        if not figs:
            continue
        lines.append(f"### {title}")
        lines.append("")
        for label, cap in figs:
            lines.append(f"* @{label} — {cap}")
        lines.append("")

    lines.append("## List of Tables")
    lines.append("")
    for title, figs, tbls, apps in chapters_data:
        if not tbls:
            continue
        lines.append(f"### {title}")
        lines.append("")
        for label, cap in tbls:
            lines.append(f"* @{label} — {cap}")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def main():
    chapter_files = get_chapter_order()
    if not chapter_files:
        print("gen_gallery: no chapters found in _quarto.yml", file=sys.stderr)
        sys.exit(1)

    chapters_data = []
    n_fig = n_tbl = n_app = 0
    seen_labels = {}  # label -> chapter title that first defined it
    for rel in chapter_files:
        path = ROOT / rel
        if not path.exists():
            print(f"WARNING: {rel} listed in _quarto.yml but not found on disk; skipped.",
                  file=sys.stderr)
            continue
        # On a case-insensitive filesystem (e.g. default macOS) `path.exists()`
        # can succeed even when the on-disk filename's case differs from the
        # one written in _quarto.yml. That mismatch is harmless locally but
        # means the chapter silently fails to resolve on a case-sensitive
        # host (Linux CI, GitHub Pages) -- catch it here instead.
        if path.name not in {p.name for p in path.parent.iterdir()}:
            print(f"WARNING: {rel} in _quarto.yml does not match the on-disk "
                  f"filename's case exactly; rename the file or fix the yml "
                  f"entry, or this chapter will vanish from the gallery (and "
                  f"the book) on a case-sensitive filesystem.", file=sys.stderr)
        title, figs, tbls, apps = parse_chapter(path)
        chapters_data.append((title, figs, tbls, apps))
        n_fig += len(figs); n_tbl += len(tbls); n_app += len(apps)

        # @label must be unique across the whole book -- a collision silently
        # makes Quarto's cross-reference resolve to whichever chapter renders
        # first, so surface it here rather than let it hide in the HTML.
        for label, _ in figs:
            _check_duplicate(label, title, seen_labels)
        for label, _ in tbls:
            _check_duplicate(label, title, seen_labels)
        for sec_id, _ in apps:
            _check_duplicate(sec_id, title, seen_labels)

    OUTPUT.write_text(render_gallery(chapters_data), encoding="utf-8")
    print(f"gen_gallery: wrote {OUTPUT.name} — {n_fig} figures, {n_tbl} tables, "
          f"{n_app} interactive apps across {len(chapters_data)} chapters.", file=sys.stderr)


def _check_duplicate(label, title, seen_labels):
    prior = seen_labels.get(label)
    if prior is not None and prior != title:
        print(f"WARNING: label '{label}' is used in both '{prior}' and "
              f"'{title}' -- @{label} will resolve ambiguously; rename one.",
              file=sys.stderr)
    else:
        seen_labels[label] = title


if __name__ == "__main__":
    main()