
# In[30]:


#!/usr/bin/env python
# coding: utf-8

# # Converting .py and .ipynb files

# # Import libraries

# In[30]:


# --- Imports ---
import re
import pandas as pd
import textwrap

import pandas as pd
import streamlit as st
import re
from datetime import datetime
import socket
import textwrap


hostname = socket.gethostname()
DEBUG = "streamlit" not in hostname.lower()  # Assume cloud has "streamlit" in hostname


# # Preprocessing Text with Space Inserted or Removed

# In[31]:


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

# In[30]:



# --- Helper Functions ---
# Assume get_letters_abbrs, get_letters_words, find_abbreviation_matches
# are defined as per the latest versions agreed upon.
# ... (Paste latest versions of KNOWN_COMMAND_NAMES, get_letters_abbrs, get_letters_words, find_abbreviation_matches here) ...
# Define known Greek/symbol commands whose name should be used
KNOWN_COMMAND_NAMES = {
    'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta',
    'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho',
    'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',
    'Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi', 'Sigma', 'Upsilon',
    'Phi', 'Psi', 'Omega'
}
def get_letters_abbrs(abbr_string):
    representative_items = []; original_parts = []
    for match_obj in re.finditer(r'(\\[a-zA-Z]+)|([A-Z])([a-z]+)?|([a-z])', abbr_string):
         original_part = match_obj.group(0); command = match_obj.group(1); upper = match_obj.group(2); standalone_lower = match_obj.group(4)
         current_repr_item = ''; current_orig_part = ''
         if command: current_repr_item = command[1:].lower(); current_orig_part = command
         elif upper: current_repr_item = upper.lower(); current_orig_part = original_part
         elif standalone_lower: current_repr_item = standalone_lower; current_orig_part = standalone_lower
         if current_repr_item: representative_items.append(current_repr_item); original_parts.append(current_orig_part)
    return representative_items, original_parts
def get_letters_words(word: str, debug: bool = False) -> str:
    original_word = word; word = word.strip();
    if not word: return ''
    try:
        command_match = re.match(r'\$?(\\[a-zA-Z]+)', word);
        if command_match:
            command_name = command_match.group(1)[1:]
            if command_name in KNOWN_COMMAND_NAMES: return command_name.lower()
        word_to_check = word; word_to_check = re.sub(r'^\s*\\([a-zA-Z]+)\s*\{?', '', word_to_check)
        word_to_check = word_to_check.strip(' ${}')
        if word_to_check.endswith('}'): word_to_check = word_to_check[:-1].rstrip()
        core_word_match = re.search(r'[a-zA-Z0-9]+(?:[.-]?[a-zA-Z0-9]+)*', word_to_check)
        if core_word_match: return core_word_match.group(0).lower()
        fallback_match = re.search(r'[a-zA-Z0-9]+', original_word)
        if fallback_match: return fallback_match.group(0).lower()
        return ''
    except Exception as e:
        if debug: print(f"      Error in get_letters_words for '{original_word}': {e}")
        return ''
def find_abbreviation_matches(words_ahead, abbr_string, match_threshold, debug=True):
    try: abbr_items, original_abbr_parts = get_letters_abbrs(abbr_string); num_abbr_items = len(abbr_items)
    except Exception as e_parse:
        if debug: print(f"Error parsing abbr: {e_parse}"); return None
    if not abbr_items:
        if debug: print(f"Warning: No items from '{abbr_string}'."); return None
    num_words = len(words_ahead); match_indices = [-1] * num_abbr_items; last_matched_index = num_words
    words_ahead_comparables = [get_letters_words(word, debug=False) for word in words_ahead]
    if debug: print(f"\n--- Starting find_abbreviation_matches ---\n  Input Abbr: '{abbr_string}'\n  Words Ahead ({num_words}): {words_ahead}\n  Word Comparables: {words_ahead_comparables}\n  Abbr Items ({num_abbr_items}): {abbr_items}\n  Orig Abbr Parts: {original_abbr_parts}\n  Threshold: {match_threshold}\n{'-'*20}")
    for abbr_idx in range(num_abbr_items - 1, -1, -1):
        target_comparable = abbr_items[abbr_idx]; match_found_for_abbr = False
        if not target_comparable: continue
        for word_idx in range(last_matched_index - 1, -1, -1):
            word_comparable = words_ahead_comparables[word_idx]
            if not word_comparable: continue
            current_match_found = word_comparable.startswith(target_comparable)
            if debug: print(f"  Compare WordComp[{word_idx}]('{words_ahead[word_idx]}' -> '{word_comparable}') starts with AbbrComp[{abbr_idx}]('{target_comparable}')?: Match = {current_match_found}")
            if current_match_found:
                match_indices[abbr_idx] = word_idx; last_matched_index = word_idx; match_found_for_abbr = True
                if debug: print(f"    >> Internal Match: Storing word index {word_idx} for abbr index {abbr_idx}.")
                break
    count_matched = sum(1 for idx in match_indices if idx != -1); is_valid = False; ratio_matched = 0.0
    if num_abbr_items > 0: ratio_matched = count_matched / num_abbr_items; is_valid = ratio_matched >= match_threshold
    if debug:
        print(f"{'-'*20}\n  Validation Result: Matched {count_matched}/{num_abbr_items} (Ratio: {ratio_matched:.2f}, Threshold: {match_threshold:.2f}) -> Valid: {is_valid}")
        if is_valid: print(f"  Internal match indices: {match_indices}")
        matched_abbrs_string = [''] * num_words; matched_abbrs_comparable = [''] * num_words
        for i, w_idx in enumerate(match_indices):
            if w_idx != -1 and 0 <= w_idx < num_words:
                if 0 <= i < len(abbr_items): matched_abbrs_comparable[w_idx] = abbr_items[i]
                if 0 <= i < len(original_abbr_parts): matched_abbrs_string[w_idx] = original_abbr_parts[i]
        print("\n  Final Matching Result (Debug DataFrame):")
        try:
            debug_data = {'Words Ahead': words_ahead,'Words Ahead Comparables': words_ahead_comparables,'Matched Abbrs (String)': matched_abbrs_string,'Matched Abbrs (Comparable)': matched_abbrs_comparable}
            if all(len(lst) == num_words for lst in debug_data.values()):
                df_debug = pd.DataFrame(debug_data); print(f"\n  Matching Result (Rows: Words, Comparables, MatchOrig, MatchComp):\n{textwrap.indent(df_debug.T.to_string(), '    ')}")
            else: print("\n  [DEBUG] Error: Length mismatch for debug DataFrame.")
        except Exception as e_debug: print(f"\n  [DEBUG] Error creating debug DataFrame: {e_debug}")
        print("--- Ending find_abbreviation_matches ---\n")
    return match_indices if is_valid else None

# --- REVISED extract_abbreviations ---
def extract_abbreviations(text, match_threshold=0.7, debug=False):
    """
    Extracts abbreviations. Includes revised reconstruction logic.
    Returns a DataFrame sorted by usage count (desc) then abbreviation (asc).
    """
    # (Initial pattern matching and usage counting remain the same)
    pattern = r'((?:[\w\\\$\{\}]+[ -]+){1,10}(?:[\w\\\$\{\}]+)[ -]?)\(([^\(\)]*[a-zA-Z0-9]{2,}[^\(\)]*)\)'
    matches = re.findall(pattern, text)
    abbreviation_dict = {}
    abbr_usage_count = {}
    if debug: print(f"\nDebugging extract_abbreviations: Found {len(matches)} potential candidates.")
    all_potential_abbrs = [match[1].strip() for match in matches]
    for abbr in set(all_potential_abbrs):
        abbr_search_string = re.sub(r'[\(\)]', '', abbr); abbr_usage_pattern = rf'\b{re.escape(abbr_search_string)}\b'
        try: abbr_usage_count[abbr] = len(re.findall(abbr_usage_pattern, text))
        except re.error as re_err:
             if debug: print(f"  Regex error counting usage for '{abbr}': {re_err}"); abbr_usage_count[abbr] = 0
    if debug: print(f"  Initial Abbreviation Usage Counts: {abbr_usage_count}")

    # --- Process Matches ---
    for match_idx, match in enumerate(matches):
        words_before_abbr_text = match[0].strip(); abbr_string = match[1].strip()
        current_usage_count = abbr_usage_count.get(abbr_string, 0)
        if debug: print(f"\n--- Candidate {match_idx+1}: Abbr='{abbr_string}', Before='{words_before_abbr_text}' ---")

        split_pattern = r'([ -]+)'; split_list = re.split(split_pattern, words_before_abbr_text); words_ahead = [item for item in split_list if item]
        if not words_ahead:
             if debug: print("  Skipping: No words found before abbreviation."); continue

        # Call find_abbreviation_matches (which performs validation internally)
        match_indices_result = find_abbreviation_matches(words_ahead, abbr_string, match_threshold, debug=debug)

        # Check if the result indicates a valid match (is not None)
        if match_indices_result is not None:
            # Get indices of words that successfully matched an abbr item
            successful_match_indices = [idx for idx in match_indices_result if idx != -1]

            if not successful_match_indices:
                if debug: print("  Skipping: Match valid, but no successful indices found (Error?)."); continue

            # --- REVISED RECONSTRUCTION ---
            # Find the index of the FIRST matched word
            min_idx_py = min(successful_match_indices)

            # Slice from the first matched word to the END of words_ahead
            if 0 <= min_idx_py < len(words_ahead):
                full_phrase_words_slice = words_ahead[min_idx_py:] # Slice from min_idx_py to the end
                full_name = ''.join(full_phrase_words_slice).strip() # Join and strip potential trailing space

                # Store valid result
                if debug:
                     print(f"  VALID MATCH FOUND by find_abbreviation_matches: Storing '{abbr_string}' -> '{full_name}' (Usage: {current_usage_count})")

                abbreviation_dict[abbr_string] = {
                    'full_name': full_name,
                    'usage_count': current_usage_count
                }
            else:
                 # This might happen if min_idx_py is somehow invalid
                 if debug: print(f"  Skipping: Invalid index derived [{min_idx_py}:] for reconstruction (words_ahead len {len(words_ahead)}).")
            # --- END REVISED RECONSTRUCTION ---
        elif debug:
             # Match was deemed invalid by find_abbreviation_matches
             print(f"  Match for '{abbr_string}' deemed invalid by find_abbreviation_matches.")
    # --- End Main Loop Over Matches ---


    # --- Final DataFrame Creation and Sorting (No change needed here) ---
    # ... (Code remains the same as previous version) ...
    if not abbreviation_dict:
        if debug: print("\nNo valid abbreviations extracted meeting criteria.")
        return pd.DataFrame(columns=['Row No.', 'abbreviation', 'full_name', 'usage_count'])
    if debug: print(f"\nCreating final DataFrame from {len(abbreviation_dict)} valid abbreviations.")
    try:
        final_df = pd.DataFrame.from_dict(abbreviation_dict, orient='index')
        final_df = final_df.reset_index().rename(columns={'index': 'abbreviation'})
        final_df = final_df.sort_values(by=['usage_count', 'abbreviation'], ascending=[False, True], ignore_index=True)
        final_df.insert(0, 'Row No.', final_df.index + 1)
        final_df = final_df[['Row No.', 'abbreviation', 'full_name', 'usage_count']]
    except Exception as e_df:
        if debug: print(f"Error creating or sorting final DataFrame: {e_df}")
        return pd.DataFrame(columns=['Row No.', 'abbreviation', 'full_name', 'usage_count'])
    return final_df


def get_sort_key_from_abbr(abbr_string):
    """Generates a lowercase string key for sorting abbreviations."""
    repr_letters = get_abbr_repr_items(abbr_string)
    sort_key = "".join(repr_letters).lower()
    if not sort_key:
         fallback_key = re.sub(r"^[^\w]+", "", abbr_string.lower())
         return fallback_key
    return sort_key

# In[30]:



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

# ## example_text

# In[36]:


example_text = r"""Paste your latex text (LT)  and enjoy the app (ETA). There is no limitation of the length of text. 

What is regarded as abbreviations (RA):

The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time(AFT), or \textbf{Time-Constant (TC) Data}. The full definitions and abbrievations can contain greek symbols, for example,  $\alpha$-synclein protein ($\alpha$-SP), $\beta$-Z residual (BZR), $\sigma$-Z residual ($\sigma$-ZR), $\frac{\gamma}{Z}$-residuals ($\frac{\gamma}{Z}$-R). The first letters of latex commands will be used to compare against the abbreviation letters.

What is desregarded as abbreviations (DA):

Citations and explanations in brackets will be omitted, eg. this one (Li et al. 2025), and this ($\beta$). The $T$ in $f(T)$ is not an abbreviation too.   %This abbreviation, comment text (CT) or the line starting with % will be omitted. 

The abbreviations used above include: AFT, BZR,  DA,  ETA, LT, RSP,  RA, TC, $\alpha$-SP, $\frac{\gamma}{Z}$-R, $\sigma$-ZR.  

Note: the extraction is not perfect as it cannot accommodate all possible abbreviations and may include those you don't want. Modify the results as necessary.

"""



# ## Testing

# # Streamlit Interface

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
            # Consider uncommenting rerun if updates aren't immediate enough
            # st.rerun()
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
        # Optional: Clear results when text changes?
        # st.session_state.abbreviations_df = None

# --- Column 2: Controls and Output Display (Original Structure) ---
with col_output:
    # Original button label and settings
    extract_pressed = st.button("Extract Abbreviations with Regex", type="primary", use_container_width=True)

    # --- Processing Logic (Triggered by button press) ---
    # Corrected: Process only when button is pressed
    if extract_pressed:
        if input_text:
            with st.spinner("Processing..."):
                try:
                    normalized_text = normalize_latex_math(input_text)
                    # Store the DataFrame result (which includes 'Row No.')
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
            # --- MODIFICATION STARTS HERE ---
            # Rename columns including the new 'Row No.' for display
            df_display_renamed = df_display.rename(columns={
                'Row No.': 'No.', # Rename for display
                'abbreviation': 'Abbreviation',
                'full_name': 'Full Phrase',
                'usage_count': 'Usage'
            })
            # Select columns to display, including the new 'No.' column first
            display_columns = ['No.', 'Abbreviation', 'Full Phrase', 'Usage']
            # --- END MODIFICATION ---

            # Generate markdown table from the selected & renamed columns
            # index=False prevents pandas default index from showing (we use our 'No.' column)
            markdown_table = df_display_renamed[display_columns].to_markdown(index=False)
            st.markdown(markdown_table) # Display the table

        elif df_display is not None and df_display.empty: # Explicitly handle empty DataFrame
            # Use a message consistent with format_abbreviations output for empty results
            st.info("No abbreviations found in the text.")
        # else: Display nothing or placeholder if df_display is None


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
    formatted_output = "" # Default to empty string
    df_export = st.session_state.get('abbreviations_df', None) # Safely get the DataFrame

    if df_export is not None:
        if df_export.empty:
            formatted_output = "No abbreviations found in the text."
        else:
            try:
                # Pass the DataFrame (which might include 'Row No.') to the formatting function
                # The format_abbreviations function should ideally ignore the 'Row No.' column if present
                formatted_output = format_abbreviations(df_export, format_type=selected_format)
            except Exception as format_e:
                formatted_output = f"Error formatting output: {format_e}"
                st.error(formatted_output) # Show error if formatting fails
    # else: If df_export is None, formatted_output remains "" initially, or update message:
    elif extract_pressed or url_text_param: # Only show if an attempt was made
         formatted_output = "Extract abbreviations first or check input/errors."


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
7.  **Output:** Returns results (Abbreviation, Full Name, Count) as a DataFrame, sorted by count then abbreviation, including a row number.

*(This process uses heuristics, especially for LaTeX, so results may vary.)*
"""

detailed_expander_label = "ⓘ Detailed Algorithm Explanation"
detailed_description_text = """
This algorithm identifies abbreviations defined as `Full Definition Phrase (Abbr)` within text, including LaTeX, extracts the phrase, and counts usage.

**Core Steps:**

1.  **Optional Preprocessing (`normalize_latex_math`):** Standardizes LaTeX comments, math delimiters (`\\(...\\)` to `\$...\$`), spacing around braces/commands.
2.  **Candidate Identification (Regex):** Finds `Definition (Abbr)` patterns. Captures preceding words (Group 1, same line only) and the abbreviation (Group 2).
3.  **Usage Counting:** Counts occurrences of each *potential* abbreviation string (from Group 2) elsewhere in the text using a separate regex pattern designed to match the abbreviation as a standalone unit. Stores these counts.
4.  **Abbreviation Parsing (`get_letters_abbrs`):** Creates two lists from the abbreviation: one with single comparable letters, one with the original segments.
5.  **Preceding Text Tokenization (Split):** Splits preceding words into `words_ahead` using `re.split(r'([ -]+)', ...)`, retaining spaces/hyphens as separate tokens.
6.  **Word Analysis (`get_letters_words`):** Pre-calculates a list (`words_ahead_letters`) containing the single comparable letter for each token in `words_ahead`.
7.  **Backward Matching (`find_abbreviation_matches`):** Matches `abbr_items` (letters) to `words_ahead_letters` tokens in reverse, respecting sequence and using state (`last_matched_index`) to constrain search. Returns two lists mapping word index to the matched original abbreviation part (`matched_abbrs_string`) and the matched abbreviation letter (`matched_abbrs_letters`).
8.  **Validation:** Calculates the ratio of successfully matched items (`sum(1 for letter in matched_abbrs_letters if letter) / len(abbr_items)`). Considers the definition valid if this ratio meets/exceeds `match_threshold`.
9.  **Phrase Reconstruction:** If valid, finds the min/max indices of matched words (from non-empty entries in `matched_abbrs_letters`), slices `words_ahead`, and reconstructs `full_name`.
10. **Output Aggregation:** Stores valid `abbr_string` (original abbreviation), reconstructed `full_name`, and pre-calculated `usage_count` in a dictionary.
11. **Final DataFrame Creation & Sorting:** Converts the final dictionary into a Pandas DataFrame, sorts it by usage count (desc) then abbreviation (asc), adds a 1-based 'Row No.' column, and returns it.
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

    