import streamlit as st
import re
from datetime import datetime # Import datetime for current date example
#from streamlit_extras.keyboard_url import st_copy_to_clipboard

# (Same as before - greek_map, get_abbr_repr_letters, extract_abbreviations,
#  escape_latex, format_abbreviations)

def normalize_latex_math(text):
    """
    Converts LaTeX inline math \( ... \) to $ ... $.
    Handles optional space after \( and before \).
    Strips leading/trailing space within the math content.
    """
    # Regex:
    # \\\(  : literal \(
    # \s* : zero or more whitespace chars
    # (.*?) : non-greedily capture content (group 1)
    # \s* : zero or more whitespace chars
    # \\\)  : literal \)
    # Replacement uses group 1, strips it, and wraps with $
    try:
        # Using a lambda function for replacement to strip internal whitespace
        normalized_text = re.sub(
            r'\\\(\s*(.*?)\s*\\\)',
            lambda match: f"${match.group(1).strip()}$",
            text
        )
        return normalized_text
    except Exception as e:
        st.error(f"Error during LaTeX math normalization: {e}")
        return text # Return original text on error
        
greek_map = {
    'alpha': 'a', 'beta': 'b', 'gamma': 'g', 'delta': 'd', 'epsilon': 'e',
    'zeta': 'z', 'eta': 'e', 'theta': 't', 'iota': 'i', 'kappa': 'k',
    'lambda': 'l', 'mu': 'm', 'nu': 'n', 'xi': 'x', 'omicron': 'o',
    'pi': 'p', 'rho': 'r', 'sigma': 's', 'tau': 't', 'upsilon': 'u',
    'phi': 'p', 'chi': 'c', 'psi': 'p', 'omega': 'o',
    'Gamma': 'g', 'Delta': 'd', 'Theta': 't', 'Lambda': 'l', 'Xi': 'x',
    'Pi': 'p', 'Sigma': 's', 'Upsilon': 'u', 'Phi': 'p', 'Psi': 'p', 'Omega': 'o'
}

def get_abbr_repr_letters(abbr_string):
    representative_letters = []
    findings = re.findall(r'\\([a-zA-Z]+)|([A-Z])', abbr_string)
    for greek_cmd, upper_letter in findings:
        if greek_cmd:
            if greek_cmd in greek_map:
                representative_letters.append(greek_map[greek_cmd])
        elif upper_letter:
            representative_letters.append(upper_letter.lower())
    return representative_letters
    
    
def get_abbr_repr_letters(abbr_string):
        """
        Parses an abbreviation string containing potential LaTeX Greek letters
        and ALSO now regular upper/lower case letters.
        Returns a list of representative lowercase chars.
        e.g., "$\alpha$-SP" -> ['a', 's', 'p']
        e.g., "$u$-RN" -> ['u', 'r', 'n'] # Assumes $u$ contributes 'u'
        e.g., "CPU" -> ['c', 'p', 'u']
        """
        representative_letters = []
        # Pattern finds \command OR single Letter (Upper or Lower)
        # Captures command name in group 1 OR the letter in group 2
        # MODIFIED REGEX to capture [a-zA-Z]
        findings = re.findall(r'\\([a-zA-Z]+)|([a-zA-Z])', abbr_string)

        for greek_cmd, any_letter in findings:
            if greek_cmd: # Matched \command (e.g., greek_cmd == 'alpha')
                if greek_cmd in greek_map:
                    representative_letters.append(greek_map[greek_cmd]) # Add lowercase greek representation
                # Optional: Add handling for non-greek commands if needed
            elif any_letter: # Matched single letter (e.g., any_letter == 'S' or 'u')
                representative_letters.append(any_letter.lower()) # Add lowercase representation

        return representative_letters


def extract_abbreviations(text, require_first_last_match=True):
    pattern = re.compile(r'((?:[\w\-\$\\]+\s+){1,10})\(([A-Za-z\-\$\\]{2,})\)')
    matches = pattern.findall(text)
    abbreviation_dict = {}
    # ...(rest of the function remains the same)...
    for match in matches:
        words_before_abbr_text = match[0].strip()
        words_ahead = [word for word in re.split(r'\s+|(?<=-)(?=[A-Za-z])', words_before_abbr_text) if word]
        abbr_string = match[1]
        abbr_letters = get_abbr_repr_letters(abbr_string)
        num_abbr_letters = len(abbr_letters)

        if not abbr_letters or not words_ahead or num_abbr_letters == 0: continue
        match_indices = [-1] * num_abbr_letters
        unmatched_abbr_indices = set(range(num_abbr_letters))
        for i, word in enumerate(reversed(words_ahead)):
            original_idx = len(words_ahead) - 1 - i
            if not unmatched_abbr_indices: break
            effective_char = None
            m_dollar = re.match(r'\$\\([a-zA-Z]+)', word)
            if m_dollar and m_dollar.group(1) in greek_map: effective_char = greek_map[m_dollar.group(1)]
            else:
                m_slash = re.match(r'\\([a-zA-Z]+)', word)
                if m_slash and m_slash.group(1) in greek_map: effective_char = greek_map[m_slash.group(1)]
                else:
                    m_first_letter = re.search(r'[a-zA-Z]', word)
                    if m_first_letter: effective_char = m_first_letter.group(0).lower()
            if effective_char is not None:
                best_match_abbr_idx = -1
                for abbr_idx in sorted(list(unmatched_abbr_indices), reverse=True):
                    if effective_char == abbr_letters[abbr_idx]:
                        best_match_abbr_idx = abbr_idx
                        break
                if best_match_abbr_idx != -1:
                    match_indices[best_match_abbr_idx] = original_idx
                    unmatched_abbr_indices.remove(best_match_abbr_idx)
        successful_match_indices = [idx for idx in match_indices if idx != -1]
        if not successful_match_indices: continue
        valid_match = True
        if require_first_last_match:
            if match_indices[0] == -1 or match_indices[num_abbr_letters - 1] == -1: valid_match = False
        if valid_match:
            min_idx_py = min(successful_match_indices)
            max_idx_py = max(successful_match_indices)
            if min_idx_py <= max_idx_py:
                full_phrase_words_slice = words_ahead[min_idx_py : max_idx_py + 1]
                full_name = ''.join(word if i == 0 else (' ' + word if not full_phrase_words_slice[i - 1].endswith('-') else word)
                                    for i, word in enumerate(full_phrase_words_slice))
                abbreviation_dict[abbr_string] = full_name
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


# --- Define Default Example Text ---
# Using r""" allows multi-line string and handles backslashes well
example_text = r"""This is an example of an input text  (EIT). In this paper, we propose utilizing $\beta$-\( Z \)-residuals ($\beta$$Z$R) to diagnose Cox PH models. The recent studies by Li et al. 2021 \cite{LiLonghai2021Mdfc} and Wu et al. 2024 \cite{WuTingxuan2024Zdtf} introduced the concept of randomized survival probabilities (RSP) to define Z-residuals for diagnosing model assumptions in accelerated failure time (AFT) and shared frailty models. The RSP approach involves replacing the survival probability of a censored failure time (SPCFT) with $u$ random numbers ($u$RN) between 0 and the survival probability of the censored time (SPCT) \cite{WuTingxuan2024Zdtf}."""

def get_abbreviation_output(input_text_string):
    """
    Processes input text to extract abbreviations and returns them
    formatted as a string using the default 'tabular' format.

    Args:
        input_text_string (str): The text to process.

    Returns:
        str: The formatted string of abbreviations (defaulting to tabular),
             or an error/info message if no text provided or no abbreviations found.
    """
    # Default format chosen from our Streamlit app setup
    default_format_type = 'plain'

    if not input_text_string:
        return "Input text cannot be empty."

    try:
        # 1. Normalize LaTeX math input (e.g., \(...\) -> $...$)
        normalized_text = normalize_latex_math(input_text_string)

        # 2. Extract abbreviations using the core logic
        #    (This assumes extract_abbreviations uses require_first_last_match=True by default)
        abbreviations_dict = extract_abbreviations(normalized_text)

        # 3. Handle cases where no abbreviations are found
        if not abbreviations_dict:
            return "No abbreviations found in the text."

        # 4. Format the results using the default format type
        formatted_output = format_abbreviations(abbreviations_dict, default_format_type)

        # 5. Return the result (or a message if formatting failed)
        return formatted_output if formatted_output else "Formatting resulted in empty output."

    except Exception as e:
        # Basic error handling
        # Consider more specific logging or error handling if needed
        print(f"Error processing text: {e}") # Log error to console/logs
        return f"An error occurred during processing."




import streamlit as st
import re
from datetime import datetime
# Assuming your functions (normalize_latex_math, extract_abbreviations, format_abbreviations, etc.)
# and the example_text variable are defined above this point.

st.set_page_config(layout="wide")
st.title(r"Extracting Abbreviations from $\LaTeX$ Source Text")
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

    # sub_col_btn, sub_col_select = st.columns([1, 1]) # Equal width for button and selector

    # with sub_col_btn:
    #     # Button and its logic now in the nested column
    #     extract_pressed = st.button("Extract Abbreviations", type="primary", use_container_width=True)

    # with sub_col_select:
    #     # # Selector now in the nested column
    #     # selected_format = st.selectbox(
    #     #     "Select Output Format:", # Slightly revised label
    #     #     options=['plain', 'tabular', 'nomenclature'],
    #     #     index=0,  # Default to 'tabular'
    #     #     key='format_selector' # Key allows state to persist
    #     # )
    #     selected_format = st.selectbox(
    #     label="format_select_internal_label", # Internal label, not displayed
    #     options=['plain', 'tabular', 'nomenclature'],
    #     index=0,  # Default to 'plain'
    #     key='format_selector', # Key allows state to persist
    #     help="Select the format for the abbreviation list output.", # ADDED help tooltip
    #     label_visibility="collapsed" # ADDED this to hide the label
    # )
    # --- End Nested Columns ---

    # Processing Logic (triggered by button state)
    if extract_pressed: # Check the state of the button variable
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
    st.subheader(f"List of Abbreviations") # Directly under col_output

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
    
    

# Note: Copy button logic was removed previously due to issues.

# --- Footer (outside columns) ---
st.markdown("---")

st.caption("Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada")
# current_date_param = st.query_params.get('current_date', 'N/A')
# st.caption(f"Current date (from URL param 'current_date', if provided): {current_date_param}")
# st.caption(f"Actual current server time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} (CST)") # Indicate CST
# st.caption("Location context: Saskatoon, SK, Canada")