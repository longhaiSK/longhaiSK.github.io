# sanitize list
# regexrepl.py lec1*.qmd \
# '(?m)^(?!\s*(?:[-*]|\d+\.)\s)(.+)\n(?!\s*\n)(\s*(?:[-*]|\d+\.)\s)' \
# '\1\n\n\2'

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

#regexrepl.py lec3*.qmd '::: \{\.callout-note(?=[^}]*title="Proof")[^}]*\}' ':::{.proof}'

# render with no cache

# quarto render lec1*.qmd --execute-daemon 0 --no-cache --to html
 
# quarto render lec3-mvn.qmd --execute-daemon 0 --no-cache --to pdf
 
#quarto render --execute-daemon 0 --no-cache --to pdf

# chrome stat_lin_theory.pdf 