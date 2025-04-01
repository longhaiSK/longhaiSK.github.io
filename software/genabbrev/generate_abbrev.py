import streamlit as st
import re
from datetime import datetime # Import datetime for current date example
#from streamlit_extras.keyboard_url import st_copy_to_clipboard
upper_greek_cmds = ['Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi', 'Sigma', 'Upsilon', 'Phi', 'Psi', 'Omega']

greek_map = {
    'alpha': 'a', 'beta': 'b', 'gamma': 'g', 'delta': 'd', 'epsilon': 'e',
    'zeta': 'z', 'eta': 'e', 'theta': 't', 'iota': 'i', 'kappa': 'k',
    'lambda': 'l', 'mu': 'm', 'nu': 'n', 'xi': 'x', 'omicron': 'o',
    'pi': 'p', 'rho': 'r', 'sigma': 's', 'tau': 't', 'upsilon': 'u',
    'phi': 'p', 'chi': 'c', 'psi': 'p', 'omega': 'o',
    'Gamma': 'g', 'Delta': 'd', 'Theta': 't', 'Lambda': 'l', 'Xi': 'x',
    'Pi': 'p', 'Sigma': 's', 'Upsilon': 'u', 'Phi': 'p', 'Psi': 'p', 'Omega': 'o'
}
   
import re
# import streamlit as st # Only if using st.error

def normalize_latex_math(text):
    """
    Preprocesses LaTeX text:
    1. Converts LaTeX inline math \( ... \) to $ ... $.
    2. Removes LaTeX comments (% to end of line), respecting \%.
    3. Removes preamble/end tags if \begin{document} is found.
    4. Adds space after opening curly braces ({).
    5. Adds space after lowercase LaTeX commands (\cmd) if not already present.
    6. Adds space after specific uppercase Greek commands (\Cmd) if not present.
    7. Cleans up extra blank lines and trims whitespace.
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
        if end_doc_index != -1 and len(processed_text) - end_doc_index < 30:
            processed_text = processed_text[:end_doc_index]

        # --- Spacing Adjustments ---
        # 4. Add space after {
        processed_text = re.sub(r'\{', r'{ ', processed_text)

        # 5. Add space after lowercase commands (\cmd) if not followed by space
        processed_text = re.sub(r'(\\[a-z]+)(?!\s)', r'\1 ', processed_text)

        # --- NEW STEP 6 ---
        # 6. Add space after specific uppercase Greek commands (\Cmd) if not followed by space
        upper_greek_cmds = [
            'Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi',
            'Sigma', 'Upsilon', 'Phi', 'Psi', 'Omega'
            ]
        # Create pattern part like: Gamma|Delta|Theta...
        pattern_part = '|'.join(upper_greek_cmds)
        # Regex captures (\ + one of the commands), checks no following whitespace
        pattern_upper = rf'(\\ (?:{pattern_part}))(?!\s)'
        # Replacement adds back captured command (group 1) + space
        processed_text = re.sub(pattern_upper, r'\1 ', processed_text)
        # --- End NEW STEP 6 ---

        # 7. Clean up potential excessive blank lines
        processed_text = re.sub(r'(\n\s*){2,}', '\n', processed_text)
        # Remove leading/trailing whitespace from the whole result
        processed_text = processed_text.strip()

        # Optional: Collapse multiple spaces (might affect deliberate spacing)
        # processed_text = re.sub(r'[ \t]+', ' ', processed_text)

        return processed_text

    except Exception as e:
        error_message = f"Error during LaTeX text preprocessing: {e}"
        try:
            import streamlit as st
            st.error(error_message)
        except ImportError:
            print(error_message)
        return text # Return original text on error    

def get_abbr_repr_letters(abbr_string):
    """Parses abbreviation string, returns list of representative lowercase letters."""
    representative_letters = []
    findings = re.findall(r'\\([a-zA-Z]+)|([a-zA-Z])', abbr_string)
    for greek_cmd, any_letter in findings:
        if greek_cmd:
            if greek_cmd in greek_map: representative_letters.append(greek_map[greek_cmd])
        elif any_letter: representative_letters.append(any_letter.lower())
    return representative_letters
import re # Make sure re is imported

# Assume greek_map and get_abbr_repr_letters are defined above this point

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
        abbr_letters = get_abbr_repr_letters(abbr_string)

        if debug: # Print statements if needed
             print(text)
             print(f"\n---\nCandidate Found:")
             # print(match) # Raw match tuple if needed
             print(f"  Captured Abbr String: '{abbr_string}'")
             print(f"  Generated abbr_letters: {abbr_letters}")
             print(f"  Preceding Text for Split: '{words_before_abbr_text}'")
             print(f"  Split words_ahead: {words_ahead}")

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

    if debug: print(f"--- Debugging End ---\nFinal Dict: {abbreviation_dict}")
    return abbreviation_dict
def get_sort_key_from_abbr(abbr_string):
    """Generates a lowercase string key for sorting abbreviations."""
    repr_letters = get_abbr_repr_letters(abbr_string)
    sort_key = "".join(repr_letters).lower()
    if not sort_key:
         fallback_key = re.sub(r"^[^\w]+", "", abbr_string.lower())
         return fallback_key
    return sort_key

 

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


# --- Define Default Example Text ---
# Using r""" allows multi-line string and handles backslashes well
# $\frac{\gamma}{Z}$-residuals ($\frac{\gamma}{Z}$R)
example_text = r"""
\begin{document}
The full name and abbrievation can contain greek symbols, for example, $\beta$-\( Z \)-residuals ($\beta$$Z$R), or $\gamma$-\( Z \)-residuals ($\gammaZ$R).

The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time (AFT), or \textbf{Time-Constant (TC) Data} will be caught. 

The citations and explanations in brackets will be omitted, for example, this one (Wu et al. 2024), regression coeficcient ($\beta$). This is not an abbreviation (acronym) either. %The comment text (CT) will be omitted.

Paste your \LaTex text (LT) and enjoy the app. 

\end{document}

""".strip()



import streamlit as st
import re
from datetime import datetime
# Assuming your functions (normalize_latex_math, extract_abbreviations, format_abbreviations, etc.)
# and the example_text variable are defined above this point.

st.set_page_config(layout="wide")
st.title(r"Extracting Abbreviations from $\LaTeX$ Text")
# --- Initialize Session State (Add 'processed_url_param') ---
if 'abbreviations_dict' not in st.session_state:
    st.session_state.abbreviations_dict = None
if 'last_input_text' not in st.session_state:
    st.session_state.last_input_text = example_text
if 'processed_url_param' not in st.session_state:
     st.session_state.processed_url_param = False # Flag to process URL text only once

# --- Handle URL Query Parameter (Place this *before* UI rendering) ---
# Use "text" as the parameter name, default to None if not present
url_text_param = st.query_params.get("text", None)

if url_text_param and not st.session_state.processed_url_param:
    # If param exists AND we haven't processed it automatically yet
    print(f"Processing text from URL parameter: {url_text_param[:50]}...") # Debug print
    st.session_state.last_input_text = url_text_param # Pre-fill text area state
    try:
        # Use a spinner just like the button press
        with st.spinner("Processing text from URL..."):
             normalized_text = normalize_latex_math(url_text_param)
             # Run extraction and store result directly in session state
             st.session_state.abbreviations_dict = extract_abbreviations(normalized_text)
             st.session_state.processed_url_param = True # Mark as processed
    except Exception as e:
        st.error(f"Error processing text from URL: {e}")
        st.session_state.abbreviations_dict = None
        st.session_state.processed_url_param = True # Mark as processed even if error
elif not url_text_param:
     # If no URL text parameter on this run, reset the flag
     # Allows reprocessing if user navigates away and back without param
     st.session_state.processed_url_param = False

# --- Create two main columns for side-by-side layout ---
col_input, col_output = st.columns([1.5,1]) # Create two equal-width columns

# --- Column 1: Input Area ---
with col_input:
    st.subheader("Paste your text")
    input_text = st.text_area(
        label="input_text_main",
        label_visibility="collapsed",
        value=st.session_state.last_input_text,
        height=350,  # Adjust height as needed for side-by-side view
        placeholder="Paste your text here...",
        key="input_text_area"
    )
    st.caption("Privacy note: this app does not save your text and only serves your need. Latex code is allowed.")

    # --- Use THREE columns in ONE row for Button, Label, Selector ---
    # Adjust the ratios as needed for desired visual spacing
    sub_col_label, sub_col_widget, sub_col_btn = st.columns([0.5, 2, 3])


    with sub_col_label:
        # Place label text in the second sub-column
        # Using markdown allows potential styling. Adjust padding/margin for vertical alignment.
        st.markdown("<div style='margin-top: 0.6rem; text-align: left;'>Format:</div>", unsafe_allow_html=True)
        # Simpler alternative: st.text("Format:") - may not align vertically as well

    with sub_col_widget:
        # Place selectbox in the third sub-column (hide its own label)
        selected_format = st.selectbox(
            label="format_select_internal_label", # Internal label, not displayed
            label_visibility="collapsed", # Hide label above the widget
            options=['plain', 'tabular', 'nomenclature'],
            index=0,  # Default to 'tabular'
            key='format_selector', # Key allows state to persist
            help="Select the format for the abbreviation list output."
        )
    with sub_col_btn:
        # Place button in the first sub-column
        extract_pressed = st.button("Extract Abbreviations", type="primary", use_container_width=True)

    # Processing Logic (triggered by button state)
    if "first_run_done" not in st.session_state:
        st.session_state.first_run_done = True  # Mark that the first run has happened

    if extract_pressed or st.session_state.first_run_done: # Check the state of the button variable
        if input_text:
            with st.spinner("Processing..."):
                normalized_text = normalize_latex_math(input_text)
                st.session_state.abbreviations_dict = extract_abbreviations(normalized_text)
        else:
            st.warning("Please enter some text in the input box above.")
            st.session_state.abbreviations_dict = None

    # Update session state for input text (placement fine here)
    if input_text != st.session_state.last_input_text:
        st.session_state.last_input_text = input_text
        

# --- Column 2: Output Area (Modified Layout) ---
with col_output:
    # --- Output Header and Selector (Now Vertical) ---
    st.subheader(f"Formatted Abbreviations") # Directly under col_output

    # --- Prepare Output Value ---
    output_value_placeholder = "Output will appear here after clicking 'Extract Abbreviations'."
    formatted_output_display = output_value_placeholder
    if st.session_state.abbreviations_dict is not None:
        if not st.session_state.abbreviations_dict:
             formatted_output_display = "No abbreviations found in the text."
        else:
            formatted_output = format_abbreviations(st.session_state.abbreviations_dict, selected_format)
            if formatted_output:
                formatted_output_display = formatted_output
            else:
                formatted_output_display = "Formatting resulted in empty output."

    # --- Display Output Text Area ---
    st.text_area(
        label="output_text_main",
        label_visibility="collapsed",
        value=formatted_output_display,
        height=350,  # Explicit Height (Match input column)
        help="Copy the output from this box.",
        key="output_text_area"
    )
   
   # --- Footer (outside columns) ---
st.markdown("---")

st.caption("Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada")
# current_date_param = st.query_params.get('current_date', 'N/A')
# st.caption(f"Current date (from URL param 'current_date', if provided): {current_date_param}")
# st.caption(f"Actual current server time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} (CST)") # Indicate CST
# st.caption("Location context: Saskatoon, SK, Canada")
 
