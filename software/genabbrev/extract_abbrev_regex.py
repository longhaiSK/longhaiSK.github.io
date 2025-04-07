# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: -remove
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.16.7
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# + editable=true id="341c23fe-78ff-4705-88ed-df1a16e863a1" tags=["remove"]
import os

#os.system('jupyter nbconvert --to script extract_abbrev_regex.ipynb --TagRemovePreprocessor.remove_cell_tags="remove"')
#os.system('jupytext extract_abbrev_regex.ipynb --to py")

# I made this change in colab

# + editable=true id="b736e5f0-26b8-42e4-9f4a-db61fa2d0f81"
import streamlit as st
import re
from datetime import datetime # Import datetime for current date example
import pandas as pd

# + id="f657e848-b933-4135-90ba-78a55409c24c" jupyter={"source_hidden": true}
# Functions for normalizing and extracting abbrs

# Code block prepared on Thursday, April 3, 2025 at 12:38:43 AM CST in Saskatoon, Saskatchewan, Canada.
# Optional import for error display if using Streamlit
# try:
#     import streamlit as st
# except ImportError:
#     st = None # Define st as None if not available

# This list is used by normalize_latex_math
upper_greek_cmds = [
    'Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi',
    'Sigma', 'Upsilon', 'Phi', 'Psi', 'Omega'
]

# --- Normalization Function ---
def normalize_latex_math(text):
    """
    Preprocesses LaTeX text:
    1. Converts LaTeX inline math \( ... \) to $ ... $.
    2. Removes LaTeX comments (% to end of line), respecting \%.
    3. Removes preamble/end tags if \begin{document} is found.
    4a. Adds space BEFORE and AFTER opening curly braces ({).
    4b. Adds space BEFORE and AFTER closing curly braces (}).
    5. Adds space after specific uppercase Greek commands (\Cmd) if not present. (Note: Using corrected pattern)
    6. Adds space after lowercase LaTeX commands (\cmd) if not already present. (Note: Pattern may be restrictive)
    7. Removes whitespace immediately following $. (Moved Step)
    8. Cleans up extra blank lines and trims whitespace.
    """
    if not isinstance(text, str):
        print("Warning: Input to normalize_latex_math was not a string.")
        return text

    processed_text = text
    try:
        # 1. Normalize math \(...\) to $...$
        processed_text = re.sub(
            r'\\\(\s*(.*?)\s*\\\)',
            lambda match: f"${match.group(1).strip()}$",
            processed_text
        )

        # 2. Remove LaTeX comment lines (respects \%)
        processed_text = re.sub(r'(?<!\\)%.*$', '', processed_text, flags=re.MULTILINE)

        # 3. Remove preamble IF \begin{document} exists
        begin_doc_marker = r'\begin{document}'
        begin_doc_index = processed_text.find(begin_doc_marker)
        if begin_doc_index != -1:
            processed_text = processed_text[begin_doc_index + len(begin_doc_marker):]
        # 3b. Remove \end{document} if present near the end
        end_doc_marker = r'\end{document}'
        end_doc_index = processed_text.rfind(end_doc_marker)
        if end_doc_index != -1 and len(processed_text) - end_doc_index < 30: # Heuristic check
            processed_text = processed_text[:end_doc_index]

        # --- Spacing Adjustments ---
        # 4a. Add space BEFORE and AFTER { (handles existing spaces robustly)
        processed_text = re.sub(r'\s*\{\s*', r' { ', processed_text)

        # 4b. Add space BEFORE and AFTER } (handles existing spaces robustly)
        processed_text = re.sub(r'\s*\}\s*', r' } ', processed_text)

        # 5. Add space after specific uppercase Greek commands (\Cmd) if not followed by space
        pattern_part = '|'.join(upper_greek_cmds)
        # Using corrected pattern (no space after \\)
        pattern_upper = rf'(\\({pattern_part}))(?!\s)'
        processed_text = re.sub(pattern_upper, r'\1 ', processed_text)

        # 6. Add space after lowercase commands (\cmd) if not followed by specific pattern
        # !!! Note: This pattern (?=[A-Z][^a-z]) might be too restrictive.
        processed_text = re.sub(r'(\\[a-z]+)(?=[A-Z][^a-z])', r'\1 ', processed_text)

        # 7. Remove one or more whitespace characters (\s+) immediately after a dollar sign ($) (Moved Step)
        processed_text = re.sub(r'\$\s+', '$', processed_text)

        # 8. Clean up potential excessive blank lines and trim overall whitespace
        processed_text = re.sub(r'(\n\s*){2,}', '\n', processed_text) # Collapse blank lines
        #processed_text = processed_text.strip() # Trim leading/trailing whitespace

        # 9. Join non-empty newline to the previous line
        #processed_text = re.sub(r'(\r\n|\r|\n)', ' ', processed_text)       # Optional final step: Collapse multiple spaces into one IF NEEDED
        # processed_text = re.sub(r' +', ' ', processed_text)

        return processed_text

    except Exception as e:
        error_message = f"Error during LaTeX text preprocessing: {e}"
        try:
            # Attempt to use streamlit for error display if available
            import streamlit as st
            st.error(error_message)
        except ImportError:
            # Fallback to print if streamlit is not available
            print(error_message)
        return text # Return original text on error


# + id="b1381c44-7aeb-4691-aa1c-058eeea37777" jupyter={"source_hidden": true}
## convert the abbreviation into a lower case letter for comparison
def get_abbr_repr_items(abbr_string):
    """
    Parses abbreviation string, returns list of representative items WITHOUT Greek mapping.
    - Keeps ALL LaTeX commands (like \frac, \gamma) as strings.
    - Takes the uppercase letter from sequences like 'Cp' or 'CPs', ignoring trailing lowercase.
    - Includes standalone lowercase letters.
    """
    representative_items = []
    # Regex captures: \cmd | Upper | OptionalLowerSuffix | StandaloneLower
    findings = re.findall(r'(\\[a-zA-Z]+)|([A-Z])([a-z]+)?|([a-z])', abbr_string)

    # The tuple returned by findall will have 4 elements corresponding to the groups
    for command, upper, trailing_lower, standalone_lower in findings:
        if command:  # Group 1: \command
            # Keep the original command string (no mapping)
            representative_items.append(command)
        elif upper:  # Group 2: An uppercase letter was found
            # Use the uppercase letter, ignore trailing lowercase (group 3)
            representative_items.append(upper.lower())
        elif standalone_lower: # Group 4: A standalone lowercase letter
            representative_items.append(standalone_lower)
    return representative_items

## capturing the first letter of the words for comparison
def get_effective_char(word: str, debug: bool = False) -> str:
    """
    Tries to derive the effective matching character from a LaTeX-style word
    by stripping common leading markup and finding the first letter.
    """
    original = word
    word_to_check = word
    try:
        # Heuristically strip leading commands/braces to find the first actual letter.
        m1 = re.match(r'^\s*\\[a-zA-Z]+\s*\{(.*)', word_to_check)
        if m1:
            word_to_check = m1.group(1)
            # Removed internal debug print for brevity in final code
        else:
            m2 = re.match(r'^\s*\{\s*\\[a-zA-Z]+\s+(.*)', word_to_check)
            if m2:
                content = m2.group(1)
                if content.endswith('}'): content = content[:-1].rstrip()
                word_to_check = content
            else:
                m3 = re.match(r'^\s*\\[a-zA-Z]+(\s+.*)', word_to_check)
                if m3:
                     if m3.group(1) and m3.group(1).strip():
                         word_to_check = m3.group(1).lstrip()

        if word_to_check.startswith('{'):
            word_to_check = word_to_check[1:].lstrip()

        match = re.search(r'[a-zA-Z]', word_to_check)
        if match:
             return match.group(0).lower()

        if word_to_check is not original:
             match_orig = re.search(r'[a-zA-Z]', original)
             if match_orig:
                  return match_orig.group(0).lower()

        return ''

    except Exception as e:
        # Keep error print if helper function itself fails when its debug is on
        if debug: print(f"      Error in get_effective_char for '{original}': {e}")
        match = re.search(r'[a-zA-Z]', original)
        return match.group(0).lower() if match else ''


# + id="87b2ab12-5fd9-4397-9bfb-b522db6f3a66"
def find_abbreviation_matches(words_ahead, abbr_items, debug=True):
    """
    Performs backward matching between definition words (words_ahead) and
    abbreviation items (abbr_items). Uses V3 comparison logic.
    If debug=True, prints cumulative matching DataFrame (requires pandas
    to be imported globally as pd) and final indices map.
    NOTE: Enabling debug=True can significantly slow down execution due to
          DataFrame creation/printing in the loop.

    Args:
        words_ahead (list): List of word tokens from the definition part.
        abbr_items (list): List of representative items from the abbreviation part.
        debug (bool): Flag to enable cumulative DataFrame printing.

    Returns:
        list: A list where index `i` contains the index from `words_ahead`
              that matches `abbr_items[i]`, or -1 if no match was found.
    """
    num_abbr_items = len(abbr_items)
    num_words = len(words_ahead)
    match_indices = [-1] * num_abbr_items

    # Initialize structures for pandas debug output if needed
    words_line = words_ahead[:]
    abbr_line = [''] * num_words

    last_matched_index = num_words

    # Outer loop iterates through Abbr Items in reverse
    for abbr_idx in range(num_abbr_items - 1, -1, -1):
        target_abbr = abbr_items[abbr_idx]
        match_found_for_abbr = False # Renamed for clarity

        # Inner loop iterates through Words in reverse
        for i in range(last_matched_index - 1, -1, -1):
            word = words_ahead[i]
            # Call helper with debug=False unless you want its prints too
            effective_char = get_effective_char(word, debug=False)

            current_match_found = False
            # --- V3 COMPARISON LOGIC ---
            if target_abbr.startswith('\\'):
                word_to_compare = word
                if word_to_compare.startswith('$'):
                    word_to_compare = word_to_compare[1:]
                if word_to_compare.startswith(target_abbr):
                    current_match_found = True
            elif effective_char:
                if effective_char == target_abbr:
                    current_match_found = True
            # --- END V3 COMPARISON LOGIC ---

            if current_match_found:
                match_indices[abbr_idx] = i
                abbr_line[i] = target_abbr # Update debug line
                last_matched_index = i
                match_found_for_abbr = True
                break # Found match for this abbr_idx

        # --- Cumulative Debug Output ---
        # This block now assumes 'pd' is available if debug is True
        if debug:
             try:
                 # Create DataFrame using the globally imported pd
                 df_data = {'Words before': words_line, 'Abb matched': abbr_line}
                 df = pd.DataFrame(df_data)
                 print(f"\nMatching result after item '{target_abbr}' (abbr_idx {abbr_idx}):")
                 print(df.T.to_string())
             except NameError: # Catch error if pd wasn't imported globally
                 print("(NameError: 'pd' not defined. Cannot print DataFrame. "
                       "Import pandas as pd globally for DataFrame debug output.)")
                 print(f"Abb matched line state: {abbr_line}") # Fallback
             except Exception as df_err:
                 print(f"(Error creating/printing DataFrame: {df_err})")
                 print(f"Abb matched line state: {abbr_line}") # Fallback
        # --- End Cumulative Debug Output ---

    # --- Final Debug Output ---
    if debug:
        print(f"\nFinal Abbreviation Match Indices: {match_indices}")
    # --- End Final Debug Output ---

    return match_indices

import re
# Assume find_abbreviation_matches, get_abbr_repr_items, and get_effective_char
# are defined as previously provided.
# Assume normalize_latex_math is also available if you use it beforehand.

# --- Updated Extraction function with Threshold Validation & Reduced Debug ---

def extract_abbreviations(text, match_threshold=0.6, debug=True):
    """
    Extracts abbreviations defined as (Abbr) following their definition.
    Validates match if a certain threshold of abbreviation items are matched
    to corresponding words.

    Args:
        text (str): The input text potentially containing definitions.
        match_threshold (float): The minimum fraction (e.g., 0.7 for 70%) of
                                 abbreviation items that must be successfully
                                 matched to words for the definition to be
                                 considered valid.
        debug (bool): Flag to enable extensive debug printing.

    Returns:
        dict: A dictionary mapping abbreviation strings to their extracted full definitions.
    """
    # Main pattern (same as before - restricted to same line)
    pattern = re.compile(
        r'('                      # Start Group 1: Preceding words
         r'(?:[\w\-\$\\\{\}]+[ \t]?){1,10}' # Words separated by space/tab on same line
        r')'                      # End Group 1
        r'\(\s*'                  # Literal opening parenthesis
        r'('                      # Start Group 2: Abbreviation
         r'(?=.*[A-Z\\\$])'       # Positive lookahead
         r'[\w\s\$\-\\\{\}]+'   # Allowed characters
        r')'                      # End Group 2 capture
        r'\s*\)'                  # Literal closing parenthesis
    )
    matches = pattern.findall(text)
    abbreviation_dict = {}

    # Get current time and location context for potential use
    current_time_str = "Thursday, April 3, 2025 at 5:42:20 PM CST" # Replace with dynamic time if needed
    current_location = "Saskatoon, Saskatchewan, Canada"

    if debug: print(f"\nDebugging extract_abbreviations: Found {len(matches)} potential matches.")
    if debug: print(f"(Context: {current_time_str}, {current_location})")


    for match in matches:
        words_before_abbr_text = match[0].strip()
        abbr_string = match[1].strip()
        abbr_items = get_abbr_repr_items(abbr_string)

        # Split preceding text using space/hyphen, retaining delimiters
        words_ahead = [item for item in re.split(r'([ -]+)', words_before_abbr_text) if item]

        if debug:
            # Debug printing for candidate
            print(f"\n---\nCandidate Found:")
            print(f"  Captured Abbr String: '{abbr_string}'")
            print(f"  Generated abbr_items: {abbr_items}")
            print(f"  Preceding Text for Split: '{words_before_abbr_text}'")
            # --- BLOCK REMOVED ---
            # print(f"  Split words_ahead (elements - includes separators):")
            # if words_ahead:
            #     for i, word in enumerate(words_ahead):
            #         print(f"    [{i}]: '{word}'")
            # else:
            #     print("    (list is empty)")
            # --- END BLOCK REMOVED ---
            # You could optionally print the whole list if needed, e.g.:
            # print(f"  Split words_ahead list: {words_ahead}")


        # Initial check: Need words and abbreviation items to proceed
        if not words_ahead or not abbr_items:
             if debug: print(f"  Skipping: No words ahead ({bool(words_ahead)}) or no abbr items found ({bool(abbr_items)}).")
             continue

        # Call the matching function (assuming it's defined)
        # Ensure find_abbreviation_matches is defined elsewhere using the latest logic
        match_indices = find_abbreviation_matches(words_ahead, abbr_items, debug)

        # Post-match checks and reconstruction
        successful_match_indices = [idx for idx in match_indices if idx != -1]
        count_matched = len(successful_match_indices)
        num_abbr_items = len(abbr_items)

        if debug:
             # Keep these summary debug prints
             print(f"  Successful match indices for words: {successful_match_indices}")
             print(f"  Final match_indices map (abbr_idx -> word_idx): {match_indices}")
             print(f"  Items matched: {count_matched} out of {num_abbr_items}")

        # Validation Logic (using threshold)
        valid_match = False
        if num_abbr_items > 0:
             ratio_matched = count_matched / num_abbr_items
             if ratio_matched >= match_threshold:
                 valid_match = True
             elif debug:
                 print(f"  Validation Failed: Match ratio {ratio_matched:.2f} "
                       f"is less than threshold {match_threshold:.2f}")
        elif debug:
             print("  Validation Failed: No abbreviation items were generated.")

        # Reconstruction Logic
        if valid_match:
            if not successful_match_indices:
                 if debug: print("  Skipping: Match deemed valid by ratio, but no word indices found?")
                 continue

            min_idx_py = min(successful_match_indices)
            max_idx_py = max(successful_match_indices)

            if min_idx_py <= max_idx_py:
                full_phrase_words_slice = words_ahead[min_idx_py : max_idx_py + 1]
                full_name = ''.join(full_phrase_words_slice)

                if debug: print(f"  Validation Passed (Ratio >= {match_threshold:.2f}). Storing: '{abbr_string}': '{full_name}'")
                abbreviation_dict[abbr_string] = full_name
            elif debug: print(f"  Skipping: min_idx ({min_idx_py}) > max_idx ({max_idx_py}) issue.")


    if debug: print(f"--- Debugging End ---\nFinal Dict: {abbreviation_dict}")
    return abbreviation_dict


# + editable=true id="f48d8618-3d25-4f3a-8b46-a4d3079d1605" jupyter={"source_hidden": true}
# Functions for formatting abbrs

def format_abbreviations(abbreviations_dict, format_type):
    """Formats the extracted abbreviations based on the specified type.
       Sorts abbreviations alphabetically, handling LaTeX commands in keys.
       ASSUMES extracted abbr and full_name are valid LaTeX snippets
       for 'tabular' and 'nomenclature' formats. No escaping is applied.
    """
    if not abbreviations_dict:
        return "No abbreviations found."

    # --- ADD SORTING STEP HERE ---
    try:
        # Sort the dictionary items alphabetically based on the abbreviation (item[0])
        sorted_items = sorted(
            abbreviations_dict.items(),
            key=lambda item: get_sort_key_from_abbr(item[0])
        )
    except Exception as e:
        # Error handling for sorting, fallback to unsorted
        st.error(f"Error during abbreviation sorting: {e}. Displaying unsorted.")
        sorted_items = abbreviations_dict.items()
    # --- END SORTING STEP ---

    if format_type == "nomenclature":
        # LaTeX nomenclature package format
        latex_output = "\\usepackage{nomencl}\n"
        latex_output += "\\makenomenclature\n"
        for abbr, full_name in sorted_items:
            latex_output += f"\\nomenclature{{{abbr}}}{{{full_name}}}\n"
        return latex_output

    elif format_type == "tabular":
        # LaTeX tabular format for a table
        latex_output = "\\begin{tabular}{ll}\n"
        latex_output += "\\hline\n"
        latex_output += "\\textbf{Abbreviation} & \\textbf{Full Name} \\\\\n"
        latex_output += "\\hline\n"
        for abbr, full_name in sorted_items:
            latex_output += f"{abbr} & {full_name} \\\\\n"
        latex_output += "\\hline\n"
        latex_output += "\\end{tabular}\n"
        return latex_output

    else:
        # Default format: plain list of abbreviations and full names
        output = ""
        items_list = list(sorted_items)  # Convert to list for index access if needed
        for i, (abbr, full_name) in enumerate(items_list):
            output += f"{abbr}: {full_name}"
            if i < len(items_list) - 1:
                output += "; \n"  # Adds a semicolon between items
        return output


def get_sort_key_from_abbr(abbr_string):
    """Generates a lowercase string key for sorting abbreviations."""
    repr_letters = get_abbr_repr_items(abbr_string)
    sort_key = "".join(repr_letters).lower()
    if not sort_key:
         fallback_key = re.sub(r"^[^\w]+", "", abbr_string.lower())
         return fallback_key
    return sort_key

#print( r"\begin{tabular}{ll} \hline \textbf{Abbreviation} & \textbf{Full Name} \\ \hline AFT & accelerated failure time \\ $\alpha Z$R & $\alpha$-$Z$-residuals \\ $\beta$$Z$R & $\beta$-$Z$-residuals \\ $frac{ \gamma}{ Z}-R & $\frac{ \gamma}{ Z}$-residuals \\ $\gamma Z$R & $\gamma$-$Z$-residuals \\ LT & \LaTex text \\ RSP & randomized survival probabilities \\ TC & Time-Constant \\ \hline \end{tabular}")




# + editable=true id="d26d6e3c-6372-45d3-a2dc-3c21262aeeaf" outputId="61334b69-e9f5-43ee-b97a-3988a86b8266"
# example_text
example_text = r"""Paste your \LaTex text (LT) and enjoy the app.

The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time(AFT), or \textbf{Time-Constant (TC) Data} will be caught.

The citations and explanations in brackets will be omitted, for example, this one (Wu et al. 2024), regression coeficcient ($\beta$). This is not an abbreviation (acronym) either.

%The comment text (CT) or line will be omitted.

The full name and abbrievation can contain greek symbols, for example,  $\alpha$-\( Z \)-residuals($\alpha Z$R), $\frac{\gamma}{Z}$-residuals($\frac{\gamma}{Z}$-R)
"""
#print(example_text)
#extract_abbreviations(normalize_latex_math(example_text),debug=False)


# + id="df50c561-69c2-485b-b7b0-c4d559268dc7" jupyter={"outputs_hidden": true} outputId="a1b8872d-9ffd-413b-fdfe-1d3a63e82801"
# normalize_latex_math Example with example_text
#normtext = normalize_latex_math(example_text)
#print(normtext)

# + id="3e23265f-6775-4cdc-ba9c-89c51cebf8f6" outputId="2377ff10-d6f6-47af-e02e-936777c4ac51"
#extract_abbreviations(normalize_latex_math(example_text),debug=False)

# + editable=true id="0e7dfa4d-df12-4923-8154-3da60db28f34" jupyter={"source_hidden": true} tags=["remove"]
# This cell is removed
from IPython.display import HTML, display
import html # Used for escaping, though might not be strictly needed depending on content

def render_dataframe_with_latex(df):
    """
    Generates an IPython HTML object to display a Pandas DataFrame
    with LaTeX rendering via MathJax. Corrected f-string syntax (v3).

    Args:
        df (pd.DataFrame): The Pandas DataFrame to render. Assumes LaTeX
                           is enclosed in $...$ or \(...\).

    Returns:
        IPython.display.HTML: An HTML object ready for display in notebooks.
    """

    # Convert DataFrame to HTML, ensuring LaTeX characters are not escaped
    # Also add some basic Bootstrap classes for better table styling
    table_html = df.to_html(escape=False, classes=['table', 'table-striped', 'table-bordered'], border=0, index=False)

    # Full HTML document including MathJax configuration - with corrected f-string syntax
    full_html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DataFrame with LaTeX</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script>
      MathJax = {{{{ // Start Escaped Braces for JS Object
        tex: {{{{
          inlineMath: [['$', '$'], ['\\(', '\\)']], // Recognize $...$ and \(...\)
          displayMath: [['$$', '$$'], ['\\[', '\\]']], // Recognize $$...$$ and \[...\]
          processEscapes: true
        }}}}, // End tex config
        svg: {{{{
          fontCache: 'global'
        }}}} // End svg config
      }}}}; // End MathJax config
    </script>
    <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
    <style>
        /* Optional: Add some padding */
        .dataframe {{{{ margin: 20px; }}}} /* Escaped braces for CSS */
        th, td {{{{ text-align: left; padding: 8px; }}}} /* Escaped braces for CSS */
    </style>
</head>
<body>

<div class="container-fluid">
{table_html}
</div>

</body>
</html>
    """
    return HTML(full_html)

def extract_abbreviations(text, require_first_last_match=True, debug=True):
    """
    Extracts abbreviations defined as (Abbr) following their definition.
    Attempts to handle various LaTeX math/command formats, including stripping
    leading formatting locally when determining the matching character.
    Matches abbreviation command strings (like \frac) if they appear in the words.
    """
    # Pattern allows spaces inside abbr, requires lookahead for uppercase/$/\
    # Allows {} in preceding words and abbreviation content
    pattern = re.compile(
        r'('                      # Start Group 1: Preceding words
         r'(?:[\w\-\$\\\{\}]+\s+){1,10}' # Word pattern
        r')'                      # End Group 1
        r'\(\s*'                  # Literal opening parenthesis, optional space
        # --- Group 2: Abbreviation ---
        r'('                      # Start Group 2 capture
         r'(?=.*[A-Z\\\$])'       # Positive lookahead: Must contain uppercase, \ or $
         r'[\w\s\$\-\\\{\}]+'   # Match allowed characters (incl. space, {})
        r')'                      # End Group 2 capture
        # --- End Group 2 ---
        r'\s*\)'                  # Optional space, literal closing parenthesis
    )
    matches = pattern.findall(text)
    abbreviation_dict = {}

    if debug: print(f"\nDebugging extract_abbreviations: Found {len(matches)} potential matches.")

    for match in matches:
        words_before_abbr_text = match[0].strip()
        # Use the split that handles hyphens between letters
        words_ahead = [word for word in re.split(r'\s+|(?<=-)(?=[A-Za-z])', words_before_abbr_text) if word]
        abbr_string = match[1].strip() # Strip leading/trailing space from captured abbr
        # Use the version that keeps command strings
        abbr_letters = get_abbr_repr_letters_v2(abbr_string)

        if debug: # Print statements if needed
            print(f"\n---\nCandidate Found:")
            print(f"  Captured Abbr String: '{abbr_string}'")
            print(f"  Generated abbr_letters: {abbr_letters}")
            print(f"  Preceding Text for Split: '{words_before_abbr_text}'")
            print(f"  Split words_ahead (elements):")
            if words_ahead:
                for i, word in enumerate(words_ahead):
                    print(f"    [{i}]: '{word}'")
            else:
                print("    (list is empty)")

        # Check if words_ahead list exists and if abbr_letters has at least 2 items
        if not words_ahead or len(abbr_letters) < 2:
            if debug: print(f"  Skipping: Not enough words ahead ({bool(words_ahead)}) or less than 2 abbr items found ({len(abbr_letters)}).")
            continue

        # If we passed the check, we know we have at least 2 items
        num_abbr_letters = len(abbr_letters)
        match_indices = [-1] * num_abbr_letters
        unmatched_abbr_indices = set(range(num_abbr_letters))

        # Backward matching logic
        for i, word in enumerate(reversed(words_ahead)):
            original_idx = len(words_ahead) - 1 - i
            if not unmatched_abbr_indices: break

            # --- REVISED effective_char Logic v3 (as provided before) ---
            effective_char = None
            word_to_check = word # Start with the original token

            # 1. Attempt to strip ONLY LEADING markup heuristically
            try:
                stripped_something = False # Flag to track if changes were made
                m1 = re.match(r'^\s*\\([a-zA-Z]+)\s*\{(.*)', word_to_check)
                if m1:
                    word_to_check = m1.group(2)
                    stripped_something = True
                    if debug: print(f"    Stripped '\\cmd{{' prefix -> CheckAs: '{word_to_check}'")
                else:
                    m2 = re.match(r'^\s*\{\s*\\([a-zA-Z]+)\s+(.*)', word_to_check)
                    if m2:
                        content = m2.group(2)
                        if content.endswith('}'): content = content[:-1].rstrip()
                        word_to_check = content
                        stripped_something = True
                        if debug: print(f"    Stripped '{{\\cmd ' prefix -> CheckAs: '{word_to_check}'")
                    else:
                        m3 = re.match(r'^\s*\\([a-zA-Z]+)(\s+.*)', word_to_check)
                        if m3:
                            cmd_name = m3.group(1)
                            # Only strip if it's NOT a mapped greek command we need later
                            # Check existence of greek_map defensively
                            if 'greek_map' in globals() and cmd_name not in greek_map:
                                word_to_check = m3.group(2).lstrip()
                                stripped_something = True
                                if debug: print(f"    Stripped '\\cmd ' prefix -> CheckAs: '{word_to_check}'")

                if word_to_check.startswith('{'):
                    word_to_check = word_to_check[1:].lstrip()
                    stripped_something = True
                    if debug: print(f"    Stripped leading '{{' -> CheckAs: '{word_to_check}'")

                if stripped_something and not word_to_check.strip():
                    word_to_check = word
                    if debug: print(f"    Reverted stripping as it resulted in empty string.")

            except Exception as e:
                if debug: print(f"    Error during word stripping: {e}")
                word_to_check = word

            # 2. Now find effective char using the potentially cleaned word_to_check
            m_dollar = re.match(r'\$\\([a-zA-Z]+)', word_to_check)
            # Check existence of greek_map defensively
            if 'greek_map' in globals() and m_dollar and m_dollar.group(1) in greek_map:
                effective_char = greek_map[m_dollar.group(1)]
            else:
                m_slash = re.match(r'\\([a-zA-Z]+)', word_to_check)
                if 'greek_map' in globals() and m_slash and m_slash.group(1) in greek_map:
                    effective_char = greek_map[m_slash.group(1)]
                else:
                    m_first_letter = re.search(r'[a-zA-Z]', word_to_check)
                    if m_first_letter:
                        effective_char = m_first_letter.group(0).lower()
            # --- END REVISED effective_char Logic v3 ---

            if debug: print(f"  Word: '{word}' (CheckAs: '{word_to_check}'), Effective Char: '{effective_char}'")

            # --- MODIFIED COMPARISON LOGIC ---
            # Compare effective char OR command string with remaining abbreviation items
            # Check if word could potentially match either via effective char or command prefix
            if effective_char is not None or word.startswith('\\'):
                best_match_abbr_idx = -1
                # Iterate through remaining unmatched abbr indices, highest first
                for abbr_idx in sorted(list(unmatched_abbr_indices), reverse=True):
                    target_abbr = abbr_letters[abbr_idx]
                    match_found = False

                    if target_abbr.startswith('\\'):
                        # If abbr item is a command, check if the original word starts with it
                        if word.startswith(target_abbr):
                            match_found = True
                            if debug: print(f"    -> Matched command '{target_abbr}' by prefix in word '{word}'")
                    elif effective_char is not None:
                        # If abbr item is a letter, use effective_char comparison
                        if effective_char == target_abbr:
                            match_found = True
                            if debug: print(f"    -> Matched letter '{target_abbr}' via effective_char '{effective_char}' in word '{word}'")

                    if match_found:
                        best_match_abbr_idx = abbr_idx
                        break # Found best match for this word, move to next word

                if best_match_abbr_idx != -1:
                    # Store the original index of the matched word
                    match_indices[best_match_abbr_idx] = original_idx
                    # Remove the matched index from the set of those needing matches
                    unmatched_abbr_indices.remove(best_match_abbr_idx)
            # --- END MODIFIED COMPARISON LOGIC ---


        # --- Post-loop checks and reconstruction ---
        successful_match_indices = [idx for idx in match_indices if idx != -1]
        if debug: print(f"  Successful match indices for words: {successful_match_indices}")
        if debug: print(f"  Final match_indices map (abbr_idx -> word_idx): {match_indices}")


        if not successful_match_indices:
             if debug: print("  Skipping: No successful matches found during backward search.")
             continue

        # Validation Step
        valid_match = True
        if require_first_last_match:
            if match_indices[0] == -1 or match_indices[num_abbr_letters - 1] == -1:
                valid_match = False
                if debug: print(f"  Validation Failed: First or last letter not matched (Indices map: {match_indices})")

        if valid_match:
            min_idx_py = min(successful_match_indices)
            max_idx_py = max(successful_match_indices)

            if min_idx_py <= max_idx_py:
                # Slice uses original words_ahead tokens
                full_phrase_words_slice = words_ahead[min_idx_py : max_idx_py + 1]
                # Use the join logic that handles hyphens correctly
                # Join words, adding space unless previous word ended with hyphen
                full_name = ''.join(word if i == 0 else (' ' + word if not full_phrase_words_slice[i - 1].endswith('-') else word)
                                    for i, word in enumerate(full_phrase_words_slice))


                if debug: print(f"  Validation Passed. Storing: '{abbr_string}': '{full_name}'")
                # Store original abbreviation string and reconstructed full name
                abbreviation_dict[abbr_string] = full_name
            elif debug: print(f"  Skipping: min_idx ({min_idx_py}) > max_idx ({max_idx_py}) issue.") # Should not happen if successful_match_indices not empty
        elif debug: print(f"  Skipping: Match deemed invalid by require_first_last_match.")

    #if debug: print(f"--- Debugging End ---\nFinal Dict: {abbreviation_dict}")
    return abbreviation_dict

def extract_abbreviations(text, require_first_last_match=True, debug=True):
    """
    Extracts abbreviations defined as (Abbr) following their definition.
    Attempts to handle various LaTeX math/command formats, including stripping
    leading formatting locally when determining the matching character.
    """
    # Pattern allows spaces inside abbr, requires lookahead for uppercase/$/\
    # Allows {} in preceding words and abbreviation content
    pattern = re.compile(
        r'('                     # Start Group 1: Preceding words
          r'(?:[\w\-\$\\\{\}]+\s+){1,10}' # Word pattern
        r')'                     # End Group 1
        r'\(\s*'                 # Literal opening parenthesis, optional space
        # --- Group 2: Abbreviation ---
        r'('                     # Start Group 2 capture
          r'(?=.*[A-Z\\\$])'     # Positive lookahead: Must contain uppercase, \ or $
          r'[\w\s\$\-\\\{\}]+'   # Match allowed characters (incl. space, {})
        r')'                     # End Group 2 capture
        # --- End Group 2 ---
        r'\s*\)'                 # Optional space, literal closing parenthesis
    )
    matches = pattern.findall(text)
    abbreviation_dict = {}

    if debug: print(f"\nDebugging extract_abbreviations: Found {len(matches)} potential matches.")

    for match in matches:
        words_before_abbr_text = match[0].strip()
        # Use the split that handles hyphens between letters
        words_ahead = [word for word in re.split(r'\s+|(?<=-)(?=[A-Za-z])', words_before_abbr_text) if word]
        abbr_string = match[1].strip() # Strip leading/trailing space from captured abbr
        abbr_letters = get_abbr_repr_letters_v2(abbr_string)



        # Handle LaTeX-style abbreviations correctly (raw string handling)
        abbr_letters = get_abbr_repr_letters_v2(abbr_string)

        if debug: # Print statements if needed
            # print(text)
            print(f"\n---\nCandidate Found:")
            # print(match) # Raw match tuple if needed
            print(f"  Captured Abbr String: '{abbr_string}'")
            print(f"  Generated abbr_letters: {abbr_letters}")
            print(f"  Preceding Text for Split: '{words_before_abbr_text}'")

            print(f"  Split words_ahead (elements):")
            if words_ahead: # Avoid error if list is empty
                for i, word in enumerate(words_ahead):
                # Now 'word' is a string directly in the f-string, so it uses str()
                    print(f"    [{i}]: '{word}'")
                else:
                    print("    (list is empty)")

        # Check if words_ahead list exists and if abbr_letters has at least 2 items
        if not words_ahead or len(abbr_letters) < 2:
            if debug: print(f"  Skipping: Not enough words ahead ({bool(words_ahead)}) or less than 2 abbr letters found ({len(abbr_letters)}).")
            continue

        # If we passed the check, we know we have at least 2 letters
        num_abbr_letters = len(abbr_letters)
        match_indices = [-1] * num_abbr_letters
        unmatched_abbr_indices = set(range(num_abbr_letters))

        # Backward matching logic
        for i, word in enumerate(reversed(words_ahead)):

            original_idx = len(words_ahead) - 1 - i
            if not unmatched_abbr_indices: break

            # --- REVISED effective_char Logic v3 ---
            effective_char = None
            word_to_check = word # Start with the original token

            # 1. Attempt to strip ONLY LEADING markup heuristically
            try:
                stripped_something = False # Flag to track if changes were made
                # Pattern: Optional whitespace, \command, optional space, { ? -> Group 1 has cmd, Group 2 has content after {
                m1 = re.match(r'^\s*\\([a-zA-Z]+)\s*\{(.*)', word_to_check)
                if m1:
                    word_to_check = m1.group(2) # Use content starting after {
                    stripped_something = True
                    if debug: print(f"    Stripped '\\cmd{{' prefix -> CheckAs: '{word_to_check}'")
                else:
                    # Pattern: Optional whitespace, {\command ... -> Group 1 has cmd, Group 2 has content after space
                    m2 = re.match(r'^\s*\{\s*\\([a-zA-Z]+)\s+(.*)', word_to_check)
                    if m2:
                         content = m2.group(2)
                         # Remove potential trailing brace from this pattern
                         if content.endswith('}'): content = content[:-1].rstrip()
                         word_to_check = content
                         stripped_something = True
                         if debug: print(f"    Stripped '{{\\cmd ' prefix -> CheckAs: '{word_to_check}'")
                    else:
                         # Pattern: \command (not Greek) followed by space+content -> Group 1 is cmd, Group 2 is content after space
                         m3 = re.match(r'^\s*\\([a-zA-Z]+)(\s+.*)', word_to_check)
                         if m3:
                             cmd_name = m3.group(1)
                             # Only strip if it's NOT a mapped greek command we need later
                             if cmd_name not in greek_map:
                                 word_to_check = m3.group(2).lstrip() # Use content after command+space
                                 stripped_something = True
                                 if debug: print(f"    Stripped '\\cmd ' prefix -> CheckAs: '{word_to_check}'")

                # Remove purely structural leading brace if it exists after other steps
                if word_to_check.startswith('{'):
                     word_to_check = word_to_check[1:].lstrip()
                     stripped_something = True # Mark potentially changed
                     if debug: print(f"    Stripped leading '{{' -> CheckAs: '{word_to_check}'")

                # Revert if stripping resulted in empty string
                if stripped_something and not word_to_check.strip():
                     word_to_check = word # Use original word
                     if debug: print(f"    Reverted stripping as it resulted in empty string.")

            except Exception as e:
                if debug: print(f"    Error during word stripping: {e}")
                word_to_check = word # Use original word if stripping fails

            # 2. Now find effective char using the potentially cleaned word_to_check
            # Check for $\command... first
            m_dollar = re.match(r'\$\\([a-zA-Z]+)', word_to_check)
            if m_dollar and m_dollar.group(1) in greek_map:
                effective_char = greek_map[m_dollar.group(1)]
            else:
                # Check for \command... second (only if not stripped above and is greek)
                m_slash = re.match(r'\\([a-zA-Z]+)', word_to_check)
                # Only use if it's a known greek command we need for matching
                if m_slash and m_slash.group(1) in greek_map:
                     effective_char = greek_map[m_slash.group(1)]
                else:
                    # Standard word handling: find the first ASCII letter in potentially stripped word
                    m_first_letter = re.search(r'[a-zA-Z]', word_to_check)
                    if m_first_letter:
                        effective_char = m_first_letter.group(0).lower()
            # --- END REVISED effective_char Logic v3 ---


            if debug: print(f"  Word: '{word}' (CheckAs: '{word_to_check}'), Effective Char: '{effective_char}'")

            # Compare effective char with remaining abbreviation letters
            if effective_char is not None:
                best_match_abbr_idx = -1
                for abbr_idx in sorted(list(unmatched_abbr_indices), reverse=True):
                    if effective_char == abbr_letters[abbr_idx]:
                        best_match_abbr_idx = abbr_idx
                        break
                if best_match_abbr_idx != -1:
                    if debug: print(f"    -> Matched letter '{abbr_letters[best_match_abbr_idx]}' at abbr_idx {best_match_abbr_idx}")
                    match_indices[best_match_abbr_idx] = original_idx
                    unmatched_abbr_indices.remove(best_match_abbr_idx)

        # --- Post-loop checks and reconstruction ---
        successful_match_indices = [idx for idx in match_indices if idx != -1]
        if debug: print(f"  Successful match indices: {successful_match_indices}")

        if not successful_match_indices:
             if debug: print("  Skipping: No successful matches found during backward search.")
             continue

        # Validation Step
        valid_match = True
        if require_first_last_match:
            if match_indices[0] == -1 or match_indices[num_abbr_letters - 1] == -1:
                valid_match = False
                if debug: print(f"  Validation Failed: First or last letter not matched (Indices: {match_indices})")

        if valid_match:
            min_idx_py = min(successful_match_indices)
            max_idx_py = max(successful_match_indices)

            if min_idx_py <= max_idx_py:
                # Slice uses original words_ahead tokens
                full_phrase_words_slice = words_ahead[min_idx_py : max_idx_py + 1]
                # Use the join logic that handles hyphens correctly
                full_name = ''.join(word if i == 0 else (' ' + word if not full_phrase_words_slice[i - 1].endswith('-') else word)
                                    for i, word in enumerate(full_phrase_words_slice))

                if debug: print(f"  Validation Passed. Storing: '{abbr_string}': '{full_name}'")
                # Store original abbreviation string and reconstructed full name
                abbreviation_dict[abbr_string] = full_name
            elif debug: print(f"  Skipping: min_idx > max_idx issue.")
        elif debug: print(f"  Skipping: Match deemed invalid by require_first_last_match.")

    #if debug: print(f"--- Debugging End ---\nFinal Dict: {abbreviation_dict}")
    return abbreviation_dict





def get_sort_key_from_abbr(abbr_string):
    """
    Generates a lowercase string key for sorting abbreviations,
    handling common LaTeX math/greek commands via get_abbr_repr_letters.
    e.g., '$\alpha$-RM' -> 'arm', 'CPU' -> 'cpu'
    """
    # Use the existing function to get representative letters
    repr_letters = get_abbr_repr_letters(abbr_string)
    sort_key = "".join(repr_letters).lower()

    # If get_abbr_repr_letters returns empty (e.g., abbreviation has no letters/commands?)
    # provide a fallback using the original string, lowercased, maybe stripped of leading symbols.
    if not sort_key:
         # Fallback: lowercase, remove non-alphanumeric start chars for sorting robustness
         fallback_key = re.sub(r"^[^\w]+", "", abbr_string.lower())
         return fallback_key
    return sort_key

def format_abbreviations(abbreviations_dict, format_type):
    """Formats the extracted abbreviations based on the specified type.
       Sorts abbreviations alphabetically, handling LaTeX commands in keys.
       ASSUMES extracted abbr and full_name are valid LaTeX snippets
       for 'tabular' and 'nomenclature' formats. No escaping is applied.
    """
    if not abbreviations_dict:
        return "No abbreviations found."

    # --- ADD SORTING STEP HERE ---
    # Sort the dictionary items based on a generated key from the abbreviation (item[0])
    try:
        sorted_items = sorted(
            abbreviations_dict.items(),
            key=lambda item: get_sort_key_from_abbr(item[0])
        )
    except Exception as e:
        # Basic error handling for sorting, fallback to unsorted
        st.error(f"Error during abbreviation sorting: {e}. Displaying unsorted.")
        sorted_items = abbreviations_dict.items()
    # --- END SORTING STEP ---


    if format_type == "nomenclature":
        latex_output = "\\usepackage{nomencl}\n"
        latex_output += "\\makenomenclature\n"
        # Loop through the SORTED items
        for abbr, full_name in sorted_items:
            latex_output += f"\\nomenclature{{{abbr}}}{{{full_name}}}\n"
        return latex_output

    elif format_type == "tabular":
        latex_output = "\\begin{tabular}{ll}\n"
        latex_output += "\\hline\n"
        latex_output += "\\textbf{Abbreviation} & \\textbf{Full Name} \\\\\n"
        latex_output += "\\hline\n"
        # Loop through the SORTED items
        for abbr, full_name in sorted_items:
            latex_output += f"{abbr} & {full_name} \\\\\n"
        latex_output += "\\hline\n"
        latex_output += "\\end{tabular}\n"
        return latex_output

    # Default is 'plain' format
    else:
        output = ""
        # Loop through the SORTED items
        items_list = list(sorted_items) # Convert to list for index access if needed
        for i, (abbr, full_name) in enumerate(items_list):
            output += f"{abbr}: {full_name}"
            if i < len(items_list) - 1:
                 output += "; \n"
        return output
