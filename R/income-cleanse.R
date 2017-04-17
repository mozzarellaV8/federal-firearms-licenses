# ATF - FFL
# US Census - American Community Survey -  Table S2503
# "Financial Characteristics"
# Annual Household Income - stratified brackets
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# 53 obs of 279 variables
finance <- read.csv("data/01-US-census/ACS_15_1YR_financial/ACS_15_1YR_S2503.csv",
                    stringsAsFactors = F)

# create key
# finance.key <- finance[1, ]

# per capita functions
source("R/00-per-capita.R")

# Cleanse: ACS Finance Characteristics data -----------------------------------

# select annual household income by bracket
# Occupied Housing Units (total of Owner-Occupied and Renter-Occupied Housing)
# Income bracket observations are percentages of total Occupied Housing Units

# 53 obs of 14 variables
# e.g. 'HOUSEHOLD INCOME IN THE PAST 12 MONTHS - $10,000 TO $14,999'
finance <- finance %>%
  select(GEO.display.label,
         HC01_EST_VC01, HC01_EST_VC03, HC01_EST_VC04, HC01_EST_VC05, HC01_EST_VC06,
         HC01_EST_VC07, HC01_EST_VC08, HC01_EST_VC09, HC01_EST_VC10, HC01_EST_VC11,
         HC01_EST_VC12, HC01_EST_VC13, HC01_EST_VC14)

colnames(finance) <- c("NAME", 
                       "OccupiedHousingUnits", "a.LessThan5000", "b.5000to9999",
                       "c.10000to14999", "d.15000to19999", "e.20000to24999",
                       "f.25000to34999", "g.35000to49999", "h.50000to74999",
                       "i.75000to99999", "j.100000to149999", "k.150000.or.more",
                       "MedianHouseholdIncome")

# remove Total, DC, and PR
finance <- finance[-c(1, 10, 53), ]
finance$NAME <- factor(finance$NAME)
rownames(finance) <- NULL

# convert to integer
finance <- finance %>%
  mutate_each(funs(as.numeric), 2:14)

# output total finance percentage data
write.csv(finance, file = "data/04-total-data-clean/us-census-finance-pct.csv",
          row.names = F)

# Finance: compute total population from percentages --------------------------

# function to compute raw counts from percentages
# observations are percentages of total housing units, so the formula is:
# total housing units * 0.01 * percentage observation
percentage.income <- function(x) {
  x <- (finance$OccupiedHousingUnits * 0.01) * x
  x
}

# compute on each percentage variable
finance.total <- finance %>%
  mutate_each(funs(percentage.income), 3:13)

# output total finance data 
write.csv(finance, file = "data/04-total-data-clean/us-census-finance.csv",
          row.names = F)

# Finance: compute per capita totals ------------------------------------------

# compute per capita totals with function in header
finance.perCapita <- finance.total %>%
  mutate_each(funs(perCapita2015), 3:13) %>%
  left_join(ffl.pop)

# output per capita finance data
write.csv(finance.perCapita, file = "data/05-per-capita-clean/per-capita-finance.csv",
          row.names = F)
