#!/usr/bin/env python
# coding: utf-8
# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: tags,-all
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.16.7
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# %% [markdown] tags=[]
# # Import libraries

# %% tags=[]
import pandas as pd
#import streamlit as st
import re
from datetime import datetime
import socket
import textwrap


hostname = socket.gethostname()
DEBUG = "streamlit" not in hostname.lower()  # Assume cloud has "streamlit" in hostname


# %% [markdown]
# # Preprocessing Text with Space Inserted or Removed

# %% tags=[]
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


# %% [markdown] tags=[]
# ## Normalize_dollar_spacing
# %% tags=[]


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


# %% [markdown]
# ## Normalization Function
# %%


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


# %% [markdown]
# # Finding Matching
# %% [markdown]
# ## KNOWN_COMMAND_NAMES
# %%


# --- Expanded KNOWN_COMMAND_NAMES Set ---

KNOWN_COMMAND_NAMES = {
    # Lowercase Greek
    'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta',
    'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho',
    'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',

    # Uppercase Greek (Ensure exact case matching LaTeX)
    'Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi', 'Sigma', 'Upsilon',
    'Phi', 'Psi', 'Omega',

    # --- NEWLY ADDED COMMON MATH/SCIENCE COMMANDS ---

    # Common Functions
    'sin', 'cos', 'tan', 'csc', 'sec', 'cot',
    'arcsin', 'arccos', 'arctan',
    'sinh', 'cosh', 'tanh',
    'log', 'ln', 'exp',
    'sqrt',
    'frac', # Often takes arguments, but name itself is semantic

    # Limits / Bounds / Operators
    'lim', 'max', 'min', 'sup', 'inf',
    'det', 'dim', 'deg', # Degree symbol often ^\circ, but deg exists
    'gcd', 'hom', 'ker', 'Pr', # Probability

    # Large Operators (Symbols but represent operation)
    'sum', 'prod', 'int', 'oint', # Integral variants
    'bigcup', 'bigcap', 'bigvee', 'bigwedge',

    # Calculus / Vector Calculus
    'partial', 'nabla', 'mathrm', # d in mathrm often used for derivative/integral dx

    # Symbols with semantic meaning often abbreviated
    'infty', # Infinity
    'prime', # As in f'

    # Common Logic/Set Theory (Add more if needed for your domain)
    'forall', 'exists', 'in', 'notin', 'subset', 'supset',
    # 'subseteq', 'supseteq', 'cup', 'cap', 'vee', 'wedge',

    # Common Relations (Add more if needed)
    'leq', 'geq', 'equiv', 'approx', 'propto', 'sim', 'simeq',

    # Other Potentials (Consider based on your specific field)
    # 'vec', 'hat', 'bar', 'tilde', # Accents - Treat by name or first letter? (Leaving out for now)
    # 'mathbb', 'mathcal', 'mathbf', 'mathit', # Fonts - Usually formatting (Leaving out)
    # 'text', # Usually wraps non-math text (Leaving out)

    # Common Operators with names (less likely abbreviation targets?)
    'pm', 'mp', 'times', 'div', 'cdot', 'ast', 'star',
}

# --- Reminder: How this set is used by the helper functions ---

# In get_letters_abbrs(abbr_string):
#   If a command like `\sqrt` is found, and 'sqrt' is in KNOWN_COMMAND_NAMES,
#   the comparable item added is 'sqrt'.
#   If a command like `\textbf` is found, and 'textbf' is NOT in KNOWN_COMMAND_NAMES,
#   the comparable item added is 't'.

# In get_letters_words(word, debug=False):
#   If a word starts with `\sqrt`, and 'sqrt' is in KNOWN_COMMAND_NAMES,
#   this function returns 'sqrt'.
#   If a word starts with `\textbf{Word}`, and 'textbf' is NOT in KNOWN_COMMAND_NAMES,
#   this function proceeds to find the first letter of the content ('w').


# %% [markdown]
# ## Get Abbr Letters
# %%


# --- REVISED get_letters_abbrs (Handles consecutive numbers \d+) ---
def get_letters_abbrs(abbr_string):
    """
    Parses abbreviation string component by component using finditer.
    - Known commands (\\alpha) -> comparable name ('alpha').
    - Unknown commands (\\textbf) -> first letter lowercase ('t').
    - Letter-Number combinations (N1) -> comparable string ('n1').
    - Uppercase letters (G) -> first letter lowercase ('g').
    - Standalone lowercase letters/words (a, word) -> first letter ('a', 'w').
    - Consecutive Digits (2025) -> digit string ('2025'). # MODIFIED RULE
    Returns list of comparables AND list of corresponding original segments.

    Returns:
        tuple: (representative_items, original_parts)
               - representative_items: list (e.g., 'alpha', 't', 'g', 'm', 'n1', '2025')
               - original_parts: list of original strings (e.g., '\\alpha', '\\textbf', 'G', 'M', 'N1', '2025')
    """
    representative_items = []
    original_parts = []
    # --- MODIFIED REGEX: Changed (\d) to (\d+) for Group 6 ---
    # Regex captures: \cmd | CapNum | Upper | OptionalTrailingLower | StandaloneLower | Num+
    regex_pattern = r'(\\[a-zA-Z]+)|([A-Z][0-9]+)|([A-Z])([a-z]+)?|([a-z])(?:[a-z]*)|(\d+)'
    # Groups:      (1:Cmd)        (2:CapNum)     (3:Upper)(4:TrailLow) (5:StdLow)       (6:Num+)

    for match_obj in re.finditer(regex_pattern, abbr_string):
         original_segment = match_obj.group(0) # The whole segment matched
         command = match_obj.group(1)          # Group 1: e.g., \alpha
         cap_num = match_obj.group(2)          # Group 2: e.g., N1
         upper = match_obj.group(3)              # Group 3: e.g., G
         # trailing_lower = match_obj.group(4) # Group 4 - Ignored
         standalone_lower = match_obj.group(5) # Group 5: e.g., p in protein
         number_seq = match_obj.group(6)       # Group 6: e.g., 2025

         current_repr_item = None # Use None to track if set
         current_orig_part = original_segment # Store the originally matched segment

         if command:
             command_name = command[1:]
             if command_name in KNOWN_COMMAND_NAMES:
                 current_repr_item = command_name.lower() # Known command -> name
             else:
                 current_repr_item = command_name[0].lower() # Unknown command -> first letter
             current_orig_part = command # Original part is the command itself

         elif cap_num: # Handle N1, H2 etc.
             current_repr_item = cap_num.lower() # Use 'n1', 'h2' lowercase
             current_orig_part = cap_num # Original part is 'N1'

         elif upper: # Handle G, L, M, or R in Rsp etc.
             current_repr_item = upper.lower() # Use first letter only
             current_orig_part = original_segment # Original part includes trailing lower if present (e.g. "Rsp")

         elif standalone_lower: # Handle 'a', or first letter of 'protein'
             current_repr_item = standalone_lower # Group 5 only captures first letter
             current_orig_part = original_segment # Original part is the full lowercase word

         elif number_seq: # Handle '2025' etc.
             # --- MODIFIED LOGIC: Use the whole number sequence ---
             current_repr_item = number_seq # Use the full number string '2025'
             current_orig_part = number_seq # Original part is the number string
             # --- END MODIFICATION ---

         # Append only if a representative item was derived
         if current_repr_item is not None:
             representative_items.append(current_repr_item)
             original_parts.append(current_orig_part)

    return representative_items, original_parts

if (False):
# --- Example Usage ---
    print("--- Testing get_letters_abbrs (Corrected for Consecutive Numbers) ---")
    abbr1 = "GLM"
    abbr2 = r"\alpha SP"
    abbr3 = "BFN1"
    abbr4 = "Version 3" # Should yield v, 3
    abbr5 = "H2O"
    abbr6 = "Li et al. 2025" # Should yield l, e, a, l, 2025

    abbreviations_to_test = [abbr1, abbr2, abbr3, abbr4, abbr5, abbr6]

    for abbr_str in abbreviations_to_test:
        comparable_items, original_segments = get_letters_abbrs(abbr_str)
        print(f"Input:  '{abbr_str}'")
        print(f"  -> Comparables: {comparable_items}")
        print(f"  -> Originals:   {original_segments}")
        print("-" * 20)



# %% [markdown]
# ## Get Words Letters
# %%


# Assume KNOWN_COMMAND_NAMES set is defined

def get_letters_words(word: str, debug: bool = False) -> str:
    """
    Derives a comparable unit (lowercase) from a word token.
    - If the word is primarily a known LaTeX command -> returns command name ('alpha').
    - For other words (including unknown commands like \\textbf{Word}) ->
      returns the single effective first letter ('g' for 'Generalized', 'w' for Word).
    - Returns '' for separators or unprocessable words.
    """
    original_word = word; word = word.strip()
    if not word: return ''

    try:
        # 1. Check if it starts with a LaTeX command
        command_match = re.match(r'\$?(\\[a-zA-Z]+)', word)
        if command_match:
            command_name = command_match.group(1)[1:]
            # --- MODIFIED Logic: Only return name if KNOWN ---
            if command_name in KNOWN_COMMAND_NAMES:
                 # If known command, return its name lowercase
                 return command_name.lower()
            # --- If it's an unknown command (\textbf etc.), DON'T return here.
            # Let processing continue below to find first letter of content/command name itself.

        # 2. Find first effective letter (applies to regular words AND unknown commands)
        word_to_check = word
        # Strip leading command \cmd{ or \cmd (handles unknown like \textbf{ )
        word_to_check = re.sub(r'^\s*\\([a-zA-Z]+)\s*\{?', '', word_to_check)
        # Strip other common leading junk more aggressively
        word_to_check = word_to_check.lstrip(' ${}')
        # Strip trailing brace more aggressively
        if word_to_check.endswith('}'): word_to_check = word_to_check[:-1].rstrip()

        # Find first letter in remaining text OR in the command name if that's all left
        first_letter_match = re.search(r'[a-zA-Z]', word_to_check)
        if first_letter_match:
            return first_letter_match.group(0).lower()
        # --- ADDED: Fallback specifically for unknown commands where content was empty ---
        elif command_match: # If we detected an unknown command earlier but found no letter in content
             unknown_command_name = command_match.group(1)[1:]
             return unknown_command_name[0].lower() # Use first letter of the command itself
        # --- END ADDED Fallback ---


        # Fallback: Check original word directly if others failed
        fallback_match_orig = re.search(r'[a-zA-Z]', original_word)
        if fallback_match_orig: return fallback_match_orig.group(0).lower()

        return '' # No letter found

    except Exception as e:
        # if debug: print(f"      Error in get_letters_words for '{original_word}': {e}") # Keep minimal
        # Fallback on error
        fallback_match = re.search(r'[a-zA-Z]', original_word)
        return fallback_match.group(0).lower() if fallback_match else ''


# %% [markdown]
# ## find_abbreviation_matches
# %%


def find_abbreviation_matches(words_ahead, abbr_string, debug=True):
    """
    Performs backward matching using startswith comparison logic.
    Calculates and returns match indices, abbreviation match ratio,
    and matched words ratio within the identified phrase range.
    If debug=True, prints debug information including a final DataFrame.

    Args:
        words_ahead (list): Word tokens from the definition part.
        abbr_string (str): The original abbreviation string.
        debug (bool): Flag to enable console debug printing.

    Returns:
        tuple: (match_indices, match_ratio, perc_words_matched)
               - match_indices: list mapping abbr_idx -> word_idx (-1 if no match).
               - match_ratio: float, fraction of matched abbr items (0.0 to 1.0).
               - perc_words_matched: float, fraction of 'real' words in the matched
                 phrase range (from first match to end) that were matched by an abbr item.
               Returns ([], 0.0, 0.0) if abbreviation parsing fails or yields no items.
    """
    try:
        abbr_items, original_abbr_parts = get_letters_abbrs(abbr_string)
        num_abbr_items = len(abbr_items)
        if not abbr_items:
             if debug: print(f"Warning: Abbr string '{abbr_string}' yielded no items.")
             return [], 0.0, 0.0
    except Exception as e_parse:
         if debug: print(f"Error parsing abbr string '{abbr_string}': {e_parse}.")
         return [], 0.0, 0.0

    num_words = len(words_ahead)
    match_indices = [-1] * num_abbr_items
    last_matched_index = num_words
    words_ahead_comparables = [get_letters_words(word, debug=False) for word in words_ahead]

    if debug:
        # Print initial state for debugging
        print("\n" + ("=" * 100))
        #print(f"Starting find_abbreviation_matches for ('{abbr_string}')\n")
        # print(f"  Words Ahead ({num_words}): {words_ahead}")
        # print(f"  Words Ahead Comparables ({len(words_ahead_comparables)}): {words_ahead_comparables}")
        print(f"  Abbr Items (Letter/CmdName) ({num_abbr_items}): {abbr_items}")
        # print(f"  Original Abbr Parts ({len(original_abbr_parts)}): {original_abbr_parts}")
        # # Removed threshold print
        # print("-" * 20)

    # --- Matching Loop ---
    for abbr_idx in range(num_abbr_items - 1, -1, -1):
        target_comparable = abbr_items[abbr_idx]; match_found_for_abbr = False
        if not target_comparable: continue
        for word_idx in range(last_matched_index - 1, -1, -1):
            word_comparable = words_ahead_comparables[word_idx]
            if not word_comparable: continue
            current_match_found = word_comparable.startswith(target_comparable)
            if current_match_found:
                match_indices[abbr_idx] = word_idx; last_matched_index = word_idx; match_found_for_abbr = True;
                # Removed verbose internal prints
                break
    # --- END Matching Loop ---

    # --- Calculate Results ---
    successful_match_indices = [idx for idx in match_indices if idx != -1]
    count_matched = len(successful_match_indices)
    match_ratio = count_matched / num_abbr_items if num_abbr_items > 0 else 0.0
    perc_words_matched = 0.0; matchable_words_in_range = 0
    if successful_match_indices:
        start_range_idx = min(successful_match_indices)
        if 0 <= start_range_idx < num_words:
            for i in range(start_range_idx, num_words):
                if words_ahead_comparables[i]: matchable_words_in_range += 1
            if matchable_words_in_range > 0: perc_words_matched = min(count_matched / matchable_words_in_range, 1.0)
    # --- END Calculate Results ---

    # --- Debugging Output Section ---
    if debug:

        # Keep calculation and printing of the final debug DataFrame
        matched_abbrs_string = [''] * num_words; matched_abbrs_comparable = [''] * num_words
        for i, w_idx in enumerate(match_indices):
            if w_idx != -1 and 0 <= w_idx < num_words:
                if 0 <= i < len(abbr_items): matched_abbrs_comparable[w_idx] = abbr_items[i]
                if 0 <= i < len(original_abbr_parts): matched_abbrs_string[w_idx] = original_abbr_parts[i]
        #print("\n  Matching Details (Debug DataFrame):")
        try:
            debug_data = {'Words Ahead': words_ahead,'Words Ahead Comparables': words_ahead_comparables,'Matched Abbrs (String)': matched_abbrs_string,'Matched Abbrs (Comparable)': matched_abbrs_comparable}
            if all(len(lst) == num_words for lst in debug_data.values()):
                df_debug = pd.DataFrame(debug_data); print(f"\n  Matching Result (Rows: Words, Comparables, MatchOrig, MatchComp):\n{textwrap.indent(df_debug.T.to_string(), '    ')}")
            else: print("\n  [DEBUG] Error: Length mismatch for debug DataFrame.")
        except Exception as e_debug: print(f"\n  [DEBUG] Error creating debug DataFrame: {e_debug}")
        #print("--- Ending find_abbreviation_matches ---\n")

       # Print calculated results
        print(f"\nMatching Complete: Matched {count_matched}/{num_abbr_items} items.")
        print(f"  Abbr Match Ratio: {match_ratio:.2f}")
        print(f"  Words Matched Ratio (in range): {perc_words_matched:.2f}")
        print(f"  Final match indices (abbr_idx -> word_idx): {match_indices}"+"\n") # Keep this useful index map

    # --- END Debugging Output Section ---

    # --- Return the results ---
    return match_indices, match_ratio, perc_words_matched # Return tuple


# %% [markdown]
# # Extracting Abbreviations
# %% [markdown]
# ## Collect_abbreviations
# %%


import re
import pandas as pd
# Assumes find_abbreviation_matches function is defined elsewhere

# --- collect_abbreviations Function (Syntax Corrected) ---

def collect_abbreviations(text, debug=False):
    """
    Finds all potential abbreviation candidates Def (Abbr), calculates usage,
    calls find_abbreviation_matches to get matching details (indices and ratios),
    and reconstructs potential full name.
    Does NOT filter based on match ratio or usage count.

    Args:
        text (str): The input text (ideally normalized).
        debug (bool): Flag to enable detailed debug printing in this function
                      and called functions.

    Returns:
        pd.DataFrame: DataFrame containing all candidates with columns:
                      'abbreviation', 'full_name', 'usage_count',
                      'perc_abbr_matches', 'perc_words_matched'.
                      Returns empty DataFrame if no candidates found.
    """
    # Initial pattern find candidates
    #pattern = r'((?:[\w\\\$\{\}]+[ -]+){1,10}(?:[\w\\\$\{\}]+)[ -]?)\(([^\(\)]*[a-zA-Z0-9]{2,}[^\(\)]*)\)'
    pattern = r'((?:[\w\\\$\{\}]+[ -]+){1,10}(?:[\w\\\$\{\}]+)[ -]?)\((?=[^\(\)\,]*[A-Z])([^\(\)\,]*[a-zA-Z0-9]{2,}[^\(\)\,]*)\)'
#                                                                    ^^^^^^^^^^^^^^^^^^^  <-- Added Positive Lookahead
    matches = re.findall(pattern, text)

    # Define expected columns for the output DataFrame
    required_columns = ['abbreviation', 'full_name', 'usage_count', 'perc_abbr_matches', 'perc_words_matched']
    empty_df = pd.DataFrame(columns=required_columns)

    if not matches:
        # Return empty DataFrame early if no initial regex matches found
        # if debug: print("collect_abbreviations: No potential candidates found by initial regex.") # Keep debug minimal
        return empty_df

    # if debug: print(f"collect_abbreviations: Found {len(matches)} potential candidates.") # Keep debug minimal

    # Calculate usage counts first
    abbr_usage_count = {}
    all_potential_abbrs = [match[1].strip() for match in matches]
    for abbr in set(all_potential_abbrs):
        abbr_search_string = re.sub(r'[\(\)]','',abbr) # Basic cleaning
        # Using lookaround pattern for usage count robustness
        aup = rf'(?<![a-zA-Z\(\)]){re.escape(abbr_search_string)}(?![a-zA-Z\)\)])'
        try:
            abbr_usage_count[abbr] = len(re.findall(aup,text))
        except re.error as e:
            # --- CORRECTED INDENTATION ---
            if debug: # Indented
                print(f"  Regex error counting usage for '{abbr}': {e}")
            abbr_usage_count[abbr] = 0 # Indented - Set count to 0 on error
            # --- END CORRECTION ---
    # if debug: print(f"  Usage Counts Calculated: {len(abbr_usage_count)} unique abbreviations.") # Keep debug minimal

    # Process each candidate found by the initial regex
    all_candidate_data = []
    for match_idx, match in enumerate(matches):
        words_before_abbr_text = match[0].strip()
        abbr_string = match[1].strip()
        current_usage_count = abbr_usage_count.get(abbr_string, 0) # Get pre-calculated count

        # if debug: print(f"\n--- Collecting Candidate {match_idx+1}: Abbr='{abbr_string}' ---") # Keep debug minimal

        # Tokenize words before abbreviation
        split_pattern = r'([ -]+)'; split_list = re.split(split_pattern, words_before_abbr_text);
        words_ahead = [item for item in split_list if item]

        # Initialize results for this candidate
        full_name = ""; match_ratio = 0.0; perc_words = 0.0; match_indices = []

        if words_ahead:
            if (debug):
                print ("=" * 100)
                print("\n" + f"Starting the matching process for Candidate {match_idx}" + "\n")
                print(" " * 10 + f" {words_before_abbr_text} ({abbr_string})")
                # Call find_abbreviation_matches to get indices and ratios
            # Assumes find_abbreviation_matches is defined and returns tuple(list, float, float)
            try:
                 match_indices, ratio_result, perc_words_result = find_abbreviation_matches(
                    words_ahead,
                    abbr_string,
                    debug=debug # Pass debug flag down
                )
                 match_ratio = ratio_result
                 perc_words = perc_words_result
            except NameError as e_find:
                 if debug: print(f"  Error: find_abbreviation_matches function not defined? {e_find}")
                 # Keep defaults (empty name, zero ratios)
            except Exception as e_find_other:
                 if debug: print(f"  Error calling find_abbreviation_matches: {e_find_other}")
                 # Keep defaults

            # Reconstruct name based on match_indices (even if ratio is low)
            if match_indices: # Check if list is not empty (find_... returns [] on error/no parse)
                successful_match_indices = [idx for idx in match_indices if idx != -1]
                if successful_match_indices:
                    min_idx_py = min(successful_match_indices)
                    # Slice from first matched word to end
                    if 0 <= min_idx_py < len(words_ahead):
                        full_phrase_words_slice=words_ahead[min_idx_py:]
                        fn=''.join(full_phrase_words_slice).strip()
                        full_name=fn
                    # elif debug: print(f"  Warning: Invalid min_idx {min_idx_py} for reconstruction.") # Keep debug minimal
        # elif debug: print("  Note: No words found before abbreviation for reconstruction.") # Keep debug minimal

        # Append data for every candidate
        all_candidate_data.append({
            'abbreviation': abbr_string,
            'full_name': full_name,
            'usage_count': current_usage_count,
            'perc_abbr_matches': match_ratio,
            'perc_words_matched': perc_words
        })
        # if debug: print(f"  Collected: AbbrRatio={match_ratio:.2f}, WordRatio={perc_words:.2f}, Usage={current_usage_count}, Name='{full_name}'") # Keep debug minimal

    # Create the final DataFrame from all collected data
    if not all_candidate_data:
        return empty_df # Return empty DF with correct columns
    else:
        collected_df = pd.DataFrame(all_candidate_data)
        # Ensure columns exist and are in the desired order before returning
        for col in required_columns:
            if col not in collected_df.columns:
                 # Add missing column - should only happen if upstream changes break expected output
                 if 'perc' in col: collected_df[col] = 0.0
                 elif 'usage' in col: collected_df[col] = 0
                 else: collected_df[col] = ""
        return collected_df[required_columns]


# %% [markdown]
# ## Select Abbreviations
# %%


# --- 5.2 select_abbreviations ---
def select_abbreviations(
    collected_df,
    threshold_perc_abbr_matches=0.7,
    threshold_usage=0,
    threshold_perc_words_matched=0.0, # Added threshold for new metric
    debug=False
    ):
    """
    Filters a DataFrame of abbreviation candidates based on criteria.
    DOES NOT SORT or add/remove display columns like 'Row No.'.

    Args:
        collected_df (pd.DataFrame): DataFrame from collect_abbreviations.
        threshold_perc_abbr_matches (float): Min abbr match ratio required.
        threshold_usage (int): Min usage count required.
        threshold_perc_words_matched (float): Min word match ratio required.
        debug(bool): Enable printing status messages.

    Returns:
        pd.DataFrame: Filtered DataFrame with original columns from collect_abbreviations.
                      Returns empty DataFrame if none meet criteria or input invalid.
    """
    # Define expected columns from input/output of this stage
    final_columns = ['abbreviation', 'full_name', 'usage_count', 'perc_abbr_matches', 'perc_words_matched']
    empty_df = pd.DataFrame(columns=final_columns)

    if not isinstance(collected_df, pd.DataFrame) or collected_df.empty:
        if debug: print("select_abbreviations: Input DataFrame empty/invalid.")
        return empty_df
    required_cols = final_columns
    if not all(col in collected_df.columns for col in required_cols):
         if debug: print(f"select_abbreviations: Input missing required columns."); return empty_df

    #if debug: print(f"\n--- Starting select_abbreviations ---\n Input: {len(collected_df)}\n Filters: AbbrRatio>={threshold_perc_abbr_matches}, Usage>={threshold_usage}, WordRatio>={threshold_perc_words_matched}")

    # Apply Filters (including new one)
    filtered_df = collected_df[
        (collected_df['perc_abbr_matches'] >= threshold_perc_abbr_matches) &
        (collected_df['usage_count'] >= threshold_usage) &
        (collected_df['perc_words_matched'] >= threshold_perc_words_matched) # Filter by word match %
    ].copy()

    if filtered_df.empty:
        if debug: print(f"  Filtering Result: No abbreviations met criteria.")
        return empty_df # Return empty DF with correct columns
    #if debug: print(f"  Filtering Result: {len(filtered_df)} passed criteria.\n--- Ending select_abbreviations ---")

    # Return the filtered DataFrame (unsorted, contains all collected columns)
    return filtered_df


# %% [markdown] tags=[]
# # Formatting abbrs
# %% tags=[]


# --- 6. Formatting abbrs ---

def format_abbreviations(abbr_df, format_type):
     """
     Formats selected DataFrame for export (e.g., plain text, LaTeX table).
     Ignores columns like percentages before formatting.
     Assumes input abbr_df is the final filtered (and possibly sorted) data.
     """
     # Drop columns not typically needed for final export format
     cols_to_drop = [col for col in ['Row No.', 'perc_abbr_matches', 'perc_words_matched'] if col in abbr_df.columns]
     df_to_format = abbr_df.drop(columns=cols_to_drop)

     if df_to_format.empty: return "No abbreviations selected."

     # Generate output based on format_type
     if format_type == "tabular":
         # Use f-strings and ensure proper escaping for LaTeX special chars in content if needed
         header = "\\begin{tabular}{ll}\n\\hline\n\\textbf{Abbreviation} & \\textbf{Full Name} \\\\\n\\hline\n"
         footer = "\\hline\n\\end{tabular}\n"
         rows = [f"{row.get('abbreviation','')} & {row.get('full_name','')} \\\\" for _, row in df_to_format.iterrows()]
         return header + "\n".join(rows) + "\n" + footer
     elif format_type == "nomenclature":
         header = "\\usepackage{nomencl}\n\\makenomenclature\n"
         rows = [f"\\nomenclature{{{row.get('abbreviation','')}}}{{{row.get('full_name','')}}}" for _, row in df_to_format.iterrows()]
         return header + "\n".join(rows)
     else: # plain text
          rows = [f"{row.get('abbreviation','')}: {row.get('full_name','')}" for _, row in df_to_format.iterrows()]
          return "; \n".join(rows)



# %% [markdown]
# # Example Text and Testing
# %% [markdown]
# ## example_text
# %%


example_text = r"""Paste your latex text (LT)  and enjoy the app (ETA). There is no limitation of the length of text (LT).

What is regarded as abbreviations (RA):
The abbreviations like accelerated failure time (AFT), or \textbf{Time-Constant (TC) Data}.
The full definitions and abbrievations can contain greek symbols or simple latex commands like \frac, for example,
$\alpha$ Predictive p-value (aPP),
$\alpha$ synclein protein ($\alpha$-synclein),
$\beta$-Z residual (BZR), $\sigma$-Z residual ($\sigma$-ZR).

What is desregarded as abbreviations (DA):
Citations and explanations in brackets will be omitted, eg. this one (Li et al. 2025), and this ($\beta$). The $T$ in $f(T)$ is not an abbreviation too.
%This abbreviation, comment text (CT) or the line starting with % will be omitted.

Note: the extraction is not perfect as it cannot accommodate all possible abbreviations and may include those you don't want. Modify the results as necessary.

The abbreviations used above include: AFT, BZR,  DA,  ETA, LT, RSP,  RA, TC, $\alpha$-SP, $\sigma$-ZR. ETA!

"""



# %% [markdown]
# # Ipywidgets UI
# %% [markdown]
# ## Descriptions

# %% tags=[]
# @title 

# --- Define Explanation Text Variables ---
# Copied from above for inclusion
summary_expander_label = "ⓘ How Abbreviation Extraction Works (Summary)"
summary_explanation_text = r"""
This tool tries to automatically find abbreviations defined within parentheses immediately following their full phrase, like `Full Definition Phrase (Abbr)`, even within text containing common LaTeX commands and math.

Here’s a simplified overview:

1.  **Cleaning:** The input LaTeX text is first cleaned up – comments are removed, math delimiters are standardized, and perhaps most importantly, consistent spacing is added around commands, braces `{}` and parentheses `()` to help separate items.
2.  **Finding Candidates:** It scans the cleaned text for the `Phrase (...)` pattern using regular expressions.
3.  **Parsing & Comparing:**
    * The potential abbreviation inside the parentheses (e.g., `GLM`, `\alpha SP`) is broken down into its core components. These become either a single lowercase letter (`g`, `l`, `m`, `s`, `p`) or a lowercase command name (`alpha`).
    * The words *before* the parentheses are also processed to get comparable units – either the full lowercase word (`generalized`, `linear`, `model`, `protein`) or a lowercase command name (`alpha`, `beta`).
    * The algorithm works backward from the end of the abbreviation and the end of the phrase, checking if the **word unit `startswith` the abbreviation unit** (e.g., does `generalized` start with `g`? does `alpha` start with `alpha`? does `alpha` start with `a`?). It tries to find a consistent match for all abbreviation components.
4.  **Calculating Match Quality:** Two "match percentage" metrics are calculated:
    * **% Abbr Matched:** What percentage of the abbreviation's components successfully matched a preceding word.
    * **% Words Matched:** Within the range of words considered part of the definition (from first match to end), what percentage of those 'real' words were matched by an abbreviation component.
5.  **Reconstructing Phrase:** If a match is found, the tool reconstructs the likely full phrase by taking the text from where the *first* component of the abbreviation matched, all the way up to the opening parenthesis.
6.  **Counting Usage:** It also counts how many times the literal abbreviation appears elsewhere in the text.
7.  **Filtering & Sorting:** Finally, you can use the filter controls to select only those abbreviations that meet your desired minimum criteria for both match percentages and usage count. You can also sort the results by different columns.

*(Disclaimer: This process uses specific rules and heuristics. It may not catch all possible ways abbreviations are defined and might sometimes misinterpret patterns, especially with very complex LaTeX.)*
"""


detailed_expander_label = "ⓘ Detailed Algorithm Explanation"
detailed_description_text = r"""
This algorithm identifies and extracts abbreviation definitions like `Full Definition Phrase (Abbr)` from potentially LaTeX-formatted text.

**Core Steps:**

1.  **Normalization (`normalize_latex_math`):** (Optional) Input text preprocessing: comments removed, math delimiters standardized (`$...$`), spacing adjusted around `{}()`, commands.
2.  **Candidate Identification (Regex):** Finds all `Potential Phrase (Abbr)` patterns, capturing the phrase part and the `abbr_string`.
3.  **Usage Counting:** Counts occurrences of each unique `abbr_string` elsewhere in the text.
4.  **Processing Each Candidate (`collect_abbreviations` loop):**
    * **Phrase Tokenization:** Splits the phrase part into `words_ahead` (list of words and delimiters).
    * **Abbreviation Parsing (`get_letters_abbrs`):** Gets `abbr_items` (list of comparable units: `alpha` or `g`) and `original_abbr_parts` (list: `\alpha` or `G`).
    * **Word Parsing (`get_letters_words`):** Pre-calculates `words_ahead_comparables` (list of comparable units: `alpha` or `generalized`).
    * **Backward Matching (`find_abbreviation_matches`):**
        * Compares `abbr_items` to `words_ahead_comparables` backward using `word_comparable.startswith(abbr_comparable)`.
        * Uses `last_matched_index` to constrain search.
        * Calculates `match_indices` (list: `abbr_idx` -> `word_idx`).
        * Calculates `match_ratio` (% Abbr Matched).
        * Calculates `perc_words_matched` (% Words Matched in derived range).
        * Returns `(match_indices, match_ratio, perc_words_matched)`.
    * **Phrase Reconstruction:** Uses `match_indices` to find the first matched word index (`min_idx_py`). Reconstructs `full_name` from `words_ahead[min_idx_py:]`.
    * **Data Collection:** Stores candidate `abbreviation`, `full_name`, `usage_count`, `perc_abbr_matches`, `perc_words_matched`.
5.  **DataFrame Creation (`collect_abbreviations` return):** Returns a DataFrame of *all* candidates.
6.  **Filtering (`select_abbreviations`):** Filters the collected DataFrame based on user-set thresholds for `perc_abbr_matches`, `usage_count`, and `perc_words_matched`.
7.  **Sorting (UI):** Sorts the filtered DataFrame based on the user's choice from the "Sort by" dropdown.
8.  **Display (UI):** Displays the filtered and sorted data using `st.markdown` rendering a Markdown table (`to_markdown(index=True)`). Shows default row index, renders `$LaTeX$` math. Includes both percentage columns. Table is static.
"""
# --- END Define explanation text variables ---


# %% [markdown]
# ## UI
#

# %%

# Import necessary libraries
import ipywidgets as widgets
from IPython.display import display, clear_output
import pandas as pd
import io # For potential future use like file output if needed

# --- IMPORTANT: Assumed Functions and Variables ---
# Ensure the following functions are defined or imported in your notebook:
# - normalize_latex_math(text)
# - collect_abbreviations(text, debug=False) -> returns pd.DataFrame
# - select_abbreviations(df, threshold_perc_abbr_matches, threshold_usage, threshold_perc_words_matched, debug=False) -> returns pd.DataFrame
# - format_abbreviations(df, format_type='plain') -> returns string
#
# Ensure the following variable is defined:
# - DEBUG (boolean, e.g., DEBUG = False)
#
DEBUG = False
# Ensure the following text variables are defined (copied from earlier input):
# - summary_expander_label (string)
# - summary_explanation_text (string)
# - detailed_expander_label (string)
# - detailed_description_text (string)
# --- END Assumed Functions and Variables ---


# --- Global variables to hold state ---
collected_df_raw = pd.DataFrame()
display_df_filtered_sorted = pd.DataFrame()

# --- Define UI Widgets ---

# 1. Input Area
input_subheader = widgets.HTML("<b>Paste Your Text</b>")

# --- MODIFIED START ---
# Try to use the user-defined example_text variable for the initial value
try:
    # This assumes 'example_text' is defined in a cell ABOVE this one
    initial_text_value = example_text
except NameError:
    # Fallback if example_text is not defined
    initial_text_value = ""
    print("Note: 'example_text' variable not found, starting with empty input area.")

input_text_area = widgets.Textarea(
    placeholder='Paste your LaTeX text here...',
    value=initial_text_value,  # Set the initial value here
    layout=widgets.Layout(height='250px', width='99%')
)
# --- MODIFIED END ---

privacy_caption = widgets.HTML("<p><i>Privacy: this app does not save your text.</i></p>")
process_button = widgets.Button(description="Process Text and Extract Abbreviations", button_style='primary')
input_box = widgets.VBox([input_subheader, input_text_area, privacy_caption, process_button])
# 2. Filtering Controls
filter_subheader = widgets.HTML("<h3>Filtering Controls</h3>")
reset_button = widgets.Button(description="Reset Filters", tooltip="Reset filters to default values.")
show_all_button = widgets.Button(description="Show All", tooltip="Show all collected items (minimum filters).")
header_button_box = widgets.HBox([
    reset_button,
    show_all_button,
    widgets.Box(layout=widgets.Layout(flex='3.5')) # Approximate large spacer
], layout=widgets.Layout(width='100%', justify_content='flex-start'))

# Filter options
usage_options = list(range(11))
# Create options list suitable for Dropdown display value mapping
abbr_perc_options_list = [f"{x*100:.0f}%" for x in [round(i * 0.1, 1) for i in range(11)]]
word_perc_options_list = [f"{x*100:.0f}%" for x in [round(i * 0.1, 1) for i in range(11)]]
# We'll map these back to float values in the callback if needed, or use a dictionary if Dropdown supports it well.
# Storing the float value directly in Dropdown is easier if labels aren't critical:
abbr_perc_float_options = [round(i * 0.1, 1) for i in range(11)]
word_perc_float_options = [round(i * 0.1, 1) for i in range(11)]

duplicate_options = ['No', 'Yes']

# Filter widgets - Use Dropdowns to match st.selectbox
# Using float options directly, format function can customize display label if needed (though Dropdown format_func is limited)
usage_filter_dd = widgets.Dropdown(options=usage_options, value=0, description="Usage ≥:", layout=widgets.Layout(flex='1 1 0%', width='auto'), style={'description_width': 'initial'})
abbr_match_filter_dd = widgets.Dropdown(options=abbr_perc_float_options, value=0.7, description="% Abbr Match ≥:", readout_format='.0%', layout=widgets.Layout(flex='1 1 0%', width='auto'), style={'description_width': 'initial'}) # Use readout_format
words_match_filter_dd = widgets.Dropdown(options=word_perc_float_options, value=0.3, description="% Words Match ≥:", readout_format='.0%', layout=widgets.Layout(flex='1 1 0%', width='auto'), style={'description_width': 'initial'}) # Use readout_format
clear_duplicates_dd = widgets.Dropdown(options=duplicate_options, value='No', description="Clear Duplicates:", layout=widgets.Layout(flex='1 1 0%', width='auto'), style={'description_width': 'initial'})

# Mimic st.columns([1, 1, 1, 1, 3]) => 4 widgets + spacer weighted 3 (adjust flex)
filter_controls_box = widgets.HBox([
    usage_filter_dd,
    abbr_match_filter_dd,
    words_match_filter_dd,
    clear_duplicates_dd,
    widgets.Box(layout=widgets.Layout(flex='1.5')) # Approx spacer weight
], layout=widgets.Layout(width='100%', justify_content='flex-start')) # Align left

filter_section = widgets.VBox([filter_subheader, header_button_box, filter_controls_box])

# 3. Results Display
results_subheader = widgets.HTML("<h3>Selected Abbreviations</h3>")
sort_options = ['Abbreviation', 'Full Phrase', 'Usage', '% Abbr Matched', '% Words Matched']
sort_dd = widgets.Dropdown(options=sort_options, value='Abbreviation', description="Sort by:")
# Mimic st.columns([2, 15])
results_header_box = widgets.HBox([
    sort_dd,
    widgets.Box(layout=widgets.Layout(flex='7.5')) # Spacer relative to sort_dd
], layout=widgets.Layout(width='100%', justify_content='flex-start'))

# Output widget to display table, messages, etc.
results_output = widgets.Output(layout=widgets.Layout(border='1px solid lightgray', padding='5px', width='99%'))
results_info_output = widgets.Output(layout=widgets.Layout(width='50%')) # Separate output for info notes

results_section = widgets.VBox([results_subheader, results_header_box, results_output, results_info_output])

# 4. Export Section
export_divider = widgets.HTML("<hr>")
export_subheader = widgets.HTML("<h3>Export Selected Abbreviations</h3>")
export_format_dd = widgets.Dropdown(options=['plain', 'tabular', 'nomenclature'], value='plain', description="Format:")
export_format_box = widgets.HBox([export_format_dd, widgets.Box(layout=widgets.Layout(flex='1'))]) # Mimic 50% width

export_output_text = widgets.Textarea(
    value="Process text first.",
    description="Formatted Output:",
    disabled=True,
    layout=widgets.Layout(height='150px', width='99%'),
    style={'description_width': 'initial'}
)
export_section = widgets.VBox([export_divider, export_subheader, export_format_box, export_output_text])

# 5. Explanations Section
explanation_divider = widgets.HTML("<hr>")
explanation_subheader = widgets.HTML("<h3>About the Algorithm</h3>")
# Use HTML widgets for content. Basic formatting applied.
summary_html = widgets.HTML(summary_explanation_text.replace('\n', '<br>').replace('`', '<code>').replace('$', '<i>$</i>'))
detailed_html = widgets.HTML(detailed_description_text.replace('\n', '<br>').replace('`', '<code>').replace('$', '<i>$</i>'))

expander1 = widgets.Accordion(children=[summary_html], selected_index=None) # Initially closed
try: expander1.set_title(0, summary_expander_label)
except NameError: expander1.set_title(0, "Summary")

expander2 = widgets.Accordion(children=[detailed_html], selected_index=None) # Initially closed
try: expander2.set_title(0, detailed_expander_label)
except NameError: expander2.set_title(0, "Details")

# Mimic st.columns(2)
explanation_box = widgets.HBox([expander1, expander2], layout=widgets.Layout(width='100%'))

explanation_section = widgets.VBox([explanation_divider, explanation_subheader, explanation_box])

# 6. Footer
footer_hr = widgets.HTML("<hr>")
footer_caption = widgets.HTML("<p><i>Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada</i></p>")
footer = widgets.VBox([footer_hr, footer_caption])


# --- Combine sections into final layout ---
main_layout = widgets.VBox([
    input_box,
    filter_section,
    results_section,
    export_section,
    explanation_section,
    footer
], layout=widgets.Layout(width='100%'))


# --- Callback Functions ---

# Function to update results based on current filters/sorting
def update_results_display(change=None):
    global collected_df_raw, display_df_filtered_sorted, DEBUG # Reference global DEBUG

    with results_output:
        clear_output(wait=True)
        current_display_df = pd.DataFrame()

        if collected_df_raw is None or collected_df_raw.empty:
            print("Process text first or no abbreviations found in raw collection.")
        else:
            data_to_filter = collected_df_raw.copy() # Work on a copy
            if clear_duplicates_dd.value == 'Yes' and 'abbreviation' in data_to_filter.columns:
                try: data_to_filter = data_to_filter.drop_duplicates(subset=['abbreviation'], keep='first', ignore_index=True)
                except Exception as e_dup: print(f"Warning: Issue removing duplicates: {e_dup}")

            try:
                # Ensure select_abbreviations function is available
                filtered_df = select_abbreviations(
                    data_to_filter,
                    threshold_perc_abbr_matches=abbr_match_filter_dd.value, # Direct float value
                    threshold_usage=usage_filter_dd.value,
                    threshold_perc_words_matched=words_match_filter_dd.value, # Direct float value
                    debug=DEBUG
                )
            except NameError: print("Error: select_abbreviations function not defined."); filtered_df = pd.DataFrame()
            except Exception as e_filt: print(f"Error during filtering: {e_filt}"); filtered_df = pd.DataFrame()

            display_dataframe = filtered_df.copy()
            if not display_dataframe.empty:
                try: # Wrap sorting logic in try-except
                    sort_column_map = {'Abbreviation': 'abbreviation', 'Full Phrase': 'full_name', 'Usage': 'usage_count', '% Abbr Matched': 'perc_abbr_matches', '% Words Matched': 'perc_words_matched'}
                    sort_by_display = sort_dd.value
                    sort_by_actual = sort_column_map.get(sort_by_display, 'abbreviation')
                    sort_ascending = not (sort_by_actual in ['usage_count', 'perc_abbr_matches', 'perc_words_matched'])
                    secondary_sort = 'abbreviation'; secondary_ascending = True
                    if sort_by_actual == 'abbreviation': secondary_sort = 'usage_count'; secondary_ascending = False
                    cols_to_sort_by = [sort_by_actual]; ascending_list = [sort_ascending]
                    if secondary_sort != sort_by_actual and secondary_sort in display_dataframe.columns:
                        cols_to_sort_by.append(secondary_sort); ascending_list.append(secondary_ascending)
                    if all(col in display_dataframe.columns for col in cols_to_sort_by):
                        display_dataframe = display_dataframe.sort_values(by=cols_to_sort_by, ascending=ascending_list, ignore_index=True)
                    else:
                        missing_cols = [col for col in cols_to_sort_by if col not in display_dataframe.columns]; print(f"Warning: Cannot sort on missing columns: {', '.join(missing_cols)}.")
                except Exception as sort_e: print(f"Error sorting data: {sort_e}")


            if not display_dataframe.empty:
                display_df_formatted = display_dataframe.rename(columns={'abbreviation': 'Abbreviation', 'full_name': 'Full Phrase', 'usage_count': 'Usage', 'perc_abbr_matches': '% Abbr Matched', 'perc_words_matched': '% Words Matched'})
                display_columns_order = ['Abbreviation', 'Full Phrase', 'Usage', '% Abbr Matched', '% Words Matched']
                display_columns_exist = [col for col in display_columns_order if col in display_df_formatted.columns]
                display_df_formatted = display_df_formatted[display_columns_exist]
                try:
                    if '% Abbr Matched' in display_df_formatted.columns: display_df_formatted['% Abbr Matched'] = display_df_formatted['% Abbr Matched'].apply(lambda x: f"{x:.1%}" if pd.notna(x) and isinstance(x, (int, float)) else x)
                    if '% Words Matched' in display_df_formatted.columns: display_df_formatted['% Words Matched'] = display_df_formatted['% Words Matched'].apply(lambda x: f"{x:.1%}" if pd.notna(x) and isinstance(x, (int, float)) else x)
                except Exception as fmt_e: print(f"Warning: Could not format percentage columns: {fmt_e}")
                n_rows = len(display_df_formatted)
                if n_rows > 0: display_df_formatted.index = pd.RangeIndex(start=1, stop=n_rows + 1, step=1)
                current_display_df = display_df_formatted.copy()
                # Display HTML table
                display(widgets.HTML(display_df_formatted.to_html(index=True, classes='jupyter-widgets table-widget')))
            else:
                print("No abbreviations match the current filter criteria.")

    # Update global state for export
    display_df_filtered_sorted = current_display_df.copy()

    # Update info notes separately
    with results_info_output:
        clear_output(wait=True)
        if not display_df_filtered_sorted.empty:
             if collected_df_raw is not None and not collected_df_raw.empty:
                count = len(collected_df_raw)
                display(widgets.HTML(f"<p>ℹ️ A total of {count} Possible Abbreviation{'s' if count != 1 else ''} Found. <b>Click 'Show All' to see all of them.</b></p>"))

                 # --- Modified Duplicate Check ---
                notes_found = False
                duplicates_df = pd.DataFrame() # Initialize empty
                if clear_duplicates_dd.value == 'No':
                    display_abbreviation_col = 'Abbreviation' # Use the display name
                
                    # Check if the column exists in the final DataFrame
                    if display_abbreviation_col in display_df_filtered_sorted.columns:
                        # Calculate the mask DIRECTLY on the DataFrame being filtered
                        duplicate_mask_final = display_df_filtered_sorted[display_abbreviation_col].duplicated(keep=False)
                
                        if duplicate_mask_final.any():
                            notes_found = True
                            # Apply the correctly indexed mask
                            duplicates_df = display_df_filtered_sorted[duplicate_mask_final].sort_values(by=['Abbreviation', 'Full Phrase'])
                
                            if not duplicates_df.empty:
                                # Group by the display name
                                dup_grouped = duplicates_df.groupby('Abbreviation')['Full Phrase'].apply(lambda names: f"<b>{names.name}</b> ({', '.join(names)})").tolist()
                                note_text = "Multiply defined abbreviations displayed: " + "; ".join(dup_grouped)
                                display(widgets.HTML(f"<p>ℹ️ {note_text}</p>"))
                        # No 'else' needed here for the .any() check unless you want a specific message when no duplicates are found
                
                    else:
                        # Use display/HTML for warnings within the Output widget
                        display(widgets.HTML(f"<p style='color:orange;'>Warning: '{display_abbreviation_col}' column not found for duplicate check.</p>"))
                # --- End of Modified Duplicate Check ---
                
                # --- Zero Usage Check (check column name consistency here too) ---
                display_usage_col = 'Usage'
                if display_usage_col in display_df_filtered_sorted.columns and 'Abbreviation' in display_df_filtered_sorted.columns: # Check both needed columns
                    zero_usage_df = display_df_filtered_sorted[display_df_filtered_sorted[display_usage_col] == 0]
                    if not zero_usage_df.empty:
                        all_zero_usage_abbrs = zero_usage_df['Abbreviation'].unique().tolist()
                        # Ensure duplicates_df is valid and has the 'Abbreviation' column before using it
                        zero_usage_abbrs_to_report = all_zero_usage_abbrs
                        if not duplicates_df.empty and 'Abbreviation' in duplicates_df.columns:
                            reported_duplicates = duplicates_df['Abbreviation'].unique()
                            zero_usage_abbrs_to_report = [abbr for abbr in all_zero_usage_abbrs if abbr not in reported_duplicates]
                
                        if zero_usage_abbrs_to_report:
                            notes_found = True
                            abbr_list_str = ", ".join([f"<b>{abbr}</b>" for abbr in zero_usage_abbrs_to_report]) # Use HTML bold
                            note_text = "Zero usage found for displayed abbreviations: " + abbr_list_str
                            display(widgets.HTML(f"<p>ℹ️ {note_text}</p>"))
                else:
                    # Check which column was missing for a more specific warning
                    missing_cols_zero = [col for col in [display_usage_col, 'Abbreviation'] if col not in display_df_filtered_sorted.columns]
                    display(widgets.HTML(f"<p style='color:orange;'>Warning: Column(s) '{', '.join(missing_cols_zero)}' not found for zero usage check.</p>"))

    # Update export text
    update_export_output()

# Function to update the export text area
def update_export_output(change=None):
    global display_df_filtered_sorted # This DataFrame has display names like 'Abbreviation'

    if display_df_filtered_sorted is None or display_df_filtered_sorted.empty:
         export_output_text.value = "No abbreviations selected."
    else:
        try:
            # --- ADDED: Rename columns back to original for the function ---
            # Create a copy to avoid modifying the global DataFrame used for display notes
            df_to_format = display_df_filtered_sorted.copy()

            # Define the mapping from display names back to original internal names
            # Ensure this matches the keys used in your format_abbreviations function
            reverse_column_map = {
                'Abbreviation': 'abbreviation',
                'Full Phrase': 'full_name',
                'Usage': 'usage_count',
                '% Abbr Matched': 'perc_abbr_matches',
                '% Words Matched': 'perc_words_matched'
                # Add any other columns if your format_abbreviations uses them
            }

            # Filter the map to only include columns actually present in the current display DataFrame
            existing_cols_to_rename = {k: v for k, v in reverse_column_map.items() if k in df_to_format.columns}

            # Rename the columns in the copied DataFrame
            df_to_format.rename(columns=existing_cols_to_rename, inplace=True)
            # --- END ADDED ---

            # Ensure format_abbreviations function is available in your environment
            # Pass the DataFrame with the original column names expected by the function
            formatted_output = format_abbreviations(df_to_format, format_type=export_format_dd.value)
            export_output_text.value = formatted_output

        except NameError:
            export_output_text.value = "Error: format_abbreviations function not defined."
        except Exception as format_e:
            # Provide more specific error if possible
            export_output_text.value = f"Error during formatting: {type(format_e).__name__} - {format_e}"

# --- Connect Callbacks to Widgets ---
# (Make sure this function is connected correctly)
# export_format_dd.observe(update_export_output, names='value')
# Also ensure update_export_output() is called at the end of update_results_display()

# Callback for Process Button
def on_process_button_clicked(b):
    global collected_df_raw, DEBUG
    input_text = input_text_area.value
    if not input_text:
        with results_output: clear_output(wait=True); print("Warning: Please enter text.")
        with results_info_output: clear_output(wait=True)
        collected_df_raw = pd.DataFrame()
        update_results_display()
        return

    reset_filters()
    process_button.disabled = True; process_button.description = "Processing..."
    with results_output: clear_output(wait=True); print("Collecting...")
    with results_info_output: clear_output(wait=True)

    try:
        # Ensure helper functions are available
        normalized_text = normalize_latex_math(input_text)
        collected_df_raw = collect_abbreviations(normalized_text, debug=DEBUG)
    except NameError as e:
         with results_output: clear_output(wait=True); print(f"Error: Function missing: {e}")
         collected_df_raw = pd.DataFrame()
    except Exception as e:
         with results_output: clear_output(wait=True); print(f"Error during collection: {e}")
         collected_df_raw = pd.DataFrame()
    finally:
        process_button.disabled = False; process_button.description = "Process Text and Extract Abbreviations"
        update_results_display()


# Function to reset filters to default values
def reset_filters():
    usage_filter_dd.value = 0
    abbr_match_filter_dd.value = 0.7
    words_match_filter_dd.value = 0.3
    clear_duplicates_dd.value = 'No'
    sort_dd.value = 'Abbreviation'

# Callback for Reset Button
def on_reset_button_clicked(b):
    reset_filters()
    update_results_display()

# Callback for Show All Button
def on_show_all_button_clicked(b):
    usage_filter_dd.value = 0
    abbr_match_filter_dd.value = 0.0
    words_match_filter_dd.value = 0.0
    clear_duplicates_dd.value = 'No'
    sort_dd.value = 'Abbreviation' # Also reset sort for consistency? Optional.
    update_results_display()


# --- Connect Callbacks to Widgets ---
process_button.on_click(on_process_button_clicked)
reset_button.on_click(on_reset_button_clicked)
show_all_button.on_click(on_show_all_button_clicked)

# Observe changes in filter/sort dropdown values
usage_filter_dd.observe(update_results_display, names='value')
abbr_match_filter_dd.observe(update_results_display, names='value')
words_match_filter_dd.observe(update_results_display, names='value')
clear_duplicates_dd.observe(update_results_display, names='value')
sort_dd.observe(update_results_display, names='value')

# Observe changes in export format dropdown
export_format_dd.observe(update_export_output, names='value')


# --- Display the final UI ---
# Run this in a Jupyter cell:
display(main_layout)

# %%
