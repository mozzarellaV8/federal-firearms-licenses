# FFL - EDA
# 2016 cleanse

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

ffl <- fread("data/ffl-2016.csv", stringsAsFactors = T)
ffl <- as.data.frame(ffl)
str(ffl)
# 1581033 obs. of  20 variables

# rename columns
colnames(ffl) <- c("Region", "District", "County", "Type", "Expiration", "Seqn",
                   "LicenseName", "BusinessName", "PremiseStreet", "PremiseCity",
                   "PremiseState", "PremiseZIP", "MailStreet", "MailCity", "MailState",
                   "MailZIP", "Phone", "ExpireDate", "year", "month")


# cleanse: full state names  --------------------------------------------------

# full state names
ffl$PremiseStateFull <- state.name[match(as.character(ffl$PremiseState), state.abb)]

# Commonwealths and Territories:
# PR - Puerto Rico
# VI - Virgin Islands
# DC - Washington DC 
# MP - Northern Mariana Islands
# GU - Guam

ffl$PremiseStateFull <- ifelse(ffl$PremiseState == "PR", "Puerto Rico", ffl$PremiseStateFull)
ffl$PremiseStateFull <- ifelse(ffl$PremiseState == "DC", "Washington DC", ffl$PremiseStateFull)
ffl$PremiseStateFull <- ifelse(ffl$PremiseState == "MP", "North Marianas", ffl$PremiseStateFull)
ffl$PremiseStateFull <- ifelse(ffl$PremiseState == "GU", "Guam", ffl$PremiseStateFull)
ffl$PremiseStateFull <- ifelse(ffl$PremiseState == "VI", "Virgin Islands", ffl$PremiseStateFull)

levels(as.factor(ffl$PremiseStateFull))
ffl$PremiseStateFull <- factor(ffl$PremiseStateFull)

# remove NAs ----------------------------------------------
remove <- which(is.na(ffl$PremiseStateFull))
ffl <- ffl[-remove, ]

# Firearm License Types -------------------------------------------------------

# type.tsv is simply copied from the ATF website
# https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016

types <- read.csv("data/ffl-type.tsv", sep = "\t", stringsAsFactors = T)

types$Type <- factor(types$Type)
types$Description <- as.character(types$Description)
levels(types$Type)

ffl$FullType <- ifelse(ffl$Type == "01", types$Description[[1]], 
                       ifelse(ffl$Type == "02", types$Description[[2]],
                              ifelse(ffl$Type == "06", types$Description[[4]],
                                     ifelse(ffl$Type == "07", types$Description[[5]],
                                            ifelse(ffl$Type == "08", types$Description[[6]],
                                                   ifelse(ffl$Type == "09", types$Description[[7]],
                                                          ifelse(ffl$Type == "10", types$Description[[8]],
                                                                 ifelse(ffl$Type == "11", types$Description[[9]], ""))))))))


ffl$FullType <- factor(ffl$FullType)
summary(ffl$FullType)

# create license count variable -----------------------------------------------

# FFL count by state
lic.count <- as.data.frame(table(ffl$PremiseState))
colnames(lic.count) <- c("PremiseState", "LicCount")

# check total 
sum(lic.count$LicCount)
# 1581016

# join license count table with main ffl data
ffl <- left_join(ffl, lic.count, by = "PremiseState")
summary(ffl$LicCount)

# create count by Firearm Type variable ---------------------------------------

TypeCount <- ffl %>%
  select(PremiseState, FullType) %>%
  group_by(PremiseState) %>%
  count(FullType)

# check total
sum(TypeCount$n)
# 795570

ffl <- left_join(ffl, TypeCount)
colnames(ffl)[24] <- "TypeCount"

write.csv(ffl, file = "data/ffl-2016-V2.csv", row.names = F)
