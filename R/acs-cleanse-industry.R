# ATF - FFL
# US Census - American Community Survey - Table S2407
# "Industry by Class of Worker for the Civilian Employed Population 16 Years and Over"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# per capita computation function
source("R/00-per-capita.R")

# industry data
industry <- read.csv("data/01-US-Census/ACS_15_1YR_industry/ACS_15_1YR_S2407.csv",
                     stringsAsFactors = F)
str(industry)
# 53 obs off 183 variables

# select total estimate data for each industry
# for each industry there is finer grain data - 
# e.g, within each sector of industry, there are stratifications 
# by type of company: private, not-for-profit, self-employed, &c.

# Cleanse: ACS Industry data --------------------------------------------------

# select total estimated population by sector
# e.g. 'Total; Estimate; Manufacturing'
#  HC01_EST_VC01 = "Civilian employed population 16 years and over"
industry <- industry %>%
  select(GEO.display.label, 
         HC01_EST_VC01, HC01_EST_VC02, HC01_EST_VC03, HC01_EST_VC04, HC01_EST_VC05, 
         HC01_EST_VC06, HC01_EST_VC07, HC01_EST_VC08, HC01_EST_VC09, HC01_EST_VC10,
         HC01_EST_VC11, HC01_EST_VC12, HC01_EST_VC13, HC01_EST_VC14)

# create key before renaming columns
industry.key <- industry[1, ]

# rename columns and remove first row
colnames(industry) <- c("NAME", "CivilianPop.16", "Agriculture.Hunting.Mining",
                        "Construction", "Manufacturing", "Wholesale.Trade", "Retail.Trade",
                        "Transportation.Warehousing.Util", "Information", "Finance.Insurance.RealEstate",
                        "Sciences.Professional.Waste", "Education.HealthCare.Social", 
                        "Arts.Accomodation.Foodservice", "OtherServices", "PublicAdministration")

# add prefix to variables names for ID
# colnames(industry) <- paste0("ind.", colnames(industry))

# remove 'Total', DC, and PR
industry <- industry[-c(1, 10, 53), ]
industry$NAME <- factor(industry$NAME)
rownames(industry) <- NULL

# output total industry data
write.csv(industry, file = "data/04-total-data-clean/us-census-industry.csv", row.names = F)

# Industry: Per Capita computation --------------------------------------------

# merge FFL and population data
industry <- industry %>%
  left_join(ffl.pop) %>%
  mutate_each(funs(as.integer), 3:16)

# check `perCapita.industry` function against manual computation
perCapita.industry(industry$Agriculture.Hunting.Mining)[1]                # 708.3619
((industry$Agriculture.Hunting.Mining/industry$POPESTIMATE2015)*100000)[1] # 708.3619

# convert factors to integers and compute per capita totals
industry.perCapita <- industry %>%
  mutate_each(funs(perCapita2015), 3:16)

# output Industry Per Capita data
write.csv(industry.perCapita, file = "data/05-per-capita-clean/per-capita-industry.csv",
          row.names = F)