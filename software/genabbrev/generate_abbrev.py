import streamlit as st
import re
from datetime import datetime
# import urllib.parse # Needed if you construct URLs with parameters elsewhere

# ==============================================================================
# 1. Core Logic Functions
# ==============================================================================

greek_map = {
    'alpha': 'a', 'beta': 'b', 'gamma': 'g', 'delta': 'd', 'epsilon': 'e',
    'zeta': 'z', 'eta': 'e', 'theta': 't', 'iota': 'i', 'kappa': 'k',
    'lambda': 'l', 'mu': 'm', 'nu': 'n', 'xi': 'x', 'omicron': 'o',
    'pi': 'p', 'rho': 'r', 'sigma': 's', 'tau': 't', 'upsilon': 'u',
    'phi': 'p', 'chi': 'c', 'psi': 'p', 'omega': 'o',
    'Gamma': 'g', 'Delta': 'd', 'Theta': 't', 'Lambda': 'l', 'Xi': 'x',
    'Pi': 'p', 'Sigma': 's', 'Upsilon': 'u', 'Phi': 'p', 'Psi': 'p', 'Omega': 'o'
}

def normalize_latex_math(text):
    """
    Preprocesses LaTeX text:
    1. Converts LaTeX inline math \( ... \) to $ ... $.
    2. Removes LaTeX comments (% to end of line), respecting \%.
    3. Removes preamble if \begin{document} is found.
    4. Cleans up extra blank lines and trims whitespace.
    """
    if not isinstance(text, str):
        print("Warning: Input to normalize_latex_math was not a string.")
        return text

    processed_text = text
    try:
        processed_text = re.sub(r'\\\(\s*(.*?)\s*\\\)', lambda match: f"${match.group(1).strip()}$", processed_text)
        processed_text = re.sub(r'(?<!\\)%.*$', '', processed_text, flags=re.MULTILINE)
        begin_doc_marker = r'\begin{document}'
        begin_doc_index = processed_text.find(begin_doc_marker)
        if begin_doc_index != -1:
            processed_text = processed_text[begin_doc_index + len(begin_doc_marker):]
        # Also remove \end{document} if present at the end
        end_doc_marker = r'\end{document}'
        end_doc_index = processed_text.rfind(end_doc_marker)
        if end_doc_index != -1:
             # Check if it's near the end before stripping
             if len(processed_text) - end_doc_index < 20: # Heuristic check
                 processed_text = processed_text[:end_doc_index]

        processed_text = re.sub(r'(\n\s*){2,}', '\n', processed_text)
        processed_text = processed_text.strip()
        return processed_text
    except Exception as e:
        error_message = f"Error during LaTeX text preprocessing: {e}"
        try:
            import streamlit as st; st.error(error_message)
        except ImportError: print(error_message)
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

def get_sort_key_from_abbr(abbr_string):
    """Generates a lowercase string key for sorting abbreviations."""
    repr_letters = get_abbr_repr_letters(abbr_string)
    sort_key = "".join(repr_letters).lower()
    if not sort_key:
         fallback_key = re.sub(r"^[^\w]+", "", abbr_string.lower())
         return fallback_key
    return sort_key

def extract_abbreviations(text, require_first_last_match=True, debug=False):
    """Extracts abbreviations defined as (Abbr) following their definition."""
    # Pattern allows spaces inside abbr, requires lookahead for uppercase/$/\
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
        # ... (inner logic as provided in your last code block, using correct full_name join) ...
        words_before_abbr_text = match[0].strip()
        words_ahead = [word for word in re.split(r'\s+|(?<=-)(?=[A-Za-z])', words_before_abbr_text) if word]
        abbr_string = match[1].strip()
        abbr_letters = get_abbr_repr_letters(abbr_string)

        if debug: # Print statements if needed
             print(f"\n---\nCandidate Found:")
             print(f"  Captured Abbr String: '{abbr_string}'")
             print(f"  Generated abbr_letters: {abbr_letters}")
             print(f"  Preceding Text for Split: '{words_before_abbr_text}'")
             print(f"  Split words_ahead: {words_ahead}")

        num_abbr_letters = len(abbr_letters)
        if not abbr_letters or not words_ahead or num_abbr_letters == 0: continue

        match_indices = [-1] * num_abbr_letters
        unmatched_abbr_indices = set(range(num_abbr_letters))

        for i, word in enumerate(reversed(words_ahead)):
            original_idx = len(words_ahead) - 1 - i
            if not unmatched_abbr_indices: break
            effective_char = None
            m_first_letter = re.search(r'[a-zA-Z]', word)
            if m_first_letter: effective_char = m_first_letter.group(0).lower()

            if debug and effective_char is not None: print(f"  Word: '{word}' (idx {original_idx}), Effective Char: '{effective_char}'")

            if effective_char is not None:
                best_match_abbr_idx = -1
                for abbr_idx in sorted(list(unmatched_abbr_indices), reverse=True):
                    if effective_char == abbr_letters[abbr_idx]: best_match_abbr_idx = abbr_idx; break
                if best_match_abbr_idx != -1:
                    if debug: print(f"    -> Matched letter '{abbr_letters[best_match_abbr_idx]}' at abbr_idx {best_match_abbr_idx}")
                    match_indices[best_match_abbr_idx] = original_idx
                    unmatched_abbr_indices.remove(best_match_abbr_idx)

        successful_match_indices = [idx for idx in match_indices if idx != -1]
        if debug: print(f"  Successful match indices: {successful_match_indices}")
        if not successful_match_indices: continue

        valid_match = True
        if require_first_last_match:
            if match_indices[0] == -1 or match_indices[num_abbr_letters - 1] == -1:
                valid_match = False
                if debug: print(f"  Validation Failed: First or last letter not matched (Indices: {match_indices})")

        if valid_match:
            min_idx_py = min(successful_match_indices)
            max_idx_py = max(successful_match_indices)
            if min_idx_py <= max_idx_py:
                full_phrase_words_slice = words_ahead[min_idx_py : max_idx_py + 1]
                # Use the join logic that handles hyphens correctly
                full_name = ''.join(word if i == 0 else (' ' + word if not full_phrase_words_slice[i - 1].endswith('-') else word)
                                    for i, word in enumerate(full_phrase_words_slice))
                if debug: print(f"  Validation Passed. Storing: '{abbr_string}': '{full_name}'")
                abbreviation_dict[abbr_string] = full_name
            elif debug: print(f"  Skipping: min_idx > max_idx issue.")
        elif debug: print(f"  Skipping: Match deemed invalid.")

    if debug: print(f"--- Debugging End ---\nFinal Dict: {abbreviation_dict}")
    return abbreviation_dict

# --- UPDATED format_abbreviations FUNCTION ---
def format_abbreviations(abbreviations_dict, format_type):
    """Formats the extracted abbreviations based on the specified type. Sorts alphabetically."""
    if not abbreviations_dict: return "No abbreviations found."

    try:
        sorted_items = sorted(
            abbreviations_dict.items(),
            key=lambda item: get_sort_key_from_abbr(item[0])
        )
    except Exception as e:
        try: import streamlit as st; st.error(f"Error sorting: {e}")
        except ImportError: print(f"Error sorting: {e}")
        sorted_items = abbreviations_dict.items()

    if format_type == "nomenclature":
        latex_output = "\\usepackage{nomencl}\n\\makenomenclature\n"
        for abbr, full_name in sorted_items:
            latex_output += f"\\nomenclature{{{abbr}}}{{{full_name}}}\n"
        return latex_output
    elif format_type == "tabular":
        latex_output = "\\begin{tabular}{ll}\n\\hline\n\\textbf{Abbreviation} & \\textbf{Full Name} \\\\\n\\hline\n"
        for abbr, full_name in sorted_items:
            latex_output += f"{abbr} & {full_name} \\\\\n"
        latex_output += "\\hline\n\\end{tabular}\n"
        return latex_output
    else: # Plain format - CHANGED TO USE NEWLINES
        output_lines = []
        for abbr, full_name in sorted_items:
            output_lines.append(f"{abbr}: {full_name}") # Format each entry
        return "\n".join(output_lines) # Join the list with newline characters

# --- UPDATED EXAMPLE TEXT ---
example_text = r"""
\begin{document}
The full name and abbrievation can contain equations, for example, 
$\alpha$-\( Z \)-residuals ($\alphaZ$R), or 
$\beta$-\( Z \)-residuals ($\beta$$Z$R), or
$\gamma$-\( Z \)-residuals ($\gamma Z$R).

The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time (AFT) will be caught. 

The citations and explanations in brackets, for example, this one (Wu et al. 2024) and that one (example),  will be omitted. %The comment text (CT) will be omitted.

Paste your \LaTex text (LT) and enjoy the app. 
\end{document}
""".strip()


# ==============================================================================
# 2. Streamlit Interface Code
# ==============================================================================

st.set_page_config(layout="wide")
st.title(r"Extracting Abbreviations from $\LaTeX$ Text")

# --- Initialize Session State ---
if 'abbreviations_dict' not in st.session_state:
    st.session_state.abbreviations_dict = None
if 'last_input_text' not in st.session_state:
    st.session_state.last_input_text = example_text # Use updated example text
if 'processed_url_param' not in st.session_state:
     st.session_state.processed_url_param = False

# --- Handle URL Query Parameter ---
# ... (URL handling code remains the same) ...
url_text_param = st.query_params.get("text", None)
if url_text_param and not st.session_state.processed_url_param:
    st.session_state.last_input_text = url_text_param
    try:
        with st.spinner("Processing text from URL..."):
             normalized_text = normalize_latex_math(url_text_param)
             st.session_state.abbreviations_dict = extract_abbreviations(normalized_text, debug=False)
             st.session_state.processed_url_param = True
    except Exception as e:
        st.error(f"Error processing text from URL: {e}")
        st.session_state.abbreviations_dict = None
        st.session_state.processed_url_param = True
elif not url_text_param:
     st.session_state.processed_url_param = False


# --- Create two main columns ---
col_input, col_output = st.columns([1.5, 1])

# --- Column 1: Input Area ---
# ... (Input column code remains the same, including sub-columns for controls) ...
with col_input:
    st.subheader("Paste your text")
    input_text_value = st.session_state.get("last_input_text", "")
    input_text = st.text_area(
        label="input_text_main", label_visibility="collapsed", value=input_text_value,
        height=350, placeholder="Paste your text here...", key="input_text_area"
    )
    st.caption("Privacy note: this app does not save your text and only serves your need. Latex code is allowed.")
    sub_col_label, sub_col_widget, sub_col_btn = st.columns([0.5, 2, 3])
    with sub_col_label:
        st.markdown("<div style='margin-top: 0.6rem; text-align: left;'>Format:</div>", unsafe_allow_html=True)
    with sub_col_widget:
        selected_format = st.selectbox(
            label="format_select_internal_label", label_visibility="collapsed",
            options=['plain', 'tabular', 'nomenclature', 'Rendered LaTeX'], index=0,
            key='format_selector', help="Select the format for the abbreviation list output."
        )
    with sub_col_btn:
        extract_pressed = st.button("Extract Abbreviations", type="primary", use_container_width=True)

    if extract_pressed:
        current_text_in_box = st.session_state.get("input_text_area", "")
        if current_text_in_box:
            with st.spinner("Processing..."):
                 normalized_text = normalize_latex_math(current_text_in_box)
                 st.session_state.abbreviations_dict = extract_abbreviations(normalized_text, debug=False)
                 st.session_state.processed_url_param = (current_text_in_box == url_text_param) if url_text_param else False
        else:
            st.warning("Please enter some text in the input box above.")
            st.session_state.abbreviations_dict = None
            st.session_state.processed_url_param = False if url_text_param else False

    current_text_in_box = st.session_state.get("input_text_area", "")
    if current_text_in_box != st.session_state.last_input_text:
         st.session_state.last_input_text = current_text_in_box


# --- Column 2: Output Area ---
# ... (Output column code remains the same, using the updated format_abbreviations) ...
with col_output:
    current_format_selection = st.session_state.get('format_selector', 'plain')
    output_value_placeholder = "Output will appear here after clicking 'Extract Abbreviations' or providing text via URL."
    formatted_output_display = output_value_placeholder
    raw_latex_source_for_rendering = None

    if st.session_state.abbreviations_dict is not None:
        if not st.session_state.abbreviations_dict:
            formatted_output_display = "No abbreviations found in the text."
        else:
            format_to_generate = 'tabular' if current_format_selection == 'Rendered LaTeX' else current_format_selection
            formatted_output = format_abbreviations(st.session_state.abbreviations_dict, format_to_generate) # Will use updated plain format logic
            if formatted_output:
                formatted_output_display = formatted_output
                if current_format_selection == 'Rendered LaTeX':
                     raw_latex_source_for_rendering = formatted_output
            else:
                formatted_output_display = "Formatting resulted in empty output."

    if current_format_selection == 'Rendered LaTeX':
        st.subheader("Rendered Output (Tabular Format)")
        st.markdown("---")
        if raw_latex_source_for_rendering and raw_latex_source_for_rendering not in [output_value_placeholder, "No abbreviations found in the text.", "Formatting resulted in empty output."]:
             st.latex(raw_latex_source_for_rendering)
             st.caption("Note: Rendering uses KaTeX. Complex layouts or packages may not display perfectly.")
             with st.expander("Show Raw LaTeX Source (for copying)"):
                 st.text_area(label="raw_latex_output_hidden", label_visibility="collapsed",value=raw_latex_source_for_rendering, height=150, key="raw_latex_source_output")
        else:
             st.info(formatted_output_display)
    else:
        st.subheader(f"Formatted Output ({current_format_selection})")
        st.markdown("---")
        st.text_area(label="output_text_main", label_visibility="collapsed",value=formatted_output_display, height=350,help="Copy the output from this box.", key="output_text_area")

#
# Note: Copy button logic was removed previously due to issues.

# --- Footer (outside columns) ---
st.markdown("---")

st.caption("Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada")
# current_date_param = st.query_params.get('current_date', 'N/A')
# st.caption(f"Current date (from URL param 'current_date', if provided): {current_date_param}")
# st.caption(f"Actual current server time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} (CST)") # Indicate CST
# st.caption("Location context: Saskatoon, SK, Canada")
