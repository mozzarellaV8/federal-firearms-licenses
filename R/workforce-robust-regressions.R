# Workforce-Industry - Robust Regressions
# Federal Firearms License data
# "INDUSTRY BY SEX FOR THE FULL-TIME, YEAR-ROUND CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/
# American Community Survey - Subject Tables - Table S2404
# 2015 American Community Survey 1-Year Estimates

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)
library(MASS)

# load themes and functions
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")

# ffl data and industry per capita data
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
wf <- read.csv("data/04-per-capita-clean/per-capita-workforce.csv", stringsAsFactors = F)
str(wf)

# remove population total variables
wf <- wf %>% select(1:22, 25)
str(wf)

# Robust Regression Model 01  -------------------------------------------------

library(MASS)
wf$NAME <- NULL

wf.rr01 <- rlm(perCapitaFFL ~ Waste.Management + Mining.Oil.Gas + 
                 Finance.Insurance + Construction + Information, data = wf)
summary(wf.rr01)

# check weights
rr01.weights <- data.frame(NAME = rownames(wf),
                           resid = wf.rr01$resid,
                           weight = wf.rr01$w) %>% arrange(weight)

rr01.weights

# rr01: Merge weights and create weighted fit -----------------------------------
rr01.coef <- augment(wf.rr01) %>%
  mutate(NAME = rownames(wf)) %>%
  left_join(rr01.weights) %>%
  mutate(weighted.resid = .resid * weight,
         weighted.fit = .fitted * weight) %>%
  arrange(weight)

# rr01: plot fitted vs observed, arranged by residual size ----------------------

# distribution of absolute residuals
summary(abs(rr01.coef$resid))
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  0.3238  3.4150  6.4290  9.1590 12.0500 38.4200 

# geom_segment is colored with perCapitaFFL
# switch to black when serious
ggplot(rr01.coef, aes(reorder(.rownames, abs(resid)),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr01.coef) +
  geom_point(aes(.rownames, perCapitaFFL),
             shape = 1, 
             size = 4,
             color = "black") +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL,
                    color = abs(resid)), 
                linetype = "solid",
                size = 0.65,
                data = rr01.coef) +
  scale_color_gradient2(low = "black",
                        mid = "antiquewhite2",
                        high = "firebrick",
                        midpoint = 19.2) +
  coord_flip() + pd.theme +
  theme(panel.grid.major = element_line(color = "gray94"),
        axis.text = element_text(size = 12),
        legend.text = element_text(size = 8),
        legend.position = "right",
        legend.box = "horizontal",
        legend.title.align = 1,
        legend.key.size = unit(0.35, "cm"),
        legend.title = element_text(hjust = -1, vjust = -1)) +
  labs(x = "", y = "", color = "",
       title = "FFLs ~ Industry: Weighted Fit vs Observed Values, ordered by Absolute Residuals")

# rr01: plot fitted vs observed, arranged by weighted fit ---------------------

# geom_segment is colored with perCapitaFFL
# switch to black when serious
ggplot(rr01.coef, aes(reorder(.rownames, weighted.fit),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr01.coef) +
  geom_point(aes(.rownames, perCapitaFFL),
             shape = 1, 
             size = 4,
             color = "black") +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL), 
                linetype = "solid",
                size = 0.65,
                data = rr01.coef) +
  scale_color_gradient2(low = "black",
                        mid = "antiquewhite2",
                        high = "firebrick",
                        midpoint = 19.2) +
  coord_flip() + pd.theme +
  theme(panel.grid.major = element_line(color = "gray94"),
        axis.text = element_text(size = 12),
        legend.text = element_text(size = 8),
        legend.position = "right",
        legend.box = "horizontal",
        legend.title.align = 1,
        legend.key.size = unit(0.35, "cm"),
        legend.title = element_text(hjust = -1, vjust = -1)) +
  labs(x = "", y = "", color = "",
       title = "FFLs ~ Industry: Weighted Fit vs Observed Values")

# rr01: plot assigned weights ---------------------------------------------------

# filter for weights < 1
weights <- rr01.coef %>%
  dplyr::select(.rownames, weight) %>%
  filter(weight < 1)

# vector of values for axis labels
round(weights$weight, 2)

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
  scale_y_continuous(breaks = c(0.33, 0.40, 0.46, 0.68, 0.72, 
                                0.77, 0.83, 0.93, 0.98)) +
  pd.theme + 
  theme(axis.title = element_text(size = 12.5),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 45, size = 12,
                                   hjust = 1, vjust = 1)) +
  labs(x = "", y = "assigned weight",
       title = "Federal Firearms Licenses by Industry - Tree Split Variables\nRobust Regression Weights on Outlier States")

# Robust Regression Model 02  -------------------------------------------------
# Robust Regression with Outliers (weight < 0.5) removed

# remove outliers
wf.out <- rr01.coef[-c(1:4), ]

# select original variables
wf.out <- wf.out %>%
  dplyr::select(1:7)

# add states as rownames
rownames(wf.out) <- wf.out$.rownames
wf.out$.rownames <- NULL

# fit robust model
wf.rr02 <- rlm(perCapitaFFL ~ ., data = wf.out)

# check weights
rr02.weights <- data.frame(NAME = rownames(wf.out),
                           resid = wf.rr02$resid,
                           weight = wf.rr02$w) %>% arrange(weight)

rr02.weights
#              NAME        resid    weight
# 1    Rhode Island -17.00764433 0.7833687
# 2    South Dakota  16.70883786 0.7973872
# 3          Hawaii -16.06094596 0.8294473
# 4         Vermont  15.49188618 0.8599883
# 5         Arizona  15.31271248 0.8700380
# 6           Texas -14.31051350 0.9309072
# 7        Missouri  13.65031369 0.9759982
# 8          Oregon  13.53826449 0.9840435

# Weights carry a softer penalty with the larger outliers Montana, Alaska, and Idaho removed.

# Robust Regression Model 03  -------------------------------------------------

# remove general population variable
wf2 <- wf %>%
  dplyr::select(-CivilianPop.16, -POPESTIMATE2015, -POPESTIMATE2016)

str(wf2)

# Robust Regression on all variables
# maxit raised to 40 for all variables
rr03 <- rlm(perCapitaFFL ~ ., data = wf2, maxit = 40)
summary(rr03)
glance(rr03)

# check weights
rr03.weights <- data.frame(NAME = rownames(wf2),
                           resid = rr03$resid,
                           weight = rr03$w) %>% arrange(weight)

rr03.weights

# rr03: bar plot weights ------------------------------------------------------

# filter for weights < 1
weights03 <- rr03.weights %>%
  filter(weight < 1)

# vector of values for y-axis labels
round(weights03$weight, 2)

# barplot of outlier weights by state
rr03.weights %>%
  filter(weight < 1) %>%
  ggplot(aes(reorder(NAME, weight),
             weight,
             fill = weight)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "firebrick4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4",
                       midpoint = 0.5,
                       guide = F) +
  scale_y_continuous(breaks = c(0.14, 0.17, 0.20, 0.23, 0.28, 0.43, 0.48,
                                0.62, 0.66, 0.79, 0.79, 0.85, 0.91, 0.95)) +
  pd.theme + 
  theme(axis.text = element_text(size = 10),
        axis.text.x = element_text(angle = 45, size = 12,
                                   hjust = 1, vjust = 1),
        axis.title = element_text(size = 12.5)) +
  labs(x = "", y = "assigned weight",
       title = "Federal Firearms Licenses by Industry - All Variables\nRobust Regression Weights on Outlier States")

# rr03: Merge weights and create weighted fit -----------------------------------

rr03.coef <- augment(rr03) %>%
  mutate(NAME = rownames(wf)) %>%
  left_join(rr03.weights) %>%
  mutate(weighted.resid = .resid * weight,
         weighted.fit = .fitted * weight) %>%
  arrange(weight)

# rr03: plot fitted vs observed, arranged by residual size ----------------------

ggplot(rr03.coef, aes(reorder(.rownames, abs(resid)),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr03.coef) +
  geom_point(aes(.rownames, perCapitaFFL),
             shape = 1, 
             size = 4) +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL), 
                linetype = "solid",
                size = 0.5) +
  coord_flip() +
  pd.theme +
  theme(panel.grid.major = element_line(color = "gray94"),
        axis.text = element_text(size = 12)) +
  labs(x = "", y = "",
       title = "FFLs ~ Industry: Weighted Fit vs Observed Values, all variables\narranged by absolute residual values")

# rr03: plot fitted vs observed, arranged by weighted fit value ---------------

ggplot(rr03.coef, aes(reorder(.rownames, weighted.fit),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr03.coef) +
  geom_point(aes(.rownames, perCapitaFFL),
             shape = 1, 
             size = 4) +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL), 
                linetype = "solid",
                size = 0.5) +
  coord_flip() +
  pd.theme +
  theme(panel.grid.major = element_line(color = "gray94"),
        axis.text = element_text(size = 12)) +
  labs(x = "", y = "",
       title = "FFLs ~ Industry: Weighted Fit vs Observed Values (all variables)")

