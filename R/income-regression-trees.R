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
source("~/GitHub/federal-firearms-licenses/R/00-pd-themes.R")

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

# rpart model 01 --------------------------------------------------------------

income.rpart01 <- rpart(perCapitaFFL ~ ., data = income)

rpart.plot(income.rpart01, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(income$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(income.rpart01)
summary(income.rpart01)
# Variable importance:
#   h.50000to74999 k.150000.or.more   e.20000to24999   g.35000to49999   f.25000to34999   a.LessThan5000
#               27               15               10                9                8                7


# distribution of rpart splits
par(mar = c(3, 3, 3, 3), mfrow = c(1, 2), 
    cex.axis = 0.85, cex.main = 0.95, family = "GillSans")
hist(income$h.50000to74999, main = "$50,000-74,999", xlab = "", ylab = "")
hist(income$k.150000.or.more, main = "$150,000 or more", xlab = "", ylab = "")

summary(income$h.50000to74999)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    5424    6392    6915    6853    7299    8150 

summary(income$k.150000.or.more)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  1699    2806    3203    3796    4721    6972 

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

# Rpart Variable Splits 01 ----------------------------------------------------
summary(income$h.50000to74999)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    5424    6392    6915    6853    7299    8150

summary(income$k.150000.or.more)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1699    2806    3203    3796    4721    6972

summary(income$a.LessThan5000)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 610.4  1028.0  1228.0  1217.0  1427.0  2032.0 

income$NAME <- rownames(income)

ggplot(income, aes(h.50000to74999,
                   k.150000.or.more,
                   label = NAME, 
                   size = perCapitaFFL)) +
  geom_segment(x = 7291, xend = 7291, 
               y = -100, yend = 10000,
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_segment(x = 0, xend = 7291, 
               y = 5289, yend = 5289, 
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_point(aes(color = perCapitaFFL)) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 20), 
             guide = F) +
  geom_text(aes(h.50000to74999,
                k.150000.or.more,
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = income) +
  geom_smooth(method = "lm", se = F, 
              linetype = "dotted",
              color = "cadetblue3",
              size = 0.75) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Annual Income - primary & secondary regression tree splits",
       x = "per capita $50,000 to $74,999", y = "per capita $150,000 or more",
       color = "per capita FFLs")


# Rpart Variable Splits 02 ----------------------------------------------------
summary(income$k.150000.or.more)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1699    2806    3203    3796    4721    6972

summary(income$a.LessThan5000)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 610.4  1028.0  1228.0  1217.0  1427.0  2032.0

income$NAME <- rownames(income)

ggplot(income, aes(a.LessThan5000,
                   k.150000.or.more,
                   label = NAME, 
                   size = perCapitaFFL)) +
  geom_segment(y = 2732, yend = 2732, 
               x = -100, xend = 10000,
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_segment(y = 2732, yend = 10000, 
               x = 1214, xend = 1214, 
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_point(aes(color = perCapitaFFL)) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 20), 
             guide = F) +
  geom_text(aes(a.LessThan5000,
                k.150000.or.more,
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = income) +
  geom_smooth(method = "lm", se = F, 
              linetype = "dotted",
              color = "cadetblue3",
              size = 0.75) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Annual Income - third and fourth regression tree splits",
       y = "per capita $150,000 or more",
       x = "per capita Less than $5,000",
       color = "per capita FFLs")

# rpart tree 02: outliers removed ---------------------------------------------

# Montana, Alaska, South Dakota, and Wyoming were heavily penalized
# by the robust regression model. 

income$NAME <- rownames(income)

# subset outliers
income.out <- income %>%
  filter(NAME != "Montana", NAME != "Alaska", NAME != "South Dakota", NAME != "Wyoming")

# grow regression tree
income.rpart02 <- rpart(perCapitaFFL ~ .-NAME, data = income.out)

# plot regression tree
par(mfrow = c(1, 1))
rpart.plot(income.rpart02, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(income.out$perCapitaFFL),
           round = 1,
           family = "GillSans")

# the larger the lower-middle class, the more FFLs.
# but the outlier class is significant. 

summary(income.out$g.35000to49999)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    3411    4679    5249    5074    5594    6224

# split threshold: 4973
hist(income.out$g.35000to49999)

summary(income.out$c.10000to14999)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1001    1592    1909    1905    2182    2729 

# split threshold: 1986
hist(income.out$c.10000to14999)

# vis cross validation results
plotcp(income.rpart02)

# vis cross-validation results
par(mfrow = c(1, 2))
rsq.rpart(income.rpart02)

# tree model 02: outliers removed ---------------------------------------------

income.tree02 <- tree(perCapitaFFL ~ .-NAME, data = income.out)

# visualize tree
# plot the tree
par(mfrow = c(1, 1), family = "GillSans")
plot(income.tree02, lty = 3)
text(income.tree02, pretty = 0, cex = 0.9)

# prune the tree
prune.tree02 <- prune.tree(income.tree02, best = 5)

# plot the pruned
par(mfrow = c(1, 1), family = "GillSans")
plot(prune.tree02, lty = 3)
text(prune.tree02, pretty = 0, cex = 0.9)

