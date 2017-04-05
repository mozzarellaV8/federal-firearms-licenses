# ATF - FFL
# US Census - Rural-Urban Proportions Data
# "2010 Census Urban and Rural Classification and Urban Area Criteria"
# https://www.census.gov/geo/reference/ua/urban-rural-2010.html

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# per capita computation function
source("R/00-per-capita.R")

# us census full-time rural.urban data
rural.urban <- read.csv("data/01-US-Census/PctUrbanRural_State.csv",
                     stringsAsFactors = F)

str(rural.urban)
# 52 obs. of  24 variables:

ffl <- read.csv('data/ffl-per-capita.csv')

# Cleanse: ACS rural.urban data --------------------------------------------------

colnames(rural.urban)[2] <- "NAME"

# remove DC and PR
rural.urban <- rural.urban[-c(9, 52), ]
rownames(rural.urban) <- NULL

summary(rural.urban)
# 50 observations of 24 variables

# join FFL data
rural.urban <- left_join(rural.urban, ffl)

# output total rural.urban data
write.csv(rural.urban, file = "data/04-per-capita-clean/pct-rural-urban.csv", row.names = F)