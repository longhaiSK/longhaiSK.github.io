#!/Users/longhai/Github/bin/.venv/bin/python3

import re

# --- CONFIGURATION ---
file_path = "lec1-vecspace.qmd"  # Change this to your filename
# Create a backup just in case
backup_path = file_path + ".bak"

# --- THE REGEX ---
# 1. (::: \{#[^}]+)  -> Capture Group 1: The opening ::: and the {#id... part
# 2. \}              -> Match the closing brace (we will replace it)
# 3. \s*\n\s* -> Match whitespace, a newline, and potential blank lines/indentation
# 4. #{1,6}\s+       -> Match the markdown header (e.g. ##, ####)
# 5. (.+)            -> Capture Group 2: The actual title text
pattern = r"(::: \{#[^}]+)\}\s*\n\s*#{1,6}\s+(.+)"

# --- THE REPLACEMENT ---
# \1        -> Restore the ::: {#id...
# title="\2" -> Add the title attribute using Group 2
# }         -> Close the brace
replacement = r'\1 title="\2"}'

def process_file():
    try:
        # 1. Read the content
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 2. Save a backup
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Backup created: {backup_path}")

        # 3. Perform the Regex Substitution
        # re.MULTILINE isn't strictly needed here because we match \n explicitly,
        # but it helps anchor ^ if we used it. 
        new_content, count = re.subn(pattern, replacement, content)

        # 4. Write back if changes were made
        if count > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Success! Replaced {count} occurrences.")
        else:
            print("No matches found. Check your regex or file content.")

    except FileNotFoundError:
        print(f"Error: Could not find file '{file_path}'")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    process_file()
