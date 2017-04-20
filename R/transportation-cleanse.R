# ATF - Federal Firearms Licenses
# US Census - American Community Survey - Table S0802
# "MEANS OF TRANSPORTATION TO WORK BY SELECTED CHARACTERISTICS"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# per capita computation function
source("R/00-per-capita.R")

# us census full-time employment data
transportation <- read.csv("data/01-US-Census/S0802-transportation/ACS_15_1YR_S0802.csv")
str(transportation)
# 51 obs of 811 variables

# Cleanse: ACS transportation data --------------------------------------------

# select variables related to characteristics on:
# TOTAL, industry, place of work, time leaving home to go to work, time traveled

# INDUSTRY --------------------------------------------------------------------

# agriculture, construction, manufacturing, wholesale, retail, transportation,
# finance, professional/scientific, educational services, arts, other services,
# public administration
transport.industry <- transportation %>% 
  select(GEO.display.label,
         HC01_EST_VC01, HC02_EST_VC01, HC03_EST_VC01, HC04_EST_VC01,
         HC01_EST_VC69, HC02_EST_VC69, HC03_EST_VC69, HC04_EST_VC69,
         HC01_EST_VC70, HC02_EST_VC70, HC03_EST_VC70, HC04_EST_VC70,
         HC01_EST_VC71, HC02_EST_VC71, HC03_EST_VC71, HC04_EST_VC71,
         HC01_EST_VC72, HC02_EST_VC72, HC03_EST_VC72, HC04_EST_VC72,
         HC01_EST_VC73, HC02_EST_VC73, HC03_EST_VC73, HC04_EST_VC73,
         HC01_EST_VC74, HC02_EST_VC74, HC03_EST_VC74, HC04_EST_VC74,
         HC01_EST_VC75, HC02_EST_VC75, HC03_EST_VC75, HC04_EST_VC75,
         HC01_EST_VC76, HC02_EST_VC76, HC03_EST_VC76, HC04_EST_VC76,
         HC01_EST_VC77, HC02_EST_VC77, HC03_EST_VC77, HC04_EST_VC77,
         HC01_EST_VC78, HC02_EST_VC78, HC03_EST_VC78, HC04_EST_VC78,
         HC01_EST_VC79, HC02_EST_VC79, HC03_EST_VC79, HC04_EST_VC79,
         HC01_EST_VC80, HC02_EST_VC80, HC03_EST_VC80, HC04_EST_VC80,
         HC01_EST_VC81, HC02_EST_VC81, HC03_EST_VC81, HC04_EST_VC81)

# 51 obs of 57 variables
str(transport.industry)

# remove first row
transport.industry <- transport.industry[-1, ]

# convert to numeric
transport.industry <- transport.industry %>%
  mutate_each(funs(factor), 1:57) %>%
  mutate_each(funs(as.character), 2:57) %>%
  mutate_each(funs(as.numeric), 2:57)

# rename variables
colnames(transport.industry) <- c("NAME",
                                  "total.workers", "total.drove.alone", "total.carpool", "total.public.transportation",
                                  "agriculture.total", "agriculture.drove.alone", "agriculture.carpool", "agriculture.public",
                                  "construction.total", "construction.drove.alone", "construction.carpool", "construction.public",
                                  "manufacturing.total", "manufacturing.drove.alone", "manufacturing.carpool", "manufacturing.public",
                                  "wholesale.total", "wholesale.drove.alone", "wholesale.carpool", "wholesale.public",
                                  "retail.total", "retail.drove.alone", "retail.carpool", "retail.public",
                                  "transportation.total", "transportation.drove.alone", "transportation.carpool", "transportation.public",
                                  "info.finance.total", "info.finance.drove.alone", "info.finance.carpool", "info.finance.public",
                                  "science.total", "science.drove.alone", "science.carpool", "science.public",
                                  "education.total", "education.drove.alone", "education.carpool", "education.public",
                                  "arts.total", "arts.drove.alone", "arts.carpool", "arts.public",
                                  "other.total", "other.drove.alone", "other.carpool", "other.public",
                                  "public.admin.total", "public.admin.drove.alone", "public.admin.carpool", "public.admin.public",
                                  "armed.forces.total", "armed.forces.drove.alone", "armed.forces.carpool", "armed.forces.public")

write.csv(transport.workplace, file = "data/03-additional-data/transporation-by-industry.csv",
          row.names = F)

# PLACE OF WORK  --------------------------------------------------------------
# in state, in-county, out of county, out of state, not at home
transport.workplace <- transportation %>%
  select(GEO.display.label,
         HC01_EST_VC90, HC02_EST_VC90, HC03_EST_VC90, HC04_EST_VC90,
         HC01_EST_VC91, HC02_EST_VC91, HC03_EST_VC91, HC04_EST_VC91,
         HC01_EST_VC92, HC02_EST_VC92, HC03_EST_VC92, HC04_EST_VC92,
         HC01_EST_VC93, HC02_EST_VC93, HC03_EST_VC93, HC04_EST_VC93,
         HC01_EST_VC95, HC02_EST_VC95, HC03_EST_VC95, HC04_EST_VC95)

# 51 obs of 21 variables
str(transport.workplace)

# remove first row (description)
transport.workplace <- transport.workplace[-1, ]


# convert to numeric
transport.workplace <- transport.workplace %>%
  mutate_each(funs(factor), 1:21) %>%
  mutate_each(funs(as.character), 2:21) %>%
  mutate_each(funs(as.numeric), 2:21)

# rename variables
colnames(transport.workplace) <- c("NAME",
                                   "in.state.total", "in.state.drove.alone", "in.state.carpool", "in.state.public.transportation",
                                   "in.county.total", "in.county.drove.alone", "in.county.carpool", "in.county.public.transportation",
                                   "out.of.county.total", "out.of.county.drove.alone", "out.of.county.carpool", "out.of.county.public.transportation",
                                   "out.of.state.total", "out.of.state.drove.alone", "out.of.state.carpool", "out.of.state.public.transportation",
                                   "not.at.home.total", "not.at.home.drove.alone", "not.at.home.carpool", "not.at.home.public.transportation")

write.csv(transport.workplace, file = "data/03-additional-data/transporation-by-workplace.csv",
          row.names = F)


# TIME LEAVING HOME TO GO TO WORK ---------------------------------------------

time.leaving.home <- transportation %>%
  select(GEO.display.label,
         HC01_EST_VC97, HC02_EST_VC97, HC03_EST_VC97, HC04_EST_VC97,
         HC01_EST_VC98, HC02_EST_VC98, HC03_EST_VC98, HC04_EST_VC98,
         HC01_EST_VC99, HC02_EST_VC99, HC03_EST_VC99, HC04_EST_VC99,
         HC01_EST_VC100, HC02_EST_VC100, HC03_EST_VC100, HC04_EST_VC100,
         HC01_EST_VC101, HC02_EST_VC101, HC03_EST_VC101, HC04_EST_VC101,
         HC01_EST_VC102, HC02_EST_VC102, HC03_EST_VC102, HC04_EST_VC102,
         HC01_EST_VC103, HC02_EST_VC103, HC03_EST_VC103, HC04_EST_VC103,
         HC01_EST_VC104, HC02_EST_VC104, HC03_EST_VC104, HC04_EST_VC104,
         HC01_EST_VC105, HC02_EST_VC105, HC03_EST_VC105, HC04_EST_VC105,
         HC01_EST_VC106, HC02_EST_VC106, HC03_EST_VC106, HC04_EST_VC106)

# 51 obs of 41 variables
str(time.leaving.home)

# remove first row (description)
time.leaving.home <- time.leaving.home[-1, ]

# convert to numeric
time.leaving.home <- time.leaving.home %>%
  mutate_each(funs(factor), 1:41) %>%
  mutate_each(funs(as.character), 2:41) %>%
  mutate_each(funs(as.numeric), 2:41)

# rename variables
colnames(time.leaving.home) <- c("NAME",
                                 "AM.12.00to4.59.total", "AM.12.00to4.59.drove.alone", "AM.12.00to4.59.carpool", "AM.12.00to4.59.public",
                                 "AM.5.00to5.29.total", "AM.5.00to5.29.drove.alone", "AM.5.00to5.29.carpool", "AM.5.00to5.29.public",
                                 "AM.5.30to5.59.total", "AM.5.30to5.59.drove.alone", "AM.5.30to5.59.carpool", "AM.5.30to5.59.public",
                                 "AM.6.00to6.29.total", "AM.6.00to6.29.drove.alone", "AM.6.00to6.29.carpool", "AM.6.00to6.29.public",
                                 "AM.6.30to6.59.total", "AM.6.30to6.59.drove.alone", "AM.6.30to6.59.carpool", "AM.6.30to6.59.public",
                                 "AM.7.00to7.29.total", "AM.7.00to7.29.drove.alone", "AM.7.00to7.29.carpool", "AM.7.00to7.29.public",
                                 "AM.7.30to7.59.total", "AM.7.30to7.59.drove.alone", "AM.7.30to7.59.carpool", "AM.7.30to7.59.public",
                                 "AM.8.00to8.29.total", "AM.8.00to8.29.drove.alone", "AM.8.00to8.29.carpool", "AM.8.00to8.29.public",
                                 "AM.8.30to8.59.total", "AM.8.30to8.59.drove.alone", "AM.8.30to8.59.carpool", "AM.8.30to8.59.public",
                                 "AM.9.00to11.59.total", "AM.9.00to11.59.drove.alone", "AM.9.00to11.59.carpool", "AM.9.00to11.59.public")

write.csv(time.leaving.home, file = "data/03-additional-data/transportation-time-leaving-home.csv",
          row.names = F)

# TRAVEL TIME TO WORK ---------------------------------------------------------

travel.time <- transportation %>%
  select(GEO.display.label,
         HC01_EST_VC109, HC02_EST_VC109, HC03_EST_VC109, HC04_EST_VC109,
         HC01_EST_VC110, HC02_EST_VC110, HC03_EST_VC110, HC04_EST_VC110,
         HC01_EST_VC111, HC02_EST_VC111, HC03_EST_VC111, HC04_EST_VC111,
         HC01_EST_VC112, HC02_EST_VC112, HC03_EST_VC112, HC04_EST_VC112,
         HC01_EST_VC113, HC02_EST_VC113, HC03_EST_VC113, HC04_EST_VC113,
         HC01_EST_VC114, HC02_EST_VC114, HC03_EST_VC114, HC04_EST_VC114,
         HC01_EST_VC115, HC02_EST_VC115, HC03_EST_VC115, HC04_EST_VC115,
         HC01_EST_VC116, HC02_EST_VC116, HC03_EST_VC116, HC04_EST_VC116,
         HC01_EST_VC117, HC02_EST_VC117, HC03_EST_VC117, HC04_EST_VC117,
         HC01_EST_VC118, HC02_EST_VC118, HC03_EST_VC118, HC04_EST_VC118)

# 51 obs of 41 variables
str(travel.time)

# remove first row (description)
travel.time <- travel.time[-1, ]

# convert to numeric
travel.time <- travel.time %>%
  mutate_each(funs(factor), 1:41) %>%
  mutate_each(funs(as.character), 2:41) %>%
  mutate_each(funs(as.numeric), 2:41)

# rename variables
colnames(travel.time) <- c("NAME",
                           "a.less.than.10mins.total", "a.less.than.10mins.drove.alone", "a.less.than.10mins.carpool", "a.less.than.10mins.public",
                           "b.10to14mins.total", "b.10to14mins.drove.alone", "b.10to14mins.carpool", "b.10to14mins.public",
                           "c.15to19mins.total", "c.15to19mins.drove.alone", "c.15to19mins.carpool", "c.15to19mins.public", 
                           "d.20to24mins.total", "d.20to24mins.drove.alone", "d.20to24mins.carpool", "d.20to24mins.public", 
                           "e.25to29mins.total", "e.25to29mins.drove.alone", "e.25to29mins.carpool", "e.25to29mins.public", 
                           "f.30to34mins.total", "f.30to34mins.drove.alone", "f.30to34mins.carpool", "f.30to34mins.public", 
                           "g.35to44mins.total", "g.35to44mins.drove.alone", "g.35to44mins.carpool", "g.35to44mins.public",
                           "h.45to59mins.total", "h.45to59mins.drove.alone", "h.45to59mins.carpool", "h.45to59mins.public",
                           "i.over60mins.total", "i.over60mins.drove.alone", "i.over60mins.carpool", "i.over60mins.public",
                           "j.mean.time.total", "j.mean.time.drove.alone", "j.mean.time.carpool", "j.mean.time.public")

write.csv(travel.time, file = "data/03-additional-data/transportation-travel-time.csv",
          row.names = F)
