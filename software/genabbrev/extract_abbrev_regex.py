#!/usr/bin/env python
# coding: utf-8

# In[5]:


import streamlit as st
import re
from datetime import datetime # Import datetime for current date example
import pandas as pd


# In[53]:


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

import re

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
        
        # 7. Remove one or more whitespace characters (\s+) immediately after a dollar sign ($) (Moved Step)
        #processed_text = re.sub(r'\$\s+', '$', processed_text)
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


# In[ ]:


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


# In[66]:


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

def extract_abbreviations(text, match_threshold=0.7, debug=True):
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
        r'(?:[\w\-\$\\\{\}]+[ \t]+){1,10}' # Words separated by space/tab on same line
        r')'                      # End Group 1
        r'\(\s*'                  # Literal opening parenthesis
        r'('                      # Start Group 2: Abbreviation
        r'(?=.*[A-Z\\\$])'       # Positive lookahead
        r'[\w\s\$\-\\\{\}]+'   # Allowed characters
        r')'                      # End Group 2 capture
        r'\s*\)'                  # Literal closing parenthesis
    )
    
    #
    pattern = r'((?:[\w\\\$\{\}]+[ -]+){1,10}(?:[\w\\\$\{\}]+)[ -]?)\(([^\(\)]*[A-Z]+[^\(\)]*)\)'
    #matches = pattern.findall(text)
    matches = re.findall(pattern, text)
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


# In[7]:


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


    


# In[70]:


# example_text
example_text = r"""Paste your latex text (LT) and enjoy the app (ETA). There is no limitation of the length of text. 

What is regarded as abbreviations (RA):

The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time(AFT), or \textbf{Time-Constant (TC) Data}. The full definitions and abbrievations can contain greek symbols, for example,  $\alpha$-synclein protein ($\alpha$-SP), $\frac{\gamma}{Z}$-residuals($\frac{\gamma}{Z}$-R. The first letters of latex commands will be used to compare to the abbreviations.

What is desregarded as abbreviations (DA):

Citations and explanations in brackets will be omitted, eg. this one (Li et al. 2025), and this ($\beta$). There is no abbreviations (acronym) here either. %This abbreviation, comment text (CT) or the line starting with % will be omitted. The $t$ in $f(t)$ is not an abbreviation too. 

Note: the extraction is not perfect as it cannot accommodate all possible abbreviations and may include those you don't want. Modify the results as necessary.

"""
#print(example_text)
#extract_abbreviations(normalize_latex_math(example_text),debug=False)


# In[56]:


# normalize_latex_math Example with example_text
#normtext = normalize_latex_math(example_text)
#print(normtext)


# In[62]:


#extract_abbreviations(normalize_latex_math(example_text),debug=False)

