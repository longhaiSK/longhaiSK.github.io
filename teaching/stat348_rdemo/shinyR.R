library(shiny)
library(googlesheets4)
library(googledrive)
library(dplyr)

# Authenticate if needed
# gs4_auth(cache = ".secrets")

sheet_url <- "https://docs.google.com/spreadsheets/d/18EbvJqHDn1uNI4pyXmkF0nV1-hZNCmmEpUk8DmwFblg/edit?usp=sharing"
sheet_name <- "Analysis of Variance"

# Read the "Analysis of Variance" sheet
anova_data <- read_sheet(sheet_url, sheet = sheet_name)

# Function to get cell colors (corrected)
get_cell_colors <- function(sheet_url, sheet_name) {
    ss <- googledrive::as_id(sheet_url)
    sheet_properties <- gs4_get(ss) %>%
        googlesheets4:::sheet_properties() %>%
        filter(name == sheet_name)
    
    sheet_id <- sheet_properties$sheetId
    
    googlesheets4:::gs4_get_ranges(ss, range = sheet_name) %>%
        googlesheets4:::gs4_read_cells(ss, sheet_id = sheet_id) %>%
        select(row, col, effectiveFormat.backgroundColor)
}

ui <- fluidPage(
    titlePanel(anova_data[1, 1]), # Use first cell as title
    uiOutput("anovaContent")
)

server <- function(input, output, session) {
    anova_data_no_title <- anova_data[-1, ] # Remove title row
    colors <- get_cell_colors(sheet_url, sheet_name)
    
    green_cells <- colors %>%
        filter(effectiveFormat.backgroundColor$red == 0,
               effectiveFormat.backgroundColor$green == 1,
               effectiveFormat.backgroundColor$blue == 0)
    
    cyan_cells <- colors %>%
        filter(effectiveFormat.backgroundColor$red == 0,
               effectiveFormat.backgroundColor$green == 1,
               effectiveFormat.backgroundColor$blue == 1)
    
    green_inputs <- lapply(1:nrow(green_cells), function(i) {
        row <- green_cells[i, ]
        cell_value <- anova_data_no_title[row$row, row$col]
        numericInput(paste0("input_", row$row, "_", row$col),
                     paste0(names(anova_data_no_title)[row$col], " (", row$row, ")"),
                     value = cell_value)
    })
    
    output_cells <- colors %>%
        filter(!((effectiveFormat.backgroundColor$red == 0 & effectiveFormat.backgroundColor$green == 1 & effectiveFormat.backgroundColor$blue == 0) |
                     (effectiveFormat.backgroundColor$red == 0 & effectiveFormat.backgroundColor$green == 1 & effectiveFormat.backgroundColor$blue == 1)))
    
    output_values <- lapply(1:nrow(output_cells), function(i) {
        row <- output_cells[i, ]
        cell_value <- anova_data_no_title[row$row, row$col]
        paste0(names(anova_data_no_title)[row$col], " (", row$row, "): ", cell_value)
    })
    
    cyan_output_cells <- lapply(1:nrow(cyan_cells), function(i) {
        row <- cyan_cells[i, ]
        cell_value <- anova_data_no_title[row$row, row$col]
        paste0(names(anova_data_no_title)[row$col], " (", row$row, "): ", cell_value)
    })
    
    output$anovaContent <- renderUI({
        tagList(
            green_inputs,
            lapply(output_values, tags$p),
            lapply(cyan_output_cells, tags$h3)
        )
    })
}

shinyApp(ui = ui, server = server)
