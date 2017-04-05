# ATF-FFL 
# NCSL State Legislator Data
# "Legislator Data - State Partisan Composition"
# http://www.ncsl.org/research/about-state-legislatures/partisan-composition.aspx
# http://www.ncsl.org/documents/statevote/legiscontrol_2014.pdf

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# plot themes
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")
source("~/GitHub/ATF-FFL/R/usa-map-prep.R")

# dataset containing data by state for:
# - state legislature - control
# - state legislature - compensation      
pop <- read.csv("~/GitHub/ATF-FFL/data/population-compact.csv", stringsAsFactors = F)
ffl <- read.csv("~/GitHub/ATF-FFL/data/ffl-2016-perCapita-compact.csv", stringsAsFactors = F)

leg.14 <- read.csv("data/02-state-legislatures/control/2014.csv")
leg.15 <- read.csv("data/02-state-legislatures/control/2015.csv")
leg.16 <- read.csv("data/02-state-legislatures/control/2016.csv")

# add year variable and merge dataframes
leg.14$Year <- "2014"
leg.15$Year <- "2015"
leg.16$Year <- "2016"

legislature <- rbind(leg.14, leg.15, leg.16)

# cleanse data ----------------------------------------------------------------

# replace "Dem*" with "Dem"
levels(legislature$Legis.Control)
# [1] "Dem"   "Dem*"  "N/A"   "Rep"   "Split"

levels(legislature$State.Control)
# [1] "Dem"     "Dem*"    "Divided" "N/A"     "Rep" 

legislature$Legis.Control <- gsub("Dem\\*", "Dem", legislature$Legis.Control)
legislature$State.Control <- gsub("Dem\\*", "Dem", legislature$State.Control)
legislature$Legis.Control <- factor(legislature$Legis.Control)
legislature$State.Control <- factor(legislature$State.Control)

str(legislature)

# convert to integers
legislature$House.Dem <- as.integer(legislature$House.Dem)
legislature$House.Rep <- as.integer(legislature$House.Rep)
legislature$Senate.Dem <- as.integer(legislature$Senate.Dem)
legislature$Senate.Rep <- as.integer(legislature$Senate.Rep)

# filter for 2014
leg.14 <- legislature %>%
  filter(Year == "2014")

# bind FFL data ---------------------------------------------------------------

colnames(legislature)[1] <- "NAME"
colnames(leg.14)[1] <- "NAME"
  
legislature <- legislature %>%
  left_join(ffl)

leg.14 <- leg.14 %>%
  left_join(ffl)


write.csv(leg.14, file = "data/04-per-capita-clean/legislature-2014.csv", row.names = F)
write.csv(legislature, file = "data/legislature.csv", row.names = F)
