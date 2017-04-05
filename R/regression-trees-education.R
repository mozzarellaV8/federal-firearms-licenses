# ATF- FFL - Exploratory Data Analysis
# US Census - American Community Survey - Table S1501
# "Educational Attainment"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/


# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(grDevices)

# custom plot themes
source("R/00-pd-themes.R")
source("R/00-usa-map-prep.R")

# total and per capita full-time education data
education <- read.csv("data/05-per-capita-clean/per-capita-education.csv", stringsAsFactors = F)

str(education)
# 50 obs of 55 variables
summary(education)

# select only variables that pertain to HS and BA
# the only data that is complete across age groups

edu <- education %>%
  select(NAME, perCapitaFFL, POPESTIMATE2015, POPESTIMATE2016,
         contains("HS"), contains("BA"), -contains("Less"))

str(edu)
# 50 obs of 34 variables

# clean up variable names
colnames(edu) <- gsub("edu.[0-9][0-9].Total", "per.capita", colnames(edu))

# Regression Tree -------------------------------------------------------------

# Data inspection using regression trees.
# Because of the large number of variables, 
# regression trees are fit to better understand the structure of the dataframe.

# Fitting regression trees to each Census dataset (e.g. education, workforce)
# and then fitting a regression tree on all variables at once,
# to see which factors might be best used for a multiple robust regression model. 

library(rpart)
library(rpart.plot)
library(tree)

# remove non-numeric variables
edu.tree <- edu %>%
  select(-POPESTIMATE2015, -POPESTIMATE2016)

# set rownames as states
rownames(edu.tree) <- edu.tree$NAME
edu.tree$NAME <- NULL

# palette
show.prp.palettes()

# `rpart` regression tree 01 --------------------------------------------------

# different rpart.control minsplits and complexity parameters
# can be experimented with - perhaps on a dataframe with more variables.
edu.rpart01 <- rpart(perCapitaFFL ~ ., data = edu.tree, 
                     control = rpart.control())
print(edu.rpart01)
summary(edu.rpart01)

# plot tree - 4 digits
rpart.plot(edu.rpart01, 
           type = 1, extra = 1, digits = 4, cex = 0.8, 
           branch.lty = 3, branch.lwd = 2.5,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(edu$perCapitaFFL),
           round = 1,
           family = "GillSans")

prp(edu.rpart01, 
    type = 4, extra = 1, digits = 4, under = T,
    branch.lty = 2, branch.lwd = 2.5, 
    cex = 0.8,  split.cex = 1.1, nn.cex = 0.9,
    box.palette = "BuBn",
    family = "GillSans")

rsq.rpart(edu.rpart01)

# `tree` regression tree 01 --------------------------------------------------

edu.tree01 <- tree(perCapitaFFL ~ ., data = edu.tree)
print(edu.tree01)
summary(edu.tree01)

# plot tree
par(family = "GillSans")
plot(edu.tree01, branch = 0, lty = 3)
text(edu.tree01, pretty = 0, use.n = T, cex = 0.85)

# Is using gender variables in addition to age groups creating unnecessary complexity? 
# Or is providing insight? 

# What would trying one without gender reveal? 

# `rpart` model 02 ------------------------------------------------------------


