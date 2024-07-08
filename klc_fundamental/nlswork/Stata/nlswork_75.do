*----------------------------------------------
* PROCESS NLSWORK Data for the specified year
*----------------------------------------------
// This file uses the NLSWork dataset to analyze wage distribution by age.  
// It 1.) cleans, 2.) graphs, and 3.) runs a regression for a certain year.

// Define the year variable
local year 75

// Clear any existing logs and start a new log
clear
log using nlswork_`year'.log, replace

// Load the "nlswork" dataset from Stata website
use https://www.stata-press.com/data/r17/nlswork.dta

// Save the dataset locally
save nlswork.dta, replace

*----------------------------------------------
* CREATE A TABLE: Interview counts by year
*----------------------------------------------

// Generate a table of interview counts by year
tabulate year, matcell(interview_counts)

// Create a formatted table using estout
estout matrix(interview_counts, fmt(%10.0f)) using "annual_interviews.txt", ///
    title("NLSWork Interviews by Year (`year')") replace

*----------------------------------------------
* CLEAN DATA FOR ANALYSIS
*----------------------------------------------

// Describe the dataset
describe

// Clean the data: Remove NA values from wage, age, and ttl_exp variables
drop if mi(ln_wage) | mi(age) | mi(ttl_exp)

// Subset the dataset for the specified year
keep if year == `year'

*----------------------------------------------
* PLOT: Wage distribution by age
*----------------------------------------------

// Scatter plot of wage distribution by age
scatter ln_wage age, title("Wage Distribution by Age (`year')") ///
    xtitle("Age") ytitle("Wage")

// Save the scatter plot to a file (e.g., PNG format)
graph export "scatterplot_wage_age_`year'.png", replace

*----------------------------------------------
* RUN A REGRESSION
*----------------------------------------------

// Run a linear regression of ln_wage on age
regress ln_wage age

// Create a formatted output of the regression results using estout
estout, title("Linear Regression: ln_wage on age (`year')") cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) replace

// Close the log
log close

