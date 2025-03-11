library(shiny)
library(rhandsontable) # Add rhandsontable library
library(knitr)
library(kableExtra)
library(latex2exp)

# Function to compute square root using Newton's Method (unchanged)
newton_sqrt <- function(S, x0 = S/2, tol = 1e-6) { 
    if (S < 0) {
        stop("Square root of a negative number is not defined for real numbers.")
    }
    
    x_n <- x0 
    trace <- x_n
    repeat {
        x_next <- 0.5 * (x_n + S / x_n)
        trace <- c(trace, x_next)
        if (abs(x_next - x_n) < tol) {
            result <- x_next
            attr(result, "trace") <- trace
            attr(result, "error") <- abs(x_next - sqrt(S))
            attr(result, "x") <- S
            return(result)
        }
        x_n <- x_next
    }
}

# Function to display results in a table (unchanged)
display_table <- function(results) {
    numbers <- sapply(results, function(r) attr(r, "x"))
    true_values <- round(sapply(results, function(r) sqrt(attr(r, "x"))), 5)
    approximations <- round(sapply(results, function(r) r), 5)
    errors <- round(sapply(results, function(r) attr(r, "error")), 5)
    
    table_data <- data.frame(
        x = numbers,
        sqrt_x = true_values,
        Approximation = approximations,
        Error = errors,
        check.names = FALSE
    )
    
    kable(table_data, format = "html", escape = FALSE, col.names = c("S", "True sqrt(S)", "Newton sqrt(S)", "Error")) %>%
        kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) %>%
        column_spec(1, width = "5em") %>%
        column_spec(2, width = "8em") %>%
        column_spec(3, width = "10em") %>%
        column_spec(4, width = "8em") %>%
        row_spec(0, bold = TRUE) 
}

# Function to plot all traces in a single plot (unchanged)
plot_traces_single <- function(results) {
    traces <- sapply(results, function(r) attr(r, "trace"), simplify = FALSE)
    max_len <- max(sapply(traces, length))
    traces_padded <- lapply(traces, function(trace) {
        length(trace) <- max_len 
        trace 
    })
    traces_matrix <- do.call(cbind, traces_padded)
    line_types <- rep(1:10, 5) 
    matplot(1:max_len, traces_matrix, type = "b", col = rainbow(length(traces_padded)),
            lty = line_types[1:length(traces_padded)], lwd = 2,
            pch = 16, cex = 1.2,
            xlab = "Iteration", ylab = "Approximation",
            main = "Convergence of Square Root Approximations")
    x_values <- sapply(results, function(r) attr(r, "x"))
    trace_labels <- sapply(x_values, function(x) TeX(paste0("\\sqrt{", x, "}"))) 
    legend("topright", legend = trace_labels, col = rainbow(length(traces_padded)),
           lty = line_types[1:length(traces_padded)], pch = 16, title = "Approximations")
}



# Define UI
ui <- fluidPage(
    withMathJax(),
    titlePanel("Understanding Newton's Method for Finding Square Roots"),
    sidebarLayout(
        sidebarPanel(
            rHandsontableOutput("input_table"), # Use rHandsontableOutput
            actionButton("clearTable", "Clear Table"), # Add clear table Button
            selectInput("tol", "Select tolerance (tol) btw successive steps:",
                        choices = c("10" = 10, "1" = 1, "0.1" = 0.1, "0.01" = 0.01, "0.001" = 0.001),
                        selected = 0.001
            )
            
        ),
        mainPanel(
            h3("Results of Sqrt:"),
            uiOutput("result_table"),
            plotOutput("convergence_plot"),
            hr()
        )
    ),
    h3("Newton's Method Explained"),
    # ...
    h4(HTML("Example: <span>\\( S = 29 \\)</span>")),
    p(HTML("Let's compute the square root of <span>\\( S = 29 \\)</span> using Newton's method with the initial guess <span>\\( x_0 = 11 \\)</span>:")),
    p("1. First iteration:"),
    p("$$x_1 = \\frac{1}{2} \\left( 11 + \\frac{29}{11} \\right) \\approx 7.136$$"), # Three digits
    p("2. Second iteration:"),
    p("$$x_2 = \\frac{1}{2} \\left( 7.136 + \\frac{29}{7.136} \\right) \\approx 5.697$$"), # Three digits
    p("3. Third iteration:"),
    p("$$x_3 = \\frac{1}{2} \\left( 5.697 + \\frac{29}{5.697} \\right) \\approx 5.391$$"), # Three digits
    p("4. Fourth iteration:"),
    p("$$x_4 = \\frac{1}{2} \\left( 5.391 + \\frac{29}{5.391} \\right) \\approx 5.385$$"), # Three digits
    p("5. Fifth iteration:"),
    p("$$x_5 = \\frac{1}{2} \\left( 5.385 + \\frac{29}{5.385} \\right) \\approx 5.385$$"), # Three digits
    
    p(
        HTML(
            "After a few more iterations, the approximation converges to the true value of <span>\\( \\sqrt{29} \\approx 5.385 \\)</span>."
        )
    )
)

# Define server logic
server <- function(input, output) {
    
    # Reactive values to store input data
    input_data <- reactiveValues(
        data = data.frame(
            S = c(2, 5, 7, 8, 9,11),
            x0 = c(1,2.5,3.5,4,4.5,5.5)
        )
    )   
    # Create the input table
    # Create the input table using rhandsontable
    output$input_table <- renderRHandsontable({
        rhandsontable(input_data$data)
    })
    
    # Observe changes in the rhandsontable
    observeEvent(input$input_table$data, {
        if (!is.null(input$input_table$data)) {
            input_data$data <- hot_to_r(input$input_table)
        }
    })
    # Clear Table Button Functionality
    observeEvent(input$clearTable, {
        input_data$data <- data.frame(S = rep(0, 6), x0 = rep(1,6))
    })

    # Reactive expression to calculate results
    results <- reactive({
        data <- input_data$data
        numbers <- data$S
        initial_values <- data$x0
        
        # Validate inputs
        if (any(is.na(numbers)) || any(numbers < 0)) {
            showNotification("Invalid input: Please enter non-negative numbers for 'S' in the table.", type = "error")
            return(NULL)
        }
        # Remove empty rows
        valid_rows <- !is.na(numbers) & numbers >= 0 & !is.na(initial_values) & initial_values > 0
        numbers <- numbers[valid_rows]
        initial_values <- initial_values[valid_rows]
        
        # Validate inputs
        if (any(numbers < 0, na.rm = TRUE) | any(initial_values <= 0, na.rm = TRUE)) {
            showNotification("Non-negative numbers for 'S'or `Initial Values' are ignored", type = "warning")
        }
        
        
        # Use initial values if provided, otherwise use default (S/2)
        results_list <- mapply(
            newton_sqrt, numbers, initial_values,
            tol = as.numeric(input$tol), SIMPLIFY = FALSE
        )
        return(results_list)
    })
    
    # Render the result table
    output$result_table <- renderUI({
        req(results())
        table_with_tol <- display_table(results())
        tagList(
            HTML(paste0("Tolerance: ", input$tol, "<br>", table_with_tol)),
            tags$script("MathJax.Hub.Queue(['Typeset', MathJax.Hub]);")
        )
    })
    
    # Render the convergence plot
    output$convergence_plot <- renderPlot({
        req(results())
        plot_traces_single(results())
    })
}

# Run the Shiny App
shinyApp(ui, server)

