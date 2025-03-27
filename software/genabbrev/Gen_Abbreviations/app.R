library(shiny)
library(stringr)

# Function to extract abbreviations (R equivalent of your Python logic)
extract_abbreviations_r <- function(text) {
    # Robust regex pattern (similar to Python)
    pattern <- "((?:[\\w-]+\\s+){1,10})\\s*\\(\\s*([A-Za-z0-9-]+)\\s*\\)"
    matches <- str_extract_all(text, pattern, simplify = TRUE)
    
    abbreviations <- list()
    if (nrow(matches) > 0) {
        for (i in 1:nrow(matches)) {
            match <- matches[i, ]
            if (!is.na(match[1])) {
                context <- str_trim(match[1])
                abbreviation <- str_trim(match[2])
                
                words_ahead <- str_split(context, "\\s+")[[1]]
                abbr_letters <- strsplit(toupper(abbreviation), "")[[1]]
                abbr_index <- 0
                full_name_words <- c()
                
                for (word in rev(words_ahead)) {
                    if (abbr_index >= length(abbr_letters)) {
                        break
                    }
                    if (!is.na(word) && nchar(word) > 0 && toupper(substr(word, 1, 1)) == abbr_letters[length(abbr_letters) - abbr_index]) {
                        full_name_words <- c(word, full_name_words)
                        abbr_index <- abbr_index + 1
                    }
                }
                
                if (abbr_index == length(abbr_letters)) {
                    full_name <- paste(ifelse(1:length(full_name_words) == 1, full_name_words, ifelse(str_detect(lag(full_name_words), "-"), full_name_words, paste(" ", full_name_words))), collapse = "")
                    abbreviations[[abbreviation]] <- full_name
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

