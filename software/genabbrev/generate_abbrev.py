#!/usr/bin/env python
# coding: utf-8

# # Converting .py and .ipynb files

# # Import libraries

# In[34]:


import streamlit as st
import re
from datetime import datetime
from extract_abbrev_regex import *
import socket
import pandas as pd

hostname = socket.gethostname()
DEBUG = "streamlit" not in hostname.lower()  # Assume cloud has "streamlit" in hostname


# # normalizing and extracting abbrs

# In[90]:


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

#Here's a summary of the functions:

# normalize_dollar_spacing(text) (from artifact normalize_dollar_spacing_code)

# Purpose: This function cleans up LaTeX text strings. Specifically, it looks for the dollar signs ($) used for inline math. It removes any extra whitespace found immediately after an opening $ and immediately before a closing $. This helps standardize the formatting around inline math expressions.

# render_dataframe_with_latex(df) (from artifact render_df_latex_code)

# Purpose: This function takes a data table (specifically, a Pandas DataFrame) that contains text with LaTeX math code in its cells. It converts this table into HTML format. Importantly, it also includes the necessary setup for the MathJax library within that HTML. The result is an HTML object that, when displayed in a compatible environment (like a Jupyter notebook or a web browser), will show the table with the LaTeX code rendered as proper mathematical symbols and equations, rather than just the raw code.

# In short, one function cleans up spacing around LaTeX math delimiters in text, and the other helps display a data table containing LaTeX math correctly rendered in environments that support HTML and JavaScript.



def normalize_dollar_spacing(text):
    """
    Removes whitespace immediately following an opening inline math '$' AND
    whitespace immediately preceding a closing inline math '$'.
    Handles escaped '\$'.

    Args:
        text (str): The input string potentially containing LaTeX.

    Returns:
        str: The processed string.
    """
    processed_chars = []
    in_math_mode = False
    i = 0
    n = len(text)

    while i < n:
        char = text[i]

        # Check for escaped dollar sign or backslash first
        if char == '\\' and i + 1 < n:
            # Keep backslash and the next character (e.g., '\$' or '\\')
            processed_chars.append(char)
            processed_chars.append(text[i+1])
            i += 2 # Skip both characters
            continue

        # Check for unescaped dollar sign
        if char == '$':
            if not in_math_mode:
                # --- This is an OPENING dollar sign ---
                processed_chars.append(char) # Keep the opening dollar
                in_math_mode = True
                # Check if the next characters are whitespace and skip them
                j = i + 1
                while j < n and text[j].isspace():
                    j += 1
                # Advance 'i' past the dollar and the skipped whitespace
                i = j
                continue # Continue to next iteration
            else:
                # --- This is a CLOSING dollar sign ---
                in_math_mode = False
                # Remove any trailing whitespace added just before this closing '$'
                while processed_chars and processed_chars[-1].isspace():
                    processed_chars.pop()
                processed_chars.append(char) # Append the closing dollar
                # Advance 'i' past the dollar for the next iteration
                i += 1
                continue # Continue to next iteration
        else:
            # Any other character
            processed_chars.append(char)
            i += 1 # Advance 'i' past the character

    return "".join(processed_chars)

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
        
        
        # 0. Remove space inside $ $
        processed_text =  normalize_dollar_spacing(processed_text)

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
        # 4c. Add space BEFORE ( (handles no space before ()
        processed_text = re.sub(r'\s*\(', r' (', processed_text)
        
        # 5. Add space after specific uppercase Greek commands (\Cmd) if not followed by space
        pattern_part = '|'.join(upper_greek_cmds)
        # Using corrected pattern (no space after \\)
        pattern_upper = rf'(\\({pattern_part}))(?!\s)'
        processed_text = re.sub(pattern_upper, r'\1 ', processed_text)

        # 6. Add space after lowercase commands (\cmd) if not followed by specific pattern
        # !!! Note: This pattern (?=[A-Z][^a-z]) might be too restrictive.
        processed_text = re.sub(r'(\\[a-z]+)(?=[A-Z][^a-z])', r'\1 ', processed_text)

		# 7. Remove one or more whitespace characters (\s+) immediately after a dollar sign ($) (Moved Step)
        #processed_text = re.sub(r'\$\s+', '$', processed_text)

        # 8. Clean up potential excessive blank lines and trim overall whitespace
        processed_text = re.sub(r'(\n\s*){2,}', '\n', processed_text) # Collapse blank lines
        processed_text = re.sub(r'\s+', ' ', processed_text) # Collapse blank lines
        

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


# In[120]:


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


# # Finding Matching

# In[121]:


# Finding Matching
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


# Assume find_abbreviation_matches, get_abbr_repr_items, and get_effective_char
# are defined as previously provided.
# Assume normalize_latex_math is also available if you use it beforehand.

# --- Updated Extraction function with Threshold Validation & Reduced Debug ---


# # Extracting Abbreviations

# In[123]:


# Modified extract_abbreviations with Panda DataFrame output


def get_sort_key_from_abbr(abbr_string):
    """Generates a lowercase string key for sorting abbreviations."""
    repr_letters = get_abbr_repr_items(abbr_string)
    sort_key = "".join(repr_letters).lower()
    if not sort_key:
         fallback_key = re.sub(r"^[^\w]+", "", abbr_string.lower())
         return fallback_key
    return sort_key

def extract_abbreviations(text, match_threshold=0.7, debug=True):
    """
    Extracts abbreviations defined as (Abbr) following their definition.
    Validates match if a certain threshold of abbreviation items are matched
    to corresponding words. Also includes usage counts for matched abbreviations.

    Args:
        text (str): The input text potentially containing definitions.
        match_threshold (float): The minimum fraction (e.g., 0.7 for 70%) of
                                 abbreviation items that must be successfully
                                 matched to words for the definition to be
                                 considered valid.
        debug (bool): Flag to enable extensive debug printing.

    Returns:
        pd.DataFrame: A DataFrame containing 'abbreviation', 'full_name',
                      and 'usage_count', sorted alphabetically by abbreviation.
                      Returns an empty DataFrame if no valid abbreviations are found.
    """
    # Existing pattern and initialization
    pattern = r'((?:[\w\\\$\{\}]+[ -]+){1,10}(?:[\w\\\$\{\}]+)[ -]?)\(([^\(\)]*[a-zA-Z0-9]{2,}[^\(\)]*)\)'
    matches = re.findall(pattern, text)
    abbreviation_dict = {}
    abbr_usage_count = {}

    if debug:
        print(f"\nDebugging extract_abbreviations: Found {len(matches)} potential matches.")

    # --- Count Abbreviation Usages ---
    # Count usage for all potential abbreviations found in parentheses first
    all_potential_abbrs = [match[1].strip() for match in matches]
    for abbr in set(all_potential_abbrs): # Use set to count each unique string once
        # remove parenthesis and special characters for accurate search
        abbr_search_string = re.sub(r'[\(\)]', '', abbr)
        # Pattern to find the abbreviation as a whole word/unit
        # Uses negative lookbehind/lookahead to avoid matching parts of words or inside brackets
        abbr_usage_pattern = rf'(?<![a-zA-Z\(\)]){re.escape(abbr_search_string)}(?![a-zA-Z\)\)])' # Added spaces
        # Count occurrences (adjust pattern if needed based on how abbreviations appear)
        # Use finditer for potentially overlapping matches if required, len(findall) is usually sufficient
        abbr_usage_count[abbr] = len(re.findall(abbr_usage_pattern, text))
    if debug:
        print(f"  Abbreviation Usage Counts: {abbr_usage_count}")
    # --- END Usage Count ---


    # --- Process Matches and Build Dictionary ---
    for match in matches:
        words_before_abbr_text = match[0].strip()
        abbr_string = match[1].strip()

        # Get the pre-calculated usage count
        current_usage_count = abbr_usage_count.get(abbr_string, 0)

        # Note: Original code didn't strictly filter by usage_count >= 2 here,
        # keeping it that way unless explicitly needed. You could add:
        # if current_usage_count < 2: continue

        try: # Wrap processing for robustness
            abbr_items = get_abbr_repr_items(abbr_string)
            # Split preceding text using space/hyphen, retaining delimiters
            words_ahead = [item for item in re.split(r'([ -]+)', words_before_abbr_text) if item]

            if debug:
                print(f"\n---\nCandidate Found:")
                print(f"  Captured Abbr String: '{abbr_string}'")
                print(f"  Generated abbr_items: {abbr_items}")
                print(f"  Preceding Text for Split: '{words_before_abbr_text}'")
                print(f"  Words Ahead: {words_ahead}")

            # Initial check: Need words and abbreviation items to proceed
            if not words_ahead or not abbr_items:
                if debug:
                    print(f"  Skipping: No words ahead ({bool(words_ahead)}) or no abbr items found ({bool(abbr_items)}).")
                continue

            match_indices = find_abbreviation_matches(words_ahead, abbr_items, debug)
            successful_match_indices = [idx for idx in match_indices if idx != -1]
            count_matched = len(successful_match_indices)
            num_abbr_items = len(abbr_items)

            if debug:
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
                    print(f"  Validation Failed: Match ratio {ratio_matched:.2f} is less than threshold {match_threshold:.2f}")
            elif debug:
                print("  Validation Failed: No abbreviation items were generated.")

            # Reconstruction Logic
            if valid_match:
                if not successful_match_indices:
                    if debug:
                        print("  Skipping: Match deemed valid by ratio, but no word indices found?")
                    continue

                min_idx_py = min(successful_match_indices)
                max_idx_py = max(successful_match_indices)

                if min_idx_py <= max_idx_py < len(words_ahead): # Check max_idx_py is valid
                    full_phrase_words_slice = words_ahead[min_idx_py : max_idx_py + 1]
                    full_name = ''.join(full_phrase_words_slice)

                    if debug:
                        print(f"  Storing: '{abbr_string}': '{full_name}' (Usage: {current_usage_count})")

                    # Store in dictionary
                    abbreviation_dict[abbr_string] = {
                        'full_name': full_name,
                        'usage_count': current_usage_count # Use pre-calculated count
                    }
                else:
                     if debug:
                        print(f"  Skipping '{abbr_string}': Invalid index range {min_idx_py}-{max_idx_py} for words_ahead length {len(words_ahead)}.")


        except Exception as e_process:
            if debug:
                print(f"  ERROR processing potential match for '{abbr_string}': {e_process}")
            continue # Safely skip to the next match if an error occurs

    if debug:
        print(f"--- Debugging End ---\nFinal Dict before sorting: {abbreviation_dict}")

    # --- Handle Empty Results BEFORE Sorting ---
    if not abbreviation_dict:
        if debug:
            print("No valid abbreviations found meeting criteria. Returning empty DataFrame.")
        # Return an empty DataFrame with the expected column structure
        return pd.DataFrame(columns=['abbreviation', 'full_name', 'usage_count'])

    # --- SORTING STEP ---
    try:
        # Sort the dictionary items alphabetically based on the abbreviation key
        sorted_items = sorted(
            abbreviation_dict.items(),
            key=lambda item: get_sort_key_from_abbr(item[0]) # item[0] is the abbreviation string
        )
    except Exception as e_sort:
        if debug:
            print(f"Sorting error: {e_sort}. Proceeding with unsorted items.")
        # Fallback to unsorted list if sorting fails
        sorted_items = list(abbreviation_dict.items())
    # --- END SORTING STEP ---


    # --- Convert sorted_items list to DataFrame (Method 1) ---
    if debug:
        print(f"\nConverting {len(sorted_items)} sorted items to DataFrame.")

    data_for_df = []
    for abbr, details in sorted_items:
        row_dict = {'abbreviation': abbr} # Start row dict with the abbreviation
        row_dict.update(details)          # Add 'full_name' and 'usage_count' from details
        data_for_df.append(row_dict)

    # Create the DataFrame from the list of dictionaries
    df = pd.DataFrame(data_for_df)
    # --- END Conversion Step ---

    # Ensure columns are in the desired order (optional but good practice)
    if not df.empty:
        df = df[['abbreviation', 'full_name', 'usage_count']]

    return df

# Example Usage:
# text_example = "The Department of Defense (DoD) is important. Another mention of DoD. Federal Bureau of Investigation (FBI) is also key. Not a match (NaM)."
# df_results = extract_abbreviations(text_example, debug=True)
# print("\n--- Final DataFrame Output ---")
# print(df_results)


# # Formatting abbrs 

# In[ ]:





# In[139]:


def format_abbreviations(abbr_df, format_type="plain"):
    """Formats the extracted abbreviations DataFrame based on the specified type.
       Assumes the input DataFrame is already sorted alphabetically by 'abbreviation'.
       ASSUMES 'abbreviation' and 'full_name' columns contain valid LaTeX snippets
       for 'tabular' and 'nomenclature' formats. No escaping is applied.

    Args:
        abbr_df (pd.DataFrame): DataFrame with at least 'abbreviation' and 'full_name' columns.
                                Expected to be sorted by 'abbreviation'.
        format_type (str): The desired output format ('nomenclature', 'tabular', or other for plain text).

    Returns:
        str: A formatted string containing the abbreviations, or a message if the input DataFrame is empty.
    """
    # Check if the input DataFrame is empty
    if abbr_df.empty:
        return "No abbreviations found."

    # NOTE: Sorting is assumed to have been done *before* this function is called.

    if format_type == "nomenclature":
        # LaTeX nomenclature package format
        latex_output = "\\usepackage{nomencl}\n"
        latex_output += "\\makenomenclature\n"
        # Iterate over DataFrame rows
        for index, row in abbr_df.iterrows():
            abbr = row['abbreviation']
            full_name = row['full_name']
            latex_output += f"\\nomenclature{{{abbr}}}{{{full_name}}}\n"
        return latex_output

    elif format_type == "tabular":
        # LaTeX tabular format for a table
        latex_output = "\\begin{tabular}{ll}\n"
        latex_output += "\\hline\n"
        latex_output += "\\textbf{Abbreviation} & \\textbf{Full Name} \\\\\n"
        latex_output += "\\hline\n"
        # Iterate over DataFrame rows
        for index, row in abbr_df.iterrows():
            abbr = row['abbreviation']
            full_name = row['full_name']
            latex_output += f"{abbr} & {full_name} \\\\\n"
        latex_output += "\\hline\n"
        latex_output += "\\end{tabular}\n"
        return latex_output

    else:
        # Default format: plain list of abbreviations and full names
        output_parts = []
        # Iterate over DataFrame rows
        for index, row in abbr_df.iterrows():
            abbr = row['abbreviation']
            full_name = row['full_name']
            output_parts.append(f"{abbr}: {full_name}")

        # Join the parts with "; \n" separator
        return "; \n".join(output_parts)

# Example Usage (assuming df_results is a DataFrame from extract_abbreviations):
# df_results = pd.DataFrame({
#    'abbreviation': ['CAD', 'FBI', 'USA'],
#    'full_name': ['Canada', 'Federal Bureau of Investigation', 'United States of America'],
#    'usage_count': [1, 2, 3] # usage_count is ignored by this function
# })

# print("--- Nomenclature Format ---")
# print(format_abbreviations(df_results, "nomenclature"))
# print("\n--- Tabular Format ---")
# print(format_abbreviations(df_results, "tabular"))
# print("\n--- Plain Text Format ---")
# print(format_abbreviations(df_results, "plain")) # Any format_type other than the two specific ones
# print("\n--- Empty DataFrame Test ---")
# print(format_abbreviations(pd.DataFrame(columns=['abbreviation', 'full_name']), "tabular"))


# # Example Text and Testing

# In[129]:


# example_text
example_text = r"""Paste your latex text (LT)  and enjoy the app (ETA). There is no limitation of the length of text. 

What is regarded as abbreviations (RA):

The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time(AFT), or \textbf{Time-Constant (TC) Data}. The full definitions and abbrievations can contain greek symbols, for example,  $\alpha$-synclein protein ($\alpha$-SP), $\beta$-Z residual (BZR), $\sigma$-Z residual ($\sigma$-ZR), $\frac{\gamma}{Z}$-residuals ($\frac{\gamma}{Z}$-R). The first letters of latex commands will be used to compare against the abbreviation letters.

What is desregarded as abbreviations (DA):

Citations and explanations in brackets will be omitted, eg. this one (Li et al. 2025), and this ($\beta$). The $T$ in $f(T)$ is not an abbreviation too.   %This abbreviation, comment text (CT) or the line starting with % will be omitted. 

Note: the extraction is not perfect as it cannot accommodate all possible abbreviations and may include those you don't want. Modify the results as necessary.

The abbreviations used above include: AFT, BZR,  DA,  ETA, LT, RSP,  RA, TC, $\alpha$-SP, $\frac{\gamma}{Z}$-R, $\sigma$-ZR. We will happily use LT as we want. 
"""


# # Streamlit interface

# In[ ]:


st.set_page_config(layout="wide") # Original layout setting
st.title(r"Extracting Abbreviations from $\LaTeX$ Text") # Original title

# --- Initialize Session State ---
# Use '_df' suffix for the variable storing the DataFrame result
if 'abbreviations_df' not in st.session_state:
    st.session_state.abbreviations_df = None
if 'last_input_text' not in st.session_state:
    st.session_state.last_input_text = example_text
if 'processed_url_param' not in st.session_state:
    st.session_state.processed_url_param = False
# Removed 'first_run_done' as its logic seemed intertwined with layout issues,
# relying on button press or URL processing should be sufficient.

# --- Handle URL Query Parameter (Logic remains the same, but uses _df variable) ---
url_text_param = st.query_params.get("text", None)

if url_text_param and not st.session_state.processed_url_param:
    print(f"Processing text from URL parameter: {url_text_param[:50]}...") # Debug print
    st.session_state.last_input_text = url_text_param # Pre-fill text area state
    try:
        with st.spinner("Processing text from URL..."):
            normalized_text = normalize_latex_math(url_text_param)
            # Store the DataFrame result
            st.session_state.abbreviations_df = extract_abbreviations(normalized_text, debug=DEBUG)
            st.session_state.processed_url_param = True # Mark as processed
            # st.rerun() # Rerun might be needed depending on desired immediate update behavior
    except Exception as e:
        st.error(f"Error processing text from URL: {e}")
        st.session_state.abbreviations_df = None # Clear result on error
        st.session_state.processed_url_param = True # Mark as processed even if error
elif not url_text_param:
     st.session_state.processed_url_param = False

# --- Create two main columns for side-by-side layout (Original Ratio) ---
col_input, col_output = st.columns([3, 1]) # Original 3:1 ratio

# --- Column 1: Input Area (Original Structure) ---
with col_input:
    st.subheader("Paste Your text") # Original subheader
    input_text = st.text_area(
        label="input_text_main",
        label_visibility="collapsed", # Original setting
        value=st.session_state.last_input_text,
        height=350,  # Original height
        placeholder="Paste your text here...",
        key="input_text_area"
    )
    st.caption("Privacy: this app does not save your text.") # Original caption

    # Update session state if text changes (useful for comparison)
    if input_text != st.session_state.last_input_text:
        st.session_state.last_input_text = input_text
        # Decide if results should clear when text changes - currently they don't unless button pressed again
        # st.session_state.abbreviations_df = None

# --- Column 2: Controls and Output Display (Original Structure) ---
with col_output:
    # Original button label and settings
    extract_pressed = st.button("Extract Abbreviations with Regex", type="primary", use_container_width=True)

    # --- Processing Logic (Triggered by button press) ---
    if True:
        if input_text:
            with st.spinner("Processing..."):
                try:
                    normalized_text = normalize_latex_math(input_text)
                    # Store the DataFrame result
                    st.session_state.abbreviations_df = extract_abbreviations(normalized_text, debug=DEBUG)
                except Exception as e:
                    st.error(f"An error occurred during extraction: {e}")
                    st.session_state.abbreviations_df = None # Clear result on error
        else:
            # Original warning message
            st.warning("Please enter some text in the input box above.")
            st.session_state.abbreviations_df = None # Clear result if no input


    # --- Display Results Table ---
    output_placeholder = "Output will appear here after clicking 'Extract Abbreviations'." # Original placeholder
    df_display = st.session_state.get('abbreviations_df', None) # Safely get the DataFrame

    # Use container with original height, no border
    with st.container(height=350, border=False): # Original height, border setting
        if df_display is not None and not df_display.empty:
            # Rename columns to match original example attempt for display table
            df_display_renamed = df_display.rename(columns={
                'abbreviation': 'Abbreviation',
                'full_name': 'Full Phrase',
                'usage_count': 'Usage' 
            })
            # Select only the columns intended for display in the original code
            display_columns = ['Abbreviation', 'Full Phrase', 'Usage']
            # Generate markdown table from the DataFrame
            markdown_table = df_display_renamed[display_columns].to_markdown(index=False)
            st.markdown(markdown_table) # Display the table

        elif df_display is not None and df_display.empty: # Explicitly handle empty DataFrame
            # Use a message consistent with format_abbreviations output for empty results
            st.info("No abbreviations found in the text.")
        # else: # df_display is None (initial state or after error/clearing)
            # Original code didn't explicitly display placeholder *here*.
            # If processing hasn't happened or failed, this area will remain blank,
            # which matches the implied behavior of the original structure.
            # To show placeholder requires tracking if button was ever pressed.
            # Simpler approach: rely on Export section's output area to show status.


# --- Export Section (Original Structure) ---
# Original column setup for export controls
col_exp, _ = st.columns([1, 1])
with col_exp:
    st.subheader("Export") # Original subheader
    selected_format = st.selectbox(
        label="Choose an exportting format:", # Original label text
        label_visibility="collapsed",  # Original setting
        options=['plain', 'tabular', 'nomenclature'],
        index=0,  # Original default index (plain)
        key='format_selector', # Original key
        help="Select the format for the abbreviation list output." # Original help text
    )

    # --- Prepare and Display Formatted Output for Copying ---
    # Initialize variable for the text area value
    formatted_output = "" # Default to empty string
    df_export = st.session_state.get('abbreviations_df', None) # Safely get the DataFrame

    if df_export is not None:
        # Check if the DataFrame is empty using .empty
        if df_export.empty:
            # Use the specific message for empty results
            formatted_output = "No abbreviations found in the text."
        else:
            try:
                # Pass the DataFrame to the formatting function
                formatted_output = format_abbreviations(df_export, format_type=selected_format)
            except Exception as format_e:
                formatted_output = f"Error formatting output: {format_e}"
                st.error(formatted_output) # Show error if formatting fails
    # else: If df_export is None, formatted_output remains "" initially

    # Display the formatted output in the text area (Original settings)
    st.text_area(
        label="output_text_main", # Original internal label
        label_visibility="collapsed", # Original setting
        value=formatted_output, # Value is prepared above
        height=150,  # Original height
        help="Copy the output from this box.", # Original help text
        key="output_text_area" # Original key
    )


# --- Explanations Section (Original Structure) ---
st.divider() # Original separator
st.subheader("About the Algorithm") # Original subheader

# Define Content for Both Expanders (Keep existing text - updated slightly for accuracy)
summary_expander_label = "ⓘ How Abbreviation Extraction Works (Summary)"
summary_explanation_text = """
This tool attempts to find abbreviations defined within parentheses, like `Full Definition (Abbr)`, even in text containing LaTeX formatting. Here's the basic process:

1.  **Finding Candidates:** It scans the text using regular expressions to locate potential `Definition (Abbr)` patterns, focusing on words on the same line just before the parentheses.
2.  **Parsing Abbreviation:** It breaks down the abbreviation (e.g., `GRs`, `\\gamma R`) into core components (like `g`, `r` or `\\gamma`, `r`), ignoring plural 's' after capitals.
3.  **Matching Backwards:** It looks backward from the abbreviation's components through the preceding words/separators to find likely corresponding words (e.g., matching 'R' to 'Residuals'). It handles letters and LaTeX commands differently during matching.
4.  **Reconstructing Definition:** If a consistent match is found, it rebuilds the definition phrase, preserving original spacing and hyphens.
5.  **Validation:** A match is considered valid only if a high enough percentage (e.g., >= 70%) of the abbreviation's components were matched.
6.  **Usage Count:** It counts how many times the validly defined abbreviation appears elsewhere in the text (outside its definition).
7.  **Output:** Returns results (Abbreviation, Full Name, Count) as a DataFrame, sorted alphabetically.

*(This process uses heuristics, especially for LaTeX, so results may vary.)*
"""

detailed_expander_label = "ⓘ Detailed Algorithm Explanation"
detailed_description_text = """
This algorithm identifies abbreviations defined as `Full Definition Phrase (Abbr)` within text, including LaTeX, extracts the phrase, and counts usage.

**Core Steps:**

1.  **Optional Preprocessing (`normalize_latex_math`):** Standardizes LaTeX comments, math delimiters (`\\(...\\)` to `\$...\$`), spacing around braces/commands.
2.  **Candidate Identification (Regex):** Finds `Definition (Abbr)` patterns. Captures preceding words (Group 1, same line only) and the abbreviation (Group 2).
3.  **Usage Counting:** Counts occurrences of each *potential* abbreviation string (from Group 2) elsewhere in the text using a separate regex pattern designed to match the abbreviation as a standalone unit. Stores these counts.
4.  **Abbreviation Parsing (`get_abbr_repr_items`):** Creates a list (`abbr_items`) from the abbreviation. Keeps `\\commands` as strings, uses initial uppercase letters (ignoring trailing lowercase, e.g., `CPs` -> `c`, `p`), includes standalone lowercase.
5.  **Preceding Text Tokenization (Split):** Splits preceding words into `words_ahead` using `re.split(r'([ -]+)', ...)`, retaining spaces/hyphens as separate tokens (empty strings removed).
6.  **Backward Matching (`find_abbreviation_matches`):** Matches `abbr_items` to `words_ahead` tokens in reverse.
    * **Word Analysis (`get_effective_char`):** Derives a single effective character (first letter after heuristic LaTeX stripping) from word tokens for letter-matching.
    * **Comparison:** Matches command `abbr_items` if a word token starts with the command (allows leading `\$`). Matches letter `abbr_items` against a word token's `effective_char`. Skips separator tokens.
    * Records `match_indices` (word index for each abbr index, or -1).
7.  **Validation:** Calculates the ratio of successfully matched items (`count_matched / num_abbr_items`). Considers the definition valid if this ratio meets/exceeds a `match_threshold` (default 0.7).
8.  **Phrase Reconstruction:** If valid, finds the min/max matched word indices, slices `words_ahead` (getting words and separators), and reconstructs the `full_name` using `"".join(slice)` to preserve original spacing/hyphens.
9.  **Output Aggregation:** Stores valid `abbreviation`, reconstructed `full_name`, and pre-calculated `usage_count` in a dictionary.
10. **Final Conversion & Sorting:** Converts the final dictionary into a Pandas DataFrame and sorts it alphabetically by abbreviation before returning.
"""

# Create Columns and Display Expanders (Original column setup)
col1, col2 = st.columns(2)
with col1:
    with st.expander(summary_expander_label):
        st.markdown(summary_explanation_text)
with col2:
    with st.expander(detailed_expander_label):
        st.markdown(detailed_description_text)


# --- Footer (Original Structure) ---
st.markdown("---")
st.caption("Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada")
# Original commented out date logic
# current_date_param = st.query_params.get('current_date', 'N/A')
# st.caption(f"Current date (from URL param 'current_date', if provided): {current_date_param}")
# st.caption(f"Actual current server time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} (CST)") # Indicate CST
# st.caption("Location context: Saskatoon, SK, Canada")

