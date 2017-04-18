# ATF - FFL
# US Census - American Community Survey - Table 1502
# "FIELD OF BACHELOR'S DEGREE FOR FIRST MAJOR"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# per capita computation function
source("R/00-per-capita.R")

# 53 obs of 291 variables
major <- read.csv("data/01-US-census/S1502-BA-major/ACS_15_1YR_S1502.csv",
                  stringsAsFactors = F)


str(major)

# Cleanse: ACS Field of Bachelor's Degree Data --------------------------------

# select total estimates by field and sex
major <- major %>%
  select(GEO.display.label,
         HC01_EST_VC01, HC01_EST_VC03, HC01_EST_VC04, HC01_EST_VC05, HC01_EST_VC06, HC01_EST_VC07,
         HC03_EST_VC01, HC03_EST_VC03, HC03_EST_VC04, HC03_EST_VC05, HC03_EST_VC06, HC03_EST_VC07,
         HC05_EST_VC01, HC05_EST_VC03, HC05_EST_VC04, HC05_EST_VC05, HC05_EST_VC06, HC05_EST_VC07)

# rename variables
colnames(major) <- c("NAME",
                     "total.BA", "Science.and.Engineering", "Science.Engineering.related", 
                     "Business", "Education", "Arts.Humanities.Others", 
                     "male.total.BA", "male.Science.and.Engineering", 
                     "male.Science.Engineering.related", 
                     "male.Business", "male.Education", "male.Arts.Humanities.Others", 
                     "female.total.BA", "female.Science.and.Engineering",
                     "female.Science.Engineering.related", 
                     "female.Business", "female.Education", "female.Arts.Humanities.Others")

# remove first row
major <- major[-1, ]

# convert all variables to numeric
major <- major %>%
  mutate_each(funs(as.numeric), 2:19)

# compute per capita totals
major.perCapita <- major %>%
  mutate_each(funs(perCapita2015), 2:15) %>%
  left_join(ffl.pop)

# test per capita function
(major$Science.and.Engineering[1]/ffl.pop$POPESTIMATE2015[1]) * 100000
# 4799.217

# write out per capita data
write.csv(major.perCapita, 
          file = "data/04-per-capita-clean/per-capita-edu-major.csv",
          row.names = F)

