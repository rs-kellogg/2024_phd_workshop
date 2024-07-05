###############################
# Sample File for TAQ database
###############################

# import packages
import wrds
import pandas as pd
import csv
import textwrap
import time
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns

# wrds connection
conn = wrds.Connection(wrds_username='best-user-ever')

# inputs for a date and ticker
dd = '20230622'
stock = "AAPL"


####
# Create and execute a SQL query
####

# Create the SQL query to get a table from the TAQ database
sql = f"""
SELECT CONCAT(date, ' ', time_m) AS DT,
       ex, sym_root, sym_suffix, price, size, tr_scond
FROM taqmsec.ctm_{dd}
WHERE (ex = 'N' OR ex = 'T' OR ex = 'Q' OR ex = 'A')
  AND sym_root = '{stock}'
  AND price != 0 AND tr_corr = '00'
"""

# Execute the query
df_aapl = conn.raw_sql(sql)

# print the column names
print(df_aapl.columns)


####
# Obtain 5 minute average price
####

# Convert the 'dt' column to datetime
df_aapl['dt'] = pd.to_datetime(df_aapl['dt'])

# Round 'dt' to the nearest 5-minute mark
df_aapl['dt'] = df_aapl['dt'].dt.round('5Min')

# Set 'dt' as the index
df_aapl.set_index('dt', inplace=True)

# Resample to get the average price every five minutes
df_aapl_resampled = df_aapl['price'].resample('5Min').mean()

#####
# Merge the two DataFrames
#####

# Reset the index of both DataFrames
df_aapl.reset_index(inplace=True)
df_aapl_resampled = df_aapl_resampled.reset_index()

# Rename the column in df_aapl_resampled to avoid a naming conflict during the merge
df_aapl_resampled.rename(columns={'price': 'avg_price'}, inplace=True)

# Merge the two DataFrames
df_aapl = df_aapl.merge(df_aapl_resampled, on='dt', how='left')

# Fill NaN values in the 'avg_price' column
df_aapl['avg_price'].fillna(method='ffill', inplace=True)



#####
# Plot the price series
#####

# Create a new figure
plt.figure(figsize=(10, 6))

# Plot the price series
sns.lineplot(x='dt', y='price', data=df_aapl, color='gray')

# Plot the aggregated price series
sns.scatterplot(x='dt', y='avg_price', data=df_aapl, color='blue', s=50)

# Set the x-axis label
plt.xlabel('')

# Set the y-axis label
plt.ylabel('Intraday price in USD')

# Set the y-axis limits
plt.ylim(df_aapl['price'].min(), df_aapl['price'].max())

# Set the x-axis major ticks to 60-minute intervals
plt.gca().xaxis.set_major_locator(mdates.MinuteLocator(interval=60))

# Set the x-axis major tick labels to the format HH:MM
plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))

# Set the title of the plot
plt.title(f'AAPL on {df_aapl["dt"].dt.date.unique()[0]}')

# Show the plot
plt.show()


