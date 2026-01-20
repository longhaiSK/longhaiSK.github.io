



```{=latex}
\setcounter{section}{1}
```

```{=typst}
#counter(heading).update(1)
```

```{r}
#| echo: false
#| include: false
no.h2 <- 1 # Initialize counter

# Function to print current number and increment
H2 <- function() {
  current <- no.h2
  no.h2 <<- no.h2 + 1
  return(current)
}
h2 <- H2

```


