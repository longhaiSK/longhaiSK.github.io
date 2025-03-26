
import re
import requests
from bs4 import BeautifulSoup
import ipywidgets as widgets
from IPython.display import display
from ipywidgets import HTML

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
    output = ""
    for abbr, full_name in abbreviations.items():
        output += f"{abbr}: {full_name}; "
    return output

def process_input(input_text, format_type):
    if input_text.startswith('http'):
        text = get_text_from_url(input_text)
    else:
        text = input_text

    abbreviations = extract_abbreviations(text)
    formatted_output = format_abbreviations(abbreviations, format_type)

    output_text_box.value = formatted_output
    num_lines = formatted_output.count('\n') + 2
    output_text_box.layout.height = f'{min(num_lines * 20, 400)}px'

def clear_output_area(b):
    output_text_box.value = ''
    output_text_box.layout.height = '100px'

def clear_text_input(b):
    text_box.value = ''

def rerun_format(change):
    global text_box, output_format_dropdown
    process_input(text_box.value, change.new)

text_label = HTML(value='<b>Enter text (Latex Allowed) or URL:</b>')
text_box = widgets.Textarea(
    value=r'Cox proportional hazard (PH) regression models \cite{CoxD.R.1972RMaL} are widely used for analyzing time-to-event data in epidemiological and clinical research (ECR).',
    placeholder='Enter text or URL',
    disabled=False,
    layout=widgets.Layout(width='100%', height='100px')
)

output_label = HTML(value='<b>List of Abbreviations</b>')
output_format_dropdown = widgets.Dropdown(
    options=['plain','nomenclature', 'tabular'],
    value='plain',
    description='Format:',
)

output_box = widgets.HBox([output_label, output_format_dropdown])

output_text_box = widgets.Textarea(
    value='',
    placeholder='List of Generated Abbreviations',
    disabled=False,
    layout=widgets.Layout(width='100%', height='100px')
)

submit_button = widgets.Button(
    description='Generate Abbreviations',
    disabled=False,
    button_style='primary',
    tooltip='Click to generate abbreviations',
    icon='magic'
)

clear_output_button = widgets.Button(
    description='Clear Output',
    disabled=False,
    button_style='',
    tooltip='Click to clear output',
    icon='times'
)

clear_text_button = widgets.Button(
    description='Clear Input',
    disabled=False,
    button_style='',
    tooltip='Click to clear input',
    icon='times'
)

submit_button.on_click(lambda b: process_input(text_box.value, output_format_dropdown.value))
clear_output_button.on_click(clear_output_area)
clear_text_button.on_click(clear_text_input)

output_format_dropdown.observe(rerun_format, names='value')

input_box_with_clear = widgets.VBox([text_label, widgets.HBox([text_box, clear_text_button])])
output_box_with_clear = widgets.VBox([output_box, widgets.HBox([output_text_box, clear_output_button])])

display(input_box_with_clear, submit_button, output_box_with_clear)
