# ATF - FFL
# US Census - American Community Survey - Table S2404
# "INDUSTRY BY SEX FOR THE FULL-TIME, YEAR-ROUND CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# per capita computation function
source("R/00-per-capita.R")

# us census full-time employment data
employment <- read.csv("data/01-US-Census/ACS_15_1YR_employment/ACS_15_1YR_S2404.csv",
                     stringsAsFactors = F)
str(employment)
# 51 obs off 293 variables

# Cleanse: ACS employment data --------------------------------------------------

# select total estimated population by sector
# e.g. 'Total; Estimate; Manufacturing'
#  HC01_EST_VC04 = "Mining, Quarrying, Oil and Gas Extraction"
employment <- employment %>%
  select(GEO.display.label, 
         HC01_EST_VC01, HC01_EST_VC03, HC01_EST_VC04, HC01_EST_VC05, HC01_EST_VC06, 
         HC01_EST_VC07, HC01_EST_VC08, HC01_EST_VC10, HC01_EST_VC11, HC01_EST_VC12, 
         HC01_EST_VC14, HC01_EST_VC15, HC01_EST_VC17, HC01_EST_VC18, HC01_EST_VC19, 
         HC01_EST_VC21, HC01_EST_VC22, HC01_EST_VC24, HC01_EST_VC25, HC01_EST_VC26, 
         HC01_EST_VC27)

# rename columns and remove first row
colnames(employment) <- c("NAME", "CivilianPop.16", "Hunting.Fishing.Agriculture",
                        "Mining.Oil.Gas", "Construction", "Manufacturing", "Wholesale.Trade", 
                        "Retail.Trade", "Transportation.Warehousing", "Utilities", "Information", 
                        "Finance.Insurance", "Real.Estate","Sciences.Technical", "Management", 
                        "Waste.Management", "Educational.Services", "Health.Care", 
                        "Arts.Entertainment", "Foodservice.Accommodation", 
                        "OtherServices", "PublicAdministration")

# add prefix to variables names for ID
# colnames(employment) <- paste0("ind.", colnames(employment))

# remove 'Total'
employment <- employment[-1, ]
employment$NAME <- factor(employment$NAME)
rownames(employment) <- NULL

employment <- employment %>%
  mutate_each(funs(as.integer), 2:22)

summary(employment)
# 50 observations of 22 variables

# output total employment data
write.csv(employment, file = "data/04-total-data-clean/us-census-employment.csv", row.names = F)

# employment: Per Capita computation 01 -----------------------------------------

# check function against manual computation
perCapita2015(employment$Mining.Oil.Gas)[1]                     # [1] 180.0211
((employment$Mining.Oil.Gas/ffl.pop$POPESTIMATE2015)*100000)[1] # [1] 180.0211

# compute per capita and merge ffl
employment.perCapita <- employment %>%
  mutate_each(funs(perCapita2015), 2:22) %>%
  left_join(ffl.pop)

str(employment.perCapita)
# 50 obs of 25 variables

# output employment Per Capita data
write.csv(employment.perCapita, file = "data/05-per-capita-clean/per-capita-employment.csv",
          row.names = F)
