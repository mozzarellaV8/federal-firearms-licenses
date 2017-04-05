# ATF - Federal Firearms Licenses
# import and binding data

# https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2015

# load data -------------------------------------------------------------------

library(readxl)

# create a list of files for each directory
# loop through each directory, reading the .xlsx files
# add columns for month and year
# bind each .xlsx file into it's own dataframe

# read and bind data by year --------------------------------------------------

# 2016 ------------------------------------------------------------------------
# Sept (09) and Oct (10) are not available

# set directory to read data from
y2016_dir <- "~/GitHub/federal-firearms-licenses/data/00-ATF-FFL-raw/2016"
setwd(y2016_dir)

# create a list of .xlsx files to read in
y2016_list <- list.files(path = y2016_dir, pattern = ".xlsx", recursive = T, all.files = T)

# initialize a dataframe to store imported data
y2016 <- data.frame()

# loop to read in data and bind
system.time(
for(i in 1:length(y2016_list)) {
  
  temp <- read_excel(y2016_list[i])
  
  # remove first row of excel-formatted dashes
  temp <- temp[-1, ]
  
  # initialize `Expire Date` variable
  # this column doesnt appear in months 01-07 but starts to after 08
  temp$`Expire Date` <- ""

  # add year and month columns
  temp$year <- as.factor("2016")
  temp$month <- paste(y2016_list[i])
  temp$month <- gsub(".xlsx", "", temp$month)
  temp$month <- gsub("16", "", temp$month)
  
  # bind
  y2016 <- rbind(temp, y2016)
  
}
)

#     user  system elapsed 
#   22.736   2.531  26.082 

# remove temporary objects
rm(temp)
rm(y2016_dir)
rm(y2016_list)

str(y2016)
# 795578 obs. of  20 variables

# 2015 ------------------------------------------------------------------------
# Sept (09) and Oct (10) are not available

y2015dir <- "~/GitHub/federal-firearms-licenses/data/00-ATF-FFL-raw/2015"
setwd(y2015dir)

y2015.list <- list.files(path = y2015dir, pattern = ".xlsx", recursive = T, all.files = T)
y2015 <- data.frame()

system.time(
for(i in 1:length(y2015.list)) {
  
  temp <- read_excel(y2015.list[i])
  temp <- temp[-1, ]
  temp$`Expire Date` <- ""
  
  temp$year <- as.factor("2015")
  temp$month <- paste(y2015.list[i])
  temp$month <- gsub(".xlsx", "", temp$month)
  temp$month <- gsub("15", "", temp$month)
  
  y2015 <- rbind(temp, y2015)
  
}
)

#    user  system elapsed 
#  16.990   2.628  19.650

# remove temporary objects
rm(temp)
rm(y2015_dir)
rm(y2015_list)

str(y2015)
# 785455 obs. of  20 variables

# difference between 2016 and 2015
nrow(y2016) - nrow(y2015)
# 10123


# bind all years --------------------------------------------------------------

library(dplyr)

# return to main directory
setwd("~/GitHub/federal-firearms-licenses")

# bind data
ATF_FFL <- bind_rows(y2015, y2016)
str(ATF_FFL)
# 1581033 obs. of  20 variables

# check binding
nrow(y2016) + nrow(y2015)
# 1581033

# rename columns
colnames(ATF_FFL) <- c("Region", "District", "County", "Type", "Expiration", "Seqn",
                       "LicenseName", "BusinessName", "PremiseStreet", "PremiseCity",
                       "PremiseState", "PremiseZIP", "MailStreet", "MailCity", "MailState",
                       "MailZIP", "Phone", "ExpireDate", "year", "month")

write.csv(ATF_FFL, file = "data/ffl-2015-2016.csv", row.names = F)

# each year
write.csv(y2015, file = "data/ffl-2015.csv", row.names = F)
write.csv(y2016, file = "data/ffl-2016.csv", row.names = F)
