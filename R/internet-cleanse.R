# ATF - Federal Firearms Licenses
# US Census - American Community Survey - Table S2801
# "TYPES OF COMPUTERS AND INTERNET SUBSCRIPTIONS"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)

# per capita computation function
source("R/00-per-capita.R")

# us census full-time employment data
internet <- read.csv("data/01-US-Census/S2801-computers-internet/ACS_15_1YR_S2801.csv")

# 51 obs of 127 variables
str(internet)

# Clease: ACS Computer Types and Internet Subscriptions data ------------------

# select total computer-type and internet-subscription data only
net <- internet %>%
  select(GEO.display.label, 
         HC01_EST_VC01, HC01_EST_VC04, HC01_EST_VC05, HC01_EST_VC06, HC01_EST_VC07,
         HC01_EST_VC08, HC01_EST_VC09, HC01_EST_VC10, HC01_EST_VC11, HC01_EST_VC14,
         HC01_EST_VC15, HC01_EST_VC16, HC01_EST_VC17, HC01_EST_VC18, HC01_EST_VC19,
         HC01_EST_VC20, HC01_EST_VC21, HC01_EST_VC22, HC01_EST_VC23)

# 51 obs of 20 variables
str(net)

# create descriptive variable names
colnames(net) <- c("NAME",
                   "total.households", "desktop-laptop", "desktop-laptop.only", "handheld",
                   "handheld-alone.only", "other computer", "other.computer.only", "no.computer",
                   "total.internet", "dial-up", "broadband", "DSL", "DSL-mobile.broadband",
                   "mobile.broadband", "mobile.broadband.dial-up", "DSL-cable.modem",
                   "DSL-fiber", "DSL-satellite", "no.internet")


net <- net[-1, ]
net$NAME <- factor(net$NAME)
rownames(net) <- NULL

# convert to integer
net <- net %>%
  mutate_each(funs(factor), 2:20) %>%
  mutate_each(funs(as.character), 2:20) %>%
  mutate_each(funs(as.integer), 2:20)


# per capita calculations -----------------------------------------------------

# per capita computation function
perCapitaHouseholds <- function(x) {
  x <- as.integer(x)
  x <- (x / net$total.households) * 100000
}

# per capita by total households ----------------------------------------------
net.perCapita <- net %>%
  mutate_each(funs(perCapitaHouseholds), 2:20)

# check
net.perCapita[1, 3]                            # 80841.05
(net[1, 3] / net$total.households[1]) * 100000 # 80841.05

# remove total households column (all equal 100k)
net.perCapita[, 2] <- NULL

# output CSV
write.csv(net.perCapita, file = "data/04-per-capita-clean/per-capita-internet.csv",
          row.names = F)


# per capita by total population ----------------------------------------------
net.perCapitaPop <- net %>%
  mutate_each(funs(perCapita2015), 2:20)

# check
net.perCapitaPop[1, 3]                              # 30751.53
(net[1, 3] / ffl.pop$POPESTIMATE2015[1]) * 100000   # 30751.53
