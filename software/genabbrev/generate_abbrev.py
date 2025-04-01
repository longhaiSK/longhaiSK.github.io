import streamlit as st
import re
from datetime import datetime # Import datetime for current date example
#from streamlit_extras.keyboard_url import st_copy_to_clipboard

   
def normalize_latex_math(text): # Consider renaming to preprocess_latex_text
    """
    Preprocesses LaTeX text:
    1. Converts LaTeX inline math \( ... \) to $ ... $.
    2. Removes LaTeX comments (% to end of line), respecting \%.
    3. Removes preamble if \begin{document} is found.

    Args:
        text (str): The input LaTeX text.

    Returns:
        str: The processed text, or the original text if an error occurs.
    """
    if not isinstance(text, str):
        print("Warning: Input to normalize_latex_math was not a string.")
        return text # Or raise TypeError

    processed_text = text
    try:
        # 1. Normalize math \(...\) to $...$
        processed_text = re.sub(
            r'\\\(\s*(.*?)\s*\\\)',
            lambda match: f"${match.group(1).strip()}$",
            processed_text
        )

        # 2. Remove LaTeX comments (handles inline %, respects \%)
        # Replaces from an unescaped % to the end of the line with nothing.
        processed_text = re.sub(r'(?<!\\)%.*$', '', processed_text, flags=re.MULTILINE)

        # 3. Remove preamble IF \begin{document} exists
        begin_doc_marker = r'\begin{document}'
        begin_doc_index = processed_text.find(begin_doc_marker)
        if begin_doc_index != -1:
            # If marker found, keep only the text *after* the marker
            processed_text = processed_text[begin_doc_index + len(begin_doc_marker):]

        # 4. Clean up potential excessive blank lines resulting from removals
        processed_text = re.sub(r'(\n\s*){2,}', '\n', processed_text)
        # Remove leading/trailing whitespace from the whole result
        processed_text = processed_text.strip()

        return processed_text

    except Exception as e:
        # Basic error handling - logs to console or Streamlit interface if available
        error_message = f"Error during LaTeX text preprocessing: {e}"
        try:
            # Attempt to use Streamlit's error reporting if running in Streamlit
            import streamlit as st
            st.error(error_message)
        except ImportError:
            # Fallback to print if not in Streamlit environment
            print(error_message)
        return text # Return original text to avoid breaking downstream processing
        

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
    # 1. Replace Greek letter commands
    for greek_cmd, letter in greek_map.items():
        abbr_string = re.sub(r'\\' + greek_cmd, letter, abbr_string)

    # 2. Remove all other LaTeX commands (starting with \), curly braces, and division symbols
    abbr_string = re.sub(r'\\(?:[a-zA-Z]+|\{.*?\}|\}|/)', '', abbr_string)

    # 3. Remove dollar signs
    abbr_string = abbr_string.replace('$', '')

    # 4. Extract remaining letters
    representative_letters = re.findall(r'[a-zA-Z]', abbr_string)
    representative_letters = [letter.lower() for letter in representative_letters]

    return representative_letters

def extract_abbreviations(text, require_first_last_match=True, debug=True):
    pattern = re.compile(r'((?:[\w\-\$\\\{\}]+\s+){1,10})\(\s*([\w\s\$\-\\\{\}]+)\s*\)')
    matches = pattern.findall(text)
    abbreviation_dict = {}

    if debug:
        print("\nDebugging extract_abbreviations")

    for match in matches:
        words_before_abbr_text = match[0].strip()
        words_ahead = [word for word in re.split(r'\s+|(?<=-)(?=[A-Za-z])', words_before_abbr_text) if word]
        abbr_string = match[1]
        abbr_letters = get_abbr_repr_letters(abbr_string)

        if debug:
            print(f"Captured Abbr String: '{abbr_string}'")
            print(f"Generated abbr_letters: {abbr_letters}")
            print(f"Captured Full Name: {words_ahead}")

        num_abbr_letters = len(abbr_letters)

        if not abbr_letters or not words_ahead or num_abbr_letters == 0:
            continue

        match_indices = [-1] * num_abbr_letters
        unmatched_abbr_indices = set(range(num_abbr_letters))

        for i, word in enumerate(reversed(words_ahead)):
            original_idx = len(words_ahead) - 1 - i
            if not unmatched_abbr_indices:
                break

            effective_char = None
            m_first_letter = re.search(r'[a-zA-Z]', word)
            if m_first_letter:
                effective_char = m_first_letter.group(0).lower()

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

        if successful_match_indices:
            min_idx_py = min(successful_match_indices)
            max_idx_py = max(successful_match_indices)

            if min_idx_py <= max_idx_py:
                # modified full name generation
                full_name = ' '.join(words_ahead[min_idx_py : max_idx_py + 1])
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
# $\frac{\gamma}{Z}$-residuals ($\frac{\gamma}{Z}$R)
example_text = r"""
\begin{document}
The full name and abbrievation can contain equations, for example, 
$\alpha$-\( Z \)-residuals ($\alphaZ$R), or 
$\beta$-\( Z \)-residuals ($\beta$$Z$R), or
$\gamma$-\( Z \)-residuals ($\gamma Z$R), or,


The abbreviations like randomized survival probabilities (RSP) and  accelerated failure time (AFT) will be caught. 

The citations and explanations in brackets, for example, this one (Wu et al. 2024),  will be omitted. %The comment text (CT) will be omitted.

Paste your \LaTex text (LT) and enjoy the app. 
\end{document}

""".strip()

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
 