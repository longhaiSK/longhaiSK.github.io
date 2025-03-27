!pip freeze > requirements.txt

library(shiny)
library(stringr)




extract_abbreviations_r <- function(text) {
    # Robust regex pattern (similar to Python)
    pattern <- "((?:[\\w-]+\\s+){1,10})\\s*\\(\\s*([A-Za-z0-9-]+)\\s*\\)"
    matches <- str_match_all(text, pattern)
    
    abbreviations <- list()
    
    for (match_set in matches) {
        if (nrow(match_set) > 0) {
            for (i in 1:nrow(match_set)) {
                match <- match_set[i, ]
                if (!is.na(match[1])) {
                    context <- str_trim(match[2])  # Access the first capturing group
                    abbreviation <- str_trim(match[3]) # Access the second capturing group
                    
                    # Safely split and check for empty words
                    words_ahead <- str_split(context, "\\s+")[[1]]
                    words_ahead <- words_ahead[nchar(words_ahead) > 0] # Remove empty strings
                    
                    abbr_letters <- strsplit(toupper(abbreviation), "")[[1]]
                    abbr_index <- 0
                    full_name_words <- c()
                    
                    for (word in rev(words_ahead)) {
                        if (abbr_index >= length(abbr_letters)) {
                            break
                        }
                        # Comprehensive NA checks
                        if (!is.na(word) && !is.na(word[1]) && !is.na(abbr_letters[length(abbr_letters) - abbr_index]) &&
                            nchar(word) > 0 && toupper(substr(word, 1, 1)) == abbr_letters[length(abbr_letters) - 1 - abbr_index]) {
                            full_name_words <- c(word, full_name_words)
                            abbr_index <- abbr_index + 1
                        }
                        if (abbr_index == length(abbr_letters)) {
                            break
                        }
                    }
                    
                    if (abbr_index == length(abbr_letters)) {
                        full_name <- paste(full_name_words, collapse = " ")
                        abbreviations[[abbreviation]] <- full_name
                    }
                }
            }
        }
    }
    return(abbreviations)
}
# Function to format abbreviations
format_abbreviations_r <- function(abbreviations, format_type = "plain") {
    if (format_type == "nomenclature") {
        latex_output <- "\\\\usepackage{nomencl}\n"
        for (abbr in names(abbreviations)) {
            full_name <- abbreviations[[abbr]]
            latex_output <- paste0(latex_output, "\\\\nomenclature{", abbr, "}{", full_name, "}\n")
        }
        return(latex_output)
    } else if (format_type == "tabular") {
        latex_output <- "\\\\begin{tabular}{ll}\n"
        for (abbr in names(abbreviations)) {
            full_name <- abbreviations[[abbr]]
            latex_output <- paste0(latex_output, abbr, " & ", full_name, " \\\\\\\\\n")
        }
        latex_output <- paste0(latex_output, "\\\\end{tabular}\n")
        return(latex_output)
    } else { # Default plain text list
        output <- ""
        for (abbr in names(abbreviations)) {
            full_name <- abbreviations[[abbr]]
            output <- paste0(output, abbr, ": ", full_name, "; ")
        }
        return(output)
    }
}

# Shiny UI
ui <- fluidPage(
    titlePanel("LaTeX Abbreviation Extractor"),
    sidebarLayout(
        sidebarPanel(
            textAreaInput("input_text", "Enter text (LaTeX Allowed) or URL:",
                          value = "Cox proportional hazard (PH) regression models \\cite{CoxD.R.1972RMaL} are widely used for analyzing time-to-event data in epidemiological and clinical research (ECR).",
                          rows = 5,
                          placeholder = "Enter text or URL"),
            selectInput("output_format", "Output Format:",
                        choices = c("plain", "nomenclature", "tabular"),
                        selected = "plain"),
            actionButton("submit_button", "Generate Abbreviations", icon = icon("magic")),
            actionButton("clear_text_button", "Clear Input", icon = icon("times")),
            actionButton("clear_output_button", "Clear Output", icon = icon("times"))
        ),
        mainPanel(
            h2("List of Abbreviations"),
            verbatimTextOutput("output_text")
        )
    )
)

# Shiny Server
server <- function(input, output, session) {
    # Process Input
    observeEvent(input$submit_button, {
        input_text <- input$input_text
        format_type <- input$output_format
        
        if (startsWith(input_text, "http")) {
            text <- tryCatch({
                # Using curl to fetch the content
                text <- system2("curl", args = c("-s", input_text), stdout = TRUE, stderr = FALSE)
                if (length(text) > 0) {
                    paste(text, collapse = "\n")
                } else {
                    "Error fetching URL"
                }
            }, error = function(e) {
                return(paste("Error fetching URL:", e$message))
            })
        } else {
            text <- input_text
        }
        
        abbreviations <- extract_abbreviations_r(text)
        formatted_output <- format_abbreviations_r(abbreviations, format_type)
        
        output$output_text <- renderText({
            formatted_output
        })
    })
    
    # Clear Output
    observeEvent(input$clear_output_button, {
        output$output_text <- renderText({
            ""
        })
    })
    
    # Clear Input
    observeEvent(input$clear_text_button, {
        updateTextAreaInput(session, "input_text", value = "")
    })
}

# Run the Shiny App
shinyApp(ui, server)

