# sanitize list
# regexrepl.py lec2-matrix.qmd \
# '(?m)^(?!\s*(?:[-*]|\d+\.)\s)(.+)\n(?!\s*\n)(\s*(?:[-*]|\d+\.)\s)' \
# '\1\n\n\2'

regexrepl.py lec3-mvn.qmd \
'(?m)^(?!\s*(?:[-*]|\d+\.)\s)(.+)\n(?!\s*\n)(\s*(?:[-*]|\d+\.)\s)' \
'\1\n\n\2'

# regexrepl.py lec2-matrix.qmd \
# '(:::\s*\{[^}]+)\}\s*\n\s*#{1,6}\s+(.+)' \
# '\1 name="\2"}'

# regexrepl.py lec3-mvn.qmd \
# '(:::\s*\{[^}]+)\}\s*\n\s*#{1,6}\s+(.+)' \
# '\1 name="\2"}'