# "Finanacial Characteristics" - Robust Regressions
# US Census - American Community Survey, table S2503.
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/
# Federal Firearms License data

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)
library(MASS)

# load themes and functions
source("~/GitHub/federal-firearms-licenses/R/00-pd-themes.R")

# read in individual CSVs
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
income <- read.csv("data/04-per-capita-clean/per-capita-finance.csv", stringsAsFactors = F)
str(income)

# remove total occupied housing, 
# median household income, 
# and populations variables
# 50 observations of 13 variables
income <- income %>%
  dplyr::select(1, 3:13, 17)

rownames(income) <- income$NAME
income$NAME <- NULL


# Robust Regression: Outlier ID -----------------------------------------------

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

# dotplot with errorbars
ggplot(rr01.coef, aes(reorder(.rownames, abs(resid)),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr01.coef) +
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
  labs(x = "", y = "per capita Federal Firearms Licenses",
       title = "FFLs ~ Income: Weighted Fit vs Observed Values, all variables\narranged by absolute residual values")

# dotplot with errorbars, arranged  by weighted fit
ggplot(rr01.coef, aes(reorder(.rownames, weighted.fit),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr01.coef) +
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
  labs(x = "", y = "per capita Federal Firearms Licenses",
       title = "FFLs ~ Income: Weighted Fit vs Observed Values")

# filter for extremes and scatterplot
rr01.coef %>%
  filter(h.50000to74999 > 7000 | h.50000to74999 < 6900) %>%
  ggplot(aes(h.50000to74999, perCapitaFFL,
             label = .rownames)) +
  geom_point() +
  geom_point(aes(h.50000to74999, weighted.fit), 
             size = 4, shape = 17, color = "red3") +
  geom_text(aes(h.50000to74999, perCapitaFFL,label = .rownames),
            check_overlap = T, size = 3.25, 
            hjust = -0.075, vjust = -0.25) +
  geom_smooth(method = "lm", se = F, 
              color = "cadetblue3",
              linetype = "dotted",
              alpha = 0.25,
              size = 0.75) +
  geom_smooth(method = "rlm", se = F, 
              color = "goldenrod2",
              linetype = "dashed",
              alpha = 0.25,
              size = 0.5) +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL),
                linetype = "solid", 
                alpha = 0.345,
                size = 0.75) +
  pd.scatter +
  theme(axis.text = element_text(size = 11),
        axis.title = element_text(size = 12)) +
  labs(x = "per capita population: $50,000-74,999 annual household income",
       y = "per capita Federal Firearms Licenses: weighted fit and observed")

# Regression With/Out Outliers ------------------------------------------------

# per capita FFL < 80 will subset out AK, MT, and WY
income.in <- income %>%
  mutate(NAME = rownames(income)) %>%
  filter(perCapitaFFL < 80)

rownames(income.in) <- income.in$NAME

# fit regression model
inline.01 <- lm(perCapitaFFL ~ .-NAME, data = income.in)
summary(inline.01)

# plot diagnostics
par(mfrow = c(2, 2), family = "GillSans")
plot(inline.01)

glance(inline.01)
#    r.squared adj.r.squared    sigma statistic      p.value df    logLik      AIC      BIC deviance df.residual
#  1 0.7424814      0.661547 8.041474  9.173866 1.999033e-07 12 -157.7391 341.4782 365.5301 2263.286          35

tidy(inline.01) %>% arrange(p.value)
#                term      estimate    std.error   statistic      p.value
# 1    a.LessThan5000 -0.0454373236  0.010492690 -4.33037882 0.0001188433
# 2  k.150000.or.more -0.0095541884  0.003135242 -3.04735239 0.0043731450
# 3    h.50000to74999 -0.0123039813  0.006397461 -1.92326013 0.0626127853
# 4  j.100000to149999  0.0104234750  0.006192491  1.68324416 0.1012285992
# 5      b.5000to9999  0.0201930645  0.012152112  1.66169171 0.1055072964
# 6       (Intercept) 43.6477955281 28.621248445  1.52501368 0.1362419867
# 7    e.20000to24999  0.0231552401  0.015189283  1.52444586 0.1363833452
# 8    d.15000to19999 -0.0121805811  0.012770897 -0.95377647 0.3467379851
# 9    g.35000to49999  0.0059216828  0.008488742  0.69759253 0.4900405562
# 10   f.25000to34999  0.0044301293  0.011450980  0.38687776 0.7011890780
# 11   i.75000to99999  0.0020370040  0.007101889  0.28682567 0.7759370084
# 12   c.10000to14999  0.0002353679  0.009729670  0.02419074 0.9808378630

inline01.coef <- augment(inline.01)

# plot fitted vs observed in linear model
# subset for absolute residuals greater than 5
inline01.coef %>%
  filter(abs(.resid) > 5) %>%
  ggplot(aes(a.LessThan5000, perCapitaFFL,label = NAME)) +
  geom_errorbar(aes(ymin = .fitted, ymax = perCapitaFFL),
                linetype = "solid", 
                alpha = 0.75, 
                size = 0.5) +
  geom_smooth(method = "lm", se = F,
              color = "cadetblue3",
              linetype = "dotted",
              alpha = 0.2, 
              size = 0.75) +
  geom_smooth(method = "rlm", se = F,
              color = "goldenrod2",
              linetype = "dashed",
              alpha = 0.2, 
              size = 0.5) +
  geom_point(size = 2.75, shape = 21) +
  geom_point(aes(a.LessThan5000, .fitted), 
             fill = "red3", color = "black",
             size = 3.5, shape = 24) +
  geom_text(aes(a.LessThan5000, 
                perCapitaFFL, 
                label = NAME),
            check_overlap = T, 
            size = 3.5,
            hjust = -0.025, 
            vjust = -0.45) +
  expand_limits(x = c(800, 2100)) +
  pd.scatter +
  theme(axis.text = element_text(size = 11),
        axis.title = element_text(size = 11),
        panel.grid.major = element_line(color = "gray95"),
        panel.grid.minor = element_line(color = "gray95")) +
  labs(x = "per capita population: annual household income < $5,000",
       y = "per capita Federal Firearms Licenses")

# Robust Regression without outliers ------------------------------------------

rr02 <- rlm(perCapitaFFL ~ .-NAME, data = income.in)
rr02

# check weights
rr02.weights <- data.frame(NAME = rownames(income.in),
                           resid = rr02$resid,
                           weight = rr02$w) %>% arrange(weight)

rr02.weights
#              NAME       resid    weight
# 1           Idaho  25.1639829 0.4452393
# 2       Wisconsin -12.8276730 0.8733861
# 3    South Dakota  12.6867295 0.8828660

# compute weighted fit
rr02.coef <- augment(rr02) %>%
  left_join(rr02.weights) %>%
  mutate(weighted.resid = .resid * weight,
         weighted.fit = .fitted * weight) %>%
  arrange(weight)

rr02.coef

# plot fitted vs observed

summary(abs(rr02.coef$resid))
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  0.1183  2.2910  5.6180  5.5530  6.7610 25.1600

# dotplot with errorbars
ggplot(rr02.coef, aes(reorder(NAME, weighted.fit), weighted.fit))  +
  geom_point(aes(reorder(NAME, weighted.fit), perCapitaFFL),
             shape = 1, 
             size = 4) +
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4) +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL),
                linetype = "solid",
                size = 0.5) +
  coord_flip() +
  pd.theme +
  theme(panel.grid.major = element_line(color = "gray94"),
        axis.text = element_text(size = 12)) +
  labs(x = "", y = "per capita Federal Firearms Licenses",
       title = "FFLs ~ Income: Weighted Fit vs Observed Values (outliers removed)")

# filter for extremes and scatterplot

summary(rr02.coef$k.150000.or.more)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1699    2843    3229    3805    4704    6972

rr01.coef %>%
  ggplot(aes(k.150000.or.more, perCapitaFFL, label = .rownames)) +
  geom_point(size = 3, shape = 21) +
  geom_point(aes(k.150000.or.more, weighted.fit), 
             size = 3.5, shape = 17, color = "red3") +
  geom_text(aes(k.150000.or.more, 
                perCapitaFFL,
                label = .rownames),
            check_overlap = T,
            hjust = -0.075, vjust = -0.45,
            size = 3.25,
            alpha = 0.7) +
  geom_smooth(method = "lm", se = F, 
              color = "cadetblue3",
              linetype = "dotted",
              alpha = 0.25,
              size = 0.75) +
  geom_smooth(method = "rlm", se = F, 
              color = "goldenrod2",
              linetype = "dashed",
              alpha = 0.25,
              size = 0.5) +
  geom_errorbar(aes(ymin = weighted.fit, 
                    ymax = perCapitaFFL),
                linetype = "solid", 
                alpha = 0.5,
                size = 0.5) +
  expand_limits(x = c(1650, 7300)) +
  pd.scatter +
  theme(axis.text = element_text(size = 11),
        axis.title = element_text(size = 12),
        panel.grid.major = element_line(color = "gray95"),
        panel.grid.minor = element_line(color = "gray95")) +
  labs(x = "per capita population: annual household income $150,000 or more",
       y = "per capita Federal Firearms Licenses: weighted fit and observed")