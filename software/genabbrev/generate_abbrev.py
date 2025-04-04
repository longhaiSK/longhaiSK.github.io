
import streamlit as st
import re
from datetime import datetime
from extract_abbrev_regex import *
import socket
import pandas as pd
hostname = socket.gethostname()
DEBUG = "streamlit" not in hostname.lower()  # Assume cloud has "streamlit" in hostname

import pandas as pd

# --- Example Usage ---
# (This part would typically be run in a Jupyter Notebook cell)


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
             st.session_state.abbreviations_dict = extract_abbreviations(normalized_text, debug=DEBUG)
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
col_input, col_output = st.columns([3, 1]) # Create two equal-width columns

# --- Column 1: Input Area ---
with col_input:
    st.subheader("Paste Your text")
    input_text = st.text_area(
        label="input_text_main",
        label_visibility="collapsed",
        value=st.session_state.last_input_text,
        height=350,  # Adjust height as needed for side-by-side view
        placeholder="Paste your text here...",
        key="input_text_area"
    )
    st.caption("Privacy: this app does not save your text.")


    # --- Use THREE columns in ONE row for Button, Label, Selector ---
    # Adjust the ratios as needed for desired visual spacing
  
        
with col_output:
    #st.subheader("Formatted Abbreviations")  # Header

    extract_pressed = st.button("Extract Abbreviations with Regex", type="primary", use_container_width=True)
    if input_text != st.session_state.last_input_text:
         st.session_state.last_input_text = input_text
    # Processing Logic (triggered by button state)
    if "first_run_done" not in st.session_state:
        st.session_state.first_run_done = True  # Mark that the first run has happened

    if extract_pressed or st.session_state.first_run_done: # Check the state of the button variable
        if input_text:
            with st.spinner("Processing..."):
                normalized_text = normalize_latex_math(input_text)
                st.session_state.abbreviations_dict = extract_abbreviations(normalized_text, debug=False)
        else:
            st.warning("Please enter some text in the input box above.")
            st.session_state.abbreviations_dict = None
  
    # st.session_state.selected_method = st.selectbox(
    #     label="Choose a method:", # 
    #     label_visibility="collapsed", 
    #     options=['regex', 'Gemini', 'ChatGPT'],
    #     index=0,  # Default to 'tabular'
    #     key='method_selector', # Key allows state to persist
    #     help="Select the method for extracting abbreviations."
    # )
    # Update session state for input text (placement fine here)
    # if input_text != st.session_state.last_input_text:
    #     st.session_state.last_input_text = input_text
    # # if st.session_state.first_run_done: # Check the state of the button variable
    # if st.session_state.selected_method:
    #     with st.spinner("Processing..."):
    #         normalized_text = normalize_latex_math(input_text)
    #         st.session_state.abbreviations_dict = extract_abbreviations(normalized_text, debug=DEBUG)
    # else:
    #     st.warning("Other method is not implemented yet.")
    #     st.session_state.abbreviations_dict = None
        
    #--- Prepare Output Value ---
    output_placeholder = "Output will appear here after clicking 'Extract Abbreviations'."
    
    formatted_output_display = output_placeholder
    if st.session_state.abbreviations_dict is not None:
        formatted_output_display = "No abbreviations found in the text."
    else:
        formatted_output_display = format_abbreviations(st.session_state.abbreviations_dict, format_type="plain")

    # --- Display Output Text Area ---
	
    

    # Convert to Markdown table string
    df_abbr = pd.DataFrame(st.session_state.abbreviations_dict.items(), columns=['Abbreviation', 'Full Phrase'])
    markdown_table = df_abbr.to_markdown(index=False)
    #html_table = render_dataframe_with_latex(df_abbr)
    # Display using st.markdown - LaTeX should render automatically
    with st.container(height=350, border=False): # Adjust height in pixels as needed
        st.markdown(markdown_table)
	#st.markdown(html_table, unsafe_allow_html=True)
    
#sub_col_label, sub_col_widget = st.columns([0.5, 3])
#with sub_col_label:
    # Place label text in the second sub-column
    # Using markdown allows potential styling. Adjust padding/margin for vertical alignment.
#    st.markdown("<div style='margin-top: 0.6rem; text-align: left;'>Format:</div>", unsafe_allow_html=True)
    # Simpler alternative: st.text("Format:") - may not align vertically as well

#with sub_col_widget:
    # Place selectbox in the third sub-column (hide its own label)
col_exp, _ = st.columns([1, 1])
with col_exp:
    st.subheader("Export")        
    selected_format = st.selectbox(
        label="Choose an exportting format:", # 
        label_visibility="collapsed", 
        options=['plain', 'tabular', 'nomenclature'],
        index=0,  # Default to 'tabular'
        key='format_selector', # Key allows state to persist
        help="Select the format for the abbreviation list output."
    )
        
    if st.session_state.abbreviations_dict is not None:
            if not st.session_state.abbreviations_dict:
                formatted_output = "No abbreviations found in the text."
            else:
                formatted_output = format_abbreviations(st.session_state.abbreviations_dict, format_type=selected_format)    
    st.text_area(
            label="output_text_main",
            label_visibility="collapsed",
            value=formatted_output,
            height=150,  # Explicit Height (Match input column)
            help="Copy the output from this box.",
            key="output_text_area"
        )


# Add a visual separator before the explanations
st.divider()
st.subheader("About the Algorithm") # Optional subheader for the section

# --- Define Content for Both Expanders ---

# 1. Conceptual Summary Content
summary_expander_label = "ⓘ How Abbreviation Extraction Works (Summary)"
summary_explanation_text = """
This tool attempts to find abbreviations defined within parentheses, like `Full Definition (Abbr)`, even in text containing LaTeX formatting. Here's the basic process:

1.  **Finding Candidates:** It scans the text using regular expressions to locate potential `Definition (Abbr)` patterns, focusing on words on the same line just before the parentheses.
2.  **Parsing Abbreviation:** It breaks down the abbreviation (e.g., `GRs`, `\\gamma R`) into core components (like `g`, `r` or `\\gamma`, `r`), ignoring plural 's' after capitals.
3.  **Matching Backwards:** It looks backward from the abbreviation's components through the preceding words/separators to find likely corresponding words (e.g., matching 'R' to 'Residuals'). It handles letters and LaTeX commands differently during matching.
4.  **Reconstructing Definition:** If a consistent match is found, it rebuilds the definition phrase, preserving original spacing and hyphens.
5.  **Validation:** A match is considered valid only if a high enough percentage (e.g., >= 70%) of the abbreviation's components were matched.

*(This process uses heuristics, especially for LaTeX, so results may vary.)*
"""

# 2. Detailed Description Content
detailed_expander_label = "ⓘ Detailed Algorithm Explanation"
detailed_description_text = """
This algorithm identifies abbreviations defined as `Full Definition Phrase (Abbr)` within text, including LaTeX, and extracts the phrase.

**Core Steps:**

1.  **Optional Preprocessing (`normalize_latex_math`):** Standardizes LaTeX comments, math delimiters (`\\(...\\)` to `\$...\$`), spacing around braces/commands.
2.  **Candidate Identification (Regex):** Finds `Definition (Abbr)` patterns. Captures preceding words (Group 1, same line only) and the abbreviation (Group 2).
3.  **Abbreviation Parsing (`get_abbr_repr_items`):** Creates a list (`abbr_items`) from the abbreviation. Keeps `\\commands` as strings, uses initial uppercase letters (ignoring trailing lowercase, e.g., `CPs` -> `c`, `p`), includes standalone lowercase. No Greek mapping.
4.  **Preceding Text Tokenization (Split):** Splits preceding words into `words_ahead` using `re.split(r'([ -]+)', ...)`, retaining spaces/hyphens as separate tokens (empty strings removed).
5.  **Backward Matching (`find_abbreviation_matches`):** Matches `abbr_items` to `words_ahead` tokens in reverse.
    * **Word Analysis (`get_effective_char`):** Derives a single effective character (first letter after heuristic LaTeX stripping) from word tokens for letter-matching.
    * **Comparison:** Matches command `abbr_items` if a word token starts with the command (allows leading `\$`). Matches letter `abbr_items` against a word token's `effective_char`. Skips separator tokens.
    * Records `match_indices` (word index for each abbr index, or -1).
6.  **Validation:** Calculates the ratio of successfully matched items (`count_matched / num_abbr_items`). Considers the definition valid if this ratio meets/exceeds a `match_threshold` (default 0.7).
7.  **Phrase Reconstruction:** If valid, finds the min/max matched word indices, slices `words_ahead` (getting words and separators), and reconstructs the `full_name` using `"".join(slice)` to preserve original spacing/hyphens.
8.  **Output:** Returns a dictionary mapping abbreviations to their reconstructed definitions.
"""

# --- Create Columns and Display Expanders ---

col1, col2 = st.columns(2)

with col1:
    with st.expander(summary_expander_label):
        st.markdown(summary_explanation_text)

with col2:
    with st.expander(detailed_expander_label):
        st.markdown(detailed_description_text)

   
   # --- Footer (outside columns) ---
st.markdown("---")

st.caption("Author: Longhai Li, https://longhaisk.github.io, Saskatoon, SK, Canada")
# current_date_param = st.query_params.get('current_date', 'N/A')
# st.caption(f"Current date (from URL param 'current_date', if provided): {current_date_param}")
# st.caption(f"Actual current server time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} (CST)") # Indicate CST
# st.caption("Location context: Saskatoon, SK, Canada")
 
