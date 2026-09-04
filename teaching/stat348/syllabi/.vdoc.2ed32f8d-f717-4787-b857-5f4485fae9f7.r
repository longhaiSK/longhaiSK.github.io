#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
#| message: false
#| warning: false
#| out-width: "100%"

library(gt)
library(dplyr)
library(tibble)

# 1. SETUP DATES (Estimated for Fall 2024)
start_date <- as.Date("2026-09-02")
break_date <- as.Date("2026-11-09")
end_date   <- as.Date("2026-12-07")

# Helper function to find the Monday of the week for any given date
get_monday <- function(d) { d - as.numeric(format(d, "%u")) + 1 }

first_monday <- get_monday(start_date)
break_monday <- get_monday(break_date)
last_monday  <- get_monday(end_date)

# Generate all Mondays for the term
term_dates <- seq(from = first_monday, to = last_monday, by = "week")

# 2. DEFINE COURSE TOPICS & TASKS (IN ORDER)
content_list <- tribble(
  ~Topic,                                                                 ~Base_Task,
  "1 Introduction to Sampling Techniques, R and R Markdown",              "",
  "1 Introduction to Sampling Techniques, R and R Markdown",              "",
  "2 Simple Random Sampling",                                             "",
  "2 Simple Random Sampling",                                             "",
  "3 Stratified Sampling",                                                "**Assignment 1 due**",
  "3 Stratified Sampling",                                                "",
  "4 Ratio and Regression Estimate",                                      "",
  "4 Ratio and Regression Estimate",                                      "**Midterm**",
  "4 Ratio and Regression Estimate",                                  "",
  "5 Cluster Sampling",                                  "**Assignment 2 due**",
  "5 Cluster Sampling",                                       "",
  "6 Unequal probability sampling",                                       "",
  "6 Unequal probability sampling",                                       "",
  "Review",                                                               "**Assignment 3 due**"
)

# 3. BUILD THE SCHEDULE DYNAMICALLY
schedule_list <- list()
acad_counter <- 1 # Tracks which topic we are on

for (i in seq_along(term_dates)) {
  curr_date <- term_dates[i]
  
  if (curr_date == break_monday) {
    # --- Reading Week ---
    schedule_list[[i]] <- data.frame(
      Date_Val  = curr_date,
      Date      = format(curr_date, "%b %d"),
      Acad_Week = "N/A",
      Topic     = "—",
      Task      = "**Fall Break – No classes**",
      stringsAsFactors = FALSE
    )
  } else {
    # --- Regular Academic Week ---
    curr_topic <- ifelse(acad_counter <= nrow(content_list), content_list$Topic[acad_counter], "TBD")
    curr_task  <- ifelse(acad_counter <= nrow(content_list), content_list$Base_Task[acad_counter], "")
    
    schedule_list[[i]] <- data.frame(
      Date_Val  = curr_date,
      Date      = format(curr_date, "%b %d"),
      Acad_Week = as.character(acad_counter),
      Topic     = curr_topic,
      Task      = curr_task,
      stringsAsFactors = FALSE
    )
    
    # Increment the topic counter
    acad_counter <- acad_counter + 1
  }
}

# Combine into a single dataframe
schedule_data <- do.call(rbind, schedule_list)

# 4. APPEND START & END TASKS
# Find the start week and append the start date note
start_idx <- which(schedule_data$Date_Val == first_monday)
if (length(start_idx) > 0) {
  prefix <- ifelse(schedule_data$Task[start_idx] == "", "", paste0(schedule_data$Task[start_idx], "<br>"))
  schedule_data$Task[start_idx] <- paste0(prefix, "**Course Starts (", format(start_date, "%b %d"), ")**")
}

# Find the end week and append the end date note
end_idx <- which(schedule_data$Date_Val == last_monday)
if (length(end_idx) > 0) {
  prefix <- ifelse(schedule_data$Task[end_idx] == "", "", paste0(schedule_data$Task[end_idx], "<br>"))
  schedule_data$Task[end_idx] <- paste0(prefix, "**Course Ends (", format(end_date, "%b %d"), ")**")
}

# Save index for highlighting the Reading Week
break_idx <- which(schedule_data$Date_Val == break_monday)

# Clean up the temporary internal date column
schedule_data$Date_Val <- NULL

# 5. CREATE THE GT TABLE
gt_tbl <- schedule_data %>%
  gt() %>%
  
  # Format column labels
  cols_label(
    Acad_Week = md("**Acad. Week**"),
    Date      = md("**Date**"),
    Topic     = md("**Topic**"),
    Task      = md("**Remark**")
  ) %>%
  
  # Process markdown in the Task column
  fmt_markdown(columns = c(Task)) %>%
  
  # Alignment
  cols_align(align = "center", columns = c(Acad_Week)) %>%
  cols_align(align = "left", columns = c(Date, Topic, Task)) %>%
  
  # Column widths
  cols_width(
    Acad_Week ~ pct(10),
    Date      ~ pct(10),
    Topic     ~ pct(55),
    Task      ~ pct(25)
  ) %>%
  
  opt_row_striping() %>%
  
  # Table Styling
  tab_options(
    table_body.hlines.style = "solid",
    table_body.vlines.style = "solid",
    table_body.hlines.color = "#E0E0E0",
    
    column_labels.vlines.style = "solid",
    column_labels.border.top.style = "solid",
    column_labels.border.bottom.style = "solid",
    column_labels.background.color = "#F0F0F0",
    
    table.border.top.style = "solid",
    table.border.bottom.style = "solid",
    table.font.size = px(13)
  ) %>%
  
  # Highlight the dynamically found break_date row
  tab_style(
    style = list(
      cell_fill(color = "#d1e7dd"),
      cell_text(weight = "bold", style = "italic")
    ),
    locations = cells_body(rows = break_idx)
  )

gt_tbl

#
#
#
#
#
#
#
#
#
#
#
#| echo: false
#| message: false
library(gt)
library(dplyr)

# Constructing the dataframe with updated Sampling Techniques skills
final_guide <- data.frame(
  Topic = c(
    "Principles & Bias",
    "Sampling Schemes",
    "Data Analysis",
    "R & Dissemination"
  ),
  Knowledge = c(
    "Understand the principles and methods used to design sampling schemes.",
    "Understand the characteristics of a well-designed survey, identifying possible sources of bias and measurement errors.",
    "Gain a comparative understanding of different schemes (simple, strata, cluster, unequal probabilities).",
    "Understand how to interpret outputs from datasets collected with different sampling schemes."
  ),
  Skills = c(
    "Design appropriate sampling schemes for finite populations.",
    "Critically evaluate survey designs and diagnose sources of bias.",
    "Analyze datasets collected with different schemes including simple sampling, strata, cluster, and unequal probabilities.",
    "Use R and Rmarkdown to analyze the datasets and disseminate the findings effectively."
  ),
  Percentages = c("20%", "20%", "40%", "20%")
)

outcome_tbl <- final_guide %>%
  gt() %>%
  cols_label(
    Topic = md("**Topic**"),
    Knowledge = md("**Knowledge**"),
    Skills = md("**Skills**"),
    Percentages = md("**Perc**")
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_body(columns = Topic)
  ) %>%
  opt_row_striping() %>%
  tab_options(
    table.width = pct(100),
    column_labels.background.color = "#E0E0E0",
    column_labels.font.weight = "bold",
    table.font.size = px(12),
    data_row.padding = px(5),
    row.striping.background_color = "#F5F5F5",
    table_body.hlines.color = "#B0B0B0", 
    table_body.hlines.width = px(1)
  ) %>%
  cols_width(
    Topic ~ pct(15),
    Knowledge ~ pct(35),
    Skills ~ pct(40),
    Percentages ~ pct(10)
  )

outcome_tbl

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
