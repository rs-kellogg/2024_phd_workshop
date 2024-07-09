#############################################
# Answer Key - add company name to CRSP query
#############################################

# load library
library(RPostgres)

year_input <- 2020
outdir  <- "~/answer_key/wrds/output"


# Test for existence of outdir before attempting to write
if (!dir.exists(outdir)) {
  dir.create(outdir)
}

# If necessary, create an activity log file
logfile = paste(outdir,"/activity_log.txt",sep="")
if (!file.exists(logfile)){
  fileConn <- file(logfile)
  writeLines("Date|Filepath|Year|nrows", fileConn)
  close(fileConn)
}

library(RPostgres)

# Create a connection called "wrds"
wrds <- dbConnect(Postgres(),
                  host='wrds-pgdata.wharton.upenn.edu',
                  port=9737,
                  dbname='wrds',
                  sslmode='require',
                  user='<enter_wrds_username>')
# AT THIS POINT, EXPECT A DUO PUSH

print("connected to wrds")

# CRSP tables: https://wrds-www.wharton.upenn.edu/data-dictionary/crsp_a_stock/
# table with comnam: https://wrds-www.wharton.upenn.edu/data-dictionary/crsp_a_stock/stocknames/


# FUNCTION TO PULL ONE YEAR OF CRSP DSF linked with SECURITY INFO
download_dsfenhanced <- function(year, outdir) {
  # Define a SELECT query
  query = "select a.cusip, a.permco, a.permno, issuernm, b.ticker, date, prc, ret, numtrd, vol, securitytype, c.comnam "
  query = paste(query, "from crsp.dsf as a ", sep="")
  query = paste(query, "left join crsp.wrds_names_query as b ", sep="")
  query = paste(query, "on a.cusip = b.cusip and a.date >= b.secinfostartdt and a.date <= b.secinfoenddt ", sep="")
  query = paste(query, "left join crsp.stocknames as c ", sep="")
  query = paste(query, "on a.permno = c.permno and a.permco = c.permco ", sep="")
  query = paste(query, "where date >= '", year, "-01-01' and ", sep="")
  query = paste(query, "date <= '", year, "-12-31'", sep="")


  # query
  
  # Execute the select query
  res <- dbSendQuery(wrds, query)
  data <- dbFetch(res)
  
  outfile = paste("dsf_enhanced_comnam",year,Sys.Date(),sep="_")
  outpath = paste(outdir, "/", sep="") 
  outpath = paste(outpath, outfile, ".csv", sep="")
  
  # Write "data" dataframe to external file
  write.csv(data, outpath, row.names=TRUE)
  
  # Write to activity log also
  stringout = ""
  stringout = paste(Sys.Date(),outpath,year,nrow(data),sep="|")
  write(stringout,file=logfile,append=TRUE)
  
  # Clean up workspace
  dbClearResult(res)
  
} #end download_dsfenhanced


download_dsfenhanced(year_input, outdir)

print("sucessful query!")
