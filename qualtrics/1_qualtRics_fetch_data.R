###########################
# Retrieving Qualtrics Results
############################

# Set Global Parameters
packages <- c("qualtRics","dplyr","stringr")
outdir <- "C:\\Users\\jpj8711\\downloads\\"     # "/kellogg/proj/jpj8711/qualtrics/"
sname  <- "Response Pilot 2023 (Prolific)"

## RUN THIS STEP FIRST TIME ONLY, TO GENERATE ".Renviron" FILE
#qualtrics_api_credentials(api_key = "INSERT YOUR API KEY HERE",
#                          base_url = "ca1.qualtrics.com",
#                          install = TRUE, 
#                          overwrite = TRUE)
readRenviron("~/.Renviron")

# Check, install, and load packages if necessary
for (p in packages) {
  if (!p %in% installed.packages()) {
    install.packages(p, dependencies = TRUE)
  }
  if (!p %in% .packages())  {
    library(p, character.only = TRUE)
  }  
}

#library(data.table)
#library(formattable)


# OPTIONAL: List all my surveys 
surveys   <- all_surveys()
surveys

# Select one project by name
myproject <- filter(surveys, name==sname)
myproject
myproject$id[1]

#Fetch the survey for that project as .RDS file
mysurvey <- fetch_survey(surveyID = myproject$id[1],
                         save_dir = outdir,
                         force_request = TRUE,
                         verbose = TRUE)
nrow(mysurvey)

# If necessary, create directory where output will be saved
if (!dir.exists(outdir)) {
  dir.create(outdir)
}

# If necessary, create an activity log file
logfile = paste(outdir,"/activity_log.txt",sep="")
if (!file.exists(logfile)){
  fileConn <- file(logfile)
  writeLines("Date|SurveyID|SurveyName|nrows", fileConn)
  close(fileConn)
}

# Read RDS file into dataframe "mysurvey", and save copy as CSV
rdspath <- paste(outdir, "/", myproject$id[1], ".rds", sep="")
mysurvey <- readRDS(file = rdspath)
csvpath <- paste(outdir, "/", myproject$id[1], ".csv", sep="")
ret <- write.csv(x=mysurvey, file=csvpath)

# Write an entry to activity log file

stringout = ""
stringout = paste(Sys.Date(),csvpath,sname,nrow(mysurvey),sep="|")
stringout
write(stringout,file=logfile,append=TRUE)




