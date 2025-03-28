# Load the rvest library
library(rvest)
library(httr2)
library(rvest) # Load rvest for text extraction

# 1. Define Base URL and the RAW text content
# Note: Backslashes within the R string must be escaped (e.g., \beta becomes \\beta)
library(rvest)

base_url <- r"(http://localhost:8502/)"

# Use raw string for the text (simpler!) - Requires R >= 4.0.0
raw_text <- r"(This is an example of an input text  (EIT). In this paper, we propose utilizing $\beta$-\( Z \)-residuals ($\beta$$Z$R) to diagnose Cox PH models. The recent studies by Li et al. 2021 \cite{LiLonghai2021Mdfc} and Wu et al. 2024 \cite{WuTingxuan2024Zdtf} introduced the concept of randomized survival probabilities (RSP) to define Z-residuals for diagnosing model assumptions in accelerated failure time (AFT) and shared frailty models. The RSP approach involves replacing the survival probability of a censored failure time (SPCFT) with $u$ random numbers ($u$RN) between 0 and the survival probability of the censored time (SPCT) \cite{WuTingxuan2024Zdtf}.)"

encoded_text <- URLencode(raw_text, reserved = TRUE)
full_url <- paste0(base_url, "?text=", encoded_text)

cat("Using URL (first 100 chars):", substr(full_url, 1, 100), "...\n")

cat("\nFetching and extracting visible text from the Streamlit app...\n")
extracted_text_output <- tryCatch({
    page <- read_html(full_url)
    page |> html_text2()
}, error = function(e) {
    message(paste("Error accessing Streamlit app URL:", full_url))
    message(paste("Error message:", e$message))
    return(NULL)
})

# ... (rest of the code to display output) ...
# 2. URL-encode the text using base R's URLencode
#    reserved = TRUE ensures characters like $ & + / : ; = ? @ are encoded
encoded_text <- URLencode(raw_text, reserved = TRUE)

# 3. Construct the full URL
full_url <- paste0(base_url, "?text=", encoded_text)

# Optional: Print the URL to verify encoding (can be very long)
# cat("Using URL:", substr(full_url, 1, 100), "...\n")

# 4. Fetch the HTML, parse it, and extract visible text using rvest
cat("\nFetching and extracting visible text from the Streamlit app...\n")
extracted_text_output <- tryCatch({
    # read_html fetches the URL and parses the HTML content
    page <- read_html(full_url)
    # html_text2 attempts to render text more like a browser would show it
    page |> html_text2()
}, error = function(e) {
    message(paste("Error accessing Streamlit app URL or parsing HTML:", full_url))
    message(paste("Please ensure the Streamlit app is running at", base_url))
    message(paste("Error message:", e$message))
    return(NULL) # Return NULL on error
})

# 5. Display the extracted text
if (!is.null(extracted_text_output)) {
    cat("\n--- Extracted Visible Text from App Page ---\n")
    # Print the whole output, as it might contain the formatted list
    cat(extracted_text_output, "\n")
    cat("-------------------------------------------\n")
} else {
    cat("Failed to get output from the Streamlit app.\n")
}