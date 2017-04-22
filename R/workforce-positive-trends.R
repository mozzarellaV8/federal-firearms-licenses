# ATF- FFL - Exploratory Data Analysis
# US Census - American Community Survey - Table S2404
# "INDUSTRY BY SEX FOR THE FULL-TIME, YEAR-ROUND CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/


# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# custom plot themes
source("R/00-pd-themes.R")

# total and per capita full-time employment data
employment <- read.csv("~/GitHub/ffl-data/04-total-data-clean/us-census-workforce.csv", stringsAsFactors = F)
emp.pc <- read.csv("data/04-per-capita-clean/per-capita-workforce.csv", stringsAsFactors = F)

str(employment)
# 50 obs of 22 variables
summary(emp.pc)

# Total full-time workforce, 16+ years old
summary(employment$CivilianPop.16)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#   208000   540600  1407000  2090000  2329000 12150000 

# Per Capita full-time workforce, 16+ years old
summary(emp.pc$CivilianPop.16)
#        Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#      28220   31170      32750    32820   34430     37030

# Plot Per Capita Workforce by State ------------------------------------------

# who has the largest workforce per capita? 
ggplot(emp.pc, 
       aes(reorder(NAME, CivilianPop.16), 
           CivilianPop.16, 
           fill = CivilianPop.16)) +
  geom_bar(stat = "identity") + 
  scale_fill_gradient2(low = "coral4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4", 
                       midpoint = 32750) +
  labs(title = "Per Capita Workforce Population ~ State", 
       x = "", y = "workforce population aged 16+",
       fill = "population\nper 100k") +
  pd.theme + coord_flip()

# Individual Plots: FFLs ~ Workforce Sector -----------------------------------

# After seeing a broad overview of relationships, 
# now to inspect certain individual sectors of the workforce
# to see how they may or may not relate to FFL counts.

# Hunting and Fishing, Agriculture, and Forestry Per Capita -------------------

summary(emp.pc$Hunting.Fishing.Agriculture)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    89.9   261.7   375.9   617.2   775.2  2619.0 

ggplot(emp.pc, aes(Hunting.Fishing.Agriculture, 
                   perCapitaFFL, 
                   label = NAME,
                   size = perCapitaFFL)) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  scale_size(name = "per capita FFLs", 
             range = c(2.75, 5.75), 
             guide = F) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4",
                        midpoint = 52,
                        guide = F) +
  geom_point(aes(size = perCapitaFFL, 
                 color = perCapitaFFL), 
             shape = 19,
             alpha = 0.8,
             data = emp.pc) + 
  geom_text(aes(size = perCapitaFFL), 
            position = "jitter", 
            alpha = 0.95, 
            hjust = 0, vjust = 1.1,
            check_overlap = T, 
            family = "OpenSans",
            data = emp.pc) +
  expand_limits(x = c(0, 3000)) +
  labs(title = "Federal Firearms Licenses ~ Industry Sector: Agriculture, Forestry, Hunting & Fishing", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita Utilities workforce", fill = "") +
  pd.scatter +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

# Mining, Quarrying, Oil and Gas Extraction -----------------------------------
summary(emp.pc$Mining.Oil.Gas)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    3.884   41.610   89.730  376.700  346.900 4282.000 

ggplot(emp.pc, aes(Mining.Oil.Gas, 
                   perCapitaFFL, 
                   label = NAME,
                   size = perCapitaFFL)) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  scale_size(name = "per capita FFLs", 
             range = c(2.75, 5.75), 
             guide = F) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4",
                        midpoint = 52,
                        guide = F) +
  geom_point(aes(size = perCapitaFFL, 
                 color = perCapitaFFL), 
             shape = 19,
             alpha = 0.8,
             data = emp.pc) + 
  geom_text(aes(size = perCapitaFFL), 
            position = "jitter", 
            alpha = 0.95, 
            hjust = 0, vjust = 1.1,
            check_overlap = T, 
            family = "OpenSans",
            data = emp.pc) +
  expand_limits(x = c(0, 4800)) +
  labs(title = "Federal Firearms Licenses ~ Industry: Mining, Quarrying, Oil & Gas Extraction", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

# log scale
ggplot(emp.pc, aes(Mining.Oil.Gas, 
                   perCapitaFFL, 
                   label = NAME,
                   size = perCapitaFFL)) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  scale_size(name = "per capita FFLs", 
             range = c(2.75, 5.75), 
             guide = F) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4",
                        midpoint = 52,
                        guide = F) +
  geom_point(aes(size = perCapitaFFL, 
                 color = perCapitaFFL), 
             shape = 19,
             alpha = 0.8,
             data = emp.pc) + 
  geom_text(aes(size = perCapitaFFL), 
            position = "jitter", 
            alpha = 0.95, 
            hjust = 0, vjust = 1.1,
            check_overlap = T, 
            family = "OpenSans",
            data = emp.pc) +
  scale_x_log10() +
  expand_limits(x = c(0, 10000)) +
  labs(title = "Federal Firearms Licenses ~ Industry: Mining, Quarrying, Oil & Gas Extraction", 
       y = "per capita Federal Firearms Licenses", 
       x = "(log) per capita workforce population", fill = "") +
  pd.scatter +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

# FFLs ~ Construction ---------------------------------------------------------
summary(emp.pc$Construction)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1558    2008    2194    2277    2482    3164 

ggplot(emp.pc, aes(Construction, 
                   perCapitaFFL, 
                   label = NAME,
                   size = perCapitaFFL)) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  scale_size(name = "per capita FFLs", 
             range = c(2.75, 5.75), 
             guide = F) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4",
                        midpoint = 52,
                        guide = F) +
  geom_point(aes(size = perCapitaFFL, 
                 color = perCapitaFFL), 
             shape = 19,
             alpha = 0.8,
             data = emp.pc) + 
  geom_text(aes(size = perCapitaFFL), 
            position = "jitter", 
            alpha = 0.95, 
            hjust = 0, vjust = 1.1,
            check_overlap = T, 
            family = "OpenSans",
            data = emp.pc) +
  expand_limits(x = c(1400, 3500)) +
  labs(title = "Federal Firearms Licenses ~ Industry Sector: Construction", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita Construction workforce", fill = "") +
  pd.scatter +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 11))


# FFLs ~ Manufacturing --------------------------------------------------------
summary(emp.pc$Manufacturing)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1050    2962    4310    4109    5100    8181 

ggplot(emp.pc, aes(Manufacturing, 
                   perCapitaFFL, 
                   label = NAME,
                   size = perCapitaFFL)) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  scale_size(name = "per capita FFLs", 
             range = c(2.5, 4), 
             guide = F) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4",
                        midpoint = 52,
                        guide = F) +
  geom_point(aes(size = perCapitaFFL, 
                 color = perCapitaFFL), 
             shape = 19,
             alpha = 0.8,
             data = emp.pc) + 
  geom_text(aes(size = perCapitaFFL), 
            position = "jitter", 
            alpha = 0.95, 
            hjust = 0, vjust = 1.1,
            check_overlap = F, 
            family = "OpenSans",
            data = emp.pc) +
  expand_limits(x = c(1000, 8600)) +
  labs(title = "Federal Firearms Licenses ~ Industry Sector: Manufacturing", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

# FFLs ~ Utilities ------------------------------------------------------------
summary(emp.pc$Utilities)
#  211.4   323.3   357.6   385.9   429.5   741.8

ggplot(emp.pc, aes(Utilities, 
                   perCapitaFFL, 
                   label = NAME,
                   size = perCapitaFFL)) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  scale_size(name = "per capita FFLs", 
             range = c(2.75, 5.75), 
             guide = F) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4",
                        midpoint = 52,
                        guide = F) +
  geom_point(aes(size = perCapitaFFL, 
                 color = perCapitaFFL), 
             shape = 19,
             alpha = 0.8,
             data = emp.pc) + 
  geom_text(aes(size = perCapitaFFL), 
            position = "jitter", 
            alpha = 0.95, 
            hjust = 0, vjust = 1.1,
            check_overlap = T, 
            family = "OpenSans",
            data = emp.pc) +
  expand_limits(x = c(200, 800)) +
  labs(title = "Federal Firearms Licenses ~ Industry Sector: Utilities", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita Utilities workforce", fill = "") +
  pd.scatter +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

