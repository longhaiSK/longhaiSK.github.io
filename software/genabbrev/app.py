
import re

greek_map = {
    'alpha': 'a', 'beta': 'b', 'gamma': 'g', 'delta': 'd', 'epsilon': 'e',
    'zeta': 'z', 'eta': 'e', 'theta': 't', 'iota': 'i', 'kappa': 'k',
    'lambda': 'l', 'mu': 'm', 'nu': 'n', 'xi': 'x', 'omicron': 'o',
    'pi': 'p', 'rho': 'r', 'sigma': 's', 'tau': 't', 'upsilon': 'u',
    'phi': 'p', 'chi': 'c', 'psi': 'p', 'omega': 'o',
    # Add common Uppercase Greek commands if needed, mapping to lowercase
    'Gamma': 'g', 'Delta': 'd', 'Theta': 't', 'Lambda': 'l', 'Xi': 'x',
    'Pi': 'p', 'Sigma': 's', 'Upsilon': 'u', 'Phi': 'p', 'Psi': 'p', 'Omega': 'o'
    # Add others if required
}

# 2. Parse Abbreviation String
def get_abbr_repr_letters(abbr_string):
    """
    Parses an abbreviation string containing potential LaTeX Greek letters
    and uppercase letters. Returns a list of representative lowercase chars.
    e.g., "$\alpha$-SP" -> ['a', 's', 'p']
    """
    representative_letters = []
    # Pattern finds \command OR single Uppercase letter
    # It captures the command name (e.g., 'alpha') in group 1 OR the uppercase letter in group 2
    findings = re.findall(r'\\([a-zA-Z]+)|([A-Z])', abbr_string)

    for greek_cmd, upper_letter in findings:
        if greek_cmd: # Matched \command (e.g., greek_cmd == 'alpha')
            if greek_cmd in greek_map:
                representative_letters.append(greek_map[greek_cmd]) # Add lowercase representation
        elif upper_letter: # Matched single uppercase letter (e.g., upper_letter == 'S')
             representative_letters.append(upper_letter.lower()) # Add lowercase representation

    return representative_letters

def extract_abbreviations(text, require_first_last_match=True):
    """
    Best-effort abbreviation extraction supporting LaTeX Greek letters.

    Extracts inclusive slice covering first/last matched words based on
    representative characters (Greek mapped to first letter, others lowercase).
    """


    # 3. Modify Regex slightly for $, \ characters
    # Allows $, \ within words and abbreviation. Group 2 captures full abbr string.
    pattern = re.compile(r'((?:[\w\-\$\\]+\s+){1,10})\(([A-Za-z\-\$\\]{2,})\)')
    matches = pattern.findall(text)

    abbreviation_dict = {}

    for match in matches:
        words_before_abbr_text = match[0].strip()
        # Original split seems okay: '$\alpha$-Synclein Protein' -> ['$\\alpha$-Synclein', 'Protein']
        words_ahead = [word for word in re.split(r'\s+|(?<=-)(?=[A-Za-z])', words_before_abbr_text) if word]

        abbr_string = match[1] # The raw abbreviation string, e.g., "$\alpha$-SP"
        # Get representative letters, e.g., ['a', 's', 'p']
        abbr_letters = get_abbr_repr_letters(abbr_string)
        num_abbr_letters = len(abbr_letters)

        if not abbr_letters or not words_ahead or num_abbr_letters == 0:
            continue

        # Stores 0-based index
        match_indices = [-1] * num_abbr_letters
        unmatched_abbr_indices = set(range(num_abbr_letters))

        # Iterate through words backwards
        for i, word in enumerate(reversed(words_ahead)):
            original_idx = len(words_ahead) - 1 - i
            if not unmatched_abbr_indices:
                break

            # 4. Determine "Effective First Character" (lowercase)
            effective_char = None
            # Check for $\greek... pattern
            m_dollar = re.match(r'\$\\([a-zA-Z]+)', word)
            if m_dollar and m_dollar.group(1) in greek_map:
                effective_char = greek_map[m_dollar.group(1)]
            else:
                 # Check for \greek... pattern (less common start)
                 m_slash = re.match(r'\\([a-zA-Z]+)', word)
                 if m_slash and m_slash.group(1) in greek_map:
                     effective_char = greek_map[m_slash.group(1)]
                 else:
                     # Standard word handling: find the first ASCII letter
                     # Remove leading/trailing hyphens for this check? No, search within original word.
                     m_first_letter = re.search(r'[a-zA-Z]', word)
                     if m_first_letter:
                         effective_char = m_first_letter.group(0).lower()
                     # If no letter found (e.g., word is just "$"), effective_char remains None

            # 5. Match effective char with abbreviation letters
            if effective_char is not None:
                best_match_abbr_idx = -1
                # Check remaining letters right-to-left
                for abbr_idx in sorted(list(unmatched_abbr_indices), reverse=True):
                    # Compare lowercase effective char with lowercase representative abbr letter
                    if effective_char == abbr_letters[abbr_idx]:
                         best_match_abbr_idx = abbr_idx
                         break

                if best_match_abbr_idx != -1:
                    match_indices[best_match_abbr_idx] = original_idx
                    unmatched_abbr_indices.remove(best_match_abbr_idx)

        # --- Validation & Reconstruction (Keep from best_effort) ---
        successful_match_indices = [idx for idx in match_indices if idx != -1]

        if not successful_match_indices:
            continue

        valid_match = True
        if require_first_last_match:
            # Check if first (idx 0) and last (idx num_abbr_letters - 1) letters were matched
            if match_indices[0] == -1 or match_indices[num_abbr_letters - 1] == -1:
                valid_match = False

        if valid_match:
            min_idx_py = min(successful_match_indices) # 0-based index of earliest word
            max_idx_py = max(successful_match_indices) # 0-based index of latest word

            if min_idx_py <= max_idx_py:
                # Extract the inclusive slice covering the span of matched words
                full_phrase_words_slice = words_ahead[min_idx_py : max_idx_py + 1]

                # Join the slice
                full_name = ''.join(word if i == 0 else (' ' + word if not full_phrase_words_slice[i - 1].endswith('-') else word)
                                    for i, word in enumerate(full_phrase_words_slice))

                # Use the original abbreviation string as the key
                abbreviation_dict[abbr_string] = full_name

    return abbreviation_dict

