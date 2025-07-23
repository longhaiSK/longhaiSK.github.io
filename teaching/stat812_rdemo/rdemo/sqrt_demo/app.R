library(munsell)
library(shiny)
library(rhandsontable)
library(knitr)
library(kableExtra)
library(latex2exp)
library(ggplot2)
library(grid)

# Function to compute square root using Newton's Method (now includes slope)
newton_sqrt <- function(S, x0 = S / 2, tol = 1e-3) {
    if (S < 0) stop("Square root of a negative number is not defined for real numbers.")
    
    x_n <- x0
    trace <- data.frame(x_i = x_n, y = x_n^2 - S, slope = 2 * x_n) # Store initial point and slope
    
    repeat {
        x_next <- 0.5 * (x_n + S / x_n) # Newton's update formula
        trace <- rbind(trace, data.frame(x_i = x_next, y = x_next^2 - S, slope = 2 * x_next))
        
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

# Function to compute tangent lines
compute_tangent <- function(x0, y0, slope, xrange = c(-10, 10)) {
    x_vals <- seq(xrange[1], xrange[2], length.out = 100)
    y_vals <- y0 + slope * (x_vals - x0)
    data.frame(x = x_vals, y = y_vals)
}

# Function to compute square root using Newton's Method
# Function to display results in a table (updated to use new trace structure)
display_table <- function(results) {
    numbers <- sapply(results, function(r) attr(r, "x"))
    true_values <- round(sapply(results, function(r) sqrt(attr(r, "x"))), 5)
    approximations <- round(sapply(results, function(r) tail(attr(r, "trace")$x_i, 1)), 5)
    errors <- round(sapply(results, function(r) attr(r, "error")), 5)

    table_data <- data.frame(
        "\\(S\\)" = numbers,
        "Newton-\\(\\sqrt{S}\\)" = approximations,
        "R-\\(\\sqrt{S}\\)" = true_values,
        Error = errors,
        check.names = FALSE
    )

    kable(table_data, format = "html", escape = FALSE) %>%
        kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) %>%
        column_spec(1, width = "5em") %>%
        column_spec(2, width = "8em") %>%
        column_spec(3, width = "8em") %>%
        column_spec(4, width = "8em") %>%
        row_spec(0, bold = TRUE)
}

# Function to plot all iteration traces in a single plot (updated to extract trace)
plot_traces_single <- function(results) {
    # Extract all traces
    traces_list <- lapply(results, function(r) attr(r, "trace")$x_i)
    max_len <- max(sapply(traces_list, length))

    # Pad shorter traces with NA to match longest iteration length
    traces_padded <- lapply(traces_list, function(trace) {
        length(trace) <- max_len
        trace
    })

    # Convert to matrix for plotting
    traces_matrix <- do.call(cbind, traces_padded)

    line_types <- rep(1:10, 5)
    matplot(1:max_len, traces_matrix,
        type = "b", col = rainbow(length(traces_padded)),
        lty = line_types[1:length(traces_padded)], lwd = 2,
        pch = 16, cex = 1.2,
        xlab = "Iteration", ylab = "Approximation",
        main = TeX("Traces of Approximating \\sqrt{S}")
    )

    # Add legend with correct labels
    x_values <- sapply(results, function(r) attr(r, "x"))
    trace_labels <- sapply(x_values, function(x) TeX(paste0("\\sqrt{", x, "}")))
    legend("topright",
        legend = trace_labels, col = rainbow(length(traces_padded)),
        lty = line_types[1:length(traces_padded)], pch = 16
    )
}

# # Function to generate Newton's method animation using newton_sqrt output
# generate_animation <- function(S, x0, gif_path) {
#     result <- newton_sqrt(S, x0) # Run Newton's method
#     trace <- attr(result, "trace") # Extract iteration trace
# 
#     f <- function(x) x^2 - S
#     x_range <- seq(min(trace$x_i) - 1, max(trace$x_i) + 1, length.out = 100)
#     df_func <- data.frame(x = x_range, y = f(x_range))
# 
#     # Compute tangent lines for each iteration
#     tangent_data <- data.frame()
#     for (i in 1:nrow(trace)) {
#         tangent_df <- compute_tangent(trace$x_i[i], trace$y[i], trace$slope[i], xrange = range(x_range))
#         tangent_df$iter <- i
#         tangent_data <- rbind(tangent_data, tangent_df)
#     }
# 
#     p <- ggplot() +
#         geom_line(data = df_func, aes(x = x, y = y), color = "blue", size = 1.2) +
#         geom_hline(yintercept = 0, linetype = "dashed") +
#         geom_point(data = trace, aes(x = x_i, y = 0), color = "red", size = 3) +
#         geom_segment(data = trace, aes(x = x_i, y = y, xend = x_i, yend = 0), color = "purple", linetype = "dotted") +
#         geom_line(data = tangent_data, aes(x = x, y = y, group = iter), color = "deeppink", size = 1.2, linetype = "solid") +
#         labs(title = "Newton's Method for sqrt(S): Iteration {frame_time}", x = "x", y = "f(x) = x² - S") +
#         theme_minimal() +
#         transition_time(iter)
# 
#     # Save animation as GIF
#     anim_save(gif_path, animate(p, renderer = gifski_renderer(), fps = 2, duration = 5, width = 600, height = 400))
# }

ui <- fluidPage(
    tags$head(
        tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML")
    ),
    withMathJax(),
    titlePanel("Newton's Method for Finding Square Roots"),
    h3("\\(\\sqrt{S}\\) Calculator"),
    # Titles side-by-side at the top
    fluidRow(
        column(3, h3("\\(S\\) and \\(x_0\\)(editable)")),
        column(6, h3("Results of Computing \\(\\sqrt{S}\\)"))
    ),

    # Sidebar + Main Panel (Both aligned under titles)
    fluidRow(
        column(
            3,
            rHandsontableOutput("input_table"), # Editable table
            actionButton("clearTable", "Clear Table"), # Reset table button
            selectInput("tol", "Select termination tolerence:",
                choices = c("10" = 10, "1" = 1, "0.1" = 0.1, "0.01" = 0.01, "0.001" = 0.001),
                selected = 0.001
            )
        ),
        column(
            6,
            uiOutput("result_table") # Displays numerical results table
        )
    ),

    # Convergence plot placed at the bottom spanning both panels
    fluidRow(
        column(9, plotOutput("convergence_plot"))
    ),
    h3("Newton's Method Explained"),
    withMathJax(HTML("
        <p>Newton’s method is an iterative process used to find the roots of a function. Given a function \\( f(x) \\), Newton's iteration formula is \\( x_{n+1} = x_n - \\frac{f(x_n)}{f'(x_n)} \\). To compute the square root of \\( S \\), we define \\( f(x) = x^2 - S \\). The derivative of \\( f(x) \\) is \\( f'(x) = 2x \\). Substituting these into Newton's formula yields \\( x_{n+1} = x_n - \\frac{x_n^2 - S}{2x_n} \\). Simplifying:</p>
        $$ x_{n+1} = \\frac{1}{2} \\left( x_n + \\frac{S}{x_n} \\right) $$

    ")),

    # Input fields for S and x0 displayed side-by-side
    h4("Typing your own \\(S\\) and \\(x_0\\) to visualize the iterations:"),
    fluidRow(
        column(2, offset = 2, div(style = "margin-bottom: 10px;", numericInput("example_S", "\\(S\\):", value = 25, min = 1))),
        column(2, div(style = "margin-bottom: 10px;", numericInput("example_x0", "\\(x_0\\):", value = 2, min = 1)))
    ),
    fluidRow(
        column(
            4, # Left: Iterations Section
            h4("Iterations:"),
            uiOutput("iterations") # Auto-generated steps
        ),
        column(
            6, # Right: Animation with Controls
            h4("Animation:"),
            fluidRow(
                column(1, actionButton("prev_step", "<")), # Move backward
                column(1, actionButton("next_step", ">")) # Move forward
            ),
            plotOutput("newton_animation", height = "400px", click = "newton_animation_click") # Display animation beside text
        )
    ),
    div(
        style = "margin-top: 30px; text-align: center; font-size: 14px;",
        HTML("<hr> Author: <strong>Longhai Li</strong><br>
              Department of Mathematics and Statistics, University of Saskatchewan<br>
              <a href='https://longhaisk.github.io' target='_blank'>https://longhaisk.github.io</a>")
    )
)

# Shiny Server
server <- function(input, output) {
    input_data <- reactiveValues(
        data = data.frame(S = c(2, 5, 7, 8, 9, 11), x0 = c(1, 2.5, 3.5, 4, 4.5, 5.5)))

    observeEvent(input$clearTable, {
        input_data$data <- data.frame(S = rep(0, 6), x0 = rep(1, 6))
    })
    output$input_table <- renderRHandsontable({
        req(input_data$data)
        rhandsontable(input_data$data, colHeaders = c("\\(S\\)", "\\(x_0\\)"))
    })
    observeEvent(input$input_table$data, {
        if (!is.null(input$input_table$data)) {
            input_data$data <- hot_to_r(input$input_table)
        }
    })
    
    results <- reactive({
        req(input_data$data)
        data <- input_data$data
        numbers <- data$S
        initial_values <- data$x0
        valid_rows <- !is.na(numbers) & numbers >= 0 & !is.na(initial_values) & initial_values > 0
        numbers <- numbers[valid_rows]
        initial_values <- initial_values[valid_rows]
        mapply(newton_sqrt, numbers, initial_values, tol = as.numeric(input$tol), SIMPLIFY = FALSE)
    })

    output$result_table <- renderUI({
        req(results())
        HTML(display_table(results()))
    })

    output$convergence_plot <- renderPlot({
        req(results())
        plot_traces_single(results())
    })


    # Compute Newton iterations reactively
    newton_results <- reactive({
        newton_sqrt(input$example_S, input$example_x0, tol = 0.001)
    })

    # Store the current iteration index
    current_step <- reactiveVal(1)

    # Reset step when S or x0 changes
    observeEvent(input$example_S,
        {
            current_step(1)
        },
        ignoreInit = TRUE
    )
    observeEvent(input$example_x0,
        {
            current_step(1)
        },
        ignoreInit = TRUE
    )

    # Display Iteration 0 (Initial Guess)


    # Dynamically generate iteration steps and highlight the active one
    output$iterations <- renderUI({
        trace <- attr(newton_results(), "trace")$x_i
        step <- current_step() # Get the current animation step

        # Handle Iteration 0 separately to avoid duplication
        merged_text <- paste0(
            "<p style='line-height: 3;", if (step == 1) " color: red; font-weight: bold;'" else "'>",
            "<strong>Iteration 0:</strong> \\( x_0 = ", round(trace[1], 5), " \\)</p>"
        )

        # Loop for Iterations 1, 2, ..., n
        merged_text <- paste0(
            merged_text,
            paste(
                sapply(1:(length(trace) - 1), function(i) {
                    paste0(
                        "<p style='line-height: 3;", if (i == step - 1) " color: red; font-weight: bold;'" else "'>",
                        "<strong>Iteration ", i, ":</strong> \\( x_", i,
                        " = \\frac{1}{2} \\left( ", round(trace[i], 5),
                        " + \\dfrac{", input$example_S, "}{", round(trace[i], 5), "} \\right) \\approx ",
                        round(trace[i + 1], 5), " \\)</p>"
                    )
                }),
                collapse = ""
            )
        )

        withMathJax(HTML(merged_text))
    })
    # Move forward when "Next Step" is clicked
    observeEvent(input$next_step, {
        trace <- attr(newton_results(), "trace")$x_i
        if (current_step() < length(trace)) {
            current_step(current_step() + 1) # Move to next step
        }
    })

    # Move backward when "Previous Step" is clicked
    observeEvent(input$prev_step, {
        if (current_step() > 1) {
            current_step(current_step() - 1) # Move to previous step
        }
    })

    # Render the animation for the current step

    
    output$newton_animation <- renderPlot({
        # Get the iteration trace (only x_i values) from newton_results()
        trace <- attr(newton_results(), "trace")$x_i
        # current_step() is 1-indexed; label for the plot should be (current_step() - 1)
        step <- current_step()
        iter_label <- step - 1 # Label for the plot (e.g., if step==1, label = 0)
        
        # Current x value at the iteration
        x_i <- trace[step]
        
        # Define the function f(x) = x^2 - S
        f <- function(x) x^2 - input$example_S
        
        # Expand the x_range to include some negative values
        x_range <- seq(min(min(trace) - 1, -2), max(trace) + 1, length.out = 100)
        df_func <- data.frame(x = x_range, y = f(x_range))
        
        # Compute a fixed y-range based solely on f(x)
        y_min <- min(df_func$y)
        y_max <- max(df_func$y)
        
        # Compute the tangent line at the current iteration
        slope <- 2 * x_i
        tangent_x <- seq(min(x_range), max(x_range), length.out = 100)
        tangent_y <- f(x_i) + slope * (tangent_x - x_i)
        df_tangent <- data.frame(x = tangent_x, y = tangent_y)
        
        # Create a LaTeX label for x_i using latex2exp (label shows x_{iter_label})
        label_expr <- TeX(paste0("$x_{", iter_label, "}$"))
        
        # Get the plotting area range based on ggplot limits
        plot_x_min <- min(x_range)
        plot_x_max <- max(x_range)
        
        # Find the maximum y-value within the plotting area (x_min, x_max)
        visible_x_range <- seq(plot_x_min, plot_x_max, length.out = 100)
        visible_y_values <- f(visible_x_range)
        max_y_index <- which.max(visible_y_values)
        max_x <- visible_x_range[max_y_index]
        max_y <- visible_y_values[max_y_index]
        
        # Build the plot
        ggplot() +
            geom_line(data = df_func, aes(x = x, y = y), color = "blue", size = 1.2) +
            geom_hline(yintercept = 0, linetype = "dashed") +
            geom_point(aes(x = x_i, y = 0), color = "red", size = 3) +
            geom_segment(aes(x = x_i, y = f(x_i), xend = x_i, yend = 0),
                         color = "purple", linetype = "dotted"
            ) +
            geom_line(
                data = df_tangent, aes(x = x, y = y),
                color = "deeppink", size = 1.2, linetype = "solid"
            ) +
            geom_text(aes(x = x_i, y = -1),
                      label = label_expr,
                      size = 6, vjust = 1.5
            ) +
            labs(
                title = TeX(sprintf("Iteration %d: $x_{%d}$ = %.4f", iter_label, iter_label, x_i)),
                x = "x",
                y = TeX("$f(x) = x^2 - S$")
            ) +
            scale_y_continuous(limits = c(y_min - 1, y_max + 1)) +
            theme_minimal() +
            
            # Add the LaTeX y-label "f(x) = x^2 - S" inside the plot with an arrow
            annotation_custom(
                grob = textGrob(TeX("$f(x) = x^2 - S$"), gp = gpar(fontsize = 12, col = "black")),
                xmin = min(x_range) + 0.5, ymin = y_max * 0.85
            ) +
            
            # Add an arrow pointing to the maximum of f(x) (blue color)
            annotation_custom(
                grob = linesGrob(
                    x = unit(c(min(x_range) + 0.5, max_x), "native"),
                    y = unit(c(y_max * 0.85, max_y), "native"),
                    gp = gpar(col = "blue", lwd = 1, arrow = arrow(type = "closed", length = unit(0.15, "inches")))
                )
            )
    })
    
}

shinyApp(ui, server)
