# Regression Trees - Workforce-Industry
# Federal Firearms License data
# "INDUSTRY BY SEX FOR THE FULL-TIME, YEAR-ROUND CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

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

# Regression Trees ------------------------------------------------------------

# remove NAME
rownames(wf) <- wf$NAME
wf$NAME <- NULL

# rpart - tree 01a - all features ---------------------------------------------
wf.tree01 <- rpart(perCapitaFFL ~ ., data = wf)

rpart.plot(wf.tree01, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(wf$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(wf.tree01)
summary(wf.tree01)

# tree- tree 01b - all features ---------------------------------------------
wf.tree01b <- tree(perCapitaFFL ~ ., data = wf)
print(wf.tree01b)
summary(wf.tree01b)

par(mfrow = c(1, 1), family = "GillSans")
plot(wf.tree01b, lty = 3)
text(wf.tree01b, pretty = 0, cex = 0.9)

# the results are similar to the rpart model, but with more terminal nodes
# and slightly finer grain.


# Scatterplot: Primary & Secondary Rpart Splits -------------------------------

summary(wf$Waste.Management)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   613.7   974.2  1172.0  1177.0  1307.0  1842.0 

summary(wf$Mining.Oil.Gas)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    3.884   41.610   89.730  376.700  346.900 4282.000 

wf$NAME <- rownames(wf)

ggplot(wf, aes(Waste.Management,
               Mining.Oil.Gas,
               label = NAME, 
               size = perCapitaFFL)) +
  geom_segment(x = 936, xend = 936, 
               y = -100, yend = 5000,
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_segment(x = 936, xend = 2200, 
               y = 24.75, yend = 24.75, 
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
  geom_text(aes(Waste.Management,
                Mining.Oil.Gas, 
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = wf) +
  expand_limits(x = c(500, 1900), 
                y = c(0, 4300)) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Workforce Sector - Primary & Secondary Regression Tree Splits",
       x = "Waste Management", y = "Mining, Oil and Gas Extraction",
       color = "per capita FFLs")

# Wyoming appears to be exerting significant influence due to what appears to be 
# a monopoly in the Mining, Oil & Gas industry. How does the distribution look
# with Wyoming removed.

wf.wy <- wf %>%
  filter(NAME != "Wyoming")

summary(wf.wy$Mining.Oil.Gas)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    3.884   41.460   86.700  297.000  331.500 1632.000

# Scatterplot: Third & Fourth Rpart Splits ------------------------------------

summary(wf$Finance.Insurance)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   721.8  1420.0  1777.0  1809.0  2077.0  3365.0 

summary(wf$Construction)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#     1558    2008    2194       2277    2482      3164


ggplot(wf, aes(Finance.Insurance,
               Construction,
               label = NAME, 
               size = perCapitaFFL)) +
  geom_segment(x = 1368, xend = 1368, 
               y = -1000, yend = 5000,
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_segment(x = 1368, xend = 4000, 
               y = 2399, yend = 2399, 
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
  geom_text(aes(Finance.Insurance,
                Construction,
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = wf) +
  expand_limits(x = c(700, 3500), 
                y = c(1500, 3200)) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Workforce Sector - 3rd & 4th Regression Tree Splits",
       x = "Finance & Insurance", y = "Construction",
       color = "per capita FFLs")

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

# RR: Merge weights and create weighted fit -----------------------------------
rr01.coef <- augment(wf.rr01) %>%
  mutate(NAME = rownames(wf)) %>%
  left_join(rr01.weights) %>%
  mutate(weighted.resid = .resid * weight,
         weighted.fit = .fitted * weight) %>%
  arrange(weight)

# RR: plot fitted vs observed, arranged by residual size ----------------------

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

# RR: plot assigned weights ---------------------------------------------------

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
  dplyr::select(-CivilianPop.16)

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
                       midpoint = 0.75,
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

rr03.coef <- augment(wf.rr01) %>%
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

