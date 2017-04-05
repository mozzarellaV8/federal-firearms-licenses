# ATF - FFL
# US Census - American Community Survey - Table S1501
# "Educational Attainment"
# Education Attainment by Age Bracket
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# 53 obs of 771 variables
education <- read.csv("data/01-US-census/ACS_15_1YR_education/ACS_15_1YR_S1501.csv",
                      stringsAsFactors = F)

# per capita computation function
source("R/00-per-capita.R")

# Cleanse: ACS Education data -------------------------------------------------

# select total estimate data for each age bracket
# and also male and female data
# 53 obs of 52 variables
# e.g. 'Total; Estimate; Males; Population 18 to 24 years; High school graduate'
education <- education %>%
  select(GEO.display.label, 
         HC01_EST_VC02, HC03_EST_VC02, HC05_EST_VC02,
         HC01_EST_VC03, HC03_EST_VC03, HC05_EST_VC03,
         HC01_EST_VC04, HC03_EST_VC04, HC05_EST_VC04,
         HC01_EST_VC05, HC03_EST_VC05, HC05_EST_VC05,
         HC01_EST_VC06, HC03_EST_VC06, HC05_EST_VC06,
         HC01_EST_VC20, HC03_EST_VC20, HC05_EST_VC20,
         HC01_EST_VC21, HC03_EST_VC21, HC05_EST_VC21,
         HC01_EST_VC22, HC03_EST_VC22, HC05_EST_VC22,
         HC01_EST_VC24, HC03_EST_VC24, HC05_EST_VC24,
         HC01_EST_VC25, HC03_EST_VC25, HC05_EST_VC25,
         HC01_EST_VC26, HC03_EST_VC26, HC05_EST_VC26,
         HC01_EST_VC28, HC03_EST_VC28, HC05_EST_VC28,
         HC01_EST_VC29, HC03_EST_VC29, HC05_EST_VC29,
         HC01_EST_VC30, HC03_EST_VC30, HC05_EST_VC30,
         HC01_EST_VC32, HC03_EST_VC32, HC05_EST_VC32,
         HC01_EST_VC33, HC03_EST_VC33, HC05_EST_VC33,
         HC01_EST_VC34, HC03_EST_VC34, HC05_EST_VC34)

# create key
# edu.key <- education[1, ]

# rename columns
colnames(education) <- c("NAME", 
                         "02.Total.18to24", "02.Total.18.to24.Male", "02.Total.18to24.Female",
                         "03.Total.18to24.LessHS", "03.Total.18to24.LessHS.Male", "03.Total.18to24.LessHS.Female",
                         "04.Total.18to24.HS", "04.Total.1824.HS.Male", "04.Total.18to24.HS.Female",
                         "05.Total.18to24.AA", "05.Total.18to24.AA.Male", "05.Total.18to24.AA.Female",
                         "06.Total.18to24.BA", "06.Total.18to24.BA.Male", "06.Total.18to24.BA.Female",
                         "20.Total.25to34", "20.Total.25to34.Male", "20.Total.25to34.Female",
                         "21.Total.25to34.HS", "21.Total.25to34.HS.Male", "21.Total.25to34.HS.Female",
                         "22.Total.25to34.BA", "22.Total.25to34.BA.Male", "22.Total.25to34.BA.Female",
                         "24.Total.35to44", "24.Total.35to44.Male", "24.Total.35to44.Female",
                         "25.Total.35to44.HS", "25.Total.35to44.HS.Male", "25.Total.35to44.HS.Female",
                         "26.Total.35to44.BA", "26.Total.35to44.BA.Male", "26.Total.35to44.BA.Female",
                         "28.Total.45to64", "28.Total.45to64.Male", "28.Total.45to64.Female",
                         "29.Total.45to64.HS", "29.Total.45to64.HS.Male", "29.Total.45to64.HS.Female",
                         "30.Total.45to64.BA", "30.Total.45to64.BA.Male", "30.Total.45to64.BA.Female",
                         "32.Total.65plus", "32.Total.65plus.Male", "32.Total.65plus.Female",
                         "33.Total.65plus.HS", "33.Total.65plus.HS.Male", "33.Total.65plus.HS.Female",
                         "34.Total.65plus.BA", "34.Total.65plus.BA.Male", "34.Total.65plus.BA.Female")


# remove Total, DC, and PR
education <- education[-c(1, 10, 53), ]
rownames(education) <- NULL

# add prefix to variables names for ID
colnames(education)[2:52] <- paste0("edu.", colnames(education)[2:52])

# convert to integers
education <- education %>%
  mutate_each(funs(as.integer), 2:52)

# output total education data
write.csv(education, file = "data/04-total-data-clean/us-census-education.csv", 
          row.names = F)

# Education: Per Capita Computation -------------------------------------------

education.perCapita <- education %>%
  mutate_each(funs(perCapita2015), 2:52) %>%
  left_join(ffl.pop)

# output per capita education data
write.csv(education.perCapita, 
          file = "data/05-per-capita-clean/per-capita-education.csv",
          row.names = F)