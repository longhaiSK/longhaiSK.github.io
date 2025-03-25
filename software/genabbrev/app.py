
import streamlit as st
import re
import requests
from bs4 import BeautifulSoup

def get_text_from_url(url):
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.content, 'html.parser')
        return soup.get_text()
    except requests.exceptions.RequestException as e:
        return f"Error fetching URL: {e}"

def extract_abbreviations(text):
    pattern = re.compile(r'((?:[\w-]+\s+){1,10})\((([a-z]*[A-Z]{2,})[a-z]*)\)')
    matches = pattern.findall(text)

    abbreviation_dict = {}

    for match in matches:
        words_ahead = [word for word in re.split(r'\s+|(?<=-)(?=[A-Za-z])', match[0].strip()) if word]
        abbr = match[1]
        abbr_letters = list(re.sub(r'[^A-Z]', '', abbr.upper()))

        full_name_words = []
        abbr_index = 0

        for word in reversed(words_ahead):
            if word and len(word) > 0 and abbr_index < len(abbr_letters) and len(word.replace('-', '')) > 0 and word.replace('-', '')[0].upper() == abbr_letters[len(abbr_letters) - 1 - abbr_index]:
                full_name_words.insert(0, word)
                abbr_index += 1
            if abbr_index == len(abbr_letters):
                break

        if len(full_name_words) == len(abbr_letters):
            full_name = ''.join(word if i == 0 else (' ' + word if not full_name_words[i - 1].endswith('-') else word) for i, word in enumerate(full_name_words))
            abbreviation_dict[abbr] = full_name

    return abbreviation_dict

def format_abbreviations(abbreviations, format_type):
    if format_type == "nomenclature":
        latex_output = "\\usepackage{{nomencl}}
"
        for abbr, full_name in abbreviations.items():
            latex_output += f"\\nomenclature{{{abbr}}}{{{full_name}}}
"
        return latex_output
    elif format_type == "tabular":
        latex_output = "\\begin{{tabular}}{{ll}}
"
        for abbr, full_name in abbreviations.items():
            latex_output += f"{abbr} & {full_name} \\\\
"
        latex_output += "\\end{{tabular}}
"
        return latex_output
    else: # Default plain text list
        output = ""
        for abbr, full_name in abbreviations.items():
            output += f"{abbr}: {full_name}; "
        return output

st.title("Abbreviation Extractor")

text_input = st.text_area("Enter text (LaTeX Allowed) or URL:", 
                            value=r'Cox proportional hazard (PH) regression models \\cite{{CoxD.R.1972RMaL}} are widely used for analyzing time-to-event data in epidemiological and clinical research (ECR).',
                            height=100)

format_type = st.selectbox("Output Format:", options=['plain', 'nomenclature', 'tabular'], index=0)

if st.button("Generate Abbreviations"):
    if text_input.startswith('http'):
        text = get_text_from_url(text_input)
    else:
        text = text_input

    abbreviations = extract_abbreviations(text)
    formatted_output = format_abbreviations(abbreviations, format_type)

    st.text_area("List of Abbreviations:", value=formatted_output, height=200)

if st.button("Clear Input"):
    st.text_area("Enter text (LaTeX Allowed) or URL:", value="", height=100)

if st.button("Clear Output"):
    st.text_area("List of Abbreviations:", value="", height=200)
