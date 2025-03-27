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


# --- Streamlit Interface ---

st.set_page_config(layout="wide")
st.title("Extracting Abbreviations for Your Papers")
#st.markdown("Enter text below: ")

# Initialize session state
if 'abbreviations_dict' not in st.session_state:
    st.session_state.abbreviations_dict = None
# Initialize last_input_text with example if not already set
if 'last_input_text' not in st.session_state:
    st.session_state.last_input_text = example_text # <<< Set default example here

# Text input area - Value defaults to example text on first load
st.subheader("Paste your text")

# Modify st.text_area to remove/hide the built-in label
input_text = st.text_area(
    label="input_text_main", # Provide a unique label string for internal use/accessibility
    label_visibility="collapsed", # Hide the label visually
    value=st.session_state.last_input_text, # Uses session state value
    height=150,
    placeholder="Paste your text here...",
    key="input_text_area"
)
st.caption("Privacy note: this app does not save your text and only serves your need. Latex code is allowed.")
# Update session state whenever the text area changes
# This ensures if user types something, it's remembered over the default
if input_text != st.session_state.last_input_text:
     st.session_state.last_input_text = input_text


# Button to trigger processing
if st.button("Extract Abbreviations", type="primary"):
    if input_text:
        with st.spinner("Processing..."):
            # --- ADD NORMALIZATION STEP HERE ---
            normalized_text = normalize_latex_math(input_text)
            # --- END NORMALIZATION STEP ---

            # Call extraction with the NORMALIZED text
            st.session_state.abbreviations_dict = extract_abbreviations(normalized_text)
    else:
        st.warning("Please enter some text in the input box above.")
        st.session_state.abbreviations_dict = None
        
# --- Output Section ---
#if st.session_state.abbreviations_dict is not None:
st.markdown("---")
col1, col2 = st.columns([3, 1])
with col1:
    st.subheader("Formatted Output")
with col2:
    selected_format = st.selectbox(
        "Select Format:",
        options=['plain','tabular',  'nomenclature'],
        index=0, # Default to 'tabular'
        key='format_selector'
    )

formatted_output = format_abbreviations(st.session_state.abbreviations_dict, selected_format)

st.text_area(
    f"List of Abbreviations ({selected_format}):",
    value=formatted_output,
    height=200,
    #disabled=True,
    help="Copy the output above."
)

# --- ADD THE COPY BUTTON HERE ---
#st_copy_to_clipboard(formatted_output, "Copy Output to Clipboard")

# --- Footer ---
st.markdown("---")
#current_date_param = st.query_params.get('current_date', 'N/A')
#st.caption(f"Current date: {current_date_param}")
# Display the actual current server time using Python's datetime
# Note: This uses the server's time where Streamlit is running.
#st.caption(f"Actual current server time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
# Display approximate user location based on context (if relevant/desired)
st.caption("Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada")