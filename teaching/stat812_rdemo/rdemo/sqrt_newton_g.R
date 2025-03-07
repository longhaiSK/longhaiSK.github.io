library(shiny)
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
    titlePanel("Newton's Method for Finding Square Roots"),
    sidebarLayout(
        sidebarPanel(
            numericInput("num_rows", "Number of rows:", value = 5, min = 1),
            uiOutput("input_table"),  
            selectInput("tol", "Select tolerance (tol) btw successive steps:",
                        choices = c("10" = 10, "1" = 1, "0.1" = 0.1, "0.01" = 0.01, "0.001" = 0.001),
                        selected = 0.001
            )
        ),
        mainPanel(
            h3("Results:"),
            uiOutput("result_table"),
            plotOutput("convergence_plot"),
            hr()
        )
    ),
    h3("Newton's Method Explained"),
    p("Newton's method is an iterative approach to find increasingly accurate approximations to the roots (or zeroes) of a real-valued function. It is derived from the general Newton-Raphson formula:"),
    p("$$x_{n+1} = x_n - \\frac{f(x_n)}{f'(x_n)}$$"),
    p(HTML("For the square root problem, we want to find the root of the function <span>\\( f(x) = x^2 - S \\)</span>, where <span>\\( S \\)</span> is the number whose square root we want to compute. The derivative of <span>\\( f(x) \\)</span> is <span>\\( f'(x) = 2x \\)</span>. Substituting into the Newton-Raphson formula, we get:")),
    p("$$x_{n+1} = x_n - \\frac{x_n^2 - S}{2x_n}$$"),
    p(HTML("Simplifying this expression, we obtain the formula used in this app:")),
    p("$$x_{n+1} = \\frac{1}{2} \\left( x_n + \\frac{S}{x_n} \\right)$$"),
    p("This process continues until the difference between successive approximations is smaller than a predefined tolerance, indicating convergence."),
    h4(HTML("Example: <span>\\( S = 19 \\)</span>")),
    p(HTML("Let's compute the square root of <span>\\( S = 19 \\)</span> using Newton's method with two different initial guesses:")),
    p(HTML("<b>Case 1: Initial guess <span>\\( x_0 = 7 \\)</span></b>")),
    p("1. First iteration:"),
    p("$$x_1 = \\frac{1}{2} \\left( 7 + \\frac{19}{7} \\right) = \\frac{1}{2} \\left( 7 + 2.714 \\right) = 4.857$$"),
    p("2. Second iteration:"),
    p("$$x_2 = \\frac{1}{2} \\left( 4.857 + \\frac{19}{4.857} \\right) = \\frac{1}{2} \\left( 4.857 + 3.913 \\right) = 4.385$$"),
    p("3. Third iteration:"),
    p("$$x_3 = \\frac{1}{2} \\left( 4.385 + \\frac{19}{4.385} \\right) = \\frac{1}{2} \\left( 4.385 + 4.334 \\right) = 4.360$$"),
    p(HTML("<b>Case 2: Initial guess <span>\\( x_0 = \\frac{19}{2} = 9.5 \\)</span></b>")),
    p("1. First iteration:"),
    p("$$x_1 = \\frac{1}{2} \\left( 9.5 + \\frac{19}{9.5} \\right) = \\frac{1}{2} \\left( 9.5 + 2 \\right) = 5.75$$"),
    p("2. Second iteration:"),
    p("$$x_2 = \\frac{1}{2} \\left( 5.75 + \\frac{19}{5.75} \\right) = \\frac{1}{2} \\left( 5.75 + 3.304 \\right) = 4.527$$"),
    p("3. Third iteration:"),
    p("$$x_3 = \\frac{1}{2} \\left( 4.527 + \\frac{19}{4.527} \\right) = \\frac{1}{2} \\left( 4.527 + 4.2 \\right) = 4.363$$"),
    p(HTML("After a few more iterations, in both cases, the approximation converges to the true value of <span>\\( \\sqrt{19} \\approx 4.359 \\)</span>. Notice that with the better initial guess, the convergence is faster."))
    
    
)

# Define server logic
server <- function(input, output) {
    
    # Reactive values to store input data
    input_data <- reactiveValues(
        Squares = c(2,5, 50, 500,1000),
        InitialValues = c(1, 5 / 2, 50 / 2, 500 / 2, 500)
    )
    
    # Create the input table
    output$input_table <- renderUI({
        num_rows <- input$num_rows
        
        # Update input_data if num_rows increased
        if (num_rows > length(input_data$Squares)) {
            new_squares <- rep(1000, num_rows - length(input_data$Squares))
            new_initial_values <- rep(500, num_rows - length(input_data$InitialValues))
            input_data$Squares <- c(input_data$Squares, new_squares)
            input_data$InitialValues <- c(input_data$InitialValues, new_initial_values)
        }
        
        table_output <- lapply(1:num_rows, function(i) {
            fluidRow(
                column(6, numericInput(paste0("number_", i), label = NULL, value = input_data$Squares[i])),
                column(6, numericInput(paste0("initial_value_", i), label = NULL, value = input_data$InitialValues[i]))
            )
        })
        
        # Add headers to the table
        tagList(
            fluidRow(
                column(6, h5("Squares (S)")),
                column(6, h5("Initial Values (\\(x_0\\) )"))
            ),
            table_output
        )
    })
    
    # Reactive expression to get numbers and initial values
    get_input_data <- reactive({
        req(input$num_rows)
        num_rows <- input$num_rows
        numbers <- sapply(1:num_rows, function(i) input[[paste0("number_", i)]])
        initial_values <- sapply(1:num_rows, function(i) input[[paste0("initial_value_", i)]])
        list(numbers = numbers, initial_values = initial_values)
    })
    
    # Calculate results reactively
    results <- reactive({
        data <- get_input_data()
        numbers <- data$numbers
        initial_values <- data$initial_values
        
        # Validate inputs
        if (any(is.na(numbers)) || any(numbers < 0)) {
            showNotification("Invalid input: Please enter non-negative numbers for 'Number' in the table.", type = "error")
            return(NULL)
        }
        
        if (any(is.na(initial_values)) || any(initial_values <= 0)) {
            showNotification("Invalid input: Please enter positive numbers for 'Initial Value' in the table.", type = "error")
            return(NULL)
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