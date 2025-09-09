#!/usr/bin/env python3

import os
from pathlib import Path
from bs4 import BeautifulSoup

# --- CONFIGURATION: EDIT THIS LIST ---
# Add any filenames you want to exclude from the generated list.
FILES_TO_EXCLUDE = [
    "index.html",
    "stat845.html",
    "scheduling.html"
]
# ------------------------------------

# Add any directory names you want to completely exclude from the search.
# Any file inside a folder with one of these names will be ignored.
DIRECTORIES_TO_EXCLUDE = [
    "hidden"
]
# ------------------------------------

def create_html_link_list(root_dir=".", exclusion_list=None, directory_exclusion_list=None):
    """
    Searches for all .html files, extracts their titles, and generates an
    HTML list of links, applying exclusion rules.

    Args:
        root_dir (str): The starting directory to search from.
        exclusion_list (list, optional): A list of filenames to exclude.
        directory_exclusion_list (list, optional): A list of directory names
                                                    to exclude.

    Returns:
        str: A string containing the formatted HTML <li> elements.
    """
    if exclusion_list is None:
        exclusion_list = []
    if directory_exclusion_list is None:
        directory_exclusion_list = []
        
    html_items = []
    root_path = Path(root_dir)

    # Use rglob to recursively find all files ending with .html
    all_html_files = root_path.rglob("*.html")

    # Filter files: exclude by filename and by parent directory name.
    filtered_files = sorted([
        f for f in all_html_files
        if f.name not in exclusion_list and not any(part in directory_exclusion_list for part in f.parent.parts)
    ])

    if not filtered_files:
        return ""

    for html_file in filtered_files:
        try:
            # Get the relative path for the href attribute
            relative_path = html_file.relative_to(root_path).as_posix()

            # --- Extract the title from the HTML file ---
            with open(html_file, 'r', encoding='utf-8', errors='ignore') as f:
                soup = BeautifulSoup(f.read(), 'html.parser')

                if soup.title and soup.title.string:
                    title = soup.title.string.strip()
                else:
                    # Fallback: use the filename
                    title = html_file.stem.replace('_', ' ').replace('-', ' ').title()
            
            list_item = f'    <li><a href="{relative_path}">{title}</a></li>'
            html_items.append(list_item)

        except Exception as e:
            print(f"Could not process file {html_file}: {e}")

    return "\n".join(html_items)

if __name__ == "__main__":
    print("Searching for HTML files and generating list...")
    
    # Pass the exclusion lists from the top of the script to the function
    link_list = create_html_link_list(
        exclusion_list=FILES_TO_EXCLUDE,
        directory_exclusion_list=DIRECTORIES_TO_EXCLUDE
    )
    
    if link_list:
        print("\n--- Your HTML Code ---")
        print("<ol class=\"unit-list\">")
        print(link_list)
        print("</ol>")
        print("\n--- End of Code ---")
    else:
        print("No eligible .html files were found.")

