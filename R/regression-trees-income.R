# Regression Trees - All Data
# Federal Firearms License data

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(broom)
library(rpart)
library(rpart.plot)
library(tree)
library(ggplot2)

# load themes and functions
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")

# load and bind all per capita data -------------------------------------------

# Finance

# read in individual CSVs
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
edu <- read.csv("data/04-per-capita-clean/per-capita-education.csv", stringsAsFactors = F)
fin <-read.csv("data/04-per-capita-clean/per-capita-finance.csv", stringsAsFactors = F)
leg <- read.csv("data/04-per-capita-clean/legislature-2014.csv", stringsAsFactors = F)
race <- read.csv("data/04-per-capita-clean/per-capita-race.csv", stringsAsFactors = F)
rural.urban <- read.csv("data/04-per-capita-clean/pct-rural-urban.csv", stringsAsFactors = F)
wf <- read.csv("data/04-per-capita-clean/per-capita-workforce.csv", stringsAsFactors = F)
wc <- read.csv("data/04-per-capita-clean/per-capita-working-class.csv", stringsAsFactors = F)