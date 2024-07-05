###############################
# Sample File for TAQ database
###############################

# import packages
library(DBI)
library(RPostgres)
library(dplyr)
library(lubridate)
library(ggplot2)

# Connect to WRDS
con <- dbConnect(Postgres(),
                 host='wrds-pgdata.wharton.upenn.edu',
                 port=9737,
                 dbname='wrds',
                 sslmode='require',
                 user='best-user-ever')

# Define date and stock
dd <- '20230622'
stock <- "AAPL"


####
# Create and execute a SQL query
####

# Create SQL query
sql <- paste0("
  SELECT CONCAT(date, ' ', time_m) AS DT,
         ex, sym_root, sym_suffix, price, size, tr_scond
  FROM taqmsec.ctm_", dd, "
  WHERE (ex = 'N' OR ex = 'T' OR ex = 'Q' OR ex = 'A')
    AND sym_root = '", stock, "'
    AND price != 0 AND tr_corr = '00'
")

# Execute the query
df_aapl <- dbGetQuery(con, sql)

####
# Obtain 5 minute average price
####

#Convert 'DT' to datetime and round to nearest 5 minutes
df_aapl$dt <- round_date(as.POSIXct(df_aapl$dt, format = "%Y-%m-%d %H:%M:%OS"), "5 minutes")

# Obtain 5 minute average price
df_aapl_resampled <- aggregate(price ~ dt, df_aapl, function(x) mean(x, na.rm = TRUE))
colnames(df_aapl_resampled)[2] <- "avg_price"

#####
# Merge the two DataFrames
#####

# Merge the two data frames
df_aapl$avg_price <- NULL
df_aapl <- merge(df_aapl, df_aapl_resampled, by = "dt", all.x = TRUE)

# Fill NA values in 'avg_price'
na_locs <- which(is.na(df_aapl$avg_price))
df_aapl$avg_price[na_locs] <- df_aapl$avg_price[na_locs - 1]

# print the column names
print(colnames(df_aapl))

# print the number of columns and rows
print(dim(df_aapl))

#####
# Plot the price series
#####


# Plot the price series
ggplot(df_aapl, aes(x = dt)) +
  geom_line(aes(y = price), color = "gray") +
  geom_point(aes(y = avg_price), color = "blue", size = 2) +
  scale_y_continuous("Intraday price in USD", limits = c(min(df_aapl$price), max(df_aapl$price))) +
  scale_x_datetime("", date_labels = "%H:%M", date_breaks = "60 min") +
  ggtitle(paste0("AAPL on ", unique(as.Date(df_aapl$dt)))) +
  theme_minimal()