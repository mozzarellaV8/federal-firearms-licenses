# ATF- FFL - Exploratory Data Analysis
# US Census - American Community Survey - Table S1501
# "Educational Attainment"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)
library(grDevices)

# custom plot themes
source("R/00-pd-themes.R")
source("R/00-usa-map-prep.R")

# total and per capita full-time education data
education <- read.csv("data/04-per-capita-clean/per-capita-education.csv", stringsAsFactors = F)

str(education)
# 50 obs of 55 variables

# select only variables that pertain to HS and BA
# the only data that is complete across age groups
edu <- education %>%
  select(NAME, perCapitaFFL, POPESTIMATE2015, POPESTIMATE2016,
         contains("HS"), contains("BA"), -contains("Less"))

str(edu)
# 50 obs of 34 variables

# clean up variable names
colnames(edu) <- gsub("edu.[0-9][0-9].Total", "per.capita", colnames(edu))

# Regression Trees ------------------------------------------------------------

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

# `rpart` model 02 prep -------------------------------------------------------
# Grow Regression Trees without the gender split in variables
# i.e. work only with total HS and college graudate data

# remove male/female split
edu.tree.all <- edu.tree %>%
  select(-contains("Male"), -contains("Female"), -contains("65"))

# exploratory plot - distribution by education and age bracket
# select age+education varialbes, `gather` into stacked dataframe
edu.tree.all %>%
  select(perCapitaFFL, 2:9) %>%
  gather(key = age.bracket, value = per.capita.total, 2:9) %>%
  ggplot(aes(per.capita.total, perCapitaFFL, fill = perCapitaFFL)) +
  geom_point(aes(fill = perCapitaFFL), shape = 21, size = 1.6) +
  facet_wrap(~ age.bracket, scales = "free_x", ncol = 2) +
  scale_fill_gradient2(low = "deepskyblue3",
                       mid = "antiquewhite2",
                       high = "firebrick3",
                       midpoint = 52, guide = F) +
  pd.facet +
  labs(x = "graduates per 100k", y = "FFLs per 100k")


# `rpart` model 02 ------------------------------------------------------------
edu.rpart02 <- rpart(perCapitaFFL ~ ., data = edu.tree.all)

rpart.plot(edu.rpart02, 
           type = 1, extra = 1, digits = 4, cex = 0.8, 
           branch.lty = 1, branch.lwd = 1.25,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(edu$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(edu.rpart02)
# n = 50 

# node), split, n, deviance, yval
# * denotes terminal node

# 1) root 50 22865.960 31.16886  
# 2) per.capita.18to24.BA>=716.5771 41  6963.186 25.22488  
# 4) per.capita.25to34.BA>=4765.145 15  2386.392 16.74053 *
#   5) per.capita.25to34.BA< 4765.145 26  2874.088 30.11971  
# 10) per.capita.18to24.BA< 966.096 19   953.609 27.35809 *
#   11) per.capita.18to24.BA>=966.096 7  1382.263 37.61553 *
#   3) per.capita.18to24.BA< 716.5771 9  7855.201 58.24696 *

summary(edu.rpart02)
# Variable importance
# per.capita.18to24.BA per.capita.25to34.BA per.capita.35to44.BA per.capita.45to64.BA per.capita.25to34.HS per.capita.35to44.HS per.capita.45to64.HS
#                   35                   26                   17                   14                    4                    3                    1

# Going by Variable Importance as determined by `rpart`, BAs at any age group
# take precedence over HS graduates in any age group. 

# `tree` model 02 ------------------------------------------------------------

edu.tree02 <- tree(perCapitaFFL ~ ., data = edu.tree.all)

par(mfrow = c(1, 1), family = "GillSans")
plot(edu.tree02, branch = 0, lty = 1)
text(edu.tree02, pretty = 0, use.n = T, cex = 0.85)

print(edu.tree02)
summary(edu.tree02)

# `rpart` model 02 regression on splits ---------------------------------------

# create variables based on splits
edu.tree.rpart02 <- edu.tree.all %>%
  mutate(ba.01 = factor(edu.tree.all$per.capita.18to24.BA >= 716.6),
         ba.02 = factor(edu.tree.all$per.capita.25to34.BA >= 4765),
         ba.03 = factor(edu.tree.all$per.capita.18to24.BA < 966.1),
         NAME = rownames(.))

# linear model with interactions
edu.rpart.r2 <- lm(perCapitaFFL ~ ba.01 * ba.02 * ba.03, data = edu.tree.rpart02)
summary(edu.rpart.r2)
# Residuals:
# Min      1Q  Median      3Q     Max 
# -37.125  -8.655  -1.608   7.091  46.478 

# Coefficients: (3 not defined because of singularities)
# Estimate Std. Error t value      Pr(>|t|)    
# (Intercept)                    68.5044     9.2219   7.428 0.00000000237 ***
#   ba.01TRUE                     -30.8889     6.7393  -4.583 0.00003630851 ***
#   ba.02TRUE                     -20.2009     7.7096  -2.620        0.0119 *  
#   ba.03TRUE                     -10.2574     7.3637  -1.393        0.1705    
# ba.01TRUE:ba.02TRUE                 NA         NA      NA            NA    
# ba.01TRUE:ba.03TRUE                 NA         NA      NA            NA    
# ba.02TRUE:ba.03TRUE             0.1462    18.7461   0.008        0.9938    
# ba.01TRUE:ba.02TRUE:ba.03TRUE       NA         NA      NA            NA    

# Residual standard error: 16.65 on 45 degrees of freedom
# Multiple R-squared:  0.4541,	Adjusted R-squared:  0.4056 
# F-statistic: 9.359 on 4 and 45 DF,  p-value: 0.00001363

tidy(edu.rpart.r2)
#                  term    estimate std.error    statistic           p.value
# 1         (Intercept)  68.5044017  9.221946  7.428410655 0.000000002370038
# 2           ba.01TRUE -30.8888741  6.739343 -4.583365611 0.000036308508122
# 3           ba.02TRUE -20.2009191  7.709625 -2.620220884 0.011939020954886
# 4           ba.03TRUE -10.2574405  7.363723 -1.392969269 0.170472878400516
# 5 ba.02TRUE:ba.03TRUE   0.1462391 18.746092  0.007801045 0.993810211651877

# Confirming - the first split being of most important weight. 

# join fitted with observed and plot
edu.tree.rpart02 <- edu.tree.rpart02 %>%
  left_join(augment(edu.rpart.r2))

# plot fitted vs observed
ggplot(edu.tree.rpart02, aes(per.capita.18to24.BA, 
                             perCapitaFFL, 
                             label = NAME)) +
  geom_point(aes(color = perCapitaFFL), size = 2.5) +
  geom_point(aes(per.capita.18to24.BA,
                 .fitted, 
                 color = .fitted),
             shape = 10,
             size = 2.75,
             alpha = 1,
             data = edu.tree.rpart02) +
  geom_errorbar(aes(ymin = .fitted, 
                     ymax = perCapitaFFL), 
                data = edu.tree.rpart02,
                linetype = "solid",
                color = "gray50", 
                alpha = 0.90, 
                size = 0.250) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_fill_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 6), 
             guide = F) +
  geom_text(aes(per.capita.18to24.BA, 
                perCapitaFFL, 
                label = NAME),
            size = 3.25, 
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans",
            data = edu.tree.rpart02) +
  expand_limits(x = c(400, 2000)) +
  pd.scatter + 
  labs(x = "per capita 18-24 year old college graduates",
       y = "per capita Federal Firearms Licenses")

##### TODO: subset NAME for high and low outliers only. 

# Plot rpart split - fitted values --------------------------------------------

ggplot(edu.tree.rpart02, aes(per.capita.18to24.BA, 
                             .fitted, 
                             label = NAME, 
                             size = .fitted)) +
  geom_point(aes(alpha = perCapitaFFL/1000), 
             data = edu.tree.rpart02) +
  geom_point(aes(per.capita.18to24.BA,
                 perCapitaFFL, 
                 size = 6),
             shape = 1,
             data = edu.tree.rpart02) +
  geom_errorbar(aes(ymin = .fitted, 
                    ymax = perCapitaFFL), 
                data = edu.tree.rpart02,
                linetype = "dotted",
                color = "gray50", 
                alpha = 0.75, 
                size = 0.40) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4", 
                       midpoint = 52, 
                       guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 10), 
             guide = F) +
  geom_text(aes(per.capita.18to24.BA, 
                .fitted, 
                label = NAME),
            size = 3.5, 
            hjust = -0.25, vjust = 0, 
            check_overlap = T, 
            family = "GillSans", angle = 45,
            data = edu.tree.rpart02) +
  expand_limits(x = c(400, 2000)) +
  guides(alpha = F) +
  pd.scatter +
  labs(y = "fitted per capita FFLs", 
       x = "18-to-24 college graduates per 100k")

# Decision Tree Split 01: scatterplot -----------------------------------------

# Primary & Secondary split
# scatterplot with labels and decision-tree splits
# state names for labels
ggplot(edu.tree.rpart02, aes(per.capita.18to24.BA, 
                per.capita.25to34.BA, 
                label = NAME, 
                size = perCapitaFFL)) +
  geom_segment(x = 717, xend = 717, y = 0, yend = 10000,
               linetype = "dashed", color = "red3", size = 0.25) +
  geom_segment(x = 717, xend = 10000, y = 4765, yend = 4765, 
               linetype = "dashed", color = "red3", size = 0.25) +
  geom_segment(x = 966, xend = 966, y = 4765, yend = 0, 
               linetype = "dashed", color = "red3", size = 0.25) +
  geom_smooth(method = "lm", se = F, 
              linetype = "dotted",
              color = "cadetblue3",
              size = 0.8) +
  geom_point(aes(color = perCapitaFFL)) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 14), 
             guide = F) +
  geom_text(aes(per.capita.18to24.BA, 
                per.capita.25to34.BA, 
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = edu.tree.rpart02) +
  expand_limits(x = c(400, 2000)) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Educational Attainment - Regression Trees, Primary & Secondary splits",
       x = "per capita 18-24 year old college graduates", 
       y = "per capita 25-34 year old college graduates",
       color = "per capita FFLs")




