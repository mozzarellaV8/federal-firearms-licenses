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

# Education
# Finance
# Legislature
# Race
# Rural-Urban proportions
# Workforce 
# Working Class 

getwd()
setwd("~/GitHub/federal-firearms-licenses")

# read in individual CSVs
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
edu <- read.csv("data/04-per-capita-clean/per-capita-education.csv", stringsAsFactors = F)
fin <-read.csv("data/04-per-capita-clean/per-capita-finance.csv", stringsAsFactors = F)
leg <- read.csv("data/04-per-capita-clean/legislature-2014.csv", stringsAsFactors = F)
race <- read.csv("data/04-per-capita-clean/per-capita-race.csv", stringsAsFactors = F)
rural.urban <- read.csv("data/04-per-capita-clean/pct-rural-urban.csv", stringsAsFactors = F)
wf <- read.csv("data/04-per-capita-clean/per-capita-workforce.csv", stringsAsFactors = F)
wc <- read.csv("data/04-per-capita-clean/per-capita-working-class.csv", stringsAsFactors = F)

# clean edu - select out FFL variables
edu <- edu %>% select(1:52)
colnames(edu) <- gsub("edu.[0-9][0-9].Total", "per.capita", colnames(edu))

# clean fin, rural.urban, and wf data
# select out FFL variables
fin <- fin %>% select(1:14)
rural.urban <- rural.urban %>% select(2:24)
wf <- wf %>% select(1:22)

# clean legislature data
leg <- leg %>% select(-contains("Total"), -contains("other")) 
leg <- leg %>% select(1:8)

# bind all into one dataframe
all.features <- ffl %>%
  left_join(leg, by = "NAME") %>%
  left_join(edu) %>%
  left_join(fin) %>%
  left_join(race) %>%
  left_join(rural.urban) %>%
  left_join(wf)
  
which(is.na(all.features))
# [1] 227 277 327 377

# 50 observations of 128 variables
str(all.features)

write.csv(all.features, file = "data/all-features.csv", row.names = F)

# Regression Trees ------------------------------------------------------------

# remove NAME
rownames(all.features) <- all.features$NAME
all.features$NAME <- NULL

# rpart - tree 01a - all features ---------------------------------------------
all.tree.a <- rpart(perCapitaFFL ~ ., data = all.features)

rpart.plot(all.tree.a, 
           type = 1, extra = 1, digits = 4, cex = 1.2, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(all.features$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(all.tree.a)
# n= 50 

# node), split, n, deviance, yval
# * denotes terminal node

# 1) root 50 22865.9600 31.16886  
# 2) POP_UA>=616118 42  5508.6760 24.20456  
# 4) AREAPCT_UA>=2.665 25  1495.8680 17.29237  
# 8) Legis.Control=Dem 11   180.5655 10.13255 *
#   9) Legis.Control=Rep,Split 14   308.3505 22.91794 *
#     5) AREAPCT_UA< 2.665 17  1061.7880 34.36955 *
#   3) POP_UA< 616118 8  4625.6530 67.73143 *


# tree - tree 01b - all features ----------------------------------------------
all.tree.b <- tree(perCapitaFFL ~ ., data = all.features)

# plot `tree` model
par(family = "GillSans", cex = 1)
plot(all.tree.b)
text(all.tree.b, pretty = 0)

print(all.tree.b)

# all features 02: immigration  -----------------------------------------------


# merge immigration data
# load immigration data
immigration <- read.csv("data/Immigration-Permanent-Residents-2014-Table4-Homeland-Security.csv",
                        stringsAsFactors = F)
colnames(immigration)[2:4] <- c("y2012", "y2013", "y2014")

# remove commas
immigration$y2012 <- gsub(",", "", immigration$y2012)
immigration$y2013 <- gsub(",", "", immigration$y2013)
immigration$y2014 <- gsub(",", "", immigration$y2014)
immigration$y2012 <- as.integer(immigration$y2012)
immigration$y2013 <- as.integer(immigration$y2013)
immigration$y2014 <- as.integer(immigration$y2014)

immigration <- immigration %>%
  select(NAME, y2014) %>%
  left_join(all.features.pc)

all.features.pc <- immigration

# rpart - tree 02
all.tree.02 <- rpart(perCapitaFFL ~ ., data = all.features.pc)

rpart.plot(all.tree.a, type = 1, extra = 1,
           digits = 4, cex = 0.75, 
           split.family = "GillSans", split.cex = 1.1,
           nn.family = "GillSans", nn.cex = 0.85, 
           fallen.leaves = T)

# tree- tree 02b
all.tree.b <- tree(perCapitaFFL ~ ., data = all.features.pc)
par(family = "GillSans", cex = 0.85)
plot(all.tree.b)
text(all.tree.b, pretty = 0)
