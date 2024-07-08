############################
#  Analyze NLSWork Dataset #
############################
# This file uses the NLSWork dataset to analyze wage distribution by age.  
# It 1.) cleans, 2.) graphs, and 3.) runs a regression for a certain year.

# input libraries
library(haven)

########
# Inputs
########
# year <- 75

# Run the script with the year as a command line argument
# Rscript nlswork_year.R 75

# command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("Please provide the year as a command line argument.")
}
year <- as.numeric(args[1])

###########
# Functions
###########

# download nlswork data
download_data <- function(url, destfile) {
  cat("Downloading dataset...\n")
  download.file(url, destfile, mode = "wb")
}

# load nlswork data
load_data <- function(filepath) {
  cat("Loading dataset...\n")
  read_dta(filepath)
}

# create interview counts table
create_interview_counts_table <- function(data) {
  cat("Generating interview counts by year...\n")
  interview_counts <- table(data$year)
  write.table(interview_counts, file = "annual_interviews.txt", col.names = NA)
}

# clean data
clean_data <- function(data) {
  cat("Cleaning data...\n")
  cat("Initial dimensions:\n")
  print(dim(data))
  cleaned_data <- na.omit(data[, c("ln_wage", "age", "ttl_exp", "year")])
  cat("Dimensions after removing NA values:\n")
  print(dim(cleaned_data))
  cleaned_data
}

# subset data by selected year
subset_data_by_year <- function(data, year) {
  cat(sprintf("Subsetting data for the year %d...\n", year))
  subset_data <- subset(data, year == year)
  cat(sprintf("Dimensions after subsetting for the year %d:\n", year))
  print(dim(subset_data))
  subset_data
}


# plot wage distribution by age
plot_wage_distribution <- function(data) {
  cat("Plotting wage distribution by age...\n")
  plot(data$age, data$ln_wage, main = "Wage Distribution by Age", xlab = "Age", ylab = "Wage")
  dev.copy(pdf, file = "Rplots.pdf")
  dev.off()
  plot_name = paste("scatterplot_wage_age_", year, ".pdf", sep="")
  file.rename("Rplots.pdf", plot_name)
}

# run regression for selected year
run_regression <- function(data,year) {
  cat("Running regression...\n")
  lm_results <- lm(ln_wage ~ age, data = data)
  cat("Regression Summary:\n")
  print(summary(lm_results))
  reg_results_text = paste("reg_results", year, ".txt", sep="")
  write.table(lm_results$coefficients, file=reg_results_text)
}

########
# Run
########

download_data("https://www.stata-press.com/data/r17/nlswork.dta", "nlswork.dta")
nlswork <- load_data("nlswork.dta")
create_interview_counts_table(nlswork)
nlswork_cleaned <- clean_data(nlswork)
nlswork_subset <- subset_data_by_year(nlswork_cleaned, year)
plot_wage_distribution(nlswork_subset)
run_regression(nlswork_subset,year)
cat("Analysis completed.\n")


