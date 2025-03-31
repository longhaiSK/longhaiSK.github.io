library(RSelenium)

# --- Step 1 & 2: Start WebDriver and Connect for CHROME ---

# Define Chrome-specific capabilities for headless mode
eCaps <- list(
    chromeOptions = list(
        args = list('--headless', '--disable-gpu', '--window-size=1280,800')
    )
)

# Attempt to start rsDriver with Chrome
# Ensure chromedriver matching your Chrome version is available
# If chromedriver is not in PATH, you might need to specify its version/path
# Check rsDriver documentation for 'chromever' argument or other ways.
# Setting check = FALSE can sometimes bypass problematic version checks if needed,
# but ensure your driver version IS correct manually.
rD <- tryCatch({
    rsDriver(
        browser = "chrome",
        chromever = NULL, # Set to specific version '115.0.5790.170' or NULL to auto-detect/use PATH
        extraCapabilities = eCaps,
        verbose = TRUE,    # See output during startup
        check = FALSE      # Consider setting check = TRUE first
        # port = free_port() # Automatically find a free port if needed
    )
}, error = function(e) {
    message("Failed to start rsDriver for Chrome.")
    message("Ensure chromedriver matching your Chrome version is installed and in PATH or specified correctly.")
    message("Download from: https://googlechromelabs.github.io/chrome-for-testing/")
    message("Error: ", e$message)
    return(NULL)
})

# Get the client object if successful
remDr <- NULL
if (!is.null(rD)) {
    remDr <- rD[["client"]]
}

# Check if connection successful
if (is.null(remDr)) {
    stop("Could not connect to WebDriver. Aborting.")
} else {
    cat("Chrome WebDriver session started.\n")
}

# --- Steps 3-7 remain conceptually the same ---
# You use 'remDr' object as before

# Step 3: Navigate (remDr$navigate(full_url))
# Step 4: Wait (Sys.sleep or explicit wait using remDr$findElement)
# Step 5: Locate Element (remDr$findElement using CSS/XPath - selector MIGHT need slight tweaks)
# Step 6: Extract Text (output_element$getElementAttribute("value"))
# Step 7: Clean Up (remDr$close(), rD$server$stop())


# Load the rvest library
library(rvest)
library(httr2)
library(rvest) # Load rvest for text extraction

# 1. Define Base URL and the RAW text content
# Note: Backslashes within the R string must be escaped (e.g., \beta becomes \\beta)
library(rvest)

base_url <- r"(http://localhost:8502/)"
base_url <- r"(https://genabbre-longhaisk.streamlit.app/)"

# Use raw string for the text (simpler!) - Requires R >= 4.0.0
raw_text <- r"(This is an example of an input text  (EIT).)" #In this paper, we propose utilizing $\beta$-\( Z \)-residuals ($\beta$$Z$R) to diagnose Cox PH models. The recent studies by Li et al. 2021 \cite{LiLonghai2021Mdfc} and Wu et al. 2024 \cite{WuTingxuan2024Zdtf} introduced the concept of randomized survival probabilities (RSP) to define Z-residuals for diagnosing model assumptions in accelerated failure time (AFT) and shared frailty models. The RSP approach involves replacing the survival probability of a censored failure time (SPCFT) with $u$ random numbers ($u$RN) between 0 and the survival probability of the censored time (SPCT) \cite{WuTingxuan2024Zdtf}.)"

encoded_text <- URLencode(raw_text, reserved = TRUE)
full_url <- paste0(base_url, "?text=", encoded_text); full_url

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

extracted_text_output



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