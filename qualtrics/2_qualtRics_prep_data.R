###########################
# Retrieving Qualtrics Results
############################

# Set Global Parameters
packages  <- c("qualtRics","dplyr","stringr")
inputfile <- "C:\\Users\\jpj8711\\downloads\\SV_eDjV9Qa04XrwsDk.rds"     # "/kellogg/proj/jpj8711/qualtrics/"
outdir    <- "C:\\Users\\jpj8711\\downloads\\modified"     # "/kellogg/proj/jpj8711/qualtrics/"

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

# If necessary, create directory where output will be saved
if (!dir.exists(outdir)) {
  dir.create(outdir)
}

# Read the original survey in
mysurvey <- readRDS(inputfile)
nrow(mysurvey)

# Fix problem of spaces in column names!
names(mysurvey) <- str_replace_all(names(mysurvey),c(" "=".", ","=""))
names(mysurvey)[names(mysurvey) == "Duration.(in.seconds)"] <- "Duration"
colnames(mysurvey)
View(mysurvey)

### FILTERING
# Eliminate test responses
mysample <- filter(mysurvey, Q5 != "delete me")


# Function to return total respondents and % who are female
sample_count <- function(a) {
  females <- filter(a, Gender == "Female")
  pct_female <- percent((nrow(females) / nrow(a)),1)
  return = paste("The sample now contains ", nrow(a), " reponses, ", pct_female, " of which are from subjects who identify as female.", sep="", collapse=NULL) 
  return
}
sample_count(mysample)

# More filtering examples
# Did you pass the attention check?
mysample2 <- filter(mysample, Check == "eleven")
print("We removed anyone who failed the comprehension check.")
sample_count(mysample2)


# Three ways to eliminate outliers for response time
# (a) Using a hard cutoff...
print("We removed observations where total duration was greater than 5 minutes.")
mysample3a <- filter(mysample2, Duration < 300)
sample_count(mysample3a)

# (b) using quantiles...
quant_duration <- quantile(mysample$`Duration`, probs=seq(0,1,.05), na.rm=FALSE, names=FALSE)
quant_duration
mysample3b <- filter(mysample2,   `Duration` > quant_duration[2])
mysample3b <- filter(mysample3b, `Duration` < quant_duration[20])
sample_count(mysample3b)

# (c) using mean and standard deviation
#print(mean(mysample2$Duration))
#print(  sd(mysample2$Duration))
mysample3c <- filter(mysample2, `Duration` < mean(mysample2$Duration) + 1.645*sd(mysample2$Duration))
print("We removed responses that were more than 1.645 standard deviations beyond mean response time.")
sample_count(mysample3c)


