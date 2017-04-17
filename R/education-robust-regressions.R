# ATF- FFL - Exploratory Data Analysis
# US Census - American Community Survey - Table S1501
# "Educational Attainment"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)
library(MASS)

# custom plot themes
source("R/00-pd-themes.R")

# total and per capita full-time education data
education <- read.csv("data/04-per-capita-clean/per-capita-education.csv", stringsAsFactors = F)

str(education)
# 50 obs of 55 variables

# select only variables that pertain to HS and BA
# the only data that is complete across age groups
edu <- education %>%
  select(NAME, perCapitaFFL, -POPESTIMATE2015, -POPESTIMATE2016,
         contains("HS"), contains("BA"), -contains("Less"),
         -contains("Male"), -contains("Female"))

str(edu)
# 50 obs of 34 variables

# clean up variable names
colnames(edu) <- gsub("edu.[0-9][0-9].Total", "per.capita", colnames(edu))

# Robust Regression 01 --------------------------------------------------------

# fit robust model
rr01 <- rlm(perCapitaFFL ~ .-NAME, data = edu)
summary(rr01)

# calculate weights
rr01.coef <- data.frame(NAME = edu$NAME,
                        resid = rr01$resid,
                        weight = rr01$w) %>% arrange(weight)

head(rr01.coef)
#      NAME      resid    weight
# 1  Hawaii -52.062688 0.4015925
# 2 Wyoming  45.768302 0.4568538
# 3 Montana  45.079535 0.4638652
# 4  Kansas  21.233736 0.9847722
# 5 Alabama  -4.352671 1.0000000

# Hawaii, Wyoming, Montana, and Kansas are penalized by the robust model. 

# barplot of weighted observations
rr01.coef %>%
  filter(weight < 1) %>%
  ggplot(aes(reorder(NAME, weight), weight, fill = weight)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(high = "deepskyblue4",
                       mid = "antiquewhite2",
                       low = "firebrick4",
                       midpoint = 0.5) +
  scale_y_continuous(breaks = c(0, 0.40, 0.46, 0.98, 1)) +
  pd.theme +
  theme(axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 11)) +
  labs(x = "", y = "weight",
       title = "Educational Attainment - Robust Regression Weights")

# Fitted vs Observed Values
rr01.coef <- left_join(augment(rr01), rr01.coef) %>%
  mutate(weighted.resid = .resid * weight,
         weighted.fit = .fitted * weight) %>%
  arrange(weight)

# Plot weighted fit vs observed values
ggplot(rr01.coef, aes(reorder(NAME, weighted.fit),
                      weighted.fit)) + 
  geom_point(color = "firebrick3", 
             shape = 17, 
             size = 4, 
             data = rr01.coef) +
  geom_point(aes(NAME, perCapitaFFL),
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
  labs(y = "per capita Federal Firearms Licenses", x = "",
       title = "FFLs ~ Education: Weighted Fit vs Observed Values")

