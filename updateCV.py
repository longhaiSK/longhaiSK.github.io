#!/usr/bin/env python3
"""GUI for editing longhailiCV-2026.qmd's `r ritem()` lists.

The entry box always holds the *entire* file -- it's the single source of
truth while the app is open, and Save writes it back verbatim. The
category (## header) -> subcategory (### header) -> year/type group (a
**bold** line like **2025-2026** or **Ph.D. Students**) selectors don't
edit anything themselves; picking one just scrolls/positions the cursor
in the box at the right spot:
- If the chosen year/type already exists, its header + first entry are
  selected in the box so you can see and edit them directly.
- If it doesn't exist yet, the cursor is placed where a new block should
  go (in sorted order for year groups); type the new **header** and
  entry there yourself.

Render renders profweb-html only (twice, for ritem's two-pass reverse
numbering) and opens the browser jumped to the anchor of the current
category/subcategory. It saves the box to disk first.
"""
import re
import subprocess
import threading
import tkinter as tk
import webbrowser
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from tkinter import messagebox, ttk

CV_FILE = Path("/Users/longhai/Github/longhaiSK.github.io/longhailiCV-2026.qmd")
HTML_PORT = 8080  # assumes a local server (e.g. `quarto preview` or `python3 -m http.server`)
                   # is already serving CV_FILE.parent on this port
RENDER_FORMAT = "profweb-html"

HEADER_RE = re.compile(r'^(#{2,3})\s+(.*\S)\s*$')
ATTR_BLOCK_RE = re.compile(r'\{([^{}]*)\}\s*$')  # trailing pandoc {#id .class} attrs
ID_IN_ATTR_RE = re.compile(r'#([^\s}]+)')
BOLD_HEADER_RE = re.compile(r'^\*\*(.+)\*\*\s*$')  # a `**...**`-only line = a group header
NEW_LIST_RE = re.compile(r'`r\s+ritem\(\s*["\']new["\']\s*\)`')
ITEM_RE = re.compile(r'^`r\s+ritem\(\s*\)`')
YEAR_RANGE_RE = re.compile(r'^(\d{4})-(\d{4})$')


def split_header_title(raw_title):
    """('9.1 Foo {#bar}', ...) -> ('9.1 Foo', 'bar'); no attrs -> (title, None)."""
    m = ATTR_BLOCK_RE.search(raw_title)
    if not m:
        return raw_title.strip(), None
    idm = ID_IN_ATTR_RE.search(m.group(1))
    return raw_title[:m.start()].strip(), (idm.group(1) if idm else None)


def slugify(title):
    """Reproduce Pandoc's auto-identifier algorithm (verified against the
    actual rendered longhailiCV-2026.html anchor ids)."""
    t = title.lower()
    t = re.sub(r'[^a-z0-9_\-. ]', '', t)
    t = t.replace(' ', '-')
    t = re.sub(r'^[^a-z]+', '', t)
    return t or 'section'


def default_academic_year():
    today = date.today()
    y = today.year
    return f"{y}-{y + 1}" if today.month >= 7 else f"{y - 1}-{y}"


def render_url(anchor=None):
    url = f"http://localhost:{HTML_PORT}/{CV_FILE.stem}.html"
    return f"{url}#{anchor}" if anchor else url


@dataclass
class Header:
    level: int
    title: str
    line: int          # index of the header line itself
    body_start: int    # first line after the header
    end: int            # index of next header at <= this level, or EOF
    explicit_id: str = None


def parse_headers(lines):
    raw = []
    for i, line in enumerate(lines):
        m = HEADER_RE.match(line)
        if m:
            title, explicit_id = split_header_title(m.group(2))
            raw.append(Header(level=len(m.group(1)), title=title, line=i,
                               body_start=i + 1, end=len(lines), explicit_id=explicit_id))
    for idx, h in enumerate(raw):
        for other in raw[idx + 1:]:
            if other.level <= h.level:
                h.end = other.line
                break
    return raw


def anchor_for(header):
    return header.explicit_id or slugify(header.title)


def has_ritem(lines, start, end):
    return any('ritem(' in lines[k] for k in range(start, end))


def get_categories(lines):
    """## headers (in doc order) that contain ritem() usage anywhere under them."""
    headers = parse_headers(lines)
    return [h.title for h in headers if h.level == 2 and has_ritem(lines, h.body_start, h.end)]


def get_subcategories(lines, category):
    """### headers under `category` that use ritem(). Empty list means the
    category itself is the leaf (no subcategory division)."""
    headers = parse_headers(lines)
    cat = next(h for h in headers if h.level == 2 and h.title == category)
    return [h.title for h in headers
            if h.level == 3 and cat.line < h.line < cat.end and has_ritem(lines, h.body_start, h.end)]


def get_header(lines, category, subcategory):
    headers = parse_headers(lines)
    cat = next(h for h in headers if h.level == 2 and h.title == category)
    if subcategory and subcategory != category:
        return next(h for h in headers
                     if h.level == 3 and h.title == subcategory and cat.line < h.line < cat.end)
    return cat


get_leaf = get_header  # alias: the header whose body directly holds the entry list


def find_groups(lines, start, end):
    """(title, header_line_idx) for **bold** group headers within [start, end), in doc order."""
    return [(BOLD_HEADER_RE.match(lines[k]).group(1).strip(), k)
            for k in range(start, end) if BOLD_HEADER_RE.match(lines[k])]


def group_entry_zone(lines, groups, idx, leaf_end):
    """Where entries for groups[idx] start (skipping blank lines and an immediate
    ritem("new") restart) and end (next group header or leaf end)."""
    _, header_line = groups[idx]
    end = groups[idx + 1][1] if idx + 1 < len(groups) else leaf_end
    s = header_line + 1
    while s < end and lines[s].strip() == '':
        s += 1
    if s < end and NEW_LIST_RE.search(lines[s]):
        s += 1
        while s < end and lines[s].strip() == '':
            s += 1
    return s, end


def leaf_entry_zone(lines, start, end):
    """Same as group_entry_zone but for the top of a leaf, before any group header."""
    s = start
    while s < end and lines[s].strip() == '':
        s += 1
    if s < end and NEW_LIST_RE.search(lines[s]):
        s += 1
        while s < end and lines[s].strip() == '':
            s += 1
    return s


def find_first_entry_span(lines, search_start, boundary):
    """Return (first_line_idx, end_idx) spanning just the first `r ritem()`
    entry (including any indented continuation lines) within [search_start,
    boundary). end_idx is the start of the next entry if one exists (so
    inter-entry spacing is preserved), else `boundary` trimmed of trailing
    blank lines. Returns (None, None) if there's no entry at all."""
    first = next((k for k in range(search_start, boundary) if ITEM_RE.match(lines[k].strip())), None)
    if first is None:
        return None, None
    second = next((k for k in range(first + 1, boundary) if ITEM_RE.match(lines[k].strip())), None)
    if second is not None:
        return first, second
    end = boundary
    while end > first + 1 and lines[end - 1].strip() == '':
        end -= 1
    return first, end


def get_groups_for(lines, category, subcategory):
    leaf = get_leaf(lines, category, subcategory)
    return find_groups(lines, leaf.body_start, leaf.end)


def build_nav(lines):
    """Precompute category -> subcategory -> [group titles] once, so the
    selector comboboxes are plain dict/list lookups instead of re-parsing
    the whole document on every click or keystroke. Rebuilt at load and
    after Save; jump_to_selection still parses the live box text (cheaply,
    via a cache of its own) to find exact line numbers to jump to."""
    categories = get_categories(lines)
    nav = {}
    for cat in categories:
        subcats = get_subcategories(lines, cat)
        subs = subcats if subcats else [cat]
        nav[cat] = {sub: [t for t, _ in get_groups_for(lines, cat, sub)] for sub in subs}
    return categories, nav


def compute_insert_point(lines, category, subcategory, group_title):
    """Where a new (not-yet-existing) group_title's block belongs: sorted by
    year for year-range groups, otherwise the top of the leaf's entry list."""
    leaf = get_leaf(lines, category, subcategory)
    groups = find_groups(lines, leaf.body_start, leaf.end)
    group_title = (group_title or '').strip()
    ymatch = YEAR_RANGE_RE.match(group_title)
    all_years = bool(groups) and all(YEAR_RANGE_RE.match(t) for t, _ in groups)

    if groups and ymatch and all_years:
        target_year = int(group_title.split('-')[0])
        insert_before = leaf.end
        for title, hline in groups:
            if target_year > int(title.split('-')[0]):
                insert_before = hline
                break
        return insert_before

    return leaf_entry_zone(lines, leaf.body_start, leaf.end)


def compute_jump(lines, category, subcategory, group_title):
    """Return (start, end, mode) describing where in `lines` the selector
    points, for scrolling/selecting in the entry box. mode is one of:
    - "replace": [start, end) is an existing header + first entry to select.
    - "insert":  start == end is where a new group's block should be typed.
    - "blocked": a grouped list but no year/type chosen yet; start == end
      is just the top of the list.
    """
    leaf = get_leaf(lines, category, subcategory)
    groups = find_groups(lines, leaf.body_start, leaf.end)
    group_title = (group_title or '').strip()

    for idx, (title, hline) in enumerate(groups):
        if title.lower() == group_title.lower():
            s, e = group_entry_zone(lines, groups, idx, leaf.end)
            first, end = find_first_entry_span(lines, s, e)
            if first is None:
                return hline, hline + 1, "replace"
            return hline, end, "replace"

    if not groups:
        if not group_title:
            s = leaf_entry_zone(lines, leaf.body_start, leaf.end)
            first, end = find_first_entry_span(lines, s, leaf.end)
            if first is None:
                return s, s, "replace"
            return first, end, "replace"
        insert_at = compute_insert_point(lines, category, subcategory, group_title)
        return insert_at, insert_at, "insert"

    if not group_title:
        return leaf.body_start, leaf.body_start, "blocked"

    insert_at = compute_insert_point(lines, category, subcategory, group_title)
    return insert_at, insert_at, "insert"


class UpdateCVApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Update CV")
        self.geometry("680x560")
        self.minsize(600, 500)

        if not CV_FILE.exists():
            messagebox.showerror("File not found", f"Cannot find:\n{CV_FILE}")
            self.destroy()
            return

        full_text = CV_FILE.read_text()
        lines = full_text.splitlines(keepends=True)
        self.categories, self.nav = build_nav(lines)
        if not self.categories:
            messagebox.showerror("No categories found",
                                  "No headers with `r ritem(\"new\")` were found in the file.")
            self.destroy()
            return

        pad = {"padx": 10, "pady": 6}
        ttk.Label(self, text=f"File: {CV_FILE.name}", foreground="#555").pack(anchor="w", **pad)

        frm = ttk.Frame(self)
        frm.pack(fill="x", **pad)
        frm.columnconfigure(1, weight=1)

        ttk.Label(frm, text="Category:").grid(row=0, column=0, sticky="w")
        self.category_var = tk.StringVar()
        self.category_box = ttk.Combobox(frm, textvariable=self.category_var,
                                          values=self.categories, state="readonly", width=55)
        self.category_box.grid(row=0, column=1, sticky="we", padx=(8, 0))
        self.category_box.bind("<<ComboboxSelected>>", lambda e: self.on_category_change())

        ttk.Label(frm, text="Subcategory:").grid(row=1, column=0, sticky="w", pady=(8, 0))
        self.subcat_var = tk.StringVar()
        self.subcat_box = ttk.Combobox(frm, textvariable=self.subcat_var,
                                        state="readonly", width=55)
        self.subcat_box.grid(row=1, column=1, sticky="we", padx=(8, 0), pady=(8, 0))
        self.subcat_box.bind("<<ComboboxSelected>>", lambda e: self.on_subcat_change())

        ttk.Label(frm, text="Year / Type:").grid(row=2, column=0, sticky="w", pady=(8, 0))
        self.group_var = tk.StringVar()
        self.group_box = ttk.Combobox(frm, textvariable=self.group_var, width=30)
        self.group_box.grid(row=2, column=1, sticky="w", padx=(8, 0), pady=(8, 0))
        self.group_box.bind("<<ComboboxSelected>>", lambda e: self.on_group_change())
        self.group_box.bind("<KeyRelease>", lambda e: self.on_group_change())
        ttk.Label(frm, text="(pick an existing one, type a new year/topic, "
                            "or leave blank if this list has no groups)",
                  foreground="#888").grid(row=3, column=1, sticky="w", padx=(8, 0))

        self.mode_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.mode_var, foreground="#a05a00").pack(anchor="w", **pad)

        ttk.Label(self, text="File contents (the selectors above just jump the cursor here — "
                              "edit and Save writes the whole file back):"
                  ).pack(anchor="w", padx=10)
        self.entry_box = tk.Text(self, height=12, wrap="word", undo=True)
        self.entry_box.pack(fill="both", expand=True, padx=10, pady=(2, 0))
        self.entry_box.insert("1.0", full_text)
        self._lines_cache = lines
        self.entry_box.edit_modified(False)
        self._sel_range = None

        btn_frm = ttk.Frame(self)
        btn_frm.pack(fill="x", **pad)
        ttk.Button(btn_frm, text="Save", command=self.on_save).pack(side="left")
        self.render_btn = ttk.Button(btn_frm, text="Render && Open in Browser", command=self.on_render)
        self.render_btn.pack(side="left", padx=8)
        ttk.Button(btn_frm, text="Quit", command=self.destroy).pack(side="left", padx=8)

        self.status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.status_var, foreground="#0a7d00").pack(anchor="w", **pad)

        self.category_var.set(self.categories[0])
        self.on_category_change()

    def box_lines(self):
        """Live box text as a lines list, cached and only re-fetched from the
        Tk widget (an expensive cross-boundary call for a whole-file buffer)
        when it's actually been edited since the last fetch."""
        if self._lines_cache is None or self.entry_box.edit_modified():
            self._lines_cache = self.entry_box.get("1.0", "end-1c").splitlines(keepends=True)
            self.entry_box.edit_modified(False)
        return self._lines_cache

    def on_category_change(self):
        category = self.category_var.get()
        values = list(self.nav.get(category, {}).keys()) or [category]
        self.subcat_box["values"] = values
        self.subcat_var.set(values[0])
        self.on_subcat_change()

    def on_subcat_change(self):
        category, subcategory = self.category_var.get(), self.subcat_var.get()
        titles = self.nav.get(category, {}).get(subcategory, [])
        self.group_box["values"] = titles
        if titles and all(YEAR_RANGE_RE.match(t) for t in titles):
            self.group_var.set(default_academic_year())
        elif titles:
            self.group_var.set(titles[0])
        else:
            self.group_var.set("")
        self.jump_to_selection()

    def on_group_change(self):
        self.jump_to_selection()

    def jump_to_selection(self):
        lines = self.box_lines()
        category, subcategory, group_title = (self.category_var.get(), self.subcat_var.get(),
                                                self.group_var.get())
        try:
            start, end, mode = compute_jump(lines, category, subcategory, group_title)
        except StopIteration:
            return

        tk_start, tk_end = f"{start + 1}.0", f"{end + 1}.0"
        if self._sel_range:
            self.entry_box.tag_remove("sel", *self._sel_range)
            self._sel_range = None
        if mode == "replace" and end > start:
            self.entry_box.tag_add("sel", tk_start, tk_end)
            self._sel_range = (tk_start, tk_end)
        self.entry_box.mark_set("insert", tk_start)
        self.entry_box.see(tk_start)

        if mode == "replace":
            self.mode_var.set("Jumped to the existing entry — edit in place, or add lines "
                               "above it for a newest entry, then Save.")
        elif mode == "insert":
            self.mode_var.set(f"Cursor placed where “{group_title.strip()}” belongs — "
                               "type the new **header** and entry here, then Save.")
        else:
            self.mode_var.set("This list is grouped — choose or type a Year/Type above to jump to it.")

    def write_box_to_file(self):
        text = self.entry_box.get("1.0", "end-1c")
        if not text.endswith("\n"):
            text += "\n"
        CV_FILE.write_text(text)

    def on_save(self):
        self.write_box_to_file()

        category, subcategory = self.category_var.get(), self.subcat_var.get()
        self.categories, self.nav = build_nav(self.box_lines())
        if category in self.categories:
            self.category_box["values"] = self.categories
            values = list(self.nav[category].keys())
            self.subcat_box["values"] = values
            if subcategory in values:
                self.group_box["values"] = self.nav[category][subcategory]

        self.status_var.set(f"Saved {CV_FILE.name}.")

    def current_anchor(self):
        lines = self.box_lines()
        headers = parse_headers(lines)
        category, subcategory = self.category_var.get(), self.subcat_var.get()
        cat = next(h for h in headers if h.level == 2 and h.title == category)
        if subcategory and subcategory != category:
            sub = next((h for h in headers if h.level == 3 and h.title == subcategory
                        and cat.line < h.line < cat.end), None)
            if sub:
                return anchor_for(sub)
        return anchor_for(cat)

    def on_render(self):
        self.write_box_to_file()
        self.pending_anchor = self.current_anchor()
        self.render_btn.config(state="disabled")
        self.status_var.set("Rendering (pass 1/2)…")
        threading.Thread(target=self._render_worker, daemon=True).start()

    def _render_worker(self):
        # ritem() needs two renders to settle its reverse-numbering cache
        for pass_num in (1, 2):
            self.after(0, lambda p=pass_num: self.status_var.set(f"Rendering (pass {p}/2)…"))
            try:
                result = subprocess.run(
                    ["quarto", "render", CV_FILE.name, "--to", RENDER_FORMAT],
                    cwd=CV_FILE.parent, capture_output=True, text=True,
                )
            except FileNotFoundError:
                self.after(0, lambda: self._render_failed(
                    "`quarto` not found on PATH. Is Quarto installed?"))
                return
            if result.returncode != 0:
                self.after(0, lambda p=pass_num, r=result: self._render_failed(
                    f"quarto render failed (pass {p}/2):\n\n{r.stderr[-2000:]}"))
                return
        self.after(0, self._render_succeeded)

    def _render_failed(self, message):
        self.render_btn.config(state="normal")
        self.status_var.set("Render failed.")
        messagebox.showerror("Render failed", message)

    def _render_succeeded(self):
        self.render_btn.config(state="normal")
        url = render_url(self.pending_anchor)
        self.status_var.set(f"Rendered. Opening {url} …")
        webbrowser.open(url)


if __name__ == "__main__":
    UpdateCVApp().mainloop()
