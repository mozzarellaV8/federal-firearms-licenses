# Regression Trees - Workforce-Industry
# Federal Firearms License data
# "INDUSTRY BY SEX FOR THE FULL-TIME, YEAR-ROUND CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

########
#### Appendix -----------------------------------------------------------------
########

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

# ffl data and industry per capita data
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
wf <- read.csv("data/04-per-capita-clean/per-capita-workforce.csv", stringsAsFactors = F)

# remove population total variables
wf <- wf %>% select(1:22, 25)
str(wf)

# Baseline Linear Models ------------------------------------------------------

# maximal
wf.m01 <- lm(perCapitaFFL ~ .-NAME, data = wf)
tidy(wf.m01) %>% arrange(p.value)
glance(wf.m01) %>% select(r.squared, adj.r.squared, p.value)

# top 2 split variables
wf.m01b <- lm(perCapitaFFL ~ Waste.Management + Mining.Oil.Gas, data = wf)
tidy(wf.m01b) %>% arrange(p.value)
glance(wf.m01b) %>% select(r.squared, adj.r.squared, p.value)

# all 4 split variables
wf.m01c <- lm(perCapitaFFL ~ Waste.Management + Mining.Oil.Gas + 
                Finance.Insurance + Construction, data = wf)
tidy(wf.m01c) %>% arrange(p.value)
glance(wf.m01c) %>% select(r.squared, adj.r.squared, p.value)

par(mfrow = c(2, 2), family = "GillSans")
plot(wf.m01)
plot(wf.m01b)
plot(wf.m01c)

# Modeling Split Interactions -------------------------------------------------

# create factors
waste01 <- factor(wf$Waste.Management >= 936.4)
mine01 <- factor(wf$Mining.Oil.Gas < 24.75)

# model interaction 01
wf.m02 <- lm(perCapitaFFL ~ waste01 * mine01, data = wf)
summary(wf.m02)
tidy(wf.m02) %>% arrange(p.value)
glance(wf.m02) %>% select(r.squared, adj.r.squared, p.value)

# create remaining factors
fin01 <- factor(wf$Finance.Insurance >= 1368)
con01 <- factor(wf$Construction < 2399)

# model interaction 02
wf.m02b <- lm(perCapitaFFL ~ waste01 * mine01 * fin01 * con01, data = wf)
summary(wf.m02b)
tidy(wf.m02b) %>% arrange(p.value)
glance(wf.m02b) %>% select(r.squared, adj.r.squared, p.value)

