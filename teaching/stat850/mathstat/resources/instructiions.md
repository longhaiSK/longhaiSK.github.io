
Instructions for Writing quarto Document 

* Don't add yaml header.
* Don't forget to add ``` at the end of code chunk.
* The top header level is #. 
* Delete the direct numbering like 3.1, or Chapter 1
* Put definitions/theorem/corrallary example in respective divisions in this format:

::: {#thm-admissibility-unique}
### Name of Theorem/Definition/Corollary
Content of Theorem/Definition/Corollary
:::

::: {#exm-admissibility-unique}
### Name of Theorem/Definition/Corollary
Content of Theorem/Definition/Corollary
:::


* The proof is put in proof division in this format:
::: {.proof}
:::

* Always add a blank line before and after making a list or a division.

* Displayed math is put in \n$$ \n ... \n $$\n format where \n is a new line.

* To make tikz figure in quarto, use this format:

```{tikz fig-pythagoras-proof}
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

* Specific instructions for making assignments:
* 
    - Solution is put in solution division in this format:
    - 
    ::: {.sol}
    Content of solution
    :::

    - Each question should be header level 2 (##).

* Using \lVert \rVert to write || ||

* Don't place floating figures like table and figure inside divisions like theorem, definition, example, proof, etc.
* 