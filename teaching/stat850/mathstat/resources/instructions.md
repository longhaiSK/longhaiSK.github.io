
**Instructions for Writing quarto Documents**

* Don't add yaml header.
* Always add 4 backticks ```` around qmd code
* Don't use the direct numbering such as 3.1, or Chapter 1
* Dont use direct numbering to make a list such as **1. Factor into Components:**. Instead, using auto numbering: 
   1. **Factor into Components** \n
   where \n means a newline

* Always indent the text or sublists  of a list item such as:
   
   1. Item 1
      More discussion of Item 1
   2. Item 2
      More discussion of Item 2

* Put definitions/theorem/corrallary/proof/example/remark in respective divisions in this format:

   ::: {#thm-admissibility-unique}
   ### Name of Theorem/Definition/Corollary
   Content of Theorem/Definition/Corollary
   :::

   ::: {#exm-admissibility-unique}
   ### Name of Theorem/Definition/Corollary
   Content of Theorem/Definition/Corollary
   :::

   ::: {.proof}
   :::

* Don't place floating figures like table and figure inside divisions like theorem, definition, example, proof, etc.

* Always add a blank line before and after making a list or a division.

* Displayed math is put in \n$$ \n ... \n $$\n format where \n is a new line.

* To make tikz figure in quarto, use this format. Note that "%|" not "#|" inside tikz division. 

   ```{tikz}
   %| label: fig-pythagoras-proof
   %| fig-cap: "Proof of Pythagorean Theorem using Area Scaling"
   %| echo: false
   %| fig-align: "center"
   %| out-extra: 'style="width: 80% !important;"'
   %| engine.opts:
   %|   extra.preamble: "\\usepackage{amssymb}"

   \begin{tikzpicture}
   plotting commands here
   \end{tikzpicture}
   ```


**Specific instructions for making assignments:**

* Solution is put in solution division in this format:
  
    ::: {.sol}
    Content of solution
    :::

    - Each question should be header level 2 (##).


