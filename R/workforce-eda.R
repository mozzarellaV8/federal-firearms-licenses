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
source("R/00-usa-map-prep.R")

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

# Map Per Capita Workforce by State -------------------------------------------

# How does this per capita workforce look spatially?

# Map Preparation:
# merge USA map data with FFL data
perCapitaMap <- left_join(emp.pc, fifty_states, by = "NAME") %>%
  arrange(group, order)

# Map per capita workforce, workforce population color fill
ggplot(perCapitaMap, aes(lon, lat, 
                         group = group,
                         fill = CivilianPop.16)) +
  geom_polygon(color = "white", size = 0.1) +
  scale_fill_gradient2(high = "deepskyblue4",
                       mid = "antiquewhite1",
                       low = "coral4", 
                       midpoint = 32750) +
  coord_map("polyconic") + pd.theme +
  theme(panel.border = element_rect(linetype = "solid", 
                                    fill = NA, 
                                    color = "white"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1),
        legend.position = "right") +
  labs(title = "Per Capita Workforce Population by State", 
       x = "", y = "", fill = "")

# Faceted Plots ---------------------------------------------------------------

# Each industry variable, and how it relates to per capita FFL counts.

# select per capita observations
# create a long dataframe
workforce <- emp.pc %>%
  select(NAME, POPESTIMATE2015, 3:22, perCapitaFFL) %>%
  gather(key = industry, value = perCapitaWorkforce, 3:22)

levels(as.factor(workforce$industry))


# Facet for all variables -----------------------------------------------------
workforce %>% group_by(industry) %>%
  filter(industry != "Workforce") %>%
  ggplot(aes(perCapitaWorkforce, perCapitaFFL, label = NAME)) +
  geom_point(size = 1, alpha = 0.65) +
  geom_smooth(method = "loess", se = F, size = 0.5,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.2,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 2.25, position = "jitter", 
            alpha = 0.75, hjust = 1, vjust = 1,
            check_overlap = T, family = "GillSans") +
  facet_wrap(~ industry, scales = "free_x", ncol = 5) + 
  pd.facet +
  theme(axis.text = element_text(size = 7.5),
        axis.title = element_text(size = 12)) +
  labs(title = "Federal Firearms Licenses ~ Workforce Industry Population, per 100k",
       y = "per capita Federal Firearms Licenses", x = "per capita workforce population")

# Facetted Plot for Variables of Interest - Edit 01 ---------------------------
workforce %>% group_by(industry) %>%
  filter(industry == "Retail.Trade" | industry == "Utilities" | 
           industry == "Information" | industry == "Real.Estate" |
           industry == "Mining.Oil.Gas" | industry == "Hunting.Fishing.Agriculture") %>%
  ggplot(aes(perCapitaWorkforce, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.75, alpha = 0.85) +
  geom_smooth(method = "loess", se = F, size = 0.5,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.2,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 2.25, position = "jitter", 
            alpha = 0.85, hjust = 1.065, vjust = 1,
            check_overlap = T, family = "Open Sans") +
  facet_wrap(~ industry, scales = "free_x", ncol = 2) + 
  pd.facet +
  theme(axis.text = element_text(size = 7.5),
        axis.title = element_text(size = 12)) +
  labs(title = "Federal Firearms Licenses ~ Workforce Industry Population, per 100k",
       y = "per capita Federal Firearms Licenses",
       x = "per capita workforce population")

# Facetted Plot for Variables of Interest - Edit 02 - negative slopes ---------
workforce %>% group_by(industry) %>%
  filter(industry == "Real.Estate" | industry == "Information" | 
           industry == "Finance.Insurance" | industry == "Waste.Management" |
           industry == "Sciences.Technical" | industry == "Management") %>%
  ggplot(aes(perCapitaWorkforce, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.9, alpha = 0.85) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 2.25, position = "jitter", 
            alpha = 0.9, hjust = 1.05, vjust = 1,
            check_overlap = T, family = "Open Sans") +
  facet_wrap(~ industry, scales = "free_x", ncol = 2) + 
  pd.facet +
  theme(panel.background = element_rect(fill = "aliceblue"),
        strip.background = element_rect(fill = "deepskyblue4"),
        strip.text = element_text(color = "white"),
        panel.grid.major = element_line(color = "white"),
        panel.grid.minor = element_line(color = "white"),
        axis.text = element_text(size = 7.5),
        axis.title = element_text(size = 12)) +
  labs(title = "Negative Firearms License Trends ~ Workforce Sector Population",
       y = "per capita Federal Firearms Licenses",
       x = "per capita workforce population")

# Facetted Plot for Variables of Interest - Edit 03 - positive slopes ---------
workforce %>% group_by(industry) %>%
  filter(industry == "Hunting.Fishing.Agriculture" | 
           industry == "Construction" | 
           industry == "Utilities" |
           industry == "Retail.Trade" | 
           industry == "PublicAdministration" |
           industry == "Mining.Oil.Gas") %>%
  ggplot(aes(perCapitaWorkforce, perCapitaFFL, label = NAME)) +
  geom_point(size = 1, alpha = 0.85) +
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 2.5, position = "jitter", 
            alpha = 0.85, hjust = 1.05, vjust = 0.75,
            check_overlap = T, family = "Open Sans") +
  facet_wrap(~ industry, scales = "free_x", ncol = 2) + 
  pd.facet +
  theme(panel.background = element_rect(fill = "aliceblue"),
        strip.background = element_rect(fill = "deepskyblue4"),
        strip.text = element_text(color = "white"),
        panel.grid.major = element_line(color = "white"),
        panel.grid.minor = element_line(color = "white"),
        axis.text = element_text(size = 7.5),
        axis.title = element_text(size = 12)) +
  labs(title = "Positive Firearms License Trends ~ Workforce Sector Population",
       y = "per capita Federal Firearms Licenses",
       x = "per capita workforce population")

# Faceted Plot for Variables of Interest - Edit 04 - Small Effects ------------
workforce %>% group_by(industry) %>%
  filter(industry == "Educational.Services" | industry == "Transportation.Warehousing" | 
           industry == "Arts.Entertainment" | industry == "Foodservice.Accommodation" |
           industry == "Health.Care" | industry == "OtherServices") %>%
  ggplot(aes(perCapitaWorkforce, perCapitaFFL, label = NAME)) +
  geom_point(size = 1, alpha = 0.75) +
  geom_smooth(method = "loess", se = F, size = 0.75,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.5,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 2.25, position = "jitter", 
            alpha = 0.85, hjust = 1.065, vjust = 1,
            check_overlap = T, family = "Open Sans") +
  facet_wrap(~ industry, scales = "free_x", ncol = 2) + 
  pd.facet +
  theme(panel.background = element_rect(fill = "aliceblue"),
        strip.background = element_rect(fill = "deepskyblue4"),
        strip.text = element_text(color = "white"),
        panel.grid.major = element_line(color = "white"),
        panel.grid.minor = element_line(color = "white"),
        axis.text = element_text(size = 7.5),
        axis.title = element_text(size = 12)) +
  labs(title = "Not Much Effect: Firearms License Trends by Workforce Sector",
       y = "per capita Federal Firearms Licenses",
       x = "per capita workforce population")


# Individual Plots: FFLs ~ Workforce Sector -----------------------------------

# After seeing a broad overview of relationships, 
# now to inspect certain individual sectors of the workforce
# to see how they may or may not relate to FFL counts.

# Hunting and Fishing, Agriculture, and Forestry Per Capita -------------------

summary(emp.pc$Hunting.Fishing.Agriculture)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    89.9   261.7   375.9   617.2   775.2  2619.0 

ggplot(emp.pc, 
       aes(Hunting.Fishing.Agriculture, 
           perCapitaFFL, 
           label = NAME)) +
  geom_point(size = 0.9, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.5,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.05, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(0, 3000)) +
  labs(title = "FFLs ~ Workforce Sector: Hunting & Fishing, Forestry, Agriculture", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", 
       fill = "") +
  pd.scatter


# Mining, Quarrying, Oil and Gas Extraction -----------------------------------
summary(emp.pc$Mining.Oil.Gas)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    3.884   41.610   89.730  376.700  346.900 4282.000 

ggplot(emp.pc, aes(Mining.Oil.Gas, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.9, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.5,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.05, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(0, 4500)) +
  labs(title = "FFLs ~ Workforce Sector: Mining, Quarrying, Oil & Gas Extraction", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", 
       fill = "") +
  pd.scatter


# FFLs ~ Waste Management -----------------------------------------------------
summary(emp.pc$Waste.Management)
#  613.7   974.2  1172.0  1177.0  1307.0  1842.0

ggplot(emp.pc, aes(Waste.Management, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.9, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.065, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(600, 1900)) +
  labs(title = "FFLs ~ Workforce Sector: Waste Management", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter + coord_flip()

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

# FFLs ~ Public Administration -------------------------------------------------
summary(emp.pc$PublicAdministration)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1288    1664    1785    2042    2074    5002 

ggplot(emp.pc, aes(PublicAdministration, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.75, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.5,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.15,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.1, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(1200, 5100)) +
  labs(title = "FFLs ~ Workforce Sector: Public Administration", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter

# FFLs ~ Manufacturing --------------------------------------------------------
summary(emp.pc$Manufacturing)

ggplot(emp.pc, aes(Manufacturing, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.75, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.5,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.15,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.1, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(1000, 8500)) +
  labs(title = "FFLs ~ Workforce Sector: Manufacturing", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter

# FFLs ~ Finance ---------------------------------------------------------------

summary(emp.pc$Finance.Insurance)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   721.8  1420.0  1777.0  1809.0  2077.0  3365.0

ggplot(emp.pc, aes(Finance.Insurance, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.75, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.5,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.15,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.1, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(700, 3500)) +
  labs(title = "FFLs ~ Workforce Sector: Finance & Insurance", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter

# FFLs ~ Scientific -----------------------------------------------------------
summary(emp.pc$Sciences.Technical)
#  949.2  1736.0  2051.0  2222.0  2454.0  4373.0

ggplot(emp.pc, aes(Sciences.Technical, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.75, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.5,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.15,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.1, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(900, 4500)) +
  labs(title = "FFLs ~ Workforce Sector: Sciences", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter

# FFLs ~ Utilities ------------------------------------------------------------
summary(emp.pc$Utilities)
#  211.4   323.3   357.6   385.9   429.5   741.8

ggplot(emp.pc, aes(Utilities, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.9, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.4,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.065, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(y = c(0, 120)) +
  labs(title = "FFLs ~ Workforce Sector: Utilities", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter + coord_flip()

# FFLs ~ Transportation & Warehousing -----------------------------------------
summary(emp.pc$Transportation.Warehousing)
#  981.6  1257.0  1424.0  1446.0  1596.0  2041.0

ggplot(emp.pc, aes(Transportation.Warehousing, perCapitaFFL, label = NAME)) +
  geom_point(size = 0.9, shape = 1) + 
  geom_smooth(method = "loess", se = F, size = 0.7,
              linetype = "dotted", color = "red3") +
  geom_smooth(method = "lm", se = F, size = 0.5,
              linetype = "dashed", color = "steelblue3") +
  geom_text(size = 3.25, position = "jitter", 
            alpha = 0.95, hjust = -0.065, vjust = 1,
            check_overlap = T, family = "GillSans") +
  expand_limits(x = c(950, 2100)) +
  labs(title = "FFLs ~ Workforce Sector: Transportation & Warehousing", 
       y = "per capita Federal Firearms Licenses", 
       x = "per capita workforce population", fill = "") +
  pd.scatter

