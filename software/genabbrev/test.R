library(stringr)

# Load the function (assuming it's in a file named "abbreviation_functions.R")


#debug("extract_abbreviations_r")
# Test cases and output
source("app.R")

extract_abbreviations <- function(text) {
    pattern <- "((?:[\\w-]+\\s+){1,10})\\((([a-z]*[A-Z]{2,})[a-z]*)\\)"
    matches <- gregexpr(pattern, text, perl = TRUE)
    matches <- regmatches(text, matches)[[1]]
    
    abbreviation_dict <- list()
    
    for (match in matches) {
        words_ahead <- unlist(strsplit(gsub("\\s+|(?<=-)(?=[A-Za-z])", " ", trimws(sub("\\((.*)\\)$", "", match))), " "))
        abbr <- sub(".*\\((.*)\\)$", "\\1", match)
        abbr_letters <- unlist(strsplit(gsub("[^A-Z]", "", toupper(abbr)), ""))
        
        full_name_words <- c()
        abbr_index <- 0
        
        for (word in rev(words_ahead)) {
            if (nchar(word) > 0 && abbr_index < length(abbr_letters) && nchar(gsub("-", "", word)) > 0 && toupper(substr(gsub("-", "", word), 1, 1)) == abbr_letters[length(abbr_letters) - abbr_index]) {
                full_name_words <- c(word, full_name_words)
                abbr_index <- abbr_index + 1
            }
            if (abbr_index == length(abbr_letters)) {
                break
            }
        }
        
        if (length(full_name_words) == length(abbr_letters)) {
            full_name <- paste(full_name_words, collapse = " ")
            abbreviation_dict[[abbr]] <- full_name
        }
    }
    
    return(abbreviation_dict)
}
cat("Test Case 1:\n")
text1 <- "Cox proportional-hazard (PH) regression models are widely used.\n"
cat("Input:\n", text1)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text1)), "\n\n")
cat("Test Case 1:\n")
text1 <- "Cox proportional hazard (PH) regression models are widely used.\n"
cat("Input:\n", text1)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text1)), "\n\n")



cat("Test Case 2:\n")
text2 <- "The Akaike information criterion (AIC) and the proportional hazards (PH) assumption are important. Analysis of Variance (ANOVA) is also used.\n"
cat("Input:\n", text2)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text2)), "\n\n")

cat("Test Case 3:\n")
text3 <- "PH (proportional hazard) regression models are widely used.\n"
cat("Input:\n", text3)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text3)), "\n\n")

cat("Test Case 4:\n")
text4 <- "Interleukin 6 (IL-6) is a cytokine.\n"
cat("Input:\n", text4)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text4)), "\n\n")

cat("Test Case 5:\n")
text5 <- "Tumor necrosis factor-alpha (TNF-alpha) is a cytokine.\n"
cat("Input:\n", text5)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text5)), "\n\n")

cat("Test Case 6:\n")
text6 <- "This is a longer sentence with more words preceding the abbreviation, such as proportional hazard (PH) models.\n"
cat("Input:\n", text6)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text6)), "\n\n")

cat("Test Case 7:\n")
text7 <- "This text has no abbreviations.\n"
cat("Input:\n", text7)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text7)), "\n\n")

cat("Test Case 8:\n")
text8 <- "This is some text with an abbreviation with nested parentheses, like example (eg (with parens)).\n"
cat("Input:\n", text8)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text8)), "\n\n")

cat("Test Case 9:\n")
text9 <- "1000 Genomes Project (1000GP) is a project.\n"
cat("Input:\n", text9)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text9)), "\n\n")

cat("Test Case 10:\n")
text10 <- "red blood cell (RBC) is a cell.\n"
cat("Input:\n", text10)
cat("Output:\n", format_abbreviations_r(extract_abbreviations_r(text10)), "\n\n")