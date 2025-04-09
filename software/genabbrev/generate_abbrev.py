#!/usr/bin/env python
# coding: utf-8

# # Converting .py and .ipynb files

# # Import libraries

# In[14]:


import pandas as pd
import streamlit as st
import re
from datetime import datetime
import socket
import textwrap


hostname = socket.gethostname()
DEBUG = "streamlit" not in hostname.lower()  # Assume cloud has "streamlit" in hostname


# # Preprocessing Text with Space Inserted or Removed

# In[15]:


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


# # Finding Matching

# In[16]:


# --- Imports ---
import re
import pandas as pd
import textwrap

# --- Helper Functions ---
# Assume KNOWN_COMMAND_NAMES, get_letters_abbrs, get_letters_words are defined as needed

KNOWN_COMMAND_NAMES = {
    'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta',
    'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho',
    'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',
    'Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi', 'Sigma', 'Upsilon',
    'Phi', 'Psi', 'Omega'
}
def get_letters_abbrs(abbr_string):
    # ... (implementation returning letters/cmd_names and originals) ...
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
    # ... (implementation returning lowercase word/cmd_name) ...
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
        # if debug: print(f"      Error in get_letters_words for '{original_word}': {e}") # Keep minimal
        return ''


# --- REVISED find_abbreviation_matches ---
def find_abbreviation_matches(words_ahead, abbr_string, debug=True): # Removed match_threshold
    """
    Performs backward matching using startswith comparison logic.
    Calculates and returns the match results and the ratio of matched items.
    If debug=True, prints debug information including a final DataFrame.

    Args:
        words_ahead (list): Word tokens from the definition part.
        abbr_string (str): The original abbreviation string.
        debug (bool): Flag to enable console debug printing.

    Returns:
        tuple: (match_indices, match_ratio)
               - match_indices: list mapping abbr_idx -> word_idx (-1 if no match).
               - match_ratio: float representing fraction of matched abbr items (0.0 to 1.0).
               Returns ([], 0.0) if abbreviation parsing fails or yields no items.
    """
    # --- Internal Calculation ---
    try:
        abbr_items, original_abbr_parts = get_letters_abbrs(abbr_string)
        num_abbr_items = len(abbr_items)
        # Handle case where abbr_string yields no parsable items
        if not abbr_items:
             if debug: print(f"Warning: Abbr string '{abbr_string}' yielded no items.")
             # Return empty list and 0.0 ratio
             return [], 0.0
    except Exception as e_parse:
         if debug: print(f"Error parsing abbr string '{abbr_string}': {e_parse}.")
         # Return empty list and 0.0 ratio on error
         return [], 0.0

    num_words = len(words_ahead)
    match_indices = [-1] * num_abbr_items # Initialize results
    last_matched_index = num_words
    words_ahead_comparables = [get_letters_words(word, debug=False) for word in words_ahead]

    if debug:
        print("\n--- Starting find_abbreviation_matches ---")
        print(f"  Input Abbr String: '{abbr_string}'")
        print(f"  Words Ahead ({num_words}): {words_ahead}")
        print(f"  Words Ahead Comparables ({len(words_ahead_comparables)}): {words_ahead_comparables}")
        print(f"  Abbr Items (Letter/CmdName) ({num_abbr_items}): {abbr_items}")
        print(f"  Original Abbr Parts ({len(original_abbr_parts)}): {original_abbr_parts}")
        # Removed Threshold printout
        print("-" * 20)

    # --- Matching Loop ---
    # (Loop logic remains the same as previous version, populates match_indices)
    for abbr_idx in range(num_abbr_items - 1, -1, -1):
        target_comparable = abbr_items[abbr_idx]; match_found_for_abbr = False
        if not target_comparable: continue
        for word_idx in range(last_matched_index - 1, -1, -1):
            word_comparable = words_ahead_comparables[word_idx]
            if not word_comparable: continue
            current_match_found = word_comparable.startswith(target_comparable)
            if current_match_found:
                match_indices[abbr_idx] = word_idx; last_matched_index = word_idx; match_found_for_abbr = True
                # Removed internal match printout
                break
        # Removed 'no match found' printout
    # --- END Matching Loop ---

    # --- Calculate Match Ratio ---
    count_matched = sum(1 for word_idx in match_indices if word_idx != -1)
    match_ratio = count_matched / num_abbr_items if num_abbr_items > 0 else 0.0
    # --- END Calculate Match Ratio ---


    # --- Debugging Output Section ---
    if debug:
        print("-" * 20)
        # Print the calculated results, not validation status
        print(f"  Matching Complete: Matched {count_matched}/{num_abbr_items} items.")
        print(f"  Match Ratio: {match_ratio:.2f}")
        print(f"  Final match indices (abbr_idx -> word_idx): {match_indices}")

        # Keep calculation and printing of the final debug DataFrame
        matched_abbrs_string = [''] * num_words; matched_abbrs_comparable = [''] * num_words
        for abbr_idx_debug, word_idx_debug in enumerate(match_indices):
             if word_idx_debug != -1:
                  if 0 <= word_idx_debug < num_words:
                      if 0 <= abbr_idx_debug < len(abbr_items): matched_abbrs_comparable[word_idx_debug] = abbr_items[abbr_idx_debug]
                      if 0 <= abbr_idx_debug < len(original_abbr_parts): matched_abbrs_string[word_idx_debug] = original_abbr_parts[abbr_idx_debug]
        print("\n  Final Matching Result (Debug DataFrame):")
        try:
            debug_data = {'Words Ahead': words_ahead,'Words Ahead Comparables': words_ahead_comparables,'Matched Abbrs (String)': matched_abbrs_string,'Matched Abbrs (Comparable)': matched_abbrs_comparable}
            list_len = len(words_ahead)
            if not all(len(lst) == list_len for lst in [words_ahead_comparables, matched_abbrs_string, matched_abbrs_comparable]): print("\n  [DEBUG] Error: Length mismatch for debug DataFrame.")
            else:
                df_debug = pd.DataFrame(debug_data); print(f"\n  Matching Result (Rows: Words, Comparables, Matched String, Matched Comparable):\n{textwrap.indent(df_debug.T.to_string(), '    ')}")
        except Exception as e_debug: print(f"\n  [DEBUG] Error creating debug DataFrame: {e_debug}")
        print("--- Ending find_abbreviation_matches ---\n")
    # --- END Debugging Output Section ---

    # --- Return the results ---
    return match_indices, match_ratio # Return tuple
    # --- End Return ---


# # Extracting Abbreviations

# In[ ]:


def extract_abbreviations(text, match_threshold=0.7, debug=False):
    """
    Extracts abbreviations. Calls find_abbreviation_matches to get results
    and match ratio, then performs validation using the ratio.
    Returns a DataFrame sorted by usage count (desc) then abbreviation (asc).
    """
    pattern = r'((?:[\w\\\$\{\}]+[ -]+){1,10}(?:[\w\\\$\{\}]+)[ -]?)\(([^\(\)]*[a-zA-Z0-9]{2,}[^\(\)]*)\)'
    matches = re.findall(pattern, text)
    abbreviation_dict = {}
    abbr_usage_count = {}
    if debug: print(f"\nDebugging extract_abbreviations: Found {len(matches)} potential candidates.")
    all_potential_abbrs = [match[1].strip() for match in matches]
    for abbr in set(all_potential_abbrs):
        abbr_search_string = re.sub(r'[\(\)]', '', abbr)
        # Using lookaround pattern for usage count
        abbr_usage_pattern = rf'(?<![a-zA-Z\(\)]){re.escape(abbr_search_string)}(?![a-zA-Z\)\)])'
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

        # --- CORRECTED CALL and UNPACKING ---
        # Call find_abbreviation_matches WITHOUT match_threshold
        match_indices_result, ratio_result = find_abbreviation_matches(
            words_ahead,
            abbr_string,
            debug=debug # Pass debug flag down
        )
        # --- END CORRECTION ---

        # --- Validation (Performed here using returned ratio) ---
        is_valid = (ratio_result >= match_threshold)
        # --- END Validation ---

        if debug: # Print outcome of validation performed here
            print(f"  Validation (in extract_abbreviations): Ratio={ratio_result:.2f}, Threshold={match_threshold:.2f} -> Valid: {is_valid}")

        # Check if the match is valid based on the ratio
        if is_valid:
            # Reconstruct Full Name using the returned match_indices
            # match_indices_result cannot be None based on find_abbreviation_matches logic,
            # it returns [] if parsing fails, resulting in ratio 0.
            successful_match_indices = [idx for idx in match_indices_result if idx != -1]

            # We must have successful matches if is_valid is True and threshold > 0
            if not successful_match_indices:
                if debug: print("  Skipping: Match deemed valid, but no successful indices found (Logic Error?)."); continue

            min_idx_py = min(successful_match_indices)

            # Slice from the first matched word to the END of words_ahead
            if 0 <= min_idx_py < len(words_ahead):
                full_phrase_words_slice = words_ahead[min_idx_py:]
                full_name = ''.join(full_phrase_words_slice).strip()

                # Store valid result
                if debug:
                     print(f"  VALID MATCH CONFIRMED: Storing '{abbr_string}' -> '{full_name}' (Usage: {current_usage_count})")

                abbreviation_dict[abbr_string] = {
                    'full_name': full_name,
                    'usage_count': current_usage_count
                }
            else:
                 if debug: print(f"  Skipping: Invalid index derived [{min_idx_py}:] for reconstruction.")
        elif debug:
             # Match was invalid based on the ratio
             print(f"  Match for '{abbr_string}' deemed invalid based on ratio.")
    # --- End Main Loop ---


    # --- Final DataFrame Creation and Sorting ---
    # (Remains the same)
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


# ## collect_abbreviations

# In[21]:


def collect_abbreviations(text, debug=False):
    """
    Finds all potential abbreviation candidates Def (Abbr), calculates usage,
    calls find_abbreviation_matches to get matching details (indices and ratio),
    and reconstructs potential full name.
    Does NOT filter based on match ratio or usage count.

    Args:
        text (str): The input text (ideally normalized).
        debug (bool): Flag to enable detailed debug printing in this function
                      and called functions.

    Returns:
        pd.DataFrame: DataFrame containing all candidates with columns:
                      'abbreviation', 'full_name', 'usage_count', 'perc_abbr_matches'.
                      Returns empty DataFrame if no candidates found.
    """
    # Initial pattern find candidates
    pattern = r'((?:[\w\\\$\{\}]+[ -]+){1,10}(?:[\w\\\$\{\}]+)[ -]?)\(([^\(\)]*[a-zA-Z0-9]{2,}[^\(\)]*)\)'
    matches = re.findall(pattern, text)

    required_columns = ['abbreviation', 'full_name', 'usage_count', 'perc_abbr_matches']
    empty_df = pd.DataFrame(columns=required_columns)

    if not matches:
        if debug: print("collect_abbreviations: No potential candidates found by initial regex.")
        return empty_df

    if debug: print(f"collect_abbreviations: Found {len(matches)} potential candidates.")

    # Calculate usage counts first
    abbr_usage_count = {}
    all_potential_abbrs = [match[1].strip() for match in matches]
    for abbr in set(all_potential_abbrs):
        abbr_search_string = re.sub(r'[\(\)]', '', abbr)
        # Using lookaround pattern
        abbr_usage_pattern = rf'(?<![a-zA-Z\(\)]){re.escape(abbr_search_string)}(?![a-zA-Z\)\)])'
        try: abbr_usage_count[abbr] = len(re.findall(abbr_usage_pattern, text))
        except re.error as re_err:
            if debug: print(f"  Regex error counting usage for '{abbr}': {re_err}"); abbr_usage_count[abbr] = 0
    if debug: print(f"  Usage Counts Calculated: {len(abbr_usage_count)} unique abbreviations.")

    # Collect data for ALL candidates
    all_candidate_data = []
    for match_idx, match in enumerate(matches):
        words_before_abbr_text = match[0].strip()
        abbr_string = match[1].strip()
        current_usage_count = abbr_usage_count.get(abbr_string, 0) # Get pre-calculated count

        if debug: print(f"\n--- Collecting Candidate {match_idx+1}: Abbr='{abbr_string}' ---")

        split_pattern = r'([ -]+)'; split_list = re.split(split_pattern, words_before_abbr_text); words_ahead = [item for item in split_list if item]

        full_name = "" # Default empty name
        match_ratio = 0.0 # Default ratio
        match_indices = [] # Default empty list

        if words_ahead:
            # Call find_abbreviation_matches to get indices and ratio
            # Pass debug flag down
            match_indices, ratio_result = find_abbreviation_matches(
                words_ahead,
                abbr_string,
                debug=debug
            )
            match_ratio = ratio_result # Store the calculated ratio

            # Reconstruct name based on match_indices (even if ratio is low)
            if match_indices: # Check if list is not empty
                successful_match_indices = [idx for idx in match_indices if idx != -1]
                if successful_match_indices:
                    min_idx_py = min(successful_match_indices)
                    # Slice from first matched word to end, as requested previously
                    if 0 <= min_idx_py < len(words_ahead):
                        full_phrase_words_slice = words_ahead[min_idx_py:]
                        full_name = ''.join(full_phrase_words_slice).strip()
                    elif debug: print(f"  Warning: Invalid min_idx {min_idx_py} for reconstruction.")
                # Optional: Log if match_indices had no successful matches?
                # elif debug: print("  Note: No successful match indices found for reconstruction.")
            # Optional: Log if find_abbreviation_matches returned empty list?
            # elif debug: print("  Note: find_abbreviation_matches returned empty list.")
        elif debug: print("  Note: No words found before abbreviation for reconstruction.")

        # Append data for this candidate regardless of match success/ratio
        all_candidate_data.append({
            'abbreviation': abbr_string,
            'full_name': full_name,
            'usage_count': current_usage_count,
            'perc_abbr_matches': match_ratio # Store the match ratio/percentage
        })
        if debug: print(f"  Collected Candidate {match_idx+1}: Ratio={match_ratio:.2f}, Usage={current_usage_count}, Name='{full_name}'")

    # Create the final DataFrame from all collected data
    if not all_candidate_data:
        return empty_df # Return empty DF with correct columns
    else:
        collected_df = pd.DataFrame(all_candidate_data)
        # Ensure columns are in desired order before returning
        return collected_df[required_columns]


# ## select_abbreviations

# In[22]:


# REVISED: Only filters, does not sort or modify columns (beyond filtering rows)
def select_abbreviations(collected_df, threshold_perc_abbr_matches=0.7, threshold_usage=0, debug=False):
    """
    Filters a DataFrame of abbreviation candidates based on criteria.
    DOES NOT SORT or add/remove display columns like 'Row No.'.

    Args:
        collected_df (pd.DataFrame): DataFrame from collect_abbreviations.
        threshold_perc_abbr_matches (float): Min match ratio required (0.0 to 1.0).
        threshold_usage (int): Min usage count required (>= threshold_usage).
        debug(bool): Enable printing status messages.

    Returns:
        pd.DataFrame: Filtered DataFrame with original columns from collect_abbreviations.
                      Returns empty DataFrame if none meet criteria or input invalid.
    """
    # Define expected columns from input
    required_cols = ['abbreviation', 'full_name', 'usage_count', 'perc_abbr_matches']
    empty_df = pd.DataFrame(columns=required_cols) # Return structure if empty

    if not isinstance(collected_df, pd.DataFrame) or collected_df.empty:
        if debug: print("select_abbreviations: Input DataFrame empty/invalid.")
        return empty_df

    if not all(col in collected_df.columns for col in required_cols):
         if debug: print(f"select_abbreviations: Input missing required columns. Expected: {required_cols}")
         return empty_df # Cannot filter without required columns

    if debug: print(f"\n--- Starting select_abbreviations (Filtering Only) ---\n  Input DF rows: {len(collected_df)}\n  Filters: Ratio >= {threshold_perc_abbr_matches}, Usage >= {threshold_usage}")

    # 1. Apply Filters
    filtered_df = collected_df[
        (collected_df['perc_abbr_matches'] >= threshold_perc_abbr_matches) &
        (collected_df['usage_count'] >= threshold_usage)
    ].copy() # Use .copy() to avoid potential SettingWithCopyWarning

    if filtered_df.empty:
        if debug: print(f"  Filtering Result: No abbreviations met criteria.")
        # Return empty DF matching expected columns
        return empty_df

    if debug: print(f"  Filtering Result: {len(filtered_df)} passed criteria.\n--- Ending select_abbreviations ---")

    # 2. Return the filtered DataFrame (unsorted by this function)
    return filtered_df


# # Formatting abbrs 

# In[18]:


def format_abbreviations(abbr_df, format_type):
     cols_to_drop = [col for col in ['Row No.', 'perc_abbr_matches'] if col in abbr_df.columns]
     df_to_format = abbr_df.drop(columns=cols_to_drop)
     if df_to_format.empty: return "No abbreviations selected."
     if format_type == "tabular": latex_output = "\\begin{tabular}{ll}\n\\hline\n\\textbf{Abb} & \\textbf{Full Name} \\\\\n\\hline\n"; # Shortened header
     elif format_type == "nomenclature": latex_output = "\\usepackage{nomencl}\n\\makenomenclature\n";
     else: output_parts = []
     for _, row in df_to_format.iterrows():
          if format_type == "tabular": latex_output += f"{row['abbreviation']} & {row['full_name']} \\\\\n"
          elif format_type == "nomenclature": latex_output += f"\\nomenclature{{{row['abbreviation']}}}{{{row['full_name']}}}\n"
          else: output_parts.append(f"{row['abbreviation']}: {row['full_name']}")
     if format_type == "tabular": latex_output += "\\hline\n\\end{tabular}\n"; return latex_output
     elif format_type == "nomenclature": return latex_output
     else: return "; \n".join(output_parts)

    


# # Example Text and Testing

# ## example_text

# In[30]:


example_text = r"""Paste your latex text (LT)  and enjoy the app (ETA). There is no limitation of the length of text. 

What is regarded as abbreviations (RA):

The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time(AFT), or \textbf{Time-Constant (TC) Data}. The full definitions and abbrievations can contain greek symbols, for example,  $\alpha$ Predictive p-value (aPP), $\alpha$-synclein protein ($\alpha$-SP), $\beta$-Z residual (BZR), $\sigma$-Z residual ($\sigma$-ZR), $\frac{\gamma}{Z}$-residuals ($\frac{\gamma}{Z}$-R). The first letters of latex commands will be used to compare against the abbreviation letters.

What is desregarded as abbreviations (DA):

Citations and explanations in brackets will be omitted, eg. this one (Li et al. 2025), and this ($\beta$). The $T$ in $f(T)$ is not an abbreviation too.   %This abbreviation, comment text (CT) or the line starting with % will be omitted. 

Note: the extraction is not perfect as it cannot accommodate all possible abbreviations and may include those you don't want. Modify the results as necessary.

The abbreviations used above include: AFT, BZR,  DA,  ETA, LT, RSP,  RA, TC, $\alpha$-SP, $\frac{\gamma}{Z}$-R, $\sigma$-ZR. We will happily use LT as we want. 
"""



# ## Testing

# # Streamlit Interface

# In[ ]:


# --- Streamlit App Code ---
# Assumes 'example_text', 'DEBUG', and all necessary functions/imports
# (normalize_*, get_*, find_*, collect_*, select_*, format_*) are defined above.

st.set_page_config(layout="wide")
st.title(r"Extracting Abbreviations from $\LaTeX$ Text")

# --- Initialize Session State (Essential for UI statefulness) ---
if 'collected_df' not in st.session_state: st.session_state.collected_df = None
if 'last_input_text_processed' not in st.session_state: st.session_state.last_input_text_processed = None
# Initialize 'last_input_text' using the globally defined example_text
if 'last_input_text' not in st.session_state:
    try:
        st.session_state.last_input_text = example_text # Initialize with the variable
    except NameError: # Fallback if example_text wasn't defined above
        st.session_state.last_input_text = ""
        st.warning("`example_text` variable not found. Using empty default for input.")

# Check if DEBUG is defined, default to False if not
try:
    _ = DEBUG
except NameError:
    DEBUG = False # Default if not defined above

# --- UI Layout (Top to Bottom) ---

# 1. Input Area
st.subheader("Paste Your Text")
input_text = st.text_area(
    label="input_text_main",
    label_visibility="collapsed",
    value=st.session_state.last_input_text, # Reads initial value correctly
    height=250,
    placeholder="Paste your text here...",
    key="input_text_area"
)
st.caption("Privacy: this app does not save your text.")
process_button = st.button("Process Text and Collect Abbreviations", type="primary")

# 2. Processing Logic (Run Collection)
collection_needed = False
# Trigger collection if button pressed OR if text area differs from last processed text
if process_button:
    collection_needed = True
    st.session_state.last_input_text = input_text # Store button-pressed text
elif input_text != st.session_state.get('last_input_text_processed', None):
    collection_needed = True
    # Don't necessarily update last_input_text state here, process current input_text below

if collection_needed and input_text:
    with st.spinner("Collecting potential abbreviations..."):
        try:
            # Assumes normalize_latex_math & collect_abbreviations are defined
            normalized_text = normalize_latex_math(input_text)
            st.session_state.collected_df = collect_abbreviations(normalized_text, debug=DEBUG)
            st.session_state.last_input_text_processed = input_text # Mark processed text
            # Optionally clear previous selection/sort state if needed
            st.info(f"Collected {len(st.session_state.collected_df) if st.session_state.collected_df is not None else 0} potential candidates. Adjust filters below.")
        except NameError as e:
            st.error(f"A required function or variable is missing: {e}")
            st.session_state.collected_df = None
            st.session_state.last_input_text_processed = input_text # Mark attempt
        except Exception as e:
            st.error(f"An error occurred during collection: {e}")
            st.session_state.collected_df = None
            st.session_state.last_input_text_processed = input_text # Mark attempt
elif collection_needed and not input_text:
    st.warning("Please enter some text to process.")
    st.session_state.collected_df = None
    st.session_state.last_input_text_processed = None

# 3. Filtering and Sorting Controls
st.divider()
st.subheader("Filter and Sort Abbreviations")
# Default to empty DF with expected columns if collection hasn't run or failed
collected_data_columns = ['abbreviation', 'full_name', 'usage_count', 'perc_abbr_matches']
collected_data = st.session_state.get('collected_df', pd.DataFrame(columns=collected_data_columns))

col_f1, col_f2, col_s1, _ = st.columns([0.5,1,1,5]) # Use 3 columns for filters and sort

with col_f1:
    usage_threshold = st.number_input(
        label="Min Usage:", min_value=0, max_value=10, value=0, step=1, key="usage_filter"
    )
with col_f2:
    perc_options = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    default_perc_index = perc_options.index(0.7) if 0.7 in perc_options else 6
    perc_match_threshold = st.selectbox(
        label="Min Match %:", options=perc_options, index=default_perc_index, key="perc_match_filter", format_func=lambda x: f"{x*100:.0f}%"
    )
with col_s1:
    sort_options = ['Abbreviation', 'Full Phrase', 'Match %', 'Usage']
    sort_column_map = {'Abbreviation':'abbreviation', 'Full Phrase':'full_name', 'Usage':'usage_count', 'Match %':'perc_abbr_matches'}
    sort_by_display = st.selectbox(
        "Sort by:", options=sort_options, index=0, key="sort_selector" # Default sort by Abbreviation
    )

# 4. Apply Selection (Filtering - using select_abbreviations function)
filtered_dataframe = pd.DataFrame(columns=collected_data_columns) # Default empty
try:
    # Assumes select_abbreviations function is defined
    # Make sure collected_data is a DataFrame before passing
    if isinstance(collected_data, pd.DataFrame):
         filtered_dataframe = select_abbreviations(
            collected_data,
            threshold_perc_abbr_matches=perc_match_threshold,
            threshold_usage=usage_threshold,
            debug=DEBUG
        )
    elif collected_data is not None : # If it's not None but not a DF (shouldn't happen)
         st.error("Internal Error: Collected data is not a DataFrame.")

except NameError as e:
     st.error(f"Function `select_abbreviations` not defined: {e}")
except Exception as e_select:
     st.error(f"Error during selection: {e_select}")


# 5. Apply Sorting (Moved here from select_abbreviations)
display_dataframe = filtered_dataframe # Start with filtered data
if not filtered_dataframe.empty:
    sort_by_actual = sort_column_map.get(sort_by_display, 'abbreviation')
    sort_ascending = not (sort_by_actual in ['usage_count', 'perc_abbr_matches'])
    secondary_sort = 'abbreviation'; secondary_ascending = True
    if sort_by_actual == 'abbreviation': secondary_sort = 'usage_count'; secondary_ascending = False

    # Check if sort columns exist before attempting sort
    cols_to_sort_by = [sort_by_actual]
    if secondary_sort != sort_by_actual: # Avoid duplicate sort column
        cols_to_sort_by.append(secondary_sort)

    if all(col in filtered_dataframe.columns for col in cols_to_sort_by):
        try:
            display_dataframe = filtered_dataframe.sort_values(
                by=cols_to_sort_by,
                ascending=[sort_ascending, secondary_ascending] if len(cols_to_sort_by)>1 else sort_ascending,
                ignore_index=True
            )
        except KeyError as sort_e:
             st.error(f"Error during sorting: Column '{sort_e}' not found.")
             # display_dataframe remains filtered but unsorted
        except Exception as sort_e:
             st.error(f"Error during sorting: {sort_e}")
             # display_dataframe remains filtered but unsorted
    else:
        st.warning(f"Cannot sort by '{sort_by_actual}': Column not found in filtered data.")


# 6. Display Table using Markdown
st.write("") # Add some vertical space
st.subheader("Selected Abbreviations")

if not display_dataframe.empty:
    # Rename columns for display and format percentage
    display_df_formatted = display_dataframe.rename(columns={
        'abbreviation': 'Abbreviation',
        'full_name': 'Full Phrase',
        'usage_count': 'Usage',
        'perc_abbr_matches': 'Match %'
    })
    # Define final columns order for display
    display_columns_order = ['Abbreviation', 'Full Phrase', 'Match %', 'Usage']
    # Select only the columns that actually exist in the dataframe
    display_columns_exist = [col for col in display_columns_order if col in display_df_formatted.columns]
    display_df_formatted = display_df_formatted[display_columns_exist]

    try:
        # Format percentage column if it exists
        if 'Match %' in display_df_formatted.columns:
            display_df_formatted['Match %'] = display_df_formatted['Match %'].map('{:.1%}'.format)
    except Exception as fmt_e: st.warning(f"Could not format Match %: {fmt_e}")

    # Convert the relevant part of the DataFrame to a Markdown table string
    # Set index=True to include the DataFrame's default index (0, 1, 2...)
    markdown_table = display_df_formatted.to_markdown(index=True)

    # Display using st.markdown
    st.markdown(markdown_table, unsafe_allow_html=False)
else:
    # Display message if no data meets criteria after filtering
    st.info("No abbreviations match the current filter criteria.")


# 7. Export Section
st.divider()
st.subheader("Export Selected Abbreviations")
col_exp_sel, _ = st.columns([1, 1]) # Keep export controls less wide
with col_exp_sel:
    selected_format = st.selectbox(
        label="Choose an exporting format:", label_visibility="collapsed", options=['plain', 'tabular', 'nomenclature'], index=0, key='format_selector', help="Select the format for the selected abbreviation list output."
    )

formatted_output = "No abbreviations selected based on filters."
# Use the final filtered AND sorted DataFrame for export
df_export = display_dataframe

if df_export is not None and not df_export.empty:
    try:
        # Assumes format_abbreviations function is defined
        formatted_output = format_abbreviations(df_export, format_type=selected_format)
    except NameError as e: formatted_output = f"Error: `format_abbreviations` fn not defined."; st.error(formatted_output)
    except Exception as format_e: formatted_output = f"Error formatting output: {format_e}"; st.error(formatted_output)
elif 'collected_df' not in st.session_state or st.session_state.collected_df is None: formatted_output = "Process text first."

st.text_area(label="Formatted Output for Copying:", label_visibility="visible", value=formatted_output, height=150, help="Copy the formatted output from this box.", key="output_text_area")

# 8. Explanations & Footer
st.divider()
st.subheader("About the Algorithm")
# Define explanation text variables or load them elsewhere in your script
summary_expander_label = "ⓘ How Abbreviation Extraction Works (Summary)"
summary_explanation_text = r"""(Your summary explanation text should be defined globally/above)"""
detailed_expander_label = "ⓘ Detailed Algorithm Explanation"
detailed_description_text = r"""(Your detailed explanation text should be defined globally/above)"""
col1_exp, col2_exp = st.columns(2)
# Use try-except or check if text variables exist before markdown
try:
    with col1_exp: st.expander(summary_expander_label).markdown(summary_explanation_text)
    with col2_exp: st.expander(detailed_expander_label).markdown(detailed_description_text)
except NameError: pass # Ignore if explanation text not defined

# --- Footer ---
st.markdown("---")
st.caption("Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada")

