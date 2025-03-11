library(ggplot2)
library(gganimate)

# Function to compute Newton's method and store iteration points
newton_sqrt_trace <- function(S, x0 = S / 2, tol = 1e-6) {
    if (S < 0) stop("Square root of a negative number is not defined for real numbers.")
    
    x_n <- x0
    trace <- data.frame(x_i = x_n, y = x_n^2 - S, slope = 2 * x_n)  # Store iteration points
    iter <- 0
    
    repeat {
        x_next <- 0.5 * (x_n + S / x_n)  # Newton's update formula
        iter <- iter + 1
        trace <- rbind(trace, data.frame(x_i = x_next, y = x_next^2 - S, slope = 2 * x_next))  
        
        if (abs(x_next - x_n) < tol) break
        x_n <- x_next
    }
    
    trace$iter <- 1:nrow(trace)  # Add iteration index
    return(trace)
}

# Function to compute tangent line points
compute_tangent <- function(x0, y0, slope, xrange = c(-10, 10)) {
    x_vals <- seq(xrange[1], xrange[2], length.out = 100)
    y_vals <- y0 + slope * (x_vals - x0)
    data.frame(x = x_vals, y = y_vals)
}

# Function to create animated plot with solid pink tangent lines
animate_newton_sqrt <- function(S, x0 = S / 2) {
    trace <- newton_sqrt_trace(S, x0)
    
    # Define function curve f(x) = x^2 - S
    f <- function(x) x^2 - S
    x_range <- seq(min(trace$x_i) - 1, max(trace$x_i) + 1, length.out = 100)
    df_func <- data.frame(x = x_range, y = f(x_range))
    
    # Compute tangent lines for each iteration
    tangent_data <- data.frame()
    for (i in 1:nrow(trace)) {
        tangent_df <- compute_tangent(trace$x_i[i], trace$y[i], trace$slope[i], xrange = range(x_range))
        tangent_df$iter <- trace$iter[i]
        tangent_data <- rbind(tangent_data, tangent_df)
    }
    
    # Create animated plot
    p <- ggplot() +
        geom_line(data = df_func, aes(x = x, y = y), color = "blue", size = 1.2) +  # Function curve
        geom_hline(yintercept = 0, linetype = "dashed") +  # x-axis
        geom_point(data = trace, aes(x = x_i, y = 0), color = "red", size = 3) +  # Iteration points
        geom_segment(data = trace, aes(x = x_i, y = y, xend = x_i, yend = 0), color = "purple", linetype = "dotted") +  # Drop lines
        geom_line(data = tangent_data, aes(x = x, y = y, group = iter), color = "deeppink", size = 1.2, linetype = "solid") +  # Solid pink tangent lines
        labs(title = "Newton's Method for sqrt(S): Iteration {frame_time}", x = "x", y = "f(x) = x² - S") +
        theme_minimal() +
        transition_time(iter)  # Animate over iteration steps
    
    # Render animation in RStudio Viewer
    animate(p, renderer = gifski_renderer(), fps = 2, duration = 5, width = 600, height = 400)
}

# Example usage
animate_newton_sqrt(S = 29, x0 = 11)
