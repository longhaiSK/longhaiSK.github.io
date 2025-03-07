library(shiny)
library(knitr)
library(kableExtra)
library(latex2exp)
library(DT)

# Improved Newton's method with max iterations
newton_sqrt <- function(S, tol = 1e-6, max_iter = 100) {
    if (S < 0) return(NA) # Prevent error, handle gracefully
    
    x_n <- ifelse(S < 1, S / 2, S) # Better initial guess
    trace <- c(x_n)
    
    for (i in 1:max_iter) {
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
    
    return(NA) # Return NA if max iterations reached
}

# Display results in an interactive DT table
display_table <- function(results) {
    table_data <- data.frame(
        Number = sapply(results, function(r) attr(r, "x")),
        `True \\sqrt{x}` = round(sapply(results, function(r) sqrt(attr(r, "x"))), 5),
        Approximation = round(sapply(results, function(r) r), 5),
        Error = round(sapply(results, function(r) attr(r, "error")), 5),
        check.names = FALSE
    )
    
    datatable(table_data, options = list(pageLength = 5, autoWidth = TRUE))
}

# Plotting function
plot_traces_single <- function(results) {
    traces <- lapply(results, function(r) attr(r, "trace"))
    max_len <- max(sapply(traces, length))
    
    traces_padded <- lapply(traces, function(trace) {
        length(trace) <- max_len
        trace
    })
    
    matplot(1:max_len, do.call(cbind, traces_padded), type = "b",
            col = rainbow(length(traces_padded)), lwd = 2,
            pch = 16, cex = 1.2, xlab = "Iteration", ylab = "Approximation",
            main = "Convergence of Newton's Square Root")
    
    legend("topright", legend = sapply(results, function(r) paste0("\\sqrt{", attr(r, "x"), "}")),
           col = rainbow(length(traces_padded)), pch = 16, title = "Approximations")
}

# UI
ui <- fluidPage(
    withMathJax(),
    titlePanel("Newton's Method Square Root Calculator"),
    sidebarLayout(
        sidebarPanel(
            textInput("numbers", "Enter numbers separated by spaces:", value = "2 50 101 200 500"),
            selectInput("tol", "Select tolerance:",
                        choices = c("10" = 10, "1" = 1, "0.1" = 0.1, "0.01" = 0.01, "0.001" = 0.001),
                        selected = 0.001),
            actionButton("compute", "Compute")
        ),
        mainPanel(
            h3("Results:"),
            dataTableOutput("result_table"),
            plotOutput("convergence_plot"),
            hr(),
            h3("Newton's Method Explained"),
            p("Newton's method is an iterative approach to find increasingly accurate approximations to the roots of a real-valued function. It is based on the formula:"),
            p("$$x_{n+1} = x_n - \\frac{f(x_n)}{f'(x_n)}$$"),
            p("For the square root calculation, we define our function as:"),
            p("$$f(x) = x^2 - S$$"),
            p("The derivative is:"),
            p("$$f'(x) = 2x$$"),
            p("Substituting into Newton’s formula, we get:"),
            p("$$x_{n+1} = \\frac{1}{2} \\left( x_n + \\frac{S}{x_n} \\right)$$"),
            p("This iterative process continues until the difference between successive approximations is smaller than a given tolerance."),
            h4("Example: Computing \( \\sqrt{19} \)"),
            p("Using an initial guess of \( x_0 = 9.5 \), we get:"),
            p("$$x_1 = \\frac{1}{2} \\left( 9.5 + \\frac{19}{9.5} \\right) = 5.75$$"),
            p("$$x_2 = \\frac{1}{2} \\left( 5.75 + \\frac{19}{5.75} \\right) = 4.527$$"),
            p("Continuing further, we converge to \( \\sqrt{19} \\approx 4.359 \).")
        )
    )
)

# Server
server <- function(input, output) {
    results <- reactiveVal(NULL)
    
    observeEvent(input$compute, {
        numbers <- as.numeric(unlist(strsplit(input$numbers, "\\s+")))
        
        if (any(is.na(numbers)) || any(numbers < 0)) {
            showNotification("Invalid input: Please enter non-negative numbers.", type = "error")
            return()
        }
        
        tol <- as.numeric(input$tol)
        results_list <- lapply(numbers, newton_sqrt, tol = tol)
        results(results_list)
    })
    
    output$result_table <- renderDataTable({
        req(results())
        display_table(results())
    })
    
    output$convergence_plot <- renderPlot({
        req(results())
        plot_traces_single(results())
    })
}

shinyApp(ui, server)
