# Regression Trees - Income
# "Finanacial Characteristics"
# US Census - American Community Survey, table S2503.
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/
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
income <- read.csv("data/04-per-capita-clean/per-capita-finance.csv", stringsAsFactors = F)
str(income)

# remove total occupied housing, 
# median household income, 
# and populations variables
# 50 observations of 13 variables
income <- income %>%
  select(1, 3:13, 17)

rownames(income) <- income$NAME
income$NAME <- NULL

# Rpart model 01 --------------------------------------------------------------

income.rpart01 <- rpart(perCapitaFFL ~ ., data = income)

rpart.plot(income.rpart01, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(wf$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(income.rpart01)
summary(income.rpart01)
# Variable importance:
#   h.50000to74999 k.150000.or.more   e.20000to24999   g.35000to49999   f.25000to34999   a.LessThan5000
#               27               15               10                9                8                7


# distribution of rpart splits
par(mar = c(4, 4, 4, 4), mfrow = c(2, 2), family = "GillSans")
hist(income$a.LessThan5000, xlab = "", ylab = "", 
     main = "Less than $5,000")
hist(income$h.50000to74999, xlab = "", ylab = "", 
     main = "$50,000-74,999")
hist(income$j.100000to149999, xlab = "", ylab = "", 
     main = "$100,000-149,999")
hist(income$k.150000.or.more, xlab = "", ylab = "", 
     main = "$150,000 or more")


# tree - tree 01 - all features -----------------------------------------------

income.tree01 <- tree(perCapitaFFL ~ ., data = income)
print(income.tree01)
summary(income.tree01)
# Variables used:
# "a.LessThan5000" "g.35000to49999" "c.10000to14999"

# plot the tree
par(mfrow = c(1, 1), family = "GillSans")
plot(income.tree01, lty = 3)
text(income.tree01, pretty = 0, cex = 0.9)

# Quite a departure from the rpart model - pruning may provide clarity

# prune the tree
prune.tree01 <- prune.tree(income.tree01, best = 5)

# plot the pruned
par(mfrow = c(1, 1), family = "GillSans")
plot(prune.tree01, lty = 3)
text(prune.tree01, pretty = 0, cex = 0.8)

# distributions of tree split variables
par(mar = c(4, 4, 4, 4), mfrow = c(1, 3), family = "GillSans")
hist(income$a.LessThan5000, xlab = "", ylab = "", 
     main = "Less than $5,000")
hist(income$c.10000to14999, xlab = "", ylab = "", 
     main = "$10,000-14,999")
hist(income$g.35000to49999, xlab = "", ylab = "", 
     main = "$35,000-49,999")















