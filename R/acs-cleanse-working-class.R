# ATF - FFL
# US Census - American Community Survey - Table S2408
# "CLASS OF WORKER BY SEX FOR THE CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

working.class <- read.csv("data/01-US-census/ACS_15_1YR_working-class/ACS_15_1YR_S2408.csv",
                          stringsAsFactors = F)
# 53 obs of 93 variables

# function to compute per capita totals
source("R/00-per-capita.R")

# Cleanse: ACS Working Class data ---------------------------------------------

# select total estimate data for each class category
# there is also male-female data
# 53 obs of 11 variables
working.class <- working.class %>%
  select(GEO.display.label,
         HC01_EST_VC01, HC01_EST_VC02, HC01_EST_VC03, HC01_EST_VC04, HC01_EST_VC05,
         HC01_EST_VC06, HC01_EST_VC07, HC01_EST_VC08, HC01_EST_VC09)

# rename columns
colnames(working.class) <- c("NAME", "CivilianPop.16", "Private.ForProfit", 
                             "Private.ForProfit.Employee", 
                             "Private.ForProfit.Self.Inc", 
                             "Private.NonProfit", "LocalGov", "StateGov",
                             "FederalGov", "Self.Employed")

# remove Total, DC, PR
working.class <- working.class[-c(1, 10, 53), ]
working.class$NAME <- factor(working.class$NAME)
rownames(working.class) <- NULL

# convert to integers
working.class <- working.class %>%
  mutate_each(funs(as.integer), 2:10)

# output total working class data
write.csv(working.class, file = "data/04-total-data-clean/us-census-working-class.csv", 
          row.names = F)

# Working Class: Per Capita computation  --------------------------------------

# test function against manual computation
perCapita2015(working.class$Private.ForProfit)[1]                         # 30871.46
((working.class$Private.ForProfit / ffl.pop$POPESTIMATE2015) * 100000)[1] # 30871.46

work.perCapita <- working.class %>%
  mutate_each(funs(perCapita2015), 2:10)
  
# output per capita working class totals
write.csv(work.perCapita, file = "data/05-per-capita-clean/per-capita-working-class.csv",
          row.names = F)