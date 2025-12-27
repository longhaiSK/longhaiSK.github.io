# sanitize list
regexrepl.py lec3*.qmd \
'(?m)^(?!\s*(?:[-*]|\d+\.)\s)(.+)\n(?!\s*\n)(\s*(?:[-*]|\d+\.)\s)' \
'\1\n\n\2'

# regexrepl.py lec3-mvn.qmd \
# '(?m)^(?!\s*(?:[-*]|\d+\.)\s)(.+)\n(?!\s*\n)(\s*(?:[-*]|\d+\.)\s)' \
# '\1\n\n\2'

# sanitize enviroment name tags
# regexrepl.py lec2-matrix.qmd \
# '(:::\s*\{[^}]+)\}\s*\n\s*#{1,6}\s+(.+)' \
# '\1 name="\2"}'

# regexrepl.py lec3-mvn.qmd \
# '(:::\s*\{[^}]+)\}\s*\n\s*#{1,6}\s+(.+)' \
# '\1 name="\2"}'

# change proof format
#regexrepl.py lec3*.qmd '\:\:\:\s*\{\.proof\}' '::: {.callout-note collapse="true" icon="false" title="Proof"}'