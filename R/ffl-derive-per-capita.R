# ATF - Federal Firearms Licenses
# Exploratory Data Analysis

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)
library(scales)

# data: Federal Firearms Licenses 2016 
ffl <- fread("data/ffl-2016-V2.csv", stringsAsFactors = T)
ffl <- as.data.frame(ffl)
str(ffl)
# 795570 obs. of  24 variables

# data: US Census Population estimates 2010-2016
pop <- fread("data/01-US-Census/nst-est2016-alldata.csv")
pop <- as.data.frame(pop)
str(pop)
# 57 obs. of  106 variables

# 2016 population: US Census --------------------------------------------------

# select out 2016 variables
ffl.pop <- pop %>%
  select(REGION, DIVISION, STATE, NAME, contains("2016")) %>%
  arrange(desc(POPESTIMATE2016))

# remove regional observations
ffl.pop <- ffl.pop[-c(1, 2, 3, 4, 5), ]
str(ffl.pop)
# 52 obs. of  19 variables

# Per Capita FFLs -------------------------------------------------------------

# 1. find monthly average of FFLs per state
# 2. calculate number of FFLs per 100,000 people

# 2:
# Using Census population data, find license counts per 100,000 residents
# (number of FFLS / population) * 100,000

# rename state variable in ffl
colnames(ffl)[21] <- "NAME"
ffl$NAME <- as.character(ffl$NAME)

ffl.16 <- ffl.pop %>%
  select(NAME, POPESTIMATE2016) %>%
  left_join(ffl, by = "NAME")

# create per capita variables
perCapitaFFL <- ffl.16 %>%
  select(NAME, LicCount, POPESTIMATE2016) %>%
  distinct() %>%
  mutate(LicCountMonthly = LicCount / 12,
         perCapitaFFL.2016 = (LicCount / POPESTIMATE2016) * 100000,
         perCapitaFFL = LicCountMonthly / POPESTIMATE2016 * 100000)

# 'perCapitaFFL' is the truer number of FFLs per 100,000: 
# it takes the mean of FFLs monthly.
# The annual FFL count has many duplicates, repeat businesses.

# merge FFL and Census Population data
pc.FFL <- left_join(perCapitaFFL, ffl.pop)
summary(pc.FFL)

# write CSV with per capita FFL data
write.csv(pc.FFL, file = "data/ffl-2016-perCapita.csv", row.names = F)
