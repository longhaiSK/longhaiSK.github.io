# Define log_add_exp and log_minus_exp for stable logarithmic addition and subtraction
log_add_exp <- function(log_a, log_b) {
    max_val <- max(log_a, log_b)
    return(max_val + log(1 + exp(min(log_a, log_b) - max_val)))
}

log_minus_exp <- function(log_a, log_b) {
    max_val <- max(log_a, log_b)
    return(max_val + log(exp(min(log_a, log_b) - max_val) - 1))
}

# Function to compute the square root using the Taylor series and logarithmic addition/subtraction
sqrt_taylor_log <- function(S, x0 = 1, tol = 1e-6) {
    if (S < 0) stop("S must be non-negative")  # Square root is undefined for negative numbers
    
    # Initialize sum and first term
    sum_result <- log(x0)  # Start with the logarithm of x0
    term_log <- log(abs(S - x0^2)) - log(2 * x0)  # First term in logarithmic form
    n <- 1  # Term counter
    trace <- c(sum_result)  # Store the initial value of the sum
    
    # Iterate until the term is smaller than the tolerance in logarithmic form
    while (exp(term_log) > tol) {
        # Compute the next term (logarithmic)
        term_log <- log(abs((S - x0^2)^n)) - log(factorial(n) * (2 * x0)^(2 * n + 1))
        
        # Update the sum using log_add_exp or log_minus_exp
        sum_result <- log_add_exp(sum_result, term_log)  # Add the log term to the sum
        trace <- c(trace, sum_result)  # Store the partial sum trace
        
        # Move to the next term
        n <- n + 1
    }
    
    # Return the square root approximation and the trace
    structure(exp(sum_result), trace = trace)
}

# Example usage
result <- sqrt_taylor_log(5, x0 = 1.5)
print(result)  # Square root approximation
print(attr(result, "trace"))  # Partial sum trace


plot_sqrt_taylor_trace <- function(taylor_result, true_value = NULL) {
    trace <- attr(taylor_result, "trace")  # Extract trace
    
    if (is.null(trace)) stop("No trace found. Ensure input is from sqrt_taylor_loop function.")
    
    # Set dynamic ylim based on trace and true value (if provided)
    min_value <- min(c(trace, true_value), na.rm = TRUE)
    max_value <- max(c(trace, true_value), na.rm = TRUE)
    
    # Plot the partial sums from the Taylor series
    plot(seq_along(trace), trace, type = "b", pch = 19, col = "blue",
         xlab = "Iteration", ylab = "Partial Sum", 
         main = "Convergence of Taylor Series for sqrt(S)",
         ylim = c(min_value, max_value))  # Dynamic y-axis limits
    
    # Add the true value line if provided
    if (!is.null(true_value)) {
        abline(h = true_value, col = "red", lty = 2)  # Red dashed line for true value
        legend("topright", legend = c("Taylor Series Approximation", "True Value"), 
               col = c("blue", "red"), lty = c(1, 2))
    }
}


S <-5
result <- sqrt_taylor(S, a = 4, tol = 1e-20)  # Compute sqrt(10) with tolerance
print(result)  # Display the final approximation

plot_sqrt_taylor_trace(result, sqrt(S))  # Plot the convergence trace
