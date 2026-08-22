#!/usr/bin/env python3
"""GUI for appending an entry to longhailiCV-2026.qmd in `r ritem()` format.

Pick a category (auto-detected from headers followed by `r ritem("new")`),
pick/confirm an academic year, type the entry, and it's inserted as the
newest item in that year's block (creating the block if needed).

After using this, render the CV twice (as usual with ritem's two-pass
reverse numbering) to see correct item numbers.
"""
import re
import tkinter as tk
from datetime import date
from pathlib import Path
from tkinter import messagebox, ttk

CV_FILE = Path("/Users/longhai/Github/longhaiSK.github.io/longhailiCV-2026.qmd")

HEADER_RE = re.compile(r'^(#{2,3})\s+(.*\S)\s*$')
HEADER_ATTR_RE = re.compile(r'\s*\{[^{}]*\}\s*$')  # trailing pandoc {#id .class} attrs


def clean_header_text(text):
    return HEADER_ATTR_RE.sub('', text).strip()
NEW_LIST_RE = re.compile(r'`r\s+ritem\(\s*["\']new["\']\s*\)`')
YEAR_HEADER_RE = re.compile(r'^\*\*(\d{4})-(\d{4})\*\*\s*$')
YEAR_RANGE_RE = re.compile(r'^(\d{4})-(\d{4})$')


def default_academic_year():
    today = date.today()
    y = today.year
    return f"{y}-{y + 1}" if today.month >= 7 else f"{y - 1}-{y}"


def find_categories(lines):
    """Return header texts (in document order) that open a ritem("new") list."""
    cats = []
    for i, line in enumerate(lines):
        if not HEADER_RE.match(line):
            continue
        for j in range(i + 1, min(i + 5, len(lines))):
            if NEW_LIST_RE.search(lines[j]):
                cats.append(clean_header_text(HEADER_RE.match(line).group(2)))
                break
            if HEADER_RE.match(lines[j]):
                break
    return cats


def find_category_block(lines, category):
    """Locate the ritem("new") line for `category` and the end of its block
    (index of the next ##/### header, or EOF)."""
    for i, line in enumerate(lines):
        m = HEADER_RE.match(line)
        if not (m and clean_header_text(m.group(2)) == category):
            continue
        for j in range(i + 1, min(i + 5, len(lines))):
            if NEW_LIST_RE.search(lines[j]):
                end = len(lines)
                for k in range(j + 1, len(lines)):
                    if HEADER_RE.match(lines[k]):
                        end = k
                        break
                return j, end
            if HEADER_RE.match(lines[j]):
                break
    raise ValueError(f"Category not found in file: {category!r}")


def insert_entry(lines, category, year, text):
    """Insert `r ritem()` entry into `lines` (a list of lines with newlines).
    Returns the modified list."""
    new_idx, block_end = find_category_block(lines, category)

    year_positions = []  # (start_year, line_idx), in document order
    for k in range(new_idx + 1, block_end):
        m = YEAR_HEADER_RE.match(lines[k])
        if m:
            year_positions.append((int(m.group(1)), k))

    entry_line = f'`r ritem()` {text}\n'
    target_year = int(year.split('-')[0])

    # Case 1: matching year block already exists -> insert as its first item
    for start_year, idx in year_positions:
        if start_year == target_year:
            insert_at = idx + 1
            while insert_at < block_end and lines[insert_at].strip() == '':
                insert_at += 1
            lines.insert(insert_at, entry_line)
            return lines

    # Case 2: flat list, no year headers anywhere in this category -> insert first
    if not year_positions:
        insert_at = new_idx + 1
        while insert_at < block_end and lines[insert_at].strip() == '':
            insert_at += 1
        lines.insert(insert_at, entry_line)
        return lines

    # Case 3: need a brand-new year block, placed in descending order
    insert_before = block_end
    for start_year, idx in year_positions:
        if target_year > start_year:
            insert_before = idx
            break
    needs_leading_blank = insert_before == 0 or lines[insert_before - 1].strip() != ''
    new_block = ([ '\n'] if needs_leading_blank else []) + [f'**{year}**\n', entry_line]
    lines[insert_before:insert_before] = new_block
    return lines


class UpdateCVApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Update CV")
        self.geometry("560x420")
        self.resizable(False, False)

        if not CV_FILE.exists():
            messagebox.showerror("File not found", f"Cannot find:\n{CV_FILE}")
            self.destroy()
            return

        categories = find_categories(CV_FILE.read_text().splitlines(keepends=True))
        if not categories:
            messagebox.showerror("No categories found",
                                  "No headers with `r ritem(\"new\")` were found in the file.")
            self.destroy()
            return

        pad = {"padx": 10, "pady": 6}

        ttk.Label(self, text=f"File: {CV_FILE.name}", foreground="#555").pack(anchor="w", **pad)

        frm = ttk.Frame(self)
        frm.pack(fill="x", **pad)
        ttk.Label(frm, text="Category:").grid(row=0, column=0, sticky="w")
        self.category_var = tk.StringVar(value=categories[0])
        self.category_box = ttk.Combobox(frm, textvariable=self.category_var,
                                          values=categories, state="readonly", width=50)
        self.category_box.grid(row=0, column=1, sticky="w", padx=(8, 0))

        ttk.Label(frm, text="Year (YYYY-YYYY):").grid(row=1, column=0, sticky="w", pady=(8, 0))
        self.year_var = tk.StringVar(value=default_academic_year())
        ttk.Entry(frm, textvariable=self.year_var, width=15).grid(
            row=1, column=1, sticky="w", padx=(8, 0), pady=(8, 0))

        ttk.Label(self, text="Entry text:").pack(anchor="w", **pad)
        self.text_box = tk.Text(self, height=10, wrap="word")
        self.text_box.pack(fill="both", expand=True, padx=10)
        self.text_box.focus_set()

        btn_frm = ttk.Frame(self)
        btn_frm.pack(fill="x", **pad)
        ttk.Button(btn_frm, text="Add Entry", command=self.on_submit).pack(side="left")
        ttk.Button(btn_frm, text="Quit", command=self.destroy).pack(side="left", padx=8)

        self.status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.status_var, foreground="#0a7d00").pack(anchor="w", **pad)

        ttk.Label(self, text="Note: render the CV twice after adding entries "
                              "(ritem's two-pass reverse numbering).",
                  foreground="#888", wraplength=520).pack(anchor="w", padx=10, pady=(0, 8))

    def on_submit(self):
        category = self.category_var.get().strip()
        year = self.year_var.get().strip()
        text = self.text_box.get("1.0", "end").strip()

        if not YEAR_RANGE_RE.match(year):
            messagebox.showerror("Invalid year", "Year must look like 2025-2026.")
            return
        if not text:
            messagebox.showerror("Empty entry", "Entry text can't be empty.")
            return

        lines = CV_FILE.read_text().splitlines(keepends=True)
        try:
            lines = insert_entry(lines, category, year, text)
        except ValueError as e:
            messagebox.showerror("Error", str(e))
            return

        CV_FILE.write_text(''.join(lines))

        self.text_box.delete("1.0", "end")
        self.status_var.set(f"Added to “{category}” under {year}.")


if __name__ == "__main__":
    UpdateCVApp().mainloop()
