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

# Robust Regression: Outlier ID -----------------------------------------------

library(MASS)

# fit robust model
rr01 <- rlm(perCapitaFFL ~ ., data = income)
rr01

# check weights
rr01.weights <- data.frame(NAME = rownames(income),
                           resid = rr01$resid,
                           weight = rr01$w) %>% arrange(weight)

rr01.weights[1:20, ]
#            NAME       resid    weight
# 1       Montana  57.9554955 0.1677059
# 2        Alaska  41.9383192 0.2317737
# 3  South Dakota  26.6815671 0.3642432
# 4       Wyoming  22.6616821 0.4289978
# 5     Wisconsin -19.1916066 0.5064435
# 6   Connecticut  15.3404753 0.6335840
# 7      Nebraska -14.7089436 0.6607560
# 8        Hawaii -14.2276126 0.6830256
# 9       Indiana -11.7004541 0.8306417
# 10    Minnesota -10.8116808 0.8989420
# 11      Arizona  10.2466120 0.9485886
# 12      Alabama   2.1419139 1.0000000

# RR01: merge and compute weighted fit values ---------------------------------
rr01.coef <- augment(rr01) %>%
  mutate(NAME = rownames(income)) %>%
  left_join(rr01.weights) %>%
  mutate(weighted.resid = .resid * weight,
         weighted.fit = .fitted * weight) %>%
  arrange(weight)

# RR01: plot assigned weights -------------------------------------------------

# filter for weights < 1
weights <- rr01.coef %>%
  dplyr::select(.rownames, weight) %>%
  filter(weight < 1)

# vector of values for axis labels
weight.breaks.01 <- round(weights$weight, 2)

# barplot of outlier weights by state
rr01.coef %>%
  filter(weight < 1) %>%
  ggplot(aes(reorder(.rownames, weight),
             weight,
             fill = weight)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "firebrick4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4",
                       midpoint = 0.75,
                       guide = F) +
  scale_y_continuous(breaks = weight.breaks.01) +
  pd.theme + 
  theme(axis.title = element_text(size = 12.5),
        axis.text.y = element_text(size = 9.5),
        axis.text.x = element_text(angle = 45, size = 12,
                                   hjust = 1, vjust = 1)) +
  labs(x = "", y = "assigned weight",
       title = "Federal Firearms Licenses by Income\nRobust Regression Weights for Outlier States")


# RR01: plot fitted versus observed -------------------------------------------

summary(abs(rr01.coef$resid))
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.101   2.664   4.874   8.105   9.542  57.960 

ggplot(rr01.coef, aes(reorder(.rownames, abs(resid)),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr01.coef) +
  geom_point(aes(.rownames, perCapitaFFL),
             shape = 1, 
             size = 4) +
  geom_point(aes(.rownames, perCapitaFFL),
             shape = 20, 
             size = 2.5) +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL),
                linetype = "solid",
                size = 0.5) +
  coord_flip() +
  pd.theme +
  theme(panel.grid.major = element_line(color = "gray94"),
        axis.text = element_text(size = 12)) +
  labs(x = "", y = "per capita Federal Firearms Licenses",
       title = "FFLs ~ Income: Weighted Fit vs Observed Values, all variables\narranged by absolute residual values")


